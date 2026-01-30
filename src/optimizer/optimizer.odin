package optimizer

import "core:mem"
import "core:fmt"

import "../ast"
import "../checker"
import "../error"

Optimizer :: struct {
	alloc:		mem.Allocator,
	files:		[dynamic]^ast.File,
	symbols:	  ^checker.Symbol_Table,
	current_file: ^ast.File,
	pass:		 int,
	errs:		 [dynamic]error.Error,

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
}

optimizer_init :: proc(o: ^Optimizer, allocator := context.allocator) {
	o.alloc = allocator
	o.errs = make([dynamic]error.Error, o.alloc)
	o.scope_symbols_usage = make(map[^checker.Scope]map[string]bool, allocator)
	o.all_scopes = make([dynamic]^checker.Scope, allocator)

	o.node_parent = make(map[^ast.Node]^ast.Node, allocator)
	o.symbol_by_name_in_scope = make(map[^checker.Scope]map[string]^checker.Symbol, allocator)
	o.symbol_deps = make(map[^checker.Symbol][dynamic]^checker.Symbol, allocator)
	o.reverse_deps = make(map[^checker.Symbol][dynamic]^checker.Symbol, allocator)
	o.preserved_symbols = make(map[^checker.Symbol]bool, allocator)
	o.unused_warnings = make(map[^checker.Symbol]bool, allocator)

	o.walker_vtable = ast.Visitor_VTable{
		visit_ident = _visit_ident,
		visit_call_expr = _visit_call_expr,
		visit_func_stmt = _visit_func_stmt,
		visit_event_stmt = _visit_event_stmt,
		visit_value_decl = _visit_value_decl,
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

	#partial switch t in node.derived {
	case ^ast.Block_Stmt,
		 ^ast.Func_Stmt,
		 ^ast.Event_Stmt,
		 ^ast.Defer_Stmt:

		if scope, exists := o.symbols.node_scopes[node.id]; exists && scope.parent != nil {
			o.current_scope = scope.parent
			o.current_level = scope.parent.level
		}
	}
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

find_parent_file :: proc(o: ^Optimizer, node: ^ast.Node) -> ^ast.File {
	current := node
	for current != nil {
		parent, exists := o.node_parent[current]
		if !exists { break }

		if file, is_file := parent.derived.(^ast.File); is_file {
			return file
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
					append(&o.errs, error.Error{
						file = o.current_file,
						cause_pos = sym.decl_node.pos,
						cause_end = sym.decl_node.end,
						message = fmt.tprintf("unused symbol '%s'", sym.name),
						severity = .Warning,
					})
				}
			}
		}
	}
}

remove_unused_symbols :: proc(o: ^Optimizer) -> int {
	removed_count := 0

	for &scope in o.all_scopes {
		i := 0
		for i < len(scope.symbols) {
			sym := scope.symbols[i]

			should_keep := false

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
				ordered_remove(&scope.symbols, i)
				removed_count += 1

				if sym.decl_node != nil {
					remove_node_from_parent(o, sym.decl_node)
				}

				if deps, exists := o.symbol_deps[sym]; exists {
					delete_key(&o.symbol_deps, sym)
				}
				if rev_deps, exists := o.reverse_deps[sym]; exists {
					delete_key(&o.reverse_deps, sym)
				}
			} else {
				i += 1
			}
		}
	}

	return removed_count
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
		fmt.printfln("[INFO] Removed %d unused symbol(s)", removed)
	}

	return removed
}

optimizer_optimize :: proc(o: ^Optimizer, files: [dynamic]^ast.File, symbols: ^checker.Symbol_Table) -> [dynamic]error.Error {
	o.files = files
	o.symbols = symbols
	o.pass += 1

	o.current_scope = symbols.global_scope
	o.current_level = 0

	analyze_usage(o)

	remove_unused(o)

	return o.errs
}
