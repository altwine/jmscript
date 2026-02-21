package checker

import "core:mem"
import "core:slice"
import "core:strings"
import "core:fmt"

import "../ast"
import "../error"
import "../../assets"

Symbol_Table :: struct {
	global_scope:  ^Scope,
	current_scope: ^Scope,
	scope_level:   int,
	node_scopes:   map[int]^Scope,
}

Checker :: struct {
	alloc:			  mem.Allocator,
	symbol_table:	  ^Symbol_Table,
	files:			  [dynamic]^ast.File,
	ec:  ^error.Collector,
	current_file:	  ^ast.File,
	current_file_idx: int,

	collector_walker:	 ^ast.Walker,
	type_checker_walker: ^ast.Walker,

	collector_vtable:	 ast.Visitor_VTable,
	type_checker_vtable: ast.Visitor_VTable,
}

checker_init :: proc(c: ^Checker, ec: ^error.Collector, allocator := context.allocator) {
	c.alloc = allocator
	c.ec = ec
	c.symbol_table = new(Symbol_Table, allocator)
	c.symbol_table.scope_level = -1
	c.symbol_table.node_scopes = make(map[int]^Scope, 0, allocator)

	c.collector_vtable = ast.Visitor_VTable{}
	c.type_checker_vtable = ast.Visitor_VTable{}

	c.collector_vtable.visit_func_stmt = _collect_visit_func_stmt
	c.collector_vtable.visit_event_stmt = _collect_visit_event_stmt
	c.collector_vtable.visit_value_decl = _collect_visit_value_decl
	c.collector_vtable.before_visit_child = _collect_before_visit_child
	c.collector_vtable.after_visit_child = _collect_after_visit_child

	c.type_checker_vtable.visit_func_stmt = _type_check_visit_func_stmt
	c.type_checker_vtable.visit_event_stmt = _type_check_visit_event_stmt
	c.type_checker_vtable.visit_value_decl = _type_check_visit_value_decl
	c.type_checker_vtable.visit_assign_stmt = _type_check_visit_assign_stmt
	c.type_checker_vtable.visit_ident = _type_check_visit_ident
	c.type_checker_vtable.visit_call_expr = _type_check_visit_call_expr
	c.type_checker_vtable.visit_binary_expr = _type_check_visit_binary_expr
	c.type_checker_vtable.before_visit_node = _type_check_before_visit_node
	c.type_checker_vtable.before_visit_child = _type_check_before_visit_child
	c.type_checker_vtable.after_visit_child = _type_check_after_visit_child

	c.collector_walker = new(ast.Walker, allocator)
	c.type_checker_walker = new(ast.Walker, allocator)

	ast.walker_init(c.collector_walker, &c.collector_vtable, allocator)
	ast.walker_init(c.type_checker_walker, &c.type_checker_vtable, allocator)

	c.collector_walker.user_data = c
	c.type_checker_walker.user_data = c
}

@(private="file")
get_node_annotations :: proc(node: ^ast.Node) -> (annotations: [dynamic]ast.Annotation, ok: bool) {
	if node == nil {
		return {}, false
	}

	#partial switch n in node.derived {
	case ^ast.Func_Stmt:
		return n.annotations, true
	case ^ast.Event_Stmt:
		return n.annotations, true
	case ^ast.Value_Decl:
		return n.annotations, true
	case ^ast.Assign_Stmt:
		return n.annotations, true
	case ^ast.Expr_Stmt:
		return n.annotations, true
	case ^ast.If_Stmt:
		return n.annotations, true
	case ^ast.For_Stmt:
		return n.annotations, true
	case ^ast.Return_Stmt:
		return n.annotations, true
	case ^ast.Defer_Stmt:
		return n.annotations, true
	case ^ast.Block_Stmt:
		return n.annotations, true
	case:
		return {}, false
	}
}

@(private="file")
check_annotation_purity :: proc(c: ^Checker, anno: ast.Annotation, node: ^ast.Node) {
	if anno.value != nil && !check_expression_is_pure(c, anno.value) {
		error.add_error(c.ec, c.files[c.current_file_idx], fmt.tprintf("annotation param with name '%s' is not a constant time expression", anno.name), node.pos, node.end)
	}
}

check_node_annotations :: proc(c: ^Checker, node: ^ast.Node) {
	if node == nil {
		return
	}

	if annotations, ok := get_node_annotations(node); ok {
		for &anno in annotations {
			is_stmt := false
			#partial switch _ in node.derived {
			case ^ast.Func_Stmt,
				 ^ast.Event_Stmt,
				 ^ast.Value_Decl,
				 ^ast.Assign_Stmt,
				 ^ast.Expr_Stmt,
				 ^ast.If_Stmt,
				 ^ast.For_Stmt,
				 ^ast.Return_Stmt,
				 ^ast.Defer_Stmt,
				 ^ast.Block_Stmt:
				is_stmt = true
			}

			if is_stmt {
				check_annotation_purity(c, anno, &anno.anno_base)
				if !check_anno_meanings(c, cast(^ast.Stmt)node, &anno) {
					error.add_warning(c.ec, c.files[c.current_file_idx], fmt.tprintf("annotation '%s' likely has no effect on this kind of stmt", anno.name), anno.anno_base.pos, anno.anno_base.end)
				}
			}
		}
	}
}

@(private="file")
_collect_before_visit_child :: proc(v: ^ast.Visitor, parent, child: ^ast.Node) -> bool {
	c := cast(^Checker)v.user_data
	if child != nil {
		enter_scope_for_node(c, child)
	}
	return true
}

@(private="file")
_collect_after_visit_child :: proc(v: ^ast.Visitor, parent, child: ^ast.Node) {
	c := cast(^Checker)v.user_data
	if child != nil {
		exit_scope_for_node(c, child)
	}
}

enter_scope_for_node :: proc(c: ^Checker, node: ^ast.Node) -> bool {
	#partial switch t in node.derived {
	case ^ast.Func_Stmt,
		 ^ast.Event_Stmt:
		return false

	case ^ast.Block_Stmt,
		 ^ast.Defer_Stmt:

		if scope, exists := c.symbol_table.node_scopes[node.id]; exists {
			c.symbol_table.current_scope = scope
			c.symbol_table.scope_level = scope.level
		} else {
			enter_scope(c)
			c.symbol_table.node_scopes[node.id] = c.symbol_table.current_scope
		}
		return true
	case:
		return false
	}
}

exit_scope_for_node :: proc(c: ^Checker, node: ^ast.Node) {
	#partial switch t in node.derived {
	case ^ast.Block_Stmt,
		 ^ast.Func_Stmt,
		 ^ast.Event_Stmt,
		 ^ast.Defer_Stmt:

		if scope, exists := c.symbol_table.node_scopes[node.id]; exists && scope.parent != nil {
			c.symbol_table.current_scope = scope.parent
			c.symbol_table.scope_level = scope.parent.level
		}
	case:
	}
}

set_scope_from_node_id :: proc(c: ^Checker, node: ^ast.Node) -> bool {
	if node == nil {
		return false
	}

	if scope, exists := c.symbol_table.node_scopes[node.id]; exists {
		c.symbol_table.current_scope = scope
		c.symbol_table.scope_level = scope.level
		return true
	}
	return false
}

@(private="file")
_type_check_before_visit_child :: proc(v: ^ast.Visitor, parent, child: ^ast.Node) -> bool {
	c := cast(^Checker)v.user_data

	if child != nil {
		#partial switch t in child.derived {
		case ^ast.Block_Stmt,
			 ^ast.Func_Stmt,
			 ^ast.Event_Stmt,
			 ^ast.Defer_Stmt:

			set_scope_from_node_id(c, child)
		case:
		}
	}
	return true
}

@(private="file")
_type_check_after_visit_child :: proc(v: ^ast.Visitor, parent, child: ^ast.Node) {
	c := cast(^Checker)v.user_data

	if child != nil {
		#partial switch t in child.derived {
		case ^ast.Block_Stmt,
			 ^ast.Func_Stmt,
			 ^ast.Event_Stmt,
			 ^ast.Defer_Stmt:

			if scope, exists := c.symbol_table.node_scopes[child.id]; exists && scope.parent != nil {
				c.symbol_table.current_scope = scope.parent
				c.symbol_table.scope_level = scope.parent.level
			}
		case:
		}
	}
}

@(private="file")
_type_check_before_visit_node :: proc(v: ^ast.Visitor, node: ^ast.Node) -> bool {
	c := cast(^Checker)v.user_data
	check_node_annotations(c, node)
	return true
}

checker_check :: proc(c: ^Checker, files: [dynamic]^ast.File) -> ^Symbol_Table {
	c.files = files

	enter_scope(c)
	add_builtin_functions(c)
	add_native_functions(c)

	for file, idx in files {
		c.current_file = file
		c.current_file_idx = idx
		ast.walk_file(c.collector_walker, file)
	}

	c.current_file_idx = 0
	for file in files {
		c.current_file = file
		ast.walk_file(c.type_checker_walker, file)
		c.current_file_idx += 1
	}

	exit_scope(c)
	return c.symbol_table
}

@(private="file")
_collect_visit_func_stmt :: proc(v: ^ast.Visitor, node: ^ast.Func_Stmt) {
	c := cast(^Checker)v.user_data

	if c.symbol_table.scope_level > 0 {
		error.add_error(c.ec, c.files[c.current_file_idx], "can't define function in nested scope", node.pos, node.end)
		return
	}

	ret_type := create_type_info(string_to_type_kind(c, node.result, node), c.alloc)
	symbol := create_symbol(node.name, make_type_func(c, ret_type), node, c.alloc)

	if !add_symbol(c, symbol) {
		error.add_error(c.ec, c.files[c.current_file_idx], fmt.tprintf("function '%s' is already defined", node.name), node.pos, node.end)
		return
	}

	enter_scope(c)
	func_scope := c.symbol_table.current_scope
	c.symbol_table.node_scopes[node.id] = func_scope

	if node.params != nil {
		for param in node.params.list {
			type_info := create_type_info(string_to_type_kind(c, param.type, param), c.alloc)

			param_sym := create_symbol(param.name, type_info, node, c.alloc)
			add_symbol(c, param_sym)

			append(&symbol.type.param_names, param_sym.name)
			append(&symbol.type.param_types, type_info)
		}
	}
}

@(private="file")
_collect_visit_event_stmt :: proc(v: ^ast.Visitor, node: ^ast.Event_Stmt) {
	c := cast(^Checker)v.user_data

	if c.symbol_table.scope_level > 0 {
		error.add_error(c.ec, c.files[c.current_file_idx], "can't define event in nested scope", node.pos, node.end)
		return
	}

	symbol := create_symbol(node.name, make_type_event(c), node, c.alloc)

	if !add_symbol(c, symbol) {
		error.add_error(c.ec, c.files[c.current_file_idx], fmt.tprintf("event '%s' is already defined", node.name), node.pos, node.end)
		return
	}

	enter_scope(c)
	event_scope := c.symbol_table.current_scope
	c.symbol_table.node_scopes[node.id] = event_scope

	if node.params != nil {
		for param in node.params.list {
			type_info := create_type_info(string_to_type_kind(c, param.type, param), c.alloc)

			param_sym := create_symbol(param.name, type_info, node, c.alloc)
			add_symbol(c, param_sym)

			append(&symbol.type.param_names, param_sym.name)
			append(&symbol.type.param_types, type_info)
		}
	}
}

@(private="file")
_collect_visit_value_decl :: proc(v: ^ast.Visitor, node: ^ast.Value_Decl) {
	c := cast(^Checker)v.user_data

	if node.name == "_" {
		get_type_info_from_expression(c, node.value)
		return
	}

	if _, already_defined := lookup_local_symbol(c.symbol_table.current_scope, node.name);
		already_defined {
		error.add_error(c.ec, c.files[c.current_file_idx], fmt.tprintf("variable '%s' is already defined", node.name), node.pos, node.end)
		return
	}

	type_info := get_type_info_from_expression(c, node.value)

	if node.type != "" && type_info.kind != .Any {
		provided_type_kind := string_to_type_kind(c, node.type, node)
		if type_info.kind != provided_type_kind {
			error.add_error(c.ec, c.files[c.current_file_idx], fmt.tprintf("explicitly stated type doesn't match variable content: '%s' != '%s'",
				type_kind_to_string(type_info.kind), type_kind_to_string(provided_type_kind)), node.pos, node.end)
		}
	}

	symbol := create_symbol(node.name, type_info, node, c.alloc)
	symbol.is_const = node.is_const
	add_symbol(c, symbol)
}

@(private="file")
_type_check_visit_func_stmt :: proc(v: ^ast.Visitor, node: ^ast.Func_Stmt) {
	c := cast(^Checker)v.user_data

	sym, found := lookup_symbol(c.symbol_table.current_scope, node.name)
	if found && check_function_is_pure(c, node.name) {
		if flags_field, has := sym.metadata["flags"]; has {
			if flags, ok := flags_field.(Flags); ok {
				flags += {.PURE}
				sym.metadata["flags"] = flags
			}
		} else {
			sym.metadata["flags"] = Flags{.PURE}
		}
	}

	if anno_is_true(cast(^ast.Stmt)node, "pure") && !check_function_is_pure(c, node.name) {
		error.add_error(c.ec, c.files[c.current_file_idx], fmt.tprintf("function '%s' marked as @pure but has non-pure content", node.name), node.pos, node.end)
	}
}

@(private="file")
_type_check_visit_event_stmt :: proc(v: ^ast.Visitor, node: ^ast.Event_Stmt) {
	c := cast(^Checker)v.user_data

	sym, found := lookup_symbol(c.symbol_table.current_scope, node.name)
	if found && check_function_is_pure(c, node.name) {
		if flags_field, has := sym.metadata["flags"]; has {
			if flags, ok := flags_field.(Flags); ok {
				flags += {.PURE}
				sym.metadata["flags"] = flags
			}
		} else {
			sym.metadata["flags"] = Flags{.PURE}
		}
	}

	if anno_is_true(cast(^ast.Stmt)node, "pure") && !check_function_is_pure(c, node.name) {
		error.add_error(c.ec, c.files[c.current_file_idx], fmt.tprintf("event '%s' marked as @pure but has non-pure content", node.name), node.pos, node.end)
	}
}

@(private="file")
_type_check_visit_value_decl :: proc(v: ^ast.Visitor, node: ^ast.Value_Decl) {
	c := cast(^Checker)v.user_data

	if node.name == "_" {
		return
	}

	if node.is_const && !check_expression_is_pure(c, node.value) {
		error.add_error(c.ec, c.files[c.current_file_idx], fmt.tprintf("cannot initialize constant '%s' with non-constant value '%s'",
			node.name, ast.expr_to_string(node.value, context.temp_allocator)), node.pos, node.end)
	}

	sym, found := lookup_symbol(c.symbol_table.current_scope, node.name)
	if found && (node.is_const || anno_is_true(cast(^ast.Stmt)node, "pure")) {
		if check_expression_is_pure(c, node.value) {
			if flags_field, has := sym.metadata["flags"]; has {
				if flags, ok := flags_field.(Flags); ok {
					flags += {.PURE}
					sym.metadata["flags"] = flags
				}
			} else {
				sym.metadata["flags"] = Flags{.PURE}
			}
		} else if anno_is_true(cast(^ast.Stmt)node, "pure") {
			error.add_error(c.ec, c.files[c.current_file_idx], fmt.tprintf("variable '%s' marked as @pure but initialized with non-pure expression",
				node.name), node.pos, node.end)
		}
	}
}

@(private="file")
_type_check_visit_assign_stmt :: proc(v: ^ast.Visitor, node: ^ast.Assign_Stmt) {
	c := cast(^Checker)v.user_data
	if node.name == "_" {
		return
	}
	sym, found := lookup_symbol(c.symbol_table.current_scope, node.name)
	if found {
		if sym.is_const {
			error.add_error(c.ec, c.files[c.current_file_idx], fmt.tprintf("cannot assign to constant variable '%s'", node.name), node.pos, node.end)
		}

		if flags_field, has := sym.metadata["flags"]; has {
			if flags, ok := flags_field.(Flags); ok && .PURE in flags {
				if !check_expression_is_pure(c, node.expr) {
					error.add_error(c.ec, c.files[c.current_file_idx], fmt.tprintf("cannot assign non-pure value to pure variable '%s'", node.name), node.pos, node.end)
				}
			}
		}
	} else {
		error.add_error(c.ec, c.files[c.current_file_idx], fmt.tprintf("variable '%s' is not declared", node.name), node.pos, node.end)
	}
}

@(private="file")
_type_check_visit_ident :: proc(v: ^ast.Visitor, node: ^ast.Ident) {
	c := cast(^Checker)v.user_data

	sym, exists := lookup_symbol(c.symbol_table.current_scope, node.name)
	if !exists {
		error.add_error(c.ec, c.files[c.current_file_idx], fmt.tprintf("variable '%s' is not declared", node.name), node.pos, node.end)
	}
}

@(private="file")
_type_check_visit_call_expr :: proc(v: ^ast.Visitor, node: ^ast.Call_Expr) {
	c := cast(^Checker)v.user_data

	if ident, is_ident := node.expr.derived.(^ast.Ident); is_ident {
		sym, exists := lookup_symbol(c.symbol_table.current_scope, ident.name)
		if !exists {
			error.add_error(c.ec, c.files[c.current_file_idx], fmt.tprintf("function '%s' is not defined", ident.name), ident.pos, ident.end)
			return
		}

		if len(node.args) != len(sym.type.param_types) {
			error.add_error(c.ec, c.files[c.current_file_idx], fmt.tprintf("invalid arguments count in function call: %d != %d",
				len(node.args), len(sym.type.param_types)), node.pos, node.end)
			return
		}

		for arg, i in node.args {
			real_index := i
			arg_type, param_type: ^Type_Info

			if arg.name == "" {
				arg_type = get_type_info_from_expression(c, arg.value)
				param_type = sym.type.param_types[i]
			} else {
				real_index = -1
				for param_name, arg_i in sym.type.param_names {
					if param_name == arg.name {
						real_index = arg_i
						break
					}
				}

				if real_index == -1 {
					closest := _find_closest(c, arg.name, sym.type.param_names[:])
					error.add_error(c.ec, c.files[c.current_file_idx], fmt.tprintf("invalid named argument: '%s', maybe '%s'?", arg.name, closest), node.pos, node.end)
					continue
				}

				arg_type = get_type_info_from_expression(c, arg.value)
				param_type = sym.type.param_types[real_index]
			}

			if arg_type.kind == .Text && param_type.kind == .Enum {
				action, action_exists := assets.action_native_from_mapped(ident.name)
				if !action_exists {
					error.add_error(c.ec, c.files[c.current_file_idx], "enum validation not implemented for this function", node.pos, node.end)
					continue
				}

				if text_lit, is_text_lit := arg.value.derived.(^ast.Basic_Lit); is_text_lit {
					content := text_lit.tok.content[1:len(text_lit.tok.content)-1]
					if !slice.contains(action.slots[real_index]._enum[:], content) {
						closest := _find_closest(c, content, action.slots[real_index]._enum[:])
						error.add_error(c.ec, c.files[c.current_file_idx], fmt.tprintf("invalid value for enum: '%s', maybe '%s'?", content, closest), text_lit.pos, text_lit.end)
					}
				}
			} else if arg_type.kind != param_type.kind && !can_casted(arg_type.kind, param_type.kind) {
				error.add_error(c.ec, c.files[c.current_file_idx], fmt.tprintf("invalid argument type: '%s' != '%s'",
					type_kind_to_string(arg_type.kind), type_kind_to_string(param_type.kind)), node.pos, node.end)
			}
		}
	}
}

@(private="file")
_type_check_visit_binary_expr :: proc(v: ^ast.Visitor, node: ^ast.Binary_Expr) {
	c := cast(^Checker)v.user_data

	left_kind := get_type_info_from_expression(c, node.left).kind
	right_kind := get_type_info_from_expression(c, node.right).kind

	if left_kind == .Any || right_kind == .Any {
		return
	}

	if left_kind != right_kind {
		left_str := type_kind_to_string(left_kind)
		right_str := type_kind_to_string(right_kind)
		error.add_error(c.ec, c.files[c.current_file_idx], fmt.tprintf("incompatible types: '%s' and '%s'", left_str, right_str), node.pos, node.end)
	}
}

get_type_info_from_expression :: proc(c: ^Checker, expr: ^ast.Expr) -> ^Type_Info {
	type_info := create_type_info(.Invalid, c.alloc)

	if expr == nil {
		return type_info
	}

	#partial switch v in expr.derived {
	case ^ast.Paren_Expr:
		return get_type_info_from_expression(c, v.expr)
	case ^ast.Ident:
		sym, exists := lookup_symbol(c.symbol_table.current_scope, v.name)
		if !exists {
			return type_info
		}
		return sym.type

	case ^ast.Basic_Lit:
		#partial switch v.tok.kind {
		case .Text: type_info.kind = .Text
		case .Number: type_info.kind = .Number
		case .True, .False: type_info.kind = .Boolean
		}
		return type_info

	case ^ast.Binary_Expr:
		left := get_type_info_from_expression(c, v.left)
		right := get_type_info_from_expression(c, v.right)

		if left.kind == .Any || right.kind == .Any {
			type_info.kind = .Any
			return type_info
		}

		if left.kind != right.kind {
			return type_info
		}

		type_info.kind = left.kind
		return type_info

	case ^ast.Call_Expr:
		if ident, is_ident := v.expr.derived.(^ast.Ident); is_ident {
			sym, exists := lookup_symbol(c.symbol_table.current_scope, ident.name)
			if exists && sym.type != nil {
				return sym.type.return_t
			}
		}
		return type_info

	case:
		return type_info
	}
}

make_type_event :: proc(c: ^Checker) -> ^Type_Info {
	type_info_event := create_type_info(.Event, c.alloc)
	return type_info_event
}

make_type_func :: proc(c: ^Checker, ret_type: ^Type_Info) -> ^Type_Info {
	type_info_func := create_type_info(.Function, c.alloc)
	if ret_type != nil {
		type_info_func.return_t = ret_type
	}
	return type_info_func
}

create_builtin_type_info :: proc(c: ^Checker, kind, ret_kind: Type_Kind) -> ^Type_Info {
	type_info := create_type_info(kind, c.alloc)
	return_type := create_type_info(ret_kind, c.alloc)
	type_info.return_t = return_type
	return type_info
}

add_builtin_functions :: proc(c: ^Checker) {
	game_value_type := create_builtin_type_info(c, .Function, .GameValue)
	append(&game_value_type.param_names, "value")
	append(&game_value_type.param_names, "selection")
	append(&game_value_type.param_types, create_type_info(.Text, c.alloc))
	append(&game_value_type.param_types, create_type_info(.Text, c.alloc))
	symbol := create_symbol("game_value", game_value_type, nil, c.alloc)
	symbol.metadata["flags"] = Flags{.BUILTIN}
	add_symbol(c, symbol)

	item_value_type := create_builtin_type_info(c, .Function, .Item)
	append(&item_value_type.param_names, "id")
	append(&item_value_type.param_names, "count")
	append(&item_value_type.param_types, create_type_info(.Text, c.alloc))
	append(&item_value_type.param_types, create_type_info(.Number, c.alloc))
	symbol = create_symbol("item", item_value_type, nil, c.alloc)
	symbol.metadata["flags"] = Flags{.BUILTIN}
	add_symbol(c, symbol)

	array_value_type := create_builtin_type_info(c, .Function, .Array)
	// ...
	symbol = create_symbol("array", array_value_type, nil, c.alloc)
	symbol.metadata["flags"] = Flags{.BUILTIN}
	add_symbol(c, symbol)

	dict_value_type := create_builtin_type_info(c, .Function, .Dict)
	// ...
	symbol = create_symbol("dict", dict_value_type, nil, c.alloc)
	symbol.metadata["flags"] = Flags{.BUILTIN}
	add_symbol(c, symbol)

	location_value_type := create_builtin_type_info(c, .Function, .Location)
	append(&location_value_type.param_names, "x")
	append(&location_value_type.param_names, "y")
	append(&location_value_type.param_names, "z")
	append(&location_value_type.param_names, "yaw")
	append(&location_value_type.param_names, "pitch")
	append(&location_value_type.param_types, create_type_info(.Number, c.alloc))
	append(&location_value_type.param_types, create_type_info(.Number, c.alloc))
	append(&location_value_type.param_types, create_type_info(.Number, c.alloc))
	append(&location_value_type.param_types, create_type_info(.Number, c.alloc))
	append(&location_value_type.param_types, create_type_info(.Number, c.alloc))
	symbol = create_symbol("location", location_value_type, nil, c.alloc)
	symbol.metadata["flags"] = Flags{.BUILTIN}
	add_symbol(c, symbol)

	vec3_value_type := create_builtin_type_info(c, .Function, .Vector)
	append(&vec3_value_type.param_names, "x")
	append(&vec3_value_type.param_names, "y")
	append(&vec3_value_type.param_names, "z")
	append(&vec3_value_type.param_types, create_type_info(.Number, c.alloc))
	append(&vec3_value_type.param_types, create_type_info(.Number, c.alloc))
	append(&vec3_value_type.param_types, create_type_info(.Number, c.alloc))
	symbol = create_symbol("vec3", vec3_value_type, nil, c.alloc)
	symbol.metadata["flags"] = Flags{.BUILTIN}
	add_symbol(c, symbol)

	sound_value_type := create_builtin_type_info(c, .Function, .Sound)
	append(&sound_value_type.param_names, "sound")
	append(&sound_value_type.param_names, "pitch")
	append(&sound_value_type.param_names, "volume")
	append(&sound_value_type.param_names, "variation")
	append(&sound_value_type.param_names, "source")
	append(&sound_value_type.param_types, create_type_info(.Text, c.alloc))
	append(&sound_value_type.param_types, create_type_info(.Number, c.alloc))
	append(&sound_value_type.param_types, create_type_info(.Number, c.alloc))
	append(&sound_value_type.param_types, create_type_info(.Text, c.alloc))
	append(&sound_value_type.param_types, create_type_info(.Text, c.alloc))
	symbol = create_symbol("sound", sound_value_type, nil, c.alloc)
	symbol.metadata["flags"] = Flags{.BUILTIN}
	add_symbol(c, symbol)

	particle_value_type := create_builtin_type_info(c, .Function, .Particle)
	append(&particle_value_type.param_names, "particle_type")
	append(&particle_value_type.param_names, "count")
	append(&particle_value_type.param_names, "first_spread")
	append(&particle_value_type.param_names, "second_spread")
	append(&particle_value_type.param_names, "x_motion")
	append(&particle_value_type.param_names, "y_motion")
	append(&particle_value_type.param_names, "z_motion")
	append(&particle_value_type.param_names, "color")
	append(&particle_value_type.param_names, "size")
	append(&particle_value_type.param_types, create_type_info(.Text, c.alloc))
	append(&particle_value_type.param_types, create_type_info(.Number, c.alloc))
	append(&particle_value_type.param_types, create_type_info(.Number, c.alloc))
	append(&particle_value_type.param_types, create_type_info(.Number, c.alloc))
	append(&particle_value_type.param_types, create_type_info(.Number, c.alloc))
	append(&particle_value_type.param_types, create_type_info(.Number, c.alloc))
	append(&particle_value_type.param_types, create_type_info(.Number, c.alloc))
	append(&particle_value_type.param_types, create_type_info(.Number, c.alloc))
	append(&particle_value_type.param_types, create_type_info(.Number, c.alloc))
	symbol = create_symbol("particle", particle_value_type, nil, c.alloc)
	symbol.metadata["flags"] = Flags{.BUILTIN}
	add_symbol(c, symbol)

	block_value_type := create_builtin_type_info(c, .Function, .Block)
	append(&block_value_type.param_names, "id")
	append(&block_value_type.param_types, create_type_info(.Text, c.alloc))
	symbol = create_symbol("block", block_value_type, nil, c.alloc)
	symbol.metadata["flags"] = Flags{.BUILTIN}
	add_symbol(c, symbol)

	number_value_type := create_builtin_type_info(c, .Function, .Number)
	append(&number_value_type.param_names, "value")
	append(&number_value_type.param_types, create_type_info(.Any, c.alloc))
	symbol = create_symbol("number", number_value_type, nil, c.alloc)
	symbol.metadata["flags"] = Flags{.BUILTIN}
	add_symbol(c, symbol)

	text_value_type := create_builtin_type_info(c, .Function, .Text)
	append(&text_value_type.param_names, "value")
	append(&text_value_type.param_types, create_type_info(.Any, c.alloc))
	symbol = create_symbol("text", text_value_type, nil, c.alloc)
	symbol.metadata["flags"] = Flags{.BUILTIN}
	add_symbol(c, symbol)

	enum_value_type := create_builtin_type_info(c, .Function, .Enum)
	append(&enum_value_type.param_names, "value")
	append(&enum_value_type.param_types, create_type_info(.Text, c.alloc))
	symbol = create_symbol("enum", enum_value_type, nil, c.alloc)
	symbol.metadata["flags"] = Flags{.BUILTIN}
	add_symbol(c, symbol)

	potion_value_type := create_builtin_type_info(c, .Function, .Potion)
	append(&potion_value_type.param_names, "potion")
	append(&potion_value_type.param_names, "amplifier")
	append(&potion_value_type.param_names, "duration")
	append(&potion_value_type.param_types, create_type_info(.Text, c.alloc))
	append(&potion_value_type.param_types, create_type_info(.Number, c.alloc))
	append(&potion_value_type.param_types, create_type_info(.Number, c.alloc))
	symbol = create_symbol("potion", potion_value_type, nil, c.alloc)
	symbol.metadata["flags"] = Flags{.BUILTIN}
	add_symbol(c, symbol)
}

add_native_functions :: proc(c: ^Checker) {
	for action_name, action_data in assets.actions {
		if action_data.type != .BASIC {
			continue
		}
		type_info := create_type_info(.Function, c.alloc)
		for slot in action_data.slots[:] {
			append(&type_info.param_names, slot.name)
			slot_type_info := create_type_info(string_to_type_kind(c, slot.type, nil), c.alloc)
			append(&type_info.param_types, slot_type_info)
		}
		sym := create_symbol(action_name, type_info, nil, c.alloc)
		sym.metadata["flags"] = Flags{.NATIVE}
		add_symbol(c, sym)
	}
}

can_casted :: proc(first, second: Type_Kind) -> bool {
	if first == .Any || second == .Any {
		return true
	}

	if first == second {
		return true
	}

	return false
}

check_anno_meanings :: proc(c: ^Checker, stmt: ^ast.Stmt, anno: ^ast.Annotation) -> bool {
	switch anno.name {
	case "pure":
		#partial switch t in stmt.derived {
		case ^ast.Func_Stmt, ^ast.Event_Stmt, ^ast.Value_Decl, ^ast.Assign_Stmt:
			return true
		}
	case "name", "desc", "icon":
		#partial switch t in stmt.derived {
		case ^ast.Func_Stmt:
			return true
		}
	case "export":
		#partial switch t in stmt.derived {
		case ^ast.Value_Decl, ^ast.Func_Stmt:
			return true
		}
	}

	return false
}

check_function_is_pure :: proc(c: ^Checker, name: string) -> bool {
	sym, exists := lookup_symbol(c.symbol_table.current_scope, name)

	if !exists {
		return false
	}

	if sym.type.kind != .Function {
		return false
	}

	if is_builtin(c, name) {
		return true
	}

	if _, action_exists := assets.action_native_from_mapped(name); action_exists {
		return false
	}

	if func_stmt, is_func_stmt := sym.decl_node.derived.(^ast.Func_Stmt); is_func_stmt {
		if func_scope, exists2 := c.symbol_table.node_scopes[func_stmt.id]; exists2 {
			return check_function_body_is_pure(c, func_stmt.body, func_scope)
		}
	}

	return false
}

is_builtin :: proc(c: ^Checker, name: string) -> bool {
	sym, found := lookup_symbol(c.symbol_table.current_scope, name)
	if !found {
		return false
	}

	if flags_field, has := sym.metadata["flags"]; has {
		if flags, ok := flags_field.(Flags); ok {
			return .BUILTIN in flags
		}
	}
	return false
}

check_function_body_is_pure :: proc(c: ^Checker, body: ^ast.Block_Stmt, func_scope: ^Scope = nil) -> bool {
	if body == nil {
		return true
	}

	for stmt in body.stmts {
		#partial switch s in stmt.derived {
		case ^ast.Value_Decl:
			if t, is_value_decl := s.derived.(^ast.Value_Decl); is_value_decl {
				if !check_expression_is_pure(c, t.value) {
					return false
				}
			}

		case ^ast.Assign_Stmt:
			if !check_expression_is_pure(c, s.expr) {
				return false
			}

			if func_scope != nil {
				if sym, exists := lookup_local_symbol(func_scope, s.name); exists {
				} else if sym2, exists2 := lookup_symbol(c.symbol_table.global_scope, s.name); exists2 {
					return false
				} else if sym3, exists3 := lookup_symbol(c.symbol_table.current_scope, s.name); exists3 {
					return false
				}
			}

		case ^ast.Expr_Stmt:
			if !check_expression_is_pure(c, s.expr) {
				return false
			}

		case ^ast.Return_Stmt:
			if s.result != nil && !check_expression_is_pure(c, s.result) {
				return false
			}

		case ^ast.If_Stmt:
			if !check_expression_is_pure(c, s.cond) {
				return false
			}
			if !check_function_body_is_pure(c, s.body, func_scope) {
				return false
			}
			if s.else_stmt != nil && !check_function_body_is_pure(c, s.else_stmt, func_scope) {
				return false
			}

		case ^ast.For_Stmt:
			if !check_for_stmt_is_pure(c, s) {
				return false
			}

		case ^ast.Block_Stmt:
			if !check_function_body_is_pure(c, s, func_scope) {
				return false
			}

		case ^ast.Defer_Stmt:
			#partial switch d in s.stmt.derived {
			case ^ast.Expr_Stmt:
				if !check_expression_is_pure(c, d.expr) {
					return false
				}
			case:
				return false
			}

		case:
			return false
		}
	}

	return true
}

check_for_stmt_is_pure :: proc(c: ^Checker, for_stmt: ^ast.For_Stmt) -> bool {
	if for_stmt.init != nil {
		for ident in for_stmt.init {
			if sym, exists := lookup_symbol(c.symbol_table.current_scope, ident.name); !exists {
				return false
			}
		}
	}

	if for_stmt.cond != nil && !check_expression_is_pure(c, for_stmt.cond) {
		return false
	}
	if for_stmt.second_cond != nil && !check_expression_is_pure(c, for_stmt.second_cond) {
		return false
	}

	if for_stmt.post != nil {
		#partial switch post_stmt in for_stmt.post.derived {
		case ^ast.Expr_Stmt:
			if !check_expression_is_pure(c, post_stmt.expr) {
				return false
			}
	 case ^ast.Assign_Stmt:
			if !check_expression_is_pure(c, post_stmt.expr) {
				return false
			}
		case:
			return false
		}
	}

	if for_stmt.body != nil {
		enter_scope(c)
		defer exit_scope(c)

		if for_stmt.init != nil {
			for ident in for_stmt.init {
				type_info := create_type_info(.Any, c.alloc)
				symbol := create_symbol(ident.name, type_info, cast(^ast.Node)ident, c.alloc)
				add_symbol(c, symbol)
			}
		}

		if !check_function_body_is_pure(c, for_stmt.body) {
			return false
		}
	}

	return !contains_notpure_calls_in_for_body(c, for_stmt.body)
}

contains_notpure_calls_in_for_body :: proc(c: ^Checker, body: ^ast.Block_Stmt) -> bool {
	if body == nil {
		return false
	}

	for stmt in body.stmts {
		#partial switch s in stmt.derived {
		case ^ast.Expr_Stmt:
			if contains_notpure_calls_in_expr(c, s.expr) {
				return true
			}

		case ^ast.Value_Decl:
			if t, is_value_decl := s.derived.(^ast.Value_Decl); is_value_decl {
				if contains_notpure_calls_in_expr(c, t.value) {
					return true
				}
			}

		case ^ast.Assign_Stmt:
			if contains_notpure_calls_in_expr(c, s.expr) {
				return true
			}

		case ^ast.If_Stmt:
			if contains_notpure_calls_in_expr(c, s.cond) {
				return true
			}
			if contains_notpure_calls_in_body(c, s.body) {
				return true
			}
			if s.else_stmt != nil && contains_notpure_calls_in_body(c, s.else_stmt) {
				return true
			}

		case ^ast.For_Stmt:
			if contains_notpure_calls_in_for_body(c, s.body) {
				return true
			}

		case ^ast.Block_Stmt:
			if contains_notpure_calls_in_body(c, s) {
				return true
			}

		case ^ast.Defer_Stmt:
			#partial switch d in s.stmt.derived {
			case ^ast.Expr_Stmt:
				if contains_notpure_calls_in_expr(c, d.expr) {
					return true
				}
			case:
				return true
			}
		}
	}

	return false
}

contains_notpure_calls_in_expr :: proc(c: ^Checker, expr: ^ast.Expr) -> bool {
	if expr == nil {
		return false
	}

	#partial switch e in expr.derived {
	case ^ast.Call_Expr:
		if ident, is_ident := e.expr.derived.(^ast.Ident); is_ident {
			return !check_function_is_pure(c, ident.name)
		}

		return true

	case ^ast.Binary_Expr:
		return contains_notpure_calls_in_expr(c, e.left) ||
			   contains_notpure_calls_in_expr(c, e.right)

	case ^ast.Unary_Expr:
		return contains_notpure_calls_in_expr(c, e.expr)

	case ^ast.Paren_Expr:
		return contains_notpure_calls_in_expr(c, e.expr)

	case ^ast.Index_Expr:
		return contains_notpure_calls_in_expr(c, e.expr) ||
			   contains_notpure_calls_in_expr(c, e.index)

	case ^ast.Member_Access_Expr:
		return contains_notpure_calls_in_expr(c, e.expr)

	case ^ast.Field_Value:
		return contains_notpure_calls_in_expr(c, e.field) ||
			   contains_notpure_calls_in_expr(c, e.value)
	}

	return false
}

contains_notpure_calls_in_body :: proc(c: ^Checker, body: ^ast.Block_Stmt) -> bool {
	if body == nil {
		return false
	}

	for stmt in body.stmts {
		#partial switch s in stmt.derived {
		case ^ast.Expr_Stmt:
			if contains_notpure_calls_in_expr(c, s.expr) {
				return true
			}

		case ^ast.Value_Decl:
			if t, is_value_decl := s.derived.(^ast.Value_Decl); is_value_decl {
				if contains_notpure_calls_in_expr(c, t.value) {
					return true
				}
			}

		case ^ast.Assign_Stmt:
			if contains_notpure_calls_in_expr(c, s.expr) {
				return true
			}

		case ^ast.If_Stmt:
			if contains_notpure_calls_in_expr(c, s.cond) {
				return true
			}
			if contains_notpure_calls_in_body(c, s.body) {
				return true
			}
			if s.else_stmt != nil && contains_notpure_calls_in_body(c, s.else_stmt) {
				return true
			}

		case ^ast.For_Stmt:
			if contains_notpure_calls_in_for_body(c, s.body) {
				return true
			}

		case ^ast.Block_Stmt:
			if contains_notpure_calls_in_body(c, s) {
				return true
			}
		}
	}

	return false
}

check_expression_is_pure :: proc(c: ^Checker, expr: ^ast.Expr) -> bool {
	if expr == nil {
		return false
	}

	#partial switch t in expr.derived {
	case ^ast.Basic_Lit:
		return true
	case ^ast.Binary_Expr:
		return check_expression_is_pure(c, t.left) && check_expression_is_pure(c, t.right)
	case ^ast.Unary_Expr:
		return check_expression_is_pure(c, t.expr)
	case ^ast.Paren_Expr:
		return check_expression_is_pure(c, t.expr)
	case ^ast.Ident:
		sym, exists := lookup_symbol(c.symbol_table.current_scope, t.name)

		if !exists {
			return false
		}

		if sym.is_const {
			return true
		}

		if value_decl, is_value_decl := sym.decl_node.derived.(^ast.Value_Decl); is_value_decl {
			if value_decl.is_const {
				return check_expression_is_pure(c, value_decl.value)
			}
		}

		return false
	case ^ast.Call_Expr:
		if ident, is_ident := t.expr.derived.(^ast.Ident); is_ident {
			if !check_function_is_pure(c, ident.name) {
				return false
			}

			for arg in t.args {
				if !check_expression_is_pure(c, arg.value) {
					return false
				}
			}
			return true
		}
		return false
	case ^ast.Index_Expr:
		return check_expression_is_pure(c, t.expr) && check_expression_is_pure(c, t.index)
	case ^ast.Member_Access_Expr:
		return check_expression_is_pure(c, t.expr)
	case ^ast.Field_Value:
		return check_expression_is_pure(c, t.field) && check_expression_is_pure(c, t.value)
	case:
		return false
	}
}

get_anno :: proc(stmt: ^ast.Stmt, name: string) -> ^ast.Annotation {
	if annotations, ok := get_node_annotations(stmt); ok {
		for &anno in annotations {
			if strings.equal_fold(anno.name, name) {
				return &anno
			}
		}
	}
	return nil
}

anno_is_true :: proc(stmt: ^ast.Stmt, name: string) -> bool {
	anno := get_anno(stmt, name)
	if anno == nil {
		return false
	}

	if anno.value == nil {
		return true
	}

	#partial switch v in anno.value.derived {
	case ^ast.Basic_Lit:
		if v.tok.kind == .True {
			return true
		}
		return false

	case ^ast.Ident:
		if v.name == "true" {
			return true
		}
		return false

	case:
		return false
	}
}

enter_scope :: proc(c: ^Checker) {
	new_scope := create_scope(c.symbol_table.current_scope, c.symbol_table.scope_level + 1, c.alloc)

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

@(private="file")
_find_closest :: proc(c: ^Checker, word: string, words: []string) -> string {
	if len(words) == 0 {
		return ""
	}
	closest := words[0]
	closest_distance := max(int)
	for item in words {
		distance := strings.levenshtein_distance(word, item, c.alloc)
		if distance < closest_distance {
			closest = item
			closest_distance = distance
		}
		if distance == 0 {
			break
		}
	}
	return closest
}
