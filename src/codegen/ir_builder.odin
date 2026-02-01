package codegen

import "core:slice"
import "core:strconv"
import "core:fmt"
import "core:mem"
import "core:strings"

import "../ast"
import "../lexer"
import "../checker"
import "../error"
import "../../assets"

IR_Builder :: struct {
	jb: Json_Builder,
	handlers: [dynamic]^Handler,
	curr_file: ^ast.File,
	entry_handler: ^Handler,
	unique_id: string,
	minify: bool,
	symbols: ^checker.Symbol_Table,
	handler_index: int,
	inner_names_index: int,
	alloc: mem.Allocator,
	errs: [dynamic]error.Error,
}

ir_builder_init :: proc(irb: ^IR_Builder, minify: bool, unique_id: string, symbols: ^checker.Symbol_Table, allocator := context.allocator) {
	irb.errs = make([dynamic]error.Error, allocator)
	irb.alloc = allocator
	irb.unique_id = unique_id
	irb.symbols = symbols
	irb.minify = minify
	irb.handler_index = -1
	irb.handlers = make([dynamic]^Handler, irb.alloc)
	irb.entry_handler = new_handler(irb, "event", "world_start")
	json_builder_init(&irb.jb, irb.minify, irb.alloc)
}

ir_add_error :: proc(irb: ^IR_Builder, message: string, node: ^ast.Node) {
	cause_pos, cause_end: lexer.Pos
	if node != nil {
		cause_pos, cause_end = node.pos, node.end
	}
	err := error.Error{
		file=irb.curr_file,
		message=message,
		cause_pos=cause_pos,
		cause_end=cause_end,
	}
	append(&irb.errs, err)
}

ir_add_warning :: proc(irb: ^IR_Builder, message: string, node: ^ast.Node) {
	cause_pos, cause_end: lexer.Pos
	if node != nil {
		cause_pos, cause_end = node.pos, node.end
	}
	warn := error.Error{
		file=irb.curr_file,
		message=message,
		severity=.Warning,
		cause_pos=cause_pos,
		cause_end=cause_end,
	}
	append(&irb.errs, warn)
}

ir_parse_stmt :: proc(irb: ^IR_Builder, stmt: ^ast.Stmt) -> [dynamic]Operation {
	ops := make([dynamic]Operation, irb.alloc)
	if stmt == nil {
		return ops
	}
	#partial switch v in stmt.derived {
	case ^ast.Block_Stmt:
		block_stmt := cast(^ast.Block_Stmt)stmt
		for stmt2 in block_stmt.stmts {
			ops2 := ir_parse_stmt(irb, stmt2)
			append_operations(&ops, ops2)
		}
	case ^ast.Expr_Stmt:
		expr_stmt := cast(^ast.Expr_Stmt)stmt
		ops2, _ := ir_parse_expression(irb, expr_stmt.expr)
		append_operations(&ops, ops2)
	case ^ast.If_Stmt:
		if_stmt := cast(^ast.If_Stmt)stmt
		cond := if_stmt.cond
		body := if_stmt.body
		body_ops := ir_parse_stmt(irb, body)
		else_body_ops := ir_parse_stmt(irb, if_stmt.else_stmt)
		#partial switch v in cond.derived {
		case ^ast.Binary_Expr:
			cond_binary_expr := cast(^ast.Binary_Expr)cond
			cond_binary_expr_op_kind := cond_binary_expr.op.kind
			left_ops, left_value := ir_parse_expression(irb, cond_binary_expr.left)
			right_ops, right_value := ir_parse_expression(irb, cond_binary_expr.right)
			append_operations(&ops, left_ops)
			append_operations(&ops, right_ops)
			values := make([dynamic]NamedValue, irb.alloc)
			append(&values, named_value("value", left_value))
			append(&values, named_value("compare", right_value))
			action_name: string
			#partial switch cond_binary_expr_op_kind {
			case .Cmp_Eq:
				action_name = "if_variable_equals"
			case .Not_Eq:
				action_name = "if_variable_not_equals"
			case .Lt:
				action_name = "if_variable_less"
			case .Lt_Eq:
				action_name = "if_variable_less_or_equals"
			case .Gt:
				action_name = "if_variable_greater"
			case .Gt_Eq:
				action_name = "if_variable_greater_or_equals"
			case:
				fmt.printfln("Unhandled operation type in if_stmt: %v", lexer.to_string(cond_binary_expr.op.kind))
				break
			}
			append(&ops, container_operation(action_name, values, body_ops ))
		case ^ast.Call_Expr:
			cond_call_expr := cast(^ast.Call_Expr)cond
			call_expr := cond_call_expr.expr
			call_args := cond_call_expr.args

			call_args_values := make([dynamic]Value, irb.alloc)
			for call_arg in call_args {
				call_arg_ops, call_arg_value := ir_parse_expression(irb, call_arg)
				append_operations(&ops, call_arg_ops)
				append(&call_args_values, call_arg_value)
			}
			#partial switch v in call_expr.derived {
			case ^ast.Ident:
				ident := cast(^ast.Ident)call_expr
				ident_name := ident.name
				action, is_exist := assets.action_native_from_mapped(ident_name)
				if !is_exist {
					fmt.printfln("Unknown conditional action")
					break
				}
				values := make([dynamic]NamedValue, irb.alloc)
				if action.type != .CONTAINER {
					fmt.printfln("(user error) Unhandled if stmt, container action expected: %v ", if_stmt)
					break
				}
				if len(call_args_values) > len(action.slots) {
					fmt.printfln("(user error) Unhandled if stmt, too much input variables, expected %d or less but got %d: %v", len(call_args_values), len(action.slots), if_stmt)
					break
				}
				for call_arg_value, call_arg_value_index in call_args_values {
					append(&values, named_value(action.slots[call_arg_value_index].name, call_arg_value))
				}
				append(&ops, container_operation(action.name, values, body_ops))
			case:
				fmt.printfln("Unhandled if_stmt: %v", v)
				break
			}
		case:
			fmt.printfln("Unhandled expression type in if_stmt: %v", v)
			break
		}
		if len(else_body_ops) > 0 {
			empty_values := make([dynamic]NamedValue, irb.alloc)
			append(&ops, container_operation("else", empty_values, else_body_ops))
		}
	case ^ast.For_Stmt:
		for_stmt := cast(^ast.For_Stmt)stmt
		if for_stmt.init == nil && for_stmt.cond == nil && for_stmt.post == nil && for_stmt.second_cond == nil {
			ops3 := ir_parse_stmt(irb, for_stmt.body)
			values := make([dynamic]NamedValue, irb.alloc)
			append(&ops, container_operation("repeat_forever", values, ops3))
		} else {
			ir_add_error(irb, "repeats are temporarily disabled", for_stmt)
			// if for_stmt.init != nil && for_stmt.cond != nil && for_stmt.post == nil && for_stmt.second_cond == nil {
			// 	init_ident := for_stmt.init
			// 	cond_expr := for_stmt.cond
			// 	#partial switch v in cond_expr.derived {
			// 	case ^ast.Call_Expr:
			// 		cond_expr_call_expr := cast(^ast.Call_Expr)cond_expr
			// 		#partial switch v in cond_expr_call_expr.expr.derived {
			// 		case ^ast.Ident:
			// 			ident := cast(^ast.Ident)cond_expr_call_expr.expr
			// 			ident_name := ident.name
			// 			action, is_exist := assets.action_native_from_mapped(ident_name)
			// 			if !is_exist {
			// 				fmt.printfln("Unknown repeat action")
			// 				break
			// 			}
			// 			if action.type != .CONTAINER {
			// 				fmt.printfln("Unhandled4 for loop construction, non-container action: %v", for_stmt)
			// 				break
			// 			}
			// 			if len(init_ident) > len(action.out_slots) {
			// 				fmt.printfln("(user error) Unhandled5 for loop construction, too much output variables, expected %d or less but got %d: %v", len(action.out_slots), len(init_ident), for_stmt)
			// 				break
			// 			}
			// 			if len(cond_expr_call_expr.args) > len(action.in_slots) {
			// 				fmt.printfln("(user error) Unhandled6 for loop construction, too much input variables, expected %d or less but got %d: %v", len(cond_expr_call_expr.args), len(action.in_slots), for_stmt)
			// 				break
			// 			}
			// 			argvalues := make([dynamic]Value, irb.alloc)
			// 			for arg_expr in cond_expr_call_expr.args {
			// 				opsops, val := ir_parse_expression(irb, arg_expr)
			// 				append_operations(&ops, opsops)
			// 				append(&argvalues, val)
			// 			}
			// 			result_ops := make([dynamic]Operation, irb.alloc)
			// 			ops3 := ir_parse_stmt(irb, for_stmt.body)

			// 			if ident_name == "repeat_multi_times" && len(init_ident) == 1 {
			// 				values1 := make([dynamic]NamedValue, irb.alloc)
			// 				res_var := variable_value(init_ident[0].name, SCOPE_LOCAL)
			// 				append(&values1, named_value("variable", res_var))
			// 				append(&values1, named_value("number", number_value(1)))
			// 				append(&result_ops, basic_operation("set_variable_decrement", values1))
			// 			}
			// 			values := make([dynamic]NamedValue, irb.alloc)
			// 			for idnt, idnt_idx in init_ident {
			// 				append(&values, named_value(action.out_slots[idnt_idx], variable_value(idnt.name, SCOPE_LOCAL)))
			// 			}
			// 			for argvalue, argvalue_index in argvalues {
			// 				append(&values, named_value(action.in_slots[argvalue_index], argvalue))
			// 			}
			// 			append_operations(&result_ops, ops3)
			// 			append(&ops, container_operation(action.name, values, result_ops))
			// 		case:
			// 			fmt.printfln("[DEBUG] Unhandled1 for loop construction: %v", for_stmt)
			// 		}
			// 	case:
			// 		fmt.printfln("[DEBUG] Unhandled2 for loop construction: %v", for_stmt)
			// 	}
			// }
		}
	case ^ast.Value_Decl:
		value_decl := cast(^ast.Value_Decl)stmt
		values := make([dynamic]NamedValue, irb.alloc)
		append(&values, named_value("variable", variable_value(value_decl.name, SCOPE_LOCAL)))
		ops2, var := ir_parse_expression(irb, value_decl.value)
		append_operations(&ops, ops2)
		append(&values, named_value("value", var))
		append(&ops, basic_operation("set_variable_value", values))
	case ^ast.Assign_Stmt:
		assign_stmt := cast(^ast.Assign_Stmt)stmt
		values := make([dynamic]NamedValue, irb.alloc)
		result_var := variable_value(assign_stmt.name, SCOPE_LOCAL)
		append(&values, named_value("variable", result_var))
		ops2, var := ir_parse_expression(irb, assign_stmt.expr)
		append_operations(&ops, ops2)
		#partial switch assign_stmt.op.kind {
		case .Add_Eq, .Sub_Eq, .Quo_Eq, .Mul_Eq:
			array_values := make([dynamic]Value, irb.alloc)
			append(&array_values, result_var)
			append(&array_values, var)
			append(&values, named_value("value", array_value(array_values)))
			action_name: string
			#partial switch assign_stmt.op.kind {
			case .Add_Eq: action_name = "set_variable_add"
			case .Sub_Eq: action_name = "set_variable_subtract"
			case .Quo_Eq: action_name = "set_variable_divide"
			case .Mul_Eq: action_name = "set_variable_multiply"
			}
			append(&ops, basic_operation(action_name, values))
		case .Eq:
			append(&values, named_value("value", var))
			append(&ops, basic_operation("set_variable_value", values))
		}
	case:
		fmt.printfln("Unhandled %v", v)
	}
	return ops
}

ir_builder_append_file :: proc(irb: ^IR_Builder, file: ^ast.File) {
	irb.curr_file = file
	for decl in file.decls {
		#partial switch typed_stmt in decl.derived {
		case:
			ops := ir_parse_stmt(irb, decl)
			append_operations(&irb.entry_handler.operations, ops)
		case ^ast.Func_Stmt:
			func_handler := new_handler(irb, "function", typed_stmt.name)
			ops := ir_parse_stmt(irb, typed_stmt.body)
			append_operations(&func_handler.operations, ops)
			func_handler.values = make([dynamic]NamedValue, irb.alloc)

			translations_template :: `{{\"translations\":{{\"en-US\":{{\"rawText\":\"%s\",\"parsingType\":\"LEGACY\"},\"ru-RU\":{{\"rawText\":\"%s\",\"parsingType\":\"LEGACY\"},\"ua-UA\":{{\"rawText\":\"%s\",\"parsingType\":\"LEGACY\"},\"fallback\":{{\"rawText\":\"%s\",\"parsingType\":\"LEGACY\"}}}`

			if name_anno := checker.get_anno(typed_stmt, "name"); name_anno != nil {
				if name_anno.value != nil {
					if basic_lit, is_basic_lit := name_anno.value.derived.(^ast.Basic_Lit); is_basic_lit {
						if basic_lit.tok.kind == .Text {
							anno_content := basic_lit.tok.content[1:len(basic_lit.tok.content)-1]
							display_name_data := fmt.tprintf(translations_template, anno_content, anno_content, anno_content, anno_content)
							append(&func_handler.values, named_value("display_name", localized_text_value(display_name_data)))
						}
					}
				}
			}

			if desc_anno := checker.get_anno(typed_stmt, "desc"); desc_anno != nil {
				if desc_anno.value != nil {
					if basic_lit, is_basic_lit := desc_anno.value.derived.(^ast.Basic_Lit); is_basic_lit {
						if basic_lit.tok.kind == .Text {
							anno_content := basic_lit.tok.content[1:len(basic_lit.tok.content)-1]
							display_desc_data := fmt.tprintf(translations_template, anno_content, anno_content, anno_content, anno_content)
							append(&func_handler.values, named_value("display_description", localized_text_value(display_desc_data)))
						}
					}
				}
			}

			if icon_anno := checker.get_anno(typed_stmt, "icon"); icon_anno != nil {
				if icon_anno.value != nil {
					if basic_lit, is_basic_lit := icon_anno.value.derived.(^ast.Basic_Lit); is_basic_lit {
						if basic_lit.tok.kind == .Text {
							item_id := basic_lit.tok.content[1:len(basic_lit.tok.content)-1]
							func_icon := generate_item(irb, item_id, 1, irb.alloc)
							append(&func_handler.values, named_value("icon", item_value(func_icon)))
						}
					}
				}
			}

			if checker.anno_is_true(typed_stmt, "hidden") {
				append(&func_handler.values, named_value("is_hidden", enum_value("TRUE")))
			}

			append(&irb.handlers, func_handler)
		case ^ast.Event_Stmt:
			event_handler := new_handler(irb, "event", typed_stmt.name)
			ops := ir_parse_stmt(irb, typed_stmt.body)
			append_operations(&event_handler.operations, ops)
			append(&irb.handlers, event_handler)
		}
	}
}

new_handler :: proc(irb: ^IR_Builder, type: string, name: string) -> ^Handler {
	handler := new(Handler, irb.alloc)
	handler.type = type
	if type == "event" {
		handler.event = name
	} else {
		handler.name = name
	}
	handler.operations = make([dynamic]Operation, irb.alloc)
	return handler
}

ir_parse_expression :: proc(irb: ^IR_Builder, expr: ^ast.Expr) -> ([dynamic]Operation, Value) {
	operations_list := make([dynamic]Operation, irb.alloc)
	result_value: Value

	#partial expr_type_switch: switch typed_stmt in expr.derived {
	case ^ast.Ident:
		result_value = variable_value(typed_stmt.name, SCOPE_LOCAL)
	case ^ast.Basic_Lit:
		#partial switch typed_stmt.tok.kind {
		case .Ident:
			ident_raw := typed_stmt.tok.content
			result_value = variable_value(ident_raw, SCOPE_LOCAL)
		case .Number:
			number_raw := typed_stmt.tok.content
			num, _ := strconv.parse_f64(number_raw)
			result_value = number_value(num)
		case .Text:
			text_raw := typed_stmt.tok.content
			result_value = text_value(text_raw[1:len(text_raw)-1], PARSING_COLORED)
		case .True:
			result_value = number_value(1)
		case .False:
			result_value = number_value(0)
		case:
			fmt.printfln("[DEBUG] UNHANDLED BASIC LITERAL WITH TYPE %s", lexer.to_string(typed_stmt.tok.kind))
		}
	case ^ast.Binary_Expr:
		ops1, left_expr := ir_parse_expression(irb, typed_stmt.left)
		append_operations(&operations_list, ops1)
		ops2, right_expr := ir_parse_expression(irb, typed_stmt.right)
		append_operations(&operations_list, ops2)

		#partial switch typed_stmt.op.kind {
		case .Add, .Sub, .Mul, .Quo:
			result_value = variable_value(get_new_inner_name(irb), SCOPE_LOCAL)
			values := make([dynamic]NamedValue, irb.alloc)
			append(&values, named_value("variable", result_value))
			array_values := make([dynamic]Value, irb.alloc)
			append(&array_values, left_expr)
			append(&array_values, right_expr)
			append(&values, named_value("value", array_value(array_values)))
			action_name: string
			#partial switch typed_stmt.op.kind {
			case .Add: action_name = "set_variable_add"
			case .Sub: action_name = "set_variable_subtract"
			case .Quo: action_name = "set_variable_divide"
			case .Mul: action_name = "set_variable_multiply"
			}
			append(&operations_list, basic_operation(action_name, values))

		case .Mod:
			result_value = variable_value(get_new_inner_name(irb), SCOPE_LOCAL)
			values := make([dynamic]NamedValue, irb.alloc)
			append(&values, named_value("variable", result_value))
			append(&values, named_value("dividend", left_expr))
			append(&values, named_value("divisor", right_expr))

			append(&operations_list, basic_operation("set_variable_remainder", values))

		case .Eq: fmt.printfln("[DEBUG] UNHANDLED BINARY EXPR OP: %s", lexer.to_string(typed_stmt.op.kind))
		case .Not: fmt.printfln("[DEBUG] UNHANDLED BINARY EXPR OP: %s", lexer.to_string(typed_stmt.op.kind))
		case .Hash: fmt.printfln("[DEBUG] UNHANDLED BINARY EXPR OP: %s", lexer.to_string(typed_stmt.op.kind))
		case .At: fmt.printfln("[DEBUG] UNHANDLED BINARY EXPR OP: %s", lexer.to_string(typed_stmt.op.kind))
		case .Cmp_And: fmt.printfln("[DEBUG] UNHANDLED BINARY EXPR OP: %s", lexer.to_string(typed_stmt.op.kind))
		case .Cmp_Or: fmt.printfln("[DEBUG] UNHANDLED BINARY EXPR OP: %s", lexer.to_string(typed_stmt.op.kind))
		case .Cmp_Eq: fmt.printfln("[DEBUG] UNHANDLED BINARY EXPR OP: %s", lexer.to_string(typed_stmt.op.kind))
		case .Not_Eq: fmt.printfln("[DEBUG] UNHANDLED BINARY EXPR OP: %s", lexer.to_string(typed_stmt.op.kind))
		case .Lt: fmt.printfln("[DEBUG] UNHANDLED BINARY EXPR OP: %s", lexer.to_string(typed_stmt.op.kind))
		case .Gt: fmt.printfln("[DEBUG] UNHANDLED BINARY EXPR OP: %s", lexer.to_string(typed_stmt.op.kind))
		case .Lt_Eq: fmt.printfln("[DEBUG] UNHANDLED BINARY EXPR OP: %s", lexer.to_string(typed_stmt.op.kind))
		case .Gt_Eq: fmt.printfln("[DEBUG] UNHANDLED BINARY EXPR OP: %s", lexer.to_string(typed_stmt.op.kind))
		case: fmt.printfln("[DEBUG] UNKNOWN BINARY EXPR OP %s", lexer.to_string(typed_stmt.op.kind))
		}
	case ^ast.Paren_Expr:
		ops: [dynamic]Operation
		ops, result_value = ir_parse_expression(irb, typed_stmt.expr)
		append_operations(&operations_list, ops)
	case ^ast.Call_Expr:
		arg_names_handled := make([dynamic]string, irb.alloc)
		arg_values_handled := make([dynamic]Value, irb.alloc)

		for arg in typed_stmt.args {
			ops, value := ir_parse_expression(irb, arg.value)
			append_operations(&operations_list, ops)
			append(&arg_values_handled, value)
			append(&arg_names_handled, arg.name)
		}

		if ident, ok := typed_stmt.expr.derived.(^ast.Ident); ok {
			call_name := ident.name

			if action, is_native := assets.action_native_from_mapped(call_name); is_native {
				if len(arg_values_handled) > len(action.slots) {
					ir_add_error(irb, "too much arguments", ident)
					break
				}
				slots_map := make(map[string]Value, len(action.slots), irb.alloc)
				for arg_value, arg_value_index in arg_values_handled {
					arg_name := arg_names_handled[arg_value_index]
					slot_data := action.slots[arg_value_index]
					new_arg_value := arg_value
					if slot_data.type == "enum" {
						new_arg_value = enum_value(arg_value.(TextValue).text)
					}
					if arg_name == "" {
						slots_map[slot_data.name] = new_arg_value
					} else {
						found := false
						for slot in action.slots {
							if slot.name == arg_name {
								found = true
								break
							}
						}
						if found {
							// maybe check if keyword argument overlap
							// positional argument and warn user if so?
							slots_map[arg_name] = new_arg_value
						} else {
							ir_add_error(irb, "unknown keyword argument: no parameters matches", typed_stmt)
							break
						}
					}
				}
				values := make([dynamic]NamedValue, irb.alloc)
				for slot_key, slot_value in slots_map {
					append(&values, named_value(slot_key, slot_value))
				}
				append(&operations_list, basic_operation(action.name, values))
				break
			}

			switch call_name {
			case "game_value":
				fmt.println("[DEBUG] game_value fabric")
				if len(arg_values_handled) == 0 {
					ir_add_error(irb, "can't generate game value from empty constructor", ident)
					break expr_type_switch
				}
				ir_add_error(irb, "not implemented", ident)
				break expr_type_switch
			case "item": // item("item_name", 16)
				if len(arg_values_handled) == 0 {
					ir_add_error(irb, "can't generate item from empty constructor", ident)
					break expr_type_switch
				}
				item_name: string
				item_count: f64

				item_name_val: Value
				item_count_val: Value
				if slice.contains(arg_names_handled[:], "name") {
					for arg_name, arg_index in arg_names_handled {
						if arg_names_handled[arg_index] == "name" {
							item_name_val = arg_values_handled[arg_index]
						}
					}
				} else {
					item_name_val = arg_values_handled[0]
				}

				if len(arg_values_handled) > 1 {
					if slice.contains(arg_names_handled[:], "count") {
						for arg_name, arg_index in arg_names_handled {
							if arg_names_handled[arg_index] == "count" {
								item_count_val = arg_values_handled[arg_index]
							}
						}
					} else {
						item_count_val = arg_values_handled[1]
					}
				}

				if item_name_lit, is_text_lit := item_name_val.(TextValue); is_text_lit {
					item_name = item_name_lit.text
				} else {
					ir_add_error(irb, "text literal expected", ident)
				}

				if item_count_lit, is_number_lit := item_count_val.(NumberValue); is_number_lit {
					item_count = item_count_lit.number
				} else if len(arg_values_handled) > 1 {
					ir_add_error(irb, "number literal expected", ident)
				} else {
					item_count = 1
				}

				nbt_result, success := generate_item(irb, item_name, int(item_count), irb.alloc)
				if !success {
					fmt.printfln("[DEBUG] Can't compress item from raw to nbt format for some reason. Contact compiler devs pls")
					break expr_type_switch
				}

				result_value = item_value(nbt_result)
				break expr_type_switch
			case "array":
				fmt.println("[DEBUG] array fabric")
				break expr_type_switch
			case "dict":
				fmt.println("[DEBUG] dict fabric")
				break expr_type_switch
			case "location":
				fmt.println("[DEBUG] location fabric")
				break expr_type_switch
			case "vec3":
				fmt.println("[DEBUG] vec3 fabric")
				break expr_type_switch
			case "sound":
				fmt.println("[DEBUG] sound fabric")
				break expr_type_switch
			case "particle":
				fmt.println("[DEBUG] particle fabric")
				break expr_type_switch
			case "block":
				fmt.println("[DEBUG] block fabric")
				break expr_type_switch
			case "number":
				fmt.println("[DEBUG] number fabric")
				break expr_type_switch
			case "text":
				fmt.println("[DEBUG] text fabric")
				break expr_type_switch
			case "enum":
				fmt.println("[DEBUG] enum fabric")
				break expr_type_switch
			case "potion":
				fmt.println("[DEBUG] potion fabric")
				break expr_type_switch
			}

			if _, exists := checker.lookup_symbol(irb.symbols.global_scope, call_name); exists {
				if len(typed_stmt.args) > 0 {
					ir_add_warning(irb, "Function arguments are ignored because they're not implemented yet.", typed_stmt)
				}
				values := make([dynamic]NamedValue, irb.alloc)
				append(&values, named_value("function_name", text_value(call_name, PARSING_COLORED)))
				append(&operations_list, basic_operation("call_function", values))
				break
			}
		} else {
			fmt.printfln("[DEBUG] Unhandled")
		}
	case ^ast.Argument:
		fmt.printfln("UNHANDLED :: %v", typed_stmt.pos)
	case:
		fmt.printfln("UNHANDLED :: %v", typed_stmt)
		result_value = variable_value(get_new_inner_name(irb), SCOPE_LOCAL)
	}

	return operations_list, result_value
}

ir_build :: proc(irb: ^IR_Builder) -> (string, [dynamic]error.Error) {
	json_begin_object(&irb.jb)
	json_begin_array(&irb.jb, "handlers")

	all_handlers := make([dynamic]^Handler, irb.alloc)
	for handler in irb.handlers {
		if len(handler.operations) == 0 {
			handler_name: string
			if handler.type == "event" {
				handler_name = handler.event
			} else {
				handler_name = handler.name
			}
			ir_add_warning(irb, fmt.tprintf("Skipping empty handler: %s", handler_name), nil)
			continue
		}
		append(&all_handlers, handler)
	}
	if len(irb.entry_handler.operations) > 0 {
		append(&all_handlers, irb.entry_handler)
	}

	handlers_count := len(all_handlers)
	for handler, handler_idx in all_handlers {
		is_last_handler := handler_idx != handlers_count-1
		ir_write_handler(irb, handler, is_last_handler)
	}

	json_end_array(&irb.jb, false)
	json_end_object(&irb.jb, false)

	result := strings.clone(strings.to_string(irb.jb.builder), irb.alloc)
	return result, irb.errs
}

get_new_position :: proc(irb: ^IR_Builder) -> int {
	irb.handler_index += 1
	return irb.handler_index
}

get_new_inner_name :: proc(irb: ^IR_Builder) -> string {
	irb.inner_names_index += 1
	inner_name := fmt.tprintf("jms.inner_name.%d", irb.inner_names_index)
	return inner_name
}

ir_write_handler :: proc(irb: ^IR_Builder, handler: ^Handler, comma: bool) {
	json_begin_object(&irb.jb)

	switch handler.type {
	case "event":
		json_write_string(&irb.jb, "event", handler.event, true)
	case "function", "process":
		json_write_string(&irb.jb, "name", handler.name, true)
		json_begin_array(&irb.jb, "values")
		named_values_count := len(handler.values)
		for &named_value, named_value_idx in handler.values {
			is_last_named_value := named_value_idx != named_values_count-1
			ir_write_named_value(irb, &named_value, is_last_named_value)
		}
		json_end_array(&irb.jb, true)
	}
	json_write_string(&irb.jb, "type", handler.type, true)
	json_write_number(&irb.jb, "position", get_new_position(irb), true)
	json_begin_array(&irb.jb, "operations")
	operations_count := len(handler.operations)
	for operation, operation_idx in handler.operations {
		is_last_operation := operation_idx != operations_count-1
		ir_write_operation(irb, operation, is_last_operation)
	}
	json_end_array(&irb.jb, false)
	json_end_object(&irb.jb, comma)
}

ir_write_operation :: proc(irb: ^IR_Builder, operation: Operation, comma: bool) {
	json_begin_object(&irb.jb)
	json_write_string(&irb.jb, "action", operation.action, true)
	if operation.selection.type != "" {
		json_begin_object(&irb.jb, "selection")
		json_write_string(&irb.jb, "type", operation.selection.type, false)
		json_end_object(&irb.jb, true)
	}
	if len(operation.operations) > 0 {
		json_begin_array(&irb.jb, "operations")
		ops_count := len(operation.operations)
		for op, op_index in operation.operations {
			is_last_operation := op_index != ops_count-1
			ir_write_operation(irb, op, is_last_operation)
		}
		json_end_array(&irb.jb, true)
	}
	json_begin_array(&irb.jb, "values")
	named_values_count := len(operation.values)
	for &named_value, named_value_idx in operation.values {
		is_last_named_value := named_value_idx != named_values_count-1
		ir_write_named_value(irb, &named_value, is_last_named_value)
	}
	json_end_array(&irb.jb, false)
	json_end_object(&irb.jb, comma)
}

ir_write_named_value :: proc(irb: ^IR_Builder, named_value: ^NamedValue, comma: bool) {
	json_begin_object(&irb.jb)
	json_write_string(&irb.jb, "name", named_value.name, true)
	ir_write_value(irb, &named_value.value, false)
	json_end_object(&irb.jb, comma)
}

ir_write_value :: proc(irb: ^IR_Builder, value: ^Value, comma: bool, is_named := true) {
	if is_named {
		json_begin_object(&irb.jb, "value")
	} else {
		json_begin_object(&irb.jb)
	}
	switch typed_value in value {
	case NullValue:
		json_begin_object(&irb.jb)
		json_end_object(&irb.jb, false)
	case ArrayValue:
		json_write_string(&irb.jb, "type", "array", true)
		json_begin_array(&irb.jb, "values")
		values_count := len(typed_value.values)
		for &value, value_idx in typed_value.values {
			is_last_value := value_idx == values_count-1
			ir_write_value(irb, &value, !is_last_value, false)
		}
		json_end_array(&irb.jb, false)
	case NumberValue:
		number_string := fmt.tprintf("%0.8f", typed_value.number)
		for strings.contains(number_string, ".") && strings.ends_with(number_string, "0") {
			number_string = number_string[:len(number_string)-1]
		}
		if strings.ends_with(number_string, ".") {
			number_string = number_string[:len(number_string)-1]
		}
		json_write_string(&irb.jb, "type", "number", true)
		json_write_string_unquoted(&irb.jb, "number", number_string, false)
	case TextValue:
		json_write_string(&irb.jb, "type", "text", true)
		json_write_string(&irb.jb, "text", typed_value.text, true)
		json_write_string(&irb.jb, "parsing", typed_value.parsing, false)
	case VariableValue:
		json_write_string(&irb.jb, "type", "variable", true)
		json_write_string(&irb.jb, "variable", typed_value.variable, true)
		json_write_string(&irb.jb, "scope", typed_value.scope, false)
	case EnumValue:
		json_write_string(&irb.jb, "type", "enum", true)
		json_write_string(&irb.jb, "enum", typed_value._enum, false)
	case LocationValue:
		json_write_string(&irb.jb, "type", "location", true)
		json_write_number(&irb.jb, "yaw", typed_value.yaw, true)
		json_write_number(&irb.jb, "pitch", typed_value.pitch, true)
		json_write_number(&irb.jb, "x", typed_value.x, true)
		json_write_number(&irb.jb, "y", typed_value.y, true)
		json_write_number(&irb.jb, "z", typed_value.z, false)
	case VectorValue:
		json_write_string(&irb.jb, "type", "vector", true)
		json_write_number(&irb.jb, "x", typed_value.x, true)
		json_write_number(&irb.jb, "y", typed_value.y, true)
		json_write_number(&irb.jb, "z", typed_value.z, false)
	case SoundValue:
		json_write_string(&irb.jb, "type", "sound", true)
		json_write_string(&irb.jb, "sound", typed_value.sound, true)
		json_write_string(&irb.jb, "source", typed_value.source, true)
		json_write_string(&irb.jb, "variation", typed_value.variation, true)
		json_write_number(&irb.jb, "volume", typed_value.volume, true)
		json_write_number(&irb.jb, "pitch", typed_value.pitch, false)
	case ParticleValue:
		json_write_string(&irb.jb, "type", "particle", true)
		json_write_string(&irb.jb, "particle_type", typed_value.particle_type, true)
		json_write_number(&irb.jb, "count", typed_value.count, true)
		json_write_number(&irb.jb, "size", typed_value.size, true)
		json_write_number(&irb.jb, "color", typed_value.color, true)
		json_write_number(&irb.jb, "first_spread", typed_value.first_spread, true)
		json_write_number(&irb.jb, "second_spread", typed_value.second_spread, true)
		json_write_number(&irb.jb, "x_motion", typed_value.x_motion, true)
		json_write_number(&irb.jb, "y_motion", typed_value.y_motion, true)
		json_write_number(&irb.jb, "z_motion", typed_value.z_motion, false)
	case ItemValue:
		json_write_string(&irb.jb, "type", "item", true)
		json_write_string(&irb.jb, "item", typed_value.item, false)
	case GameValue:
		json_write_string(&irb.jb, "type", "game_value", true)
		json_write_string(&irb.jb, "game_value", typed_value.game_value, true)
		json_write_string(&irb.jb, "selection", typed_value.selection, false)
	case PotionValue:
		json_write_string(&irb.jb, "type", "potion", true)
		json_write_string(&irb.jb, "potion", typed_value.potion, true)
		json_write_number(&irb.jb, "amplifier", typed_value.amplifier, true)
		json_write_number(&irb.jb, "duration", typed_value.duration, false)
	case BlockValue:
		json_write_string(&irb.jb, "type", "block", true)
		json_write_string(&irb.jb, "block", typed_value.block, false)
	case LocalizedTextValue:
		json_write_string(&irb.jb, "type", "localized_text", true)
		json_write_string(&irb.jb, "data", typed_value.data, false)
	}
	json_end_object(&irb.jb, comma)
}

append_operations :: proc(operations_1: ^[dynamic]Operation, operations_2: [dynamic]Operation) {
	for op in operations_2 {
		append(operations_1, op)
	}
}
