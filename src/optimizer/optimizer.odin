package optimizer

import "core:mem"
import "core:fmt"
import "core:strconv"
import "core:strings"
import "core:math"

import "../ast"
import "../checker"
import "../error"
import "../lexer"

Optimizer :: struct {
	alloc:		mem.Allocator,
	files:		[dynamic]^ast.File,
	symbols:	  ^checker.Symbol_Table,
	current_file: ^ast.File,
	ec: ^error.Collector,

	scope_symbols_usage: map[^checker.Scope]map[string]bool,
	all_scopes:		  [dynamic]^checker.Scope,
	current_scope:	   ^checker.Scope,
	current_level:	   int,

	node_parent: map[^ast.Node]^ast.Node,

	symbol_deps:		map[^checker.Symbol][dynamic]^checker.Symbol,
	reverse_deps:	   map[^checker.Symbol][dynamic]^checker.Symbol,
	symbol_by_name_in_scope: map[^checker.Scope]map[string]^checker.Symbol,

	preserved_symbols:  map[^checker.Symbol]bool,
	unused_warnings:	map[^checker.Symbol]bool,

	walker:		^ast.Walker,
	walker_vtable: ast.Visitor_VTable,

	constant_cache: map[^ast.Node]Constant_Result,

	anonymous_vars: map[string]bool,

	inlined_symbols:   map[^checker.Symbol]bool,
	symbol_usage_count: map[^checker.Symbol]int,
	symbols_to_inline: [dynamic]^checker.Symbol,

	func_calls:		  map[^checker.Symbol][dynamic]^ast.Call_Expr,
	call_to_func:		map[^ast.Call_Expr]^checker.Symbol,
}

EPSILON :: 1e-12

Constant_Value :: union {
	bool,
	i64,
	f64,
	string,
}

Constant_Result :: struct {
	value:   Constant_Value,
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
	o.symbols_to_inline = make([dynamic]^checker.Symbol, allocator)
	o.anonymous_vars = make(map[string]bool, allocator)
	o.func_calls = make(map[^checker.Symbol][dynamic]^ast.Call_Expr, allocator)
	o.call_to_func = make(map[^ast.Call_Expr]^checker.Symbol, allocator)

	o.walker_vtable = ast.Visitor_VTable{
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

	o.walker = new(ast.Walker, allocator)
	ast.walker_init(o.walker, &o.walker_vtable, allocator)
	o.walker.user_data = o
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
	for file in o.files {
		count_symbol_usage_in_file(o, file)
	}

	for sym, count in &o.symbol_usage_count {
		if can_inline_symbol(o, sym) {
			append(&o.symbols_to_inline, sym)
		}
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
		} else if (expr.op.kind == .Add || expr.op.kind == .Sub || expr.op.kind == .Mul || expr.op.kind == .Quo) &&
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

		sym := find_symbol_in_scopes(o, ident.name, o.current_scope)
		if sym != nil && sym.type.kind == .Function {
			if flags_field, has := sym.metadata["flags"]; has {
				if flags, ok := flags_field.(checker.Flags); ok && .PURE in flags {
					all_args_constant := true
					for arg in call.args {
						arg_result := evaluate_constant_expression(o, arg.value)
						if !arg_result.is_constant {
							all_args_constant = false
							break
						}
					}

					if all_args_constant {
						// TODO
						result.is_constant = true
						result.type_kind = .Any
					}
				}
			}
		}
	}

	return result
}

replace_constant_factory_calls :: proc(o: ^Optimizer, file: ^ast.File) -> int {
	replaced_count := 0

	traverse_and_replace :: proc(o: ^Optimizer, node: ^ast.Node, replaced_count: ^int) {
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
									decl.value = new_lit
									replaced_count^ += 1
								}
							}
						}
					}
				case ^ast.Binary_Expr:
					binary := expr
					traverse_and_replace(o, binary.left, replaced_count)
					traverse_and_replace(o, binary.right, replaced_count)
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
									stmt.expr = new_lit
									replaced_count^ += 1
								}
							}
						}
					}
				}
			}

		case ^ast.Block_Stmt:
			block := n
			for stmt in block.stmts {
				traverse_and_replace(o, stmt, replaced_count)
			}

		case ^ast.If_Stmt:
			if_stmt := n
			if if_stmt.body != nil {
				traverse_and_replace(o, if_stmt.body, replaced_count)
			}
			if if_stmt.else_stmt != nil {
				traverse_and_replace(o, if_stmt.else_stmt, replaced_count)
			}

		case ^ast.For_Stmt:
			for_stmt := n
			if for_stmt.body != nil {
				traverse_and_replace(o, for_stmt.body, replaced_count)
			}

		case ^ast.Func_Stmt:
			func_stmt := n
			if func_stmt.body != nil {
				traverse_and_replace(o, func_stmt.body, replaced_count)
			}

		case ^ast.Event_Stmt:
			event_stmt := n
			if event_stmt.body != nil {
				traverse_and_replace(o, event_stmt.body, replaced_count)
			}
		}
	}

	traverse_and_replace(o, file, &replaced_count)

	if replaced_count > 0 {
		fmt.printfln("[DEBUG] Replaced %d constant factory call(s)", replaced_count)
	}

	return replaced_count
}

try_optimize_expression :: proc(o: ^Optimizer, expr: ^ast.Expr, parent: ^ast.Node) -> (bool, Constant_Result) {
	result := evaluate_constant_expression(o, expr)

	if result.is_constant && parent != nil {
		new_lit := create_constant_literal(o, result, expr.pos, expr.end)

		if new_lit != nil {
			#partial switch p in parent.derived {
			case ^ast.Binary_Expr:
				if p.left == expr {
					p.left = new_lit
					o.node_parent[new_lit] = parent
					return true, result
				} else if p.right == expr {
					p.right = new_lit
					o.node_parent[new_lit] = parent
					return true, result
				}
			case ^ast.Value_Decl:
				p.value = new_lit
				o.node_parent[new_lit] = parent
				return true, result
			case ^ast.Expr_Stmt:
				p.expr = new_lit
				o.node_parent[new_lit] = parent
				return true, result
			case ^ast.Assign_Stmt:
				p.expr = new_lit
				o.node_parent[new_lit] = parent
				return true, result
			case ^ast.Return_Stmt:
				p.result = new_lit
				o.node_parent[new_lit] = parent
				return true, result
			case ^ast.If_Stmt:
				p.cond = new_lit
				o.node_parent[new_lit] = parent
				return true, result
			case ^ast.For_Stmt:
				p.cond = new_lit
				o.node_parent[new_lit] = parent
				return true, result
			case ^ast.Unary_Expr:
				p.expr = new_lit
				o.node_parent[new_lit] = parent
				return true, result
			case ^ast.Call_Expr:
				for i in 0..<len(p.args) {
					if p.args[i].value == expr {
						p.args[i].value = new_lit
						o.node_parent[new_lit] = parent
						return true, result
					}
				}
			case ^ast.Paren_Expr:
				p.expr = new_lit
				o.node_parent[new_lit] = parent
				return true, result
			}
		}
	}

	return false, result
}

simplify_constant_subexpressions :: proc(o: ^Optimizer, expr: ^ast.Expr) -> bool {
	if expr == nil {
		return false
	}

	changed := false

	#partial switch node in expr.derived {
	case ^ast.Binary_Expr:
		changed = simplify_constant_subexpressions(o, node.left) || changed
		changed = simplify_constant_subexpressions(o, node.right) || changed

		if ok, result := try_optimize_expression(o, expr, nil); ok {
			changed = true
		}

	case ^ast.Unary_Expr:
		changed = simplify_constant_subexpressions(o, node.expr)

		if ok, result := try_optimize_expression(o, expr, nil); ok {
			changed = true
		}

	case ^ast.Paren_Expr:
		changed = simplify_constant_subexpressions(o, node.expr)

		if _, is_lit := node.expr.derived.(^ast.Basic_Lit); is_lit {
			if parent, exists := o.node_parent[expr]; exists {
				#partial switch p in parent.derived {
				case ^ast.Binary_Expr:
					if p.left == expr {
						p.left = node.expr
						changed = true
					} else if p.right == expr {
						p.right = node.expr
						changed = true
					}
				}
			}
		}

	case ^ast.Call_Expr:
		changed = simplify_constant_subexpressions(o, node.expr)
		for arg in node.args {
			changed = simplify_constant_subexpressions(o, arg.value) || changed
		}
	}

	return changed
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
					parent_block := find_parent_block(o, cast(^ast.Node)stmt)
					if parent_block == nil {
						return 0
					}

					if_index := -1
					for i in 0..<len(parent_block.stmts) {
						if cast(uintptr)parent_block.stmts[i] == cast(uintptr)stmt {
							if_index = i
							break
						}
					}
					if if_index == -1 {
						return 0
					}

					if bool_val {
						if if_stmt.body != nil {
							if if_stmt.else_stmt != nil {
								removed_count += remove_block(o, if_stmt.else_stmt)
								if_stmt.else_stmt = nil
							}

							new_block := ast.new(ast.Block_Stmt, if_stmt.pos, if_stmt.end, o.alloc)

							body_stmts: []^ast.Stmt
							if body_block, is_block := if_stmt.body.derived.(^ast.Block_Stmt); is_block {
								body_stmts = body_block.stmts
								body_block.stmts = nil
							} else {
								body_stmts = make([]^ast.Stmt, 1, o.alloc)
								body_stmts[0] = if_stmt.body
								if_stmt.body = nil
							}

							new_block.stmts = make([]^ast.Stmt, len(body_stmts), o.alloc)
							copy(new_block.stmts[:], body_stmts[:])

							for stmt2 in new_block.stmts {
								o.node_parent[stmt2] = cast(^ast.Node)new_block
							}
							o.node_parent[new_block] = cast(^ast.Node)parent_block

							parent_block.stmts[if_index] = new_block

							delete_key(&o.node_parent, stmt)
							if if_stmt.body != nil {
								delete_key(&o.node_parent, if_stmt.body)
							}

							removed_count += 1
						}
					} else {
						if if_stmt.else_stmt != nil {
							new_block := ast.new(ast.Block_Stmt, if_stmt.pos, if_stmt.end, o.alloc)

							else_stmts: []^ast.Stmt
							if else_block, is_block := if_stmt.else_stmt.derived.(^ast.Block_Stmt); is_block {
								else_stmts = else_block.stmts
								else_block.stmts = nil
							} else {
								else_stmts = make([]^ast.Stmt, 1, o.alloc)
								else_stmts[0] = if_stmt.else_stmt
								if_stmt.else_stmt = nil
							}

							new_block.stmts = make([]^ast.Stmt, len(else_stmts), o.alloc)
							copy(new_block.stmts[:], else_stmts[:])

							for stmt2 in new_block.stmts {
								o.node_parent[stmt2] = cast(^ast.Node)new_block
							}
							o.node_parent[new_block] = cast(^ast.Node)parent_block

							parent_block.stmts[if_index] = new_block
						} else {
							new_stmts := make([dynamic]^ast.Stmt, len(parent_block.stmts)-1, o.alloc)
							copy(new_stmts[:if_index], parent_block.stmts[:if_index])
							copy(new_stmts[if_index:], parent_block.stmts[if_index+1:])
							parent_block.stmts = new_stmts[:]
						}

						if if_stmt.body != nil {
							removed_count += remove_block(o, if_stmt.body)
							delete_key(&o.node_parent, if_stmt.body)
						}

						delete_key(&o.node_parent, stmt)
						if if_stmt.else_stmt != nil {
							delete_key(&o.node_parent, if_stmt.else_stmt)
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
					if block := find_parent_block(o, cast(^ast.Node)stmt); block != nil {
						for i in 0..<len(block.stmts) {
							if cast(uintptr)block.stmts[i] == cast(uintptr)stmt {
								if for_stmt.body != nil {
									removed_count += remove_block(o, for_stmt.body)
									for_stmt.body = nil
								}

								new_stmts := make([dynamic]^ast.Stmt, len(block.stmts)-1, o.alloc)
								copy(new_stmts[:i], block.stmts[:i])
								copy(new_stmts[i:], block.stmts[i+1:])
								block.stmts = new_stmts[:]

								delete_key(&o.node_parent, stmt)
								if for_stmt.body != nil {
									delete_key(&o.node_parent, for_stmt.body)
								}

								removed_count += 1
								break
							}
						}
					}
				}
			}
		}
	}

	return removed_count
}

remove_block :: proc(o: ^Optimizer, block: ^ast.Block_Stmt) -> int {
	if block == nil {
		return 0
	}

	removed_count := 0

	parent, exists := o.node_parent[block]
	if !exists {
		return 0
	}

	#partial switch p in parent.derived {
	case ^ast.File:
		file := p
		for i := 0; i < len(file.decls); i += 1 {
			if cast(uintptr)file.decls[i] == cast(uintptr)block {
				ordered_remove(&file.decls, i)
				delete_key(&o.node_parent, block)
				removed_count += 1
				break
			}
		}

	case ^ast.Block_Stmt:
		parent_block := p
		for i in 0..<len(parent_block.stmts) {
			if cast(uintptr)parent_block.stmts[i] == cast(uintptr)block {
				new_stmts := make([]^ast.Stmt, len(parent_block.stmts)-1, o.alloc)
				copy(new_stmts[:i], parent_block.stmts[:i])
				copy(new_stmts[i:], parent_block.stmts[i+1:])
				parent_block.stmts = new_stmts
				delete_key(&o.node_parent, block)
				removed_count += 1
				break
			}
		}

	case ^ast.If_Stmt:
		if_stmt := p
		if if_stmt.body == block {
			if_stmt.body = nil
			delete_key(&o.node_parent, block)
			removed_count += 1
		} else if if_stmt.else_stmt == block {
			if_stmt.else_stmt = nil
			delete_key(&o.node_parent, block)
			removed_count += 1
		}

	case ^ast.For_Stmt:
		for_stmt := p
		if for_stmt.body == block {
			for_stmt.body = nil
			delete_key(&o.node_parent, block)
			removed_count += 1
		}

	case ^ast.Func_Stmt:
		func_stmt := p
		if func_stmt.body == block {
			func_stmt.body = nil
			delete_key(&o.node_parent, block)
			removed_count += 1
		}

	case ^ast.Event_Stmt:
		event_stmt := p
		if event_stmt.body == block {
			event_stmt.body = nil
			delete_key(&o.node_parent, block)
			removed_count += 1
		}
	}

	for stmt in block.stmts {
		delete_key(&o.node_parent, stmt)
	}

	return removed_count
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
				replace_expr_in_parent(o, parent, expr, final_expr)
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

replace_expr_in_parent :: proc(o: ^Optimizer, parent: ^ast.Node, old_expr, new_expr: ^ast.Expr) -> bool {
	if parent == nil || old_expr == nil || new_expr == nil {
		return false
	}

	#partial switch p in parent.derived {
	case ^ast.Binary_Expr:
		binary := p
		if binary.left == old_expr {
			binary.left = new_expr
			o.node_parent[new_expr] = parent
			return true
		} else if binary.right == old_expr {
			binary.right = new_expr
			o.node_parent[new_expr] = parent
			return true
		}
	case ^ast.Value_Decl:
		decl := p
		if decl.value == old_expr {
			decl.value = new_expr
			o.node_parent[new_expr] = parent
			return true
		}
	case ^ast.Expr_Stmt:
		stmt := p
		if stmt.expr == old_expr {
			stmt.expr = new_expr
			o.node_parent[new_expr] = parent
			return true
		}
	case ^ast.Assign_Stmt:
		assign := p
		if assign.expr == old_expr {
			assign.expr = new_expr
			o.node_parent[new_expr] = parent
			return true
		}
	case ^ast.Return_Stmt:
		ret := p
		if ret.result == old_expr {
			ret.result = new_expr
			o.node_parent[new_expr] = parent
			return true
		}
	case ^ast.Unary_Expr:
		unary := p
		if unary.expr == old_expr {
			unary.expr = new_expr
			o.node_parent[new_expr] = parent
			return true
		}
	case ^ast.Call_Expr:
		call := p
		for i in 0..<len(call.args) {
			if call.args[i].value == old_expr {
				call.args[i].value = new_expr
				o.node_parent[new_expr] = parent
				return true
			}
		}
	case ^ast.Paren_Expr:
		paren := p
		if paren.expr == old_expr {
			paren.expr = new_expr
			o.node_parent[new_expr] = parent
			return true
		}
	}

	return false
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

	if optimized_count > 0 {
		fmt.printfln("[DEBUG] Optimized %d constant expression(s)", optimized_count)
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

	if removed_count > 0 {
		fmt.printfln("[DEBUG] Removed %d empty block(s)", removed_count)
	}

	return removed_count
}

remove_empty_blocks_in_file :: proc(o: ^Optimizer, file: ^ast.File) -> int {
	removed_count := 0

	nodes_to_process := make([dynamic]^ast.Node, o.alloc)
	defer delete(nodes_to_process)

	collect_function_calls(o)

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
							remove_node_from_parent(o, parent)
							removed_count += 1
						}
					}

					delete_key(&o.func_calls, sym)
				}
			}
		}
	}

	return removed_count
}

flatten_nested_blocks :: proc(o: ^Optimizer) -> int {
	flattened_count := 0

	for file in o.files {
		flattened_count += flatten_blocks_in_file(o, file)
	}

	if flattened_count > 0 {
		fmt.printfln("[DEBUG] Flattened %d nested block(s)", flattened_count)
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
		ast.walk_file(o.walker, file)
	}

	build_dependency_graph(o)

	mark_used_symbols(o)
}

remove_unused :: proc(o: ^Optimizer) -> int {
	check_for_unused_symbols(o)

	removed := remove_unused_symbols(o)

	if removed > 0 {
		fmt.printfln("[DEBUG] Removed %d unused symbol(s)", removed)
	}

	return removed
}

remove_anonymous_assignments :: proc(o: ^Optimizer) -> int {
	removed_count := 0

	for file in o.files {
		o.current_file = file
		removed_count += remove_anonymous_assignments_from_node(o, cast(^ast.Node)file)
	}

	if removed_count > 0 {
		fmt.printfln("[DEBUG] Removed %d anonymous assignment(s)", removed_count)
	}

	return removed_count
}

remove_anonymous_assignments_from_node :: proc(o: ^Optimizer, node: ^ast.Node) -> int {
	if node == nil { return 0 }

	removed_count := 0

	#partial switch n in node.derived {
	case ^ast.File:
		file := n
		i := 0
		for i < len(file.decls) {
			stmt := file.decls[i]

			removed_count += remove_anonymous_assignments_from_node(o, stmt)

			should_remove := false
			#partial switch s in stmt.derived {
			case ^ast.Value_Decl:
				decl := s
				if decl.name == "_" && decl.value != nil {
					should_remove = true
				}
			case ^ast.Assign_Stmt:
				assign := s
				if assign.name == "_" && assign.expr != nil {
					should_remove = true
				}
			}

			if should_remove {
				new_decls := make([dynamic]^ast.Stmt, len(file.decls)-1, o.alloc)
				copy(new_decls[:], file.decls[:i])
				copy(new_decls[i:], file.decls[i+1:])
				file.decls = new_decls

				delete_key(&o.node_parent, stmt)
				removed_count += 1
				continue
			}

			i += 1
		}

	case ^ast.Block_Stmt:
		block := n
		i := 0
		for i < len(block.stmts) {
			stmt := block.stmts[i]

			removed_count += remove_anonymous_assignments_from_node(o, stmt)

			should_remove := false
			#partial switch s in stmt.derived {
			case ^ast.Value_Decl:
				decl := s
				if decl.name == "_" && decl.value != nil {
					should_remove = true
				}
			case ^ast.Assign_Stmt:
				assign := s
				if assign.name == "_" && assign.expr != nil {
					should_remove = true
				}
			}

			if should_remove {
				new_stmts := make([dynamic]^ast.Stmt, len(block.stmts)-1, o.alloc)
				copy(new_stmts[:], block.stmts[:i])
				copy(new_stmts[i:], block.stmts[i+1:])
				block.stmts = new_stmts[:]

				delete_key(&o.node_parent, stmt)
				removed_count += 1
				continue
			}

			i += 1
		}

	case ^ast.If_Stmt:
		if_stmt := n

		if if_stmt.init != nil {
			removed_count += remove_anonymous_assignments_from_node(o, if_stmt.init)
		}

		if if_stmt.body != nil {
			removed_count += remove_anonymous_assignments_from_node(o, if_stmt.body)
		}

		if if_stmt.else_stmt != nil {
			removed_count += remove_anonymous_assignments_from_node(o, if_stmt.else_stmt)
		}

	case ^ast.For_Stmt:
		for_stmt := n
		if for_stmt.body != nil {
			removed_count += remove_anonymous_assignments_from_node(o, for_stmt.body)
		}

	case ^ast.Func_Stmt:
		func_stmt := n

		if func_stmt.body != nil {
			saved_scope := o.current_scope
			saved_level := o.current_level

			if scope, exists := o.symbols.node_scopes[func_stmt.body.id]; exists {
				o.current_scope = scope
				o.current_level = scope.level
			}

			removed_count += remove_anonymous_assignments_from_node(o, func_stmt.body)

			o.current_scope = saved_scope
			o.current_level = saved_level
		}

	case ^ast.Event_Stmt:
		event_stmt := n
		if event_stmt.body != nil {
			saved_scope := o.current_scope
			saved_level := o.current_level

			if scope, exists := o.symbols.node_scopes[event_stmt.body.id]; exists {
				o.current_scope = scope
				o.current_level = scope.level
			}

			removed_count += remove_anonymous_assignments_from_node(o, event_stmt.body)

			o.current_scope = saved_scope
			o.current_level = saved_level
		}

	case ^ast.Value_Decl:
		decl := n
		if decl.value != nil {
			removed_count += remove_anonymous_assignments_from_node(o, decl.value)
		}

	case ^ast.Expr_Stmt:
		expr_stmt := n
		if expr_stmt.expr != nil {
			removed_count += remove_anonymous_assignments_from_node(o, expr_stmt.expr)
		}

	case ^ast.Assign_Stmt:
		assign := n
		if assign.expr != nil {
			removed_count += remove_anonymous_assignments_from_node(o, assign.expr)
		}

	case ^ast.Return_Stmt:
		ret := n
		if ret.result != nil {
			removed_count += remove_anonymous_assignments_from_node(o, ret.result)
		}

	case ^ast.Call_Expr:
		call := n
		for arg in call.args {
			removed_count += remove_anonymous_assignments_from_node(o, arg.value)
		}

	case ^ast.Binary_Expr:
		binary := n
		removed_count += remove_anonymous_assignments_from_node(o, binary.left)
		removed_count += remove_anonymous_assignments_from_node(o, binary.right)

	case ^ast.Unary_Expr:
		unary := n
		removed_count += remove_anonymous_assignments_from_node(o, unary.expr)

	case ^ast.Paren_Expr:
		paren := n
		removed_count += remove_anonymous_assignments_from_node(o, paren.expr)
	}

	return removed_count
}

optimizer_optimize :: proc(o: ^Optimizer, files: [dynamic]^ast.File, symbols: ^checker.Symbol_Table) {
	o.files = files
	o.symbols = symbols

	o.current_scope = symbols.global_scope
	o.current_level = 0

	analyze_usage(o)

	count_all_symbol_usage(o)

	remove_anonymous_assignments(o)

	optimize_constant_expressions(o)

	count_all_symbol_usage(o)

	remove_unused(o)

	remove_empty_blocks(o)
	flatten_nested_blocks(o)
}
