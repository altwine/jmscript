package codegen

import "core:unicode/utf8"
import "core:fmt"
import "core:strconv"
import "core:mem"

import "../ast"
import "../lexer"
import "../checker"
import "../error"
import "../../assets"

// This is compiler-side limit.
RANGE_EXPR_LIST_LIT_HARD_LIMIT :: 128

BLOCKS :: 88
LINES :: 23
FLOORS :: 15

Codegen :: struct {
	alloc: mem.Allocator,
	jb: Json_Builder,
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
	c.alloc = allocator
}

codegen_gen_statement :: proc(c: ^Codegen, stmt: ^ast.Stmt) {
	if stmt == nil {
		return
	}

	if block, is_block := stmt.derived.(^ast.Block_Stmt); is_block {
		if scope, exists := c.symbols.node_scopes[stmt.id]; exists {
			c.current_scope = scope
		}
		for child_stmt in block.stmts {
			codegen_gen_statement(c, child_stmt)
		}
		if scope, exists := c.symbols.node_scopes[stmt.id]; exists {
			if scope.parent != nil {
				c.current_scope = scope.parent
			}
		}
		return
	}

	#partial switch s in stmt.derived {
	case ^ast.Func_Stmt:   codegen_gen_func_stmt(c, s)
	case ^ast.Event_Stmt:  codegen_gen_event_stmt(c, s)
	case ^ast.Expr_Stmt:   codegen_gen_expr_stmt(c, s)
	case ^ast.Assign_Stmt: codegen_gen_assign_stmt(c, s)
	case ^ast.If_Stmt:     codegen_gen_if_stmt(c, s)
	case ^ast.For_Stmt:    codegen_gen_for_stmt(c, s)
	case ^ast.Value_Decl:  codegen_gen_value_decl(c, s)
	case ^ast.Return_Stmt: codegen_gen_return_stmt(c, s)
	case ^ast.Defer_Stmt:  codegen_gen_defer_stmt(c, s)
	case:                  unimplemented(fmt.tprintf("statement type %T", s))
	}
}

codegen_gen_expression :: proc(c: ^Codegen, expr: ^ast.Expr, waits_enum := false) -> (Value, checker.Type_Kind) {
	if expr == nil {
		return nil, .Invalid
	}

	#partial switch e in expr.derived {
	case ^ast.Range_Expr:  return codegen_gen_range_expr(c, e, waits_enum)
	case ^ast.Call_Expr:   return codegen_gen_call_expr(c, e, waits_enum)
	case ^ast.Argument:    return codegen_gen_expression(c, e.value, waits_enum)
	case ^ast.Ident:       return codegen_gen_ident(c, e)
	case ^ast.Basic_Lit:   return codegen_gen_basic_lit(c, e, waits_enum)
	case ^ast.Binary_Expr: return codegen_gen_binary_expr(c, e, waits_enum)
	case ^ast.Unary_Expr:  return codegen_gen_unary_expr(c, e, waits_enum)
	case ^ast.Paren_Expr:  return codegen_gen_expression(c, e.expr, waits_enum)
	case:                  unimplemented(fmt.tprintf("expression type %v", e))
	}
	return nil, .Invalid
}

codegen_gen_func_stmt :: proc(c: ^Codegen, node: ^ast.Func_Stmt) {
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

	ensure(len(node.params.list) <= 7, "slots overflow")

	if len(node.params.list) > 0 {
		parameters_inner := create_array_value(make_values(c.alloc), c.alloc)

		for param, param_index in node.params.list {
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
			param_data := create_parameter_value("singular", "", param.name, param.type, slot, desc_slot, "true", "{}", c.alloc)
			append(&parameters_inner.values, param_data)
		}
		parameters := create_named_value("parameters", parameters_inner, c.alloc)
		append(&func_handler.values, parameters)
	}

	append(&c.handlers, func_handler)
	push_operations(c, &func_handler.operations)

	if node.body != nil {
		codegen_gen_statement(c, node.body)
	}

	pop_operations(c)
}

codegen_gen_event_stmt :: proc(c: ^Codegen, node: ^ast.Event_Stmt) {
	event_handler := create_event_handler(node.name, make_operations(c.alloc), c.alloc)
	append(&c.handlers, event_handler)
	push_operations(c, &event_handler.operations)
	if node.body != nil {
		codegen_gen_statement(c, node.body)
	}
	pop_operations(c)
}

codegen_gen_expr_stmt :: proc(c: ^Codegen, node: ^ast.Expr_Stmt) {
	codegen_gen_expression(c, node.expr)
}

codegen_gen_assign_stmt :: proc(c: ^Codegen, node: ^ast.Assign_Stmt) {
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
		array_value := create_array_value(make_values(c.alloc), c.alloc)
		append(&array_value.values, current_var)
		append(&array_value.values, result_value)
		append(&op.values, create_named_value("value", array_value, c.alloc))

	case .Sub_Eq:
		op = create_basic_operation("set_variable_subtract", make_named_values(c.alloc), "", c.alloc)
		append(&op.values, create_named_value("variable", current_var, c.alloc))
		array_value := create_array_value(make_values(c.alloc), c.alloc)
		append(&array_value.values, current_var)
		append(&array_value.values, result_value)
		append(&op.values, create_named_value("value", array_value, c.alloc))

	case .Mul_Eq:
		op = create_basic_operation("set_variable_multiply", make_named_values(c.alloc), "", c.alloc)
		append(&op.values, create_named_value("variable", current_var, c.alloc))
		array_value := create_array_value(make_values(c.alloc), c.alloc)
		append(&array_value.values, current_var)
		append(&array_value.values, result_value)
		append(&op.values, create_named_value("value", array_value, c.alloc))

	case .Quo_Eq:
		op = create_basic_operation("set_variable_divide", make_named_values(c.alloc), "", c.alloc)
		append(&op.values, create_named_value("variable", current_var, c.alloc))
		array_value := create_array_value(make_values(c.alloc), c.alloc)
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

codegen_gen_if_stmt :: proc(c: ^Codegen, node: ^ast.If_Stmt) {
	if node.init != nil {
		codegen_gen_statement(c, node.init)
	}

	if_stmt_result, res_type := codegen_gen_expression(c, node.cond)

	op := create_container_operation("if_variable_equals", make_named_values(c.alloc), make_operations(c.alloc), allocator=c.alloc)
	append(&op.values, create_named_value("value", if_stmt_result, c.alloc))
	append(&op.values, create_named_value("compare", create_number_value(1, c.alloc), c.alloc))
	append(c.current_operations, op)

	push_operations(c, &op.operations)

	if node.body != nil {
		codegen_gen_statement(c, node.body)
	}

	if node.else_stmt != nil {
		unimplemented("else body in if statement")
	}

	pop_operations(c)

	if node.else_stmt != nil {
		else_op := create_container_operation("if_variable_equals", make_named_values(c.alloc), make_operations(c.alloc), allocator=c.alloc)
		append(&else_op.values, create_named_value("value", if_stmt_result, c.alloc))
		append(&else_op.values, create_named_value("compare", create_number_value(0, c.alloc), c.alloc))
		append(c.current_operations, else_op)

		push_operations(c, &else_op.operations)

		codegen_gen_statement(c, node.else_stmt)

		pop_operations(c)
	}
}

codegen_gen_for_stmt :: proc(c: ^Codegen, node: ^ast.For_Stmt) {
	switch node.type {
	case .Basic:
		if node.init != nil {
			codegen_gen_statement(c, node.init)
		}
		loop_container := create_container_operation("repeat_forever", make_named_values(c.alloc), make_operations(c.alloc), allocator=c.alloc)
		append(c.current_operations, loop_container)
		push_operations(c, &loop_container.operations)

		if node.cond != nil {
			cond_value, cond_type := codegen_gen_expression(c, node.cond)

			break_cond := create_container_operation("if_variable_equals", make_named_values(c.alloc), make_operations(c.alloc), allocator=c.alloc)
			append(&break_cond.values, create_named_value("value", cond_value, c.alloc))
			append(&break_cond.values, create_named_value("compare", create_number_value(0, c.alloc), c.alloc))
			append(&loop_container.operations, break_cond)

			break_op := create_basic_operation("control_stop_repeat", make_named_values(c.alloc), "", c.alloc)
			append(&break_cond.operations, break_op)
		}

		if node.body != nil {
			codegen_gen_statement(c, node.body)
		}

		if node.post != nil {
			codegen_gen_statement(c, node.post)
		}

		pop_operations(c)

	case .Unconditional:
		op := create_container_operation("repeat_forever", make_named_values(c.alloc), make_operations(c.alloc), allocator=c.alloc)
		append(c.current_operations, op)
		push_operations(c, &op.operations)
		if node.body != nil {
			codegen_gen_statement(c, node.body)
		}
		pop_operations(c)

	case .Conditional:
		if node.init != nil {
			codegen_gen_statement(c, node.init)
		}
		loop_container := create_container_operation("repeat_forever", make_named_values(c.alloc), make_operations(c.alloc), allocator=c.alloc)
		append(c.current_operations, loop_container)
		push_operations(c, &loop_container.operations)
		if node.cond != nil {
			cond_value, cond_type := codegen_gen_expression(c, node.cond)

			break_cond := create_container_operation("if_variable_equals", make_named_values(c.alloc), make_operations(c.alloc), true, "", c.alloc)
			append(&break_cond.values, create_named_value("value", cond_value, c.alloc))
			append(&break_cond.values, create_named_value("compare", create_number_value(1, c.alloc), c.alloc))

			break_op := create_basic_operation("control_stop_repeat", make_named_values(c.alloc), "", c.alloc)
			append(&break_cond.operations, break_op)
			append(&loop_container.operations, break_cond)
		}
		if node.body != nil {
			codegen_gen_statement(c, node.body)
		}
		pop_operations(c)

	case .Range:
		loop_container := create_container_operation("repeat_for_each_in_list", make_named_values(c.alloc), make_operations(c.alloc), allocator=c.alloc)
		append(c.current_operations, loop_container)
		push_operations(c, &loop_container.operations)
		if node.body != nil {
			codegen_gen_statement(c, node.body)
		}

		if len(node.range_vars) > 0 {
			append(&loop_container.values, create_named_value("value_variable", create_variable_value(node.range_vars[0].name, guess_variable_type_by_scope(c, node.range_vars[0].name), c.alloc), c.alloc))
		}
		if len(node.range_vars) > 1 {
			append(&loop_container.values, create_named_value("index_variable", create_variable_value(node.range_vars[1].name, guess_variable_type_by_scope(c, node.range_vars[1].name), c.alloc), c.alloc))
		}
		if node.cond != nil {
			#partial switch v in node.cond.derived {
			case ^ast.Basic_Lit:
				result_value := decompose_basic_lit_into_array_lit(c, v)
				append(&loop_container.values, create_named_value("list", result_value, c.alloc))
			}
		}
		if node.range_expr != nil {
			result_value, _ := codegen_gen_expression(c, node.range_expr, false)
			append(&loop_container.values, create_named_value("list", result_value, c.alloc))
		}
		pop_operations(c)
	}
}

codegen_gen_value_decl :: proc(c: ^Codegen, node: ^ast.Value_Decl) {
	value_decl_op := create_basic_operation("set_variable_value", make_named_values(c.alloc), "", c.alloc)
	append(&value_decl_op.values, create_named_value("variable", create_variable_value(node.name, guess_variable_type_by_scope(c, node.name), c.alloc), c.alloc))
	result_value, _ := codegen_gen_expression(c, node.value)
	append(&value_decl_op.values, create_named_value("value", result_value, c.alloc))
	append(c.current_operations, value_decl_op)
}

codegen_gen_return_stmt :: proc(c: ^Codegen, node: ^ast.Return_Stmt) {
	unimplemented("return statement support")
}

codegen_gen_defer_stmt :: proc(c: ^Codegen, node: ^ast.Defer_Stmt) {
	unimplemented("defer statement support")
}

codegen_gen_call_expr :: proc(c: ^Codegen, node: ^ast.Call_Expr, waits_enum: bool) -> (Value, checker.Type_Kind) {
	result_var := create_variable_value(next_unique_id(c), SCOPE_GAME, c.alloc)
	ident, is_ident := node.expr.derived.(^ast.Ident)
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
		for arg, i in node.args {
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
		op := create_basic_operation("call_function", make_named_values(c.alloc), "", c.alloc)
		append(&op.values, create_named_value("function_name", create_text_value(func_name, PARSING_PLAIN, c.alloc), c.alloc))

		args_count := len(node.args)
		if args_count > 0 {
			keys := make([dynamic]string, 0, c.alloc)
			values := make_values(c.alloc)

			for arg, i in node.args {
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
	return result_var, .Number
}


// TODO: maybe remove waits_enum, do we really even need it everywhere


codegen_gen_range_expr :: proc(c: ^Codegen, node: ^ast.Range_Expr, waits_enum: bool) -> (Value, checker.Type_Kind) {
	array_values := make_values(c.alloc)
	start, is_lit := node.start_expr.derived.(^ast.Basic_Lit)
	end, _is_lit := node.end_expr.derived.(^ast.Basic_Lit)
	if !(is_lit && _is_lit) {
		unimplemented("codegen of range expressions other than literal...literal")
	}
	start_num, _ := strconv.parse_f64(start.tok.content)
	end_num, _ := strconv.parse_f64(end.tok.content)
	if node.kind == .Inclusive {
		end_num += 1
	}
	if end_num - start_num > RANGE_EXPR_LIST_LIT_HARD_LIMIT {
		unimplemented(fmt.tprintf("codegen of ranges: can't generate more than %d elements", RANGE_EXPR_LIST_LIT_HARD_LIMIT))
	}
	for i := start_num; i < end_num; i += 1 {
		append(&array_values, create_number_value(i, c.alloc))
	}
	return create_array_value(array_values, c.alloc), .Array
}

codegen_gen_ident :: proc(c: ^Codegen, node: ^ast.Ident) -> (Value, checker.Type_Kind) {
	sym, exists := checker.lookup_symbol(c.current_scope, node.name)
	ensure(exists, "symbol should exist, if not, something in the middle of pipeline removing it from symbol table, but not from AST!")
	return create_variable_value(node.name, guess_variable_type_by_scope(c, node.name), c.alloc), sym.type.kind
}

codegen_gen_basic_lit :: proc(c: ^Codegen, node: ^ast.Basic_Lit, waits_enum: bool) -> (Value, checker.Type_Kind) {
	content := node.tok.content
	#partial switch node.tok.kind {
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
	return nil, .Invalid
}

codegen_gen_binary_expr :: proc(c: ^Codegen, node: ^ast.Binary_Expr, waits_enum: bool) -> (Value, checker.Type_Kind) {
	result_var := create_variable_value(next_unique_id(c), SCOPE_GAME, c.alloc)
	operator := node.op.kind
	left_val, left_type := codegen_gen_expression(c, node.left, waits_enum)
	right_val, right_type := codegen_gen_expression(c, node.right, waits_enum)

	switch {
	case left_type == .Text && right_type == .Text && operator == .Add:
		text_add_op := create_basic_operation("set_variable_text", make_named_values(c.alloc), "", c.alloc)
		append(&text_add_op.values, create_named_value("variable", result_var, c.alloc))
		array_value := create_array_value(make_values(c.alloc), c.alloc)
		append(&array_value.values, left_val)
		append(&array_value.values, right_val)
		append(&text_add_op.values, create_named_value("text", array_value, c.alloc))
		append(&text_add_op.values, create_named_value("merging", create_enum_value("CONCATENATION", c.alloc), c.alloc))
		append(c.current_operations, text_add_op)
		return result_var, .Text

	case left_type == .Number && right_type == .Number && operator == .Add:
		op := create_basic_operation("set_variable_add", make_named_values(c.alloc), "", c.alloc)
		append(&op.values, create_named_value("variable", result_var, c.alloc))
		array_value := create_array_value(make_values(c.alloc), c.alloc)
		append(&array_value.values, left_val)
		append(&array_value.values, right_val)
		append(&op.values, create_named_value("value", array_value, c.alloc))
		append(c.current_operations, op)
		return result_var, .Number

	case left_type == .Number && right_type == .Number && operator == .Sub:
		op := create_basic_operation("set_variable_subtract", make_named_values(c.alloc), "", c.alloc)
		append(&op.values, create_named_value("variable", result_var, c.alloc))
		array_value := create_array_value(make_values(c.alloc), c.alloc)
		append(&array_value.values, left_val)
		append(&array_value.values, right_val)
		append(&op.values, create_named_value("value", array_value, c.alloc))
		append(c.current_operations, op)
		return result_var, .Number

	case left_type == .Number && right_type == .Number && operator == .Mul:
		op := create_basic_operation("set_variable_multiply", make_named_values(c.alloc), "", c.alloc)
		append(&op.values, create_named_value("variable", result_var, c.alloc))
		array_value := create_array_value(make_values(c.alloc), c.alloc)
		append(&array_value.values, left_val)
		append(&array_value.values, right_val)
		append(&op.values, create_named_value("value", array_value, c.alloc))
		append(c.current_operations, op)
		return result_var, .Number

	case left_type == .Number && right_type == .Number && operator == .Quo:
		op := create_basic_operation("set_variable_divide", make_named_values(c.alloc), "", c.alloc)
		append(&op.values, create_named_value("variable", result_var, c.alloc))
		array_value := create_array_value(make_values(c.alloc), c.alloc)
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

		op := create_container_operation("if_variable_equals", make_named_values(c.alloc), make_operations(c.alloc), allocator=c.alloc)
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

		op := create_container_operation("if_variable_not_equals", make_named_values(c.alloc), make_operations(c.alloc), allocator=c.alloc)
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

		if_right := create_container_operation("if_variable_equals", make_named_values(c.alloc), make_operations(c.alloc), allocator=c.alloc)
		append(&if_right.values, create_named_value("value", right_val, c.alloc))
		append(&if_right.values, create_named_value("compare", create_number_value(1, c.alloc), c.alloc))
		append(&if_right.operations, set_true)

		if_left := create_container_operation("if_variable_equals", make_named_values(c.alloc), make_operations(c.alloc), allocator=c.alloc)
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

		if_left := create_container_operation("if_variable_equals", make_named_values(c.alloc), make_operations(c.alloc), allocator=c.alloc)
		append(&if_left.values, create_named_value("value", left_val, c.alloc))
		append(&if_left.values, create_named_value("compare", create_number_value(1, c.alloc), c.alloc))
		append(&if_left.operations, set_true_left)
		append(c.current_operations, if_left)

		set_true_right := create_basic_operation("set_variable_value", make_named_values(c.alloc), "", c.alloc)
		append(&set_true_right.values, create_named_value("variable", result_var, c.alloc))
		append(&set_true_right.values, create_named_value("value", create_number_value(1, c.alloc), c.alloc))

		if_right := create_container_operation("if_variable_equals", make_named_values(c.alloc), make_operations(c.alloc), allocator=c.alloc)
		append(&if_right.values, create_named_value("value", right_val, c.alloc))
		append(&if_right.values, create_named_value("compare", create_number_value(1, c.alloc), c.alloc))
		append(&if_right.operations, set_true_right)
		append(c.current_operations, if_right)
		return result_var, .Boolean

	case:
		unimplemented(fmt.tprintf("generation of binary expr (%v, %v, %v)", left_type, operator, right_type))
	}
	return nil, .Invalid
}

codegen_gen_unary_expr :: proc(c: ^Codegen, node: ^ast.Unary_Expr, waits_enum: bool) -> (Value, checker.Type_Kind) {
	unimplemented("unary expression support")
}

decompose_basic_lit_into_array_lit :: proc(c: ^Codegen, basic_lit: ^ast.Basic_Lit) -> ^ArrayValue {
	array_value := create_array_value(make_values(c.alloc), c.alloc)

	#partial switch basic_lit.tok.kind {
	case .Text:
		text_content := basic_lit.tok.content[1:len(basic_lit.tok.content)-1]
		for r in text_content {
			append(&array_value.values, create_text_value(utf8.runes_to_string({r}, c.alloc), PARSING_PLAIN, c.alloc))
		}
	case: unimplemented(fmt.tprintf("decomposition of %s literal", lexer.to_string(basic_lit.tok.kind)))
	}

	return array_value
}

guess_variable_type_by_scope :: proc(c: ^Codegen, variable_name: string) -> string {
	if variable_name == "_" {
		return SCOPE_LINE
	}

	sym, exist := checker.lookup_symbol(c.current_scope, variable_name)
	ensure(exist)
	if sym.type.is_param || sym.type.from_for_head {
		return SCOPE_LINE
	}
	return SCOPE_GAME
}

codegen_gen :: proc(c: ^Codegen, files: [dynamic]^ast.File, symbols: ^checker.Symbol_Table, minify: bool, unique_id: string) -> string {
	c.symbols = symbols
	for file in files {
		for decl in file.decls {
			codegen_gen_statement(c, decl)
		}
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
