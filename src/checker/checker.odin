package checker

import "core:mem"
import "core:fmt"

import "../ast"
import "../../assets"

Scope :: struct {
	id:      int,
	symbols: map[string]^Symbol,
	parent: ^Scope,
	level: int,
	children: [dynamic]^Scope,
	file: string,
}

Symbol :: struct {
	name: string,
	type: Symbol_Type,
	is_const: bool,
	decl_node: ^ast.Node,
	scope_level: int,
	file: string,
}

Symbol_Type :: string

Checker :: struct {
	alloc: mem.Allocator,
	symbol_table: Symbol_Table,
	files: map[string]^ast.File,
	errs: [dynamic]Checker_Error,
	current_file: ^ast.File,
}

Symbol_Table :: struct {
	global_scope: ^Scope,
	current_scope: ^Scope,
	scope_level: int,
}

Checker_Error :: struct {
	message: string,
}

checker_init :: proc(c: ^Checker, allocator := context.allocator) {
	c.alloc = allocator
	c.errs = make([dynamic]Checker_Error, allocator)
	c.files = make(map[string]^ast.File, 0, allocator)
	c.symbol_table.scope_level = -1
}

checker_check :: proc(c: ^Checker, files: [dynamic]^ast.File) -> (Symbol_Table, [dynamic]Checker_Error) {
	enter_scope(c)
	c.symbol_table.global_scope.file = "global"

	for file in files {
		c.files[file.fullpath] = file
		c.current_file = file
		for decl in file.decls {
			if is_global_declaration(decl) {
				extract_declaration(c, decl)
			}
		}
	}

	for file in files {
		c.current_file = file
		for decl in file.decls {
			if !is_global_declaration(decl) {
				extract_declaration(c, decl)
			}
		}
		for decl in file.decls {
			check_declaration(c, decl)
		}
	}

	exit_scope(c)
	return c.symbol_table, c.errs
}

is_global_declaration :: proc(decl: ^ast.Stmt) -> bool {
	#partial switch d in decl.derived {
	case ^ast.Value_Decl:
		return true
	case ^ast.Func_Stmt:
		return true
	case ^ast.Event_Stmt:
		return true
	case:
		return false
	}
}

extract_declaration :: proc(c: ^Checker, decl: ^ast.Stmt) {
	#partial switch s in decl.derived {
	case ^ast.Value_Decl:
		extract_value_decl(c, s)

	case ^ast.Func_Stmt:
		extract_func_decl(c, s)

	case ^ast.Event_Stmt:
		extract_event_decl(c, s)

	case ^ast.Block_Stmt:
		enter_scope(c)
		c.symbol_table.current_scope.file = c.current_file.fullpath
		for stmt in s.stmts {
			extract_declaration(c, stmt)
		}
		exit_scope(c)

	case ^ast.If_Stmt:
		enter_scope(c)
		c.symbol_table.current_scope.file = c.current_file.fullpath
		extract_stmt_list(c, s.body.stmts)
		exit_scope(c)

	case ^ast.For_Stmt:
		extract_for_stmt(c, s)

	case ^ast.Return_Stmt, ^ast.Assign_Stmt, ^ast.Expr_Stmt, ^ast.Defer_Stmt:
		break

	case:
		fmt.printfln("Unsupported %v", s)
	}
}

check_declaration :: proc(c: ^Checker, decl: ^ast.Stmt) {
	#partial switch s in decl.derived {
	case ^ast.Value_Decl:
		check_value_decl(c, s)

	case ^ast.Func_Stmt:
		check_func_decl(c, s)

	case ^ast.Event_Stmt:
		check_event_decl(c, s)

	case ^ast.Block_Stmt:
		enter_scope(c)
		c.symbol_table.current_scope.file = c.current_file.fullpath
		for stmt in s.stmts {
			check_declaration(c, stmt)
		}
		exit_scope(c)

	case ^ast.If_Stmt:
		enter_scope(c)
		c.symbol_table.current_scope.file = c.current_file.fullpath
		check_stmt_list(c, s.body.stmts)
		exit_scope(c)

	case ^ast.For_Stmt:
		check_for_stmt(c, s)

	case ^ast.Return_Stmt:
		check_return_stmt(c, s)

	case ^ast.Assign_Stmt:
		check_assign_stmt(c, s)

	case ^ast.Expr_Stmt:
		check_expr_stmt(c, s)

	case ^ast.Defer_Stmt:
		check_defer_stmt(c, s)

	case:
		fmt.printfln("Unsupported %v", s)
	}
}

extract_value_decl :: proc(c: ^Checker, decl: ^ast.Value_Decl) {
	if symbol := lookup_in_current_scope(c, decl.name); symbol != nil {
		add_error(c, fmt.tprintf("'%s' already presented", decl.name))
		return
	}

	symbol := new(Symbol, c.alloc)
	symbol.name = decl.name
	symbol.type = decl.type
	symbol.is_const = decl.is_const
	symbol.decl_node = decl
	symbol.scope_level = c.symbol_table.scope_level
	symbol.file = c.current_file.fullpath

	add_symbol(c, symbol)
}

check_value_decl :: proc(c: ^Checker, decl: ^ast.Value_Decl) {
	//todo
}

extract_func_decl :: proc(c: ^Checker, func: ^ast.Func_Stmt) {
	if symbol := lookup_in_current_scope(c, func.name); symbol != nil {
		add_error(c, fmt.tprintf("function '%s' is already declared", func.name))
		return
	}

	symbol := new(Symbol, c.alloc)
	symbol.name = func.name
	symbol.type = "function"
	symbol.decl_node = func
	symbol.scope_level = c.symbol_table.scope_level
	symbol.file = c.current_file.fullpath

	add_symbol(c, symbol)
	enter_scope(c)
	c.symbol_table.current_scope.file = c.current_file.fullpath

	for param in func.params.list {
		param_symbol := new(Symbol, c.alloc)
		param_symbol.name = param.name
		param_symbol.type = param.type
		param_symbol.scope_level = c.symbol_table.scope_level
		param_symbol.file = c.current_file.fullpath
		add_symbol(c, param_symbol)
	}

	extract_stmt_list(c, func.body.stmts)
	exit_scope(c)
}

check_func_decl :: proc(c: ^Checker, func: ^ast.Func_Stmt) {
	enter_scope(c)
	c.symbol_table.current_scope.file = c.current_file.fullpath

	for param in func.params.list {
		param_symbol := new(Symbol, c.alloc)
		param_symbol.name = param.name
		param_symbol.type = param.type
		param_symbol.scope_level = c.symbol_table.scope_level
		param_symbol.file = c.current_file.fullpath
		add_symbol(c, param_symbol)
	}

	check_stmt_list(c, func.body.stmts)
	exit_scope(c)
}

extract_event_decl :: proc(c: ^Checker, event: ^ast.Event_Stmt) {
	// if symbol := lookup_in_current_scope(c, event.name); symbol != nil {
	// 	add_error(c, fmt.tprintf("Event '%s' is already used", event.name))
	// 	return
	// }

	_, is_valid := assets.event_native_from_mapped(event.name)
	if !is_valid {
		add_error(c, fmt.tprintf("Invalid event name: '%s'", event.name))
		return
	}

	symbol := new(Symbol, c.alloc)
	symbol.name = event.name
	symbol.type = "event"
	symbol.decl_node = event
	symbol.scope_level = c.symbol_table.scope_level
	symbol.file = c.current_file.fullpath
	add_symbol(c, symbol)

	enter_scope(c)
	c.symbol_table.current_scope.file = c.current_file.fullpath

	for param in event.params.list {
		param_symbol := new(Symbol, c.alloc)
		param_symbol.name = param.name
		param_symbol.type = param.type
		param_symbol.scope_level = c.symbol_table.scope_level
		param_symbol.file = c.current_file.fullpath

		add_symbol(c, param_symbol)
	}

	extract_stmt_list(c, event.body.stmts)
	exit_scope(c)
}

check_event_decl :: proc(c: ^Checker, event: ^ast.Event_Stmt) {
	enter_scope(c)
	c.symbol_table.current_scope.file = c.current_file.fullpath

	for param in event.params.list {
		param_symbol := new(Symbol, c.alloc)
		param_symbol.name = param.name
		param_symbol.type = param.type
		param_symbol.scope_level = c.symbol_table.scope_level
		param_symbol.file = c.current_file.fullpath

		add_symbol(c, param_symbol)
	}

	check_stmt_list(c, event.body.stmts)
	exit_scope(c)
}

extract_for_stmt :: proc(c: ^Checker, for_stmt: ^ast.For_Stmt) {
	enter_scope(c)
	c.symbol_table.current_scope.file = c.current_file.fullpath

	if for_stmt.init != nil {
		for init in for_stmt.init {
			if ident, ok := init.derived.(^ast.Ident); ok {
				iter_symbol := new(Symbol, c.alloc)
				iter_symbol.name = ident.name
				iter_symbol.type = "int"
				iter_symbol.scope_level = c.symbol_table.scope_level
				iter_symbol.file = c.current_file.fullpath

				add_symbol(c, iter_symbol)
			}
		}
	}

	extract_stmt_list(c, for_stmt.body.stmts)
	exit_scope(c)
}

check_for_stmt :: proc(c: ^Checker, for_stmt: ^ast.For_Stmt) {
	enter_scope(c)
	c.symbol_table.current_scope.file = c.current_file.fullpath

	if for_stmt.init != nil {
		for init in for_stmt.init {
			if ident, ok := init.derived.(^ast.Ident); ok {
				iter_symbol := new(Symbol, c.alloc)
				iter_symbol.name = ident.name
				iter_symbol.type = "int"
				iter_symbol.scope_level = c.symbol_table.scope_level
				iter_symbol.file = c.current_file.fullpath

				add_symbol(c, iter_symbol)
			}
		}
	}

	check_stmt_list(c, for_stmt.body.stmts)
	exit_scope(c)
}

extract_stmt_list :: proc(c: ^Checker, stmts: []^ast.Stmt) {
	for stmt in stmts {
		extract_declaration(c, stmt)
	}
}

check_stmt_list :: proc(c: ^Checker, stmts: []^ast.Stmt) {
	for stmt in stmts {
		check_declaration(c, stmt)
	}
}

check_return_stmt :: proc(c: ^Checker, stmt: ^ast.Return_Stmt) {
	//todo
}

check_assign_stmt :: proc(c: ^Checker, stmt: ^ast.Assign_Stmt) {
	//todo
}

check_expr_stmt :: proc(c: ^Checker, stmt: ^ast.Expr_Stmt) {
	//todo
}

check_defer_stmt :: proc(c: ^Checker, stmt: ^ast.Defer_Stmt) {
	//todo
}

add_symbol :: proc(c: ^Checker, symbol: ^Symbol) {
	if c.symbol_table.current_scope == nil {
		return
	}
	c.symbol_table.current_scope.symbols[symbol.name] = symbol
}

lookup_in_current_scope :: proc(c: ^Checker, name: string) -> ^Symbol {
	if c.symbol_table.current_scope == nil {
		return nil
	}
	return c.symbol_table.current_scope.symbols[name]
}

lookup_symbol :: proc(c: ^Checker, name: string) -> ^Symbol {
	scope := c.symbol_table.current_scope
	for scope != nil {
		if symbol := scope.symbols[name]; symbol != nil {
			return symbol
		}
		scope = scope.parent
	}
	return nil
}

enter_scope :: proc(c: ^Checker) {
	new_scope := new(Scope, c.alloc)
	new_scope.symbols = make(map[string]^Symbol, c.alloc)
	new_scope.parent = c.symbol_table.current_scope
	new_scope.level = c.symbol_table.scope_level + 1
	new_scope.children = make([dynamic]^Scope, 0, c.alloc)
	new_scope.file = c.current_file.fullpath if c.current_file != nil else "unknown"

	if c.symbol_table.current_scope == nil {
		c.symbol_table.global_scope = new_scope
	} else {
		append(&c.symbol_table.current_scope.children, new_scope)
	}

	c.symbol_table.current_scope = new_scope
	c.symbol_table.scope_level += 1
}

exit_scope :: proc(c: ^Checker) {
	if c.symbol_table.current_scope != nil {
		c.symbol_table.current_scope = c.symbol_table.current_scope.parent
		c.symbol_table.scope_level -= 1
	}
}

add_error :: proc(c: ^Checker, message: string) {
	file_name: string
	if c.current_file != nil {
		file_name = c.current_file.fullpath
	} else {
		file_name = "unknown"
	}
	err := Checker_Error{message=fmt.tprintf("%s: %s", file_name, message)}
	append(&c.errs, err)
}
