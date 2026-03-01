package codegen

import "core:fmt"
import "core:strconv"
import "core:mem"

import "../ast"
import "../lexer"
import "../checker"
import "../error"
import "../../assets"

BLOCKS :: 88
LINES :: 23
FLOORS :: 15

Codegen :: struct {
	alloc: mem.Allocator,
	jb: Json_Builder,
	walker: ast.Walker,
	symbols: ^checker.Symbol_Table,
	ec: ^error.Collector,

	entry_handler: ^Handler,
	exit_handler: ^Handler,
	current_scope: ^checker.Scope,
	current_operations: ^[dynamic]^Operation,
	current_operations_stack: [dynamic]^[dynamic]^Operation,
	handlers: [dynamic]^Handler,

	unique_id: int,
}

push_operations :: proc(c: ^Codegen, new_ops: ^[dynamic]^Operation) {
	append(&c.current_operations_stack, c.current_operations)
	c.current_operations = new_ops
}

pop_operations :: proc(c: ^Codegen) {
	if len(c.current_operations_stack) > 0 {
		c.current_operations = pop(&c.current_operations_stack)
	}
}

next_unique_id :: proc(c: ^Codegen) -> string {
	defer c.unique_id += 1
	return fmt.tprintf("jms.%d", c.unique_id)
}

codegen_init :: proc(c: ^Codegen, ec: ^error.Collector, allocator := context.allocator) {
	c.ec = ec
	c.handlers = make_handlers(allocator)
	c.entry_handler = create_event_handler("world_start", make_operations(allocator), allocator)
	c.current_operations = &c.entry_handler.operations
	c.exit_handler = create_event_handler("world_stop", make_operations(allocator), allocator)

	c.current_operations_stack = make([dynamic]^[dynamic]^Operation, allocator)
	c.unique_id = 0

	vtable := new(ast.Visitor_VTable, allocator)
	vtable.visit_func_stmt = visit_func_stmt
	vtable.visit_event_stmt = visit_event_stmt
	vtable.visit_expr_stmt = visit_expr_stmt
	vtable.visit_assign_stmt = visit_assign_stmt
	// vtable.visit_block_stmt = visit_block_stmt
	vtable.visit_if_stmt = visit_if_stmt
	vtable.visit_return_stmt = visit_return_stmt
	vtable.visit_defer_stmt = visit_defer_stmt
	vtable.visit_for_stmt = visit_for_stmt
	vtable.visit_value_decl = visit_value_decl
	vtable.before_visit_child = before_visit_child
	vtable.after_visit_child = after_visit_child
	vtable.before_visit_node = before_visit_node
	vtable.after_visit_node = after_visit_node
	c.walker.user_data = c
	ast.walker_init(&c.walker, vtable, allocator)
	c.alloc = allocator
}

before_visit_node :: proc(v: ^ast.Visitor, node: ^ast.Node) -> bool {
	c := cast(^Codegen)v.user_data
	return true
}

after_visit_node :: proc(v: ^ast.Visitor, node: ^ast.Node) {
	c := cast(^Codegen)v.user_data
	#partial switch n in node.derived {
	case ^ast.If_Stmt, ^ast.For_Stmt, ^ast.Func_Stmt, ^ast.Event_Stmt:
		pop_operations(c)
	}
}

before_visit_child :: proc(v: ^ast.Visitor, parent, child: ^ast.Node) -> bool {
	if child == nil {
		return true
	}
	#partial switch t in child.derived {
	case ^ast.Block_Stmt, ^ast.Defer_Stmt:
		c := cast(^Codegen)v.user_data
		if scope, exists := c.symbols.node_scopes[child.id]; exists {
			c.current_scope = scope
		}
	}
	return true
}

after_visit_child :: proc(v: ^ast.Visitor, parent, child: ^ast.Node) {
	if child == nil {
		return
	}
	#partial switch t in child.derived {
	case ^ast.Block_Stmt, ^ast.Defer_Stmt:
		c := cast(^Codegen)(v.user_data)
		if scope, exists := c.symbols.node_scopes[child.id]; exists {
			if scope.parent != nil {
				c.current_scope = scope.parent
			}
		}
	}
}

visit_func_stmt :: proc(v: ^ast.Visitor, node: ^ast.Func_Stmt) {
	c := cast(^Codegen)v.user_data
	func_handler := create_func_handler(node.name, make_operations(c.alloc), c.alloc)

	translations_template :: `{{\"translations\":{{\"en-US\":{{\"rawText\":\"%s\",\"parsingType\":\"LEGACY\"}},\"ru-RU\":{{\"rawText\":\"%s\",\"parsingType\":\"LEGACY\"}},\"ua-UA\":{{\"rawText\":\"%s\",\"parsingType\":\"LEGACY\"}}}},\"fallback\":{{\"rawText\":\"%s\",\"parsingType\":\"LEGACY\"}}}}`

	if anno := checker.get_anno(node, "name"); anno != nil && anno.value != nil {
		if basic_lit, is_basic_lit := anno.value.derived.(^ast.Basic_Lit); is_basic_lit && basic_lit.tok.kind == .Text {
			anno_content := basic_lit.tok.content[1:len(basic_lit.tok.content)-1]
			display_name_data := fmt.tprintf(translations_template, anno_content, anno_content, anno_content, anno_content)
			append(&func_handler.values, create_named_value("display_name", create_localized_text_value(display_name_data, c.alloc), c.alloc))
		}
	}

	if anno := checker.get_anno(node, "desc"); anno != nil && anno.value != nil {
		if basic_lit, is_basic_lit := anno.value.derived.(^ast.Basic_Lit); is_basic_lit && basic_lit.tok.kind == .Text {
			anno_content := basic_lit.tok.content[1:len(basic_lit.tok.content)-1]
			display_desc_data := fmt.tprintf(translations_template, anno_content, anno_content, anno_content, anno_content)
			append(&func_handler.values, create_named_value("display_description", create_localized_text_value(display_desc_data, c.alloc), c.alloc))
		}
	}

	if anno := checker.get_anno(node, "icon"); anno != nil && anno.value != nil {
		if basic_lit, is_basic_lit := anno.value.derived.(^ast.Basic_Lit); is_basic_lit && basic_lit.tok.kind == .Text {
			item_id := basic_lit.tok.content[1:len(basic_lit.tok.content)-1]
			func_icon := generate_item(item_id, 1, c.alloc)
			append(&func_handler.values, create_named_value("icon", create_item_value(func_icon, c.alloc), c.alloc))
		}
	}

	if checker.anno_is_true(node, "hidden") {
		append(&func_handler.values, create_named_value("is_hidden", create_enum_value("TRUE", c.alloc), c.alloc))
	}

	// TODO: fix possible slots overflow when len(params) > 7
	ensure(len(node.params.list) <= 7, "slots overflow")

	if len(node.params.list) > 0 {
		parameters_inner := create_array_value(make([dynamic]Value, 0, c.alloc), c.alloc)

		for param, param_index in node.params.list {
			test_desc :: "Test param description!"
			test_desc_data := fmt.tprintf(translations_template, test_desc, test_desc, test_desc, test_desc)

			// TODO: fix leaking abstract type (bool or smth) to justmc ir
			ensure(
				param.type == "number" || param.type == "text" ||
				param.type == "variable" || param.type == "array" ||
				param.type == "parameter" || param.type == "enum" ||
				param.type == "location" ||	param.type == "vector" ||
				param.type == "sound" || param.type == "particle" ||
				param.type == "item" || param.type == "game_value" ||
				param.type == "potion" || param.type == "block" ||
				param.type == "map" || param.type == "localized_text", "abstract type leakage")

			slot := 10 + f64(param_index)
			desc_slot := 19 + f64(param_index)
			param_data := create_parameter_value("singular", test_desc_data, param.name, param.type, slot, desc_slot, "true", "{}", c.alloc)
			append(&parameters_inner.values, param_data)
		}
		parameters := create_named_value("parameters", parameters_inner, c.alloc)
		append(&func_handler.values, parameters)
	}

	append(&c.handlers, func_handler)
	push_operations(c, &func_handler.operations)
}

visit_event_stmt :: proc(v: ^ast.Visitor, node: ^ast.Event_Stmt) {
	c := cast(^Codegen)v.user_data
	event_handler := create_event_handler(node.name, make_operations(c.alloc), c.alloc)
	append(&c.handlers, event_handler)
	push_operations(c, &event_handler.operations)
}

visit_expr_stmt :: proc(v: ^ast.Visitor, node: ^ast.Expr_Stmt) {
	c := cast(^Codegen)v.user_data
	codegen_gen_expression(c, node.expr)
}

visit_assign_stmt :: proc(v: ^ast.Visitor, node: ^ast.Assign_Stmt) {
	c := cast(^Codegen)v.user_data

	result_value, result_type := codegen_gen_expression(c, node.expr)
	origin_sym, exists := checker.lookup_symbol(c.current_scope, node.name)
	ensure(exists, "symbol should exist, if not, something in the middle of pipeline removing it from symbol table, but not from AST!")

	origin_type := origin_sym.type.kind

	if origin_type != .Number || result_type != .Number {
		unimplemented(fmt.tprintf("assignment with %s and %s", checker.type_kind_to_string(origin_type), checker.type_kind_to_string(result_type)))
	}

	op: ^Operation
	current_var := create_variable_value(origin_sym.name, guess_variable_type_by_scope(c, origin_sym.name), c.alloc)

	#partial switch node.op.kind { // TODO: get rid of duplicate code
	case .Eq:
		op = create_basic_operation("set_variable_value", make_named_values(c.alloc), "", c.alloc)
		append(&op.values, create_named_value("variable", current_var, c.alloc))
		append(&op.values, create_named_value("value", result_value, c.alloc))

	case .Add_Eq:
		op = create_basic_operation("set_variable_add", make_named_values(c.alloc), "", c.alloc)
		append(&op.values, create_named_value("variable", current_var, c.alloc))
		array_value := create_array_value(make([dynamic]Value, 0, c.alloc), c.alloc)
		append(&array_value.values, current_var)
		append(&array_value.values, result_value)
		append(&op.values, create_named_value("value", array_value, c.alloc))

	case .Sub_Eq:
		op = create_basic_operation("set_variable_subtract", make_named_values(c.alloc), "", c.alloc)
		append(&op.values, create_named_value("variable", current_var, c.alloc))
		array_value := create_array_value(make([dynamic]Value, 0, c.alloc), c.alloc)
		append(&array_value.values, current_var)
		append(&array_value.values, result_value)
		append(&op.values, create_named_value("value", array_value, c.alloc))

	case .Mul_Eq:
		op = create_basic_operation("set_variable_multiply", make_named_values(c.alloc), "", c.alloc)
		append(&op.values, create_named_value("variable", current_var, c.alloc))
		array_value := create_array_value(make([dynamic]Value, 0, c.alloc), c.alloc)
		append(&array_value.values, current_var)
		append(&array_value.values, result_value)
		append(&op.values, create_named_value("value", array_value, c.alloc))

	case .Quo_Eq:
		op = create_basic_operation("set_variable_divide", make_named_values(c.alloc), "", c.alloc)
		append(&op.values, create_named_value("variable", current_var, c.alloc))
		array_value := create_array_value(make([dynamic]Value, 0, c.alloc), c.alloc)
		append(&array_value.values, current_var)
		append(&array_value.values, result_value)
		append(&op.values, create_named_value("value", array_value, c.alloc))
		append(&op.values, create_named_value("division_mode", create_enum_value("default", c.alloc), c.alloc))

	case .Mod_Eq:
		op = create_basic_operation("set_variable_remainder", make_named_values(c.alloc), "", c.alloc)
		append(&op.values, create_named_value("variable", current_var, c.alloc))
		append(&op.values, create_named_value("dividend", current_var, c.alloc))
		append(&op.values, create_named_value("divisor", result_value, c.alloc))
		append(&op.values, create_named_value("remainder_mode", create_enum_value("REMAINDER", c.alloc), c.alloc))

	case:
		unimplemented(fmt.tprintf("assignment with %s operator", lexer.to_string(node.op.kind)))
	}

	append(c.current_operations, op)
}

visit_if_stmt :: proc(v: ^ast.Visitor, node: ^ast.If_Stmt) {
	c := cast(^Codegen)v.user_data
	if_stmt_result, res_type := codegen_gen_expression(c, node.cond)

	op := create_container_operation("if_variable_equals", make_named_values(c.alloc), make_operations(c.alloc), false, "", c.alloc)
	append(&op.values, create_named_value("value", if_stmt_result, c.alloc))
	append(&op.values, create_named_value("compare", create_number_value(1, c.alloc), c.alloc))
	append(c.current_operations, op)

	push_operations(c, &op.operations)
}

visit_return_stmt :: proc(v: ^ast.Visitor, node: ^ast.Return_Stmt) {
	c := cast(^Codegen)v.user_data
	unimplemented("return statement support")
}

visit_defer_stmt :: proc(v: ^ast.Visitor, node: ^ast.Defer_Stmt) {
	c := cast(^Codegen)v.user_data
	unimplemented("defer statement support")
}

visit_for_stmt :: proc(v: ^ast.Visitor, node: ^ast.For_Stmt) {
	c := cast(^Codegen)v.user_data
	unimplemented("for statement support")
}

visit_value_decl :: proc(v: ^ast.Visitor, node: ^ast.Value_Decl) {
	c := cast(^Codegen)v.user_data
	value_decl_op := create_basic_operation("set_variable_value", make_named_values(c.alloc), "", c.alloc)
	append(&value_decl_op.values, create_named_value("variable", create_variable_value(node.name, guess_variable_type_by_scope(c, node.name), c.alloc), c.alloc))
	result_value, _ := codegen_gen_expression(c, node.value)
	append(&value_decl_op.values, create_named_value("value", result_value, c.alloc))
	append(c.current_operations, value_decl_op)
}

codegen_gen_expression :: proc(c: ^Codegen, node: ^ast.Node, waits_enum := false) -> (Value, checker.Type_Kind) {
	#partial switch typed_node in node.derived {
	case ^ast.Call_Expr:
		result_var := create_variable_value(next_unique_id(c), SCOPE_GAME, c.alloc)
		ident, is_ident := typed_node.expr.derived.(^ast.Ident)
		ensure(is_ident)
		func_name := ident.name
		sym, exists := checker.lookup_symbol(c.symbols.global_scope, func_name)
		ensure(exists, "symbol should exist, if not, something in the middle of pipeline removing it from symbol table, but not from AST!")
		func_flags := sym.metadata["flags"].(checker.Flags)

		switch {
		case .NATIVE in func_flags:
			action, _ := assets.action_native_from_mapped(func_name)
			if action.type != .BASIC {
				unimplemented()
			}
			op := create_basic_operation(func_name, make_named_values(c.alloc), "", c.alloc)
			for arg, i in typed_node.args {
				real_index := i
				if arg.name != "" {
					for param_name, arg_i in sym.type.param_names {
						if param_name == arg.name {
							real_index = arg_i
							break
						}
					}
				}
				arg_name := action.slots[real_index].name
				param_type := action.slots[real_index].type
				arg_value, _ := codegen_gen_expression(c, arg, waits_enum=param_type=="enum")
				append(&op.values, create_named_value(arg_name, arg_value, c.alloc))
			}
			append(c.current_operations, op)
		case .BUILTIN in func_flags:
			unimplemented("generation of built-in function")
		case:
			// unimplemented("generation of default function with arguments")
			op := create_basic_operation("call_function", make_named_values(c.alloc), "", c.alloc)
			append(&op.values, create_named_value("function_name", create_text_value(func_name, PARSING_PLAIN, c.alloc), c.alloc))

			args_count := len(typed_node.args)
			if args_count > 0 {
				keys := make([dynamic]string, 0, c.alloc)
				values := make([dynamic]Value, 0, c.alloc)

				for arg, i in typed_node.args {
					real_index := i
					if arg.name != "" {
						for param_name, arg_i in sym.type.param_names {
							if param_name == arg.name {
								real_index = arg_i
								break
							}
						}
					}
					arg_name := sym.type.param_names[real_index]
					param_type := checker.type_kind_to_string(sym.type.param_types[real_index].kind)

					// TODO: fix leaking abstract type (bool or smth) to justmc ir
					ensure(
						param_type == "number" || param_type == "text" ||
						param_type == "variable" || param_type == "array" ||
						param_type == "parameter" || param_type == "enum" ||
						param_type == "location" ||	param_type == "vector" ||
						param_type == "sound" || param_type == "particle" ||
						param_type == "item" || param_type == "game_value" ||
						param_type == "potion" || param_type == "block" ||
						param_type == "map" || param_type == "localized_text", "abstract type leakage")

					arg_value, _ := codegen_gen_expression(c, arg, waits_enum=param_type=="enum")
					append(&keys, fmt.tprintf(`{{\"type\":\"text\",\"text\":\"%s\",\"parsing\":\"plain\"}}`, arg_name))
					append(&values, arg_value)
				}
				append(&op.values, create_named_value("args", create_map_value(keys, values, c.alloc), c.alloc))
			}
			append(c.current_operations, op)
		}
	case ^ast.Argument:
		return codegen_gen_expression(c, typed_node.value, waits_enum)

	case ^ast.Ident:
		sym, exists := checker.lookup_symbol(c.current_scope, typed_node.name)
		ensure(exists, "symbol should exist, if not, something in the middle of pipeline removing it from symbol table, but not from AST!")
		return create_variable_value(typed_node.name, guess_variable_type_by_scope(c, typed_node.name), c.alloc), sym.type.kind

	case ^ast.Basic_Lit:
		content := typed_node.tok.content
		#partial switch typed_node.tok.kind {
		case .Text:
			text_content := content[1:len(content)-1]
			if waits_enum {
				return create_enum_value(text_content, c.alloc), .Enum
			}
			return create_text_value(text_content, get_parsing_type(text_content), c.alloc), .Text
		case .Number:
			num, _ := strconv.parse_f64(content)
			return create_number_value(num, c.alloc), .Number
		case .True:
			return create_number_value(1, c.alloc), .Boolean
		case .False:
			return create_number_value(0, c.alloc), .Boolean
		}
	case ^ast.Binary_Expr:
		result_var := create_variable_value(next_unique_id(c), SCOPE_GAME, c.alloc)
		operator := typed_node.op.kind
		left_val, left_type := codegen_gen_expression(c, typed_node.left, waits_enum)
		right_val, right_type := codegen_gen_expression(c, typed_node.right, waits_enum)

		switch { // TODO: get rid of duplicate code
		case left_type == .Text && right_type == .Text && operator == .Add:
			text_add_op := create_basic_operation("set_variable_text", make_named_values(c.alloc), "", c.alloc)
			append(&text_add_op.values, create_named_value("variable", result_var, c.alloc))
			array_value := create_array_value(make([dynamic]Value, 0, c.alloc), c.alloc)
			append(&array_value.values, left_val)
			append(&array_value.values, right_val)
			append(&text_add_op.values, create_named_value("text", array_value, c.alloc))
			append(&text_add_op.values, create_named_value("merging", create_enum_value("CONCATENATION", c.alloc), c.alloc))
			append(c.current_operations, text_add_op)
			return result_var, .Text

		case left_type == .Number && right_type == .Number && operator == .Add:
			op := create_basic_operation("set_variable_add", make_named_values(c.alloc), "", c.alloc)
			append(&op.values, create_named_value("variable", result_var, c.alloc))
			array_value := create_array_value(make([dynamic]Value, 0, c.alloc), c.alloc)
			append(&array_value.values, left_val)
			append(&array_value.values, right_val)
			append(&op.values, create_named_value("value", array_value, c.alloc))
			append(c.current_operations, op)
			return result_var, .Number

		case left_type == .Number && right_type == .Number && operator == .Sub:
			op := create_basic_operation("set_variable_subtract", make_named_values(c.alloc), "", c.alloc)
			append(&op.values, create_named_value("variable", result_var, c.alloc))
			array_value := create_array_value(make([dynamic]Value, 0, c.alloc), c.alloc)
			append(&array_value.values, left_val)
			append(&array_value.values, right_val)
			append(&op.values, create_named_value("value", array_value, c.alloc))
			append(c.current_operations, op)
			return result_var, .Number

		case left_type == .Number && right_type == .Number && operator == .Mul:
			op := create_basic_operation("set_variable_multiply", make_named_values(c.alloc), "", c.alloc)
			append(&op.values, create_named_value("variable", result_var, c.alloc))
			array_value := create_array_value(make([dynamic]Value, 0, c.alloc), c.alloc)
			append(&array_value.values, left_val)
			append(&array_value.values, right_val)
			append(&op.values, create_named_value("value", array_value, c.alloc))
			append(c.current_operations, op)
			return result_var, .Number

		case left_type == .Number && right_type == .Number && operator == .Quo:
			op := create_basic_operation("set_variable_divide", make_named_values(c.alloc), "", c.alloc)
			append(&op.values, create_named_value("variable", result_var, c.alloc))
			array_value := create_array_value(make([dynamic]Value, 0, c.alloc), c.alloc)
			append(&array_value.values, left_val)
			append(&array_value.values, right_val)
			append(&op.values, create_named_value("value", array_value, c.alloc))
			append(&op.values, create_named_value("division_mode", create_enum_value("default", c.alloc), c.alloc))
			append(c.current_operations, op)
			return result_var, .Number

		case left_type == .Number && right_type == .Number && operator == .Mod:
			op := create_basic_operation("set_variable_remainder", make_named_values(c.alloc), "", c.alloc)
			append(&op.values, create_named_value("variable", result_var, c.alloc))
			append(&op.values, create_named_value("dividend", left_val, c.alloc))
			append(&op.values, create_named_value("divisor", right_val, c.alloc))
			append(&op.values, create_named_value("remainder_mode", create_enum_value("REMAINDER", c.alloc), c.alloc))
			append(c.current_operations, op)
			return result_var, .Number

		case left_type == .Number && right_type == .Number && operator == .Cmp_Eq,
			left_type == .Text && right_type == .Text && operator == .Cmp_Eq,
			left_type == .Boolean && right_type == .Boolean && operator == .Cmp_Eq:

			value_decl_op := create_basic_operation("set_variable_value", make_named_values(c.alloc), "", c.alloc)
			append(&value_decl_op.values, create_named_value("variable", result_var, c.alloc))
			append(&value_decl_op.values, create_named_value("value", create_number_value(0, c.alloc), c.alloc))
			append(c.current_operations, value_decl_op)

			value_decl_op_inner := create_basic_operation("set_variable_value", make_named_values(c.alloc), "", c.alloc)
			append(&value_decl_op_inner.values, create_named_value("variable", result_var, c.alloc))
			append(&value_decl_op_inner.values, create_named_value("value", create_number_value(1, c.alloc), c.alloc))

			op := create_container_operation("if_variable_equals", make_named_values(c.alloc), make_operations(c.alloc), false, "", c.alloc)
			append(&op.values, create_named_value("value", left_val, c.alloc))
			append(&op.values, create_named_value("compare", right_val, c.alloc))
			append(&op.operations, value_decl_op_inner)
			append(c.current_operations, op)
			return result_var, .Boolean

		case left_type == .Number && right_type == .Number && operator == .Not_Eq,
			left_type == .Text && right_type == .Text && operator == .Not_Eq,
			left_type == .Boolean && right_type == .Boolean && operator == .Not_Eq:

			value_decl_op := create_basic_operation("set_variable_value", make_named_values(c.alloc), "", c.alloc)
			append(&value_decl_op.values, create_named_value("variable", result_var, c.alloc))
			append(&value_decl_op.values, create_named_value("value", create_number_value(0, c.alloc), c.alloc))
			append(c.current_operations, value_decl_op)

			value_decl_op_inner := create_basic_operation("set_variable_value", make_named_values(c.alloc), "", c.alloc)
			append(&value_decl_op_inner.values, create_named_value("variable", result_var, c.alloc))
			append(&value_decl_op_inner.values, create_named_value("value", create_number_value(1, c.alloc), c.alloc))

			op := create_container_operation("if_variable_not_equals", make_named_values(c.alloc), make_operations(c.alloc), false, "", c.alloc)
			append(&op.values, create_named_value("value", left_val, c.alloc))
			append(&op.values, create_named_value("compare", right_val, c.alloc))
			append(&op.operations, value_decl_op_inner)
			append(c.current_operations, op)
			return result_var, .Boolean

		case left_type == .Boolean && right_type == .Boolean && operator == .Cmp_And:
			set_false := create_basic_operation("set_variable_value", make_named_values(c.alloc), "", c.alloc)
			append(&set_false.values, create_named_value("variable", result_var, c.alloc))
			append(&set_false.values, create_named_value("value", create_number_value(0, c.alloc), c.alloc))
			append(c.current_operations, set_false)

			set_true := create_basic_operation("set_variable_value", make_named_values(c.alloc), "", c.alloc)
			append(&set_true.values, create_named_value("variable", result_var, c.alloc))
			append(&set_true.values, create_named_value("value", create_number_value(1, c.alloc), c.alloc))

			if_right := create_container_operation("if_variable_equals", make_named_values(c.alloc), make_operations(c.alloc), false, "", c.alloc)
			append(&if_right.values, create_named_value("value", right_val, c.alloc))
			append(&if_right.values, create_named_value("compare", create_number_value(1, c.alloc), c.alloc))
			append(&if_right.operations, set_true)

			if_left := create_container_operation("if_variable_equals", make_named_values(c.alloc), make_operations(c.alloc), false, "", c.alloc)
			append(&if_left.values, create_named_value("value", left_val, c.alloc))
			append(&if_left.values, create_named_value("compare", create_number_value(1, c.alloc), c.alloc))
			append(&if_left.operations, if_right)
			append(c.current_operations, if_left)

			return result_var, .Boolean

		case left_type == .Boolean && right_type == .Boolean && operator == .Cmp_Or:
			set_false := create_basic_operation("set_variable_value", make_named_values(c.alloc), "", c.alloc)
			append(&set_false.values, create_named_value("variable", result_var, c.alloc))
			append(&set_false.values, create_named_value("value", create_number_value(0, c.alloc), c.alloc))
			append(c.current_operations, set_false)

			set_true_left := create_basic_operation("set_variable_value", make_named_values(c.alloc), "", c.alloc)
			append(&set_true_left.values, create_named_value("variable", result_var, c.alloc))
			append(&set_true_left.values, create_named_value("value", create_number_value(1, c.alloc), c.alloc))

			if_left := create_container_operation("if_variable_equals", make_named_values(c.alloc), make_operations(c.alloc), false, "", c.alloc)
			append(&if_left.values, create_named_value("value", left_val, c.alloc))
			append(&if_left.values, create_named_value("compare", create_number_value(1, c.alloc), c.alloc))
			append(&if_left.operations, set_true_left)
			append(c.current_operations, if_left)

			set_true_right := create_basic_operation("set_variable_value", make_named_values(c.alloc), "", c.alloc)
			append(&set_true_right.values, create_named_value("variable", result_var, c.alloc))
			append(&set_true_right.values, create_named_value("value", create_number_value(1, c.alloc), c.alloc))

			if_right := create_container_operation("if_variable_equals", make_named_values(c.alloc), make_operations(c.alloc), false, "", c.alloc)
			append(&if_right.values, create_named_value("value", right_val, c.alloc))
			append(&if_right.values, create_named_value("compare", create_number_value(1, c.alloc), c.alloc))
			append(&if_right.operations, set_true_right)
			append(c.current_operations, if_right)
			return result_var, .Boolean

		case:
			unimplemented(fmt.tprintf("generation of binary expr (%v, %v, %v)", left_type, operator, right_type))
		}
	case:
		unimplemented(fmt.tprintf("%v", typed_node))
	}
	return nil, nil
}

guess_variable_type_by_scope :: proc(c: ^Codegen, variable_name: string) -> string {
	sym, _ := checker.lookup_symbol(c.current_scope, variable_name)
	if sym.type.is_param {
		return SCOPE_LINE
	}
	return SCOPE_GAME
}

codegen_gen :: proc(c: ^Codegen, files: [dynamic]^ast.File, symbols: ^checker.Symbol_Table, minify: bool, unique_id: string) -> string {
	c.symbols = symbols

	for file in files {
		ast.walk_file(&c.walker, file)
	}

	if len(c.entry_handler.operations) > 0 {
		append(&c.handlers, c.entry_handler)
	}

	if len(c.exit_handler.operations) > 0 {
		append(&c.handlers, c.exit_handler)
	}

	json_builder_init(&c.jb, minify, c.alloc)
	return handlers_to_string(&c.jb, c.handlers)
}
