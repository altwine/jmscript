package optimizer

import "core:log"
import "core:mem"
import "core:fmt"
import "core:strconv"
import "core:strings"
import "core:math"
import "core:slice"
import "core:time"

import "../ast"
import "../checker"
import "../error"
import "../lexer"

Optimizer :: struct {
	alloc:		  mem.Allocator,
	files:		  [dynamic]^ast.File,
	symbols:	  ^checker.Symbol_Table,
	current_file: ^ast.File,
	ec:           ^error.Collector,

	scope_symbols_usage: map[^checker.Scope]map[string]bool,
	all_scopes:		     [dynamic]^checker.Scope,
	current_scope:	     ^checker.Scope,
	current_level:	     int,
	scope_to_node:       map[^checker.Scope]^ast.Node,

	node_parent:         map[^ast.Node]^ast.Node,

	symbol_deps:	         map[^checker.Symbol][dynamic]^checker.Symbol,
	reverse_deps:	         map[^checker.Symbol][dynamic]^checker.Symbol,
	symbol_by_name_in_scope: map[^checker.Scope]map[string]^checker.Symbol,

	preserved_symbols:  map[^checker.Symbol]bool,
	unused_warnings:	map[^checker.Symbol]bool,

	pre_walker:		    ^ast.Walker,
	pre_walker_vtable:  ast.Visitor_VTable,

	constant_cache:     map[^ast.Node]Constant_Result,

	anonymous_vars:     map[string]bool,

	inlined_symbols:    map[^checker.Symbol]bool,
	symbol_usage_count: map[^checker.Symbol]int,

	func_calls:		    map[^checker.Symbol][dynamic]^ast.Call_Expr,
	call_to_func:		map[^ast.Call_Expr]^checker.Symbol,

	deep_analyzer: ^Deep_Analyzer,

	deferred_operations: [dynamic]Deferred_Operation,
	operation_counter:   int,
	nodes_to_remove:     map[^ast.Node]bool,

	flow_analyzer:       ^Flow_Analyzer,

	const_prop_candidates:  map[^checker.Symbol]Constant_Result,
	variables_to_convert:   map[^checker.Symbol]bool,
	variables_to_replace:   map[^checker.Symbol]bool,
	visited_in_propagation: map[^ast.Node]bool,
}

Operation_Type :: enum {
	Remove_Node,
	Replace_Node,
	Append_Statements,
	Replace_Expression,
	Remove_Symbol,
	Move_Node,
	Insert_Node,
	Swap_Nodes,
}

Node_Selector :: union {
	^ast.Node,
	struct {
		block: ^ast.Block_Stmt,
		index: int,
	},
}

Insert_Position :: union {
	int,
	enum {
		Before_Node,
		After_Node,
		At_Beginning,
		At_End,
	},
}

Deferred_Operation :: struct {
	type:        Operation_Type,
	priority:    int,

	selector:    Node_Selector,
	replacement: ^ast.Node,

	block_to_clear:       ^ast.Block_Stmt,
	target_block:         ^ast.Block_Stmt,
	statements_to_append: []^ast.Stmt,

	symbol: ^checker.Symbol,
	scope:  ^checker.Scope,

	source_node:     ^ast.Node,
	target_parent:   ^ast.Node,
	target_position: Insert_Position,
	relative_node:   ^ast.Node,

	node_a: ^ast.Node,
	node_b: ^ast.Node,

	container_node: ^ast.Node,
	extracted_stmt: ^ast.Stmt,

	reason:         string,
	source_context: ^Deep_Expression_Context,
}

EPSILON :: 1e-12

Constant_Value :: union {
	bool,
	i64,
	f64,
	string,
}

Constant_Result :: struct {
	value:       Constant_Value,
	is_constant: bool,
	type_kind:   checker.Type_Kind,
}

optimizer_init :: proc(o: ^Optimizer, ec: ^error.Collector, allocator := context.allocator) {
	o.alloc = allocator
	o.ec = ec
	o.scope_symbols_usage = make(map[^checker.Scope]map[string]bool, allocator)
	o.all_scopes = make([dynamic]^checker.Scope, allocator)

	o.node_parent = make(map[^ast.Node]^ast.Node, allocator)
	o.symbol_by_name_in_scope = make(map[^checker.Scope]map[string]^checker.Symbol, allocator)
	o.symbol_deps = make(map[^checker.Symbol][dynamic]^checker.Symbol, allocator)
	o.reverse_deps = make(map[^checker.Symbol][dynamic]^checker.Symbol, allocator)
	o.preserved_symbols = make(map[^checker.Symbol]bool, allocator)
	o.unused_warnings = make(map[^checker.Symbol]bool, allocator)
	o.constant_cache = make(map[^ast.Node]Constant_Result, allocator)
	o.inlined_symbols = make(map[^checker.Symbol]bool, allocator)
	o.symbol_usage_count = make(map[^checker.Symbol]int, allocator)
	o.anonymous_vars = make(map[string]bool, allocator)
	o.func_calls = make(map[^checker.Symbol][dynamic]^ast.Call_Expr, allocator)
	o.call_to_func = make(map[^ast.Call_Expr]^checker.Symbol, allocator)
	o.const_prop_candidates = make(map[^checker.Symbol]Constant_Result, allocator)
	o.variables_to_convert = make(map[^checker.Symbol]bool, allocator)
	o.variables_to_replace = make(map[^checker.Symbol]bool, allocator)
	o.visited_in_propagation = make(map[^ast.Node]bool, allocator)
	o.scope_to_node = make(map[^checker.Scope]^ast.Node, allocator)

	o.pre_walker_vtable = ast.Visitor_VTable{
		visit_ident = _visit_ident,
		visit_call_expr = _visit_call_expr,
		visit_func_stmt = _visit_func_stmt,
		visit_event_stmt = _visit_event_stmt,
		visit_value_decl = _visit_value_decl,
		visit_basic_lit = _visit_basic_lit,
		before_visit_node = _before_visit_node,
		after_visit_node = _after_visit_node,
		before_visit_child = _before_visit_child,
		after_visit_child = _after_visit_child,
	}

	o.pre_walker = new(ast.Walker, allocator)
	ast.walker_init(o.pre_walker, &o.pre_walker_vtable, allocator)
	o.pre_walker.user_data = o

	deep_analyzer_init(o)
	init_deferred_system(o)
	flow_analyzer_init(o)
}

init_deferred_system :: proc(o: ^Optimizer) {
	o.deferred_operations = make([dynamic]Deferred_Operation, o.alloc)
	o.nodes_to_remove = make(map[^ast.Node]bool, o.alloc)
}

create_operation :: proc(o: ^Optimizer, op: Deferred_Operation) -> int {
	op := op
	op.priority = o.operation_counter
	o.operation_counter += 1
	append(&o.deferred_operations, op)
	return len(o.deferred_operations) - 1
}

schedule_node_removal :: proc(o: ^Optimizer, node: ^ast.Node, reason: string, ctx: ^Deep_Expression_Context = nil) -> int {
	op := Deferred_Operation{
		type = .Remove_Node,
		selector = node,
		reason = reason,
		source_context = ctx,
	}
	o.nodes_to_remove[node] = true
	return create_operation(o, op)
}

schedule_node_replacement :: proc(o: ^Optimizer, old_node, new_node: ^ast.Node, reason: string, ctx: ^Deep_Expression_Context = nil) -> int {
	op := Deferred_Operation{
		type = .Replace_Node,
		selector = old_node,
		replacement = new_node,
		reason = reason,
		source_context = ctx,
	}
	return create_operation(o, op)
}

schedule_statements_append :: proc(o: ^Optimizer, block: ^ast.Block_Stmt, statements: []^ast.Stmt, reason: string, ctx: ^Deep_Expression_Context = nil) -> int {
	op := Deferred_Operation{
		type = .Append_Statements,
		target_block = block,
		statements_to_append = statements,
		reason = reason,
		source_context = ctx,
	}
	return create_operation(o, op)
}

schedule_expression_replacement :: proc(o: ^Optimizer, parent: ^ast.Node, old_expr, new_expr: ^ast.Expr, reason: string, ctx: ^Deep_Expression_Context = nil) -> int {
	op := Deferred_Operation{
		type = .Replace_Expression,
		selector = parent,
		replacement = new_expr,
		reason = reason,
		source_context = ctx,
	}
	return create_operation(o, op)
}

schedule_node_move :: proc(
	o: ^Optimizer,
	node: ^ast.Node,
	new_parent: ^ast.Node,
	position: Insert_Position = .At_End,
	relative_to: ^ast.Node = nil,
	reason: string = "",
	ctx: ^Deep_Expression_Context = nil,
) -> int {
	op := Deferred_Operation{
		type = .Move_Node,
		source_node = node,
		target_parent = new_parent,
		target_position = position,
		relative_node = relative_to,
		reason = reason,
		source_context = ctx,
	}
	return create_operation(o, op)
}

schedule_node_insert :: proc(
	o: ^Optimizer,
	node: ^ast.Node,
	parent: ^ast.Node,
	position: Insert_Position = .At_End,
	relative_to: ^ast.Node = nil,
	reason: string = "",
	ctx: ^Deep_Expression_Context = nil,
) -> int {
	op := Deferred_Operation{
		type = .Insert_Node,
		source_node = node,
		target_parent = parent,
		target_position = position,
		relative_node = relative_to,
		reason = reason,
		source_context = ctx,
	}
	return create_operation(o, op)
}

schedule_nodes_swap :: proc(
	o: ^Optimizer,
	node_a, node_b: ^ast.Node,
	reason: string = "",
	ctx: ^Deep_Expression_Context = nil,
) -> int {
	op := Deferred_Operation{
		type = .Swap_Nodes,
		node_a = node_a,
		node_b = node_b,
		reason = reason,
		source_context = ctx,
	}
	return create_operation(o, op)
}

@(private="file")
_before_visit_child :: proc(v: ^ast.Visitor, parent, child: ^ast.Node) -> bool {
	o := cast(^Optimizer)v.user_data
	if child != nil && parent != nil {
		o.node_parent[child] = parent
	}

	if child != nil {
		enter_scope_for_node(o, child)
	}
	return true
}

@(private="file")
_after_visit_child :: proc(v: ^ast.Visitor, parent, child: ^ast.Node) {
	o := cast(^Optimizer)v.user_data
	if child != nil {
		exit_scope_for_node(o, child)
	}
}

@(private="file")
_before_visit_node :: proc(v: ^ast.Visitor, node: ^ast.Node) -> bool {
	o := cast(^Optimizer)v.user_data
	if scope, exists := o.symbols.node_scopes[node.id]; exists {
		o.scope_to_node[scope] = node
	}
	enter_scope_for_node(o, node)
	return true
}

@(private="file")
_after_visit_node :: proc(v: ^ast.Visitor, node: ^ast.Node) {
	o := cast(^Optimizer)v.user_data
	exit_scope_for_node(o, node)
}

@(private="file")
_visit_basic_lit :: proc(v: ^ast.Visitor, node: ^ast.Basic_Lit) {
	o := cast(^Optimizer)v.user_data
	if node.tok.kind == .Number {
		check_numeric_literal_overflow(o, node.tok.content, node.pos, node.end)
	}
}

enter_scope_for_node :: proc(o: ^Optimizer, node: ^ast.Node) -> bool {
	if node == nil {
		return false
	}

	if scope, exists := o.symbols.node_scopes[node.id]; exists {
		o.current_scope = scope
		o.current_level = scope.level
		return true
	}

	return false
}

exit_scope_for_node :: proc(o: ^Optimizer, node: ^ast.Node) {
	if node == nil {
		return
	}

	if scope, exists := o.symbols.node_scopes[node.id]; exists && scope.parent != nil {
		o.current_scope = scope.parent
		o.current_level = scope.parent.level
	}
}

count_all_symbol_usage :: proc(o: ^Optimizer) {
	clear(&o.symbol_usage_count)
	for file in o.files {
		count_symbol_usage_in_file(o, file)
	}
}

count_symbol_usage_in_file :: proc(o: ^Optimizer, file: ^ast.File) {
	for decl in file.decls {
		count_symbol_usage_in_node(o, decl)
	}
}

count_symbol_usage_in_node :: proc(o: ^Optimizer, node: ^ast.Node) {
	if node == nil { return }

	saved_scope := o.current_scope
	saved_level := o.current_level

	if scope, exists := o.symbols.node_scopes[node.id]; exists {
		o.current_scope = scope
		o.current_level = scope.level
	}

	#partial switch n in node.derived {
	case ^ast.Ident:
		sym := find_symbol_in_scopes(o, n.name, o.current_scope)
		if sym != nil {
			increment_symbol_usage(o, sym)
		}

	case ^ast.Call_Expr:
		if ident, is_ident := n.expr.derived.(^ast.Ident); is_ident {
			sym := find_symbol_in_scopes(o, ident.name, o.current_scope)
			if sym != nil {
				increment_symbol_usage(o, sym)
			}
		}
		for arg in n.args {
			count_symbol_usage_in_node(o, arg)
		}

	case ^ast.File:
		for decl in n.decls {
			count_symbol_usage_in_node(o, decl)
		}

	case ^ast.Block_Stmt:
		for stmt in n.stmts {
			count_symbol_usage_in_node(o, stmt)
		}

	case ^ast.Value_Decl:
		if n.name == "_" && n.value != nil {
			count_symbol_usage_in_node(o, n.value)
			collect_symbols_from_expr(o, n.value)
		} else {
			if n.value != nil {
				count_symbol_usage_in_node(o, n.value)
			}
		}

	case ^ast.Assign_Stmt:
		if n.name == "_" && n.expr != nil {
			count_symbol_usage_in_node(o, n.expr)
			collect_symbols_from_expr(o, n.expr)
		} else {
			if n.expr != nil {
				count_symbol_usage_in_node(o, n.expr)
			}
		}

	case ^ast.Binary_Expr:
		count_symbol_usage_in_node(o, n.left)
		count_symbol_usage_in_node(o, n.right)

	case ^ast.Unary_Expr:
		count_symbol_usage_in_node(o, n.expr)

	case ^ast.Paren_Expr:
		count_symbol_usage_in_node(o, n.expr)

	case ^ast.If_Stmt:
		if n.init != nil {
			count_symbol_usage_in_node(o, n.init)
		}

		if n.cond != nil {
			count_symbol_usage_in_node(o, n.cond)
		}

		if n.body != nil {
			saved_if_scope := o.current_scope
			saved_if_level := o.current_level

			if scope, exists := o.symbols.node_scopes[n.body.id]; exists {
				o.current_scope = scope
				o.current_level = scope.level
			}

			count_symbol_usage_in_node(o, n.body)

			o.current_scope = saved_if_scope
			o.current_level = saved_if_level
		}

		if n.else_stmt != nil {
			saved_else_scope := o.current_scope
			saved_else_level := o.current_level

			if scope, exists := o.symbols.node_scopes[n.else_stmt.id]; exists {
				o.current_scope = scope
				o.current_level = scope.level
			}

			count_symbol_usage_in_node(o, n.else_stmt)

			o.current_scope = saved_else_scope
			o.current_level = saved_else_level
		}

	case ^ast.For_Stmt:
		if n.init != nil {
			for ident in n.init {
				count_symbol_usage_in_node(o, ident)
			}
		}

		if n.cond != nil {
			count_symbol_usage_in_node(o, n.cond)
		}

		if n.second_cond != nil {
			count_symbol_usage_in_node(o, n.second_cond)
		}

		if n.post != nil {
			count_symbol_usage_in_node(o, n.post)
		}

		if n.body != nil {
			saved_for_scope := o.current_scope
			saved_for_level := o.current_level

			if scope, exists := o.symbols.node_scopes[n.body.id]; exists {
				o.current_scope = scope
				o.current_level = scope.level
			}

			count_symbol_usage_in_node(o, n.body)

			o.current_scope = saved_for_scope
			o.current_level = saved_for_level
		}

	case ^ast.Func_Stmt:
		if n.params != nil {
			saved_params_scope := o.current_scope
			saved_params_level := o.current_level

			if scope, exists := o.symbols.node_scopes[n.id]; exists {
				o.current_scope = scope
				o.current_level = scope.level
			}

			o.current_scope = saved_params_scope
			o.current_level = saved_params_level
		}

		if n.body != nil {
			saved_body_scope := o.current_scope
			saved_body_level := o.current_level

			if scope, exists := o.symbols.node_scopes[n.body.id]; exists {
				o.current_scope = scope
				o.current_level = scope.level
			}

			count_symbol_usage_in_node(o, n.body)

			o.current_scope = saved_body_scope
			o.current_level = saved_body_level
		}

	case ^ast.Event_Stmt:
		if n.params != nil {
			saved_params_scope := o.current_scope
			saved_params_level := o.current_level

			if scope, exists := o.symbols.node_scopes[n.id]; exists {
				o.current_scope = scope
				o.current_level = scope.level
			}

			o.current_scope = saved_params_scope
			o.current_level = saved_params_level
		}

		if n.body != nil {
			saved_body_scope := o.current_scope
			saved_body_level := o.current_level

			if scope, exists := o.symbols.node_scopes[n.body.id]; exists {
				o.current_scope = scope
				o.current_level = scope.level
			}

			count_symbol_usage_in_node(o, n.body)

			o.current_scope = saved_body_scope
			o.current_level = saved_body_level
		}

	case ^ast.Member_Access_Expr:
		count_symbol_usage_in_node(o, n.expr)
		if ident, is_ident := n.field.derived.(^ast.Ident); is_ident {
			sym := find_symbol_in_scopes(o, ident.name, o.current_scope)
			if sym != nil {
				increment_symbol_usage(o, sym)
			}
		}

	case ^ast.Index_Expr:
		count_symbol_usage_in_node(o, n.expr)
		count_symbol_usage_in_node(o, n.index)

	case ^ast.Field_Value:
		count_symbol_usage_in_node(o, n.field)
		count_symbol_usage_in_node(o, n.value)

	case ^ast.Return_Stmt:
		if n.result != nil {
			count_symbol_usage_in_node(o, n.result)
		}

	case ^ast.Defer_Stmt:
		count_symbol_usage_in_node(o, n.stmt)

	case ^ast.Expr_Stmt:
		if n.expr != nil {
			count_symbol_usage_in_node(o, n.expr)
		}
	case ^ast.Argument:
		if n.name != "" && n.name != "_" {
			sym := find_symbol_in_scopes(o, n.name, o.current_scope)
			if sym != nil {
				increment_symbol_usage(o, sym)
			}
		}

		if n.value != nil {
			count_symbol_usage_in_node(o, n.value)
		}
	}

	o.current_scope = saved_scope
	o.current_level = saved_level
}

increment_symbol_usage :: proc(o: ^Optimizer, sym: ^checker.Symbol) {
	if sym == nil { return }

	if count, exists := o.symbol_usage_count[sym]; exists {
		o.symbol_usage_count[sym] = count + 1
	} else {
		o.symbol_usage_count[sym] = 1
	}
}

collect_function_calls :: proc(o: ^Optimizer) {
	for file in o.files {
		collect_calls_in_node(o, cast(^ast.Node)file)
	}
}

collect_calls_in_node :: proc(o: ^Optimizer, node: ^ast.Node) {
	if node == nil { return }

	#partial switch n in node.derived {
	case ^ast.Call_Expr:
		call := n
		if ident, is_ident := call.expr.derived.(^ast.Ident); is_ident {
			sym := find_symbol_in_scopes(o, ident.name, o.current_scope)
			if sym != nil && sym.type.kind == .Function {
				o.call_to_func[call] = sym

				if _, exists := o.func_calls[sym]; !exists {
					o.func_calls[sym] = make([dynamic]^ast.Call_Expr, o.alloc)
				}
				append(&o.func_calls[sym], call)
			}
		}

		for arg in call.args {
			collect_calls_in_node(o, arg)
		}

	case ^ast.File:
		for decl in n.decls {
			collect_calls_in_node(o, decl)
		}

	case ^ast.Block_Stmt:
		for stmt in n.stmts {
			collect_calls_in_node(o, stmt)
		}

	case ^ast.If_Stmt:
		if n.cond != nil {
			collect_calls_in_node(o, n.cond)
		}
		if n.body != nil {
			collect_calls_in_node(o, n.body)
		}
		if n.else_stmt != nil {
			collect_calls_in_node(o, n.else_stmt)
		}

	case ^ast.For_Stmt:
		if n.cond != nil {
			collect_calls_in_node(o, n.cond)
		}
		if n.body != nil {
			collect_calls_in_node(o, n.body)
		}

	case ^ast.Func_Stmt:
		if n.body != nil {
			saved_scope := o.current_scope
			saved_level := o.current_level

			if scope, exists := o.symbols.node_scopes[n.id]; exists {
				o.current_scope = scope
				o.current_level = scope.level
			}

			collect_calls_in_node(o, n.body)

			o.current_scope = saved_scope
			o.current_level = saved_level
		}

	case ^ast.Event_Stmt:
		if n.body != nil {
			saved_scope := o.current_scope
			saved_level := o.current_level

			if scope, exists := o.symbols.node_scopes[n.id]; exists {
				o.current_scope = scope
				o.current_level = scope.level
			}

			collect_calls_in_node(o, n.body)

			o.current_scope = saved_scope
			o.current_level = saved_level
		}

	case ^ast.Value_Decl:
		if n.value != nil {
			collect_calls_in_node(o, n.value)
		}

	case ^ast.Expr_Stmt:
		if n.expr != nil {
			collect_calls_in_node(o, n.expr)
		}

	case ^ast.Assign_Stmt:
		if n.expr != nil {
			collect_calls_in_node(o, n.expr)
		}

	case ^ast.Return_Stmt:
		if n.result != nil {
			collect_calls_in_node(o, n.result)
		}

	case ^ast.Binary_Expr:
		collect_calls_in_node(o, n.left)
		collect_calls_in_node(o, n.right)

	case ^ast.Unary_Expr:
		collect_calls_in_node(o, n.expr)

	case ^ast.Paren_Expr:
		collect_calls_in_node(o, n.expr)

	case ^ast.Index_Expr:
		collect_calls_in_node(o, n.expr)
		collect_calls_in_node(o, n.index)

	case ^ast.Member_Access_Expr:
		collect_calls_in_node(o, n.expr)
	}
}

collect_symbols_from_expr :: proc(o: ^Optimizer, expr: ^ast.Expr) {
	if expr == nil { return }

	saved_scope := o.current_scope
	saved_level := o.current_level

	if scope, exists := o.symbols.node_scopes[expr.id]; exists {
		o.current_scope = scope
		o.current_level = scope.level
	}

	#partial switch n in expr.derived {
	case ^ast.Ident:
		sym := find_symbol_in_scopes(o, n.name, o.current_scope)
		if sym != nil {
			o.anonymous_vars[sym.name] = true
		}

	case ^ast.Call_Expr:
		if ident, is_ident := n.expr.derived.(^ast.Ident); is_ident {
			sym := find_symbol_in_scopes(o, ident.name, o.current_scope)
			if sym != nil {
				o.anonymous_vars[sym.name] = true
			}
		}
		for arg in n.args {
			collect_symbols_from_expr(o, arg.value)
		}

	case ^ast.Binary_Expr:
		collect_symbols_from_expr(o, n.left)
		collect_symbols_from_expr(o, n.right)

	case ^ast.Unary_Expr:
		collect_symbols_from_expr(o, n.expr)

	case ^ast.Paren_Expr:
		collect_symbols_from_expr(o, n.expr)

	case ^ast.Member_Access_Expr:
		collect_symbols_from_expr(o, n.expr)

	case ^ast.Index_Expr:
		collect_symbols_from_expr(o, n.expr)
		collect_symbols_from_expr(o, n.index)

	case ^ast.Field_Value:
		collect_symbols_from_expr(o, n.field)
		collect_symbols_from_expr(o, n.value)
	}

	o.current_scope = saved_scope
	o.current_level = saved_level
}

can_inline_symbol :: proc(o: ^Optimizer, sym: ^checker.Symbol) -> bool {
	if is_symbol_public(sym) {
		return false
	}

	if flags_field, has := sym.metadata["flags"]; has {
		if flags, ok := flags_field.(checker.Flags); ok {
			if .BUILTIN in flags || .NATIVE in flags {
				return false
			}
		}
	}

	if !sym.is_const {
		return false
	}

	if count, exists := &o.symbol_usage_count[sym]; exists {
		return count^ == 1
	}

	return false
}

build_parent_tree :: proc(o: ^Optimizer) {
	for file in o.files {
		build_parent_tree_for_node(o, file, nil)
	}
}

build_parent_tree_for_node :: proc(o: ^Optimizer, node: ^ast.Node, parent: ^ast.Node) {
	if node == nil { return }

	if parent != nil {
		o.node_parent[node] = parent
	}

	#partial switch n in node.derived {
	case ^ast.File:
		for decl in n.decls {
			build_parent_tree_for_node(o, decl, node)
		}

	case ^ast.Block_Stmt:
		for stmt in n.stmts {
			build_parent_tree_for_node(o, stmt, node)
		}

	case ^ast.Func_Stmt:
		for &anno in n.annotations {
			build_parent_tree_for_node(o, &anno, node)
		}
		build_parent_tree_for_node(o, n.params, node)
		build_parent_tree_for_node(o, n.body, node)

	case ^ast.Event_Stmt:
		for &anno in n.annotations {
			build_parent_tree_for_node(o, &anno, node)
		}
		build_parent_tree_for_node(o, n.params, node)
		build_parent_tree_for_node(o, n.body, node)

	case ^ast.If_Stmt:
		for &anno in n.annotations {
			build_parent_tree_for_node(o, &anno, node)
		}
		build_parent_tree_for_node(o, n.init, node)
		build_parent_tree_for_node(o, n.cond, node)
		build_parent_tree_for_node(o, n.body, node)
		build_parent_tree_for_node(o, n.else_stmt, node)

	case ^ast.For_Stmt:
		for &anno in n.annotations {
			build_parent_tree_for_node(o, &anno, node)
		}
		if n.init != nil {
			for ident in n.init {
				build_parent_tree_for_node(o, ident, node)
			}
		}
		build_parent_tree_for_node(o, n.cond, node)
		build_parent_tree_for_node(o, n.second_cond, node)
		build_parent_tree_for_node(o, n.post, node)
		build_parent_tree_for_node(o, n.body, node)

	case ^ast.Value_Decl:
		for &anno in n.annotations {
			build_parent_tree_for_node(o, &anno, node)
		}
		build_parent_tree_for_node(o, n.value, node)

	case ^ast.Expr_Stmt:
		for &anno in n.annotations {
			build_parent_tree_for_node(o, &anno, node)
		}
		build_parent_tree_for_node(o, n.expr, node)

	case ^ast.Assign_Stmt:
		for &anno in n.annotations {
			build_parent_tree_for_node(o, &anno, node)
		}
		build_parent_tree_for_node(o, n.expr, node)

	case ^ast.Return_Stmt:
		for &anno in n.annotations {
			build_parent_tree_for_node(o, &anno, node)
		}
		build_parent_tree_for_node(o, n.result, node)

	case ^ast.Defer_Stmt:
		for &anno in n.annotations {
			build_parent_tree_for_node(o, &anno, node)
		}
		build_parent_tree_for_node(o, n.stmt, node)

	case ^ast.Call_Expr:
		build_parent_tree_for_node(o, n.expr, node)
		for arg in n.args {
			build_parent_tree_for_node(o, arg, node)
		}

	case ^ast.Binary_Expr:
		build_parent_tree_for_node(o, n.left, node)
		build_parent_tree_for_node(o, n.right, node)

	case ^ast.Unary_Expr:
		build_parent_tree_for_node(o, n.expr, node)

	case ^ast.Paren_Expr:
		build_parent_tree_for_node(o, n.expr, node)

	case ^ast.Member_Access_Expr:
		build_parent_tree_for_node(o, n.expr, node)
		build_parent_tree_for_node(o, n.field, node)

	case ^ast.Index_Expr:
		build_parent_tree_for_node(o, n.expr, node)
		build_parent_tree_for_node(o, n.index, node)

	case ^ast.Field_Value:
		build_parent_tree_for_node(o, n.field, node)
		build_parent_tree_for_node(o, n.value, node)

	case ^ast.Annotation:
		build_parent_tree_for_node(o, n.value, node)

	case ^ast.Argument:
		build_parent_tree_for_node(o, n.value, node)

	case ^ast.Param_List:
		for param in n.list {
			build_parent_tree_for_node(o, param, node)
		}
	}
}

find_parent_block :: proc(o: ^Optimizer, node: ^ast.Node) -> ^ast.Block_Stmt {
	current := node
	for current != nil {
		parent, exists := o.node_parent[current]
		if !exists { break }

		if block, is_block := parent.derived.(^ast.Block_Stmt); is_block {
			return block
		}
		current = parent
	}
	return nil
}

remove_node_from_parent :: proc(o: ^Optimizer, node: ^ast.Node) -> bool {
	parent, exists := o.node_parent[node]
	if !exists || parent == nil { return false }

	if scope, exists2 := o.symbols.node_scopes[node.id]; exists2 {
		for sym in scope.symbols {
			if sym.decl_node == node {
				if parent_scope := scope.parent; parent_scope != nil {
					for i := 0; i < len(parent_scope.symbols); i += 1 {
						if parent_scope.symbols[i] == sym {
							ordered_remove(&parent_scope.symbols, i)
							break
						}
					}
				}
			}
		}
		delete_key(&o.symbols.node_scopes, node.id)
	}

	#partial switch p in parent.derived {
	case ^ast.File:
		file := p
		for i := 0; i < len(file.decls); i += 1 {
			if cast(uintptr)file.decls[i] == cast(uintptr)node {
				new_decls := make([dynamic]^ast.Stmt, len(file.decls)-1, o.alloc)
				copy(new_decls[:], file.decls[:i])
				copy(new_decls[i:], file.decls[i+1:])
				file.decls = new_decls

				delete_key(&o.node_parent, node)
				return true
			}
		}

	case ^ast.Block_Stmt:
		block := p
		for i := 0; i < len(block.stmts); i += 1 {
			if cast(uintptr)block.stmts[i] == cast(uintptr)node {
				new_stmts := make([dynamic]^ast.Stmt, len(block.stmts)-1, o.alloc)
				copy(new_stmts[:], block.stmts[:i])
				copy(new_stmts[i:], block.stmts[i+1:])
				block.stmts = new_stmts[:]

				delete_key(&o.node_parent, node)
				return true
			}
		}

	case ^ast.If_Stmt:
		if_stmt := p
		if cast(uintptr)if_stmt.init == cast(uintptr)node {
			if_stmt.init = nil
			delete_key(&o.node_parent, node)
			return true
		}
		if cast(uintptr)if_stmt.body == cast(uintptr)node {
			if_stmt.body = nil
			delete_key(&o.node_parent, node)
			return true
		}
		if cast(uintptr)if_stmt.else_stmt == cast(uintptr)node {
			if_stmt.else_stmt = nil
			delete_key(&o.node_parent, node)
			return true
		}

	case ^ast.For_Stmt:
		for_stmt := p
		if for_stmt.init != nil {
			for i := 0; i < len(for_stmt.init); i += 1 {
				if cast(uintptr)for_stmt.init[i] == cast(uintptr)node {
					new_init := make([dynamic]^ast.Ident, len(for_stmt.init)-1, o.alloc)
					copy(new_init[:], for_stmt.init[:i])
					copy(new_init[i:], for_stmt.init[i+1:])
					for_stmt.init = new_init[:]

					delete_key(&o.node_parent, node)
					return true
				}
			}
		}
		if cast(uintptr)for_stmt.body == cast(uintptr)node {
			for_stmt.body = nil
			delete_key(&o.node_parent, node)
			return true
		}

	case ^ast.Call_Expr:
		call := p
		for i := 0; i < len(call.args); i += 1 {
			if cast(uintptr)call.args[i] == cast(uintptr)node {
				new_args := make([dynamic]^ast.Argument, len(call.args)-1, o.alloc)
				copy(new_args[:], call.args[:i])
				copy(new_args[i:], call.args[i+1:])
				call.args = new_args[:]

				delete_key(&o.node_parent, node)
				return true
			}
		}

	case ^ast.Param_List:
		params := p
		for i := 0; i < len(params.list); i += 1 {
			if cast(uintptr)params.list[i] == cast(uintptr)node {
				new_list := make([dynamic]^ast.Param, len(params.list)-1, o.alloc)
				copy(new_list[:], params.list[:i])
				copy(new_list[i:], params.list[i+1:])
				params.list = new_list[:]

				delete_key(&o.node_parent, node)
				return true
			}
		}
	}

	return false
}

collect_all_scopes :: proc(o: ^Optimizer, scope: ^checker.Scope) {
	if scope == nil { return }

	append(&o.all_scopes, scope)

	if _, exists := o.scope_symbols_usage[scope]; !exists {
		o.scope_symbols_usage[scope] = make(map[string]bool, o.alloc)
	}

	for child in scope.children {
		collect_all_scopes(o, child)
	}
}

@(private="file")
_visit_ident :: proc(v: ^ast.Visitor, node: ^ast.Ident) {
	o := cast(^Optimizer)v.user_data
	mark_symbol_usage(o, node.name)
}

@(private="file")
_visit_call_expr :: proc(v: ^ast.Visitor, node: ^ast.Call_Expr) {
	o := cast(^Optimizer)v.user_data
	if ident, is_ident := node.expr.derived.(^ast.Ident); is_ident {
		mark_symbol_usage(o, ident.name)
	}
}

@(private="file")
_visit_func_stmt :: proc(v: ^ast.Visitor, node: ^ast.Func_Stmt) {
	o := cast(^Optimizer)v.user_data
}

@(private="file")
_visit_event_stmt :: proc(v: ^ast.Visitor, node: ^ast.Event_Stmt) {
	o := cast(^Optimizer)v.user_data
}

@(private="file")
_visit_value_decl :: proc(v: ^ast.Visitor, node: ^ast.Value_Decl) {
	o := cast(^Optimizer)v.user_data
}

mark_symbol_usage :: proc(o: ^Optimizer, name: string) {
	scope := o.current_scope
	for scope != nil {
		if _, exists := o.scope_symbols_usage[scope]; !exists {
			o.scope_symbols_usage[scope] = make(map[string]bool, o.alloc)
		}

		for sym in scope.symbols {
			if sym.name == name {
				if s, exist := &o.scope_symbols_usage[scope]; exist {
					s[name] = true
				}
				return
			}
		}

		scope = scope.parent
	}
}

build_dependency_graph :: proc(o: ^Optimizer) {
	for scope in o.all_scopes {
		for sym in scope.symbols {
			o.symbol_deps[sym] = make([dynamic]^checker.Symbol, o.alloc)
			o.reverse_deps[sym] = make([dynamic]^checker.Symbol, o.alloc)

			if _, exists := o.symbol_by_name_in_scope[scope]; !exists {
				o.symbol_by_name_in_scope[scope] = make(map[string]^checker.Symbol, o.alloc)
			}
			if scop, exist := &o.symbol_by_name_in_scope[scope]; exist {
				scop[sym.name] = sym
			}

			analyze_symbol_dependencies(o, sym)
		}
	}
}

analyze_symbol_dependencies :: proc(o: ^Optimizer, sym: ^checker.Symbol) {
	if sym.decl_node == nil {
		return
	}

	saved_scope := o.current_scope
	saved_level := o.current_level

	if scope, exists := o.symbols.node_scopes[sym.decl_node.id]; exists {
		o.current_scope = scope
		o.current_level = scope.level
	}

	#partial switch node in sym.decl_node.derived {
	case ^ast.Value_Decl:
		if node.value != nil {
			collect_dependencies_from_expr(o, sym, node.value)
		}

	case ^ast.Func_Stmt:
		if node.body != nil {
			collect_dependencies_from_block(o, sym, node.body)
		}

	case ^ast.Event_Stmt:
		if node.body != nil {
			collect_dependencies_from_block(o, sym, node.body)
		}
	}

	o.current_scope = saved_scope
	o.current_level = saved_level
}

collect_dependencies_from_expr :: proc(o: ^Optimizer, from_sym: ^checker.Symbol, expr: ^ast.Expr) {
	if expr == nil { return }

	#partial switch e in expr.derived {
	case ^ast.Ident:
		found_sym := find_symbol_in_scopes(o, e.name, o.current_scope)
		if found_sym != nil && found_sym != from_sym {
			append(&o.symbol_deps[from_sym], found_sym)
			append(&o.reverse_deps[found_sym], from_sym)
		}

	case ^ast.Call_Expr:
		if ident, is_ident := e.expr.derived.(^ast.Ident); is_ident {
			found_sym := find_symbol_in_scopes(o, ident.name, o.current_scope)
			if found_sym != nil && found_sym != from_sym {
				append(&o.symbol_deps[from_sym], found_sym)
				append(&o.reverse_deps[found_sym], from_sym)
			}
		}
		for arg in e.args {
			collect_dependencies_from_expr(o, from_sym, arg.value)
		}

	case ^ast.Binary_Expr:
		collect_dependencies_from_expr(o, from_sym, e.left)
		collect_dependencies_from_expr(o, from_sym, e.right)

	case ^ast.Unary_Expr:
		collect_dependencies_from_expr(o, from_sym, e.expr)

	case ^ast.Paren_Expr:
		collect_dependencies_from_expr(o, from_sym, e.expr)

	case ^ast.Index_Expr:
		collect_dependencies_from_expr(o, from_sym, e.expr)
		collect_dependencies_from_expr(o, from_sym, e.index)

	case ^ast.Member_Access_Expr:
		collect_dependencies_from_expr(o, from_sym, e.expr)
	}
}

collect_dependencies_from_block :: proc(o: ^Optimizer, from_sym: ^checker.Symbol, block: ^ast.Block_Stmt) {
	if block == nil { return }

	for stmt in block.stmts {
		#partial switch s in stmt.derived {
		case ^ast.Expr_Stmt:
			collect_dependencies_from_expr(o, from_sym, s.expr)

		case ^ast.Value_Decl:
			if decl, ok := s.derived.(^ast.Value_Decl); ok {
				collect_dependencies_from_expr(o, from_sym, decl.value)
			}

		case ^ast.Assign_Stmt:
			collect_dependencies_from_expr(o, from_sym, s.expr)

		case ^ast.Return_Stmt:
			collect_dependencies_from_expr(o, from_sym, s.result)

		case ^ast.If_Stmt:
			collect_dependencies_from_expr(o, from_sym, s.cond)
			if s.body != nil {
				collect_dependencies_from_block(o, from_sym, s.body)
			}
			if s.else_stmt != nil {
				collect_dependencies_from_block(o, from_sym, s.else_stmt)
			}

		case ^ast.For_Stmt:
			collect_dependencies_from_expr(o, from_sym, s.cond)
			collect_dependencies_from_expr(o, from_sym, s.second_cond)
			if s.body != nil {
				collect_dependencies_from_block(o, from_sym, s.body)
			}

		case ^ast.Block_Stmt:
			collect_dependencies_from_block(o, from_sym, s)

		case ^ast.Defer_Stmt:
			#partial switch d in s.stmt.derived {
			case ^ast.Expr_Stmt:
				collect_dependencies_from_expr(o, from_sym, d.expr)
			}
		}
	}
}

find_symbol_in_scopes :: proc(o: ^Optimizer, name: string, start_scope: ^checker.Scope) -> ^checker.Symbol {
	scope := start_scope
	for scope != nil {
		if sym_map, exists := o.symbol_by_name_in_scope[scope]; exists {
			if sym, found := sym_map[name]; found {
				return sym
			}
		}
		scope = scope.parent
	}
	return nil
}

mark_anonymous_vars_as_used :: proc(o: ^Optimizer) {
	for name in o.anonymous_vars {
		found := false

		scope := o.current_scope
		for scope != nil {
			for sym in scope.symbols {
				if sym.name == name {
					mark_symbol_and_dependencies(o, sym)
					found = true
					break
				}
			}

			if found {
				break
			}

			scope = scope.parent
		}

		if !found {
			scope_stack := make([dynamic]^checker.Scope, o.alloc)
			defer delete(scope_stack)

			append(&scope_stack, o.symbols.global_scope)

			for len(scope_stack) > 0 {
				scope2 := pop(&scope_stack)

				for sym in scope2.symbols {
					if sym.name == name {
						mark_symbol_and_dependencies(o, sym)
						found = true
						break
					}
				}

				if found {
					break
				}

				for child in scope.children {
					append(&scope_stack, child)
				}
			}
		}
	}
}

mark_used_symbols :: proc(o: ^Optimizer) {
	for scope, usage_map in o.scope_symbols_usage {
		for name, used in usage_map {
			if used {
				if sym_map, exists := o.symbol_by_name_in_scope[scope]; exists {
					if sym, found := sym_map[name]; found {
						mark_symbol_and_dependencies(o, sym)
					}
				}
			}
		}
	}

	mark_builtin_and_native_as_used(o)

	mark_anonymous_vars_as_used(o)
}

mark_symbol_and_dependencies :: proc(o: ^Optimizer, sym: ^checker.Symbol) {
	stack := make([dynamic]^checker.Symbol, o.alloc)

	append(&stack, sym)

	for len(stack) > 0 {
		current := pop(&stack)

		if _, already_marked := o.preserved_symbols[current]; already_marked {
			continue
		}

		o.preserved_symbols[current] = true

		if deps, exists := o.symbol_deps[current]; exists {
			for dep in deps {
				append(&stack, dep)
			}
		}
	}
}

mark_builtin_and_native_as_used :: proc(o: ^Optimizer) {
	scope_stack := make([dynamic]^checker.Scope, o.alloc)

	append(&scope_stack, o.symbols.global_scope)

	for len(scope_stack) > 0 {
		scope := pop(&scope_stack)

		for sym in scope.symbols {
			if sym.type.kind == .Function || sym.type.kind == .Event {
				if flags_field, has := sym.metadata["flags"]; has {
					if flags, ok := flags_field.(checker.Flags); ok {
						if .BUILTIN in flags || .NATIVE in flags {
							mark_symbol_and_dependencies(o, sym)
						}
					}
				}
			}
		}

		for child in scope.children {
			append(&scope_stack, child)
		}
	}
}

is_symbol_public :: proc(sym: ^checker.Symbol) -> bool {
	if sym.decl_node == nil { return false }

	#partial switch node in sym.decl_node.derived {
	case ^ast.Func_Stmt:
		stmt := cast(^ast.Stmt)node
		for anno in stmt.annotations {
			if anno.name == "export" {
				return true
			}
		}
	case ^ast.Event_Stmt:
		stmt := cast(^ast.Stmt)node
		for anno in stmt.annotations {
			if anno.name == "export" {
				return true
			}
		}
	case ^ast.Value_Decl:
		stmt := cast(^ast.Stmt)node
		for anno in stmt.annotations {
			if anno.name == "export" {
				return true
			}
		}
	}

	return false
}

check_for_unused_symbols :: proc(o: ^Optimizer) {
	for scope in o.all_scopes {
		for sym in scope.symbols {
			if _, preserved := o.preserved_symbols[sym]; preserved {
				continue
			}

			if flags_field, has := sym.metadata["flags"]; has {
				if flags, ok := flags_field.(checker.Flags); ok {
					if .BUILTIN in flags || .NATIVE in flags {
						continue
					}
				}
			}

			if is_symbol_public(sym) {
				continue
			}

			if scope.level == 0 && sym.type.kind == .Event {
				continue
			}

			if _, already_warned := o.unused_warnings[sym]; !already_warned {
				o.unused_warnings[sym] = true

				if sym.decl_node != nil {
					error.add_warning(o.ec, o.current_file, fmt.tprintf("unused symbol '%s'", sym.name), sym.decl_node)
				}
			}
		}
	}
}

remove_unused_symbols :: proc(o: ^Optimizer) -> int {
	removed_count := 0

	collect_function_calls(o)

	for &scope in o.all_scopes {
		i := 0
		for i < len(scope.symbols) {
			sym := scope.symbols[i]

			should_keep := false

			if sym.name in o.anonymous_vars {
				should_keep = true
			}

			if _, was_inlined := o.inlined_symbols[sym]; was_inlined {
				if count, exists := &o.symbol_usage_count[sym]; exists && count^ <= 0 {
					ordered_remove(&scope.symbols, i)
					removed_count += 1

					if sym.decl_node != nil {
						remove_node_from_parent(o, sym.decl_node)

						if sym.type.kind == .Function {
							if calls, exists2 := o.func_calls[sym]; exists2 {
								for call in calls {
									if parent, exists3 := o.node_parent[call]; exists3 {
										remove_node_from_parent(o, cast(^ast.Node)call)
									}
								}
								delete_key(&o.func_calls, sym)
							}
						}
					}

					delete_key(&o.symbol_deps, sym)
					delete_key(&o.reverse_deps, sym)
					delete_key(&o.symbol_usage_count, sym)
					delete_key(&o.inlined_symbols, sym)
					continue
				}
			}

			if _, preserved := o.preserved_symbols[sym]; preserved {
				should_keep = true
			}

			if scope.level == 0 && sym.type.kind == .Event {
				should_keep = true
			}

			if is_symbol_public(sym) {
				should_keep = true
			}

			if !should_keep {
				if count, exists := o.symbol_usage_count[sym]; exists && count > 0 {
					should_keep = true
				}
			}

			if !should_keep {
				ordered_remove(&scope.symbols, i)
				removed_count += 1

				if sym.decl_node != nil {
					remove_node_from_parent(o, sym.decl_node)

					if sym.type.kind == .Function {
						if calls, exists := o.func_calls[sym]; exists {
							for call in calls {
								if parent, exists2 := o.node_parent[call]; exists2 {
									remove_node_from_parent(o, cast(^ast.Node)call)
								}
							}
							delete_key(&o.func_calls, sym)
						}
					}
				}

				delete_key(&o.symbol_deps, sym)
				delete_key(&o.reverse_deps, sym)
				delete_key(&o.symbol_usage_count, sym)
			} else {
				i += 1
			}
		}
	}

	return removed_count
}

create_constant_literal :: proc(o: ^Optimizer, const_result: Constant_Result, pos, end: lexer.Pos) -> ^ast.Expr {
	if !const_result.is_constant {
		return nil
	}

	#partial switch const_result.type_kind {
	case .Number:
		#partial switch val in const_result.value {
		case i64:
			f64_val := f64(val)
			if math.is_inf(f64_val) || math.is_nan(f64_val) {
				error.add_error(o.ec, o.current_file, fmt.tprintf("number overflow: integer value %d too large for double precision", val), pos, end)
				return nil
			}
			return ast.create_number_lit(fmt.tprintf("%d", val), pos, end, o.alloc)
		case f64:
			if math.is_inf(val) {
				error.add_error(o.ec, o.current_file, fmt.tprintf("number overflow: value results in %v", val > 0 ? "+Infinity" : "-Infinity"), pos, end)
				return nil
			} else if math.is_nan(val) {
				error.add_error(o.ec, o.current_file, "number error: value results in NaN", pos, end)
				return nil
			}
			return ast.create_number_lit(fmt.tprintf("%f", val), pos, end, o.alloc)
		}

	case .Boolean:
		if val, ok := const_result.value.(bool); ok {
			return ast.create_bool_lit(val, pos, end, o.alloc)
		}

	case .Text:
		if str_val, ok := const_result.value.(string); ok {
			return ast.create_text_lit(str_val, pos, end, o.alloc)
		}
	}

	return nil
}

evaluate_constant_expression :: proc(o: ^Optimizer, expr: ^ast.Expr) -> Constant_Result {
	if expr == nil {
		return {is_constant = false}
	}

	if result, exists := o.constant_cache[expr]; exists {
		return result
	}

	result: Constant_Result

	#partial switch node in expr.derived {
	case ^ast.Basic_Lit:
		result = evaluate_basic_literal(o, node)

	case ^ast.Ident:
		result = evaluate_identifier(o, node)

	case ^ast.Binary_Expr:
		result = evaluate_binary_expression(o, node)

	case ^ast.Unary_Expr:
		result = evaluate_unary_expression(o, node)

	case ^ast.Paren_Expr:
		result = evaluate_constant_expression(o, node.expr)

	case ^ast.Call_Expr:
		result = evaluate_call_expression(o, node)

	case:
		result.is_constant = false
	}

	o.constant_cache[expr] = result
	return result
}

evaluate_basic_literal :: proc(o: ^Optimizer, lit: ^ast.Basic_Lit) -> Constant_Result {
	result: Constant_Result
	result.is_constant = false

	#partial switch lit.tok.kind {
	case .Number:
		if val, ok := strconv.parse_f64(lit.tok.content); ok {
			result.value = val
			result.type_kind = .Number
			result.is_constant = true

			if math.is_inf(val) {
				error.add_error(o.ec, o.current_file, fmt.tprintf("number overflow/underflow: '%s' results in Infinity", lit.tok.content), lit)
				result.is_constant = false
			} else if math.is_nan(val) {
				error.add_error(o.ec, o.current_file, fmt.tprintf("invalid number: '%s' results in NaN", lit.tok.content), lit)
				result.is_constant = false
			}
		}

	case .Text:
		if len(lit.tok.content) >= 2 {
			result.value = lit.tok.content[1:len(lit.tok.content)-1]
			result.type_kind = .Text
			result.is_constant = true
		}

	case .True:
		result.value = true
		result.type_kind = .Boolean
		result.is_constant = true

	case .False:
		result.value = false
		result.type_kind = .Boolean
		result.is_constant = true

	case:
		result.is_constant = false
	}

	return result
}

evaluate_identifier :: proc(o: ^Optimizer, ident: ^ast.Ident) -> Constant_Result {
	result: Constant_Result
	result.is_constant = false

	sym := find_symbol_in_scopes(o, ident.name, o.current_scope)
	if sym == nil {
		return result
	}

	if sym.is_const {
		if sym.decl_node != nil {
			#partial switch decl in sym.decl_node.derived {
			case ^ast.Value_Decl:
				if decl.value != nil {
					saved_scope := o.current_scope
					saved_level := o.current_level

					if scope, exists := o.symbols.node_scopes[sym.decl_node.id]; exists {
						o.current_scope = scope
						o.current_level = scope.level
					}

					expr_result := evaluate_constant_expression(o, decl.value)

					o.current_scope = saved_scope
					o.current_level = saved_level

					if can_inline_symbol(o, sym) {
						if count, exists := &o.symbol_usage_count[sym]; exists && count^ > 0 {
							o.symbol_usage_count[sym] = count^ - 1
							o.inlined_symbols[sym] = true
						}
					}

					return expr_result
				}
			}
		}
	}

	if flags_field, has := sym.metadata["flags"]; has {
		if flags, ok := flags_field.(checker.Flags); ok && .PURE in flags {
			if sym.decl_node != nil {
				#partial switch decl in sym.decl_node.derived {
				case ^ast.Value_Decl:
					if decl.value != nil {
						saved_scope := o.current_scope
						saved_level := o.current_level

						if scope, exists := o.symbols.node_scopes[sym.decl_node.id]; exists {
							o.current_scope = scope
							o.current_level = scope.level
						}

						expr_result := evaluate_constant_expression(o, decl.value)

						o.current_scope = saved_scope
						o.current_level = saved_level

						return expr_result
					}
				}
			}
		}
	}

	return result
}

evaluate_binary_expression :: proc(o: ^Optimizer, expr: ^ast.Binary_Expr) -> Constant_Result {
	result: Constant_Result
	result.is_constant = false

	left_result := evaluate_constant_expression(o, expr.left)
	right_result := evaluate_constant_expression(o, expr.right)

	if left_result.is_constant && right_result.is_constant {
		if expr.op.kind == .Add && left_result.type_kind == .Number && right_result.type_kind == .Number {
			result = add_numbers(left_result, right_result, o, expr)
		} else if expr.op.kind == .Add && left_result.type_kind == .Text && right_result.type_kind == .Text {
			if left_str, left_ok := left_result.value.(string); left_ok {
				if right_str, right_ok := right_result.value.(string); right_ok {
					result.type_kind = .Text
					result.value = strings.concatenate([]string{left_str, right_str}, o.alloc)
					result.is_constant = true
				}
			}
		} else if (expr.op.kind == .Add || expr.op.kind == .Sub || expr.op.kind == .Mul || expr.op.kind == .Quo || expr.op.kind == .Mod) &&
				left_result.type_kind == .Number && right_result.type_kind == .Number {
			result = perform_arithmetic(expr.op.kind, left_result, right_result, o, expr)
		} else if (expr.op.kind == .Gt || expr.op.kind == .Gt_Eq || expr.op.kind == .Lt || expr.op.kind == .Lt_Eq ||
				 expr.op.kind == .Cmp_Eq || expr.op.kind == .Not_Eq) {
			result = perform_comparison(expr.op.kind, left_result, right_result)
		} else if (expr.op.kind == .Cmp_And || expr.op.kind == .Cmp_Or) {
			result = perform_logical(expr.op.kind, left_result, right_result)
		}
	}

	return result
}

add_numbers :: proc(left, right: Constant_Result, o: ^Optimizer, expr: ^ast.Binary_Expr) -> Constant_Result {
	result: Constant_Result
	result.is_constant = true
	result.type_kind = .Number

	#partial switch left_val in left.value {
	case i64:
		#partial switch right_val in right.value {
		case i64:
			result.value = left_val + right_val
		case f64:
			result.value = f64(left_val) + right_val
		}
	case f64:
		#partial switch right_val in right.value {
		case i64:
			result.value = left_val + f64(right_val)
		case f64:
			result.value = left_val + right_val
		}
	}

	if f64_val, is_f64 := result.value.(f64); is_f64 {
		if math.is_inf(f64_val) {
			if o != nil && expr != nil {
				error.add_error(o.ec, o.current_file, fmt.tprintf("addition overflow: operation results in %v", f64_val > 0 ? "+Infinity" : "-Infinity"), expr)
			}
			result.is_constant = false
		} else if math.is_nan(f64_val) {
			if o != nil && expr != nil {
				error.add_error(o.ec, o.current_file, "addition error: operation results in NaN", expr)
			}
			result.is_constant = false
		}
	}

	return result
}

perform_arithmetic :: proc(op: lexer.Token_Kind, left, right: Constant_Result, o: ^Optimizer, expr: ^ast.Binary_Expr) -> Constant_Result {
	result: Constant_Result
	result.is_constant = true
	result.type_kind = .Number

	left_num: f64
	right_num: f64

	if i64_val, is_i64 := left.value.(i64); is_i64 {
		left_num = f64(i64_val)
	} else if f64_val, is_f64 := left.value.(f64); is_f64 {
		left_num = f64_val
	} else {
		result.is_constant = false
		return result
	}

	if i64_val, is_i64 := right.value.(i64); is_i64 {
		right_num = f64(i64_val)
	} else if f64_val, is_f64 := right.value.(f64); is_f64 {
		right_num = f64_val
	} else {
		result.is_constant = false
		return result
	}

	#partial switch op {
	case .Add:
		result.value = left_num + right_num

	case .Sub:
		result.value = left_num - right_num

	case .Mul:
		result.value = left_num * right_num

	case .Quo:
		if abs(right_num) < EPSILON {
			result.is_constant = false
			if o != nil && expr != nil {
				error.add_error(o.ec, o.current_file, "division by zero", expr)
			}
		} else {
			result.value = left_num / right_num
		}
	case .Mod:
		if abs(right_num) < EPSILON {
			result.is_constant = false
			if o != nil && expr != nil {
				error.add_error(o.ec, o.current_file, "modulo by zero", expr)
			}
		} else {
			result.value = math.mod(left_num, right_num)
		}

	case:
		result.is_constant = false
	}

	if result.is_constant {
		if f64_val, is_f64 := result.value.(f64); is_f64 {
			if math.is_inf(f64_val) {
				if o != nil && expr != nil {
					error.add_error(o.ec, o.current_file, fmt.tprintf("arithmetic overflow: operation results in %v", f64_val > 0 ? "+Infinity" : "-Infinity"), expr.pos, expr.end)
				}
				result.is_constant = false
			} else if math.is_nan(f64_val) {
				if o != nil && expr != nil {
					error.add_error(o.ec, o.current_file, "arithmetic error: operation results in NaN", expr)
				}
				result.is_constant = false
			}
		} else if i64_val, is_i64 := result.value.(i64); is_i64 {
			f64_val2 := f64(i64_val)
			if math.is_inf(f64_val2) || math.is_nan(f64_val2) {
				if o != nil && expr != nil {
					error.add_error(o.ec, o.current_file, fmt.tprintf("arithmetic overflow: integer value %d too large for double precision", i64_val), expr)
				}
				result.is_constant = false
			}
		}
	}

	return result
}

check_numeric_literal_overflow :: proc(o: ^Optimizer, content: string, pos, end: lexer.Pos) -> bool {
	val, parse_ok := strconv.parse_f64(content)

	if !parse_ok {
		error.add_error(o.ec, o.current_file, fmt.tprintf("number overflow/underflow or invalid format: '%s' cannot be represented as double", content), pos, end)
		return true
	}

	if math.is_inf(val) {
		error.add_error(o.ec, o.current_file, fmt.tprintf("number overflow/underflow: '%s' results in Infinity", content), pos, end)
		return true
	}

	if math.is_nan(val) {
		error.add_error(o.ec, o.current_file, fmt.tprintf("invalid number: '%s' results in NaN", content), pos, end)
		return true
	}

	return false
}

perform_comparison :: proc(op: lexer.Token_Kind, left, right: Constant_Result) -> Constant_Result {
	result: Constant_Result
	result.is_constant = true
	result.type_kind = .Boolean

	if left.type_kind == .Number && right.type_kind == .Number {
		left_num: f64
		right_num: f64

		if i64_val, is_i64 := left.value.(i64); is_i64 {
			left_num = f64(i64_val)
		} else if f64_val, is_f64 := left.value.(f64); is_f64 {
			left_num = f64_val
		} else {
			result.is_constant = false
			return result
		}

		if i64_val, is_i64 := right.value.(i64); is_i64 {
			right_num = f64(i64_val)
		} else if f64_val, is_f64 := right.value.(f64); is_f64 {
			right_num = f64_val
		} else {
			result.is_constant = false
			return result
		}

		#partial switch op {
		case .Gt: result.value = left_num > right_num
		case .Gt_Eq: result.value = left_num >= right_num
		case .Lt: result.value = left_num < right_num
		case .Lt_Eq: result.value = left_num <= right_num
		case .Cmp_Eq: result.value = left_num == right_num
		case .Not_Eq: result.value = left_num != right_num
		case:
			result.is_constant = false
		}
	} else if left.type_kind == .Text && right.type_kind == .Text {
		if left_str, left_ok := left.value.(string); left_ok {
			if right_str, right_ok := right.value.(string); right_ok {
				#partial switch op {
				case .Cmp_Eq: result.value = left_str == right_str
				case .Not_Eq: result.value = left_str != right_str
				case:
					result.is_constant = false
				}
			} else {
				result.is_constant = false
			}
		} else {
			result.is_constant = false
		}
	} else if left.type_kind == .Boolean && right.type_kind == .Boolean {
		if left_bool, left_ok := left.value.(bool); left_ok {
			if right_bool, right_ok := right.value.(bool); right_ok {
				#partial switch op {
				case .Cmp_Eq: result.value = left_bool == right_bool
				case .Not_Eq: result.value = left_bool != right_bool
				case:
					result.is_constant = false
				}
			} else {
				result.is_constant = false
			}
		} else {
			result.is_constant = false
		}
	} else {
		result.is_constant = false
	}

	return result
}

perform_logical :: proc(op: lexer.Token_Kind, left, right: Constant_Result) -> Constant_Result {
	result: Constant_Result
	result.is_constant = true
	result.type_kind = .Boolean

	left_bool: bool
	right_bool: bool

	if left.type_kind == .Boolean {
		if bool_val, ok := left.value.(bool); ok {
			left_bool = bool_val
		} else {
			result.is_constant = false
			return result
		}
	} else if left.type_kind == .Number {
		if i64_val, is_i64 := left.value.(i64); is_i64 {
			left_bool = i64_val != 0
		} else if f64_val, is_f64 := left.value.(f64); is_f64 {
			left_bool = f64_val != 0.0
		} else {
			result.is_constant = false
			return result
		}
	} else {
		result.is_constant = false
		return result
	}

	if right.type_kind == .Boolean {
		if bool_val, ok := right.value.(bool); ok {
			right_bool = bool_val
		} else {
			result.is_constant = false
			return result
		}
	} else if right.type_kind == .Number {
		if i64_val, is_i64 := right.value.(i64); is_i64 {
			right_bool = i64_val != 0
		} else if f64_val, is_f64 := right.value.(f64); is_f64 {
			right_bool = f64_val != 0.0
		} else {
			result.is_constant = false
			return result
		}
	} else {
		result.is_constant = false
		return result
	}

	#partial switch op {
	case .Cmp_And: result.value = left_bool && right_bool
	case .Cmp_Or: result.value = left_bool || right_bool
	case:
		result.is_constant = false
	}

	return result
}

evaluate_unary_expression :: proc(o: ^Optimizer, expr: ^ast.Unary_Expr) -> Constant_Result {
	result: Constant_Result
	result.is_constant = false

	operand_result := evaluate_constant_expression(o, expr.expr)

	if operand_result.is_constant {
		result.is_constant = true
		result.type_kind = operand_result.type_kind

		#partial switch expr.op.kind {
		case .Add:
			result.value = operand_result.value

		case .Sub:
			if operand_result.type_kind == .Number {
				#partial switch val in operand_result.value {
				case i64:
					result.value = -val
				case f64:
					result.value = -val
				}
			} else {
				result.is_constant = false
			}

		case .Not:
			if operand_result.type_kind == .Boolean {
				if bool_val, ok := operand_result.value.(bool); ok {
					result.value = !bool_val
				} else {
					result.is_constant = false
				}
			} else {
				result.is_constant = false
			}
		case:
			result.is_constant = false
		}
	}

	return result
}

evaluate_call_expression :: proc(o: ^Optimizer, call: ^ast.Call_Expr) -> Constant_Result {
	result: Constant_Result
	result.is_constant = false

	if ident, is_ident := call.expr.derived.(^ast.Ident); is_ident {
		if is_builtin_factory(ident.name) {
			all_args_constant := true
			for arg in call.args {
				arg_result := evaluate_constant_expression(o, arg.value)
				if !arg_result.is_constant {
					all_args_constant = false
					break
				}
			}

			if all_args_constant {
				result = evaluate_builtin_factory(o, ident.name, call.args)
			}
			return result
		}
	}

	return result
}

replace_constant_factory_calls :: proc(o: ^Optimizer, file: ^ast.File) -> int {
	replaced_count := 0

	traverse_and_schedule :: proc(o: ^Optimizer, node: ^ast.Node, replaced_count: ^int) {
		if node == nil { return }

		#partial switch n in node.derived {
		case ^ast.Value_Decl:
			decl := n
			if decl.value != nil {
				#partial switch expr in decl.value.derived {
				case ^ast.Call_Expr:
					call := expr
					if ident, is_ident := call.expr.derived.(^ast.Ident); is_ident {
						if is_builtin_factory(ident.name) {
							result := evaluate_builtin_factory(o, ident.name, call.args)
							if result.is_constant {
								new_lit := create_constant_literal(o, result, decl.value.pos, decl.value.end)
								if new_lit != nil {
									schedule_node_replacement(o, cast(^ast.Node)decl.value, cast(^ast.Node)new_lit,
										"replace constant factory call", nil)
									replaced_count^ += 1
								}
							}
						}
					}
				}
			}

		case ^ast.Expr_Stmt:
			stmt := n
			if stmt.expr != nil {
				#partial switch expr in stmt.expr.derived {
				case ^ast.Call_Expr:
					call := expr
					if ident, is_ident := call.expr.derived.(^ast.Ident); is_ident {
						if is_builtin_factory(ident.name) {
							result := evaluate_builtin_factory(o, ident.name, call.args)
							if result.is_constant {
								new_lit := create_constant_literal(o, result, stmt.expr.pos, stmt.expr.end)
								if new_lit != nil {
									schedule_node_replacement(o, cast(^ast.Node)stmt.expr, cast(^ast.Node)new_lit,
										"replace constant factory call", nil)
									replaced_count^ += 1
								}
							}
						}
					}
				}
			}
		}
	}

	traverse_and_schedule(o, file, &replaced_count)
	return replaced_count
}

try_optimize_expression :: proc(o: ^Optimizer, expr: ^ast.Expr, parent: ^ast.Node) -> (bool, Constant_Result) {
	result := evaluate_constant_expression(o, expr)

	if result.is_constant && parent != nil {
		new_lit := create_constant_literal(o, result, expr.pos, expr.end)

		if new_lit != nil {
			schedule_node_replacement(o, cast(^ast.Node)expr, cast(^ast.Node)new_lit,
				"constant folding", o.deep_analyzer.current_expression_context)
			return true, result
		}
	}

	return false, result
}

remove_constant_conditions :: proc(o: ^Optimizer, stmt: ^ast.Stmt) -> int {
	removed_count := 0

	#partial switch s in stmt.derived {
	case ^ast.If_Stmt:
		if_stmt := s
		if if_stmt.cond != nil {
			result := evaluate_constant_expression(o, if_stmt.cond)
			if result.is_constant && result.type_kind == .Boolean {
				if bool_val, ok := result.value.(bool); ok {
					function_name := find_enclosing_function_name(o, stmt)
					condition_str := ast.expr_to_string(if_stmt.cond, o.alloc)

					if bool_val {
						if if_stmt.else_stmt != nil {
							error.add_warning(
								o.ec,
								o.current_file,
								fmt.tprintf(
									"unreachable code: else block is unreachable because condition '%s' is always true in function '%s'",
									condition_str,
									function_name,
								),
								if_stmt.else_stmt.pos,
								if_stmt.else_stmt.end,
							)
						}

						if if_stmt.body != nil {
							schedule_node_replacement(o, cast(^ast.Node)stmt, cast(^ast.Node)if_stmt.body,
								"if with always true condition", nil)
							removed_count += 1
						} else {
							schedule_node_removal(o, cast(^ast.Node)stmt,
								"empty if with always true condition", nil)
							removed_count += 1
						}
					} else {
						if if_stmt.body != nil {
							error.add_warning(
								o.ec,
								o.current_file,
								fmt.tprintf(
									"unreachable code: if body is unreachable because condition '%s' is always false in function '%s'",
									condition_str,
									function_name,
								),
								if_stmt,
							)
						}

						if if_stmt.else_stmt != nil {
							schedule_node_replacement(o, cast(^ast.Node)stmt, cast(^ast.Node)if_stmt.else_stmt,
								"if with always false condition", nil)
						} else {
							schedule_node_removal(o, cast(^ast.Node)stmt,
								"if with always false condition and no else", nil)
						}
						removed_count += 1
					}
				}
			}
		}

	case ^ast.For_Stmt:
		for_stmt := s
		if for_stmt.cond != nil {
			result := evaluate_constant_expression(o, for_stmt.cond)
			if result.is_constant && result.type_kind == .Boolean {
				if bool_val, ok := result.value.(bool); ok && !bool_val {
					function_name := find_enclosing_function_name(o, stmt)
					condition_str := ast.expr_to_string(for_stmt.cond, o.alloc)

					error.add_warning(
						o.ec,
						o.current_file,
						fmt.tprintf(
							"unreachable code: for loop body is unreachable because condition '%s' is always false in function '%s'",
							condition_str,
							function_name,
						),
						for_stmt,
					)

					schedule_node_removal(o, cast(^ast.Node)stmt,
						"for with always false condition", nil)
					removed_count += 1
				}
			}
		}
	}

	return removed_count
}

find_enclosing_function_name :: proc(o: ^Optimizer, node: ^ast.Node) -> string {
	current := node
	for current != nil {
		#partial switch n in current.derived {
		case ^ast.Func_Stmt:
			return n.name
		case ^ast.Event_Stmt:
			return n.name
		}

		parent, exists := o.node_parent[current]
		if !exists { break }
		current = parent
	}
	return "global"
}

reorder_constant_operands :: proc(o: ^Optimizer, expr: ^ast.Binary_Expr) -> bool {
	if expr == nil {
		return false
	}

	is_associative_commutative := false
	#partial switch expr.op.kind {
	case .Add, .Mul:
		is_associative_commutative = true
	case:
		return false
	}

	if !is_associative_commutative {
		return false
	}

	changed := false
	if left_binary, is_left_binary := expr.left.derived.(^ast.Binary_Expr); is_left_binary && left_binary.op.kind == expr.op.kind {
		changed = reorder_constant_operands(o, left_binary) || changed
	}
	if right_binary, is_right_binary := expr.right.derived.(^ast.Binary_Expr); is_right_binary && right_binary.op.kind == expr.op.kind {
		changed = reorder_constant_operands(o, right_binary) || changed
	}

	constant_parts := make([dynamic]^ast.Expr, o.alloc)
	defer delete(constant_parts)

	variable_parts := make([dynamic]^ast.Expr, o.alloc)
	defer delete(variable_parts)

	collect_parts :: proc(o: ^Optimizer, expr: ^ast.Expr, op: lexer.Token_Kind, constant_parts: ^[dynamic]^ast.Expr, variable_parts: ^[dynamic]^ast.Expr) {
		if expr == nil {
			return
		}

		#partial switch e in expr.derived {
		case ^ast.Binary_Expr:
			binary := e
			if binary.op.kind == op {
				collect_parts(o, binary.left, op, constant_parts, variable_parts)
				collect_parts(o, binary.right, op, constant_parts, variable_parts)
				return
			}
		}

		result := evaluate_constant_expression(o, expr)
		if result.is_constant {
			append(constant_parts, expr)
		} else {
			append(variable_parts, expr)
		}
	}

	collect_parts(o, expr.left, expr.op.kind, &constant_parts, &variable_parts)
	collect_parts(o, expr.right, expr.op.kind, &constant_parts, &variable_parts)

	if len(constant_parts) >= 2 {
		if len(constant_parts) > 0 {
			current_const: ^ast.Expr = constant_parts[0]

			for i := 1; i < len(constant_parts); i += 1 {
				current_const = create_binary_expression_for_constants(o, current_const, constant_parts[i], expr.op)
				changed = true
			}

			final_expr: ^ast.Expr = current_const

			for i := 0; i < len(variable_parts); i += 1 {
				final_expr = ast.create_binary_expr(
					final_expr,
					expr.op,
					variable_parts[i],
					expr.pos,
					expr.end,
					o.alloc,
				)
				changed = true
			}

			if parent, exists := o.node_parent[expr]; exists {
				schedule_node_replacement(o, cast(^ast.Node)expr, cast(^ast.Node)final_expr,
					"reorder constant operands", o.deep_analyzer.current_expression_context)
				return true
			}
		}
	}

	return changed
}

create_binary_expression_for_constants :: proc(o: ^Optimizer, left, right: ^ast.Expr, op: lexer.Token) -> ^ast.Expr {
	left_result := evaluate_constant_expression(o, left)
	right_result := evaluate_constant_expression(o, right)

	if !left_result.is_constant || !right_result.is_constant {
		return ast.create_binary_expr(left, op, right, left.pos, right.end, o.alloc)
	}

	temp_expr := ast.Binary_Expr{
		left = left,
		right = right,
		op = op,
		pos = left.pos,
		end = right.end,
	}

	combined_result: Constant_Result
	#partial switch op.kind {
	case .Add:
		combined_result = add_numbers(left_result, right_result, o, &temp_expr)
	case .Mul:
		combined_result = perform_arithmetic(.Mul, left_result, right_result, o, &temp_expr)
	case .Sub:
		combined_result = perform_arithmetic(.Sub, left_result, right_result, o, &temp_expr)
	case .Quo:
		if right_result.type_kind == .Number {
			if f64_val, is_f64 := right_result.value.(f64); is_f64 && abs(f64_val) < EPSILON {
				error.add_error(o.ec, o.current_file, "division by zero", &temp_expr)
			} else if i64_val, is_i64 := right_result.value.(i64); is_i64 && i64_val == 0 {
				error.add_error(o.ec, o.current_file, "division by zero", &temp_expr)
			}
		}
		combined_result = perform_arithmetic(.Quo, left_result, right_result, o, &temp_expr)
	case .Mod:
		if right_result.type_kind == .Number {
			if f64_val, is_f64 := right_result.value.(f64); is_f64 && abs(f64_val) < EPSILON {
				error.add_error(o.ec, o.current_file, "modulo by zero", &temp_expr)
			} else if i64_val, is_i64 := right_result.value.(i64); is_i64 && i64_val == 0 {
				error.add_error(o.ec, o.current_file, "modulo by zero", &temp_expr)
			}
		}
		combined_result = perform_arithmetic(.Mod, left_result, right_result, o, &temp_expr)
	case:
		return ast.create_binary_expr(left, op, right, left.pos, right.end, o.alloc)
	}

	if combined_result.is_constant {
		new_lit := create_constant_literal(o, combined_result, left.pos, right.end)
		if new_lit != nil {
			return new_lit
		}
	}

	return ast.create_binary_expr(left, op, right, left.pos, right.end, o.alloc)
}

optimize_constants_in_stmt :: proc(o: ^Optimizer, stmt: ^ast.Stmt) -> int {
	if stmt == nil {
		return 0
	}

	optimized_count := 0

	#partial switch s in stmt.derived {
	case ^ast.Value_Decl:
		if decl, ok := s.derived.(^ast.Value_Decl); ok && decl.value != nil {
			if binary, is_binary := decl.value.derived.(^ast.Binary_Expr); is_binary {
				if reorder_constant_operands(o, binary) {
					optimized_count += 1
				}
			}

			if optimized, _ := try_optimize_expression(o, decl.value, cast(^ast.Node)stmt); optimized {
				optimized_count += 1
			}
		}

	case ^ast.Expr_Stmt:
		if expr_stmt, ok := s.derived.(^ast.Expr_Stmt); ok && expr_stmt.expr != nil {
			if optimized, _ := try_optimize_expression(o, expr_stmt.expr, cast(^ast.Node)stmt); optimized {
				optimized_count += 1
			}
		}

	case ^ast.Assign_Stmt:
		if assign, ok := s.derived.(^ast.Assign_Stmt); ok && assign.expr != nil {
			if optimized, _ := try_optimize_expression(o, assign.expr, cast(^ast.Node)stmt); optimized {
				optimized_count += 1
			}
		}

	case ^ast.Return_Stmt:
		if ret, ok := s.derived.(^ast.Return_Stmt); ok && ret.result != nil {
			if optimized, _ := try_optimize_expression(o, ret.result, cast(^ast.Node)stmt); optimized {
				optimized_count += 1
			}
		}

	case ^ast.If_Stmt:
		if if_stmt, ok := s.derived.(^ast.If_Stmt); ok {
			optimized_count += remove_constant_conditions(o, stmt)

			if if_stmt.cond != nil {
				if optimized, _ := try_optimize_expression(o, if_stmt.cond, cast(^ast.Node)stmt); optimized {
					optimized_count += 1
				}
			}

			if if_stmt.body != nil {
				optimized_count += optimize_constants_in_block_with_scope(o, if_stmt.body)
			}
			if if_stmt.else_stmt != nil {
				optimized_count += optimize_constants_in_block_with_scope(o, if_stmt.else_stmt)
			}
		}

	case ^ast.Block_Stmt:
		if block, ok := s.derived.(^ast.Block_Stmt); ok {
			optimized_count += optimize_constants_in_block_with_scope(o, block)
		}

	case ^ast.For_Stmt:
		if for_stmt, ok := s.derived.(^ast.For_Stmt); ok {
			optimized_count += remove_constant_conditions(o, stmt)

			if for_stmt.cond != nil {
				if optimized, _ := try_optimize_expression(o, for_stmt.cond, cast(^ast.Node)stmt); optimized {
					optimized_count += 1
				}
			}

			if for_stmt.body != nil {
				optimized_count += optimize_constants_in_block_with_scope(o, for_stmt.body)
			}
		}
	case ^ast.Func_Stmt:
		func_stmt := s
		if func_stmt.body != nil {
			saved_scope := o.current_scope
			saved_level := o.current_level

			if scope, exists := o.symbols.node_scopes[func_stmt.id]; exists {
				o.current_scope = scope
				o.current_level = scope.level
			}

			optimized_count += optimize_constants_in_block_with_scope(o, func_stmt.body)

			o.current_scope = saved_scope
			o.current_level = saved_level
		}

	case ^ast.Event_Stmt:
		event_stmt := s
		if event_stmt.body != nil {
			saved_scope := o.current_scope
			saved_level := o.current_level

			if scope, exists := o.symbols.node_scopes[event_stmt.id]; exists {
				o.current_scope = scope
				o.current_level = scope.level
			}

			optimized_count += optimize_constants_in_block_with_scope(o, event_stmt.body)

			o.current_scope = saved_scope
			o.current_level = saved_level
		}
	}

	return optimized_count
}

optimize_constants_in_block_with_scope :: proc(o: ^Optimizer, block: ^ast.Block_Stmt) -> int {
	if block == nil {
		return 0
	}

	saved_scope := o.current_scope
	saved_level := o.current_level

	if scope, exists := o.symbols.node_scopes[block.id]; exists {
		o.current_scope = scope
		o.current_level = scope.level
	}

	optimized_count := optimize_constants_in_block(o, block)

	o.current_scope = saved_scope
	o.current_level = saved_level

	return optimized_count
}

optimize_constant_expressions :: proc(o: ^Optimizer) -> int {
	optimized_count := 0

	for file in o.files {
		o.current_file = file
		optimized_count += replace_constant_factory_calls(o, file)
	}

	for file in o.files {
		o.current_file = file
		optimized_count += optimize_constants_in_file(o, file)
	}

	for file in o.files {
		o.current_file = file
		optimized_count += fold_constants_after_factories(o, file)
	}

	return optimized_count
}

fold_constants_after_factories :: proc(o: ^Optimizer, file: ^ast.File) -> int {
	folded_count := 0

	traverse_and_fold :: proc(o: ^Optimizer, node: ^ast.Node, folded_count: ^int) {
		if node == nil { return }

		#partial switch n in node.derived {
		case ^ast.Value_Decl:
			decl := n
			if decl.value != nil {
				if optimized, _ := try_optimize_expression(o, decl.value, node); optimized {
					folded_count^ += 1
				}

				traverse_and_fold(o, decl.value, folded_count)
			}

		case ^ast.Expr_Stmt:
			stmt := n
			if stmt.expr != nil {
				if optimized, _ := try_optimize_expression(o, stmt.expr, node); optimized {
					folded_count^ += 1
				}
				traverse_and_fold(o, stmt.expr, folded_count)
			}

		case ^ast.Binary_Expr:
			binary := n
			traverse_and_fold(o, binary.left, folded_count)
			traverse_and_fold(o, binary.right, folded_count)

			if parent, exists := o.node_parent[node]; exists {
				if optimized, _ := try_optimize_expression(o, cast(^ast.Expr)node, parent); optimized {
					folded_count^ += 1
				}
			}

		case ^ast.Unary_Expr:
			unary := n
			traverse_and_fold(o, unary.expr, folded_count)

		case ^ast.Call_Expr:
			call := n
			traverse_and_fold(o, call.expr, folded_count)
			for arg in call.args {
				traverse_and_fold(o, arg, folded_count)
			}

		case ^ast.Block_Stmt:
			block := n
			saved_scope := o.current_scope
			saved_level := o.current_level

			if scope, exists := o.symbols.node_scopes[block.id]; exists {
				o.current_scope = scope
				o.current_level = scope.level
			}

			for stmt in block.stmts {
				traverse_and_fold(o, stmt, folded_count)
			}

			o.current_scope = saved_scope
			o.current_level = saved_level

		case ^ast.If_Stmt:
			if_stmt := n
			traverse_and_fold(o, if_stmt.cond, folded_count)
			if if_stmt.body != nil {
				traverse_and_fold(o, if_stmt.body, folded_count)
			}
			if if_stmt.else_stmt != nil {
				traverse_and_fold(o, if_stmt.else_stmt, folded_count)
			}

		case ^ast.For_Stmt:
			for_stmt := n
			traverse_and_fold(o, for_stmt.cond, folded_count)
			traverse_and_fold(o, for_stmt.second_cond, folded_count)
			if for_stmt.body != nil {
				traverse_and_fold(o, for_stmt.body, folded_count)
			}

		case ^ast.Func_Stmt:
			func_stmt := n
			if func_stmt.body != nil {
				saved_scope := o.current_scope
				saved_level := o.current_level

				if scope, exists := o.symbols.node_scopes[func_stmt.id]; exists {
					o.current_scope = scope
					o.current_level = scope.level
				}

				traverse_and_fold(o, func_stmt.body, folded_count)

				o.current_scope = saved_scope
				o.current_level = saved_level
			}

		case ^ast.Event_Stmt:
			event_stmt := n
			if event_stmt.body != nil {
				saved_scope := o.current_scope
				saved_level := o.current_level

				if scope, exists := o.symbols.node_scopes[event_stmt.id]; exists {
					o.current_scope = scope
					o.current_level = scope.level
				}

				traverse_and_fold(o, event_stmt.body, folded_count)

				o.current_scope = saved_scope
				o.current_level = saved_level
			}
		}
	}

	traverse_and_fold(o, file, &folded_count)

	return folded_count
}

optimize_constants_in_block :: proc(o: ^Optimizer, block: ^ast.Block_Stmt) -> int {
	if block == nil {
		return 0
	}

	optimized_count := 0

	for stmt in block.stmts {
		#partial switch s in stmt.derived {
		case ^ast.Value_Decl:
			if decl, ok := s.derived.(^ast.Value_Decl); ok && decl.value != nil {
				if binary, is_binary := decl.value.derived.(^ast.Binary_Expr); is_binary {
					if reorder_constant_operands(o, binary) {
						optimized_count += 1
					}
				}
			}
		case ^ast.Expr_Stmt:
			if expr_stmt, ok := s.derived.(^ast.Expr_Stmt); ok && expr_stmt.expr != nil {
				if binary, is_binary := expr_stmt.expr.derived.(^ast.Binary_Expr); is_binary {
					if reorder_constant_operands(o, binary) {
						optimized_count += 1
					}
				}
			}
		case ^ast.Assign_Stmt:
			if assign, ok := s.derived.(^ast.Assign_Stmt); ok && assign.expr != nil {
				if binary, is_binary := assign.expr.derived.(^ast.Binary_Expr); is_binary {
					if reorder_constant_operands(o, binary) {
						optimized_count += 1
					}
				}
			}
		}

		optimized_count += optimize_constants_in_stmt(o, stmt)

		#partial switch s in stmt.derived {
		case ^ast.If_Stmt:
			if if_stmt, ok := s.derived.(^ast.If_Stmt); ok {
				if if_stmt.body != nil {
					if if_stmt.cond != nil {
						if optimized, _ := try_optimize_expression(o, if_stmt.cond, cast(^ast.Node)if_stmt); optimized {
							optimized_count += 1
						}
					}

					optimized_count += optimize_constants_in_block_with_scope(o, if_stmt.body)
				}
				if if_stmt.else_stmt != nil {
					optimized_count += optimize_constants_in_block_with_scope(o, if_stmt.else_stmt)
				}
			}

		case ^ast.For_Stmt:
			if for_stmt, ok := s.derived.(^ast.For_Stmt); ok {
				if for_stmt.cond != nil {
					if optimized, _ := try_optimize_expression(o, for_stmt.cond, cast(^ast.Node)for_stmt); optimized {
						optimized_count += 1
					}
				}
				if for_stmt.body != nil {
					optimized_count += optimize_constants_in_block_with_scope(o, for_stmt.body)
				}
			}

		case ^ast.Block_Stmt:
			if nested_block, ok := s.derived.(^ast.Block_Stmt); ok {
				optimized_count += optimize_constants_in_block_with_scope(o, nested_block)
			}

		case ^ast.Func_Stmt:
			if func_stmt, ok := s.derived.(^ast.Func_Stmt); ok && func_stmt.body != nil {
				saved_scope := o.current_scope
				saved_level := o.current_level

				if scope, exists := o.symbols.node_scopes[func_stmt.id]; exists {
					o.current_scope = scope
					o.current_level = scope.level
				}

				optimized_count += optimize_constants_in_block(o, func_stmt.body)

				o.current_scope = saved_scope
				o.current_level = saved_level
			}

		case ^ast.Event_Stmt:
			if event_stmt, ok := s.derived.(^ast.Event_Stmt); ok && event_stmt.body != nil {
				saved_scope := o.current_scope
				saved_level := o.current_level

				if scope, exists := o.symbols.node_scopes[event_stmt.id]; exists {
					o.current_scope = scope
					o.current_level = scope.level
				}

				optimized_count += optimize_constants_in_block(o, event_stmt.body)

				o.current_scope = saved_scope
				o.current_level = saved_level
			}
		}
	}

	return optimized_count
}

optimize_constants_in_file :: proc(o: ^Optimizer, file: ^ast.File) -> int {
	optimized_count := 0

	for stmt in file.decls {
		optimized_count += optimize_constants_in_stmt(o, stmt)
	}

	return optimized_count
}

is_empty_block :: proc(block: ^ast.Block_Stmt) -> bool {
	return block == nil || len(block.stmts) == 0
}

remove_empty_blocks :: proc(o: ^Optimizer) -> int {
	removed_count := 0

	for file in o.files {
		removed_count += remove_empty_blocks_in_file(o, file)
	}

	return removed_count
}

remove_empty_blocks_in_file :: proc(o: ^Optimizer, file: ^ast.File) -> int {
	removed_count := 0

	nodes_to_process := make([dynamic]^ast.Node, o.alloc)
	defer delete(nodes_to_process)

	collect_function_calls(o)

	type_to_default_value := make(map[string]Variable_Value, o.alloc)
	defer delete(type_to_default_value)

	type_to_default_value["number"] = f64(0)
	type_to_default_value["bool"] = false
	type_to_default_value["text"] = ""
	type_to_default_value["game_value"] = f64(0)
	type_to_default_value["location"] = nil
	type_to_default_value["vec3"] = nil
	type_to_default_value["item"] = nil
	type_to_default_value["block"] = nil
	type_to_default_value["particle"] = nil
	type_to_default_value["sound"] = nil
	type_to_default_value["potion"] = nil
	type_to_default_value["enum"] = nil
	type_to_default_value["loc_text"] = ""
	type_to_default_value["array"] = nil
	type_to_default_value["dict"] = nil
	type_to_default_value["any"] = nil

	const_returning_funcs := make(map[string]Variable_Value, o.alloc)
	defer delete(const_returning_funcs)

	funcs_to_remove := make([dynamic]^checker.Symbol, o.alloc)
	defer delete(funcs_to_remove)

	for decl in file.decls {
		append(&nodes_to_process, decl)
	}

	for len(nodes_to_process) > 0 {
		node := pop(&nodes_to_process)

		#partial switch n in node.derived {
		case ^ast.Func_Stmt:
			func_stmt := n
			if func_stmt.body != nil && is_empty_block(func_stmt.body) {
				if scope, exists := o.symbols.node_scopes[func_stmt.id]; exists {
					for sym in scope.parent.symbols {
						if sym.name == func_stmt.name {
							if !is_symbol_public(sym) {
								append(&funcs_to_remove, sym)
							}
							break
						}
					}
				}
			}

			if func_stmt.body != nil {
				append(&nodes_to_process, func_stmt.body)
			}

		case ^ast.Event_Stmt:
			event_stmt := n
			if event_stmt.body != nil {
				append(&nodes_to_process, event_stmt.body)
			}

		case ^ast.If_Stmt:
			if_stmt := n
			if if_stmt.body != nil {
				append(&nodes_to_process, if_stmt.body)
			}
			if if_stmt.else_stmt != nil {
				append(&nodes_to_process, if_stmt.else_stmt)
			}

		case ^ast.For_Stmt:
			for_stmt := n
			if for_stmt.body != nil {
				append(&nodes_to_process, for_stmt.body)
			}

		case ^ast.Block_Stmt:
			block := n
			i := 0
			for i < len(block.stmts) {
				stmt := block.stmts[i]

				if nested_block, is_block := stmt.derived.(^ast.Block_Stmt); is_block && is_empty_block(nested_block) {
					new_stmts := make([]^ast.Stmt, len(block.stmts)-1, o.alloc)
					copy(new_stmts[:i], block.stmts[:i])
					copy(new_stmts[i:], block.stmts[i+1:])
					block.stmts = new_stmts
					delete_key(&o.node_parent, nested_block)
					removed_count += 1
					continue
				}

				append(&nodes_to_process, stmt)
				i += 1
			}
		}
	}

	for sym in funcs_to_remove {
		if sym.decl_node != nil {
			if remove_node_from_parent(o, sym.decl_node) {
				removed_count += 1

				scope := get_symbol_scope(o, sym)
				if scope != nil {
					for i in 0..<len(scope.symbols) {
						if scope.symbols[i] == sym {
							ordered_remove(&scope.symbols, i)
							break
						}
					}
				}

				if calls, exists := o.func_calls[sym]; exists {
					for call in calls {
						if parent, exists2 := o.node_parent[call]; exists2 {
							#partial switch p in parent.derived {
							case ^ast.Value_Decl:
								decl := p
								if decl.value == cast(^ast.Expr)call {
									if func_stmt, is_func := sym.decl_node.derived.(^ast.Func_Stmt); is_func {
										if func_stmt.result != "" && func_stmt.result != "void" {
											if default_val, exists3 := type_to_default_value[func_stmt.result]; exists3 {
												new_lit := create_literal_from_value(o, default_val, call.pos, call.end)
												if new_lit != nil {
													decl.value = new_lit
													delete_key(&o.node_parent, call)
													removed_count += 1
												}
											}
										}
									}
								}
							case ^ast.Expr_Stmt:
								stmt := p
								if stmt.expr == cast(^ast.Expr)call {
									remove_node_from_parent(o, parent)
									delete_key(&o.node_parent, call)
									removed_count += 1
								}
							case ^ast.Assign_Stmt:
								assign := p
								if assign.expr == cast(^ast.Expr)call {
									if func_stmt, is_func := sym.decl_node.derived.(^ast.Func_Stmt); is_func {
										if func_stmt.result != "" && func_stmt.result != "void" {
											if default_val, exists3 := type_to_default_value[func_stmt.result]; exists3 {
												new_lit := create_literal_from_value(o, default_val, call.pos, call.end)
												if new_lit != nil {
													assign.expr = new_lit
													delete_key(&o.node_parent, call)
													removed_count += 1
												}
											}
										}
									}
								}
							case ^ast.Return_Stmt:
								ret := p
								if ret.result == cast(^ast.Expr)call {
									if func_stmt, is_func := sym.decl_node.derived.(^ast.Func_Stmt); is_func {
										if func_stmt.result != "" && func_stmt.result != "void" {
											if default_val, exists3 := type_to_default_value[func_stmt.result]; exists3 {
												new_lit := create_literal_from_value(o, default_val, call.pos, call.end)
												if new_lit != nil {
													ret.result = new_lit
													delete_key(&o.node_parent, call)
													removed_count += 1
												}
											}
										}
									}
								}
							}
						}
					}

					delete_key(&o.func_calls, sym)
				}
			}
		}
	}

	return removed_count
}

create_literal_from_value :: proc(o: ^Optimizer, value: Variable_Value, pos, end: lexer.Pos) -> ^ast.Expr {
	if value == nil {
		return nil
	}

	#partial switch val in value {
	case f64:
		return ast.create_number_lit(fmt.tprintf("%f", val), pos, end, o.alloc)
	case bool:
		if val {
			return ast.create_bool_lit(true, pos, end, o.alloc)
		} else {
			return ast.create_bool_lit(false, pos, end, o.alloc)
		}
	case string:
		return ast.create_text_lit(val, pos, end, o.alloc)
	case i64:
		return ast.create_number_lit(fmt.tprintf("%d", val), pos, end, o.alloc)
	}

	return nil
}

flatten_nested_blocks :: proc(o: ^Optimizer) -> int {
	flattened_count := 0

	for file in o.files {
		flattened_count += flatten_blocks_in_file(o, file)
	}

	return flattened_count
}

can_flatten_block :: proc(o: ^Optimizer, block: ^ast.Block_Stmt) -> bool {
	if block == nil {
		return false
	}

	block_scope, has_scope := o.symbols.node_scopes[block.id]
	if !has_scope {
		return true
	}

	if len(block_scope.symbols) == 0 {
		return true
	}

	parent := find_parent_block(o, cast(^ast.Node)block)
	if parent == nil {
		return false
	}

	parent_scope, parent_has_scope := o.symbols.node_scopes[parent.id]
	if !parent_has_scope {
		return false
	}

	if block_scope.parent != parent_scope {
		return false
	}

	for sym in block_scope.symbols {
		for parent_sym in parent_scope.symbols {
			if parent_sym.name == sym.name {
				return false
			}
		}

		if is_symbol_used_outside_block(o, sym, block) {
			return false
		}
	}

	return true
}

is_symbol_used_outside_block :: proc(o: ^Optimizer, sym: ^checker.Symbol, block: ^ast.Block_Stmt) -> bool {
	if sym == nil || block == nil || sym.decl_node == nil {
		return false
	}

	parent := find_parent_block(o, cast(^ast.Node)block)
	if parent == nil {
		return false
	}

	block_index := -1
	for i in 0..<len(parent.stmts) {
		if cast(uintptr)parent.stmts[i] == cast(uintptr)block {
			block_index = i
			break
		}
	}

	if block_index == -1 {
		return false
	}

	for i in block_index+1..<len(parent.stmts) {
		stmt := parent.stmts[i]
		if has_specific_symbol_usage(o, stmt, sym) {
			return true
		}
	}

	return false
}

has_specific_symbol_usage :: proc(o: ^Optimizer, node: ^ast.Node, sym: ^checker.Symbol) -> bool {
	if node == nil || sym == nil {
		return false
	}

	saved_scope := o.current_scope
	saved_level := o.current_level

	sym_scope := get_symbol_scope(o, sym)
	if sym_scope != nil {
		o.current_scope = sym_scope
		o.current_level = sym_scope.level
	}

	result := false

	#partial switch n in node.derived {
	case ^ast.Ident:
		if n.name == sym.name {
			found_sym := find_symbol_in_scopes(o, n.name, o.current_scope)
			result = found_sym == sym
		}

	case ^ast.Value_Decl:
		if decl, ok := n.derived.(^ast.Value_Decl); ok && decl.value != nil {
			result = has_specific_symbol_usage(o, decl.value, sym)
		}

	case ^ast.Expr_Stmt:
		if expr_stmt, ok := n.derived.(^ast.Expr_Stmt); ok && expr_stmt.expr != nil {
			result = has_specific_symbol_usage(o, expr_stmt.expr, sym)
		}

	case ^ast.Assign_Stmt:
		if assign, ok := n.derived.(^ast.Assign_Stmt); ok && assign.expr != nil {
			result = has_specific_symbol_usage(o, assign.expr, sym)
		}

	case ^ast.Return_Stmt:
		if ret, ok := n.derived.(^ast.Return_Stmt); ok && ret.result != nil {
			result = has_specific_symbol_usage(o, ret.result, sym)
		}

	case ^ast.If_Stmt:
		if if_stmt, ok := n.derived.(^ast.If_Stmt); ok {
			result = (if_stmt.cond != nil && has_specific_symbol_usage(o, if_stmt.cond, sym)) ||
					(if_stmt.body != nil && has_specific_symbol_usage(o, if_stmt.body, sym)) ||
					(if_stmt.else_stmt != nil && has_specific_symbol_usage(o, if_stmt.else_stmt, sym))
		}

	case ^ast.For_Stmt:
		if for_stmt, ok := n.derived.(^ast.For_Stmt); ok {
			result = (for_stmt.cond != nil && has_specific_symbol_usage(o, for_stmt.cond, sym)) ||
					(for_stmt.body != nil && has_specific_symbol_usage(o, for_stmt.body, sym))
		}

	case ^ast.Block_Stmt:
		if block, ok := n.derived.(^ast.Block_Stmt); ok {
			for stmt in block.stmts {
				if has_specific_symbol_usage(o, stmt, sym) {
					result = true
					break
				}
			}
		}

	case ^ast.Call_Expr:
		if call, ok := n.derived.(^ast.Call_Expr); ok {
			result = has_specific_symbol_usage(o, call.expr, sym)
			if !result {
				for arg in call.args {
					if has_specific_symbol_usage(o, arg.value, sym) {
						result = true
						break
					}
				}
			}
		}

	case ^ast.Binary_Expr:
		if binary, ok := n.derived.(^ast.Binary_Expr); ok {
			result = has_specific_symbol_usage(o, binary.left, sym) ||
				   has_specific_symbol_usage(o, binary.right, sym)
		}

	case ^ast.Unary_Expr:
		if unary, ok := n.derived.(^ast.Unary_Expr); ok {
			result = has_specific_symbol_usage(o, unary.expr, sym)
		}

	case ^ast.Paren_Expr:
		if paren, ok := n.derived.(^ast.Paren_Expr); ok {
			result = has_specific_symbol_usage(o, paren.expr, sym)
		}

	case ^ast.Index_Expr:
		if index, ok := n.derived.(^ast.Index_Expr); ok {
			result = has_specific_symbol_usage(o, index.expr, sym) ||
				   has_specific_symbol_usage(o, index.index, sym)
		}

	case ^ast.Member_Access_Expr:
		if member, ok := n.derived.(^ast.Member_Access_Expr); ok {
			result = has_specific_symbol_usage(o, member.expr, sym)
		}
	}

	o.current_scope = saved_scope
	o.current_level = saved_level

	return result
}

get_symbol_scope :: proc(o: ^Optimizer, sym: ^checker.Symbol) -> ^checker.Scope {
	if sym == nil || sym.decl_node == nil {
		return nil
	}

	if scope, exists := o.symbols.node_scopes[sym.decl_node.id]; exists {
		return scope
	}

	return nil
}

flatten_blocks_in_file :: proc(o: ^Optimizer, file: ^ast.File) -> int {
	flattened_count := 0

	nodes_to_process := make([dynamic]^ast.Node, o.alloc)
	defer delete(nodes_to_process)

	for decl in file.decls {
		append(&nodes_to_process, decl)
	}

	for len(nodes_to_process) > 0 {
		node := pop(&nodes_to_process)

		#partial switch n in node.derived {
		case ^ast.Block_Stmt:
			block := n
			i := 0
			for i < len(block.stmts) {
				stmt := block.stmts[i]

				if nested_block, is_block := stmt.derived.(^ast.Block_Stmt); is_block && len(nested_block.stmts) == 1 {
					if can_flatten_block(o, nested_block) {
						single_stmt := nested_block.stmts[0]

						if nested_scope, exists := o.symbols.node_scopes[nested_block.id]; exists {
							if parent_scope, parent_exists := o.symbols.node_scopes[block.id]; parent_exists {

								for sym in nested_scope.symbols {
									name_conflict := false
									for existing_sym in parent_scope.symbols {
										if existing_sym.name == sym.name {
											name_conflict = true
											break
										}
									}

									if !name_conflict {
										append(&parent_scope.symbols, sym)
									}
								}

								o.symbols.node_scopes[single_stmt.id] = parent_scope

								delete_key(&o.symbols.node_scopes, nested_block.id)

								clear(&nested_scope.symbols)
							}
						}

						o.node_parent[single_stmt] = node

						block.stmts[i] = single_stmt

						delete_key(&o.node_parent, nested_block)

						flattened_count += 1
						continue
					}
				}

				append(&nodes_to_process, stmt)
				i += 1
			}

		case ^ast.If_Stmt:
			if_stmt := n
			if if_stmt.body != nil {
				append(&nodes_to_process, if_stmt.body)
			}
			if if_stmt.else_stmt != nil {
				append(&nodes_to_process, if_stmt.else_stmt)
			}

		case ^ast.For_Stmt:
			for_stmt := n
			if for_stmt.body != nil {
				append(&nodes_to_process, for_stmt.body)
			}

		case ^ast.Func_Stmt:
			func_stmt := n
			if func_stmt.body != nil {
				append(&nodes_to_process, func_stmt.body)
			}

		case ^ast.Event_Stmt:
			event_stmt := n
			if event_stmt.body != nil {
				append(&nodes_to_process, event_stmt.body)
			}
		}
	}

	return flattened_count
}

is_builtin_factory :: proc(name: string) -> bool {
	factories := []string{
		"game_value", "item", "array", "dict", "location",
		"vec3", "sound", "particle", "block", "number",
		"text", "enum", "potion",
	}

	for factory in factories {
		if factory == name {
			return true
		}
	}
	return false
}

evaluate_builtin_factory :: proc(o: ^Optimizer, name: string, args: []^ast.Argument) -> Constant_Result {
	result: Constant_Result
	result.is_constant = false

	if name == "number" && len(args) == 1 {
		arg_result := evaluate_constant_expression(o, args[0].value)
		if arg_result.is_constant {
			if arg_result.type_kind == .Text {
				if str_val, ok := arg_result.value.(string); ok {
					if val, ok2 := strconv.parse_i64(str_val); ok2 {
						result.value = val
						result.type_kind = .Number
						result.is_constant = true
					} else if val, ok3 := strconv.parse_f64(str_val); ok3 {
						result.value = val
						result.type_kind = .Number
						result.is_constant = true
					}
				}
			} else if arg_result.type_kind == .Number {
				result = arg_result
			}
		}
	} else if name == "text" && len(args) == 1 {
		arg_result := evaluate_constant_expression(o, args[0].value)
		if arg_result.is_constant {
			if arg_result.type_kind == .Number {
				if i64_val, ok := arg_result.value.(i64); ok {
					result.value = fmt.tprintf("%d", i64_val)
					result.type_kind = .Text
					result.is_constant = true
				} else if f64_val, ok2 := arg_result.value.(f64); ok2 {
					result.value = fmt.tprintf("%f", f64_val)
					result.type_kind = .Text
					result.is_constant = true
				}
			} else if arg_result.type_kind == .Boolean {
				if bool_val, ok := arg_result.value.(bool); ok {
					result.value = bool_val ? "true" : "false"
					result.type_kind = .Text
					result.is_constant = true
				}
			}
		}
	} else if name == "enum" && len(args) == 1 {
		arg_result := evaluate_constant_expression(o, args[0].value)
		if arg_result.is_constant && arg_result.type_kind == .Text {
			result = arg_result
			result.type_kind = .Enum
		}
	}

	return result
}

analyze_usage :: proc(o: ^Optimizer) {
	collect_all_scopes(o, o.symbols.global_scope)

	build_parent_tree(o)

	for file in o.files {
		o.current_file = file
		ast.walk_file(o.pre_walker, file)
	}

	build_dependency_graph(o)

	mark_used_symbols(o)
}

remove_unused :: proc(o: ^Optimizer) -> int {
	check_for_unused_symbols(o)

	removed := remove_unused_symbols(o)

	return removed
}

remove_anonymous_assignments :: proc(o: ^Optimizer) -> int {
	removed_count := 0

	for file in o.files {
		o.current_file = file
		removed_count += remove_anonymous_assignments_from_node(o, cast(^ast.Node)file)
	}

	return removed_count
}

remove_anonymous_assignments_from_node :: proc(o: ^Optimizer, node: ^ast.Node) -> int {
	if node == nil { return 0 }

	removed_count := 0

	#partial switch n in node.derived {
	case ^ast.File:
		file := n
		for stmt in file.decls {
			if is_anonymous_assignment(stmt) {
				schedule_node_removal(o, cast(^ast.Node)stmt, "remove anonymous assignment", nil)
				removed_count += 1
			} else {
				removed_count += remove_anonymous_assignments_from_node(o, cast(^ast.Node)stmt)
			}
		}

	case ^ast.Block_Stmt:
		block := n
		for stmt in block.stmts {
			if is_anonymous_assignment(stmt) {
				schedule_node_removal(o, cast(^ast.Node)stmt, "remove anonymous assignment", nil)
				removed_count += 1
			} else {
				removed_count += remove_anonymous_assignments_from_node(o, cast(^ast.Node)stmt)
			}
		}

	case ^ast.If_Stmt:
		if_stmt := n
		if if_stmt.init != nil {
			removed_count += remove_anonymous_assignments_from_node(o, if_stmt.init)
		}
		if if_stmt.body != nil {
			removed_count += remove_anonymous_assignments_from_node(o, cast(^ast.Node)if_stmt.body)
		}
		if if_stmt.else_stmt != nil {
			removed_count += remove_anonymous_assignments_from_node(o, cast(^ast.Node)if_stmt.else_stmt)
		}

	case ^ast.For_Stmt:
		for_stmt := n
		if for_stmt.post != nil {
			removed_count += remove_anonymous_assignments_from_node(o, for_stmt.post)
		}
		if for_stmt.body != nil {
			removed_count += remove_anonymous_assignments_from_node(o, cast(^ast.Node)for_stmt.body)
		}

	case ^ast.Func_Stmt:
		func_stmt := n
		if func_stmt.body != nil {
			removed_count += remove_anonymous_assignments_from_node(o, cast(^ast.Node)func_stmt.body)
		}

	case ^ast.Event_Stmt:
		event_stmt := n
		if event_stmt.body != nil {
			removed_count += remove_anonymous_assignments_from_node(o, cast(^ast.Node)event_stmt.body)
		}

	case ^ast.Defer_Stmt:
		defer_stmt := n
		if defer_stmt.stmt != nil {
			removed_count += remove_anonymous_assignments_from_node(o, defer_stmt.stmt)
		}
	}

	return removed_count
}

is_anonymous_assignment :: proc(stmt: ^ast.Stmt) -> bool {
	if stmt == nil { return false }

	#partial switch s in stmt.derived {
	case ^ast.Value_Decl:
		return s.name == "_" && s.value != nil
	case ^ast.Assign_Stmt:
		return s.name == "_" && s.expr != nil
	}
	return false
}

Variable_Value :: union {
	bool,
	i64,
	f64,
	string,
	Variable_Range,
}

Variable_Range :: struct {
	min:          f64,
	max:          f64,
	includes_min: bool,
	includes_max: bool,
}

Value_Operation :: enum {
	Add,
	Sub,
	Mul,
	Div,
	Mod,
	And,
	Or,
	Not,
}

Predicate_Type :: enum {
	Equal,
	Not_Equal,
	Greater,
	Greater_Equal,
	Less,
	Less_Equal,
	In_Range,
	Not_In_Range,
}

Variable_ID :: struct {
	scope_id:     int,
	name:         string,
	decl_node_id: int,
}

ConditionType :: enum {
	And,
	Or,
	Not,
	Predicate,
}

Condition_Node :: struct {
	type:      ConditionType,
	predicate: Maybe(Predicate),
	left:      ^Condition_Node,
	right:     ^Condition_Node,
	operand:   ^Condition_Node,
}

Predicate :: struct {
	variable: Variable_ID,
	value:    Variable_Value,
	type:     Predicate_Type,
	transformed_from: Variable_ID,
	pos: lexer.Pos,
	end: lexer.Pos,
}

Deep_Discrete_Set :: struct {
	kind:          Deep_Expression_Kind,
	values:        [dynamic]Variable_Value,
	is_exhaustive: bool,
}

Deep_Expression :: union {
	^Deep_Binary_Expression,
	^Deep_Unary_Expression,
	^Deep_Variable_Ref,
	^Deep_Constant_Value,
	^Deep_Union_Expression,
	^Deep_Discrete_Set,
}

Deep_Expression_Kind :: enum {
	Binary,
	Unary,
	Variable,
	Constant,
	Union,
	Discrete_Set,
}

Deep_Binary_Expression :: struct {
	kind:  Deep_Expression_Kind,
	op:    Value_Operation,
	left:  ^Deep_Expression,
	right: ^Deep_Expression,
}

Deep_Unary_Expression :: struct {
	kind:    Deep_Expression_Kind,
	op:      Value_Operation,
	operand: ^Deep_Expression,
}

Deep_Variable_Ref :: struct {
	kind:   Deep_Expression_Kind,
	var_id: Variable_ID,
}

Deep_Constant_Value :: struct {
	kind:  Deep_Expression_Kind,
	value: Variable_Value,
}

Deep_Union_Expression :: struct {
	kind:          Deep_Expression_Kind,
	expressions:   [dynamic]Deep_Expression,
	is_exhaustive: bool,
	min_value:     Maybe(f64),
	max_value:     Maybe(f64),
	value_range:   Maybe(Variable_Range),
}

Deep_Expression_Context :: struct {
	parent: ^Deep_Expression_Context,
	scope:  ^checker.Scope,

	variables:              map[Variable_ID]Deep_Expression,
	constraints:            map[Variable_ID][dynamic]Predicate,
	transformed_predicates: map[Variable_ID][dynamic]Predicate,

	name_to_var_id: map[string]Variable_ID,

	is_or_context:   bool,
	possible_states: [dynamic]^Deep_Expression_Context,
}

Variable_History :: struct {
	var_id:        Variable_ID,
	values:        [dynamic]Deep_Expression,
	current_index: int,
}

Deep_Analyzer :: struct {
	walker:           ^ast.Walker,
	walker_vtable:    ast.Visitor_VTable,
	expression_cache: map[Variable_ID]Variable_Value,

	variable_expressions:    map[Variable_ID]Deep_Expression,
	expression_deps:         map[Variable_ID][dynamic]Variable_ID,
	reverse_expression_deps: map[Variable_ID][dynamic]Variable_ID,

	expression_contexts:        [dynamic]^Deep_Expression_Context,
	current_expression_context: ^Deep_Expression_Context,

	scope_to_context:  map[^checker.Scope]^Deep_Expression_Context,

	var_id_to_scope:   map[Variable_ID]^checker.Scope,
	node_id_to_var_id: map[int]Variable_ID,

	if_else_contexts:  map[^ast.If_Stmt]If_Else_Contexts,

	function_expressions:   map[^checker.Symbol]Deep_Expression,
	function_params:        map[^checker.Symbol][dynamic]Variable_ID,
	function_calls:         map[^ast.Call_Expr]^checker.Symbol,
	call_arguments:         map[^ast.Call_Expr][dynamic]Deep_Expression,
	analyzing_function:     ^checker.Symbol,
	function_return_cache:  map[[2]uintptr]Deep_Expression,
	analyzed_functions:     map[^checker.Symbol]bool,

	variable_history:       map[Variable_ID]Variable_History,
	current_function_scope: ^checker.Scope,
	history_stack:          [dynamic]map[Variable_ID]Variable_History,

	visited_nodes: map[int]bool,
}

If_Else_Contexts :: struct {
	if_context:     ^Deep_Expression_Context,
	else_context:   ^Deep_Expression_Context,
	parent_context: ^Deep_Expression_Context,
	condition_tree: ^Condition_Node,
}

variable_id_eq :: proc(a, b: Variable_ID) -> bool {
	return a.scope_id == b.scope_id &&
		   a.name == b.name &&
		   a.decl_node_id == b.decl_node_id
}

create_variable_id :: proc(o: ^Optimizer, name: string, decl_node: ^ast.Node) -> Variable_ID {
	id := Variable_ID{
		name = name,
		decl_node_id = decl_node.id,
	}

	if scope, exists := o.symbols.node_scopes[decl_node.id]; exists {
		id.scope_id = scope.id
		o.deep_analyzer.var_id_to_scope[id] = scope
	} else if o.current_scope != nil {
		id.scope_id = o.current_scope.id
		o.deep_analyzer.var_id_to_scope[id] = o.current_scope
	}

	o.deep_analyzer.node_id_to_var_id[decl_node.id] = id
	return id
}

find_variable_id_in_current_scope :: proc(o: ^Optimizer, name: string) -> (Variable_ID, bool) {
	ctx := o.deep_analyzer.current_expression_context

	if ctx != nil {
		if var_id, exists := ctx.name_to_var_id[name]; exists {
			return var_id, true
		}
	}

	current_scope := o.current_scope
	for current_scope != nil {
		for var_id, scope in o.deep_analyzer.var_id_to_scope {
			if scope == current_scope && var_id.name == name {
				return var_id, true
			}
		}
		current_scope = current_scope.parent
	}

	return {}, false
}

get_variable_id_for_name :: proc(o: ^Optimizer, name: string, usage_node: ^ast.Node) -> Variable_ID {
	if var_id, found := find_variable_id_in_current_scope(o, name); found {
		return var_id
	}

	sym := find_symbol_in_scopes(o, name, o.current_scope)
	if sym != nil && sym.decl_node != nil {
		if existing_id, exists := o.deep_analyzer.node_id_to_var_id[sym.decl_node.id]; exists {
			return existing_id
		}

		return Variable_ID{
			name = name,
			scope_id = get_scope_id_for_symbol(o, sym),
			decl_node_id = sym.decl_node.id,
		}
	}

	return Variable_ID{
		name = name,
		scope_id = o.current_scope.id if o.current_scope != nil else 0,
		decl_node_id = usage_node.id,
	}
}

get_scope_id_for_symbol :: proc(o: ^Optimizer, sym: ^checker.Symbol) -> int {
	if sym == nil || sym.decl_node == nil {
		return 0
	}

	if scope, exists := o.symbols.all_node_scopes[sym.decl_node.id]; exists {
		return scope.id
	}

	return 0
}

predicates_equal :: proc(pred1, pred2: Predicate) -> bool {
	if !variable_id_eq(pred1.variable, pred2.variable) || pred1.type != pred2.type {
		return false
	}

	#partial switch v1 in pred1.value {
	case f64:
		if v2, ok := pred2.value.(f64); ok {
			return v1 == v2
		}
	case bool:
		if v2, ok := pred2.value.(bool); ok {
			return v1 == v2
		}
	case string:
		if v2, ok := pred2.value.(string); ok {
			return v1 == v2
		}
	case:
		return false
	}

	return false
}

invert_predicate_type :: proc(type: Predicate_Type) -> Predicate_Type {
	#partial switch type {
	case .Equal: return .Not_Equal
	case .Not_Equal: return .Equal
	case .Greater: return .Less_Equal
	case .Greater_Equal: return .Less
	case .Less: return .Greater_Equal
	case .Less_Equal: return .Greater
	case .In_Range: return .Not_In_Range
	case .Not_In_Range: return .In_Range
	case: return type
	}
}

extract_condition_tree :: proc(o: ^Optimizer, cond: ^ast.Expr) -> ^Condition_Node {
	if cond == nil { return nil }

	node := new(Condition_Node, o.alloc)

	#partial switch c in cond.derived {
	case ^ast.Binary_Expr:
		binary := c

		#partial switch binary.op.kind {
		case .Cmp_And:
			node.type = .And
			node.left = extract_condition_tree(o, binary.left)
			node.right = extract_condition_tree(o, binary.right)

		case .Cmp_Or:
			node.type = .Or
			node.left = extract_condition_tree(o, binary.left)
			node.right = extract_condition_tree(o, binary.right)

		case .Cmp_Eq, .Not_Eq, .Gt, .Gt_Eq, .Lt, .Lt_Eq:
			node.type = .Predicate
			if pred := extract_comparison_predicate(o, binary, false); pred != nil {
				node.predicate = pred^
			}

		case:
			node.type = .Predicate
			node.predicate = create_general_predicate(o, binary)
		}

	case ^ast.Unary_Expr:
		unary := c
		if unary.op.kind == .Not {
			node.type = .Not
			node.operand = extract_condition_tree(o, unary.expr)
		} else {
			node.type = .Predicate
			node.predicate = create_unary_predicate(o, unary)
		}

	case ^ast.Paren_Expr:
		paren := c
		return extract_condition_tree(o, paren.expr)

	case ^ast.Ident:
		ident := c
		node.type = .Predicate
		node.predicate = create_ident_predicate(o, ident)

	case ^ast.Basic_Lit:
		lit := c
		node.type = .Predicate
		node.predicate = create_literal_predicate(o, lit)

	case:
		node.type = .Predicate
		node.predicate = create_default_predicate(o, cond)
	}

	return node
}

create_unary_predicate :: proc(o: ^Optimizer, unary: ^ast.Unary_Expr) -> Predicate {
	var_id := Variable_ID{name = "__unary__", scope_id = 0, decl_node_id = unary.id}

	result := evaluate_constant_expression(o, cast(^ast.Expr)unary)
	if result.is_constant {
		return Predicate{
			variable = var_id,
			value = convert_constant_to_predicate_value(result),
			type = .Equal,
			pos = unary.pos,
			end = unary.end,
		}
	}

	return Predicate{
		variable = var_id,
		value = true,
		type = .Equal,
		pos = unary.pos,
		end = unary.end,
	}
}

create_general_predicate :: proc(o: ^Optimizer, binary: ^ast.Binary_Expr) -> Predicate {
	var_id := Variable_ID{name = "__binary__", scope_id = 0, decl_node_id = binary.id}

	result := evaluate_constant_expression(o, cast(^ast.Expr)binary)
	if result.is_constant {
		return Predicate{
			variable = var_id,
			value = convert_constant_to_predicate_value(result),
			type = .Equal,
			pos = binary.pos,
			end = binary.end,
		}
	}

	return Predicate{
		variable = var_id,
		value = true,
		type = .Equal,
		pos = binary.pos,
		end = binary.end,
	}
}

Check_Result :: enum {
	Impossible,
	Possible,
	Certain,
}

can_value_satisfy_predicate :: proc(
	o: ^Optimizer,
	value: Deep_Expression,
	pred: Predicate,
) -> Check_Result {
	if value == nil { return .Possible }

	#partial switch v in value {
	case ^Deep_Constant_Value:
		#partial switch val in v.value {
		case f64:
			return check_numeric_value(val, pred)
		case i64:
			return check_numeric_value(f64(val), pred)
		case bool:
			return check_boolean_value(val, pred)
		case string:
			return check_string_value(val, pred)
		case Variable_Range:
			return check_range_value(val, pred)
		}

	case ^Deep_Discrete_Set:
		return check_discrete_set(v, pred)

	case ^Deep_Union_Expression:
		return check_union_expression(o, v, pred)
	}

	return .Possible
}

check_numeric_value :: proc(val: f64, pred: Predicate) -> Check_Result {
	pred_val := get_numeric_value(pred.value)

	#partial switch pred.type {
	case .Equal:
		if abs(val - pred_val) < EPSILON {
			return .Certain
		}
		return .Impossible

	case .Not_Equal:
		if abs(val - pred_val) < EPSILON {
			return .Impossible
		}
		return .Certain

	case .Greater:
		if val > pred_val {
			return .Certain
		}
		return .Impossible

	case .Greater_Equal:
		if val >= pred_val {
			return .Certain
		}
		return .Impossible

	case .Less:
		if val < pred_val {
			return .Certain
		}
		return .Impossible

	case .Less_Equal:
		if val <= pred_val {
			return .Certain
		}
		return .Impossible

	case .In_Range:
		if range, ok := pred.value.(Variable_Range); ok {
			if is_value_in_range(val, range) {
				return .Certain
			}
			return .Impossible
		}

	case .Not_In_Range:
		if range, ok := pred.value.(Variable_Range); ok {
			if !is_value_in_range(val, range) {
				return .Certain
			}
			return .Impossible
		}
	}

	return .Possible
}

check_boolean_value :: proc(val: bool, pred: Predicate) -> Check_Result {
	pred_val: bool
	#partial switch v in pred.value {
	case bool:
		pred_val = v
	case:
		return .Possible
	}

	#partial switch pred.type {
	case .Equal:
		if val == pred_val {
			return .Certain
		}
		return .Impossible

	case .Not_Equal:
		if val != pred_val {
			return .Certain
		}
		return .Impossible
	}

	return .Possible
}

check_string_value :: proc(val: string, pred: Predicate) -> Check_Result {
	pred_val: string
	#partial switch v in pred.value {
	case string:
		pred_val = v
	case:
		return .Possible
	}

	#partial switch pred.type {
	case .Equal:
		if val == pred_val {
			return .Certain
		}
		return .Impossible

	case .Not_Equal:
		if val != pred_val {
			return .Certain
		}
		return .Impossible
	}

	return .Possible
}

check_range_value :: proc(range: Variable_Range, pred: Predicate) -> Check_Result {
	pred_val := get_numeric_value(pred.value)

	#partial switch pred.type {
	case .Equal:
		if is_value_in_range(pred_val, range) {
			if abs(range.max - range.min) < EPSILON {
				return .Certain
			}
			return .Possible
		}
		return .Impossible

	case .Not_Equal:
		if abs(range.max - range.min) < EPSILON {
			if abs(range.min - pred_val) < EPSILON {
				return .Impossible
			}
			return .Certain
		}
		if is_value_in_range(pred_val, range) {
			return .Possible
		}
		return .Certain

	case .Greater:
		if range.min > pred_val {
			return .Certain
		}
		if range.max <= pred_val {
			return .Impossible
		}
		return .Possible

	case .Greater_Equal:
		if range.min >= pred_val {
			return .Certain
		}
		if range.max < pred_val {
			return .Impossible
		}
		return .Possible

	case .Less:
		if range.max < pred_val {
			return .Certain
		}
		if range.min >= pred_val {
			return .Impossible
		}
		return .Possible

	case .Less_Equal:
		if range.max <= pred_val {
			return .Certain
		}
		if range.min > pred_val {
			return .Impossible
		}
		return .Possible

	case .In_Range:
		if target, ok := pred.value.(Variable_Range); ok {
			if is_range_completely_within(range, target) {
				return .Certain
			}
			if ranges_intersect(range, target) {
				return .Possible
			}
			return .Impossible
		}

	case .Not_In_Range:
		if target, ok := pred.value.(Variable_Range); ok {
			if !ranges_intersect(range, target) {
				return .Certain
			}
			if is_range_completely_within(range, target) {
				return .Impossible
			}
			return .Possible
		}
	}

	return .Possible
}

check_discrete_set :: proc(set: ^Deep_Discrete_Set, pred: Predicate) -> Check_Result {
	results := make([dynamic]Check_Result, context.temp_allocator)
	defer delete(results)

	for val in set.values {
		#partial switch v in val {
		case f64:
			append(&results, check_numeric_value(v, pred))
		case i64:
			append(&results, check_numeric_value(f64(v), pred))
		case bool:
			append(&results, check_boolean_value(v, pred))
		case string:
			append(&results, check_string_value(v, pred))
		case Variable_Range:
			append(&results, check_range_value(v, pred))
		}
	}

	all_impossible := true
	all_certain := true
	has_possible := false

	for res in results {
		if res == .Certain {
			all_impossible = false
		} else if res == .Possible {
			all_impossible = false
			all_certain = false
			has_possible = true
		} else if res == .Impossible {
			all_certain = false
		}
	}

	if set.is_exhaustive {
		if all_impossible {
			return .Impossible
		}
		if all_certain && len(results) > 0 {
			return .Certain
		}
	}

	if has_possible {
		return .Possible
	}

	return .Possible
}

check_union_expression :: proc(
	o: ^Optimizer,
	union_expr: ^Deep_Union_Expression,
	pred: Predicate,
) -> Check_Result {
	results := make([dynamic]Check_Result, context.temp_allocator)
	defer delete(results)

	for expr in union_expr.expressions {
		append(&results, can_value_satisfy_predicate(o, expr, pred))
	}

	has_possible := false
	for res in results {
		if res == .Certain {
			return .Certain
		}
		if res == .Possible {
			has_possible = true
		}
	}

	if has_possible {
		return .Possible
	}
	return .Impossible
}

is_value_in_range :: proc(val: f64, range: Variable_Range) -> bool {
	if val < range.min - EPSILON {
		return false
	}
	if val > range.max + EPSILON {
		return false
	}

	if abs(val - range.min) < EPSILON {
		return range.includes_min
	}
	if abs(val - range.max) < EPSILON {
		return range.includes_max
	}

	return true
}

ranges_intersect :: proc(r1, r2: Variable_Range) -> bool {
	if r1.max < r2.min - EPSILON {
		return false
	}
	if r2.max < r1.min - EPSILON {
		return false
	}

	if abs(r1.max - r2.min) < EPSILON {
		return r1.includes_max && r2.includes_min
	}
	if abs(r2.max - r1.min) < EPSILON {
		return r2.includes_max && r1.includes_min
	}

	return true
}

is_range_completely_within :: proc(inner, outer: Variable_Range) -> bool {
	if inner.min < outer.min - EPSILON {
		return false
	}
	if inner.max > outer.max + EPSILON {
		return false
	}

	if abs(inner.min - outer.min) < EPSILON {
		if !outer.includes_min && inner.includes_min {
			return false
		}
	}

	if abs(inner.max - outer.max) < EPSILON {
		if !outer.includes_max && inner.includes_max {
			return false
		}
	}

	return true
}

create_ident_predicate :: proc(o: ^Optimizer, ident: ^ast.Ident) -> Predicate {
	var_id := get_variable_id_for_name(o, ident.name, cast(^ast.Node)ident)

	return Predicate{
		variable = var_id,
		value = true,
		type = .Equal,
		pos = ident.pos,
		end = ident.end,
	}
}

create_literal_predicate :: proc(o: ^Optimizer, lit: ^ast.Basic_Lit) -> Predicate {
	result := evaluate_constant_expression(o, cast(^ast.Expr)lit)

	return Predicate{
		variable = Variable_ID{name = "__constant__", scope_id = 0, decl_node_id = lit.id},
		value = convert_constant_to_predicate_value(result),
		type = .Equal,
		pos = lit.pos,
		end = lit.end,
	}
}

create_default_predicate :: proc(o: ^Optimizer, expr: ^ast.Expr) -> Predicate {
	return Predicate{
		variable = Variable_ID{name = "__expr__", scope_id = 0, decl_node_id = expr.id},
		value = true,
		type = .Equal,
		pos = expr.pos,
		end = expr.end,
	}
}

invert_condition_tree :: proc(o: ^Optimizer, node: ^Condition_Node) -> ^Condition_Node {
	if node == nil { return nil }

	result := new(Condition_Node, o.alloc)

	switch node.type {
	case .And:
		result.type = .Or
		result.left = invert_condition_tree(o, node.left)
		result.right = invert_condition_tree(o, node.right)

	case .Or:
		result.type = .And
		result.left = invert_condition_tree(o, node.left)
		result.right = invert_condition_tree(o, node.right)

	case .Not:
		return clone_condition_tree(o, node.operand)

	case .Predicate:
		result.type = .Predicate
		if pred, ok := node.predicate.?; ok {
			inverted_pred := pred
			inverted_pred.type = invert_predicate_type(pred.type)
			result.predicate = inverted_pred
		}
	}

	return result
}

clone_condition_tree :: proc(o: ^Optimizer, node: ^Condition_Node) -> ^Condition_Node {
	if node == nil { return nil }

	clone := new(Condition_Node, o.alloc)
	clone.type = node.type
	clone.predicate = node.predicate

	if node.left != nil {
		clone.left = clone_condition_tree(o, node.left)
	}
	if node.right != nil {
		clone.right = clone_condition_tree(o, node.right)
	}
	if node.operand != nil {
		clone.operand = clone_condition_tree(o, node.operand)
	}

	return clone
}

free_condition_tree :: proc(o: ^Optimizer, node: ^Condition_Node) {
	if node == nil { return }

	free_condition_tree(o, node.left)
	free_condition_tree(o, node.right)
	free_condition_tree(o, node.operand)

	free(node, o.alloc)
}

apply_condition_to_context :: proc(
	o: ^Optimizer,
	node: ^Condition_Node,
	ctx: ^Deep_Expression_Context,
) {
	if node == nil { return }

	switch node.type {
	case .And:
		apply_condition_to_context(o, node.left, ctx)
		apply_condition_to_context(o, node.right, ctx)

	case .Or:
		apply_or_to_context(o, node, ctx)

	case .Not:
		inverted := invert_condition_tree(o, node.operand)
		defer free_condition_tree(o, inverted)
		apply_condition_to_context(o, inverted, ctx)

	case .Predicate:
		if pred, ok := node.predicate.?; ok {
			deep_apply_predicate_to_context(o, pred, ctx)
		}
	}
}

apply_or_to_context :: proc(
	o: ^Optimizer,
	node: ^Condition_Node,
	ctx: ^Deep_Expression_Context,
) {
	possible_states := make([dynamic]^Deep_Expression_Context, o.alloc)

	left_state := clone_context(o, ctx)
	apply_condition_to_context(o, node.left, left_state)
	append(&possible_states, left_state)

	right_state := clone_context(o, ctx)
	apply_condition_to_context(o, node.right, right_state)
	append(&possible_states, right_state)

	ctx.is_or_context = true
	ctx.possible_states = possible_states
}

extract_comparison_predicate :: proc(o: ^Optimizer, binary: ^ast.Binary_Expr, negated: bool) -> ^Predicate {
	pred := new(Predicate, o.alloc)

	left_ident, left_is_ident := binary.left.derived.(^ast.Ident)
	right_ident, right_is_ident := binary.right.derived.(^ast.Ident)
	left_const := evaluate_constant_expression(o, binary.left)
	right_const := evaluate_constant_expression(o, binary.right)

	if left_is_ident && right_const.is_constant {
		var_id := get_variable_id_for_name(o, left_ident.name, cast(^ast.Node)left_ident)
		pred.variable = var_id
		pred.value = convert_constant_to_predicate_value(right_const)
		set_predicate_type(pred, binary.op.kind, true, negated)
		return pred
	}

	if right_is_ident && left_const.is_constant {
		var_id := get_variable_id_for_name(o, right_ident.name, cast(^ast.Node)right_ident)
		pred.variable = var_id
		pred.value = convert_constant_to_predicate_value(left_const)
		set_predicate_type(pred, binary.op.kind, false, negated)
		return pred
	}

	if left_is_ident && right_is_ident {
		right_sym := find_symbol_in_scopes(o, right_ident.name, o.current_scope)
		if right_sym != nil && right_sym.is_const {
			if const_result := get_constant_value_from_symbol(o, right_sym); const_result.is_constant {
				var_id := get_variable_id_for_name(o, left_ident.name, cast(^ast.Node)left_ident)
				pred.variable = var_id
				pred.value = convert_constant_to_predicate_value(const_result)
				set_predicate_type(pred, binary.op.kind, true, negated)
				return pred
			}
		}

		left_sym := find_symbol_in_scopes(o, left_ident.name, o.current_scope)
		if left_sym != nil && left_sym.is_const {
			if const_result := get_constant_value_from_symbol(o, left_sym); const_result.is_constant {
				var_id := get_variable_id_for_name(o, right_ident.name, cast(^ast.Node)right_ident)
				pred.variable = var_id
				pred.value = convert_constant_to_predicate_value(const_result)
				set_predicate_type(pred, binary.op.kind, false, negated)
				return pred
			}
		}

		free(pred, o.alloc)
		return nil
	}

	free(pred, o.alloc)
	return nil
}

convert_constant_to_predicate_value :: proc(const_result: Constant_Result) -> Variable_Value {
	if !const_result.is_constant {
		return nil
	}

	#partial switch val in const_result.value {
	case bool:
		return val
	case i64:
		return f64(val)
	case f64:
		return val
	case string:
		return val
	}

	return nil
}

set_predicate_type :: proc(pred: ^Predicate, op_kind: lexer.Token_Kind, left_is_ident: bool, negated: bool) {
	#partial switch op_kind {
	case .Cmp_Eq:
		pred.type = .Equal if !negated else .Not_Equal

	case .Not_Eq:
		pred.type = .Not_Equal if !negated else .Equal

	case .Gt:
		if left_is_ident {
			pred.type = .Greater if !negated else .Less_Equal
		} else {
			pred.type = .Less if !negated else .Greater_Equal
		}

	case .Gt_Eq:
		if left_is_ident {
			pred.type = .Greater_Equal if !negated else .Less
		} else {
			pred.type = .Less_Equal if !negated else .Greater
		}

	case .Lt:
		if left_is_ident {
			pred.type = .Less if !negated else .Greater_Equal
		} else {
			pred.type = .Greater if !negated else .Less_Equal
		}

	case .Lt_Eq:
		if left_is_ident {
			pred.type = .Less_Equal if !negated else .Greater
		} else {
			pred.type = .Greater_Equal if !negated else .Less
		}
	}
}

convert_constant_to_variable_value :: proc(const_result: Constant_Result) -> Variable_Value {
	if !const_result.is_constant {
		return nil
	}

	#partial switch val in const_result.value {
	case bool:
		return val
	case i64:
		return f64(val)
	case f64:
		return val
	case string:
		return val
	}

	return nil
}

deep_token_kind_to_operation :: proc(tok: lexer.Token_Kind) -> Value_Operation {
	#partial switch tok {
	case .Add: return .Add
	case .Sub: return .Sub
	case .Mul: return .Mul
	case .Quo: return .Div
	case .Mod: return .Mod
	case .Cmp_And: return .And
	case .Cmp_Or: return .Or
	case .Not: return .Not
	case: return .Add
	}
}

INFINITE_RANGE := Variable_Range{min = min(f64), max = max(f64), includes_min = false, includes_max = false}

deep_transform_predicate_expression :: proc(o: ^Optimizer, pred: Predicate, from_var: Variable_ID, to_var: Variable_ID) -> ^Predicate {
	expr := find_expression_for_variable(o, from_var)
	if expr == nil {
		return create_default_predicate_for_var(o, pred, from_var, to_var)
	}

	new_pred := try_direct_transformation(o, pred, expr, from_var, to_var)
	if new_pred != nil {
		return new_pred
	}

	return try_recursive_transformation(o, pred, from_var, to_var, o.deep_analyzer.current_expression_context)
}

create_default_predicate_for_var :: proc(o: ^Optimizer, pred: Predicate, from_var, to_var: Variable_ID) -> ^Predicate {
	new_pred := new(Predicate, o.alloc)
	new_pred^ = pred
	new_pred.variable = to_var
	new_pred.transformed_from = from_var

	#partial switch val in pred.value {
	case f64, i64:
		new_pred.value = pred.value
	case:
		free(new_pred, o.alloc)
		return nil
	}

	return new_pred
}

try_direct_transformation :: proc(o: ^Optimizer, pred: Predicate, expr: Deep_Expression, from_var, to_var: Variable_ID) -> ^Predicate {
	if !deep_expression_contains_var_id(o, expr, to_var) {
		return nil
	}

	new_pred := new(Predicate, o.alloc)
	new_pred^ = pred
	new_pred.variable = to_var
	new_pred.transformed_from = from_var

	orig_value: f64
	#partial switch val in pred.value {
	case f64: orig_value = val
	case i64: orig_value = f64(val)
	case:
		free(new_pred, o.alloc)
		return nil
	}

	solved_expr := deep_solve_expression_for_var_id(o, expr, to_var)
	if solved_expr == nil {
		free(new_pred, o.alloc)
		return nil
	}
	defer deep_free_expression(o, solved_expr)

	new_val := deep_apply_expression_to_value_for_var_id(o, solved_expr, orig_value, to_var)
	if new_val == nil {
		free(new_pred, o.alloc)
		return nil
	}
	defer free(new_val, o.alloc)

	new_pred.value = new_val^

	multiplier := deep_get_expression_multiplier_for_var_id(o, expr, to_var)
	if multiplier < 0 {
		new_pred.type = invert_predicate_type(pred.type)
	}

	return new_pred
}

try_recursive_transformation :: proc(o: ^Optimizer, pred: Predicate, from_var, to_var: Variable_ID, ctx: ^Deep_Expression_Context) -> ^Predicate {
	deps := deep_get_all_dependencies_for_var_id(o, from_var)
	defer delete(deps)

	path := find_path_between_var_ids(o, from_var, to_var)
	defer delete(path)

	if len(path) == 0 {
		return nil
	}

	current_pred := new_clone(pred, o.alloc)

	for i := 1; i < len(path); i += 1 {
		next_var := path[i]

		expr := find_expression_for_variable(o, path[i-1])
		if expr == nil {
			free(current_pred, o.alloc)
			return nil
		}

		transformed_pred := try_direct_transformation(o, current_pred^, expr, path[i-1], next_var)
		if transformed_pred == nil {
			free(current_pred, o.alloc)
			return nil
		}

		free(current_pred, o.alloc)
		current_pred = transformed_pred
	}

	return current_pred
}

deep_get_all_dependencies_for_var_id :: proc(o: ^Optimizer, var_id: Variable_ID) -> [dynamic]Variable_ID {
	deps := make([dynamic]Variable_ID, o.alloc)

	collect_deps_recursive :: proc(o: ^Optimizer, var_id: Variable_ID, result: ^[dynamic]Variable_ID, visited: ^map[Variable_ID]bool) {
		if visited[var_id] { return }
		visited[var_id] = true

		expr := find_expression_for_variable(o, var_id)
		if expr == nil { return }

		vars_in_expr := deep_extract_variable_ids(o, expr)
		defer delete(vars_in_expr)

		for v in vars_in_expr {
			if !visited[v] {
				append(result, v)
				collect_deps_recursive(o, v, result, visited)
			}
		}
	}

	visited := make(map[Variable_ID]bool, o.alloc)
	defer delete(visited)

	collect_deps_recursive(o, var_id, &deps, &visited)
	return deps
}

find_path_between_var_ids :: proc(o: ^Optimizer, from_var, to_var: Variable_ID) -> [dynamic]Variable_ID {
	path := make([dynamic]Variable_ID, o.alloc)

	queue := make([dynamic]Variable_ID, o.alloc)
	defer delete(queue)

	visited := make(map[Variable_ID]bool, o.alloc)
	defer delete(visited)

	parent := make(map[Variable_ID]Variable_ID, o.alloc)
	defer delete(parent)

	append(&queue, from_var)
	visited[from_var] = true

	found := false

	for len(queue) > 0 {
		current := queue[0]
		ordered_remove(&queue, 0)

		if variable_id_eq(current, to_var) {
			found = true
			break
		}

		deps := deep_get_all_dependencies_for_var_id(o, current)
		defer delete(deps)

		for dep in deps {
			if !visited[dep] {
				visited[dep] = true
				parent[dep] = current
				append(&queue, dep)
			}
		}
	}

	if !found {
		return path
	}

	current := to_var
	for !variable_id_eq(current, from_var) {
		append(&path, current)
		current = parent[current]
	}
	append(&path, from_var)

	reversed := make([dynamic]Variable_ID, o.alloc)
	for i := len(path)-1; i >= 0; i -= 1 {
		append(&reversed, path[i])
	}

	delete(path)
	return reversed
}

is_builtin_function :: proc(o: ^Optimizer, sym: ^checker.Symbol) -> bool {
	if sym == nil { return false }

	if flags_field, has := sym.metadata["flags"]; has {
		if flags, ok := flags_field.(checker.Flags); ok {
			return .BUILTIN in flags || .NATIVE in flags
		}
	}

	if sym.decl_node != nil {
		#partial switch node in sym.decl_node.derived {
		case ^ast.Func_Stmt:
			return node.body == nil
		case ^ast.Event_Stmt:
			return node.body == nil
		}
	}

	return true
}

create_default_value_for_type :: proc(o: ^Optimizer, type_kind: checker.Type_Kind) -> Deep_Expression {
	#partial switch type_kind {
	case .Number:
		const_expr := new(Deep_Constant_Value, o.alloc)
		const_expr.kind = .Constant
		const_expr.value = INFINITE_RANGE
		return cast(Deep_Expression)const_expr

	case .Boolean:
		discrete_set := new(Deep_Discrete_Set, o.alloc)
		discrete_set.kind = .Discrete_Set
		discrete_set.values = make([dynamic]Variable_Value, o.alloc)
		discrete_set.is_exhaustive = true
		append(&discrete_set.values, bool(true))
		append(&discrete_set.values, bool(false))
		return cast(Deep_Expression)discrete_set

	case .Text:
		const_expr := new(Deep_Constant_Value, o.alloc)
		const_expr.kind = .Constant
		const_expr.value = ""
		return cast(Deep_Expression)const_expr
	}

	return nil
}

get_function_return_type :: proc(o: ^Optimizer, sym: ^checker.Symbol) -> checker.Type_Kind {
	if sym == nil || sym.type == nil {
		return .Any
	}

	if sym.type.kind == .Function && sym.type.return_t != nil {
		return sym.type.return_t.kind
	}

	return .Any
}

analyze_expression_range :: proc(o: ^Optimizer, expr: Deep_Expression) -> (Maybe(Variable_Range), bool) {
	if expr == nil { return nil, false }

	#partial switch e in expr {
	case ^Deep_Constant_Value:
		#partial switch val in e.value {
		case Variable_Range:
			return val, true
		case f64:
			return Variable_Range{
				min = val,
				max = val,
				includes_min = true,
				includes_max = true,
			}, true
		case i64:
			fval := f64(val)
			return Variable_Range{
				min = fval,
				max = fval,
				includes_min = true,
				includes_max = true,
			}, true
		}
		return nil, false

	case ^Deep_Binary_Expression:
		left_range, left_ok := analyze_expression_range(o, e.left^)
		right_range, right_ok := analyze_expression_range(o, e.right^)

		if !left_ok || !right_ok {
			return nil, false
		}

		lr := left_range.(Variable_Range)
		rr := right_range.(Variable_Range)

		#partial switch e.op {
		case .Add:
			return Variable_Range{
				min = lr.min + rr.min,
				max = lr.max + rr.max,
				includes_min = lr.includes_min && rr.includes_min,
				includes_max = lr.includes_max && rr.includes_max,
			}, true

		case .Sub:
			return Variable_Range{
				min = lr.min - rr.max,
				max = lr.max - rr.min,
				includes_min = lr.includes_min && rr.includes_max,
				includes_max = lr.includes_max && rr.includes_min,
			}, true

		case .Mul:
			values := [4]f64{
				lr.min * rr.min,
				lr.min * rr.max,
				lr.max * rr.min,
				lr.max * rr.max,
			}
			min_val := values[0]
			max_val := values[0]
			for v in values {
				if v < min_val { min_val = v }
				if v > max_val { max_val = v }
			}
			return Variable_Range{
				min = min_val,
				max = max_val,
				includes_min = lr.includes_min && rr.includes_min,
				includes_max = lr.includes_max && rr.includes_max,
			}, true

		case .Div:
			if rr.min <= 0 && rr.max >= 0 {
				if abs(rr.min) < EPSILON || abs(rr.max) < EPSILON {
					return nil, false
				}
			}

			values := [4]f64{
				lr.min / rr.min,
				lr.min / rr.max,
				lr.max / rr.min,
				lr.max / rr.max,
			}
			min_val := values[0]
			max_val := values[0]
			for v in values {
				if !math.is_inf(v) && !math.is_nan(v) {
					if v < min_val { min_val = v }
					if v > max_val { max_val = v }
				}
			}
			return Variable_Range{
				min = min_val,
				max = max_val,
				includes_min = lr.includes_min && rr.includes_max,
				includes_max = lr.includes_max && rr.includes_min,
			}, true
		case .Mod:
			if rr.min <= 0 && rr.max >= 0 {
				if abs(rr.min) < EPSILON || abs(rr.max) < EPSILON {
					return nil, false
				}
			}

			max_divisor := max(abs(rr.min), abs(rr.max))

			min_divisor := min(abs(rr.min), abs(rr.max))

			if abs(min_divisor - math.floor(min_divisor)) < EPSILON &&
			   abs(max_divisor - math.floor(max_divisor)) < EPSILON {
				max_value := max_divisor - 1.0

				return Variable_Range{
					min = 0,
					max = max_value,
					includes_min = true,
					includes_max = true,
				}, true
			} else {
				return Variable_Range{
					min = 0,
					max = max_divisor,
					includes_min = true,
					includes_max = false,
				}, true
			}
		}

	case ^Deep_Variable_Ref:
		if value := get_current_value(o, e.var_id); value != nil {
			return analyze_expression_range(o, value)
		}
	}

	return nil, false
}

create_union_expression :: proc(
	o: ^Optimizer,
	expressions: [dynamic]Deep_Expression,
	is_exhaustive: bool,
) -> ^Deep_Union_Expression {
	normalized := make([dynamic]Deep_Expression, o.alloc)
	defer delete(normalized)

	for expr in expressions {
		normalize_expression(o, expr, &normalized)
	}

	unique := make([dynamic]Deep_Expression, o.alloc)
	for expr in normalized {
		if !is_expression_in_list(o, expr, unique[:]) {
			append(&unique, expr)
		}
	}

	union_expr := new(Deep_Union_Expression, o.alloc)
	union_expr.kind = .Union
	union_expr.expressions = make([dynamic]Deep_Expression, o.alloc)
	union_expr.is_exhaustive = is_exhaustive

	all_ranges_ok := true
	has_range := false
	ranges := make([dynamic]Variable_Range, o.alloc)
	defer delete(ranges)

	for expr in unique {
		cloned := deep_clone_expression(o, expr)
		append(&union_expr.expressions, cloned)

		if range_val, ok := analyze_expression_range(o, expr); ok {
			r := range_val.(Variable_Range)
			append(&ranges, r)
			has_range = true
		} else {
			all_ranges_ok = false
		}
	}

	if all_ranges_ok && len(ranges) > 0 {
		min_val := ranges[0].min
		max_val := ranges[0].max
		includes_min := ranges[0].includes_min
		includes_max := ranges[0].includes_max

		for r in ranges[1:] {
			if r.min < min_val {
				min_val = r.min
				includes_min = r.includes_min
			}
			if r.max > max_val {
				max_val = r.max
				includes_max = r.includes_max
			}
		}

		union_expr.min_value = min_val
		union_expr.max_value = max_val
		union_expr.value_range = Variable_Range{
			min = min_val,
			max = max_val,
			includes_min = includes_min,
			includes_max = includes_max,
		}
	}

	return union_expr
}

combine_return_expressions :: proc(o: ^Optimizer, exprs: [dynamic]Deep_Expression) -> Deep_Expression {
	if len(exprs) == 0 { return nil }
	if len(exprs) == 1 { return deep_clone_expression(o, exprs[0]) }

	normalized := make([dynamic]Deep_Expression, o.alloc)
	defer delete(normalized)

	for expr in exprs {
		normalize_expression(o, expr, &normalized)
	}

	unique := make([dynamic]Deep_Expression, o.alloc)
	defer delete(unique)

	for expr in normalized {
		if !is_expression_in_list(o, expr, unique[:]) {
			append(&unique, expr)
		}
	}

	if len(unique) == 1 {
		return unique[0]
	}

	all_constants := true
	for expr in unique {
		#partial switch e in expr {
		case ^Deep_Constant_Value:
			continue
		case:
			all_constants = false
		}
	}

	if all_constants {
		discrete_set := new(Deep_Discrete_Set, o.alloc)
		discrete_set.kind = .Discrete_Set
		discrete_set.values = make([dynamic]Variable_Value, o.alloc)
		discrete_set.is_exhaustive = true

		seen := make(map[Variable_Value]bool, o.alloc)
		defer delete(seen)

		for expr in unique {
			#partial switch e in expr {
			case ^Deep_Constant_Value:
				if !seen[e.value] {
					seen[e.value] = true
					append(&discrete_set.values, e.value)
				}
				deep_free_expression(o, expr)
			}
		}

		if len(discrete_set.values) == 1 {
			const_expr := new(Deep_Constant_Value, o.alloc)
			const_expr.kind = .Constant
			const_expr.value = discrete_set.values[0]
			delete(discrete_set.values)
			free(discrete_set, o.alloc)
			return const_expr
		}

		return cast(Deep_Expression)discrete_set
	}

	return create_union_expression(o, unique, true)
}

normalize_expression :: proc(o: ^Optimizer, expr: Deep_Expression, result: ^[dynamic]Deep_Expression) {
	if expr == nil { return }

	#partial switch e in expr {
	case ^Deep_Union_Expression:
		for sub_expr in e.expressions {
			normalize_expression(o, sub_expr, result)
		}
	case:
		append(result, expr)
	}
}

is_expression_in_list :: proc(o: ^Optimizer, expr: Deep_Expression, list: []Deep_Expression) -> bool {
	for item in list {
		if deep_expressions_equal(o, expr, item) {
			return true
		}
	}
	return false
}

deep_expressions_equal :: proc(o: ^Optimizer, a, b: Deep_Expression) -> bool {
	if a == nil && b == nil { return true }
	if a == nil || b == nil { return false }

	#partial switch a_expr in a {
	case ^Deep_Constant_Value:
		#partial switch b_expr in b {
		case ^Deep_Constant_Value:
			#partial switch a_val in a_expr.value {
			case f64:
				if b_val, ok := b_expr.value.(f64); ok {
					return abs(a_val - b_val) < EPSILON
				}
			case i64:
				if b_val, ok := b_expr.value.(i64); ok {
					return a_val == b_val
				}
			case bool:
				if b_val, ok := b_expr.value.(bool); ok {
					return a_val == b_val
				}
			case string:
				if b_val, ok := b_expr.value.(string); ok {
					return a_val == b_val
				}
			case Variable_Range:
				if b_val, ok := b_expr.value.(Variable_Range); ok {
					return abs(a_val.min - b_val.min) < EPSILON &&
						   abs(a_val.max - b_val.max) < EPSILON &&
						   a_val.includes_min == b_val.includes_min &&
						   a_val.includes_max == b_val.includes_max
				}
			}
		}

	case ^Deep_Variable_Ref:
		#partial switch b_expr in b {
		case ^Deep_Variable_Ref:
			return variable_id_eq(a_expr.var_id, b_expr.var_id)
		}

	case ^Deep_Binary_Expression:
		#partial switch b_expr in b {
		case ^Deep_Binary_Expression:
			return a_expr.op == b_expr.op &&
				   deep_expressions_equal(o, a_expr.left^, b_expr.left^) &&
				   deep_expressions_equal(o, a_expr.right^, b_expr.right^)
		}

	case ^Deep_Unary_Expression:
		#partial switch b_expr in b {
		case ^Deep_Unary_Expression:
			return a_expr.op == b_expr.op &&
				   deep_expressions_equal(o, a_expr.operand^, b_expr.operand^)
		}

	case ^Deep_Union_Expression:
		#partial switch b_expr in b {
		case ^Deep_Union_Expression:
			if len(a_expr.expressions) != len(b_expr.expressions) {
				return false
			}
			for a_sub in a_expr.expressions {
				found := false
				for b_sub in b_expr.expressions {
					if deep_expressions_equal(o, a_sub, b_sub) {
						found = true
						break
					}
				}
				if !found {
					return false
				}
			}
			return true
		}

	case ^Deep_Discrete_Set:
		#partial switch b_expr in b {
		case ^Deep_Discrete_Set:
			if len(a_expr.values) != len(b_expr.values) {
				return false
			}
			for a_val in a_expr.values {
				found := false
				for b_val in b_expr.values {
					if compare_values(a_val, b_val) == 0 {
						found = true
						break
					}
				}
				if !found {
					return false
				}
			}
			return a_expr.is_exhaustive == b_expr.is_exhaustive
		}
	}

	return false
}

get_function_return_values :: proc(
	o: ^Optimizer,
	func_sym: ^checker.Symbol,
	call_ctx: ^Deep_Expression_Context,
	call_args: []^ast.Argument,
) -> Deep_Expression {
	if func_sym == nil || func_sym.decl_node == nil {
		return create_default_value_for_type(o, get_function_return_type(o, func_sym))
	}

	if is_builtin_function(o, func_sym) {
		return create_default_value_for_type(o, get_function_return_type(o, func_sym))
	}

	cache_key := get_function_cache_key_with_args(o, func_sym, call_ctx, call_args)

	if cached, exists := o.deep_analyzer.function_return_cache[cache_key]; exists {
		return deep_clone_expression(o, cached)
	}

	saved_scope := o.current_scope
	saved_level := o.current_level
	saved_ctx := o.deep_analyzer.current_expression_context
	saved_analyzing := o.deep_analyzer.analyzing_function

	saved_context_stack := make([dynamic]^Deep_Expression_Context, len(o.deep_analyzer.expression_contexts), o.alloc)
	copy(saved_context_stack[:], o.deep_analyzer.expression_contexts[:])

	saved_history_stack := make([dynamic]map[Variable_ID]Variable_History, len(o.deep_analyzer.history_stack), o.alloc)
	copy(saved_history_stack[:], o.deep_analyzer.history_stack[:])

	saved_variable_history := make(map[Variable_ID]Variable_History, len(o.deep_analyzer.variable_history), o.alloc)
	for var_id, hist in o.deep_analyzer.variable_history {
		new_hist := Variable_History{
			var_id = var_id,
			values = make([dynamic]Deep_Expression, len(hist.values), o.alloc),
			current_index = hist.current_index,
		}
		for val in hist.values {
			append(&new_hist.values, deep_clone_expression(o, val))
		}
		saved_variable_history[var_id] = new_hist
	}

	defer {
		o.current_scope = saved_scope
		o.current_level = saved_level
		o.deep_analyzer.analyzing_function = saved_analyzing

		clear(&o.deep_analyzer.expression_contexts)
		for ctx in saved_context_stack {
			append(&o.deep_analyzer.expression_contexts, ctx)
		}
		o.deep_analyzer.current_expression_context = saved_ctx

		clear(&o.deep_analyzer.history_stack)
		for hist_map in saved_history_stack {
			append(&o.deep_analyzer.history_stack, hist_map)
		}

		clear(&o.deep_analyzer.variable_history)
		for var_id, hist in saved_variable_history {
			o.deep_analyzer.variable_history[var_id] = hist
		}
	}

	decl_ctx: ^Deep_Expression_Context
	if scope, exists := o.symbols.node_scopes[func_sym.decl_node.id]; exists {
		if ctx, exists2 := o.deep_analyzer.scope_to_context[scope]; exists2 {
			decl_ctx = ctx
		} else {
			decl_ctx = deep_create_expression_context(o, scope)
			o.deep_analyzer.scope_to_context[scope] = decl_ctx
		}
	}

	params_scope: ^checker.Scope
	body_scope: ^checker.Scope
	body_node: ^ast.Block_Stmt

	#partial switch node in func_sym.decl_node.derived {
	case ^ast.Func_Stmt:
		if scope, exists := o.symbols.node_scopes[func_sym.decl_node.id]; exists {
			params_scope = scope
		}
		if node.body != nil {
			body_node = node.body
			if scope, exists := o.symbols.node_scopes[node.body.id]; exists {
				body_scope = scope
			}
		}
	}

	if body_scope == nil || body_node == nil || params_scope == nil {
		return create_default_value_for_type(o, get_function_return_type(o, func_sym))
	}

	o.deep_analyzer.analyzing_function = func_sym

	func_ctx := deep_create_expression_context(o, params_scope)
	if decl_ctx != nil {
		func_ctx.parent = decl_ctx
	} else if o.deep_analyzer.scope_to_context[o.symbols.global_scope] != nil {
		func_ctx.parent = o.deep_analyzer.scope_to_context[o.symbols.global_scope]
	}

	o.deep_analyzer.current_expression_context = func_ctx

	push_history_scope(o, body_scope)
	defer pop_history_scope(o)

	bind_parameters_to_args_with_call_ctx(o, func_sym, call_args, params_scope, func_ctx, call_ctx)

	ast.walk_node(o.deep_analyzer.walker, cast(^ast.Node)body_node)

	return_infos := collect_function_returns(o, func_sym, body_node)

	reachable_exprs := make([dynamic]Deep_Expression, o.alloc)
	defer delete(reachable_exprs)

	for info in return_infos {
		if is_return_reachable(o, info.return_stmt, func_ctx) {
			resolved := resolve_with_history(o, info.expr, {}, nil, nil, 0)
			if resolved != nil {
				append(&reachable_exprs, resolved)
			}
		}
	}

	result_expr: Deep_Expression
	if len(reachable_exprs) == 0 {
		result_expr = create_default_value_for_type(o, get_function_return_type(o, func_sym))
	} else if len(reachable_exprs) == 1 {
		result_expr = reachable_exprs[0]
	} else {
		all_same := true
		for i := 1; i < len(reachable_exprs); i += 1 {
			if !deep_expressions_equal(o, reachable_exprs[0], reachable_exprs[i]) {
				all_same = false
				break
			}
		}

		if all_same {
			result_expr = reachable_exprs[0]
			for i := 1; i < len(reachable_exprs); i += 1 {
				deep_free_expression(o, reachable_exprs[i])
			}
		} else {
			union_expr := create_union_expression(o, reachable_exprs, true)
			result_expr = union_expr
		}
	}

	o.deep_analyzer.function_return_cache[cache_key] = deep_clone_expression(o, result_expr)

	return result_expr
}

is_return_reachable :: proc(
	o: ^Optimizer,
	return_stmt: ^ast.Return_Stmt,
	ctx: ^Deep_Expression_Context,
) -> bool {
	if return_stmt == nil { return false }

	current := cast(^ast.Node)return_stmt
	path := make([dynamic]^ast.Node, o.alloc)
	defer delete(path)

	for current != nil {
		append(&path, current)

		#partial switch n in current.derived {
		case ^ast.Func_Stmt, ^ast.Event_Stmt:
			current = nil
		case:
			if parent, exists := o.node_parent[current]; exists {
				current = parent
			} else {
				current = nil
			}
		}
	}

	slice.reverse(path[:])

	for i := 0; i < len(path)-1; i += 1 {
		node := path[i]
		next_node := path[i+1]

		#partial switch n in node.derived {
		case ^ast.If_Stmt:
			if_stmt := n
			condition_tree := extract_condition_tree(o, if_stmt.cond)
			defer free_condition_tree(o, condition_tree)

			is_then_branch := if_stmt.body == next_node

			if is_then_branch {
				if !can_condition_be_true(o, condition_tree, ctx) {
					return false
				}

			} else if if_stmt.else_stmt == next_node {
				if !can_condition_be_false(o, condition_tree, ctx) {
					return false
				}
			}

		case ^ast.For_Stmt:
			for_stmt := n
			if for_stmt.cond != nil && for_stmt.body == next_node {
				condition_tree := extract_condition_tree(o, for_stmt.cond)
				defer free_condition_tree(o, condition_tree)

				if !can_condition_be_true(o, condition_tree, ctx) {
					return false
				}
			}
		}
	}

	return true
}

can_condition_be_true :: proc(
	o: ^Optimizer,
	node: ^Condition_Node,
	ctx: ^Deep_Expression_Context,
) -> bool {
	if node == nil { return true }

	switch node.type {
	case .And:
		return can_condition_be_true(o, node.left, ctx) &&
			   can_condition_be_true(o, node.right, ctx)

	case .Or:
		return can_condition_be_true(o, node.left, ctx) ||
			   can_condition_be_true(o, node.right, ctx)

	case .Not:
		return !can_condition_be_true(o, node.operand, ctx)

	case .Predicate:
		if pred, ok := node.predicate.?; ok {
			result := can_value_satisfy_predicate(o, ctx.variables[pred.variable], pred)
			return result != .Impossible
		}
		return true
	}

	return true
}

can_condition_be_false :: proc(
	o: ^Optimizer,
	node: ^Condition_Node,
	ctx: ^Deep_Expression_Context,
) -> bool {
	if node == nil { return true }

	switch node.type {
	case .And:
		return can_condition_be_false(o, node.left, ctx) ||
			   can_condition_be_false(o, node.right, ctx)

	case .Or:
		return can_condition_be_false(o, node.left, ctx) &&
			   can_condition_be_false(o, node.right, ctx)

	case .Not:
		return !can_condition_be_false(o, node.operand, ctx)

	case .Predicate:
		if pred, ok := node.predicate.?; ok {
			result := can_value_satisfy_predicate(o, ctx.variables[pred.variable], pred)
			return result != .Certain
		}
		return true
	}

	return true
}

perform_range_arithmetic :: proc(
	op: Value_Operation,
	left_val: Variable_Value,
	right_val: Variable_Value,
) -> (Variable_Value, bool) {

	left_is_range := false
	right_is_range := false

	_, left_is_range = left_val.(Variable_Range)
	_, right_is_range = right_val.(Variable_Range)

	if !left_is_range && !right_is_range {
		return nil, false
	}

	#partial switch op {
	case .Add:
		if left_is_range && right_is_range {
			l_range := left_val.(Variable_Range)
			r_range := right_val.(Variable_Range)
			return Variable_Range{
				min = l_range.min + r_range.min,
				max = l_range.max + r_range.max,
				includes_min = l_range.includes_min && r_range.includes_min,
				includes_max = l_range.includes_max && r_range.includes_max,
			}, true
		} else if left_is_range {
			l_range := left_val.(Variable_Range)
			r_num := get_numeric_value(right_val)
			return Variable_Range{
				min = l_range.min + r_num,
				max = l_range.max + r_num,
				includes_min = l_range.includes_min,
				includes_max = l_range.includes_max,
			}, true
		} else {
			l_num := get_numeric_value(left_val)
			r_range := right_val.(Variable_Range)
			return Variable_Range{
				min = l_num + r_range.min,
				max = l_num + r_range.max,
				includes_min = r_range.includes_min,
				includes_max = r_range.includes_max,
			}, true
		}

	case .Sub:
		if left_is_range && right_is_range {
			l_range := left_val.(Variable_Range)
			r_range := right_val.(Variable_Range)
			return Variable_Range{
				min = l_range.min - r_range.max,
				max = l_range.max - r_range.min,
				includes_min = l_range.includes_min && r_range.includes_max,
				includes_max = l_range.includes_max && r_range.includes_min,
			}, true
		} else if left_is_range {
			l_range := left_val.(Variable_Range)
			r_num := get_numeric_value(right_val)
			return Variable_Range{
				min = l_range.min - r_num,
				max = l_range.max - r_num,
				includes_min = l_range.includes_min,
				includes_max = l_range.includes_max,
			}, true
		} else {
			l_num := get_numeric_value(left_val)
			r_range := right_val.(Variable_Range)
			return Variable_Range{
				min = l_num - r_range.max,
				max = l_num - r_range.min,
				includes_min = true,
				includes_max = true,
			}, true
		}

	case .Mul:
		if left_is_range && right_is_range {
			l_range := left_val.(Variable_Range)
			r_range := right_val.(Variable_Range)
			min1 := l_range.min * r_range.min
			min2 := l_range.min * r_range.max
			min3 := l_range.max * r_range.min
			min4 := l_range.max * r_range.max

			min_val := min(min1, min2, min3, min4)
			max_val := max(min1, min2, min3, min4)

			return Variable_Range{
				min = min_val,
				max = max_val,
				includes_min = l_range.includes_min && r_range.includes_min,
				includes_max = l_range.includes_max && r_range.includes_max,
			}, true
		} else if left_is_range {
			l_range := left_val.(Variable_Range)
			r_num := get_numeric_value(right_val)

			if r_num >= 0 {
				return Variable_Range{
					min = l_range.min * r_num,
					max = l_range.max * r_num,
					includes_min = l_range.includes_min,
					includes_max = l_range.includes_max,
				}, true
			} else {
				return Variable_Range{
					min = l_range.max * r_num,
					max = l_range.min * r_num,
					includes_min = l_range.includes_max,
					includes_max = l_range.includes_min,
				}, true
			}
		} else {
			l_num := get_numeric_value(left_val)
			r_range := right_val.(Variable_Range)

			if l_num >= 0 {
				return Variable_Range{
					min = l_num * r_range.min,
					max = l_num * r_range.max,
					includes_min = r_range.includes_min,
					includes_max = r_range.includes_max,
				}, true
			} else {
				return Variable_Range{
					min = l_num * r_range.max,
					max = l_num * r_range.min,
					includes_min = r_range.includes_max,
					includes_max = r_range.includes_min,
				}, true
			}
		}

	case .Div:
		if right_is_range {
			r_range := right_val.(Variable_Range)
			if r_range.min <= 0 && r_range.max >= 0 {
				return INFINITE_RANGE, true
			} else if left_is_range {
				l_range := left_val.(Variable_Range)
				min1 := l_range.min / r_range.max
				max1 := l_range.max / r_range.min
				return Variable_Range{
					min = min(min1, max1),
					max = max(min1, max1),
					includes_min = l_range.includes_min && r_range.includes_max,
					includes_max = l_range.includes_max && r_range.includes_min,
				}, true
			} else {
				l_num := get_numeric_value(left_val)
				min1 := l_num / r_range.max
				max1 := l_num / r_range.min
				return Variable_Range{
					min = min(min1, max1),
					max = max(min1, max1),
					includes_min = r_range.includes_max,
					includes_max = r_range.includes_min,
				}, true
			}
		} else if left_is_range {
			l_range := left_val.(Variable_Range)
			r_num := get_numeric_value(right_val)

			if abs(r_num) < EPSILON {
				return nil, false
			}

			if r_num > 0 {
				return Variable_Range{
					min = l_range.min / r_num,
					max = l_range.max / r_num,
					includes_min = l_range.includes_min,
					includes_max = l_range.includes_max,
				}, true
			} else {
				return Variable_Range{
					min = l_range.max / r_num,
					max = l_range.min / r_num,
					includes_min = l_range.includes_max,
					includes_max = l_range.includes_min,
				}, true
			}
		}
	case .Mod:
		if right_is_range {
			r_range := right_val.(Variable_Range)

			if r_range.min <= 0 && r_range.max >= 0 {
				if abs(r_range.min) < EPSILON || abs(r_range.max) < EPSILON {
					return nil, false
				}
			}

			max_divisor := max(abs(r_range.min), abs(r_range.max))
			min_divisor := min(abs(r_range.min), abs(r_range.max))

			all_integer := abs(min_divisor - math.floor(min_divisor)) < EPSILON &&
						  abs(max_divisor - math.floor(max_divisor)) < EPSILON

			if left_is_range {
				l_range := left_val.(Variable_Range)

				if all_integer {
					max_value := max_divisor - 1.0

					if l_range.max < min_divisor {
						max_value = min(max_value, l_range.max)
					}

					return Variable_Range{
						min = 0,
						max = max_value,
						includes_min = true,
						includes_max = true,
					}, true
				} else {
					return Variable_Range{
						min = 0,
						max = max_divisor,
						includes_min = true,
						includes_max = false,
					}, true
				}
			} else {
				l_num := get_numeric_value(left_val)
				l_int := i64(l_num)

				if all_integer && abs(l_num - math.floor(l_num)) < EPSILON {
					result := l_int % i64(max_divisor)
					return Variable_Range{
						min = f64(result),
						max = f64(result),
						includes_min = true,
						includes_max = true,
					}, true
				} else {
					return Variable_Range{
						min = 0,
						max = max_divisor,
						includes_min = true,
						includes_max = false,
					}, true
				}
			}
		} else if left_is_range {
			l_range := left_val.(Variable_Range)
			r_num := get_numeric_value(right_val)

			if abs(r_num) < EPSILON {
				return nil, false
			}

			if abs(r_num - math.floor(r_num)) < EPSILON {
				divisor := i64(r_num)

				return Variable_Range{
					min = 0,
					max = f64(divisor - 1),
					includes_min = true,
					includes_max = true,
				}, true
			} else {
				return Variable_Range{
					min = 0,
					max = abs(r_num),
					includes_min = true,
					includes_max = false,
				}, true
			}
		}
	}

	return nil, false
}

get_value_from_predicate :: proc(o: ^Optimizer, pred: Predicate) -> Maybe(Deep_Expression) {
	#partial switch pred.type {
	case .Equal:
		const_expr := new(Deep_Constant_Value, o.alloc)
		const_expr.kind = .Constant

		#partial switch val in pred.value {
		case f64:
			const_expr.value = val
			return const_expr
		case i64:
			const_expr.value = val
			return const_expr
		case bool:
			const_expr.value = val
			return const_expr
		case string:
			const_expr.value = val
			return const_expr
		case Variable_Range:
			const_expr.value = val
			return const_expr
		}
	}
	return nil
}

apply_predicate_to_union :: proc(
	o: ^Optimizer,
	union_expr: ^Deep_Union_Expression,
	pred: Predicate,
	depth: int,
) -> Deep_Expression {
	if union_expr == nil { return nil }

	#partial switch pred.type {
	case .Equal:
		target_val := get_numeric_value(pred.value)
		matching_exprs := make([dynamic]Deep_Expression, o.alloc)
		defer delete(matching_exprs)

		for expr in union_expr.expressions {
			#partial switch e in expr {
			case ^Deep_Constant_Value:
				if abs(get_numeric_value(e.value) - target_val) < EPSILON {
					return deep_clone_expression(o, expr)
				}

			case ^Deep_Union_Expression:
				narrowed := apply_predicate_to_union(o, e, pred, depth + 1)
				if narrowed != nil {
					if _, is_union := narrowed.(^Deep_Union_Expression); !is_union {
						return narrowed
					}
					append(&matching_exprs, narrowed)
				}

			case:
				if range_val, ok := analyze_expression_range(o, expr); ok {
					r := range_val.(Variable_Range)
					if target_val >= r.min - EPSILON && target_val <= r.max + EPSILON {
						if (abs(target_val - r.min) < EPSILON && !r.includes_min) ||
						   (abs(target_val - r.max) < EPSILON && !r.includes_max) {
							continue
						}
						append(&matching_exprs, deep_clone_expression(o, expr))
					}
				} else {
					append(&matching_exprs, deep_clone_expression(o, expr))
				}
			}
		}

		if len(matching_exprs) == 1 {
			return matching_exprs[0]
		} else if len(matching_exprs) > 1 {
			return create_union_expression(o, matching_exprs, false)
		}

	case .Not_Equal:
		target_val := get_numeric_value(pred.value)
		filtered_exprs := make([dynamic]Deep_Expression, o.alloc)
		defer delete(filtered_exprs)

		for expr in union_expr.expressions {
			#partial switch e in expr {
			case ^Deep_Constant_Value:
				if abs(get_numeric_value(e.value) - target_val) >= EPSILON {
					append(&filtered_exprs, deep_clone_expression(o, expr))
				}

			case ^Deep_Union_Expression:
				narrowed := apply_predicate_to_union(o, e, pred, depth + 1)
				if narrowed != nil {
					append(&filtered_exprs, narrowed)
				}

			case:
				append(&filtered_exprs, deep_clone_expression(o, expr))
			}
		}

		if len(filtered_exprs) == 1 {
			return filtered_exprs[0]
		} else if len(filtered_exprs) > 1 {
			return create_union_expression(o, filtered_exprs, union_expr.is_exhaustive)
		}

	case .Greater, .Greater_Equal, .Less, .Less_Equal:
		target_val := get_numeric_value(pred.value)

		if range_val, ok := union_expr.value_range.(Variable_Range); ok {
			new_range := range_val

			#partial switch pred.type {
			case .Greater:
				if target_val >= new_range.min {
					new_range.min = target_val
					new_range.includes_min = false
				}
			case .Greater_Equal:
				if target_val > new_range.min {
					new_range.min = target_val
					new_range.includes_min = true
				}
			case .Less:
				if target_val <= new_range.max {
					new_range.max = target_val
					new_range.includes_max = false
				}
			case .Less_Equal:
				if target_val < new_range.max {
					new_range.max = target_val
					new_range.includes_max = true
				}
			}

			if new_range.min > new_range.max ||
			   (abs(new_range.min - new_range.max) < EPSILON &&
				(!new_range.includes_min || !new_range.includes_max)) {
				return nil
			}

			const_expr := new(Deep_Constant_Value, o.alloc)
			const_expr.kind = .Constant
			const_expr.value = new_range
			return cast(Deep_Expression)const_expr
		}
	}

	return deep_clone_expression(o, union_expr)
}

find_predicates_for_var :: proc(
	o: ^Optimizer,
	var_id: Variable_ID,
	ctx: ^Deep_Expression_Context,
) -> [dynamic]Predicate {
	result := make([dynamic]Predicate, o.alloc)
	if ctx == nil { return result }

	if constraints, exists := ctx.constraints[var_id]; exists {
		for pred in constraints {
			append(&result, pred)
		}
	}

	if trans_preds, exists := ctx.transformed_predicates[var_id]; exists {
		for pred in trans_preds {
			append(&result, pred)
		}
	}

	if ctx.parent != nil {
		parent_preds := find_predicates_for_var(o, var_id, ctx.parent)
		for pred in parent_preds {
			exists := false
			for existing in result {
				if predicates_equal(existing, pred) {
					exists = true
					break
				}
			}
			if !exists {
				append(&result, pred)
			}
		}
		delete(parent_preds)
	}

	return result
}

resolve_with_history :: proc(
	o: ^Optimizer,
	expr: Deep_Expression,
	current_var: Variable_ID,
	prev_value: Deep_Expression,
	visited: ^map[Variable_ID]bool = nil,
	depth: int = 0
) -> Deep_Expression {
	if expr == nil { return nil }

	MAX_DEPTH :: 50
	if depth > MAX_DEPTH {
		unknown := new(Deep_Constant_Value, o.alloc)
		unknown.kind = .Constant
		unknown.value = INFINITE_RANGE
		return cast(Deep_Expression)unknown
	}

	visited_map: map[Variable_ID]bool
	visited_ptr: ^map[Variable_ID]bool

	if visited == nil {
		visited_map = make(map[Variable_ID]bool, o.alloc)
		visited_ptr = &visited_map
	} else {
		visited_ptr = visited
	}

	defer if visited == nil {
		delete(visited_map)
	}

	process_binary :: proc(o: ^Optimizer, e: ^Deep_Binary_Expression, left, right: Deep_Expression, visited_ptr: ^map[Variable_ID]bool, depth: int) -> Deep_Expression {
		if left == nil || right == nil {
			return nil
		}

		left_const, left_is_const := left.(^Deep_Constant_Value)
		right_const, right_is_const := right.(^Deep_Constant_Value)

		if left_is_const && right_is_const {
			if range_result, ok := perform_range_arithmetic(e.op, left_const.value, right_const.value); ok {
				result := new(Deep_Constant_Value, o.alloc)
				result.kind = .Constant
				result.value = range_result
				return cast(Deep_Expression)result
			}

			left_num := get_numeric_value(left_const.value)
			right_num := get_numeric_value(right_const.value)

			result := new(Deep_Constant_Value, o.alloc)
			result.kind = .Constant

			#partial switch e.op {
			case .Add:
				result.value = left_num + right_num
			case .Sub:
				result.value = left_num - right_num
			case .Mul:
				result.value = left_num * right_num
			case .Div:
				if abs(right_num) > EPSILON {
					result.value = left_num / right_num
				} else {
					return nil
				}
			case:
				binary := new(Deep_Binary_Expression, o.alloc)
				binary.kind = .Binary
				binary.op = e.op
				binary.left = new_clone(left, o.alloc)
				binary.right = new_clone(right, o.alloc)
				return cast(Deep_Expression)binary
			}

			return cast(Deep_Expression)result
		}

		binary := new(Deep_Binary_Expression, o.alloc)
		binary.kind = .Binary
		binary.op = e.op
		binary.left = new_clone(left, o.alloc)
		binary.right = new_clone(right, o.alloc)
		return cast(Deep_Expression)binary
	}

	ctx := o.deep_analyzer.current_expression_context

	if current_var.name == "" && current_var.scope_id == 0 && current_var.decl_node_id == 0 {
		#partial switch e in expr {
		case ^Deep_Variable_Ref:
			if ctx != nil {
				preds := find_predicates_for_var(o, e.var_id, ctx)
				defer delete(preds)

				for pred in preds {
					if pred.type == .Equal {
						if val_expr := get_value_from_predicate(o, pred); val_expr != nil {
							return resolve_with_history(o, val_expr.(Deep_Expression), {}, nil, visited_ptr, depth + 1)
						}
					}
				}
			}

			if visited_ptr[e.var_id] {
				unknown := new(Deep_Constant_Value, o.alloc)
				unknown.kind = .Constant
				unknown.value = INFINITE_RANGE
				return cast(Deep_Expression)unknown
			}

			visited_ptr[e.var_id] = true
			defer delete_key(visited_ptr, e.var_id)

			value := get_current_value(o, e.var_id)
			if value != nil {
				return resolve_with_history(o, value, {}, nil, visited_ptr, depth + 1)
			}
			return deep_clone_expression(o, expr)

		case ^Deep_Binary_Expression:
			left := resolve_with_history(o, e.left^, {}, nil, visited_ptr, depth + 1)
			right := resolve_with_history(o, e.right^, {}, nil, visited_ptr, depth + 1)
			return process_binary(o, e, left, right, visited_ptr, depth)

		case ^Deep_Unary_Expression:
			operand := resolve_with_history(o, e.operand^, {}, nil, visited_ptr, depth + 1)
			if operand == nil {
				return nil
			}

			unary := new(Deep_Unary_Expression, o.alloc)
			unary.kind = .Unary
			unary.op = e.op
			unary.operand = new_clone(operand, o.alloc)
			return cast(Deep_Expression)unary

		case ^Deep_Union_Expression:
			if ctx != nil {
				vars := deep_extract_variable_ids(o, expr)
				defer delete(vars)

				for var_id in vars {
					preds := find_predicates_for_var(o, var_id, ctx)
					defer delete(preds)

					for pred in preds {
						narrowed := apply_predicate_to_union(o, e, pred, depth)
						if narrowed != nil {
							return resolve_with_history(o, narrowed, {}, nil, visited_ptr, depth + 1)
						}
					}
				}
			}

			union_expr := new(Deep_Union_Expression, o.alloc)
			union_expr.kind = .Union
			union_expr.is_exhaustive = e.is_exhaustive
			union_expr.expressions = make([dynamic]Deep_Expression, o.alloc)
			union_expr.min_value = e.min_value
			union_expr.max_value = e.max_value
			union_expr.value_range = e.value_range

			for sub_expr in e.expressions {
				resolved := resolve_with_history(o, sub_expr, {}, nil, visited_ptr, depth + 1)
				if resolved != nil {
					append(&union_expr.expressions, resolved)
				}
			}

			return cast(Deep_Expression)union_expr

		case ^Deep_Constant_Value:
			return deep_clone_expression(o, expr)

		case:
			return deep_clone_expression(o, expr)
		}
	}

	#partial switch e in expr {
	case ^Deep_Variable_Ref:
		if ctx != nil {
			preds := find_predicates_for_var(o, e.var_id, ctx)
			defer delete(preds)

			for pred in preds {
				if pred.type == .Equal {
					if val_expr := get_value_from_predicate(o, pred); val_expr != nil {
						return resolve_with_history(o, val_expr.(Deep_Expression), current_var, prev_value, visited_ptr, depth + 1)
					}
				}
			}
		}

		if e.var_id == current_var {
			if prev_value != nil {
				return resolve_with_history(o, prev_value, current_var, nil, visited_ptr, depth + 1)
			}

			if current_val := get_current_value(o, current_var); current_val != nil {
				return resolve_with_history(o, current_val, current_var, nil, visited_ptr, depth + 1)
			}

			unknown := new(Deep_Constant_Value, o.alloc)
			unknown.kind = .Constant
			unknown.value = INFINITE_RANGE
			return cast(Deep_Expression)unknown
		}

		if visited_ptr[e.var_id] {
			unknown := new(Deep_Constant_Value, o.alloc)
			unknown.kind = .Constant
			unknown.value = INFINITE_RANGE
			return cast(Deep_Expression)unknown
		}

		visited_ptr[e.var_id] = true
		defer delete_key(visited_ptr, e.var_id)

		if value := get_current_value(o, e.var_id); value != nil {
			return resolve_with_history(o, value, current_var, nil, visited_ptr, depth + 1)
		}

		return deep_clone_expression(o, expr)

	case ^Deep_Binary_Expression:
		left := resolve_with_history(o, e.left^, current_var, prev_value, visited_ptr, depth + 1)
		right := resolve_with_history(o, e.right^, current_var, prev_value, visited_ptr, depth + 1)
		return process_binary(o, e, left, right, visited_ptr, depth)

	case ^Deep_Unary_Expression:
		operand := resolve_with_history(o, e.operand^, current_var, prev_value, visited_ptr, depth + 1)
		if operand == nil {
			return nil
		}

		unary := new(Deep_Unary_Expression, o.alloc)
		unary.kind = .Unary
		unary.op = e.op
		unary.operand = new_clone(operand, o.alloc)
		return cast(Deep_Expression)unary

	case ^Deep_Union_Expression:
		if ctx != nil {
			vars := deep_extract_variable_ids(o, expr)
			defer delete(vars)

			for var_id in vars {
				preds := find_predicates_for_var(o, var_id, ctx)
				defer delete(preds)

				for pred in preds {
					narrowed := apply_predicate_to_union(o, e, pred, depth)
					if narrowed != nil {
						return resolve_with_history(o, narrowed, current_var, prev_value, visited_ptr, depth + 1)
					}
				}
			}
		}

		union_expr := new(Deep_Union_Expression, o.alloc)
		union_expr.kind = .Union
		union_expr.is_exhaustive = e.is_exhaustive
		union_expr.expressions = make([dynamic]Deep_Expression, o.alloc)
		union_expr.min_value = e.min_value
		union_expr.max_value = e.max_value
		union_expr.value_range = e.value_range

		for sub_expr in e.expressions {
			resolved := resolve_with_history(o, sub_expr, current_var, prev_value, visited_ptr, depth + 1)
			if resolved != nil {
				append(&union_expr.expressions, resolved)
			}
		}

		return cast(Deep_Expression)union_expr

	case ^Deep_Constant_Value:
		return deep_clone_expression(o, expr)

	case:
		return deep_clone_expression(o, expr)
	}
}

get_function_cache_key_with_args :: proc(o: ^Optimizer, func_sym: ^checker.Symbol, ctx: ^Deep_Expression_Context, args: []^ast.Argument) -> [2]uintptr {
	key: [2]uintptr
	key[0] = uintptr(func_sym)

	if ctx != nil {
		key[0] = key[0] ~ hash_context(o, ctx)
	}

	for arg in args {
		if arg.value != nil {
			key[1] = key[1] ~ uintptr(arg.value.id)
		}
	}

	return key
}

hash_context :: proc(o: ^Optimizer, ctx: ^Deep_Expression_Context) -> uintptr {
	if ctx == nil {
		return 0
	}

	hash: uintptr = 0

	for var_id, expr in ctx.variables {
		var_hash := uintptr(var_id.scope_id) ~ uintptr(var_id.decl_node_id)

		expr_hash := hash_expression(o, expr)

		hash = hash ~ (var_hash ~ expr_hash)
	}

	for var_id, preds in ctx.constraints {
		for pred in preds {
			pred_hash := hash_predicate(o, pred)
			hash = hash ~ uintptr(var_id.scope_id) ~ pred_hash
		}
	}

	if ctx.parent != nil {
		hash = hash ~ hash_context(o, ctx.parent)
	}

	return hash
}

hash_expression :: proc(o: ^Optimizer, expr: Deep_Expression) -> uintptr {
	if expr == nil {
		return 0
	}

	#partial switch e in expr {
	case ^Deep_Constant_Value:
		#partial switch val in e.value {
		case f64:
			return uintptr(transmute(u64)val & 0xFFFFFFFF)
		case i64:
			return uintptr(val)
		case bool:
			return val ? 1 : 0
		case string:
			hash: uintptr = 0
			for ch in val {
				hash = hash * 31 + uintptr(ch)
			}
			return hash
		case Variable_Range:
			return uintptr(transmute(u64)val.min & 0xFFFFFFFF) ~
				   uintptr(transmute(u64)val.max & 0xFFFFFFFF)
		}

	case ^Deep_Variable_Ref:
		return uintptr(e.var_id.scope_id) ~ uintptr(e.var_id.decl_node_id)

	case ^Deep_Binary_Expression:
		left_hash := hash_expression(o, e.left^)
		right_hash := hash_expression(o, e.right^)
		return left_hash ~ right_hash ~ uintptr(e.op)

	case ^Deep_Union_Expression:
		hash: uintptr = 0
		for sub_expr in e.expressions {
			hash = hash ~ hash_expression(o, sub_expr)
		}
		return hash ~ (e.is_exhaustive ? 1 : 0)
	}

	return 0
}

hash_predicate :: proc(o: ^Optimizer, pred: Predicate) -> uintptr {
	hash := uintptr(pred.type)

	#partial switch val in pred.value {
	case f64:
		hash = hash ~ uintptr(transmute(u64)val & 0xFFFFFFFF)
	case i64:
		hash = hash ~ uintptr(val)
	case bool:
		hash = hash ~ (val ? 1 : 0)
	case string:
		for ch in val {
			hash = hash * 31 + uintptr(ch)
		}
	case Variable_Range:
		hash = hash ~ uintptr(transmute(u64)val.min & 0xFFFFFFFF) ~
					  uintptr(transmute(u64)val.max & 0xFFFFFFFF)
	}

	return hash
}

bind_parameters_to_args_with_call_ctx :: proc(
	o: ^Optimizer,
	func_sym: ^checker.Symbol,
	args: []^ast.Argument,
	params_scope: ^checker.Scope,
	func_ctx: ^Deep_Expression_Context,
	call_ctx: ^Deep_Expression_Context,
) {
	#partial switch node in func_sym.decl_node.derived {
	case ^ast.Func_Stmt:
		if node.params == nil || len(args) == 0 {
			return
		}

		for i in 0..<min(len(node.params.list), len(args)) {
			param := node.params.list[i]
			arg := args[i]

			saved_ctx := o.deep_analyzer.current_expression_context
			o.deep_analyzer.current_expression_context = call_ctx

			arg_expr := deep_create_expression(o, arg.value)

			o.deep_analyzer.current_expression_context = saved_ctx

			if arg_expr == nil {
				continue
			}

			resolved_arg := resolve_with_history(o, arg_expr, {}, nil)

			var_id := Variable_ID{
				name = param.name,
				scope_id = params_scope.id,
				decl_node_id = param.id,
			}

			o.deep_analyzer.var_id_to_scope[var_id] = params_scope
			o.deep_analyzer.node_id_to_var_id[param.id] = var_id

			if resolved_arg != nil {
				push_value(o, var_id, resolved_arg)
				func_ctx.variables[var_id] = resolved_arg
			} else {
				push_value(o, var_id, arg_expr)
				func_ctx.variables[var_id] = arg_expr
			}

			func_ctx.name_to_var_id[param.name] = var_id

			deps := deep_analyze_expression_deps(o, resolved_arg, var_id)
			o.deep_analyzer.expression_deps[var_id] = deps

			for dep_id in deps {
				if _, exists := o.deep_analyzer.reverse_expression_deps[dep_id]; !exists {
					o.deep_analyzer.reverse_expression_deps[dep_id] = make([dynamic]Variable_ID, o.alloc)
				}
				append(&o.deep_analyzer.reverse_expression_deps[dep_id], var_id)
			}
		}
	}
}

ReturnInfo :: struct {
	expr:        Deep_Expression,
	return_stmt: ^ast.Return_Stmt,
}

collect_function_returns :: proc(o: ^Optimizer, func_sym: ^checker.Symbol, body: ^ast.Block_Stmt) -> [dynamic]ReturnInfo {
	results := make([dynamic]ReturnInfo, o.alloc)
	if body == nil { return results }
	collect_returns_in_block(o, body, &results)
	return results
}

collect_returns_in_block :: proc(o: ^Optimizer, block: ^ast.Block_Stmt, results: ^[dynamic]ReturnInfo) -> bool {
	if block == nil { return false }

	all_paths_return := true
	i := 0
	for i < len(block.stmts) {
		stmt := block.stmts[i]

		#partial switch s in stmt.derived {
		case ^ast.Return_Stmt:
			if s.result != nil {
				expr := deep_create_expression(o, s.result)
				if expr != nil {
					append(results, ReturnInfo{
						expr = expr,
						return_stmt = s,
					})
				}
			}

			return true

		case ^ast.If_Stmt:
			if_stmt := s

			then_returns := false
			if if_stmt.body != nil {
				then_returns = collect_returns_in_block(o, if_stmt.body, results)
			}

			else_returns := false
			if if_stmt.else_stmt != nil {
				#partial switch else_s in if_stmt.else_stmt.derived {
				case ^ast.Block_Stmt:
					else_returns = collect_returns_in_block(o, else_s, results)
				case ^ast.Return_Stmt:
					if else_s.result != nil {
						expr := deep_create_expression(o, else_s.result)
						if expr != nil {
							append(results, ReturnInfo{
								expr = expr,
								return_stmt = else_s,
							})
						}
					}
					else_returns = true
				case ^ast.If_Stmt:
					temp_block := ast.new(ast.Block_Stmt, else_s.pos, else_s.end, o.alloc)
					temp_block.stmts = []^ast.Stmt{cast(^ast.Stmt)if_stmt.else_stmt}
					else_returns = collect_returns_in_block(o, temp_block, results)
					free(temp_block, o.alloc)
				}
			}

			if then_returns && else_returns {
				if i+1 < len(block.stmts) {
					return true
				}
			} else {
				all_paths_return = false
			}

		case ^ast.For_Stmt:
			for_stmt := s

			always_executes := false
			if for_stmt.cond != nil {
				cond_result := evaluate_constant_expression(o, for_stmt.cond)
				if cond_result.is_constant && cond_result.type_kind == .Boolean {
					if bool_val, ok := cond_result.value.(bool); ok && bool_val {
						always_executes = true
					}
				}
			} else {
				always_executes = true
			}

			if always_executes && for_stmt.body != nil {
				body_returns := false
				for body_stmt in for_stmt.body.stmts {
					#partial switch bs in body_stmt.derived {
					case ^ast.Return_Stmt:
						if bs.result != nil {
							expr := deep_create_expression(o, bs.result)
							if expr != nil {
								append(results, ReturnInfo{
									expr = expr,
									return_stmt = bs,
								})
							}
						}
						body_returns = true
					case ^ast.If_Stmt:
						temp_block := ast.new(ast.Block_Stmt, bs.pos, bs.end, o.alloc)
						temp_block.stmts = []^ast.Stmt{body_stmt}
						if collect_returns_in_block(o, temp_block, results) {
							body_returns = true
						}
						free(temp_block, o.alloc)
					}
					if body_returns { break }
				}

				if body_returns {
					if i+1 < len(block.stmts) {
						return true
					}
				}
			}
			all_paths_return = false

		case ^ast.Block_Stmt:
			nested_returns := collect_returns_in_block(o, s, results)
			if nested_returns {
				if i+1 < len(block.stmts) {
					return true
				}
			} else {
				all_paths_return = false
			}

		case:
			all_paths_return = false
		}

		i += 1
	}

	return all_paths_return
}

deep_create_expression :: proc(o: ^Optimizer, expr: ^ast.Expr) -> Deep_Expression {
	if expr == nil { return nil }

	#partial switch e in expr.derived {
	case ^ast.Call_Expr:
		call := e
		if ident, is_ident := call.expr.derived.(^ast.Ident); is_ident {
			sym := find_symbol_in_scopes(o, ident.name, o.current_scope)
			if sym != nil && sym.type != nil && sym.type.kind == .Function {
				return get_function_return_values(o, sym, o.deep_analyzer.current_expression_context, call.args)
			}
		}
		return nil

	case ^ast.Binary_Expr:
		binary := e
		left_expr := deep_create_expression(o, binary.left)
		right_expr := deep_create_expression(o, binary.right)

		if left_expr != nil && right_expr != nil {
			binary_expr := new(Deep_Binary_Expression, o.alloc)
			binary_expr.kind = .Binary
			binary_expr.op = deep_token_kind_to_operation(binary.op.kind)
			binary_expr.left = new_clone(left_expr, o.alloc)
			binary_expr.right = new_clone(right_expr, o.alloc)
			return cast(Deep_Expression)binary_expr
		}

	case ^ast.Unary_Expr:
		unary := e
		operand_expr := deep_create_expression(o, unary.expr)

		if operand_expr != nil {
			unary_expr := new(Deep_Unary_Expression, o.alloc)
			unary_expr.kind = .Unary
			unary_expr.op = deep_token_kind_to_operation(unary.op.kind)
			unary_expr.operand = new_clone(operand_expr, o.alloc)

			return cast(Deep_Expression)unary_expr
		}

	case ^ast.Ident:
		ident := e

		if o.deep_analyzer.analyzing_function != nil {
			if params, exists := o.deep_analyzer.function_params[o.deep_analyzer.analyzing_function]; exists {
				for param_id in params {
					if scope, exists2 := o.deep_analyzer.var_id_to_scope[param_id]; exists2 {
						for sym in scope.symbols {
							if sym.name == ident.name {
								var_ref := new(Deep_Variable_Ref, o.alloc)
								var_ref.kind = .Variable
								var_ref.var_id = param_id
								return cast(Deep_Expression)var_ref
							}
						}
					}
				}
			}
		}

		var_id := get_variable_id_for_name(o, ident.name, cast(^ast.Node)ident)
		var_ref := new(Deep_Variable_Ref, o.alloc)
		var_ref.kind = .Variable
		var_ref.var_id = var_id

		return cast(Deep_Expression)var_ref

	case ^ast.Basic_Lit:
		lit := e
		const_result := evaluate_constant_expression(o, expr)

		if const_result.is_constant {
			const_expr := new(Deep_Constant_Value, o.alloc)
			const_expr.kind = .Constant
			const_expr.value = convert_constant_to_variable_value(const_result)

			return cast(Deep_Expression)const_expr
		}

	case ^ast.Paren_Expr:
		paren := e
		return deep_create_expression(o, paren.expr)

	case:
		return nil
	}

	return nil
}

deep_clone_expression :: proc(o: ^Optimizer, expr: Deep_Expression) -> Deep_Expression {
	if expr == nil { return nil }

	switch e in expr {
	case ^Deep_Binary_Expression:
		cloned := new(Deep_Binary_Expression, o.alloc)
		cloned^ = e^
		cloned.left = new_clone(deep_clone_expression(o, e.left^), o.alloc)
		cloned.right = new_clone(deep_clone_expression(o, e.right^), o.alloc)
		return cast(Deep_Expression)cloned

	case ^Deep_Unary_Expression:
		cloned := new(Deep_Unary_Expression, o.alloc)
		cloned^ = e^
		cloned.operand = new_clone(deep_clone_expression(o, e.operand^), o.alloc)
		return cast(Deep_Expression)cloned

	case ^Deep_Variable_Ref:
		cloned := new(Deep_Variable_Ref, o.alloc)
		cloned^ = e^
		return cast(Deep_Expression)cloned

	case ^Deep_Constant_Value:
		cloned := new(Deep_Constant_Value, o.alloc)
		cloned^ = e^
		return cast(Deep_Expression)cloned

	case ^Deep_Union_Expression:
		cloned := new(Deep_Union_Expression, o.alloc)
		cloned.kind = e.kind
		cloned.is_exhaustive = e.is_exhaustive
		cloned.min_value = e.min_value
		cloned.max_value = e.max_value
		cloned.value_range = e.value_range

		cloned.expressions = make([dynamic]Deep_Expression, len(e.expressions), o.alloc)
		for expr2, i in e.expressions {
			cloned.expressions[i] = deep_clone_expression(o, expr2)
		}
		return cast(Deep_Expression)cloned

	case ^Deep_Discrete_Set:
		cloned := new(Deep_Discrete_Set, o.alloc)
		cloned^ = e^
		cloned.values = make([dynamic]Variable_Value, len(e.values), o.alloc)
		copy(cloned.values[:], e.values[:])
		return cast(Deep_Expression)cloned

	case:
		return nil
	}

	return nil
}

deep_free_expression :: proc(o: ^Optimizer, expr: Deep_Expression) {
	if expr == nil { return }

	visited := make(map[rawptr]bool, o.alloc)
	defer delete(visited)

	free_recursive :: proc(o: ^Optimizer, expr: Deep_Expression, visited: ^map[rawptr]bool) {
		if expr == nil { return }

		expr_ptr: rawptr
		#partial switch e in expr {
		case ^Deep_Binary_Expression: expr_ptr = e
		case ^Deep_Unary_Expression: expr_ptr = e
		case ^Deep_Variable_Ref: expr_ptr = e
		case ^Deep_Constant_Value: expr_ptr = e
		case ^Deep_Union_Expression: expr_ptr = e
		case ^Deep_Discrete_Set: expr_ptr = e
		case: return
		}

		if visited[expr_ptr] { return }
		visited[expr_ptr] = true

		#partial switch e in expr {
		case ^Deep_Binary_Expression:
			if e.left != nil {
				free_recursive(o, e.left^, visited)
			}
			if e.right != nil {
				free_recursive(o, e.right^, visited)
			}
			free(e, o.alloc)

		case ^Deep_Unary_Expression:
			if e.operand != nil {
				free_recursive(o, e.operand^, visited)
			}
			free(e, o.alloc)

		case ^Deep_Variable_Ref:
			free(e, o.alloc)

		case ^Deep_Constant_Value:
			free(e, o.alloc)

		case ^Deep_Union_Expression:
			for sub_expr in e.expressions {
				free_recursive(o, sub_expr, visited)
			}
			delete(e.expressions)
			free(e, o.alloc)

		case ^Deep_Discrete_Set:
			delete(e.values)
			free(e, o.alloc)
		}
	}

	free_recursive(o, expr, &visited)
}

deep_expression_to_string :: proc(o: ^Optimizer, expr: Deep_Expression) -> string {
	if expr == nil { return "nil" }

	builder := strings.builder_make(o.alloc)
	defer strings.builder_destroy(&builder)

	build_expr :: proc(o: ^Optimizer, expr: Deep_Expression, builder: ^strings.Builder, visited: ^map[rawptr]bool) {
		if expr == nil {
			strings.write_string(builder, "nil")
			return
		}

		expr_ptr: rawptr
		switch e in expr {
		case ^Deep_Binary_Expression: expr_ptr = e
		case ^Deep_Unary_Expression: expr_ptr = e
		case ^Deep_Variable_Ref: expr_ptr = e
		case ^Deep_Constant_Value: expr_ptr = e
		case ^Deep_Union_Expression: expr_ptr = e
		case ^Deep_Discrete_Set: expr_ptr = e
		case:
			strings.write_string(builder, "<unknown>")
			return
		}

		if visited[expr_ptr] {
			strings.write_string(builder, "...")
			return
		}
		visited[expr_ptr] = true

		switch e in expr {
		case ^Deep_Binary_Expression:
			strings.write_byte(builder, '(')
			if e.left != nil {
				build_expr(o, e.left^, builder, visited)
			} else {
				strings.write_string(builder, "nil")
			}

			#partial switch e.op {
			case .Add: strings.write_string(builder, " + ")
			case .Sub: strings.write_string(builder, " - ")
			case .Mul: strings.write_string(builder, " * ")
			case .Div: strings.write_string(builder, " / ")
			case .Mod: strings.write_string(builder, " % ")
			case .And: strings.write_string(builder, " && ")
			case .Or: strings.write_string(builder, " || ")
			case: strings.write_string(builder, " ? ")
			}

			if e.right != nil {
				build_expr(o, e.right^, builder, visited)
			} else {
				strings.write_string(builder, "nil")
			}
			strings.write_byte(builder, ')')

		case ^Deep_Unary_Expression:
			#partial switch e.op {
			case .Add: strings.write_string(builder, "+")
			case .Sub: strings.write_string(builder, "-")
			case .Not: strings.write_string(builder, "!")
			case: strings.write_string(builder, "?")
			}
			if e.operand != nil {
				build_expr(o, e.operand^, builder, visited)
			} else {
				strings.write_string(builder, "nil")
			}

		case ^Deep_Variable_Ref:
			strings.write_string(builder, fmt.tprintf("%s@%d", e.var_id.name, e.var_id.scope_id))

		case ^Deep_Constant_Value:
			switch val in e.value {
			case f64:
				strings.write_string(builder, fmt.tprintf("%f", val))
			case i64:
				strings.write_string(builder, fmt.tprintf("%d", val))
			case bool:
				strings.write_string(builder, val ? "true" : "false")
			case string:
				strings.write_string(builder, fmt.tprintf("\"%s\"", val))
			case Variable_Range:
				strings.write_string(builder, fmt.tprintf("range(%f, %f)", val.min, val.max))
			case:
				strings.write_string(builder, "<unknown>")
			}

		case ^Deep_Union_Expression:
			strings.write_string(builder, "union{")
			for i in 0..<len(e.expressions) {
				if i > 0 {
					strings.write_string(builder, ", ")
				}
				build_expr(o, e.expressions[i], builder, visited)
			}
			strings.write_string(builder, "}")
			if e.min_value != nil && e.max_value != nil {
				strings.write_string(builder, fmt.tprintf(" [%v..%v]", e.min_value, e.max_value))
			}

		case ^Deep_Discrete_Set:
			strings.write_string(builder, "set{")
			for i in 0..<len(e.values) {
				if i > 0 {
					strings.write_string(builder, ", ")
				}
				switch val in e.values[i] {
				case f64:
					strings.write_string(builder, fmt.tprintf("%f", val))
				case i64:
					strings.write_string(builder, fmt.tprintf("%d", val))
				case bool:
					strings.write_string(builder, val ? "true" : "false")
				case string:
					strings.write_string(builder, fmt.tprintf("\"%s\"", val))
				case Variable_Range:
					strings.write_string(builder, fmt.tprintf("range(%f, %f)", val.min, val.max))
				}
			}
			strings.write_string(builder, "}")
			if e.is_exhaustive {
				strings.write_string(builder, " (exhaustive)")
			}
		}
	}

	visited := make(map[rawptr]bool, o.alloc)
	defer delete(visited)

	build_expr(o, expr, &builder, &visited)
	return strings.to_string(builder)
}

deep_analyze_expression_deps :: proc(o: ^Optimizer, expr: Deep_Expression, source_var_id: Variable_ID) -> [dynamic]Variable_ID {
	deps := make([dynamic]Variable_ID, o.alloc)

	if expr == nil { return deps }

	analyze_recursive :: proc(o: ^Optimizer, expr: Deep_Expression, deps: ^[dynamic]Variable_ID,
							 visited: ^map[rawptr]bool, source_var_id: Variable_ID) {
		if expr == nil { return }

		expr_ptr: rawptr
		switch e in expr {
		case ^Deep_Binary_Expression: expr_ptr = e
		case ^Deep_Unary_Expression: expr_ptr = e
		case ^Deep_Variable_Ref: expr_ptr = e
		case ^Deep_Constant_Value: expr_ptr = e
		case ^Deep_Union_Expression: expr_ptr = e
		case ^Deep_Discrete_Set: expr_ptr = e
		case: return
		}

		if visited[expr_ptr] { return }
		visited[expr_ptr] = true

		#partial switch e in expr {
		case ^Deep_Variable_Ref:
			if e.var_id.name != "" && !variable_id_eq(e.var_id, source_var_id) {
				found := false
				for dep in deps^ {
					if variable_id_eq(dep, e.var_id) {
						found = true
						break
					}
				}
				if !found {
					append(deps, e.var_id)
				}
			}

		case ^Deep_Binary_Expression:
			if e.left != nil {
				analyze_recursive(o, e.left^, deps, visited, source_var_id)
			}
			if e.right != nil {
				analyze_recursive(o, e.right^, deps, visited, source_var_id)
			}

		case ^Deep_Unary_Expression:
			if e.operand != nil {
				analyze_recursive(o, e.operand^, deps, visited, source_var_id)
			}

		case ^Deep_Union_Expression:
			for sub_expr in e.expressions {
				analyze_recursive(o, sub_expr, deps, visited, source_var_id)
			}
		}
	}

	visited := make(map[rawptr]bool, o.alloc)
	defer delete(visited)

	analyze_recursive(o, expr, &deps, &visited, source_var_id)
	return deps
}

deep_extract_variable_ids :: proc(o: ^Optimizer, expr: Deep_Expression) -> [dynamic]Variable_ID {
	vars := make([dynamic]Variable_ID, o.alloc)

	if expr == nil { return vars }

	extract_recursive :: proc(o: ^Optimizer, expr: Deep_Expression, vars: ^[dynamic]Variable_ID, visited: ^map[rawptr]bool) {
		if expr == nil { return }

		expr_ptr: rawptr
		switch e in expr {
		case ^Deep_Binary_Expression: expr_ptr = e
		case ^Deep_Unary_Expression: expr_ptr = e
		case ^Deep_Variable_Ref: expr_ptr = e
		case ^Deep_Constant_Value: expr_ptr = e
		case ^Deep_Union_Expression: expr_ptr = e
		case ^Deep_Discrete_Set: expr_ptr = e
		case: return
		}

		if visited[expr_ptr] { return }
		visited[expr_ptr] = true

		#partial switch e in expr {
		case ^Deep_Variable_Ref:
			found := false
			for v in vars^ {
				if variable_id_eq(v, e.var_id) {
					found = true
					break
				}
			}
			if !found {
				append(vars, e.var_id)
			}

		case ^Deep_Binary_Expression:
			if e.left != nil {
				extract_recursive(o, e.left^, vars, visited)
			}
			if e.right != nil {
				extract_recursive(o, e.right^, vars, visited)
			}

		case ^Deep_Unary_Expression:
			if e.operand != nil {
				extract_recursive(o, e.operand^, vars, visited)
			}

		case ^Deep_Union_Expression:
			for sub_expr in e.expressions {
				extract_recursive(o, sub_expr, vars, visited)
			}
		}
	}

	visited := make(map[rawptr]bool, o.alloc)
	defer delete(visited)

	extract_recursive(o, expr, &vars, &visited)
	return vars
}

deep_solve_expression_for_var_id :: proc(o: ^Optimizer, expr: Deep_Expression, target_var_id: Variable_ID) -> Deep_Expression {
	if expr == nil { return nil }

	vars := deep_extract_variable_ids(o, expr)
	defer delete(vars)

	contains_target := false
	for v in vars {
		if variable_id_eq(v, target_var_id) {
			contains_target = true
			break
		}
	}

	if !contains_target {
		return nil
	}

	#partial switch e in expr {
	case ^Deep_Binary_Expression:
		if e.op == .Add || e.op == .Sub || e.op == .Mul || e.op == .Div {
			left_vars := deep_extract_variable_ids(o, e.left^)
			right_vars := deep_extract_variable_ids(o, e.right^)
			defer {
				delete(left_vars)
				delete(right_vars)
			}

			left_has_target := false
			right_has_target := false

			for v in left_vars {
				if variable_id_eq(v, target_var_id) {
					left_has_target = true
					break
				}
			}

			for v in right_vars {
				if variable_id_eq(v, target_var_id) {
					right_has_target = true
					break
				}
			}

			if left_has_target && !right_has_target {
				return deep_solve_binary_left(o, expr, target_var_id)
			} else if !left_has_target && right_has_target {
				return deep_solve_binary_right(o, expr, target_var_id)
			}
		}

	case ^Deep_Variable_Ref:
		if variable_id_eq(e.var_id, target_var_id) {
			return deep_clone_expression(o, expr)
		}
	}

	return nil
}

deep_solve_binary_left :: proc(o: ^Optimizer, expr: Deep_Expression, target_var_id: Variable_ID) -> Deep_Expression {
	#partial switch e in expr {
	case ^Deep_Binary_Expression:
		inverse_op: Value_Operation

		#partial switch e.op {
		case .Add: inverse_op = .Sub
		case .Sub: inverse_op = .Add
		case .Mul: inverse_op = .Div
		case .Div: inverse_op = .Mul
		case: return nil
		}

		solved := new(Deep_Binary_Expression, o.alloc)
		solved.kind = .Binary
		solved.op = inverse_op
		solved.left = new_clone(deep_clone_expression(o, expr), o.alloc)
		solved.right = new_clone(deep_clone_expression(o, e.right^), o.alloc)

		return cast(Deep_Expression)solved
	}

	return nil
}

deep_solve_binary_right :: proc(o: ^Optimizer, expr: Deep_Expression, target_var_id: Variable_ID) -> Deep_Expression {
	#partial switch e in expr {
	case ^Deep_Binary_Expression:
		#partial switch e.op {
		case .Add:
			solved := new(Deep_Binary_Expression, o.alloc)
			solved.kind = .Binary
			solved.op = .Sub
			solved.left = new_clone(deep_clone_expression(o, expr), o.alloc)
			solved.right = new_clone(deep_clone_expression(o, e.left^), o.alloc)
			return cast(Deep_Expression)solved

		case .Sub:
			solved := new(Deep_Binary_Expression, o.alloc)
			solved.kind = .Binary
			solved.op = .Sub
			solved.left = new_clone(deep_clone_expression(o, e.left^), o.alloc)
			solved.right = new_clone(deep_clone_expression(o, expr), o.alloc)
			return cast(Deep_Expression)solved

		case .Mul:
			solved := new(Deep_Binary_Expression, o.alloc)
			solved.kind = .Binary
			solved.op = .Div
			solved.left = new_clone(deep_clone_expression(o, expr), o.alloc)
			solved.right = new_clone(deep_clone_expression(o, e.left^), o.alloc)
			return cast(Deep_Expression)solved

		case .Div:
			solved := new(Deep_Binary_Expression, o.alloc)
			solved.kind = .Binary
			solved.op = .Div
			solved.left = new_clone(deep_clone_expression(o, e.left^), o.alloc)
			solved.right = new_clone(deep_clone_expression(o, expr), o.alloc)
			return cast(Deep_Expression)solved
		}
	}

	return nil
}

deep_evaluate_constant_expression :: proc(o: ^Optimizer, expr: Deep_Expression) -> ^f64 {
	if expr == nil { return nil }

	#partial switch e in expr {
	case ^Deep_Constant_Value:
		#partial switch val in e.value {
		case f64:
			result := new(f64, o.alloc)
			result^ = val
			return result
		case i64:
			result := new(f64, o.alloc)
			result^ = f64(val)
			return result
		}
	case:
		return nil
	}
	return nil
}

deep_expression_contains_var_id :: proc(o: ^Optimizer, expr: Deep_Expression, var_id: Variable_ID) -> bool {
	if expr == nil { return false }

	#partial switch e in expr {
	case ^Deep_Variable_Ref:
		return variable_id_eq(e.var_id, var_id)
	case ^Deep_Binary_Expression:
		return deep_expression_contains_var_id(o, e.left^, var_id) ||
			   deep_expression_contains_var_id(o, e.right^, var_id)
	case ^Deep_Unary_Expression:
		return deep_expression_contains_var_id(o, e.operand^, var_id)
	case ^Deep_Union_Expression:
		for sub_expr in e.expressions {
			if deep_expression_contains_var_id(o, sub_expr, var_id) {
				return true
			}
		}
		return false
	case:
		return false
	}
}

deep_find_variable_in_contexts :: proc(o: ^Optimizer, ctx: ^Deep_Expression_Context, var_id: Variable_ID) -> Deep_Expression {
	current := ctx
	for current != nil {
		if expr, exists := current.variables[var_id]; exists {
			return expr
		}
		current = current.parent
	}
	return nil
}

find_expression_for_variable :: proc(o: ^Optimizer, var_id: Variable_ID) -> Deep_Expression {
	ctx := o.deep_analyzer.current_expression_context
	return deep_find_variable_in_contexts(o, ctx, var_id)
}

deep_get_all_constraints_for_var_id :: proc(o: ^Optimizer, ctx: ^Deep_Expression_Context, var_id: Variable_ID) -> [dynamic]Predicate {
	constraints := make([dynamic]Predicate, o.alloc)
	current := ctx

	for current != nil {
		if var_constraints, exists := current.constraints[var_id]; exists {
			for pred in var_constraints {
				append(&constraints, pred)
			}
		}
		current = current.parent
	}

	return constraints
}

deep_create_expression_context :: proc(o: ^Optimizer, scope: ^checker.Scope) -> ^Deep_Expression_Context {
	ctx := new(Deep_Expression_Context, o.alloc)
	ctx.scope = scope
	ctx.variables = make(map[Variable_ID]Deep_Expression, o.alloc)
	ctx.constraints = make(map[Variable_ID][dynamic]Predicate, o.alloc)
	ctx.transformed_predicates = make(map[Variable_ID][dynamic]Predicate, o.alloc)
	ctx.name_to_var_id = make(map[string]Variable_ID, o.alloc)

	if o.deep_analyzer.current_expression_context != nil {
		ctx.parent = o.deep_analyzer.current_expression_context
	}

	o.deep_analyzer.scope_to_context[scope] = ctx
	return ctx
}

deep_push_expression_context :: proc(o: ^Optimizer, scope: ^checker.Scope) {
	ctx := deep_create_expression_context(o, scope)
	append(&o.deep_analyzer.expression_contexts, o.deep_analyzer.current_expression_context)
	o.deep_analyzer.current_expression_context = ctx
}

deep_pop_expression_context :: proc(o: ^Optimizer) {
	if len(o.deep_analyzer.expression_contexts) > 0 {
		o.deep_analyzer.current_expression_context = pop(&o.deep_analyzer.expression_contexts)
	}
}

deep_apply_predicate_to_context :: proc(
	o: ^Optimizer,
	pred: Predicate,
	ctx: ^Deep_Expression_Context,
) {
	if ctx == nil { return }

	if ctx.is_or_context {
		new_states := make([dynamic]^Deep_Expression_Context, o.alloc)

		for state in ctx.possible_states {
			new_state := clone_context(o, state)
			deep_apply_predicate_to_single_context(o, pred, new_state)
			append(&new_states, new_state)
		}

		for state in ctx.possible_states {
			free_context(o, state)
		}
		delete(ctx.possible_states)
		ctx.possible_states = new_states
		return
	}

	deep_apply_predicate_to_single_context(o, pred, ctx)
}

deep_apply_predicate_to_single_context :: proc(
	o: ^Optimizer,
	pred: Predicate,
	ctx: ^Deep_Expression_Context,
) {
	if _, exists := ctx.constraints[pred.variable]; !exists {
		ctx.constraints[pred.variable] = make([dynamic]Predicate, o.alloc)
	}

	for existing in ctx.constraints[pred.variable] {
		if predicates_equal(existing, pred) {
			return
		}
	}

	append(&ctx.constraints[pred.variable], pred)
	deep_propagate_predicate_in_single_context(o, pred, ctx)
}

deep_propagate_predicate_in_single_context :: proc(
	o: ^Optimizer,
	pred: Predicate,
	ctx: ^Deep_Expression_Context,
) {
	visited := make(map[Variable_ID]bool, o.alloc)
	defer delete(visited)

	propagate_recursive :: proc(
		o: ^Optimizer,
		pred: Predicate,
		var_id: Variable_ID,
		ctx: ^Deep_Expression_Context,
		visited: ^map[Variable_ID]bool,
	) {
		if visited[var_id] { return }
		visited[var_id] = true

		expr := ctx.variables[var_id]
		if expr == nil {
			return
		}

		deps := deep_extract_variable_ids(o, expr)
		defer delete(deps)

		for dep_var_id in deps {
			if !visited[dep_var_id] {
				transformed := deep_transform_predicate_expression(o, pred, var_id, dep_var_id)
				if transformed != nil {
					if _, exists := ctx.transformed_predicates[dep_var_id]; !exists {
						ctx.transformed_predicates[dep_var_id] = make([dynamic]Predicate, o.alloc)
					}

					found := false
					for existing in ctx.transformed_predicates[dep_var_id] {
						if predicates_equal(existing, transformed^) {
							found = true
							break
						}
					}

					if !found {
						append(&ctx.transformed_predicates[dep_var_id], transformed^)
						propagate_recursive(o, transformed^, dep_var_id, ctx, visited)
					}

					free(transformed, o.alloc)
				}
			}
		}
	}

	propagate_recursive(o, pred, pred.variable, ctx, &visited)
}

deep_apply_expression_to_value_for_var_id :: proc(o: ^Optimizer, expr: Deep_Expression, value: f64, var_id: Variable_ID) -> ^f64 {
	if expr == nil { return nil }

	result := new(f64, o.alloc)

	#partial switch e in expr {
	case ^Deep_Binary_Expression:
		left_val: f64 = 0
		right_val: f64 = 0

		if deep_expression_contains_var_id(o, e.left^, var_id) {
			left_val = value
		} else if const_val := deep_evaluate_constant_expression(o, e.left^); const_val != nil {
			left_val = const_val^
			free(const_val, o.alloc)
		}

		if deep_expression_contains_var_id(o, e.right^, var_id) {
			right_val = value
		} else if const_val := deep_evaluate_constant_expression(o, e.right^); const_val != nil {
			right_val = const_val^
			free(const_val, o.alloc)
		}

		#partial switch e.op {
		case .Add: result^ = left_val + right_val
		case .Sub: result^ = left_val - right_val
		case .Mul: result^ = left_val * right_val
		case .Div:
			if abs(right_val) > EPSILON {
				result^ = left_val / right_val
			} else {
				free(result, o.alloc)
				return nil
			}
		case:
			free(result, o.alloc)
			return nil
		}
		return result

	case ^Deep_Variable_Ref:
		if variable_id_eq(e.var_id, var_id) {
			result^ = value
			return result
		} else {
			free(result, o.alloc)
			return nil
		}

	case:
		free(result, o.alloc)
		return nil
	}
}

deep_get_expression_multiplier_for_var_id :: proc(o: ^Optimizer, expr: Deep_Expression, var_id: Variable_ID) -> f64 {
	if expr == nil { return 1.0 }

	#partial switch e in expr {
	case ^Deep_Binary_Expression:
		if e.op == .Mul {
			if deep_expression_contains_var_id(o, e.left^, var_id) {
				if const_val := deep_evaluate_constant_expression(o, e.right^); const_val != nil {
					multiplier := const_val^
					free(const_val, o.alloc)
					return multiplier
				}
			} else if deep_expression_contains_var_id(o, e.right^, var_id) {
				if const_val := deep_evaluate_constant_expression(o, e.left^); const_val != nil {
					multiplier := const_val^
					free(const_val, o.alloc)
					return multiplier
				}
			}
		} else if e.op == .Div {
			if deep_expression_contains_var_id(o, e.left^, var_id) {
				if const_val := deep_evaluate_constant_expression(o, e.right^); const_val != nil {
					multiplier := 1.0 / const_val^
					free(const_val, o.alloc)
					return multiplier
				}
			}
		}
	}

	return 1.0
}

@(private="file")
_deep_visit_value_decl_expr :: proc(v: ^ast.Visitor, node: ^ast.Value_Decl) {
	o := cast(^Optimizer)v.user_data

	if node.name != "" && node.name != "_" && node.value != nil {
		var_id := get_variable_id_for_name(o, node.name, cast(^ast.Node)node)

		right_expr := deep_create_expression(o, node.value)

		if right_expr == nil {
			return
		}

		resolved_right := resolve_with_history(o, right_expr, {}, nil)

		if resolved_right != nil {
			push_value(o, var_id, resolved_right)

			o.deep_analyzer.current_expression_context.variables[var_id] = resolved_right
			o.deep_analyzer.current_expression_context.name_to_var_id[node.name] = var_id

			deps := deep_analyze_expression_deps(o, resolved_right, var_id)
			o.deep_analyzer.expression_deps[var_id] = deps

			for dep_id in deps {
				if _, exists := o.deep_analyzer.reverse_expression_deps[dep_id]; !exists {
					o.deep_analyzer.reverse_expression_deps[dep_id] = make([dynamic]Variable_ID, o.alloc)
				}
				append(&o.deep_analyzer.reverse_expression_deps[dep_id], var_id)
			}
		}
	}
}

@(private="file")
_deep_visit_assign_stmt_expr :: proc(v: ^ast.Visitor, node: ^ast.Assign_Stmt) {
	o := cast(^Optimizer)v.user_data

	if node.name != "" && node.name != "_" {
		var_id := get_variable_id_for_name(o, node.name, cast(^ast.Node)node)

		effective_expr := node.expr
		temp_expr: ^ast.Expr = nil

		if node.op.kind != .Eq {
			var_ident := ast.create_ident(node.name, node.pos, node.end, o.alloc)

			binary := ast.create_binary_expr(
				cast(^ast.Expr)var_ident,
				lexer.Token{kind = op_to_binary_op(node.op.kind)},
				node.expr,
				node.pos,
				node.end,
				o.alloc,
			)

			temp_expr = cast(^ast.Expr)binary
			effective_expr = temp_expr
		}

		right_expr := deep_create_expression(o, effective_expr)

		if right_expr == nil {
			if temp_expr != nil {
				free(temp_expr, o.alloc)
			}
			return
		}

		if temp_expr != nil {
			free(temp_expr, o.alloc)
		}

		resolved_right := resolve_with_history(o, right_expr, var_id, get_previous_value(o, var_id))
		if resolved_right == nil { return }

		push_value(o, var_id, resolved_right)

		ctx := o.deep_analyzer.current_expression_context

		if ctx.is_or_context {
			for state in ctx.possible_states {
				if old_expr, exists := state.variables[var_id]; exists {
					deep_free_expression(o, old_expr)
				}
				state.variables[var_id] = deep_clone_expression(o, resolved_right)
				state.name_to_var_id[node.name] = var_id

				if _, exists := state.constraints[var_id]; exists {
					delete_key(&state.constraints, var_id)
				}
			}
		} else {
			if old_expr, exists := ctx.variables[var_id]; exists {
				deep_free_expression(o, old_expr)
			}
			ctx.variables[var_id] = resolved_right
			ctx.name_to_var_id[node.name] = var_id
		}
	}
}

op_to_binary_op :: proc(op: lexer.Token_Kind) -> lexer.Token_Kind {
	#partial switch op {
	case .Add_Eq: return .Add
	case .Sub_Eq: return .Sub
	case .Mul_Eq: return .Mul
	case .Quo_Eq: return .Quo
	case .Mod_Eq: return .Mod
	case: return .Add
	}
}

push_history_scope :: proc(o: ^Optimizer, func_scope: ^checker.Scope) {
	history_copy := make(map[Variable_ID]Variable_History, o.alloc)

	for var_id, hist in o.deep_analyzer.variable_history {
		if var_scope, exists := o.deep_analyzer.var_id_to_scope[var_id]; exists {
			if !is_scope_descendant_of(o, var_scope, func_scope) {
				new_hist := Variable_History{
					var_id = var_id,
					values = make([dynamic]Deep_Expression, o.alloc),
					current_index = hist.current_index,
				}
				for val in hist.values {
					append(&new_hist.values, deep_clone_expression(o, val))
				}
				history_copy[var_id] = new_hist
			}
		}
	}

	append(&o.deep_analyzer.history_stack, history_copy)

	new_history := make(map[Variable_ID]Variable_History, o.alloc)

	for var_id, hist in history_copy {
		new_history[var_id] = hist
	}

	o.deep_analyzer.variable_history = new_history
	o.deep_analyzer.current_function_scope = func_scope
}

pop_history_scope :: proc(o: ^Optimizer) {
	if len(o.deep_analyzer.history_stack) > 0 {
		for _, hist in o.deep_analyzer.variable_history {
			for val in hist.values {
				deep_free_expression(o, val)
			}
			delete(hist.values)
		}
		clear(&o.deep_analyzer.variable_history)

		o.deep_analyzer.variable_history = pop(&o.deep_analyzer.history_stack)
		o.deep_analyzer.current_function_scope = nil
	}
}

get_current_value :: proc(o: ^Optimizer, var_id: Variable_ID) -> Deep_Expression {
	if history, exists := o.deep_analyzer.variable_history[var_id]; exists {
		if history.current_index >= 0 && history.current_index < len(history.values) {
			return history.values[history.current_index]
		}
	}

	current_scope := o.current_scope
	if current_scope == nil {
		return nil
	}

	var_scope, scope_exists := o.deep_analyzer.var_id_to_scope[var_id]
	if !scope_exists {
		return nil
	}

	for scope := current_scope; scope != nil; scope = scope.parent {
		for sym in scope.symbols {
			if sym.name == var_id.name {
				for other_var_id, other_scope in o.deep_analyzer.var_id_to_scope {
					if other_scope == scope && other_var_id.name == var_id.name {
						if other_history, exists := o.deep_analyzer.variable_history[other_var_id]; exists {
							if other_history.current_index >= 0 && other_history.current_index < len(other_history.values) {
								return other_history.values[other_history.current_index]
							}
						}
						break
					}
				}
			}
		}
	}

	return nil
}

push_value :: proc(o: ^Optimizer, var_id: Variable_ID, value: Deep_Expression) {
	history, exists := o.deep_analyzer.variable_history[var_id]
	if !exists {
		history = Variable_History{
			var_id = var_id,
			values = make([dynamic]Deep_Expression, o.alloc),
			current_index = -1,
		}
	}

	for i := history.current_index + 1; i < len(history.values); i += 1 {
		deep_free_expression(o, history.values[i])
	}

	new_values := make([dynamic]Deep_Expression, o.alloc)
	for i in 0..<history.current_index + 1 {
		if i < len(history.values) {
			append(&new_values, history.values[i])
		}
	}

	history.current_index += 1
	append(&new_values, deep_clone_expression(o, value))

	delete(history.values)

	history.values = new_values
	o.deep_analyzer.variable_history[var_id] = history
}

get_previous_value :: proc(o: ^Optimizer, var_id: Variable_ID) -> Deep_Expression {
	if history, exists := o.deep_analyzer.variable_history[var_id]; exists {
		prev_index := history.current_index - 1
		if prev_index >= 0 && prev_index < len(history.values) {
			return history.values[prev_index]
		}
	}
	return nil
}

@(private="file")
_deep_visit_if_stmt_expr :: proc(v: ^ast.Visitor, node: ^ast.If_Stmt) {
	o := cast(^Optimizer)v.user_data

	if o.deep_analyzer.visited_nodes[node.id] {
		return
	}
	o.deep_analyzer.visited_nodes[node.id] = true

	parent_context := o.deep_analyzer.current_expression_context

	condition_tree := extract_condition_tree(o, node.cond)

	if_context := clone_context(o, parent_context)
	apply_condition_to_context(o, condition_tree, if_context)

	if node.body != nil {
		if body_scope, exists := o.symbols.node_scopes[node.body.id]; exists {
			if_context.scope = body_scope
			o.deep_analyzer.scope_to_context[body_scope] = if_context
		}
	}

	else_context: ^Deep_Expression_Context
	if node.else_stmt != nil {
		else_context = clone_context(o, parent_context)
		inverted_tree := invert_condition_tree(o, condition_tree)
		apply_condition_to_context(o, inverted_tree, else_context)
		free_condition_tree(o, inverted_tree)

		if else_scope, exists := o.symbols.node_scopes[node.else_stmt.id]; exists {
			else_context.scope = else_scope
			o.deep_analyzer.scope_to_context[else_scope] = else_context
		}
	}

	o.deep_analyzer.if_else_contexts[node] = If_Else_Contexts{
		if_context = if_context,
		else_context = else_context,
		parent_context = parent_context,
		condition_tree = condition_tree,
	}

	analyze_if_reachability(o, node, condition_tree, parent_context)
}

analyze_if_reachability :: proc(
	o: ^Optimizer,
	if_stmt: ^ast.If_Stmt,
	condition: ^Condition_Node,
	ctx: ^Deep_Expression_Context,
) {
	function_name := find_enclosing_function_name(o, cast(^ast.Node)if_stmt)
	condition_str := ast.expr_to_string(if_stmt.cond, o.alloc)

	if is_condition_always_true(o, condition, ctx) {
		if if_stmt.else_stmt != nil {
			error.add_warning(
				o.ec,
				o.current_file,
				fmt.tprintf(
					"unreachable code: else block is unreachable because condition '%s' is always true in function '%s'",
					condition_str,
					function_name,
				),
				if_stmt,
			)
		}
		schedule_if_always_true(o, if_stmt)
		return
	}

	if is_condition_always_false(o, condition, ctx) {
		if if_stmt.body != nil {
			error.add_warning(
				o.ec,
				o.current_file,
				fmt.tprintf(
					"unreachable code: if body is unreachable because condition '%s' is always false in function '%s'",
					condition_str,
					function_name,
				),
				if_stmt,
			)
		}
		schedule_if_always_false(o, if_stmt)
		return
	}
}

is_condition_always_true :: proc(
	o: ^Optimizer,
	node: ^Condition_Node,
	ctx: ^Deep_Expression_Context,
) -> bool {
	if node == nil { return true }

	if ctx.is_or_context {
		for state in ctx.possible_states {
			if !is_condition_always_true_in_single_context(o, node, state) {
				return false
			}
		}
		return true
	}

	return is_condition_always_true_in_single_context(o, node, ctx)
}

is_condition_always_false :: proc(
	o: ^Optimizer,
	node: ^Condition_Node,
	ctx: ^Deep_Expression_Context,
) -> bool {
	if node == nil { return false }

	if ctx.is_or_context {
		for state in ctx.possible_states {
			if !is_condition_always_false_in_single_context(o, node, state) {
				return false
			}
		}
		return true
	}

	return is_condition_always_false_in_single_context(o, node, ctx)
}

is_condition_always_true_in_single_context :: proc(
	o: ^Optimizer,
	node: ^Condition_Node,
	ctx: ^Deep_Expression_Context,
) -> bool {
	switch node.type {
	case .And:
		return is_condition_always_true_in_single_context(o, node.left, ctx) &&
			   is_condition_always_true_in_single_context(o, node.right, ctx)

	case .Or:
		return is_condition_always_true_in_single_context(o, node.left, ctx) ||
			   is_condition_always_true_in_single_context(o, node.right, ctx)

	case .Not:
		return !is_condition_always_true_in_single_context(o, node.operand, ctx)

	case .Predicate:
		if pred, ok := node.predicate.?; ok {
			value_result := can_value_satisfy_predicate(o, ctx.variables[pred.variable], pred)
			constraint_result := check_constraints_for_predicate(o, ctx, pred)

			return combine_check_results_for_true(value_result, constraint_result)
		}
		return false
	}
	return false
}

is_condition_always_false_in_single_context :: proc(
	o: ^Optimizer,
	node: ^Condition_Node,
	ctx: ^Deep_Expression_Context,
) -> bool {
	switch node.type {
	case .And:
		return is_condition_always_false_in_single_context(o, node.left, ctx) ||
			   is_condition_always_false_in_single_context(o, node.right, ctx)

	case .Or:
		return is_condition_always_false_in_single_context(o, node.left, ctx) &&
			   is_condition_always_false_in_single_context(o, node.right, ctx)

	case .Not:
		return !is_condition_always_false_in_single_context(o, node.operand, ctx)

	case .Predicate:
		if pred, ok := node.predicate.?; ok {
			value_result := can_value_satisfy_predicate(o, ctx.variables[pred.variable], pred)
			constraint_result := check_constraints_for_predicate(o, ctx, pred)

			return combine_check_results_for_false(value_result, constraint_result)
		}
		return false
	}
	return false
}

check_constraints_for_predicate :: proc(
	o: ^Optimizer,
	ctx: ^Deep_Expression_Context,
	pred: Predicate,
) -> Check_Result {
	result := Check_Result.Possible

	if constraints, exists := ctx.constraints[pred.variable]; exists {
		for constraint in constraints {
			if predicates_conflict(constraint, pred) {
				return .Impossible
			}
			if predicate_implies(constraint, pred) {
				result = .Certain
			}
		}
	}

	return result
}

combine_check_results_for_true :: proc(value_result, constraint_result: Check_Result) -> bool {
	switch value_result {
	case .Certain:
		return true
	case .Impossible:
		return false
	case .Possible:
		switch constraint_result {
		case .Certain:
			return true
		case .Impossible:
			return false
		case .Possible:
			return false
		}
	}
	return false
}

combine_check_results_for_false :: proc(value_result, constraint_result: Check_Result) -> bool {
	switch value_result {
	case .Impossible:
		return true
	case .Certain:
		return false
	case .Possible:
		switch constraint_result {
		case .Impossible:
			return true
		case .Certain:
			return false
		case .Possible:
			return false
		}
	}
	return false
}

clone_context :: proc(o: ^Optimizer, ctx: ^Deep_Expression_Context) -> ^Deep_Expression_Context {
	if ctx == nil { return nil }

	clone := new(Deep_Expression_Context, o.alloc)
	clone.parent = ctx.parent
	clone.scope = ctx.scope
	clone.is_or_context = ctx.is_or_context

	clone.variables = make(map[Variable_ID]Deep_Expression, o.alloc)
	for k, v in ctx.variables {
		clone.variables[k] = deep_clone_expression(o, v)
	}

	clone.constraints = make(map[Variable_ID][dynamic]Predicate, o.alloc)
	for k, v in ctx.constraints {
		clone.constraints[k] = make([dynamic]Predicate, len(v), o.alloc)
		for pred in v {
			append(&clone.constraints[k], pred)
		}
	}

	clone.transformed_predicates = make(map[Variable_ID][dynamic]Predicate, o.alloc)
	for k, v in ctx.transformed_predicates {
		clone.transformed_predicates[k] = make([dynamic]Predicate, len(v), o.alloc)
		for pred in v {
			append(&clone.transformed_predicates[k], pred)
		}
	}

	clone.name_to_var_id = make(map[string]Variable_ID, o.alloc)
	for k, v in ctx.name_to_var_id {
		clone.name_to_var_id[k] = v
	}

	if ctx.is_or_context && len(ctx.possible_states) > 0 {
		clone.possible_states = make([dynamic]^Deep_Expression_Context, o.alloc)
		for state in ctx.possible_states {
			append(&clone.possible_states, clone_context(o, state))
		}
	}

	return clone
}

free_context :: proc(o: ^Optimizer, ctx: ^Deep_Expression_Context) {
	if ctx == nil { return }

	for _, expr in ctx.variables {
		deep_free_expression(o, expr)
	}

	delete(ctx.variables)
	delete(ctx.constraints)
	delete(ctx.transformed_predicates)
	delete(ctx.name_to_var_id)

	free(ctx, o.alloc)
}

merge_contexts_after_if :: proc(
	o: ^Optimizer,
	contexts: If_Else_Contexts,
	parent_ctx: ^Deep_Expression_Context,
) {
	if parent_ctx == nil {
		return
	}

	temp_ctx := clone_context(o, parent_ctx)

	if has_or_condition(contexts.condition_tree) {
		merge_or_contexts(o, contexts, temp_ctx)
	} else {
		merge_and_contexts(o, contexts, temp_ctx)
	}

	for var_id, expr in temp_ctx.variables {
		if old_expr, exists := parent_ctx.variables[var_id]; exists {
			if !deep_expressions_equal(o, old_expr, expr) {
				deep_free_expression(o, old_expr)
				parent_ctx.variables[var_id] = deep_clone_expression(o, expr)
			}
		} else {
			parent_ctx.variables[var_id] = deep_clone_expression(o, expr)
		}
	}

	for var_id, preds in temp_ctx.constraints {
		if _, exists := parent_ctx.constraints[var_id]; !exists {
			parent_ctx.constraints[var_id] = make([dynamic]Predicate, o.alloc)
		}
		clear(&parent_ctx.constraints[var_id])
		for pred in preds {
			append(&parent_ctx.constraints[var_id], pred)
		}
	}

	for var_id, preds in temp_ctx.transformed_predicates {
		if _, exists := parent_ctx.transformed_predicates[var_id]; !exists {
			parent_ctx.transformed_predicates[var_id] = make([dynamic]Predicate, o.alloc)
		}
		clear(&parent_ctx.transformed_predicates[var_id])
		for pred in preds {
			append(&parent_ctx.transformed_predicates[var_id], pred)
		}
	}

	for name, var_id in temp_ctx.name_to_var_id {
		parent_ctx.name_to_var_id[name] = var_id
	}

	free_context(o, temp_ctx)
}

has_or_condition :: proc(tree: ^Condition_Node) -> bool {
	if tree == nil { return false }
	if tree.type == .Or { return true }
	if tree.left != nil && has_or_condition(tree.left) { return true }
	if tree.right != nil && has_or_condition(tree.right) { return true }
	return false
}

merge_or_contexts :: proc(
	o: ^Optimizer,
	contexts: If_Else_Contexts,
	parent_ctx: ^Deep_Expression_Context,
) {
	if parent_ctx == nil { return }

	all_states := make([dynamic]^Deep_Expression_Context, o.alloc)
	defer delete(all_states)

	if contexts.if_context.is_or_context {
		for state in contexts.if_context.possible_states {
			append(&all_states, state)
		}
	} else {
		append(&all_states, contexts.if_context)
	}

	if contexts.else_context != nil {
		if contexts.else_context.is_or_context {
			for state in contexts.else_context.possible_states {
				append(&all_states, state)
			}
		} else {
			append(&all_states, contexts.else_context)
		}
	}

	possible_values := make(map[Variable_ID][dynamic]Deep_Expression, o.alloc)
	defer {
		for _, values in possible_values {
			delete(values)
		}
		delete(possible_values)
	}

	possible_constraints := make(map[Variable_ID][dynamic][dynamic]Predicate, o.alloc)
	defer {
		for _, constraints in possible_constraints {
			for preds in constraints {
				delete(preds)
			}
			delete(constraints)
		}
		delete(possible_constraints)
	}

	parent_vars := make(map[Variable_ID]bool, o.alloc)
	defer delete(parent_vars)
	for var_id in parent_ctx.variables {
		parent_vars[var_id] = true
	}

	for state in all_states {
		for var_id, expr in state.variables {
			if _, exists := possible_values[var_id]; !exists {
				possible_values[var_id] = make([dynamic]Deep_Expression, o.alloc)
				possible_constraints[var_id] = make([dynamic][dynamic]Predicate, o.alloc)
			}

			found := false
			for existing in possible_values[var_id] {
				if deep_expressions_equal(o, existing, expr) {
					found = true
					break
				}
			}
			if !found {
				append(&possible_values[var_id], expr)
			}

			constraints := deep_get_all_constraints_for_var_id(o, state, var_id)
			append(&possible_constraints[var_id], constraints)
		}
	}

	for var_id in parent_vars {
		values, has_values := possible_values[var_id]
		constraints_set, has_constraints := possible_constraints[var_id]

		if has_values {
			if len(values) == 1 {
				parent_ctx.variables[var_id] = deep_clone_expression(o, values[0])

				if has_constraints {
					common_constraints := find_common_constraints_across_states(o, constraints_set[:])
					if len(common_constraints) > 0 {
						if _, exists := parent_ctx.constraints[var_id]; !exists {
							parent_ctx.constraints[var_id] = make([dynamic]Predicate, o.alloc)
						}
						clear(&parent_ctx.constraints[var_id])
						for pred in common_constraints {
							append(&parent_ctx.constraints[var_id], pred)
						}
					}
				}
			} else {
				exprs := make([dynamic]Deep_Expression, o.alloc)
				for expr in values {
					append(&exprs, deep_clone_expression(o, expr))
				}
				parent_ctx.variables[var_id] = combine_return_expressions(o, exprs)
			}
		}
	}

	for var_id, values in possible_values {
		if parent_vars[var_id] { continue }

		constraints_set := possible_constraints[var_id]

		exists_in_all_states := true
		for state in all_states {
			if _, exists := state.variables[var_id]; !exists {
				exists_in_all_states = false
				break
			}
		}

		if exists_in_all_states {
			if len(values) == 1 {
				parent_ctx.variables[var_id] = deep_clone_expression(o, values[0])

				common_constraints := find_common_constraints_across_states(o, constraints_set[:])
				if len(common_constraints) > 0 {
					if _, exists := parent_ctx.constraints[var_id]; !exists {
						parent_ctx.constraints[var_id] = make([dynamic]Predicate, o.alloc)
					}
					clear(&parent_ctx.constraints[var_id])
					for pred in common_constraints {
						append(&parent_ctx.constraints[var_id], pred)
					}
				}
			} else {
				exprs := make([dynamic]Deep_Expression, o.alloc)
				for expr in values {
					append(&exprs, deep_clone_expression(o, expr))
				}
				parent_ctx.variables[var_id] = combine_return_expressions(o, exprs)
			}

			for state in all_states {
				for name, id in state.name_to_var_id {
					if variable_id_eq(id, var_id) {
						parent_ctx.name_to_var_id[name] = var_id
						break
					}
				}
			}
		}
	}
}

find_common_constraints_across_states :: proc(
	o: ^Optimizer,
	states_constraints: [][dynamic]Predicate,
) -> [dynamic]Predicate {
	common := make([dynamic]Predicate, o.alloc)

	if len(states_constraints) == 0 {
		return common
	}

	for pred in states_constraints[0] {
		is_common := true

		for i := 1; i < len(states_constraints); i += 1 {
			found := false
			for other_pred in states_constraints[i] {
				if predicates_equal(pred, other_pred) {
					found = true
					break
				}
			}
			if !found {
				is_common = false
				break
			}
		}

		if is_common {
			append(&common, pred)
		}
	}

	return common
}

merge_and_contexts :: proc(
	o: ^Optimizer,
	contexts: If_Else_Contexts,
	parent_ctx: ^Deep_Expression_Context,
) {
	if parent_ctx == nil { return }

	parent_vars := make(map[Variable_ID]bool, o.alloc)
	defer delete(parent_vars)

	for var_id in parent_ctx.variables {
		parent_vars[var_id] = true
	}

	for var_id in parent_vars {
		then_expr := contexts.if_context.variables[var_id]
		else_exists := contexts.else_context != nil

		then_constraints := deep_get_all_constraints_for_var_id(o, contexts.if_context, var_id)
		defer delete(then_constraints)

		else_expr: Deep_Expression
		else_constraints: [dynamic]Predicate

		if else_exists {
			else_expr = contexts.else_context.variables[var_id]
			else_constraints = deep_get_all_constraints_for_var_id(o, contexts.else_context, var_id)
			defer delete(else_constraints)
		}

		parent_expr := parent_ctx.variables[var_id]

		has_then := then_expr != nil
		has_else := else_exists && else_expr != nil

		if has_then && has_else {
			merged_vars, merged_constraints := merge_branch_values(o,
				then_expr, then_constraints,
				else_expr, else_constraints,
				parent_expr, var_id)

			if merged_vars != nil {
				if !has_conflict_with_value(o, merged_vars, merged_constraints[:], var_id) {
					deep_free_expression(o, parent_ctx.variables[var_id])
					parent_ctx.variables[var_id] = merged_vars

					if len(merged_constraints) > 0 {
						if _, exists := parent_ctx.constraints[var_id]; !exists {
							parent_ctx.constraints[var_id] = make([dynamic]Predicate, o.alloc)
						}
						clear(&parent_ctx.constraints[var_id])
						for pred in merged_constraints {
							append(&parent_ctx.constraints[var_id], pred)
						}
					}
				} else {
					deep_free_expression(o, merged_vars)
				}
			}
		} else if has_then && !has_else {
			exprs := make([dynamic]Deep_Expression, o.alloc)
			defer delete(exprs)

			append(&exprs, deep_clone_expression(o, then_expr))
			append(&exprs, deep_clone_expression(o, parent_expr))

			merged_vars := combine_return_expressions(o, exprs)

			deep_free_expression(o, parent_ctx.variables[var_id])
			parent_ctx.variables[var_id] = merged_vars

		} else if !has_then && has_else {
			exprs := make([dynamic]Deep_Expression, o.alloc)
			defer delete(exprs)

			append(&exprs, deep_clone_expression(o, else_expr))
			append(&exprs, deep_clone_expression(o, parent_expr))

			merged_vars := combine_return_expressions(o, exprs)

			deep_free_expression(o, parent_ctx.variables[var_id])
			parent_ctx.variables[var_id] = merged_vars
		}
	}

	for var_id, then_expr in contexts.if_context.variables {
		if parent_vars[var_id] { continue }

		else_exists := contexts.else_context != nil
		else_expr: Deep_Expression

		if else_exists {
			else_expr = contexts.else_context.variables[var_id]
		}

		has_then := then_expr != nil
		has_else := else_exists && else_expr != nil

		if has_then && has_else {
			then_constraints := deep_get_all_constraints_for_var_id(o, contexts.if_context, var_id)
			defer delete(then_constraints)

			else_constraints := deep_get_all_constraints_for_var_id(o, contexts.else_context, var_id)
			defer delete(else_constraints)

			merged_vars, merged_constraints := merge_branch_values(o,
				then_expr, then_constraints,
				else_expr, else_constraints,
				nil, var_id)

			if merged_vars != nil {
				parent_ctx.variables[var_id] = merged_vars

				if len(merged_constraints) > 0 {
					if _, exists := parent_ctx.constraints[var_id]; !exists {
						parent_ctx.constraints[var_id] = make([dynamic]Predicate, o.alloc)
					}
					clear(&parent_ctx.constraints[var_id])
					for pred in merged_constraints {
						append(&parent_ctx.constraints[var_id], pred)
					}
				}

				for name, id in contexts.if_context.name_to_var_id {
					if variable_id_eq(id, var_id) {
						parent_ctx.name_to_var_id[name] = var_id
						break
					}
				}
			}
		} else if has_then && !has_else {
			continue
		}
	}
}

has_conflict_with_value :: proc(
	o: ^Optimizer,
	value: Deep_Expression,
	constraints: []Predicate,
	var_id: Variable_ID,
) -> bool {
	if value == nil { return false }

	for constraint in constraints {
		temp_pred := Predicate{
			variable = var_id,
			type = .Equal,
		}

		#partial switch v in value {
		case ^Deep_Constant_Value:
			temp_pred.value = v.value
			if predicates_conflict(constraint, temp_pred) {
				return true
			}
		case ^Deep_Discrete_Set:
			all_conflict := true
			for val in v.values {
				temp_pred.value = val
				if !predicates_conflict(constraint, temp_pred) {
					all_conflict = false
					break
				}
			}
			if all_conflict {
				return true
			}
		}
	}

	return false
}

filter_conflicting_constraints :: proc(
	o: ^Optimizer,
	value: Deep_Expression,
	constraints: []Predicate,
	var_id: Variable_ID,
) -> [dynamic]Predicate {
	result := make([dynamic]Predicate, o.alloc)

	eq_constraints := make([dynamic]Predicate, o.alloc)
	neq_constraints := make([dynamic]Predicate, o.alloc)
	other_constraints := make([dynamic]Predicate, o.alloc)
	defer {
		delete(eq_constraints)
		delete(neq_constraints)
		delete(other_constraints)
	}

	for pred in constraints {
		#partial switch pred.type {
		case .Equal:
			append(&eq_constraints, pred)
		case .Not_Equal:
			append(&neq_constraints, pred)
		case:
			append(&other_constraints, pred)
		}
	}

	valid_eq := make([dynamic]Predicate, o.alloc)
	for eq in eq_constraints {
		conflict := false
		for neq in neq_constraints {
			if compare_values(eq.value, neq.value) == 0 {
				conflict = true
				break
			}
		}
		if !conflict {
			append(&valid_eq, eq)
		}
	}

	valid_neq := make([dynamic]Predicate, o.alloc)
	for neq in neq_constraints {
		conflict := false
		for eq in eq_constraints {
			if compare_values(neq.value, eq.value) == 0 {
				conflict = true
				break
			}
		}
		if !conflict {
			append(&valid_neq, neq)
		}
	}

	for pred in valid_eq {
		append(&result, pred)
	}
	for pred in valid_neq {
		append(&result, pred)
	}
	for pred in other_constraints {
		append(&result, pred)
	}

	return result
}

merge_branch_values :: proc(
	o: ^Optimizer,
	then_expr: Deep_Expression,
	then_constraints: [dynamic]Predicate,
	else_expr: Deep_Expression,
	else_constraints: [dynamic]Predicate,
	parent_expr: Deep_Expression,
	var_id: Variable_ID,
) -> (Deep_Expression, [dynamic]Predicate) {

	merged_constraints := make([dynamic]Predicate, o.alloc)

	all_constraints := make([dynamic]Predicate, o.alloc)
	defer delete(all_constraints)

	for pred in then_constraints {
		append(&all_constraints, pred)
	}
	for pred in else_constraints {
		append(&all_constraints, pred)
	}

	if len(all_constraints) > 0 {
		if common_pred := find_common_constraint(o, all_constraints[:]); common_pred != nil {
			append(&merged_constraints, common_pred^)
		} else {
			possible_values := make([dynamic]f64, o.alloc)
			defer delete(possible_values)

			if then_expr != nil {
				#partial switch e in then_expr {
				case ^Deep_Constant_Value:
					if val, ok := get_numeric_value_from_constant(e); ok {
						append(&possible_values, val)
					}
				case ^Deep_Discrete_Set:
					for v in e.values {
						if num_val, ok := get_numeric_value_from_var(v); ok {
							append(&possible_values, num_val)
						}
					}
				}
			}

			if else_expr != nil {
				#partial switch e in else_expr {
				case ^Deep_Constant_Value:
					if val, ok := get_numeric_value_from_constant(e); ok {
						append(&possible_values, val)
					}
				case ^Deep_Discrete_Set:
					for v in e.values {
						if num_val, ok := get_numeric_value_from_var(v); ok {
							append(&possible_values, num_val)
						}
					}
				}
			}

			if len(possible_values) > 0 {
				min_val := possible_values[0]
				max_val := possible_values[0]

				for val in possible_values {
					if val < min_val {
						min_val = val
					}
					if val > max_val {
						max_val = val
					}
				}

				range_pred := Predicate{
					variable = var_id,
					value = Variable_Range{
						min = min_val,
						max = max_val,
						includes_min = true,
						includes_max = true,
					},
					type = .In_Range,
				}
				append(&merged_constraints, range_pred)
			}
		}
	}

	merged_expr: Deep_Expression
	if then_expr != nil && else_expr != nil {
		if deep_expressions_equal(o, then_expr, else_expr) {
			merged_expr = deep_clone_expression(o, then_expr)
		} else {
			exprs := make([dynamic]Deep_Expression, o.alloc)
			defer delete(exprs)
			append(&exprs, deep_clone_expression(o, then_expr))
			append(&exprs, deep_clone_expression(o, else_expr))
			merged_expr = combine_return_expressions(o, exprs)
		}
	} else if then_expr != nil {
		merged_expr = deep_clone_expression(o, then_expr)
	} else if else_expr != nil {
		merged_expr = deep_clone_expression(o, else_expr)
	} else if parent_expr != nil {
		merged_expr = deep_clone_expression(o, parent_expr)
	}

	return merged_expr, merged_constraints
}

get_numeric_value_from_constant :: proc(const: ^Deep_Constant_Value) -> (f64, bool) {
	#partial switch val in const.value {
	case f64:
		return val, true
	case i64:
		return f64(val), true
	}
	return 0, false
}

get_numeric_value_from_var :: proc(val: Variable_Value) -> (f64, bool) {
	#partial switch v in val {
	case f64:
		return v, true
	case i64:
		return f64(v), true
	}
	return 0, false
}

find_common_constraint :: proc(o: ^Optimizer, constraints: []Predicate) -> ^Predicate {
	if len(constraints) == 0 {
		return nil
	}
	if len(constraints) == 1 {
		return new_clone(constraints[0], o.alloc)
	}

	first := constraints[0]
	all_same_type := true
	for pred in constraints[1:] {
		if pred.type != first.type {
			all_same_type = false
			break
		}
	}

	if all_same_type {
		#partial switch first.type {
		case .Equal:
			all_same_value := true
			for pred in constraints[1:] {
				if compare_values(first.value, pred.value) != 0 {
					all_same_value = false
					break
				}
			}
			if all_same_value {
				return new_clone(first, o.alloc)
			}

		case .Greater, .Greater_Equal, .Less, .Less_Equal:
			result := new_clone(first, o.alloc)
			for pred in constraints[1:] {
				if is_stricter_constraint(pred, result^) {
					result^ = pred
				}
			}
			return result

		case .In_Range:
			if range_val, ok := first.value.(Variable_Range); ok {
				merged_range := range_val
				for pred in constraints[1:] {
					if other_range, ok2 := pred.value.(Variable_Range); ok2 {
						if other_range.min < merged_range.min {
							merged_range.min = other_range.min
						}
						if other_range.max > merged_range.max {
							merged_range.max = other_range.max
						}
						merged_range.includes_min = merged_range.includes_min || other_range.includes_min
						merged_range.includes_max = merged_range.includes_max || other_range.includes_max
					}
				}

				result := new_clone(first, o.alloc)
				result.value = merged_range
				return result
			}
		}
	}

	return nil
}

is_stricter_constraint :: proc(a, b: Predicate) -> bool {
	if a.type != b.type {
		return false
	}

	a_val := get_numeric_value(a.value)
	b_val := get_numeric_value(b.value)

	#partial switch a.type {
	case .Greater:
		return a_val > b_val
	case .Greater_Equal:
		return a_val >= b_val
	case .Less:
		return a_val < b_val
	case .Less_Equal:
		return a_val <= b_val
	}

	return false
}

deep_enter_scope :: proc(o: ^Optimizer, scope: ^checker.Scope) {
	if scope == nil { return }

	if ctx, exists := o.deep_analyzer.scope_to_context[scope]; exists {
		append(&o.deep_analyzer.expression_contexts, o.deep_analyzer.current_expression_context)
		o.deep_analyzer.current_expression_context = ctx
	} else {
		deep_push_expression_context(o, scope)
	}
}

deep_exit_scope :: proc(o: ^Optimizer) {
	if len(o.deep_analyzer.expression_contexts) > 0 {
		deep_pop_expression_context(o)
	}
}

@(private="file")
_deep_before_visit_node_expr :: proc(v: ^ast.Visitor, node: ^ast.Node) -> bool {
	o := cast(^Optimizer)v.user_data

	#partial switch n in node.derived {
	case ^ast.Block_Stmt:
		if parent, exists := o.node_parent[node]; exists {
			#partial switch p in parent.derived {
			case ^ast.If_Stmt:
				if_stmt := p
				if contexts, exists2 := o.deep_analyzer.if_else_contexts[if_stmt]; exists2 {
					if if_stmt.body == node && contexts.if_context != nil {
						o.deep_analyzer.current_expression_context = contexts.if_context
					} else if if_stmt.else_stmt == node && contexts.else_context != nil {
						o.deep_analyzer.current_expression_context = contexts.else_context
					}
				}
			}
		}
	}

	if scope, exists := o.symbols.node_scopes[node.id]; exists {
		if scope != o.current_scope {
			o.current_scope = scope
			deep_enter_scope(o, scope)
		}
	}

	return true
}

@(private="file")
_deep_after_visit_node_expr :: proc(v: ^ast.Visitor, node: ^ast.Node) {
	o := cast(^Optimizer)v.user_data

	#partial switch n in node.derived {
	case ^ast.Func_Stmt:
		if len(o.deep_analyzer.expression_contexts) > 0 {
			deep_pop_expression_context(o)
		}
	case ^ast.If_Stmt:
		if contexts, exists := o.deep_analyzer.if_else_contexts[n]; exists {
			merge_contexts_after_if(o, contexts, contexts.parent_context)

			o.deep_analyzer.current_expression_context = contexts.parent_context

			o.deep_analyzer.if_else_contexts[n] = contexts
		}

	case ^ast.Block_Stmt:
		if scope, exists := o.symbols.node_scopes[node.id]; exists {
			if scope.parent != nil && scope.parent != o.current_scope {
				o.current_scope = scope.parent
				deep_exit_scope(o)
			}
		}

		if parent, exists := o.node_parent[node]; exists {
			#partial switch p in parent.derived {
			case ^ast.If_Stmt:
				if_stmt := p
				if contexts, exists2 := o.deep_analyzer.if_else_contexts[if_stmt]; exists2 {
					if if_stmt.body == node || if_stmt.else_stmt == node {
						o.deep_analyzer.current_expression_context = contexts.parent_context
					}
				}
			}
		}

	case:
		if scope, exists := o.symbols.node_scopes[node.id]; exists {
			if scope.parent != nil && scope.parent != o.current_scope {
				o.current_scope = scope.parent
				deep_exit_scope(o)
			}
		}
	}
}

schedule_if_always_true :: proc(o: ^Optimizer, if_stmt: ^ast.If_Stmt) {
	if if_stmt.body != nil {
		schedule_node_replacement(o, cast(^ast.Node)if_stmt, cast(^ast.Node)if_stmt.body,
			"if with always true condition", o.deep_analyzer.current_expression_context)
	} else if if_stmt.else_stmt != nil {
		schedule_node_removal(o, cast(^ast.Node)if_stmt,
			"if with always true condition and empty body", o.deep_analyzer.current_expression_context)
	} else {
		schedule_node_removal(o, cast(^ast.Node)if_stmt,
			"if with always true condition and no body", o.deep_analyzer.current_expression_context)
	}
}

schedule_if_always_false :: proc(o: ^Optimizer, if_stmt: ^ast.If_Stmt) {
	if if_stmt.else_stmt != nil {
		schedule_node_replacement(o, cast(^ast.Node)if_stmt, cast(^ast.Node)if_stmt.else_stmt,
			"if with always false condition", o.deep_analyzer.current_expression_context)
	} else {
		schedule_node_removal(o, cast(^ast.Node)if_stmt,
			"if with always false condition and no else", o.deep_analyzer.current_expression_context)
	}
}

predicate_implies :: proc(p1, p2: Predicate) -> bool {
	if !variable_id_eq(p1.variable, p2.variable) {
		return false
	}

	v1 := get_numeric_value(p1.value)
	v2 := get_numeric_value(p2.value)

	if compare_values(p1.value, p2.value) == -2 {
		return predicates_equal(p1, p2)
	}

	#partial switch p1.type {
	case .Greater:
		#partial switch p2.type {
		case .Greater:
			return v1 >= v2
		case .Greater_Equal:
			return v1 >= v2
		case .Equal:
			return v2 > v1
		case .Not_Equal:
			return v2 > v1
		case:
			return false
		}

	case .Greater_Equal:
		#partial switch p2.type {
		case .Greater:
			return v1 > v2
		case .Greater_Equal:
			return v1 >= v2
		case .Equal:
			return v2 >= v1
		case .Not_Equal:
			return v2 > v1 || v2 < v1
		case:
			return false
		}

	case .Less:
		#partial switch p2.type {
		case .Less:
			return v1 <= v2
		case .Less_Equal:
			return v1 <= v2
		case .Equal:
			return v2 < v1
		case .Not_Equal:
			return v2 < v1
		case:
			return false
		}

	case .Less_Equal:
		#partial switch p2.type {
		case .Less:
			return v1 < v2
		case .Less_Equal:
			return v1 <= v2
		case .Equal:
			return v2 <= v1
		case .Not_Equal:
			return v2 < v1 || v2 > v1
		case:
			return false
		}

	case .Equal:
		#partial switch p2.type {
		case .Equal:
			return compare_values(p1.value, p2.value) == 0
		case .Greater_Equal:
			return v1 >= v2
		case .Less_Equal:
			return v1 <= v2
		case .Greater:
			return v1 > v2
		case .Less:
			return v1 < v2
		case .Not_Equal:
			return compare_values(p1.value, p2.value) != 0
		case:
			return false
		}

	case .Not_Equal:
		#partial switch p2.type {
		case .Not_Equal:
			return compare_values(p1.value, p2.value) == 0
		case .Greater:
			return false
		case .Greater_Equal:
			return false
		case .Less:
			return false
		case .Less_Equal:
			return false
		case .Equal:
			return false
		case:
			return false
		}

	case .In_Range:
		if range_val1, ok1 := p1.value.(Variable_Range); ok1 {
			#partial switch p2.type {
			case .In_Range:
				if range_val2, ok2 := p2.value.(Variable_Range); ok2 {
					return is_range_within(range_val2, range_val1)
				}
			case .Equal:
				return is_value_in_range(v2, range_val1)
			case .Greater_Equal:
				return range_val1.min <= v2
			case .Less_Equal:
				return range_val1.max >= v2
			case .Not_Equal:
				return !is_value_in_range(v2, range_val1)
			case .Greater:
				return range_val1.min > v2
			case .Less:
				return range_val1.max < v2
			}
		}

	case .Not_In_Range:
		if range_val1, ok1 := p1.value.(Variable_Range); ok1 {
			#partial switch p2.type {
			case .Not_Equal:
				if is_value_in_range(v2, range_val1) {
					return true
				}
				return false
			case .Equal:
				return false
			case:
				return false
			}
		}
	}

	return false
}

is_range_within :: proc(inner, outer: Variable_Range) -> bool {
	lower_ok: bool
	if inner.min > outer.min {
		lower_ok = true
	} else if abs(inner.min - outer.min) < EPSILON {
		lower_ok = outer.includes_min || (!outer.includes_min && inner.min > outer.min)
	} else {
		lower_ok = false
	}

	if !lower_ok { return false }

	upper_ok: bool
	if inner.max < outer.max {
		upper_ok = true
	} else if abs(inner.max - outer.max) < EPSILON {
		upper_ok = outer.includes_max || (!outer.includes_max && inner.max < outer.max)
	} else {
		upper_ok = false
	}

	return upper_ok
}

predicates_conflict :: proc(p1, p2: Predicate) -> bool {
	if !variable_id_eq(p1.variable, p2.variable) {
		return false
	}

	v1 := get_numeric_value(p1.value)
	v2 := get_numeric_value(p2.value)

	#partial switch p1.type {
	case .Greater:
		#partial switch p2.type {
		case .Greater:	  return false
		case .Greater_Equal: return false
		case .Less:		  return v1 >= v2
		case .Less_Equal:	return v1 >= v2
		case .Equal:		 return v1 >= v2
		case .Not_Equal:	 return false
		case:
			return false
		}

	case .Greater_Equal:
		#partial switch p2.type {
		case .Greater:	   return false
		case .Greater_Equal: return false
		case .Less:		  return v1 >= v2
		case .Less_Equal:	return v1 > v2
		case .Equal:		 return v1 > v2
		case .Not_Equal:	 return false
		case:
			return false
		}

	case .Less:
		#partial switch p2.type {
		case .Greater:	   return v1 <= v2
		case .Greater_Equal: return v1 <= v2
		case .Less:		  return false
		case .Less_Equal:	return false
		case .Equal:		 return v1 <= v2
		case .Not_Equal:	 return false
		case:
			return false
		}

	case .Less_Equal:
		#partial switch p2.type {
		case .Greater:	   return v1 < v2
		case .Greater_Equal: return v1 < v2
		case .Less:		  return false
		case .Less_Equal:	return false
		case .Equal:		 return v1 < v2
		case .Not_Equal:	 return false
		case:
			return false
		}

	case .Equal:
		#partial switch p2.type {
		case .Greater:	   return v1 <= v2
		case .Greater_Equal: return v1 < v2
		case .Less:		  return v1 >= v2
		case .Less_Equal:	return v1 > v2
		case .Equal:		 return compare_values(p1.value, p2.value) != 0
		case .Not_Equal:	 return compare_values(p1.value, p2.value) == 0
		case:
			return false
		}

	case .Not_Equal:
		#partial switch p2.type {
		case .Greater:	   return false
		case .Greater_Equal: return false
		case .Less:		  return false
		case .Less_Equal:	return false
		case .Equal:		 return compare_values(p1.value, p2.value) == 0
		case .Not_Equal:	 return false
		case:
			return false
		}

	case .In_Range:
		range1, ok1 := p1.value.(Variable_Range)
		if !ok1 { return false }

		#partial switch p2.type {
		case .In_Range:
			range2, ok2 := p2.value.(Variable_Range)
			if !ok2 { return false }
			return ranges_completely_exclude(range1, range2)

		case .Not_In_Range:
			range2, ok2 := p2.value.(Variable_Range)
			if !ok2 { return false }
			return ranges_equal(range1, range2)

		case .Equal:
			val := get_numeric_value(p2.value)
			return !is_value_in_range(val, range1)

		case .Not_Equal:
			val := get_numeric_value(p2.value)
			return false

		case .Greater:
			return range1.max <= v2
		case .Greater_Equal:
			return range1.max < v2
		case .Less:
			return range1.min >= v2
		case .Less_Equal:
			return range1.min > v2
		}

	case .Not_In_Range:
		range1, ok1 := p1.value.(Variable_Range)
		if !ok1 { return false }

		#partial switch p2.type {
		case .In_Range:
			range2, ok2 := p2.value.(Variable_Range)
			if !ok2 { return false }
			return ranges_equal(range1, range2)

		case .Not_In_Range:
			range2, ok2 := p2.value.(Variable_Range)
			if !ok2 { return false }
			return false

		case .Equal:
			val := get_numeric_value(p2.value)
			return is_value_in_range(val, range1)

		case .Not_Equal:
			val := get_numeric_value(p2.value)
			return false

		case .Greater:
			return false
		case .Greater_Equal:
			return false
		case .Less:
			return false
		case .Less_Equal:
			return false
		}
	}

	return false
}

ranges_equal :: proc(r1, r2: Variable_Range) -> bool {
	return abs(r1.min - r2.min) < EPSILON &&
		   abs(r1.max - r2.max) < EPSILON &&
		   r1.includes_min == r2.includes_min &&
		   r1.includes_max == r2.includes_max
}

ranges_completely_exclude :: proc(r1, r2: Variable_Range) -> bool {
	if r1.max < r2.min {
		return true
	}
	if r2.max < r1.min {
		return true
	}

	if abs(r1.max - r2.min) < EPSILON {
		return !r1.includes_max && !r2.includes_min
	}
	if abs(r2.max - r1.min) < EPSILON {
		return !r2.includes_max && !r1.includes_min
	}

	return false
}

compare_values :: proc(v1, v2: Variable_Value) -> int {
	type_match := false

	#partial switch val1 in v1 {
	case f64:
		#partial switch val2 in v2 {
		case f64:
			type_match = true
			if abs(val1 - val2) < EPSILON { return 0 }
			if val1 < val2 { return -1 }
			return 1
		case i64:
			type_match = true
			f64_val2 := f64(val2)
			if abs(val1 - f64_val2) < EPSILON { return 0 }
			if val1 < f64_val2 { return -1 }
			return 1
		}

	case i64:
		#partial switch val2 in v2 {
		case f64:
			type_match = true
			f64_val1 := f64(val1)
			if abs(f64_val1 - val2) < EPSILON { return 0 }
			if f64_val1 < val2 { return -1 }
			return 1
		case i64:
			type_match = true
			if val1 == val2 { return 0 }
			if val1 < val2 { return -1 }
			return 1
		}

	case bool:
		if val2, ok := v2.(bool); ok {
			type_match = true
			if val1 == val2 { return 0 }
			if !val1 && val2 { return -1 }
			return 1
		}

	case string:
		if val2, ok := v2.(string); ok {
			type_match = true
			if val1 == val2 { return 0 }
			if val1 < val2 { return -1 }
			return 1
		}
	}

	return -2
}

get_numeric_value :: proc(val: Variable_Value) -> f64 {
	#partial switch v in val {
	case f64:
		return v
	case i64:
		return f64(v)
	case Variable_Range:
		return (v.min + v.max) / 2.0
	case:
		return 0.0
	}
}

predicate_value_to_constant :: proc(val: Variable_Value) -> Constant_Result {
	result: Constant_Result
	result.is_constant = false

	#partial switch v in val {
	case f64:
		result.value = v
		result.type_kind = .Number
		result.is_constant = true
	case i64:
		result.value = v
		result.type_kind = .Number
		result.is_constant = true
	case bool:
		result.value = v
		result.type_kind = .Boolean
		result.is_constant = true
	case string:
		result.value = v
		result.type_kind = .Text
		result.is_constant = true
	}

	return result
}

find_constant_in_context :: proc(o: ^Optimizer, var_id: Variable_ID, ctx: ^Deep_Expression_Context) -> (Constant_Result, bool) {
	if ctx == nil { return {}, false }

	if ctx.is_or_context {
		for state in ctx.possible_states {
			if const_result, found := find_constant_in_single_context(o, var_id, state); found {
				return const_result, true
			}
		}
		return {}, false
	}

	return find_constant_in_single_context(o, var_id, ctx)
}

find_constant_in_single_context :: proc(o: ^Optimizer, var_id: Variable_ID, ctx: ^Deep_Expression_Context) -> (Constant_Result, bool) {
	if constraints, exists := ctx.constraints[var_id]; exists {
		for pred in constraints {
			if pred.type == .Equal {
				if const_result := predicate_value_to_constant(pred.value); const_result.is_constant {
					return const_result, true
				}
			}
		}
	}

	if trans_preds, exists := ctx.transformed_predicates[var_id]; exists {
		for pred in trans_preds {
			if pred.type == .Equal {
				if const_result := predicate_value_to_constant(pred.value); const_result.is_constant {
					return const_result, true
				}
			}
		}
	}

	return {}, false
}

schedule_constant_substitutions :: proc(o: ^Optimizer, expr: ^ast.Expr, ctx: ^Deep_Expression_Context) {
	if expr == nil || ctx == nil { return }

	#partial switch e in expr.derived {
	case ^ast.Ident:
		ident := e
		var_id := get_variable_id_for_name(o, ident.name, cast(^ast.Node)ident)

		if const_result, found := find_constant_in_context(o, var_id, ctx); found {
			new_lit := create_constant_literal(o, const_result, ident.pos, ident.end)
			if new_lit != nil {
				schedule_node_replacement(o, cast(^ast.Node)expr, cast(^ast.Node)new_lit,
					fmt.tprintf("substituted variable '%s' with constant",
						ident.name), ctx)
			}
		}

	case ^ast.Binary_Expr:
		binary := e
		schedule_constant_substitutions(o, binary.left, ctx)
		schedule_constant_substitutions(o, binary.right, ctx)

	case ^ast.Unary_Expr:
		unary := e
		schedule_constant_substitutions(o, unary.expr, ctx)

	case ^ast.Paren_Expr:
		paren := e
		schedule_constant_substitutions(o, paren.expr, ctx)

	case ^ast.Call_Expr:
		call := e
		schedule_constant_substitutions(o, call.expr, ctx)
		for arg in call.args {
			schedule_constant_substitutions(o, arg.value, ctx)
		}

	case ^ast.Member_Access_Expr:
		member := e
		schedule_constant_substitutions(o, member.expr, ctx)

	case ^ast.Index_Expr:
		index := e
		schedule_constant_substitutions(o, index.expr, ctx)
		schedule_constant_substitutions(o, index.index, ctx)
	}
}

process_stmt_with_constants :: proc(o: ^Optimizer, stmt: ^ast.Stmt, ctx: ^Deep_Expression_Context) {
	if stmt == nil || ctx == nil { return }

	#partial switch s in stmt.derived {
	case ^ast.Value_Decl:
		decl := s
		if decl.value != nil {
			schedule_constant_substitutions(o, decl.value, ctx)
		}

	case ^ast.Assign_Stmt:
		assign := s
		if assign.expr != nil {
			schedule_constant_substitutions(o, assign.expr, ctx)
		}

	case ^ast.Expr_Stmt:
		expr_stmt := s
		if expr_stmt.expr != nil {
			schedule_constant_substitutions(o, expr_stmt.expr, ctx)
		}

	case ^ast.If_Stmt:
		if_stmt := s
		if if_stmt.cond != nil {
			schedule_constant_substitutions(o, if_stmt.cond, ctx)
		}

	case ^ast.For_Stmt:
		for_stmt := s
		if for_stmt.cond != nil {
			schedule_constant_substitutions(o, for_stmt.cond, ctx)
		}
		if for_stmt.second_cond != nil {
			schedule_constant_substitutions(o, for_stmt.second_cond, ctx)
		}
		if for_stmt.init != nil {
			for ident in for_stmt.init {
				schedule_constant_substitutions(o, cast(^ast.Expr)ident, ctx)
			}
		}

	case ^ast.Return_Stmt:
		ret := s
		if ret.result != nil {
			schedule_constant_substitutions(o, ret.result, ctx)
		}

	case ^ast.Defer_Stmt:
		defer_stmt := s
		process_stmt_with_constants(o, defer_stmt.stmt, ctx)
	}
}

@(private="file")
_deep_visit_block_stmt :: proc(v: ^ast.Visitor, node: ^ast.Block_Stmt) {
	o := cast(^Optimizer)v.user_data

	parent_context := o.deep_analyzer.current_expression_context

	if parent, exists := o.node_parent[node]; exists {
		#partial switch p in parent.derived {
		case ^ast.If_Stmt:
			if contexts, ok := o.deep_analyzer.if_else_contexts[p]; ok {
				if p.body == node && contexts.if_context != nil {
					o.deep_analyzer.current_expression_context = contexts.if_context
				} else if p.else_stmt == node && contexts.else_context != nil {
					o.deep_analyzer.current_expression_context = contexts.else_context
				}
			}
		}
	}

	for stmt in node.stmts {
		process_stmt_with_constants(o, stmt, o.deep_analyzer.current_expression_context)
	}

	o.deep_analyzer.current_expression_context = parent_context
}

@(private="file")
_deep_visit_expr_stmt_expr :: proc(v: ^ast.Visitor, node: ^ast.Expr_Stmt) {
	o := cast(^Optimizer)v.user_data
	if node.expr != nil {
		deep_create_expression(o, node.expr)
	}
}

@(private="file")
_deep_visit_func_stmt_expr :: proc(v: ^ast.Visitor, node: ^ast.Func_Stmt) {
	o := cast(^Optimizer)v.user_data

	parent_ctx := o.deep_analyzer.current_expression_context

	if scope, exists := o.symbols.node_scopes[node.id]; exists {
		param_ctx := deep_create_expression_context(o, scope)
		param_ctx.parent = parent_ctx

		o.deep_analyzer.current_expression_context = param_ctx

		if node.params != nil {
			for param in node.params.list {
				var_id := create_variable_id(o, param.name, cast(^ast.Node)param)
				var_ref := new(Deep_Variable_Ref, o.alloc)
				var_ref.kind = .Variable
				var_ref.var_id = var_id

				param_ctx.variables[var_id] = var_ref
				param_ctx.name_to_var_id[param.name] = var_id
			}
		}
	}
}

@(private="file")
_deep_visit_for_stmt_expr :: proc(v: ^ast.Visitor, node: ^ast.For_Stmt) {
	o := cast(^Optimizer)v.user_data

	if node.init != nil {
		for init in node.init {
			if ident, is_ident := init.derived.(^ast.Ident); is_ident {
				var_id := create_variable_id(o, ident.name, cast(^ast.Node)ident)
				var_ref := new(Deep_Variable_Ref, o.alloc)
				var_ref.kind = .Variable
				var_ref.var_id = var_id

				o.deep_analyzer.current_expression_context.variables[var_id] = var_ref
				o.deep_analyzer.current_expression_context.name_to_var_id[ident.name] = var_id
			}
		}
	}

	if node.cond != nil {
		condition_tree := extract_condition_tree(o, node.cond)
		defer free_condition_tree(o, condition_tree)

		apply_condition_to_context(o, condition_tree, o.deep_analyzer.current_expression_context)
	}
}

@(private="file")
_deep_visit_return_stmt_expr :: proc(v: ^ast.Visitor, node: ^ast.Return_Stmt) {
	o := cast(^Optimizer)v.user_data

	if node.result != nil {
		deep_create_expression(o, node.result)
	}
}

deep_analyzer_init :: proc(o: ^Optimizer) {
	o.deep_analyzer = new(Deep_Analyzer, o.alloc)
	o.deep_analyzer.walker = new(ast.Walker, o.alloc)

	o.deep_analyzer.expression_cache = make(map[Variable_ID]Variable_Value, o.alloc)
	o.deep_analyzer.variable_expressions = make(map[Variable_ID]Deep_Expression, o.alloc)
	o.deep_analyzer.expression_deps = make(map[Variable_ID][dynamic]Variable_ID, o.alloc)
	o.deep_analyzer.reverse_expression_deps = make(map[Variable_ID][dynamic]Variable_ID, o.alloc)
	o.deep_analyzer.expression_contexts = make([dynamic]^Deep_Expression_Context, o.alloc)
	o.deep_analyzer.scope_to_context = make(map[^checker.Scope]^Deep_Expression_Context, o.alloc)
	o.deep_analyzer.current_expression_context = nil
	o.deep_analyzer.var_id_to_scope = make(map[Variable_ID]^checker.Scope, o.alloc)
	o.deep_analyzer.node_id_to_var_id = make(map[int]Variable_ID, o.alloc)
	o.deep_analyzer.if_else_contexts = make(map[^ast.If_Stmt]If_Else_Contexts, o.alloc)
	o.deep_analyzer.function_expressions = make(map[^checker.Symbol]Deep_Expression, o.alloc)
	o.deep_analyzer.function_params = make(map[^checker.Symbol][dynamic]Variable_ID, o.alloc)
	o.deep_analyzer.function_calls = make(map[^ast.Call_Expr]^checker.Symbol, o.alloc)
	o.deep_analyzer.call_arguments = make(map[^ast.Call_Expr][dynamic]Deep_Expression, o.alloc)
	o.deep_analyzer.analyzing_function = nil
	o.deep_analyzer.function_return_cache = make(map[[2]uintptr]Deep_Expression, o.alloc)
	o.deep_analyzer.analyzed_functions = make(map[^checker.Symbol]bool, o.alloc)
	o.deep_analyzer.variable_history = make(map[Variable_ID]Variable_History, o.alloc)
	o.deep_analyzer.history_stack = make([dynamic]map[Variable_ID]Variable_History, o.alloc)
	o.deep_analyzer.current_function_scope = nil
	o.deep_analyzer.visited_nodes = make(map[int]bool, o.alloc)

	o.deep_analyzer.walker_vtable = ast.Visitor_VTable{
		visit_func_stmt = _deep_visit_func_stmt_expr,
		visit_expr_stmt = _deep_visit_expr_stmt_expr,
		visit_assign_stmt = _deep_visit_assign_stmt_expr,
		visit_if_stmt = _deep_visit_if_stmt_expr,
		visit_return_stmt = _deep_visit_return_stmt_expr,
		visit_for_stmt = _deep_visit_for_stmt_expr,
		visit_block_stmt = _deep_visit_block_stmt,
		visit_value_decl = _deep_visit_value_decl_expr,

		before_visit_node = _deep_before_visit_node_expr,
		after_visit_node = _deep_after_visit_node_expr,
	}

	ast.walker_init(o.deep_analyzer.walker, &o.deep_analyzer.walker_vtable, o.alloc)
	o.deep_analyzer.walker.user_data = o
}

deep_analyze :: proc(o: ^Optimizer) {
	clear(&o.deep_analyzer.expression_cache)
	clear(&o.deep_analyzer.variable_expressions)
	clear(&o.deep_analyzer.expression_deps)
	clear(&o.deep_analyzer.reverse_expression_deps)
	clear(&o.deep_analyzer.scope_to_context)
	clear(&o.deep_analyzer.var_id_to_scope)
	clear(&o.deep_analyzer.node_id_to_var_id)
	clear(&o.deep_analyzer.function_expressions)
	clear(&o.deep_analyzer.function_params)
	clear(&o.deep_analyzer.function_calls)
	clear(&o.deep_analyzer.call_arguments)
	clear(&o.deep_analyzer.function_return_cache)
	o.deep_analyzer.analyzing_function = nil

	deep_push_expression_context(o, o.symbols.global_scope)

	for file in o.files {
		ast.walk_file(o.deep_analyzer.walker, file)
	}

	// deep_print_all_analysis_info(o)

	deep_pop_expression_context(o)
}

// deep_print_all_analysis_info :: proc(o: ^Optimizer) {
// 	fmt.println("\n=== All Deep Expression Analysis ===")

// 	fmt.println("\n--- Global Context ---")
// 	deep_print_context_info(o, o.deep_analyzer.current_expression_context)

// 	fmt.println("\n--- Global Stmts Contexts ---")
// 	for scope, contex in &o.deep_analyzer.scope_to_context {
// 		if scope != o.symbols.global_scope {
// 			fmt.printf("Scope: %d level: %d\n", scope.id, scope.level)
// 			deep_print_context_info(o, contex)
// 			fmt.println()
// 		}
// 	}
// }

// deep_print_context_info :: proc(o: ^Optimizer, ctx: ^Deep_Expression_Context) {
// 	if ctx == nil { return }

// 	if ctx.is_or_context {
// 		fmt.println("  OR Context with multiple possible states:")
// 		for state, i in ctx.possible_states {
// 			fmt.printf("	State %d:\n", i+1)
// 			print_single_context_info(o, state, "	  ")
// 		}
// 	} else {
// 		print_single_context_info(o, ctx, "  ")
// 	}
// }

// print_single_context_info :: proc(o: ^Optimizer, ctx: ^Deep_Expression_Context, indent: string) {
// 	for var_id, expr in ctx.variables {
// 		fmt.printf("%sVariable: %s@%d (node: %d)\n", indent, var_id.name, var_id.scope_id, var_id.decl_node_id)

// 		if expr != nil {
// 			expr_str := deep_expression_to_string(o, expr)
// 			fmt.printf("%s  Expression: %s\n", indent, expr_str)
// 		}

// 		if constraints, exists := ctx.constraints[var_id]; exists && len(constraints) > 0 {
// 			fmt.printf("%s  Constraints:\n", indent)
// 			for pred in constraints {
// 				fmt.printf("%s	%v ", indent, pred.type)
// 				#partial switch val in pred.value {
// 				case f64:
// 					fmt.printf("%f\n", val)
// 				case i64:
// 					fmt.printf("%d\n", val)
// 				case bool:
// 					fmt.printf("%v\n", val)
// 				case string:
// 					fmt.printf("\"%s\"\n", val)
// 				case Variable_Range:
// 					fmt.printf("range(%f, %f)\n", val.min, val.max)
// 				}
// 			}
// 		}

// 		if transformed, exists := ctx.transformed_predicates[var_id]; exists && len(transformed) > 0 {
// 			fmt.printf("%s  Transformed predicates:\n", indent)
// 			for pred in transformed {
// 				fmt.printf("%s	%v\n", indent, pred.type)
// 			}
// 		}
// 	}
// }

apply_deferred_operations :: proc(o: ^Optimizer) {
	slice.sort_by(o.deferred_operations[:], proc(a, b: Deferred_Operation) -> bool {
		return a.priority < b.priority
	})

	applied_count := 0
	for op in o.deferred_operations {
		if apply_operation(o, op) {
			applied_count += 1
		}
	}

	if applied_count > 0 {
		log.debugf("Applied %d deferred optimization(s)", applied_count)
	}

	clear(&o.deferred_operations)
}

find_insert_index :: proc(
	block: ^ast.Block_Stmt,
	position: Insert_Position,
	relative_node: ^ast.Node,
) -> int {
	#partial switch pos in position {
	case int:
		return clamp(pos, 0, len(block.stmts))

	case:
		switch pos {
		case .At_Beginning:
			return 0
		case .At_End:
			return len(block.stmts)
		case .Before_Node:
			for stmt, i in &block.stmts {
				if cast(uintptr)stmt == cast(uintptr)relative_node {
					return i
				}
			}
		case .After_Node:
			for stmt, i in &block.stmts {
				if cast(uintptr)stmt == cast(uintptr)relative_node {
					return i + 1
				}
			}
		}
	}
	return len(block.stmts)
}

apply_operation :: proc(o: ^Optimizer, op: Deferred_Operation) -> bool {
	#partial switch op.type {
	case .Remove_Node:
		return apply_remove_node(o, op)

	case .Replace_Node:
		return apply_replace_node(o, op)

	case .Move_Node:
		return apply_move_node(o, op)

	case .Insert_Node:
		return apply_insert_node(o, op)

	case .Swap_Nodes:
		return apply_swap_nodes(o, op)
	}

	return false
}

apply_move_node :: proc(o: ^Optimizer, op: Deferred_Operation) -> bool {
	if op.source_node == nil || op.target_parent == nil {
		return false
	}

	current_parent, exists := o.node_parent[op.source_node]
	if !exists {
		return false
	}

	if !remove_node_from_parent(o, op.source_node) {
		return false
	}

	if !insert_node_into_parent(o, op.source_node, op.target_parent, op.target_position, op.relative_node) {
		insert_node_into_parent(o, op.source_node, current_parent, .At_End, nil)
		return false
	}

	return true
}

apply_insert_node :: proc(o: ^Optimizer, op: Deferred_Operation) -> bool {
	if op.source_node == nil || op.target_parent == nil {
		return false
	}

	return insert_node_into_parent(o, op.source_node, op.target_parent, op.target_position, op.relative_node)
}

apply_swap_nodes :: proc(o: ^Optimizer, op: Deferred_Operation) -> bool {
	if op.node_a == nil || op.node_b == nil {
		return false
	}

	parent_a, exists_a := o.node_parent[op.node_a]
	parent_b, exists_b := o.node_parent[op.node_b]

	if !exists_a || !exists_b {
		return false
	}

	pos_a := find_node_position(o, op.node_a)
	pos_b := find_node_position(o, op.node_b)

	remove_node_from_parent(o, op.node_a)
	remove_node_from_parent(o, op.node_b)

	success := true
	success = success && insert_node_into_parent(o, op.node_b, parent_a, pos_a, nil)
	success = success && insert_node_into_parent(o, op.node_a, parent_b, pos_b, nil)

	return success
}

find_node_position :: proc(o: ^Optimizer, node: ^ast.Node) -> Insert_Position {
	parent, exists := o.node_parent[node]
	if !exists {
		return .At_End
	}

	#partial switch p in parent.derived {
	case ^ast.Block_Stmt:
		for stmt, i in &p.stmts {
			if cast(uintptr)stmt == cast(uintptr)node {
				return i
			}
		}

	case ^ast.File:
		for decl, i in &p.decls {
			if cast(uintptr)decl == cast(uintptr)node {
				return i
			}
		}
	}

	return .At_End
}

insert_node_into_parent :: proc(
	o: ^Optimizer,
	node: ^ast.Node,
	parent: ^ast.Node,
	position: Insert_Position,
	relative_node: ^ast.Node,
) -> bool {
	o.node_parent[node] = parent

	#partial switch p in parent.derived {
	case ^ast.File:
		file := p
		insert_index := find_insert_index_for_file(file, position, relative_node)
		new_decls := make([dynamic]^ast.Stmt, len(file.decls)+1, o.alloc)

		copy(new_decls[:], file.decls[:insert_index])

		if node_is_stmt(node) {
			new_decls[insert_index] = cast(^ast.Stmt)node
		} else {
			expr_stmt := ast.new(ast.Expr_Stmt, node.pos, node.end, o.alloc)
			expr_stmt.expr = cast(^ast.Expr)node
			new_decls[insert_index] = cast(^ast.Stmt)expr_stmt
		}

		copy(new_decls[insert_index+1:], file.decls[insert_index:])

		file.decls = new_decls
		return true

	case ^ast.Block_Stmt:
		block := p
		insert_index := find_insert_index(block, position, relative_node)
		new_stmts := make([]^ast.Stmt, len(block.stmts)+1, o.alloc)

		copy(new_stmts[:], block.stmts[:insert_index])

		if node_is_stmt(node) {
			new_stmts[insert_index] = cast(^ast.Stmt)node
		} else {
			expr_stmt := ast.new(ast.Expr_Stmt, node.pos, node.end, o.alloc)
			expr_stmt.expr = cast(^ast.Expr)node
			new_stmts[insert_index] = cast(^ast.Stmt)expr_stmt
		}

		copy(new_stmts[insert_index+1:], block.stmts[insert_index:])
		block.stmts = new_stmts[:]
		return true
	}

	return false
}

find_insert_index_for_file :: proc(file: ^ast.File, position: Insert_Position, relative_node: ^ast.Node) -> int {
	#partial switch pos in position {
	case int:
		return clamp(pos, 0, len(file.decls))

	case:
		switch pos {
		case .At_Beginning:
			return 0
		case .At_End:
			return len(file.decls)
		case .Before_Node:
			for decl, i in &file.decls {
				if cast(uintptr)decl == cast(uintptr)relative_node {
					return i
				}
			}
		case .After_Node:
			for decl, i in &file.decls {
				if cast(uintptr)decl == cast(uintptr)relative_node {
					return i + 1
				}
			}
		}
	}

	return len(file.decls)
}

apply_remove_node :: proc(o: ^Optimizer, op: Deferred_Operation) -> bool {
	if node, is_node := op.selector.(^ast.Node); is_node {
		return remove_node_from_parent(o, node)
	}
	return false
}

apply_replace_node :: proc(o: ^Optimizer, op: Deferred_Operation) -> bool {
	old_node: ^ast.Node
	#partial switch sel in op.selector {
	case ^ast.Node:
		old_node = sel
	case:
		return false
	}

	if old_node == nil || op.replacement == nil {
		return false
	}

	parent, exists := o.node_parent[old_node]
	if !exists || parent == nil {
		return false
	}

	o.node_parent[op.replacement] = parent

	return replace_node_in_parent(o, parent, old_node, op.replacement)
}

replace_node_in_parent :: proc(o: ^Optimizer, parent, old_node, new_node: ^ast.Node) -> bool {
	if scope, exists := o.symbols.node_scopes[old_node.id]; exists {
		o.symbols.node_scopes[new_node.id] = scope
		delete_key(&o.symbols.node_scopes, old_node.id)
	}

	#partial switch p in parent.derived {
	case ^ast.File:
		for i in 0..<len(p.decls) {
			if cast(uintptr)p.decls[i] == cast(uintptr)old_node {
				switch {
				case node_is_stmt(new_node):
					p.decls[i] = cast(^ast.Stmt)new_node
					return true
				case node_is_expr(new_node):
					expr_stmt := ast.new(ast.Expr_Stmt, new_node.pos, new_node.end, o.alloc)
					expr_stmt.expr = cast(^ast.Expr)new_node
					p.decls[i] = cast(^ast.Stmt)expr_stmt
					return true
				}
				#partial switch _ in new_node.derived {
				case ^ast.Block_Stmt:
					p.decls[i] = cast(^ast.Stmt)new_node
					return true
				case:
					return false
				}
			}
		}

	case ^ast.Block_Stmt:
		for i in 0..<len(p.stmts) {
			if cast(uintptr)p.stmts[i] == cast(uintptr)old_node {
				switch {
				case node_is_stmt(new_node):
					p.stmts[i] = cast(^ast.Stmt)new_node
					return true
				case node_is_expr(new_node):
					expr_stmt := ast.new(ast.Expr_Stmt, new_node.pos, new_node.end, o.alloc)
					expr_stmt.expr = cast(^ast.Expr)new_node
					p.stmts[i] = cast(^ast.Stmt)expr_stmt
					return true
			 	}

				#partial switch _ in new_node.derived {
				case ^ast.Block_Stmt:
					block := cast(^ast.Block_Stmt)new_node
					if len(block.stmts) == 1 {
						p.stmts[i] = block.stmts[0]
					} else {
						p.stmts[i] = cast(^ast.Stmt)new_node
					}
					return true
				case:
					return false
				}
			}
		}

	case ^ast.If_Stmt:
		if cast(uintptr)p.init == cast(uintptr)old_node {
			if node_is_stmt(new_node) {
				p.init = cast(^ast.Stmt)new_node
				return true
			}
		} else if cast(uintptr)p.body == cast(uintptr)old_node {
			if block, is_block := new_node.derived.(^ast.Block_Stmt); is_block {
				p.body = block
				return true
			}
		} else if cast(uintptr)p.else_stmt == cast(uintptr)old_node {
			if block, is_block := new_node.derived.(^ast.Block_Stmt); is_block {
				p.else_stmt = block
				return true
			}
		}

	case ^ast.For_Stmt:
		if cast(uintptr)p.body == cast(uintptr)old_node {
			if block, is_block := new_node.derived.(^ast.Block_Stmt); is_block {
				p.body = block
				return true
			}
		}

	case ^ast.Func_Stmt:
		if cast(uintptr)p.body == cast(uintptr)old_node {
			if block, is_block := new_node.derived.(^ast.Block_Stmt); is_block {
				p.body = block
				return true
			}
		}

	case ^ast.Event_Stmt:
		if cast(uintptr)p.body == cast(uintptr)old_node {
			if block, is_block := new_node.derived.(^ast.Block_Stmt); is_block {
				p.body = block
				return true
			}
		}

	case ^ast.Binary_Expr:
		binary := p
		if binary.left == old_node {
			if node_is_expr(new_node) {
				binary.left = cast(^ast.Expr)new_node
				return true
			}
		} else if binary.right == old_node {
			if node_is_expr(new_node) {
				binary.right = cast(^ast.Expr)new_node
				return true
			}
		}

	case ^ast.Unary_Expr:
		unary := p
		if unary.expr == old_node {
			if node_is_expr(new_node) {
				unary.expr = cast(^ast.Expr)new_node
				return true
			}
		}

	case ^ast.Paren_Expr:
		paren := p
		if paren.expr == old_node {
			if node_is_expr(new_node) {
				paren.expr = cast(^ast.Expr)new_node
				return true
			}
		}

	case ^ast.Call_Expr:
		call := p
		if call.expr == old_node {
			if node_is_expr(new_node) {
				call.expr = cast(^ast.Expr)new_node
				return true
			}
		}
		for i in 0..<len(call.args) {
			if call.args[i].value == old_node {
				if node_is_expr(new_node) {
					call.args[i].value = cast(^ast.Expr)new_node
					return true
				}
			}
		}

	case ^ast.Argument:
		arg := p
		if arg.value == old_node {
			if node_is_expr(new_node) {
				arg.value = cast(^ast.Expr)new_node
				return true
			}
		}

	case ^ast.Field_Value:
		field_val := p
		if field_val.field == old_node {
			if node_is_expr(new_node) {
				field_val.field = cast(^ast.Expr)new_node
				return true
			}
		} else if field_val.value == old_node {
			if node_is_expr(new_node) {
				field_val.value = cast(^ast.Expr)new_node
				return true
			}
		}

	case ^ast.Index_Expr:
		index := p
		if index.expr == old_node {
			if node_is_expr(new_node) {
				index.expr = cast(^ast.Expr)new_node
				return true
			}
		} else if index.index == old_node {
			if node_is_expr(new_node) {
				index.index = cast(^ast.Expr)new_node
				return true
			}
		}

	case ^ast.Member_Access_Expr:
		member := p
		if member.expr == old_node {
			if node_is_expr(new_node) {
				member.expr = cast(^ast.Expr)new_node
				return true
			}
		} else if member.field == old_node {
			#partial switch t in new_node.derived {
			case ^ast.Ident:
				member.field = t
				return true
			}
		}

	case ^ast.Value_Decl:
		decl := p
		if decl.value == old_node {
			if node_is_expr(new_node) {
				decl.value = cast(^ast.Expr)new_node
				return true
			}
		}

	case ^ast.Assign_Stmt:
		assign := p
		if assign.expr == old_node {
			if node_is_expr(new_node) {
				assign.expr = cast(^ast.Expr)new_node
				return true
			}
		}

	case ^ast.Expr_Stmt:
		expr_stmt := p
		if expr_stmt.expr == old_node {
			if node_is_expr(new_node) {
				expr_stmt.expr = cast(^ast.Expr)new_node
				return true
			}
		}

	case ^ast.Return_Stmt:
		ret := p
		if ret.result == old_node {
			if node_is_expr(new_node) {
				ret.result = cast(^ast.Expr)new_node
				return true
			}
		}
	}

	return false
}

node_is_stmt :: proc(node: ^ast.Node) -> bool {
	#partial switch _ in node.derived {
	case ^ast.Value_Decl, ^ast.Assign_Stmt, ^ast.Expr_Stmt, ^ast.If_Stmt, ^ast.For_Stmt,
		 ^ast.Return_Stmt, ^ast.Block_Stmt, ^ast.Func_Stmt, ^ast.Event_Stmt, ^ast.Defer_Stmt:
		return true
	case:
		return false
	}
}

node_is_expr :: proc(node: ^ast.Node) -> bool {
	#partial switch _ in node.derived {
	case ^ast.Ident, ^ast.Call_Expr, ^ast.Binary_Expr, ^ast.Unary_Expr, ^ast.Paren_Expr,
		 ^ast.Basic_Lit, ^ast.Member_Access_Expr, ^ast.Index_Expr, ^ast.Field_Value:
		return true
	case:
		return false
	}
}

Flow_Node :: struct {
	id:               int,
	node:             ^ast.Node,
	dependencies:     map[^ast.Node]bool,
	dependents:       map[^ast.Node]bool,
	is_volatile:      bool,
	has_side_effects: bool,
	execution_order:  int,
	flow_id:          int,
	visited:          bool,
	in_current_path:  bool,
	defined_vars:     [dynamic]string,
	used_vars:        [dynamic]string,
}

Flow :: struct {
	id:                      int,
	nodes:                   [dynamic]^Flow_Node,
	is_volatile:             bool,
	depends_on:              [dynamic]int,
	execution_order:         int,
	can_execute_in_parallel: bool,
	defined_vars:            map[string]bool,
	used_vars:               map[string]bool,
}

Flow_Analyzer :: struct {
	flow_nodes:             map[^ast.Node]^Flow_Node,
	flows:                  [dynamic]^Flow,
	current_flow_id:        int,
	execution_counter:      int,
	node_to_flow:           map[^ast.Node]int,
	flow_dependency_graph:  map[int][dynamic]int,

	temp_visited:           map[^ast.Node]bool,
	perm_visited:           map[^ast.Node]bool,
	node_stack:             [dynamic]^ast.Node,
	variable_defs:          map[string][dynamic]^ast.Node,
	current_variable_scope: ^checker.Scope,
}

flow_analyzer_init :: proc(o: ^Optimizer) {
	o.flow_analyzer = new(Flow_Analyzer, o.alloc)
	o.flow_analyzer.flow_nodes = make(map[^ast.Node]^Flow_Node, o.alloc)
	o.flow_analyzer.flows = make([dynamic]^Flow, o.alloc)
	o.flow_analyzer.node_to_flow = make(map[^ast.Node]int, o.alloc)
	o.flow_analyzer.flow_dependency_graph = make(map[int][dynamic]int, o.alloc)
	o.flow_analyzer.temp_visited = make(map[^ast.Node]bool, o.alloc)
	o.flow_analyzer.perm_visited = make(map[^ast.Node]bool, o.alloc)
	o.flow_analyzer.node_stack = make([dynamic]^ast.Node, o.alloc)
	o.flow_analyzer.variable_defs = make(map[string][dynamic]^ast.Node, o.alloc)
}

is_native_function :: proc(o: ^Optimizer, func_name: string) -> bool {
	sym := find_symbol_in_scopes(o, func_name, o.current_scope)
	if sym == nil { return false }

	if flags_field, has_flags := sym.metadata["flags"]; has_flags {
		if flags, ok := flags_field.(checker.Flags); ok {
			return .NATIVE in flags
		}
	}
	return false
}

is_function_volatile :: proc(o: ^Optimizer, func_name: string) -> bool {
	if is_native_function(o, func_name) {
		return true
	}

	sym := find_symbol_in_scopes(o, func_name, o.current_scope)
	if sym == nil { return false }

	if flags_field, has_flags := sym.metadata["flags"]; has_flags {
		if flags, ok := flags_field.(checker.Flags); ok {
			if .BUILTIN in flags {
				return .VOLATILE in flags
			}
		}
	}

	return function_has_side_effects(o, sym)
}

function_has_side_effects :: proc(o: ^Optimizer, sym: ^checker.Symbol) -> bool {
	if sym == nil || sym.decl_node == nil { return false }

	#partial switch node in sym.decl_node.derived {
	case ^ast.Func_Stmt:
		func_stmt := node
		if func_stmt.body == nil { return false }

		saved_scope := o.current_scope
		saved_level := o.current_level

		if scope, exists := o.symbols.node_scopes[func_stmt.id]; exists {
			o.current_scope = scope
			o.current_level = scope.level
		}

		has_effects := false
		check_side_effects_in_block(o, func_stmt.body, &has_effects)

		o.current_scope = saved_scope
		o.current_level = saved_level

		return has_effects

	case:
		return false
	}
}

check_side_effects_in_block :: proc(o: ^Optimizer, block: ^ast.Block_Stmt, has_effects: ^bool) {
	if block == nil || has_effects^ { return }

	for stmt in block.stmts {
		check_side_effects_in_stmt(o, stmt, has_effects)
		if has_effects^ { return }
	}
}

check_side_effects_in_stmt :: proc(o: ^Optimizer, stmt: ^ast.Stmt, has_effects: ^bool) {
	if stmt == nil || has_effects^ { return }

	#partial switch s in stmt.derived {
	case ^ast.Call_Expr:
		call := s
		if ident, is_ident := call.expr.derived.(^ast.Ident); is_ident {
			if is_function_volatile(o, ident.name) {
				has_effects^ = true
				return
			}
		}

	case ^ast.Assign_Stmt:
		assign := s
		if assign.name != "" && assign.name != "_" {
			if !is_local_variable(o, assign.name) {
				has_effects^ = true
				return
			}
		}
		if assign.expr != nil {
			check_side_effects_in_expr(o, assign.expr, has_effects)
		}

	case ^ast.Value_Decl:
		decl := s
		if decl.value != nil {
			check_side_effects_in_expr(o, decl.value, has_effects)
		}

	case ^ast.Expr_Stmt:
		expr_stmt := s
		if expr_stmt.expr != nil {
			check_side_effects_in_expr(o, expr_stmt.expr, has_effects)
		}

	case ^ast.If_Stmt:
		if_stmt := s
		if if_stmt.cond != nil {
			check_side_effects_in_expr(o, if_stmt.cond, has_effects)
		}
		if if_stmt.body != nil {
			check_side_effects_in_block(o, if_stmt.body, has_effects)
		}
		if if_stmt.else_stmt != nil {
			if block, is_block := if_stmt.else_stmt.derived.(^ast.Block_Stmt); is_block {
				check_side_effects_in_block(o, block, has_effects)
			}
		}

	case ^ast.For_Stmt:
		for_stmt := s
		if for_stmt.cond != nil {
			check_side_effects_in_expr(o, for_stmt.cond, has_effects)
		}
		if for_stmt.second_cond != nil {
			check_side_effects_in_expr(o, for_stmt.second_cond, has_effects)
		}
		if for_stmt.body != nil {
			check_side_effects_in_block(o, for_stmt.body, has_effects)
		}

	case ^ast.Block_Stmt:
		check_side_effects_in_block(o, s, has_effects)

	case ^ast.Return_Stmt:
		ret := s
		if ret.result != nil {
			check_side_effects_in_expr(o, ret.result, has_effects)
		}
	}
}

check_side_effects_in_expr :: proc(o: ^Optimizer, expr: ^ast.Expr, has_effects: ^bool) {
	if expr == nil || has_effects^ { return }

	#partial switch e in expr.derived {
	case ^ast.Call_Expr:
		call := e
		if ident, is_ident := call.expr.derived.(^ast.Ident); is_ident {
			if is_function_volatile(o, ident.name) {
				has_effects^ = true
				return
			}
		}
		for arg in call.args {
			check_side_effects_in_expr(o, arg.value, has_effects)
			if has_effects^ { return }
		}

	case ^ast.Binary_Expr:
		binary := e
		check_side_effects_in_expr(o, binary.left, has_effects)
		if has_effects^ { return }
		check_side_effects_in_expr(o, binary.right, has_effects)

	case ^ast.Unary_Expr:
		unary := e
		check_side_effects_in_expr(o, unary.expr, has_effects)

	case ^ast.Member_Access_Expr:
		member := e
		check_side_effects_in_expr(o, member.expr, has_effects)

	case ^ast.Index_Expr:
		index := e
		check_side_effects_in_expr(o, index.expr, has_effects)
		if has_effects^ { return }
		check_side_effects_in_expr(o, index.index, has_effects)

	case ^ast.Paren_Expr:
		paren := e
		check_side_effects_in_expr(o, paren.expr, has_effects)
	}
}

is_local_variable :: proc(o: ^Optimizer, var_name: string) -> bool {
	if o.current_scope == nil { return false }

	for scope := o.current_scope; scope != nil; scope = scope.parent {
		for sym in scope.symbols {
			if sym.name == var_name {
				return true
			}
		}
	}

	return false
}

create_flow_node :: proc(o: ^Optimizer, node: ^ast.Node) -> ^Flow_Node {
	if node == nil { return nil }

	flow_node := new(Flow_Node, o.alloc)
	flow_node.id = len(o.flow_analyzer.flow_nodes)
	flow_node.node = node
	flow_node.dependencies = make(map[^ast.Node]bool, o.alloc)
	flow_node.dependents = make(map[^ast.Node]bool, o.alloc)
	flow_node.defined_vars = make([dynamic]string, o.alloc)
	flow_node.used_vars = make([dynamic]string, o.alloc)
	flow_node.is_volatile = is_node_volatile(o, node)
	flow_node.has_side_effects = flow_node.is_volatile
	flow_node.flow_id = -1

	collect_variable_info(o, flow_node)

	o.flow_analyzer.flow_nodes[node] = flow_node
	return flow_node
}

is_node_volatile :: proc(o: ^Optimizer, node: ^ast.Node) -> bool {
	if node == nil { return false }

	#partial switch n in node.derived {
	case ^ast.Call_Expr:
		call := n
		if ident, is_ident := call.expr.derived.(^ast.Ident); is_ident {
			return is_function_volatile(o, ident.name)
		}
		return true

	case ^ast.Assign_Stmt:
		assign := n
		if assign.expr != nil {
			return is_node_volatile(o, assign.expr)
		}
		return false

	case ^ast.Value_Decl:
		decl := n
		if decl.value != nil {
			return is_node_volatile(o, decl.value)
		}
		return false

	case ^ast.Expr_Stmt:
		expr_stmt := n
		if expr_stmt.expr != nil {
			return is_node_volatile(o, expr_stmt.expr)
		}
		return false

	case ^ast.If_Stmt:
		if_stmt := n
		if if_stmt.cond != nil {
			return is_node_volatile(o, if_stmt.cond)
		}
		return false

	case ^ast.For_Stmt:
		for_stmt := n
		is_volatile := false
		if for_stmt.cond != nil {
			is_volatile = is_volatile || is_node_volatile(o, for_stmt.cond)
		}
		if for_stmt.second_cond != nil {
			is_volatile = is_volatile || is_node_volatile(o, for_stmt.second_cond)
		}
		return is_volatile

	case ^ast.Return_Stmt:
		ret := n
		if ret.result != nil {
			return is_node_volatile(o, ret.result)
		}
		return false

	case ^ast.Binary_Expr:
		binary := n
		left_volatile := is_node_volatile(o, binary.left)
		right_volatile := is_node_volatile(o, binary.right)
		return left_volatile || right_volatile

	case ^ast.Unary_Expr:
		unary := n
		return is_node_volatile(o, unary.expr)

	case ^ast.Paren_Expr:
		paren := n
		return is_node_volatile(o, paren.expr)

	case ^ast.Member_Access_Expr:
		member := n
		return is_node_volatile(o, member.expr)

	case ^ast.Index_Expr:
		index := n
		expr_volatile := is_node_volatile(o, index.expr)
		index_volatile := is_node_volatile(o, index.index)
		return expr_volatile || index_volatile

	case ^ast.Block_Stmt:
		block := n
		for stmt in block.stmts {
			if is_node_volatile(o, cast(^ast.Node)stmt) {
				return true
			}
		}
		return false

	case ^ast.Field_Value:
		field := n
		field_volatile := is_node_volatile(o, field.field)
		value_volatile := is_node_volatile(o, field.value)
		return field_volatile || value_volatile

	case:
		return false
	}
}

collect_variable_info :: proc(o: ^Optimizer, flow_node: ^Flow_Node) {
	if flow_node == nil || flow_node.node == nil { return }

	node := flow_node.node

	#partial switch n in node.derived {
	case ^ast.Value_Decl:
		decl := n
		if decl.name != "" && decl.name != "_" {
			append(&flow_node.defined_vars, decl.name)
		}
		if decl.value != nil {
			collect_used_vars_from_expr(o, decl.value, &flow_node.used_vars)
		}

	case ^ast.Assign_Stmt:
		assign := n
		if assign.name != "" && assign.name != "_" {
			append(&flow_node.defined_vars, assign.name)
		}
		if assign.expr != nil {
			collect_used_vars_from_expr(o, assign.expr, &flow_node.used_vars)
		}

	case ^ast.Expr_Stmt:
		expr_stmt := n
		if expr_stmt.expr != nil {
			collect_used_vars_from_expr(o, expr_stmt.expr, &flow_node.used_vars)
		}

	case ^ast.If_Stmt:
		if_stmt := n
		if if_stmt.cond != nil {
			collect_used_vars_from_expr(o, if_stmt.cond, &flow_node.used_vars)
		}

	case ^ast.For_Stmt:
		for_stmt := n
		if for_stmt.cond != nil {
			collect_used_vars_from_expr(o, for_stmt.cond, &flow_node.used_vars)
		}
		if for_stmt.second_cond != nil {
			collect_used_vars_from_expr(o, for_stmt.second_cond, &flow_node.used_vars)
		}

	case ^ast.Return_Stmt:
		ret := n
		if ret.result != nil {
			collect_used_vars_from_expr(o, ret.result, &flow_node.used_vars)
		}

	case ^ast.Block_Stmt:
		block := n
		for stmt in block.stmts {
			if stmt_flow_node := o.flow_analyzer.flow_nodes[cast(^ast.Node)stmt]; stmt_flow_node != nil {
				for var_name in stmt_flow_node.defined_vars {
					append(&flow_node.defined_vars, var_name)
				}
				for var_name in stmt_flow_node.used_vars {
					append(&flow_node.used_vars, var_name)
				}
			}
		}
	}
}

collect_used_vars_from_expr :: proc(o: ^Optimizer, expr: ^ast.Expr, used_vars: ^[dynamic]string) {
	if expr == nil { return }

	#partial switch e in expr.derived {
	case ^ast.Ident:
		ident := e
		append(used_vars, ident.name)

	case ^ast.Call_Expr:
		call := e
		collect_used_vars_from_expr(o, call.expr, used_vars)
		for arg in call.args {
			collect_used_vars_from_expr(o, arg.value, used_vars)
		}

	case ^ast.Binary_Expr:
		binary := e
		collect_used_vars_from_expr(o, binary.left, used_vars)
		collect_used_vars_from_expr(o, binary.right, used_vars)

	case ^ast.Unary_Expr:
		unary := e
		collect_used_vars_from_expr(o, unary.expr, used_vars)

	case ^ast.Member_Access_Expr:
		member := e
		collect_used_vars_from_expr(o, member.expr, used_vars)

	case ^ast.Index_Expr:
		index := e
		collect_used_vars_from_expr(o, index.expr, used_vars)
		collect_used_vars_from_expr(o, index.index, used_vars)

	case ^ast.Paren_Expr:
		paren := e
		collect_used_vars_from_expr(o, paren.expr, used_vars)

	case ^ast.Field_Value:
		field := e
		collect_used_vars_from_expr(o, field.field, used_vars)
		collect_used_vars_from_expr(o, field.value, used_vars)
	}
}

analyze_flow_dependencies :: proc(o: ^Optimizer) {
	for file in o.files {
		create_flow_nodes_for_file(o, file)
	}

	build_variable_definitions_map(o)

	for file in o.files {
		analyze_dependencies_in_file(o, file)
	}

	group_nodes_into_flows(o)

	determine_flow_execution_order(o)

	// print_flow_analysis_results(o)
}

// print_flow_analysis_results :: proc(o: ^Optimizer) {
// 	fmt.println("\n=== Flow Analysis Results ===")
// 	fmt.printf("Total flows: %d\n", len(o.flow_analyzer.flows))
// 	fmt.printf("Total flow nodes: %d\n", len(o.flow_analyzer.flow_nodes))

// 	for flow in o.flow_analyzer.flows {
// 		fmt.printf("\nFlow %d (execution order: %d):\n", flow.id, flow.execution_order)
// 		fmt.printf("  Nodes: %d\n", len(flow.nodes))
// 		fmt.printf("  Volatile: %v\n", flow.is_volatile)
// 		fmt.printf("  Can execute in parallel: %v\n", flow.can_execute_in_parallel)
// 		fmt.printf("  Depends on flows: ")
// 		if len(flow.depends_on) > 0 {
// 			for dep in flow.depends_on {
// 				fmt.printf("%d ", dep)
// 			}
// 		} else {
// 			fmt.printf("none")
// 		}
// 		fmt.println()

// 		fmt.printf("  Contains: ")
// 		node_count := 0
// 		for node in flow.nodes {
// 			if node_count >= 5 && len(flow.nodes) > 5 {
// 				fmt.printf("... and %d more", len(flow.nodes) - 5)
// 				break
// 			}
// 			#partial switch n in node.node.derived {
// 			case ^ast.Value_Decl:
// 				fmt.printf("ValueDecl ")
// 			case ^ast.Assign_Stmt:
// 				fmt.printf("AssignStmt ")
// 			case ^ast.Expr_Stmt:
// 				fmt.printf("ExprStmt ")
// 			case ^ast.If_Stmt:
// 				fmt.printf("IfStmt ")
// 			case ^ast.For_Stmt:
// 				fmt.printf("ForStmt ")
// 			case ^ast.Return_Stmt:
// 				fmt.printf("ReturnStmt ")
// 			case ^ast.Block_Stmt:
// 				fmt.printf("BlockStmt ")
// 			case:
// 				fmt.printf("Other ")
// 			}
// 			fmt.printf("on %v:%v ", node.node.pos.line + 1, node.node.pos.column + 1)
// 			node_count += 1
// 		}
// 		fmt.println()
// 	}
// }

create_flow_nodes_for_file :: proc(o: ^Optimizer, file: ^ast.File) {
	for decl in file.decls {
		create_flow_node_for_statement(o, decl)
	}
}

create_flow_node_for_statement :: proc(o: ^Optimizer, stmt: ^ast.Stmt) {
	flow_node := create_flow_node(o, cast(^ast.Node)stmt)
	if flow_node == nil { return }

	#partial switch s in stmt.derived {
	case ^ast.If_Stmt:
		if_stmt := s
		if if_stmt.body != nil {
			create_flow_nodes_for_block(o, if_stmt.body)
		}
		if if_stmt.else_stmt != nil {
			create_flow_nodes_for_block(o, if_stmt.else_stmt)
		}

	case ^ast.For_Stmt:
		for_stmt := s
		if for_stmt.body != nil {
			create_flow_nodes_for_block(o, for_stmt.body)
		}

	case ^ast.Block_Stmt:
		create_flow_nodes_for_block(o, s)

	case ^ast.Func_Stmt:
		func_stmt := s
		if func_stmt.body != nil {
			create_flow_nodes_for_block(o, func_stmt.body)
		}

	case ^ast.Event_Stmt:
		event_stmt := s
		if event_stmt.body != nil {
			create_flow_nodes_for_block(o, event_stmt.body)
		}
	}
}

create_flow_nodes_for_block :: proc(o: ^Optimizer, block: ^ast.Block_Stmt) {
	for stmt in block.stmts {
		create_flow_node_for_statement(o, stmt)
	}
}

build_variable_definitions_map :: proc(o: ^Optimizer) {
	for node, flow_node in o.flow_analyzer.flow_nodes {
		for var_name in flow_node.defined_vars {
			if _, exists := o.flow_analyzer.variable_defs[var_name]; !exists {
				o.flow_analyzer.variable_defs[var_name] = make([dynamic]^ast.Node, o.alloc)
			}
			append(&o.flow_analyzer.variable_defs[var_name], node)
		}
	}
}

analyze_dependencies_in_file :: proc(o: ^Optimizer, file: ^ast.File) {
	statements := make([dynamic]^ast.Stmt, o.alloc)
	defer delete(statements)

	collect_statements_in_order(o, cast(^ast.Node)file, &statements)

	for i in 0..<len(statements) {
		current_stmt := statements[i]
		current_node := cast(^ast.Node)current_stmt
		current_flow_node := o.flow_analyzer.flow_nodes[current_node]

		if current_flow_node == nil { continue }

		find_statement_dependencies(o, current_flow_node, i, statements[:])
	}
}

collect_statements_in_order :: proc(o: ^Optimizer, node: ^ast.Node, statements: ^[dynamic]^ast.Stmt) {
	if node == nil { return }

	#partial switch n in node.derived {
	case ^ast.File:
		file := n
		for decl in file.decls {
			collect_statements_in_order(o, cast(^ast.Node)decl, statements)
		}

	case ^ast.Block_Stmt:
		block := n
		for stmt in block.stmts {
			collect_statements_in_order(o, cast(^ast.Node)stmt, statements)
		}

	case ^ast.If_Stmt:
		if_stmt := n
		if if_stmt.body != nil {
			collect_statements_in_order(o, if_stmt.body, statements)
		}
		if if_stmt.else_stmt != nil {
			collect_statements_in_order(o, if_stmt.else_stmt, statements)
		}

	case ^ast.For_Stmt:
		for_stmt := n
		if for_stmt.body != nil {
			collect_statements_in_order(o, for_stmt.body, statements)
		}

	case ^ast.Func_Stmt:
		func_stmt := n
		if func_stmt.body != nil {
			collect_statements_in_order(o, func_stmt.body, statements)
		}

	case ^ast.Event_Stmt:
		event_stmt := n
		if event_stmt.body != nil {
			collect_statements_in_order(o, event_stmt.body, statements)
		}

	case:
		if node_is_stmt(node) {
			append(statements, cast(^ast.Stmt)node)
		}
	}
}

find_statement_dependencies :: proc(o: ^Optimizer, current_flow_node: ^Flow_Node, current_index: int, statements: []^ast.Stmt) {
	for used_var in current_flow_node.used_vars {
		if def_nodes, exists := &o.flow_analyzer.variable_defs[used_var]; exists {
			for &def_node in def_nodes {
				for i in 0..<current_index {
					if cast(uintptr)statements[i] == cast(uintptr)def_node {
						def_flow_node := o.flow_analyzer.flow_nodes[def_node]
						if def_flow_node != nil {
							current_flow_node.dependencies[def_node] = true
							def_flow_node.dependents[cast(^ast.Node)statements[current_index]] = true
						}
						break
					}
				}
			}
		}
	}

	if if_stmt, is_if := current_flow_node.node.derived.(^ast.If_Stmt); is_if {
		add_control_dependencies_for_if(o, current_flow_node, if_stmt, current_index, statements)
	}

	if for_stmt, is_for := current_flow_node.node.derived.(^ast.For_Stmt); is_for {
		add_control_dependencies_for_for(o, current_flow_node, for_stmt, current_index, statements)
	}
}

add_control_dependencies_for_if :: proc(o: ^Optimizer, if_flow_node: ^Flow_Node, if_stmt: ^ast.If_Stmt, current_index: int, statements: []^ast.Stmt) {
	for i in 0..<current_index {
		prev_stmt := statements[i]
		prev_node := cast(^ast.Node)prev_stmt
		prev_flow_node := o.flow_analyzer.flow_nodes[prev_node]

		if prev_flow_node == nil { continue }

		if affects_condition(o, prev_flow_node, if_stmt.cond) {
			if_flow_node.dependencies[prev_node] = true
			prev_flow_node.dependents[if_flow_node.node] = true
		}
	}
}

add_control_dependencies_for_for :: proc(o: ^Optimizer, for_flow_node: ^Flow_Node, for_stmt: ^ast.For_Stmt, current_index: int, statements: []^ast.Stmt) {
	for i in 0..<current_index {
		prev_stmt := statements[i]
		prev_node := cast(^ast.Node)prev_stmt
		prev_flow_node := o.flow_analyzer.flow_nodes[prev_node]

		if prev_flow_node == nil { continue }

		affects := false
		if for_stmt.cond != nil {
			affects = affects_condition(o, prev_flow_node, for_stmt.cond)
		}
		if !affects && for_stmt.second_cond != nil {
			affects = affects_condition(o, prev_flow_node, for_stmt.second_cond)
		}

		if affects {
			for_flow_node.dependencies[prev_node] = true
			prev_flow_node.dependents[for_flow_node.node] = true
		}
	}
}

affects_condition :: proc(o: ^Optimizer, stmt_flow_node: ^Flow_Node, condition: ^ast.Expr) -> bool {
	if condition == nil { return false }

	condition_vars := make([dynamic]string, o.alloc)
	defer delete(condition_vars)

	collect_used_vars_from_expr(o, condition, &condition_vars)

	for defined_var in stmt_flow_node.defined_vars {
		for condition_var in condition_vars {
			if defined_var == condition_var {
				return true
			}
		}
	}

	return false
}

group_nodes_into_flows :: proc(o: ^Optimizer) {
	independent_nodes := make([dynamic]^Flow_Node, o.alloc)

	for node, flow_node in &o.flow_analyzer.flow_nodes {
		if len(flow_node.dependencies) == 0 && flow_node.flow_id == -1 {
			append(&independent_nodes, flow_node)
		}
	}

	current_flow_id := 0

	for node in independent_nodes {
		if node.flow_id == -1 {
			flow := create_new_flow(o, current_flow_id)
			current_flow_id += 1

			add_node_to_flow(o, node, flow)

			add_connected_nodes(o, node, flow)
		}
	}

	for node, flow_node in &o.flow_analyzer.flow_nodes {
		if flow_node.flow_id == -1 {
			flow := create_new_flow(o, current_flow_id)
			current_flow_id += 1

			add_node_to_flow(o, flow_node, flow)

			add_all_dependent_nodes(o, flow_node, flow)
		}
	}
}

create_new_flow :: proc(o: ^Optimizer, id: int) -> ^Flow {
	flow := new(Flow, o.alloc)
	flow.id = id
	flow.nodes = make([dynamic]^Flow_Node, o.alloc)
	flow.depends_on = make([dynamic]int, o.alloc)
	flow.defined_vars = make(map[string]bool, o.alloc)
	flow.used_vars = make(map[string]bool, o.alloc)
	flow.can_execute_in_parallel = true
	flow.is_volatile = false

	append(&o.flow_analyzer.flows, flow)
	return flow
}

add_node_to_flow :: proc(o: ^Optimizer, flow_node: ^Flow_Node, flow: ^Flow) {
	flow_node.flow_id = flow.id
	append(&flow.nodes, flow_node)
	o.flow_analyzer.node_to_flow[flow_node.node] = flow.id

	for var_name in flow_node.defined_vars {
		flow.defined_vars[var_name] = true
	}
	for var_name in flow_node.used_vars {
		flow.used_vars[var_name] = true
	}

	if flow_node.is_volatile || flow_node.has_side_effects {
		flow.is_volatile = true
		flow.can_execute_in_parallel = false
	}
}

add_connected_nodes :: proc(o: ^Optimizer, start_node: ^Flow_Node, flow: ^Flow) {
	stack := make([dynamic]^Flow_Node, o.alloc)
	defer delete(stack)

	append(&stack, start_node)

	for len(stack) > 0 {
		current := pop(&stack)

		for dep_node, _ in &current.dependents {
			if dep_flow_node := o.flow_analyzer.flow_nodes[dep_node]; dep_flow_node != nil {
				if dep_flow_node.flow_id == -1 && !dep_flow_node.is_volatile {
					all_deps_in_flow := true
					for dep_dep_node, _ in dep_flow_node.dependencies {
						dep_dep_flow_node := o.flow_analyzer.flow_nodes[dep_dep_node]
						if dep_dep_flow_node == nil || dep_dep_flow_node.flow_id != flow.id {
							all_deps_in_flow = false
							break
						}
					}

					if all_deps_in_flow {
						add_node_to_flow(o, dep_flow_node, flow)
						append(&stack, dep_flow_node)
					}
				}
			}
		}
	}
}

add_all_dependent_nodes :: proc(o: ^Optimizer, start_node: ^Flow_Node, flow: ^Flow) {
	stack := make([dynamic]^Flow_Node, o.alloc)
	defer delete(stack)

	append(&stack, start_node)

	for len(stack) > 0 {
		current := pop(&stack)

		if current.flow_id == -1 {
			add_node_to_flow(o, current, flow)
		}

		for dep_node, _ in current.dependents {
			if dep_flow_node := o.flow_analyzer.flow_nodes[dep_node]; dep_flow_node != nil {
				if dep_flow_node.flow_id == -1 {
					append(&stack, dep_flow_node)
				}
			}
		}
	}
}

determine_flow_execution_order :: proc(o: ^Optimizer) {
	build_flow_dependency_graph(o)

	sorted_flows := topological_sort_flows(o)

	for &flow, idx in sorted_flows {
		flow.execution_order = idx
	}
}

build_flow_dependency_graph :: proc(o: ^Optimizer) {
	for flow in o.flow_analyzer.flows {
		o.flow_analyzer.flow_dependency_graph[flow.id] = make([dynamic]int, o.alloc)

		for node in flow.nodes {
			for dep_node, _ in node.dependencies {
				dep_flow_id := o.flow_analyzer.node_to_flow[dep_node]
				if dep_flow_id != flow.id && dep_flow_id != -1 {
					add_flow_dependency(o, flow.id, dep_flow_id)
				}
			}
		}
	}
}

add_flow_dependency :: proc(o: ^Optimizer, from_flow_id, to_flow_id: int) {
	deps := &o.flow_analyzer.flow_dependency_graph[from_flow_id]

	for dep in deps {
		if dep == to_flow_id {
			return
		}
	}

	append(deps, to_flow_id)

	for &flow in o.flow_analyzer.flows {
		if flow.id == from_flow_id {
			found := false
			for existing_dep in flow.depends_on {
				if existing_dep == to_flow_id {
					found = true
					break
				}
			}
			if !found {
				append(&flow.depends_on, to_flow_id)
			}
			break
		}
	}
}

topological_sort_flows :: proc(o: ^Optimizer) -> [dynamic]^Flow {
	sorted := make([dynamic]^Flow, o.alloc)
	visited := make(map[int]bool, o.alloc)
	temp_visited := make(map[int]bool, o.alloc)

	for flow in o.flow_analyzer.flows {
		if !visited[flow.id] {
			dfs_topological_sort(o, flow.id, &sorted, &visited, &temp_visited)
		}
	}

	return sorted
}

dfs_topological_sort :: proc(o: ^Optimizer, flow_id: int, sorted: ^[dynamic]^Flow, visited, temp_visited: ^map[int]bool) {
	if temp_visited[flow_id] {
		return
	}

	if visited[flow_id] {
		return
	}

	temp_visited[flow_id] = true

	if deps, exists := &o.flow_analyzer.flow_dependency_graph[flow_id]; exists {
		for &dep_id in deps {
			dfs_topological_sort(o, dep_id, sorted, visited, temp_visited)
		}
	}

	temp_visited[flow_id] = false
	visited[flow_id] = true

	for &flow in o.flow_analyzer.flows {
		if flow.id == flow_id {
			append(sorted, flow)
			break
		}
	}
}

reorder_operands_in_file :: proc(o: ^Optimizer, file: ^ast.File) -> int {
	count := 0

	reorder_in_node :: proc(o: ^Optimizer, node: ^ast.Node, count: ^int) {
		if node == nil { return }

		#partial switch n in node.derived {
		case ^ast.Binary_Expr:
			if reorder_constant_operands(o, n) {
				count^ += 1
			}
			reorder_in_node(o, n.left, count)
			reorder_in_node(o, n.right, count)

		case ^ast.File:
			for decl in n.decls {
				reorder_in_node(o, decl, count)
			}

		case ^ast.Block_Stmt:
			for stmt in n.stmts {
				reorder_in_node(o, stmt, count)
			}

		case ^ast.If_Stmt:
			reorder_in_node(o, n.cond, count)
			reorder_in_node(o, n.body, count)
			reorder_in_node(o, n.else_stmt, count)

		case ^ast.For_Stmt:
			reorder_in_node(o, n.cond, count)
			reorder_in_node(o, n.body, count)

		case ^ast.Func_Stmt:
			reorder_in_node(o, n.body, count)

		case ^ast.Event_Stmt:
			reorder_in_node(o, n.body, count)

		case ^ast.Value_Decl:
			reorder_in_node(o, n.value, count)

		case ^ast.Expr_Stmt:
			reorder_in_node(o, n.expr, count)

		case ^ast.Assign_Stmt:
			reorder_in_node(o, n.expr, count)

		case ^ast.Return_Stmt:
			reorder_in_node(o, n.result, count)

		case ^ast.Unary_Expr:
			reorder_in_node(o, n.expr, count)

		case ^ast.Paren_Expr:
			reorder_in_node(o, n.expr, count)

		case ^ast.Call_Expr:
			reorder_in_node(o, n.expr, count)
			for arg in n.args {
				reorder_in_node(o, arg.value, count)
			}
		}
	}

	reorder_in_node(o, file, &count)
	return count
}

find_constant_conversion_candidates :: proc(o: ^Optimizer) {
	clear(&o.const_prop_candidates)
	clear(&o.variables_to_convert)
	clear(&o.variables_to_replace)

	potential := make([dynamic]^checker.Symbol, o.alloc)
	defer delete(potential)

	for scope in o.all_scopes {
		for &sym in scope.symbols {
			if is_basic_conversion_candidate(o, sym) {
				append(&potential, sym)
			}
		}
	}

	found_any := true
	iteration := 0
	max_iterations := len(potential)

	for found_any && iteration < max_iterations {
		found_any = false
		iteration += 1

		for sym in potential {
			if sym in o.const_prop_candidates {
				continue
			}

			if const_result := try_evaluate_with_candidates(o, sym); const_result.is_constant {
				o.const_prop_candidates[sym] = const_result
				o.variables_to_convert[sym] = true

				if count, exists := o.symbol_usage_count[sym]; exists && count > 0 {
					o.variables_to_replace[sym] = true
				}

				found_any = true
			}
		}
	}
}

is_basic_conversion_candidate :: proc(o: ^Optimizer, sym: ^checker.Symbol) -> bool {
	if sym == nil { return false }
	if sym.decl_node == nil { return false }
	if is_symbol_public(sym) { return false }
	if sym.is_const { return false }

	if flags_field, has := sym.metadata["flags"]; has {
		if flags, ok := flags_field.(checker.Flags); ok {
			if .BUILTIN in flags || .NATIVE in flags {
				return false
			}
		}
	}

	#partial switch decl in sym.decl_node.derived {
	case ^ast.Value_Decl:
		if decl.value == nil { return false }

		count, exists := o.symbol_usage_count[sym]
		if !exists || count == 0 { return false }

		if is_variable_modified(o, sym) { return false }

		return true
	}

	return false
}

try_evaluate_with_candidates :: proc(o: ^Optimizer, sym: ^checker.Symbol) -> Constant_Result {
	if sym.decl_node == nil {
		return {is_constant = false}
	}

	#partial switch decl in sym.decl_node.derived {
	case ^ast.Value_Decl:
		if decl.value != nil {
			saved_scope := o.current_scope
			saved_level := o.current_level
			defer {
				o.current_scope = saved_scope
				o.current_level = saved_level
			}

			if scope, exists := o.symbols.all_node_scopes[sym.decl_node.id]; exists {
				o.current_scope = scope
				o.current_level = scope.level
			}

			substituted := substitute_known_constants(o, decl.value)
			if substituted != nil {
				defer free(substituted, o.alloc)
				return evaluate_constant_expression(o, substituted)
			}

			return evaluate_constant_expression(o, decl.value)
		}
	}

	return {is_constant = false}
}

substitute_known_constants :: proc(o: ^Optimizer, expr: ^ast.Expr) -> ^ast.Expr {
	if expr == nil { return nil }

	#partial switch e in expr.derived {
	case ^ast.Ident:
		sym := find_symbol_in_scopes(o, e.name, o.current_scope)
		if sym != nil {
			if const_result, exists := o.const_prop_candidates[sym]; exists {
				return create_constant_literal(o, const_result, e.pos, e.end)
			}
		}
		return nil

	case ^ast.Binary_Expr:
		left_sub := substitute_known_constants(o, e.left)
		right_sub := substitute_known_constants(o, e.right)

		if left_sub != nil || right_sub != nil {
			new_left := left_sub if left_sub != nil else e.left
			new_right := right_sub if right_sub != nil else e.right

			return ast.create_binary_expr(
				new_left,
				e.op,
				new_right,
				e.pos,
				e.end,
				o.alloc,
			)
		}

	case ^ast.Unary_Expr:
		operand_sub := substitute_known_constants(o, e.expr)
		if operand_sub != nil {
			return ast.create_unary_expr(
				e.op,
				operand_sub,
				e.pos,
				e.end,
				o.alloc,
			)
		}

	case ^ast.Paren_Expr:
		expr_sub := substitute_known_constants(o, e.expr)
		if expr_sub != nil {
			return ast.create_paren_expr(
				expr_sub,
				e.pos,
				e.end,
				o.alloc,
			)
		}
	}

	return nil
}

convert_declarations_to_constants :: proc(o: ^Optimizer) -> int {
	if len(o.variables_to_convert) == 0 {
		return 0
	}

	converted_count := 0

	for sym in &o.variables_to_convert {
		if sym.decl_node != nil {
			#partial switch decl in sym.decl_node.derived {
			case ^ast.Value_Decl:
				decl.is_const = true
				sym.is_const = true

				converted_count += 1
			}
		}
	}

	return converted_count
}

replace_variables_with_constants :: proc(o: ^Optimizer) -> int {
	if len(o.variables_to_replace) == 0 {
		return 0
	}

	replaced_count := 0

	for file in o.files {
		replaced_count += replace_in_node(o, cast(^ast.Node)file)
	}

	return replaced_count
}

replace_in_node :: proc(o: ^Optimizer, node: ^ast.Node) -> int {
	if node == nil { return 0 }
	if o.visited_in_propagation[node] { return 0 }

	o.visited_in_propagation[node] = true
	defer delete_key(&o.visited_in_propagation, node)

	replaced := 0

	#partial switch n in node.derived {
	case ^ast.Ident:
		ident := n

		scope: ^checker.Scope
		if node_scope, exists := o.symbols.node_scopes[node.id]; exists {
			scope = node_scope
		} else {
			parent := o.node_parent[node]
			for parent != nil {
				if parent_scope, exists2 := o.symbols.node_scopes[parent.id]; exists2 {
					scope = parent_scope
					break
				}
				parent = o.node_parent[parent]
			}
		}

		if scope == nil {
			scope = o.current_scope
		}

		sym := find_symbol_in_scopes(o, ident.name, scope)

		if sym != nil {
			if const_result, exists := o.const_prop_candidates[sym]; exists {
				if _, should_replace := o.variables_to_replace[sym]; should_replace {
					new_lit := create_constant_literal(o, const_result, ident.pos, ident.end)
					if new_lit != nil {
						schedule_node_replacement(o, cast(^ast.Node)ident, cast(^ast.Node)new_lit,
							fmt.tprintf("constant propagation: %s = %v", ident.name, const_result.value),
							o.deep_analyzer.current_expression_context)

						replaced += 1
					}
				}
			}
		}

	case ^ast.Binary_Expr:
		replaced += replace_in_node(o, n.left)
		replaced += replace_in_node(o, n.right)

	case ^ast.Unary_Expr:
		replaced += replace_in_node(o, n.expr)

	case ^ast.Paren_Expr:
		replaced += replace_in_node(o, n.expr)

	case ^ast.Call_Expr:
		replaced += replace_in_node(o, n.expr)
		for arg in n.args {
			replaced += replace_in_node(o, arg.value)
		}

	case ^ast.Member_Access_Expr:
		replaced += replace_in_node(o, n.expr)
		if n.field != nil {
			replaced += replace_in_node(o, n.field)
		}

	case ^ast.Index_Expr:
		replaced += replace_in_node(o, n.expr)
		if n.index != nil {
			replaced += replace_in_node(o, n.index)
		}

	case ^ast.Field_Value:
		if n.field != nil {
			replaced += replace_in_node(o, n.field)
		}
		if n.value != nil {
			replaced += replace_in_node(o, n.value)
		}

	case ^ast.File:
		for decl in n.decls {
			replaced += replace_in_node(o, decl)
		}

	case ^ast.Block_Stmt:
		for stmt in n.stmts {
			replaced += replace_in_node(o, stmt)
		}

	case ^ast.Value_Decl:
		if n.value != nil {
			sym := find_symbol_in_scopes(o, n.name, o.current_scope)
			if sym != nil {
				if _, is_candidate := o.variables_to_replace[sym]; is_candidate {
					replaced += replace_in_node(o, n.value)
				} else {
					replaced += replace_in_node(o, n.value)
				}
			} else {
				replaced += replace_in_node(o, n.value)
			}
		}

	case ^ast.Assign_Stmt:
		if n.expr != nil {
			replaced += replace_in_node(o, n.expr)
		}

	case ^ast.Expr_Stmt:
		if n.expr != nil {
			replaced += replace_in_node(o, n.expr)
		}

	case ^ast.If_Stmt:
		if n.init != nil {
			replaced += replace_in_node(o, n.init)
		}
		if n.cond != nil {
			replaced += replace_in_node(o, n.cond)
		}
		if n.body != nil {
			replaced += replace_in_node(o, n.body)
		}
		if n.else_stmt != nil {
			replaced += replace_in_node(o, n.else_stmt)
		}

	case ^ast.For_Stmt:
		if n.init != nil {
			for ident in n.init {
				replaced += replace_in_node(o, cast(^ast.Node)ident)
			}
		}
		if n.cond != nil {
			replaced += replace_in_node(o, n.cond)
		}
		if n.second_cond != nil {
			replaced += replace_in_node(o, n.second_cond)
		}
		if n.post != nil {
			replaced += replace_in_node(o, n.post)
		}
		if n.body != nil {
			replaced += replace_in_node(o, n.body)
		}

	case ^ast.Return_Stmt:
		if n.result != nil {
			replaced += replace_in_node(o, n.result)
		}

	case ^ast.Defer_Stmt:
		if n.stmt != nil {
			replaced += replace_in_node(o, n.stmt)
		}

	case ^ast.Func_Stmt:
		for &anno in n.annotations {
			replaced += replace_in_node(o, &anno)
		}
		if n.params != nil {
			replaced += replace_in_node(o, n.params)
		}
		if n.body != nil {
			replaced += replace_in_node(o, n.body)
		}

	case ^ast.Event_Stmt:
		for &anno in n.annotations {
			replaced += replace_in_node(o, &anno)
		}
		if n.params != nil {
			replaced += replace_in_node(o, n.params)
		}
		if n.body != nil {
			replaced += replace_in_node(o, n.body)
		}

	case ^ast.Param_List:
		for param in n.list {
			replaced += replace_in_node(o, param)
		}

	case ^ast.Argument:
		if n.value != nil {
			replaced += replace_in_node(o, n.value)
		}

	case ^ast.Annotation:
		if n.value != nil {
			replaced += replace_in_node(o, n.value)
		}
	}

	return replaced
}

is_variable_modified :: proc(o: ^Optimizer, sym: ^checker.Symbol) -> bool {
	for file in o.files {
		if variable_is_modified_in_node(o, sym, cast(^ast.Node)file) {
			return true
		}
	}
	return false
}

variable_is_modified_in_node :: proc(o: ^Optimizer, sym: ^checker.Symbol, node: ^ast.Node) -> bool {
	if node == nil { return false }

	#partial switch n in node.derived {
	case ^ast.Assign_Stmt:
		assign := n
		if assign.name == sym.name {
			if assign != sym.decl_node {
				return true
			}
		}

	case ^ast.Value_Decl:
		decl := n
		if decl.name == sym.name && decl != sym.decl_node {
			return true
		}

	case ^ast.File:
		for decl in n.decls {
			if variable_is_modified_in_node(o, sym, decl) {
				return true
			}
		}

	case ^ast.Block_Stmt:
		for stmt in n.stmts {
			if variable_is_modified_in_node(o, sym, stmt) {
				return true
			}
		}

	case ^ast.If_Stmt:
		if n.init != nil && variable_is_modified_in_node(o, sym, n.init) {
			return true
		}
		if n.body != nil && variable_is_modified_in_node(o, sym, n.body) {
			return true
		}
		if n.else_stmt != nil && variable_is_modified_in_node(o, sym, n.else_stmt) {
			return true
		}

	case ^ast.For_Stmt:
		if n.init != nil {
			for ident in n.init {
				if ident.name == sym.name {
					return true
				}
			}
		}
		if n.body != nil && variable_is_modified_in_node(o, sym, n.body) {
			return true
		}

	case ^ast.Func_Stmt:
		if n.params != nil {
			for param in n.params.list {
				if param.name == sym.name {
					return true
				}
			}
		}
		if n.body != nil && variable_is_modified_in_node(o, sym, n.body) {
			return true
		}

	case ^ast.Event_Stmt:
		event := n

		if event.params != nil {
			for param in event.params.list {
				if param.name == sym.name {
					return true
				}
			}
		}

		if event.body != nil && variable_is_modified_in_node(o, sym, event.body) {
			return true
		}

	case ^ast.Member_Access_Expr:
		member := n
		if variable_is_modified_in_node(o, sym, member.expr) {
			return true
		}
		if member.field != nil && variable_is_modified_in_node(o, sym, member.field) {
			return true
		}

	case ^ast.Index_Expr:
		index := n
		if variable_is_modified_in_node(o, sym, index.expr) {
			return true
		}
		if index.index != nil && variable_is_modified_in_node(o, sym, index.index) {
			return true
		}

	case ^ast.Field_Value:
		field_val := n
		if field_val.field != nil && variable_is_modified_in_node(o, sym, field_val.field) {
			return true
		}
		if field_val.value != nil && variable_is_modified_in_node(o, sym, field_val.value) {
			return true
		}
	}

	return false
}

get_constant_value_from_symbol :: proc(o: ^Optimizer, sym: ^checker.Symbol) -> Constant_Result {
	if sym.decl_node == nil {
		return {is_constant = false}
	}

	#partial switch decl in sym.decl_node.derived {
	case ^ast.Value_Decl:
		if decl.value != nil {
			saved_scope := o.current_scope
			saved_level := o.current_level

			if scope, exists := o.symbols.node_scopes[sym.decl_node.id]; exists {
				o.current_scope = scope
				o.current_level = scope.level
			}

			result := evaluate_constant_expression(o, decl.value)

			o.current_scope = saved_scope
			o.current_level = saved_level

			return result
		}
	}

	return {is_constant = false}
}

run_constant_conversion_pass :: proc(o: ^Optimizer) -> int {

	find_constant_conversion_candidates(o)

	if len(o.variables_to_convert) == 0 {
		return 0
	}

	converted := convert_declarations_to_constants(o)

	replaced := 0
	if len(o.variables_to_replace) > 0 {
		replaced = replace_variables_with_constants(o)
		apply_deferred_operations(o)
	}

	clear(&o.const_prop_candidates)
	clear(&o.variables_to_convert)
	clear(&o.variables_to_replace)

	return converted
}

Declaration_Info :: struct {
	symbol:	        ^checker.Symbol,
	decl_node:	    ^ast.Value_Decl,
	original_scope: ^checker.Scope,
	usage_nodes:    [dynamic]^ast.Node,
	target_scope:   ^checker.Scope,
	can_move:	    bool,
	move_reason:    string,
}

collect_all_declarations :: proc(o: ^Optimizer) -> [dynamic]^Declaration_Info {
	declarations := make([dynamic]^Declaration_Info, o.alloc)

	for &scope in o.all_scopes {
		for &sym in scope.symbols {
			if sym.decl_node == nil { continue }

			#partial switch decl in sym.decl_node.derived {
			case ^ast.Value_Decl:
				info := new(Declaration_Info, o.alloc)
				info.symbol = sym
				info.decl_node = decl
				info.original_scope = scope
				info.usage_nodes = make([dynamic]^ast.Node, o.alloc)
				info.can_move = false

				append(&declarations, info)
			}
		}
	}

	return declarations
}

collect_usages_for_declaration :: proc(o: ^Optimizer, info: ^Declaration_Info) {
	sym := info.symbol

	collect_usages_in_node :: proc(o: ^Optimizer, node: ^ast.Node, sym: ^checker.Symbol, usages: ^[dynamic]^ast.Node) {
		if node == nil { return }

		saved_scope := o.current_scope
		saved_level := o.current_level

		scope: ^checker.Scope
		if node_scope, exists := o.symbols.node_scopes[node.id]; exists {
			scope = node_scope
		} else {
			parent := o.node_parent[node]
			for parent != nil {
				if parent_scope, exists2 := o.symbols.node_scopes[parent.id]; exists2 {
					scope = parent_scope
					break
				}
				parent = o.node_parent[parent]
			}
		}

		if scope != nil {
			o.current_scope = scope
		}

		#partial switch n in node.derived {
		case ^ast.Ident:
			ident := n
			if ident.name == sym.name {
				found_sym := find_symbol_in_scopes(o, ident.name, o.current_scope)
				if found_sym == sym && node != sym.decl_node {
					append(usages, node)
				}
			}

		case ^ast.Call_Expr:
			call := n
			if ident, is_ident := call.expr.derived.(^ast.Ident); is_ident && ident.name == sym.name {
				found_sym := find_symbol_in_scopes(o, ident.name, o.current_scope)
				if found_sym == sym {
					append(usages, ident)
				}
			}

			for arg in call.args {
				collect_usages_in_node(o, arg.value, sym, usages)
			}

		case ^ast.Binary_Expr:
			collect_usages_in_node(o, n.left, sym, usages)
			collect_usages_in_node(o, n.right, sym, usages)

		case ^ast.Unary_Expr:
			collect_usages_in_node(o, n.expr, sym, usages)

		case ^ast.Paren_Expr:
			collect_usages_in_node(o, n.expr, sym, usages)

		case ^ast.Member_Access_Expr:
			collect_usages_in_node(o, n.expr, sym, usages)
			if n.field != nil {
				collect_usages_in_node(o, n.field, sym, usages)
			}

		case ^ast.Index_Expr:
			collect_usages_in_node(o, n.expr, sym, usages)
			if n.index != nil {
				collect_usages_in_node(o, n.index, sym, usages)
			}

		case ^ast.Field_Value:
			if n.field != nil {
				collect_usages_in_node(o, n.field, sym, usages)
			}
			if n.value != nil {
				collect_usages_in_node(o, n.value, sym, usages)
			}

		case ^ast.Return_Stmt:
			if n.result != nil {
				collect_usages_in_node(o, n.result, sym, usages)
			}

		case ^ast.Assign_Stmt:
			if n.name == sym.name && node != sym.decl_node {
				found_sym := find_symbol_in_scopes(o, n.name, o.current_scope)
				if found_sym == sym {
					append(usages, node)
				}
			}
			if n.expr != nil {
				collect_usages_in_node(o, n.expr, sym, usages)
			}

		case ^ast.Value_Decl:
			if n.value != nil {
				collect_usages_in_node(o, n.value, sym, usages)
			}

		case ^ast.Expr_Stmt:
			if n.expr != nil {
				collect_usages_in_node(o, n.expr, sym, usages)
			}

		case ^ast.If_Stmt:
			if n.init != nil {
				collect_usages_in_node(o, n.init, sym, usages)
			}
			if n.cond != nil {
				collect_usages_in_node(o, n.cond, sym, usages)
			}
			if n.body != nil {
				collect_usages_in_node(o, n.body, sym, usages)
			}
			if n.else_stmt != nil {
				collect_usages_in_node(o, n.else_stmt, sym, usages)
			}

		case ^ast.For_Stmt:
			if n.init != nil {
				for ident in n.init {
					collect_usages_in_node(o, ident, sym, usages)
				}
			}
			if n.cond != nil {
				collect_usages_in_node(o, n.cond, sym, usages)
			}
			if n.second_cond != nil {
				collect_usages_in_node(o, n.second_cond, sym, usages)
			}
			if n.post != nil {
				collect_usages_in_node(o, n.post, sym, usages)
			}
			if n.body != nil {
				collect_usages_in_node(o, n.body, sym, usages)
			}

		case ^ast.Block_Stmt:
			for stmt in n.stmts {
				collect_usages_in_node(o, stmt, sym, usages)
			}

		case ^ast.Func_Stmt:
			if n.body != nil {
				collect_usages_in_node(o, n.body, sym, usages)
			}

		case ^ast.Event_Stmt:
			if n.body != nil {
				collect_usages_in_node(o, n.body, sym, usages)
			}

		case ^ast.File:
			for decl in n.decls {
				collect_usages_in_node(o, decl, sym, usages)
			}

		case ^ast.Argument:
			if n.value != nil {
				collect_usages_in_node(o, n.value, sym, usages)
			}

		case ^ast.Annotation:
			if n.value != nil {
				collect_usages_in_node(o, n.value, sym, usages)
			}
		}

		o.current_scope = saved_scope
		o.current_level = saved_level
	}

	for file in o.files {
		collect_usages_in_node(o, file, sym, &info.usage_nodes)
	}
}

find_lowest_common_ancestor_scope :: proc(scopes: []^checker.Scope, allocator := context.allocator) -> ^checker.Scope {
	if len(scopes) == 0 {
		return nil
	}
	if len(scopes) == 1 {
		return scopes[0]
	}

	paths := make([][dynamic]^checker.Scope, len(scopes))
	defer {
		for path in paths {
			delete(path)
		}
		delete(paths)
	}

	for scope, i in scopes {
		path := make([dynamic]^checker.Scope, allocator)
		current := scope
		for current != nil {
			append(&path, current)
			current = current.parent
		}

		slice.reverse(path[:])
		paths[i] = path
	}

	result: ^checker.Scope = nil
	min_len := max(int)
	for path in paths {
		if len(path) < min_len {
			min_len = len(path)
		}
	}

	for i := 0; i < min_len; i += 1 {
		current_scope := paths[0][i]
		all_match := true

		for j := 1; j < len(paths); j += 1 {
			if paths[j][i] != current_scope {
				all_match = false
				break
			}
		}

		if all_match {
			result = current_scope
		} else {
			break
		}
	}

	return result
}

is_scope_descendant_of :: proc(o: ^Optimizer, scope: ^checker.Scope, ancestor: ^checker.Scope) -> bool {
	current := scope
	for current != nil {
		if current == ancestor {
			return true
		}
		current = current.parent
	}
	return false
}

get_first_child_containing_usages :: proc(
	o: ^Optimizer,
	scope: ^checker.Scope,
	usage_scopes: []^checker.Scope,
) -> ^checker.Scope {
	for child in scope.children {
		all_in_child := true
		for usage_scope in usage_scopes {
			if !is_scope_descendant_of(o, usage_scope, child) {
				all_in_child = false
				break
			}
		}
		if all_in_child {
			return child
		}
	}
	return nil
}

would_cause_name_conflict :: proc(o: ^Optimizer, sym: ^checker.Symbol, target_scope: ^checker.Scope) -> bool {
	check_scope :: proc(scope: ^checker.Scope, name: string, ignore_sym: ^checker.Symbol) -> bool {
		for s in scope.symbols {
			if s.name == name && s != ignore_sym {
				return true
			}
		}
		return false
	}

	if check_scope(target_scope, sym.name, sym) {
		return true
	}

	current := target_scope.parent
	for current != nil {
		if check_scope(current, sym.name, sym) {
			return true
		}
		current = current.parent
	}

	return false
}

is_modified_outside_scope :: proc(o: ^Optimizer, sym: ^checker.Symbol, target_scope: ^checker.Scope) -> bool {
	for file in o.files {
		if is_modified_in_node_outside_scope(o, sym, cast(^ast.Node)file, target_scope) {
			return true
		}
	}
	return false
}

is_modified_in_node_outside_scope :: proc(
	o: ^Optimizer,
	sym: ^checker.Symbol,
	node: ^ast.Node,
	target_scope: ^checker.Scope,
) -> bool {
	if node == nil { return false }

	saved_scope := o.current_scope
	saved_level := o.current_level

	scope: ^checker.Scope
	if node_scope, exists := o.symbols.node_scopes[node.id]; exists {
		scope = node_scope
	} else {
		parent := o.node_parent[node]
		for parent != nil {
			if parent_scope, exists2 := o.symbols.node_scopes[parent.id]; exists2 {
				scope = parent_scope
				break
			}
			parent = o.node_parent[parent]
		}
	}

	if scope != nil {
		o.current_scope = scope
	}

	result := false

	#partial switch n in node.derived {
	case ^ast.Assign_Stmt:
		if n.name == sym.name && node != sym.decl_node {
			node_scope, exists := o.symbols.node_scopes[node.id]
			if exists && !is_scope_descendant_of(o, node_scope, target_scope) {
				result = true
			}
		}

		if !result && n.expr != nil {
			result = is_modified_in_node_outside_scope(o, sym, n.expr, target_scope)
		}

	case ^ast.Value_Decl:
		if n.name == sym.name && node != sym.decl_node {
			node_scope, exists := o.symbols.node_scopes[node.id]
			if exists && !is_scope_descendant_of(o, node_scope, target_scope) {
				result = true
			}
		}
		if !result && n.value != nil {
			result = is_modified_in_node_outside_scope(o, sym, n.value, target_scope)
		}

	case ^ast.Call_Expr:
		if ident, is_ident := n.expr.derived.(^ast.Ident); is_ident {
			func_sym := find_symbol_in_scopes(o, ident.name, o.current_scope)
			if func_sym != nil && function_has_side_effects(o, func_sym) {
				node_scope, exists := o.symbols.node_scopes[node.id]
				if exists && !is_scope_descendant_of(o, node_scope, target_scope) {
					result = true
				}
			}
		}

		if !result {
			for arg in n.args {
				if is_modified_in_node_outside_scope(o, sym, arg.value, target_scope) {
					result = true
					break
				}
			}
		}

	case ^ast.File:
		for decl in n.decls {
			if is_modified_in_node_outside_scope(o, sym, decl, target_scope) {
				result = true
				break
			}
		}

	case ^ast.Block_Stmt:
		for stmt in n.stmts {
			if is_modified_in_node_outside_scope(o, sym, stmt, target_scope) {
				result = true
				break
			}
		}

	case ^ast.If_Stmt:
		if n.init != nil && is_modified_in_node_outside_scope(o, sym, n.init, target_scope) {
			result = true
		}
		if !result && n.cond != nil && is_modified_in_node_outside_scope(o, sym, n.cond, target_scope) {
			result = true
		}
		if !result && n.body != nil && is_modified_in_node_outside_scope(o, sym, n.body, target_scope) {
			result = true
		}
		if !result && n.else_stmt != nil && is_modified_in_node_outside_scope(o, sym, n.else_stmt, target_scope) {
			result = true
		}

	case ^ast.For_Stmt:
		if n.init != nil {
			for ident in n.init {
				if is_modified_in_node_outside_scope(o, sym, ident, target_scope) {
					result = true
					break
				}
			}
		}
		if !result && n.cond != nil && is_modified_in_node_outside_scope(o, sym, n.cond, target_scope) {
			result = true
		}
		if !result && n.second_cond != nil && is_modified_in_node_outside_scope(o, sym, n.second_cond, target_scope) {
			result = true
		}
		if !result && n.post != nil && is_modified_in_node_outside_scope(o, sym, n.post, target_scope) {
			result = true
		}
		if !result && n.body != nil && is_modified_in_node_outside_scope(o, sym, n.body, target_scope) {
			result = true
		}

	case ^ast.Func_Stmt:
		if n.body != nil {
			result = is_modified_in_node_outside_scope(o, sym, n.body, target_scope)
		}

	case ^ast.Event_Stmt:
		if n.body != nil {
			result = is_modified_in_node_outside_scope(o, sym, n.body, target_scope)
		}

	case ^ast.Binary_Expr:
		result = is_modified_in_node_outside_scope(o, sym, n.left, target_scope) ||
				 is_modified_in_node_outside_scope(o, sym, n.right, target_scope)

	case ^ast.Unary_Expr:
		result = is_modified_in_node_outside_scope(o, sym, n.expr, target_scope)

	case ^ast.Paren_Expr:
		result = is_modified_in_node_outside_scope(o, sym, n.expr, target_scope)

	case ^ast.Member_Access_Expr:
		result = is_modified_in_node_outside_scope(o, sym, n.expr, target_scope)

	case ^ast.Index_Expr:
		result = is_modified_in_node_outside_scope(o, sym, n.expr, target_scope) ||
				 is_modified_in_node_outside_scope(o, sym, n.index, target_scope)

	case ^ast.Return_Stmt:
		if n.result != nil {
			result = is_modified_in_node_outside_scope(o, sym, n.result, target_scope)
		}

	case ^ast.Expr_Stmt:
		if n.expr != nil {
			result = is_modified_in_node_outside_scope(o, sym, n.expr, target_scope)
		}

	case ^ast.Defer_Stmt:
		if n.stmt != nil {
			result = is_modified_in_node_outside_scope(o, sym, n.stmt, target_scope)
		}
	}

	o.current_scope = saved_scope
	o.current_level = saved_level
	return result
}

find_optimal_target_scope :: proc(o: ^Optimizer, info: ^Declaration_Info) -> ^checker.Scope {
	if len(info.usage_nodes) == 0 {
		return info.original_scope
	}

	usage_scopes := make([dynamic]^checker.Scope, o.alloc)
	defer delete(usage_scopes)

	for &node in info.usage_nodes {
		scope := find_scope_for_node(o, node)

		if scope != nil {
			is_decl_node := node == info.symbol.decl_node

			if is_decl_node {
				usage_count_in_scope := 0
				for &other_node in info.usage_nodes {
					if other_node != node {
						other_scope := find_scope_for_node(o, other_node)
						if other_scope == scope {
							usage_count_in_scope += 1
						}
					}
				}

				if usage_count_in_scope == 0 {
					continue
				}
			}

			found := false
			for &s in usage_scopes {
				if s == scope {
					found = true
					break
				}
			}
			if !found {
				append(&usage_scopes, scope)
			}
		} else {
			fmt.printfln("	Node at %v has no scope!", node.pos)
			//TODO ensure
		}
	}

	if len(usage_scopes) == 0 {
		return info.original_scope
	}

	all_scopes := make([dynamic]^checker.Scope, o.alloc)
	defer delete(all_scopes)

	for scope in usage_scopes {
		append(&all_scopes, scope)
	}

	lca := find_lowest_common_ancestor_scope(all_scopes[:], o.alloc)
	if lca == nil {
		return info.original_scope
	}

	target := lca
	current := lca

	for current != nil && current != info.original_scope {
		all_usages_in_subtree := true

		for usage_scope in usage_scopes {
			if !is_scope_descendant_of(o, usage_scope, current) {
				all_usages_in_subtree = false
				break
			}
		}

		if all_usages_in_subtree {
			current_node := find_node_for_scope(o, current)
			if current_node != nil && is_conditionally_executed(o, current_node) {
				break
			}

			target = current
			next_child := get_first_child_containing_usages(o, current, usage_scopes[:])
			if next_child != nil {
				child_node := find_node_for_scope(o, next_child)
				if child_node != nil && !is_conditionally_executed(o, child_node) {
					current = next_child
				} else {
					break
				}
			} else {
				break
			}
		} else {
			break
		}
	}

	if target == info.original_scope {
		return info.original_scope
	}

	target_node := find_node_for_scope(o, target)
	if target_node != nil && is_conditionally_executed(o, target_node) {
		return info.original_scope
	}

	if would_cause_name_conflict(o, info.symbol, target) {
		info.move_reason = "would cause name conflict"
		return info.original_scope
	}

	if is_modified_outside_scope(o, info.symbol, target) {
		info.move_reason = "modified outside target scope"
		return info.original_scope
	}

	return target
}

find_scope_for_node :: proc(o: ^Optimizer, node: ^ast.Node) -> ^checker.Scope {
	if scope, exists := o.symbols.node_scopes[node.id]; exists {
		return scope
	}

	current := node
	for current != nil {
		parent, exists := o.node_parent[current]
		if !exists || parent == nil {
			break
		}

		if scope, exists2 := o.symbols.node_scopes[parent.id]; exists2 {
			return scope
		}

		current = parent
	}

	return o.current_scope
}

is_conditionally_executed :: proc(o: ^Optimizer, node: ^ast.Node) -> bool {
	current := node
	for current != nil {
		parent, exists := o.node_parent[current]
		if !exists { break }

		#partial switch p in parent.derived {
		case ^ast.If_Stmt:
			if p.body == current || p.else_stmt == current {
				return true
			}

		case ^ast.For_Stmt:
			if p.body == current {
				if p.cond != nil {
					cond_result := evaluate_constant_expression(o, p.cond)
					if !cond_result.is_constant ||
					   (cond_result.is_constant && cond_result.type_kind == .Boolean) {
						if bool_val, ok := cond_result.value.(bool); ok && !bool_val {
							return true
						}
						return true
					}
				} else {
					return false
				}
			}

		case ^ast.Func_Stmt, ^ast.Event_Stmt:
			return false
		}

		current = parent
	}

	return false
}

can_move_declaration :: proc(o: ^Optimizer, info: ^Declaration_Info) -> bool {
	sym := info.symbol

	if is_symbol_public(sym) {
		info.move_reason = "public symbol"
		return false
	}

	if flags_field, has := sym.metadata["flags"]; has {
		if flags, ok := flags_field.(checker.Flags); ok {
			if .BUILTIN in flags || .NATIVE in flags {
				info.move_reason = "builtin/native symbol"
				return false
			}
		}
	}

	if sym.is_const {
		info.move_reason = "constant"
		return false
	}

	count, exists := o.symbol_usage_count[sym]
	if !exists || count == 0 {
		info.move_reason = "no usages"
		return false
	}

	info.target_scope = find_optimal_target_scope(o, info)

	if info.target_scope == info.original_scope {
		info.move_reason = "already optimal"
		return false
	}

	target_node := find_node_for_scope(o, info.target_scope)
	if target_node != nil && is_conditionally_executed(o, target_node) {
		info.move_reason = "target is conditionally executed"
		return false
	}

	if info.symbol.decl_node != nil && is_conditionally_executed(o, info.symbol.decl_node) {
		info.move_reason = "declaration in conditional block - cannot move out"
		return false
	}

	has_usage_in_conditional := false
	for usage_node in info.usage_nodes {
		if is_conditionally_executed(o, usage_node) {
			has_usage_in_conditional = true
			break
		}
	}

	if has_usage_in_conditional && !is_conditionally_executed(o, find_node_for_scope(o, info.target_scope)) {
		info.move_reason = "some usages are conditional but target is not"
		return false
	}

	info.can_move = true
	info.move_reason = "can move"
	return true
}

find_node_for_scope :: proc(o: ^Optimizer, scope: ^checker.Scope) -> ^ast.Node {
	if node, exists := o.scope_to_node[scope]; exists {
		return node
	}

	for file in o.files {
		if found := find_node_for_scope_in_file(o, file, scope); found != nil {
			return found
		}
	}

	return nil
}

find_node_for_scope_in_file :: proc(o: ^Optimizer, node: ^ast.Node, target_scope: ^checker.Scope) -> ^ast.Node {
	if node == nil { return nil }

	if scope, exists := o.symbols.node_scopes[node.id]; exists && scope == target_scope {
		return node
	}

	#partial switch n in node.derived {
	case ^ast.File:
		for decl in n.decls {
			if found := find_node_for_scope_in_file(o, decl, target_scope); found != nil {
				return found
			}
		}

	case ^ast.Block_Stmt:
		for stmt in n.stmts {
			if found := find_node_for_scope_in_file(o, stmt, target_scope); found != nil {
				return found
			}
		}

	case ^ast.If_Stmt:
		if n.body != nil {
			if found := find_node_for_scope_in_file(o, n.body, target_scope); found != nil {
				return found
			}
		}
		if n.else_stmt != nil {
			if found := find_node_for_scope_in_file(o, n.else_stmt, target_scope); found != nil {
				return found
			}
		}

	case ^ast.For_Stmt:
		if n.body != nil {
			if found := find_node_for_scope_in_file(o, n.body, target_scope); found != nil {
				return found
			}
		}

	case ^ast.Func_Stmt, ^ast.Event_Stmt:
		if scope, exists := o.symbols.node_scopes[node.id]; exists && scope == target_scope {
			return node
		}
	}

	return nil
}

find_block_for_scope :: proc(o: ^Optimizer, scope: ^checker.Scope) -> ^ast.Block_Stmt {
	if node, exists := o.scope_to_node[scope]; exists {
		if block, ok := node.derived.(^ast.Block_Stmt); ok {
			return block
		}
	}
	return nil
}

find_insertion_point_in_block :: proc(o: ^Optimizer, block: ^ast.Block_Stmt, scope: ^checker.Scope) -> int {
	if len(block.stmts) == 0 {
		return 0
	}

	for stmt, i in block.stmts {
		#partial switch s in stmt.derived {
		case ^ast.Value_Decl:
			continue
		case:
			return i
		}
	}

	return len(block.stmts)
}

schedule_declaration_move :: proc(o: ^Optimizer, info: ^Declaration_Info) -> bool {
	if !info.can_move || info.target_scope == nil {
		return false
	}

	target_block := find_block_for_scope(o, info.target_scope)
	if target_block == nil {
		return false
	}

	insert_pos := find_insertion_point_in_block(o, target_block, info.target_scope)

	schedule_node_move(o,
		cast(^ast.Node)info.decl_node,
		cast(^ast.Node)target_block,
		insert_pos,
		nil,
		fmt.tprintf("move declaration '%s' from scope %d to scope %d",
			info.symbol.name, info.original_scope.id, info.target_scope.id),
		nil,
	)

	return true
}

// print_declaration_move_stats :: proc(o: ^Optimizer, declarations: [dynamic]^Declaration_Info) {
// 	moved_count := 0
// 	cannot_move_count := 0
// 	reason_stats := make(map[string]int, o.alloc)
// 	defer delete(reason_stats)

// 	for info in declarations {
// 		if info.can_move {
// 			moved_count += 1
// 		} else {
// 			cannot_move_count += 1
// 			reason_stats[info.move_reason] += 1
// 		}
// 	}

// 	fmt.printfln("\n=== Declaration Move Statistics ===")
// 	fmt.printfln("Total declarations analyzed: %d", len(declarations))
// 	fmt.printfln("Can move: %d", moved_count)
// 	fmt.printfln("Cannot move: %d", cannot_move_count)

// 	if cannot_move_count > 0 {
// 		fmt.println("\nReasons cannot move:")
// 		for reason, count in reason_stats {
// 			fmt.printfln("  %s: %d", reason, count)
// 		}
// 	}
// }

move_declarations_down_pass :: proc(o: ^Optimizer) {
	declarations := collect_all_declarations(o)
	defer {
		for info in declarations {
			delete(info.usage_nodes)
			free(info, o.alloc)
		}
		delete(declarations)
	}


	for info in declarations {
		collect_usages_for_declaration(o, info)
	}

	moves_scheduled := 0
	for info in declarations {
		if can_move_declaration(o, info) {
			if schedule_declaration_move(o, info) {
				moves_scheduled += 1
			}
		}
	}

	// print_declaration_move_stats(o, declarations)
}

remove_unreachable_code_pass :: proc(o: ^Optimizer) {
	unreachable_groups := make([dynamic]UnreachableGroup, o.alloc)
	defer delete(unreachable_groups)

	for file in o.files {
		o.current_file = file

		#partial switch n in file.derived {
		case ^ast.File:
			for decl in n.decls {
				find_unreachable_groups_in_stmt(o, decl, &unreachable_groups)
			}
		}
	}

	removed_count := 0
	for group in unreachable_groups {
		if len(group.statements) == 0 { continue }

		first := group.statements[0]
		last := group.statements[len(group.statements)-1]

		error.add_warning(
			o.ec,
			o.current_file,
			fmt.tprintf("unreachable code after %s in function '%s' (%d statement(s))",
				group.reason, group.function_name, len(group.statements)),
			first.pos,
			last.end,
		)

		for stmt in group.statements {
			schedule_node_removal(o, cast(^ast.Node)stmt,
				fmt.tprintf("unreachable code after %s", group.reason),
				o.deep_analyzer.current_expression_context)
			removed_count += 1
		}
	}

	if removed_count > 0 {
		log.infof("Marked %d unreachable statement(s) for removal in %d group(s)", removed_count, len(unreachable_groups))
	}
}

UnreachableGroup :: struct {
	statements:    [dynamic]^ast.Stmt,
	reason:        string,
	function_name: string,
	start_pos:     lexer.Pos,
}

find_unreachable_groups_in_stmt :: proc(o: ^Optimizer, stmt: ^ast.Stmt, groups: ^[dynamic]UnreachableGroup) {
	if stmt == nil { return }

	#partial switch s in stmt.derived {
	case ^ast.Func_Stmt:
		if s.body != nil {
			find_unreachable_groups_in_block(o, s.body, s.name, groups)
		}

	case ^ast.Event_Stmt:
		if s.body != nil {
			find_unreachable_groups_in_block(o, s.body, s.name, groups)
		}

	case ^ast.Block_Stmt:
		find_unreachable_groups_in_block(o, s, "anonymous block", groups)
	}
}

find_unreachable_groups_in_block :: proc(o: ^Optimizer, block: ^ast.Block_Stmt, function_name: string, groups: ^[dynamic]UnreachableGroup) {
	if block == nil { return }

	i := 0
	for i < len(block.stmts) {
		stmt := block.stmts[i]

		#partial switch s in stmt.derived {
		case ^ast.Return_Stmt:
			if i+1 < len(block.stmts) {
				group := UnreachableGroup{
					statements = make([dynamic]^ast.Stmt, o.alloc),
					reason = "return",
					function_name = function_name,
					start_pos = block.stmts[i+1].pos,
				}

				for j := i + 1; j < len(block.stmts); j += 1 {
					append(&group.statements, block.stmts[j])
				}

				append(groups, group)
				return
			}

		case ^ast.If_Stmt:
			if s.body != nil {
				find_unreachable_groups_in_block(o, s.body, function_name, groups)
			}
			if s.else_stmt != nil {
				if else_block, ok := s.else_stmt.derived.(^ast.Block_Stmt); ok {
					find_unreachable_groups_in_block(o, else_block, function_name, groups)
				}
			}

			then_returns := does_block_end_with_return(o, s.body)
			else_returns := does_else_end_with_return(o, s.else_stmt)

			if then_returns && else_returns && i+1 < len(block.stmts) {
				group := UnreachableGroup{
					statements = make([dynamic]^ast.Stmt, o.alloc),
					reason = "if with returns in all branches",
					function_name = function_name,
					start_pos = block.stmts[i+1].pos,
				}

				for j := i + 1; j < len(block.stmts); j += 1 {
					append(&group.statements, block.stmts[j])
				}

				append(groups, group)
				return
			}

		case ^ast.For_Stmt:
			always_executes := false
			if s.cond != nil {
				cond_result := evaluate_constant_expression(o, s.cond)
				if cond_result.is_constant && cond_result.type_kind == .Boolean {
					if bool_val, ok := cond_result.value.(bool); ok && bool_val {
						always_executes = true
					}
				}
			} else {
				always_executes = true
			}

			if always_executes && does_block_contain_return(o, s.body) && i+1 < len(block.stmts) {
				group := UnreachableGroup{
					statements = make([dynamic]^ast.Stmt, o.alloc),
					reason = "loop with guaranteed return",
					function_name = function_name,
					start_pos = block.stmts[i+1].pos,
				}

				for j := i + 1; j < len(block.stmts); j += 1 {
					append(&group.statements, block.stmts[j])
				}

				append(groups, group)
				return
			}

			if s.body != nil {
				find_unreachable_groups_in_block(o, s.body, function_name, groups)
			}

		case ^ast.Block_Stmt:
			find_unreachable_groups_in_block(o, s, function_name, groups)
		}

		i += 1
	}
}

does_block_end_with_return :: proc(o: ^Optimizer, block: ^ast.Block_Stmt) -> bool {
	if block == nil || len(block.stmts) == 0 {
		return false
	}

	last := block.stmts[len(block.stmts)-1]

	#partial switch s in last.derived {
	case ^ast.Return_Stmt:
		return true
	case ^ast.If_Stmt:
		then_returns := does_block_end_with_return(o, s.body)
		else_returns := does_else_end_with_return(o, s.else_stmt)
		return then_returns && else_returns
	case ^ast.Block_Stmt:
		return does_block_end_with_return(o, s)
	}

	return false
}

does_else_end_with_return :: proc(o: ^Optimizer, else_stmt: ^ast.Stmt) -> bool {
	if else_stmt == nil { return false }

	#partial switch s in else_stmt.derived {
	case ^ast.Return_Stmt:
		return true
	case ^ast.Block_Stmt:
		return does_block_end_with_return(o, s)
	case ^ast.If_Stmt:
		then_returns := does_block_end_with_return(o, s.body)
		else_returns := does_else_end_with_return(o, s.else_stmt)
		return then_returns && else_returns
	}

	return false
}

does_block_contain_return :: proc(o: ^Optimizer, block: ^ast.Block_Stmt) -> bool {
	if block == nil { return false }

	for stmt in block.stmts {
		#partial switch s in stmt.derived {
		case ^ast.Return_Stmt:
			return true
		case ^ast.If_Stmt:
			if does_block_contain_return(o, s.body) {
				return true
			}
			if s.else_stmt != nil {
				if else_block, ok := s.else_stmt.derived.(^ast.Block_Stmt); ok {
					if does_block_contain_return(o, else_block) {
						return true
					}
				}
			}
		case ^ast.Block_Stmt:
			if does_block_contain_return(o, s) {
				return true
			}
		}
	}

	return false
}

Pass :: struct {
	name:                 string,
	run:                  proc(o: ^Optimizer),
	needs_usage_analysis: bool,
	needs_deep_analysis:  bool,
	needs_flow_analysis:  bool,
}

get_passes :: proc(allocator := context.allocator) -> [dynamic]Pass {
	passes := make([dynamic]Pass, allocator)

	append(&passes, Pass{
		name = "remove_anonymous",
		run = proc(o: ^Optimizer) {
			remove_anonymous_assignments(o)
		},
	})

	append(&passes, Pass{
		name = "constant_conversion",
		run = proc(o: ^Optimizer) {
			run_constant_conversion_pass(o)
		},
		needs_usage_analysis = true,
	})

	append(&passes, Pass{
		name = "constant_optimization",
		run = proc(o: ^Optimizer) {
			optimize_constant_expressions(o)
		},
	})

	append(&passes, Pass{
		name = "dead_code_elimination",
		run = proc(o: ^Optimizer) {
			for file in o.files {
				for stmt in file.decls {
					remove_constant_conditions(o, stmt)
				}
			}
		},
	})

	append(&passes, Pass{
		name = "reorder_operands",
		run = proc(o: ^Optimizer) {
			reordered := 0
			for file in o.files {
				reordered += reorder_operands_in_file(o, file)
			}
			if reordered > 0 {
				log.infof("Reordered %d expressions", reordered)
			}
		},
	})

	append(&passes, Pass{
		name = "deep_analysis",
		run = proc(o: ^Optimizer) {
			deep_analyze(o)
		},
		needs_usage_analysis = true,
	})

	append(&passes, Pass{
		name = "flow_analysis",
		run = proc(o: ^Optimizer) {
			analyze_flow_dependencies(o)
		},
	})

	append(&passes, Pass{
		name = "move_declarations_down",
		run = proc(o: ^Optimizer) {
			move_declarations_down_pass(o)
		},
		needs_usage_analysis = true,
	})

	append(&passes, Pass{
		name = "remove_unreachable_code",
		run = proc(o: ^Optimizer) {
			remove_unreachable_code_pass(o)
		},
		needs_usage_analysis = true,
	})

	append(&passes, Pass{
		name = "remove_unused",
		run = proc(o: ^Optimizer) {
			remove_unused(o)
		},
		needs_usage_analysis = true,
	})

	append(&passes, Pass{
		name = "remove_empty_blocks",
		run = proc(o: ^Optimizer) {
			remove_empty_blocks(o)
		},
	})

	append(&passes, Pass{
		name = "flatten_blocks",
		run = proc(o: ^Optimizer) {
			flatten_nested_blocks(o)
		},
	})

	return passes
}

PassManager :: struct {
	optimizer: ^Optimizer,
	passes:    [dynamic]Pass,
	stats:     map[string]int,
	allocator: mem.Allocator,
}

run_all_passes :: proc(o: ^Optimizer) {
	passes := get_passes(o.alloc)
	defer delete(passes)

	log.info("=== Starting Optimization Passes ===")

	for pass, i in passes {
		pass_start := time.now()

		log.infof("[Pass %d/%d] Running: %s", i+1, len(passes), pass.name)

		if pass.needs_usage_analysis {
			count_all_symbol_usage(o)
		}

		pass.run(o)
		apply_deferred_operations(o)

		pass_time := time.duration_milliseconds(time.since(pass_start))
		log.infof("[Pass %d/%d] Completed: %s (%.2f ms)", i+1, len(passes), pass.name, pass_time)
	}

	log.infof("=== All Optimization Passes Completed ===")
}

optimizer_optimize :: proc(o: ^Optimizer, files: [dynamic]^ast.File, symbols: ^checker.Symbol_Table) {
	o.files = files
	o.symbols = symbols
	o.current_scope = symbols.global_scope
	o.current_level = 0

	analyze_usage(o)

	run_all_passes(o)

	// for file in files {
	// 	ast.print_tree(file)
	// }
}
