package codegen

import "core:strconv"
import "core:fmt"
import "core:mem"
import "core:strings"

import "../ast"
import "../lexer"
import "../checker"
import "../../assets"

IR_Builder :: struct {
	jb: Json_Builder,
	handlers: [dynamic]^Handler,
	entry_handler: ^Handler,
	unique_id: string,
	minify: bool,
	symbols: ^checker.Symbol_Table,
	handler_index: int,
	inner_names_index: int,
	alloc: mem.Allocator,
}

ir_builder_init :: proc(irb: ^IR_Builder, minify: bool, unique_id: string, symbols: ^checker.Symbol_Table, allocator := context.allocator) {
	irb.alloc = allocator
	irb.unique_id = unique_id
	irb.symbols = symbols
	irb.minify = minify
	irb.handler_index = -1
	irb.handlers = make([dynamic]^Handler, irb.alloc)
	irb.entry_handler = new_handler(irb, "event", "world_start")
	json_builder_init(&irb.jb, irb.minify, irb.alloc)
}

ir_parse_stmt :: proc(irb: ^IR_Builder, stmt: ^ast.Stmt) -> [dynamic]Operation {
	ops := make([dynamic]Operation, irb.alloc)
	#partial switch v in stmt.derived {
	case ^ast.Block_Stmt:
		block_stmt := cast(^ast.Block_Stmt)stmt
		for stmt2 in block_stmt.stmts {
			ops2 := ir_parse_stmt(irb, stmt2)
			for op in ops2 {
				append(&ops, op)
			}
		}
	case ^ast.Expr_Stmt:
		expr_stmt := cast(^ast.Expr_Stmt)stmt
		ops2, _ := ir_parse_expression(irb, expr_stmt.expr)
		for op in ops2 {
			append(&ops, op)
		}
	case ^ast.For_Stmt:
		for_stmt := cast(^ast.For_Stmt)stmt
		if for_stmt.init == nil && for_stmt.cond == nil && for_stmt.post == nil && for_stmt.second_cond == nil {
			ops3 := ir_parse_stmt(irb, for_stmt.body)
			values := make([dynamic]NamedValue, irb.alloc)
			append(&ops, Operation{action="repeat_forever", values=values, operations=ops3 })
		} else {
			if for_stmt.init != nil && for_stmt.cond != nil && for_stmt.post == nil && for_stmt.second_cond == nil {
				init_ident := for_stmt.init
				cond_expr := for_stmt.cond
				#partial switch v in cond_expr.derived {
				case ^ast.Call_Expr:
					cond_expr_call_expr := cast(^ast.Call_Expr)cond_expr
					#partial switch v in cond_expr_call_expr.expr.derived {
					case ^ast.Ident:
						ident := cast(^ast.Ident)cond_expr_call_expr.expr
						ident_name := ident.name
						action, is_exist := assets.action_native_from_mapped(ident_name, irb.alloc)
						if !is_exist {
							fmt.printfln("Unknown repeat action")
							break
						}
						if action.type != .CONTAINER {
							fmt.printfln("Unhandled4 for loop construction, non-container action: %v", for_stmt)
							break
						}
						if len(init_ident) > len(action.out_slots) {
							fmt.printfln("(user error) Unhandled5 for loop construction, too much output variables, expected %d or less but got %d: %v", len(action.out_slots), len(init_ident), for_stmt)
							break
						}
						if len(cond_expr_call_expr.args) > len(action.in_slots) {
							fmt.printfln("(user error) Unhandled6 for loop construction, too much input variables, expected %d or less but got %d: %v", len(cond_expr_call_expr.args), len(action.in_slots), for_stmt)
							break
						}
						argvalues := make([dynamic]Value, irb.alloc)
						for arg_expr in cond_expr_call_expr.args {
							opsops, val := ir_parse_expression(irb, arg_expr)
							for op in opsops {
								append(&ops, op)
							}
							append(&argvalues, val)
						}
						result_ops := make([dynamic]Operation, irb.alloc)
						ops3 := ir_parse_stmt(irb, for_stmt.body)

						if ident_name == "repeat_multi_times" && len(init_ident) == 1 {
							values1 := make([dynamic]NamedValue, irb.alloc)
							res_var := VariableValue{variable=init_ident[0].name, scope=SCOPE_LOCAL}
							append(&values1, NamedValue{name="variable", value=res_var})
							append(&values1, NamedValue{name="number", value=NumberValue{number=1}})
							append(&result_ops, Operation{action="set_variable_decrement", values=values1 })
						}
						values := make([dynamic]NamedValue, irb.alloc)
						for idnt, idnt_idx in init_ident {
							append(&values, NamedValue{name=action.out_slots[idnt_idx], value=VariableValue{variable=idnt.name, scope=SCOPE_LOCAL}})
						}
						for argvalue, argvalue_index in argvalues {
							append(&values, NamedValue{name=action.in_slots[argvalue_index], value=argvalue})
						}
						for op in ops3 {
							append(&result_ops, op)
						}
						append(&ops, Operation{action=action.name, values=values, operations=result_ops })
					case:
						fmt.printfln("[DEBUG] Unhandled1 for loop construction: %v", for_stmt)
					}
				case:
					fmt.printfln("[DEBUG] Unhandled2 for loop construction: %v", for_stmt)
				}
			}
		}
	case ^ast.Value_Decl:
		value_decl := cast(^ast.Value_Decl)stmt
		values := make([dynamic]NamedValue, irb.alloc)
		append(&values, NamedValue{name="variable", value=VariableValue{variable=value_decl.name, scope=SCOPE_GAME}})
		ops2, var := ir_parse_expression(irb, value_decl.value)
		for op in ops2 {
			append(&ops, op)
		}
		append(&values, NamedValue{name="value", value=var})
		append(&ops, Operation{action="set_variable_value", values=values })
	case ^ast.Assign_Stmt:
		assign_stmt := cast(^ast.Assign_Stmt)stmt
		values := make([dynamic]NamedValue, irb.alloc)
		result_var := VariableValue{variable=assign_stmt.name, scope=SCOPE_GAME}
		append(&values, NamedValue{name="variable", value=result_var})
		ops2, var := ir_parse_expression(irb, assign_stmt.expr)
		for op in ops2 {
			append(&ops, op)
		}
		#partial switch assign_stmt.op.kind {
		case .Add_Eq, .Sub_Eq, .Quo_Eq, .Mul_Eq:
			array_values := make([dynamic]Value, irb.alloc)
			append(&array_values, result_var)
			append(&array_values, var)
			append(&values, NamedValue{name="value", value=ArrayValue{values=array_values}})
			action_name: string
			#partial switch assign_stmt.op.kind {
			case .Add_Eq: action_name = "set_variable_add"
			case .Sub_Eq: action_name = "set_variable_subtract"
			case .Quo_Eq: action_name = "set_variable_divide"
			case .Mul_Eq: action_name = "set_variable_multiply"
			}
			append(&ops, Operation{action=action_name, values=values })
		case .Eq:
			append(&values, NamedValue{name="value", value=var})
			append(&ops, Operation{action="set_variable_value", values=values })
		}
	case:
		fmt.printfln("Unhandled %v", v)
	}
	return ops
}

ir_builder_append_file :: proc(irb: ^IR_Builder, file: ^ast.File) {
	for decl in file.decls {
		#partial switch v in decl.derived {
		case:
			ops := ir_parse_stmt(irb, decl)
			for op in ops {
				append(&irb.entry_handler.operations, op)
			}
		case ^ast.Func_Stmt:
			func_stmt := cast(^ast.Func_Stmt)decl
			func_handler := new_handler(irb, "function", func_stmt.name)
			ops := ir_parse_stmt(irb, func_stmt.body)
			for op in ops {
				append(&func_handler.operations, op)
			}
			append(&irb.handlers, func_handler)
		case ^ast.Event_Stmt:
			event_stmt := cast(^ast.Event_Stmt)decl
			event_handler := new_handler(irb, "event", event_stmt.name)
			ops := ir_parse_stmt(irb, event_stmt.body)
			for op in ops {
				append(&event_handler.operations, op)
			}
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

	#partial switch v in expr.derived {
	// case ^ast.File: fmt.printfln("[DEBUG] UNHANDLED EXPRESSION TYPE File")
	case ^ast.Ident:
		ident := cast(^ast.Ident)expr
		result_value = VariableValue{variable=ident.name, scope=SCOPE_LOCAL}
	case ^ast.Basic_Lit:
		basic_lit := cast(^ast.Basic_Lit)expr
		#partial switch basic_lit.tok.kind {
		case .Ident:
			ident_raw := basic_lit.tok.content
			result_value = VariableValue{variable=ident_raw, scope=SCOPE_LOCAL}
		case .Integer, .Float:
			integer_raw := basic_lit.tok.content
			num, ok := strconv.parse_f64(integer_raw)
			if !ok {
				fmt.printfln("[DEBUG] INVALID FLOAT ??")
			}
			result_value = NumberValue{number=num}
		case .Text:
			text_raw := basic_lit.tok.content
			result_value = TextValue{text=text_raw[1:len(text_raw)-1], parsing=PARSING_LEGACY}
		// case .True:
		// case .False:
		case:
			fmt.printfln("[DEBUG] UNHANDLED BASIC LITERAL WITH TYPE %s", lexer.to_string(basic_lit.tok.kind))
		}
	// case ^ast.Func_Stmt: fmt.printfln("UNHANDLED EXPRESSION TYPE Func_Stmt")
	// case ^ast.Event_Stmt: fmt.printfln("UNHANDLED EXPRESSION TYPE Event_Stmt")
	// case ^ast.Unary_Expr: fmt.printfln("UNHANDLED EXPRESSION TYPE Unary_Expr")
	case ^ast.Binary_Expr:
		binary_expr := cast(^ast.Binary_Expr)expr
		ops1, left_expr := ir_parse_expression(irb, binary_expr.left)
		for op in ops1 {
			append(&operations_list, op)
		}
		ops2, right_expr := ir_parse_expression(irb, binary_expr.right)
		for op in ops2 {
			append(&operations_list, op)
		}

		#partial switch binary_expr.op.kind {
		case .Add, .Sub, .Mul, .Quo:
			result_value = VariableValue{variable=get_new_inner_name(irb), scope=SCOPE_LOCAL}
			values := make([dynamic]NamedValue, irb.alloc)
			append(&values, NamedValue{name="variable", value=result_value})
			array_values := make([dynamic]Value, irb.alloc)
			append(&array_values, left_expr)
			append(&array_values, right_expr)
			append(&values, NamedValue{name="value", value=ArrayValue{values=array_values}})
			action_name: string
			#partial switch binary_expr.op.kind {
			case .Add: action_name = "set_variable_add"
			case .Sub: action_name = "set_variable_subtract"
			case .Quo: action_name = "set_variable_divide"
			case .Mul: action_name = "set_variable_multiply"
			}
			append(&operations_list, Operation{action=action_name, values=values })

		case .Mod:
			result_value = VariableValue{variable=get_new_inner_name(irb), scope=SCOPE_LOCAL}
			values := make([dynamic]NamedValue, irb.alloc)
			append(&values, NamedValue{name="variable", value=result_value})
			append(&values, NamedValue{name="dividend", value=left_expr})
			append(&values, NamedValue{name="divisor", value=right_expr})

			append(&operations_list, Operation{action="set_variable_remainder", values=values })

		case .Eq: fmt.printfln("[DEBUG] UNHANDLED BINARY EXPR OP: %s", lexer.to_string(binary_expr.op.kind))
		case .Not: fmt.printfln("[DEBUG] UNHANDLED BINARY EXPR OP: %s", lexer.to_string(binary_expr.op.kind))
		case .Hash: fmt.printfln("[DEBUG] UNHANDLED BINARY EXPR OP: %s", lexer.to_string(binary_expr.op.kind))
		case .At: fmt.printfln("[DEBUG] UNHANDLED BINARY EXPR OP: %s", lexer.to_string(binary_expr.op.kind))
		case .Cmp_And: fmt.printfln("[DEBUG] UNHANDLED BINARY EXPR OP: %s", lexer.to_string(binary_expr.op.kind))
		case .Cmp_Or: fmt.printfln("[DEBUG] UNHANDLED BINARY EXPR OP: %s", lexer.to_string(binary_expr.op.kind))
		case .Cmp_Eq: fmt.printfln("[DEBUG] UNHANDLED BINARY EXPR OP: %s", lexer.to_string(binary_expr.op.kind))
		case .Not_Eq: fmt.printfln("[DEBUG] UNHANDLED BINARY EXPR OP: %s", lexer.to_string(binary_expr.op.kind))
		case .Lt: fmt.printfln("[DEBUG] UNHANDLED BINARY EXPR OP: %s", lexer.to_string(binary_expr.op.kind))
		case .Gt: fmt.printfln("[DEBUG] UNHANDLED BINARY EXPR OP: %s", lexer.to_string(binary_expr.op.kind))
		case .Lt_Eq: fmt.printfln("[DEBUG] UNHANDLED BINARY EXPR OP: %s", lexer.to_string(binary_expr.op.kind))
		case .Gt_Eq: fmt.printfln("[DEBUG] UNHANDLED BINARY EXPR OP: %s", lexer.to_string(binary_expr.op.kind))
		case: fmt.printfln("[DEBUG] UNKNOWN BINARY EXPR OP %s", lexer.to_string(binary_expr.op.kind))
		}
	case ^ast.Paren_Expr:
		paren_expr := cast(^ast.Paren_Expr)expr
		ops: [dynamic]Operation
		ops, result_value = ir_parse_expression(irb, paren_expr.expr)
		for op in ops {
			append(&operations_list, op)
		}
	// case ^ast.Member_Access_Expr: fmt.printfln("UNHANDLED EXPRESSION TYPE Member_Access_Expr")
	// case ^ast.Index_Expr: fmt.printfln("UNHANDLED EXPRESSION TYPE Index_Expr")
	case ^ast.Call_Expr:
		call_expr := cast(^ast.Call_Expr)expr
		args_handled := make([dynamic]Value, irb.alloc)
		for arg in call_expr.args {
			opss, vall := ir_parse_expression(irb, arg)
			for op in opss {
				append(&operations_list, op)
			}
			append(&args_handled, vall)
		}
		#partial switch v in call_expr.expr.derived {
		case ^ast.Ident:
			ident_expr := cast(^ast.Ident)call_expr.expr
			call_name := ident_expr.name
			native_action, is_valid := assets.action_native_from_mapped(call_name, irb.alloc)
			if is_valid {
				selection: Operation_Selection
				if native_action.accept_selector && len(args_handled) > 0 {
					selector_arg := args_handled[0]
					#partial switch v in selector_arg {
					case TextValue:
						text_value := selector_arg.(TextValue)
						switch text_value.text {
						case "null", "current", "default_player", "killer_player", "damager_player", "shooter_player", "victim_player", "random_player", "all_players":
							selection.type = text_value.text
						case:
							fmt.printfln("[DEBUG] Unknown selector '%s'!!!", text_value.text)
						}
					case:
						fmt.printfln("[DEBUG] Invalid argument type for selector!!!")
					}
					remove_range(&args_handled, 0, 1)
				}
				fmt.printfln("[DEBUG] Native action found: %s", native_action.name)
				values := make([dynamic]NamedValue, irb.alloc)
				slots := native_action.slots
				args_handled_length := len(args_handled)
				for slot, slot_idx in slots {
					if slot_idx > args_handled_length-1 {
						fmt.printfln("[DEBUG] NOT ENOUGHT ARGS, just skipping!")
						break
					}
					append(&values, NamedValue{name=slot.name, value=args_handled[slot_idx]})
				}
				append(&operations_list, Operation{action=native_action.name, values=values, selection=selection })
				break
			}
			func_symb, exists := irb.symbols.global_scope.symbols[call_name]
			if exists {
				values := make([dynamic]NamedValue, irb.alloc)
				append(&values, NamedValue{name="function_name", value=TextValue{text=call_name, parsing=PARSING_LEGACY}})
				append(&operations_list, Operation{action="call_function", values=values })
				break
			}

			if call_name == "get_player_count" {
				result_value = GameValue{game_value="player_count", selection="null"}
				break
			}
			fmt.printfln("[DEBUG] Unknown action: %s", call_name)
		case:
			fmt.printfln("[DEBUG] Unhandled and possibly shouldn't be allowed?")
		}
	// case ^ast.Field_Value: fmt.printfln("UNHANDLED EXPRESSION TYPE Field_Value")
	// case ^ast.Expr_Stmt: fmt.printfln("UNHANDLED EXPRESSION TYPE Expr_Stmt")
	// case ^ast.Assign_Stmt: fmt.printfln("UNHANDLED EXPRESSION TYPE Assign_Stmt")
	// case ^ast.Block_Stmt: fmt.printfln("UNHANDLED EXPRESSION TYPE Block_Stmt")
	// case ^ast.If_Stmt: fmt.printfln("UNHANDLED EXPRESSION TYPE If_Stmt")
	// case ^ast.Return_Stmt: fmt.printfln("UNHANDLED EXPRESSION TYPE Return_Stmt")
	// case ^ast.Defer_Stmt: fmt.printfln("UNHANDLED EXPRESSION TYPE Defer_Stmt")
	// case ^ast.For_Stmt: fmt.printfln("UNHANDLED EXPRESSION TYPE For_Stmt")
	// case ^ast.Range_Stmt: fmt.printfln("UNHANDLED EXPRESSION TYPE Range_Stmt")
	// case ^ast.Value_Decl: fmt.printfln("UNHANDLED EXPRESSION TYPE Value_Decl")
	// case ^ast.Field_Access: fmt.printfln("UNHANDLED EXPRESSION TYPE Field_Access")
	// case ^ast.Param: fmt.printfln("UNHANDLED EXPRESSION TYPE Param")
	// case ^ast.Param_List: fmt.printfln("UNHANDLED EXPRESSION TYPE Param_List")
	case:
		fmt.printfln("UNHANDLED :: %v", v)
		result_value = VariableValue{variable=get_new_inner_name(irb), scope=SCOPE_LOCAL}
	}

	return operations_list, result_value
}

ir_build :: proc(irb: ^IR_Builder) -> string {
	json_begin_object(&irb.jb)
	json_begin_array(&irb.jb, "handlers")

	all_handlers := make([dynamic]^Handler, irb.alloc)
	for handler in irb.handlers {
		if handler.type == "event" && len(handler.operations) > 0 {
			append(&all_handlers, handler)
		}
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

	return strings.clone(strings.to_string(irb.jb.builder), irb.alloc)
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
	}
	// fix, move them to values
	// if handler.icon != "" {
	// 	json_write_string(&irb.jb, "icon", handler.icon, true)
	// }
	// if handler.description != "" {
	// 	json_write_string(&irb.jb, "description", handler.description, true)
	// }
	// if handler.is_hidden {
	// 	json_write_boolean(&irb.jb, "is_hidden", true, true)
	// }
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
	switch v in value {
	case NullValue:
		if is_named {
			json_begin_object(&irb.jb, "value")
		} else {
			json_begin_object(&irb.jb)
		}
		json_begin_object(&irb.jb)
		json_end_object(&irb.jb, false)
		json_end_object(&irb.jb, comma)
	case ArrayValue:
		if is_named {
			json_begin_object(&irb.jb, "value")
		} else {
			json_begin_object(&irb.jb)
		}
		array_value := value.(ArrayValue)
		json_write_string(&irb.jb, "type", "array", true)
		json_begin_array(&irb.jb, "values")
		values_count := len(array_value.values)
		for &value, value_idx in array_value.values {
			is_last_value := value_idx == values_count-1
			ir_write_value(irb, &value, !is_last_value, false)
		}
		json_end_array(&irb.jb, false)
		json_end_object(&irb.jb, comma)
	case NumberValue:
		if is_named {
			json_begin_object(&irb.jb, "value")
		} else {
			json_begin_object(&irb.jb)
		}
		number_value := value.(NumberValue)
		number_string := fmt.tprintf("%0.8f", number_value.number)
		for strings.contains(number_string, ".") && strings.ends_with(number_string, "0") {
			number_string = number_string[:len(number_string)-1]
		}
		if strings.ends_with(number_string, ".") {
			number_string = number_string[:len(number_string)-1]
		}
		json_write_string(&irb.jb, "type", "number", true)
		json_write_string(&irb.jb, "number", number_string, false)
		json_end_object(&irb.jb, comma)
	case TextValue:
		if is_named {
			json_begin_object(&irb.jb, "value")
		} else {
			json_begin_object(&irb.jb)
		}
		text_value := value.(TextValue)
		json_write_string(&irb.jb, "type", "text", true)
		json_write_string(&irb.jb, "text", text_value.text, true)
		json_write_string(&irb.jb, "parsing", text_value.parsing, false)
		json_end_object(&irb.jb, comma)
	case VariableValue:
		if is_named {
			json_begin_object(&irb.jb, "value")
		} else {
			json_begin_object(&irb.jb)
		}
		variable_value := value.(VariableValue)
		json_write_string(&irb.jb, "type", "variable", true)
		json_write_string(&irb.jb, "variable", variable_value.variable, true)
		json_write_string(&irb.jb, "scope", variable_value.scope, false)
		json_end_object(&irb.jb, comma)
	case EnumValue:
		if is_named {
			json_begin_object(&irb.jb, "value")
		} else {
			json_begin_object(&irb.jb)
		}
		json_write_string(&irb.jb, "TODO!", "TODO!", false)
		json_end_object(&irb.jb, comma)
	case LocationValue:
		if is_named {
			json_begin_object(&irb.jb, "value")
		} else {
			json_begin_object(&irb.jb)
		}
		json_write_string(&irb.jb, "TODO!", "TODO!", false)
		json_end_object(&irb.jb, comma)
	case VectorValue:
		if is_named {
			json_begin_object(&irb.jb, "value")
		} else {
			json_begin_object(&irb.jb)
		}
		json_write_string(&irb.jb, "TODO!", "TODO!", false)
		json_end_object(&irb.jb, comma)
	case SoundValue:
		if is_named {
			json_begin_object(&irb.jb, "value")
		} else {
			json_begin_object(&irb.jb)
		}
		json_write_string(&irb.jb, "TODO!", "TODO!", false)
		json_end_object(&irb.jb, comma)
	case ParticleValue:
		if is_named {
			json_begin_object(&irb.jb, "value")
		} else {
			json_begin_object(&irb.jb)
		}
		json_write_string(&irb.jb, "TODO!", "TODO!", false)
		json_end_object(&irb.jb, comma)
	case ItemValue:
		if is_named {
			json_begin_object(&irb.jb, "value")
		} else {
			json_begin_object(&irb.jb)
		}
		json_write_string(&irb.jb, "TODO!", "TODO!", false)
		json_end_object(&irb.jb, comma)
	case GameValue:
		if is_named {
			json_begin_object(&irb.jb, "value")
		} else {
			json_begin_object(&irb.jb)
		}
		game_value := value.(GameValue)
		json_write_string(&irb.jb, "type", "game_value", true)
		json_write_string(&irb.jb, "game_value", game_value.game_value, true)
		json_write_string(&irb.jb, "selection", game_value.selection, false)
		json_end_object(&irb.jb, comma)
	case PotionValue:
		if is_named {
			json_begin_object(&irb.jb, "value")
		} else {
			json_begin_object(&irb.jb)
		}
		json_write_string(&irb.jb, "TODO!", "TODO!", false)
		json_end_object(&irb.jb, comma)
	case BlockValue:
		if is_named {
			json_begin_object(&irb.jb, "value")
		} else {
			json_begin_object(&irb.jb)
		}
		json_write_string(&irb.jb, "TODO!", "TODO!", false)
		json_end_object(&irb.jb, comma)
	}
}
