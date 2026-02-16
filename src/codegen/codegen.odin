package codegen

import "core:fmt"
import "core:strconv"
import "core:mem"

import "../ast"
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
	errs: [dynamic]error.Error,

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

codegen_init :: proc(c: ^Codegen, allocator := context.allocator) {
	c.handlers = make_handlers(allocator)
	c.entry_handler = create_event_handler("world_start", make_operations(allocator), allocator)
	c.current_operations = &c.entry_handler.operations
	c.exit_handler = create_event_handler("world_stop", make_operations(allocator), allocator)
	c.errs = make([dynamic]error.Error, allocator)

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
	// codegen_gen_expression(c, node.expr)
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

}

visit_defer_stmt :: proc(v: ^ast.Visitor, node: ^ast.Defer_Stmt) {
	c := cast(^Codegen)v.user_data

}

visit_for_stmt :: proc(v: ^ast.Visitor, node: ^ast.For_Stmt) {
	c := cast(^Codegen)v.user_data

}

visit_value_decl :: proc(v: ^ast.Visitor, node: ^ast.Value_Decl) {
	c := cast(^Codegen)v.user_data
	value_decl_op := create_basic_operation("set_variable_value", make_named_values(c.alloc), "", c.alloc)
	append(&value_decl_op.values, create_named_value("variable", create_variable_value(node.name, SCOPE_GAME, c.alloc), c.alloc))
	result_value, _ := codegen_gen_expression(c, node.value)
	append(&value_decl_op.values, create_named_value("value", result_value, c.alloc))
	append(c.current_operations, value_decl_op)
}

codegen_gen_expression :: proc(c: ^Codegen, node: ^ast.Node) -> (Value, checker.Type_Kind) {
	#partial switch typed_node in node.derived {
	case ^ast.Call_Expr:
		result_var := create_variable_value(next_unique_id(c), SCOPE_GAME, c.alloc)
		ident, is_ident := typed_node.expr.derived.(^ast.Ident)
		ensure(is_ident)
		func_name := ident.name
		sym, _ := checker.lookup_symbol(c.symbols.global_scope, func_name)
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
				arg_value, _ := codegen_gen_expression(c, arg)
				if param_type == "enum" {
					text_val, _ := arg_value.(^TextValue)
					arg_value = create_enum_value(text_val.text, c.alloc)
				}
				append(&op.values, create_named_value(arg_name, arg_value, c.alloc))
			}
			append(c.current_operations, op)
		case .BUILTIN in func_flags:
			unimplemented("generation of built-in function")
		case:
			unimplemented("generation of default function")
		}
	case ^ast.Argument:
		return codegen_gen_expression(c, typed_node.value)

	case ^ast.Ident:
		sym, _ := checker.lookup_symbol(c.current_scope, typed_node.name)
		return create_variable_value(typed_node.name, SCOPE_GAME, c.alloc), sym.type.kind

	case ^ast.Basic_Lit:
		content := typed_node.tok.content
		#partial switch typed_node.tok.kind {
		case .Text:
			return create_text_value(content[1:len(content)-1], PARSING_COLORED, c.alloc), .Text
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
		left_val, left_type := codegen_gen_expression(c, typed_node.left)
		right_val, right_type := codegen_gen_expression(c, typed_node.right)

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

		// TODO: add short-circuit logic
		case left_type == .Boolean && right_type == .Boolean && operator == .Cmp_And:
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

		case:
			unimplemented(fmt.tprintf("generation of binary expr (%v, %v, %v)", left_type, operator, right_type))
		}
	case:
		unimplemented(fmt.tprintf("%v", typed_node))
	}
	return nil, nil
}

codegen_gen :: proc(c: ^Codegen, files: [dynamic]^ast.File, symbols: ^checker.Symbol_Table, minify: bool, unique_id: string) -> (string, [dynamic]error.Error) {
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
	return handlers_to_string(&c.jb, c.handlers), c.errs
}

add_error :: proc(c: ^Codegen, message: string, file: ^ast.File, cause: ^ast.Node) {
	err := error.Error{file=file, message=message, cause_pos=cause.pos, cause_end=cause.end}
	append(&c.errs, err)
}

add_warning :: proc(c: ^Codegen, message: string, file: ^ast.File, cause: ^ast.Node) {
	warn := error.Error{file=file, message=message, cause_pos=cause.pos, cause_end=cause.end, severity=.Warning}
	append(&c.errs, warn)
}
