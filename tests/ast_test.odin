package tests

import "core:testing"
import "core:fmt"

import "src:ast"
import "src:lexer"

@(test)
test_create_ident :: proc(t: ^testing.T) {
	context.allocator = context.temp_allocator
	pos := lexer.Pos{line = 1, column = 1}
	end := lexer.Pos{line = 1, column = 5}

	ident := ast.create_ident("test", pos, end)

	testing.expect(t, ident != nil, "Ident should not be nil")
	testing.expect(t, ident.name == "test", fmt.tprintf("Expected 'test', got '%s'", ident.name))
	testing.expect(t, ident.pos == pos, "Position mismatch")
	testing.expect(t, ident.end == end, "End position mismatch")
}

@(test)
test_create_basic_lit :: proc(t: ^testing.T) {
	context.allocator = context.temp_allocator
	pos := lexer.Pos{line = 1, column = 1}
	end := lexer.Pos{line = 1, column = 3}

	tok := lexer.Token{kind = .Number, content = "69"}
	lit := ast.create_basic_lit(tok, pos, end)

	testing.expect(t, lit != nil, "Basic_Lit should not be nil")
	testing.expect(t, lit.tok.kind == .Number, "Should be a number token")
	testing.expect(t, lit.tok.content == "69", fmt.tprintf("Expected '69', got '%s'", lit.tok.content))

	text_tok := lexer.Token{kind = .Text, content = "\"hello\""}
	text_lit := ast.create_basic_lit(text_tok, pos, end)

	testing.expect(t, text_lit != nil, "Text Basic_Lit should not be nil")
	testing.expect(t, text_lit.tok.kind == .Text, "Should be a text token")
}

@(test)
test_create_number_lit :: proc(t: ^testing.T) {
	context.allocator = context.temp_allocator
	pos := lexer.Pos{line = 1, column = 1}
	end := lexer.Pos{line = 1, column = 3}

	lit := ast.create_number_lit("3.14", pos, end)

	testing.expect(t, lit != nil, "Number literal should not be nil")
	testing.expect(t, lit.tok.kind == .Number, "Should be a number token")
	testing.expect(t, lit.tok.content == "3.14", fmt.tprintf("Expected '3.14', got '%s'", lit.tok.content))
}

@(test)
test_create_text_lit :: proc(t: ^testing.T) {
	context.allocator = context.temp_allocator
	pos := lexer.Pos{line = 1, column = 1}
	end := lexer.Pos{line = 1, column = 7}

	lit := ast.create_text_lit("hello", pos, end)

	testing.expect(t, lit != nil, "Text literal should not be nil")
	testing.expect(t, lit.tok.kind == .Text, "Should be a text token")
	testing.expect(t, lit.tok.content == "\"hello\"", fmt.tprintf("Expected '\"hello\"', got '%s'", lit.tok.content))
}

@(test)
test_create_bool_lit :: proc(t: ^testing.T) {
	context.allocator = context.temp_allocator
	pos := lexer.Pos{line = 1, column = 1}
	end := lexer.Pos{line = 1, column = 5}

	true_lit := ast.create_bool_lit(true, pos, end)
	testing.expect(t, true_lit != nil, "True literal should not be nil")
	testing.expect(t, true_lit.tok.kind == .True, "Should be a true token")
	testing.expect(t, true_lit.tok.content == "true", fmt.tprintf("Expected 'true', got '%s'", true_lit.tok.content))

	false_lit := ast.create_bool_lit(false, pos, end)
	testing.expect(t, false_lit != nil, "False literal should not be nil")
	testing.expect(t, false_lit.tok.kind == .False, "Should be a false token")
	testing.expect(t, false_lit.tok.content == "false", fmt.tprintf("Expected 'false', got '%s'", false_lit.tok.content))
}

@(test)
test_create_unary_expr :: proc(t: ^testing.T) {
	context.allocator = context.temp_allocator
	pos := lexer.Pos{line = 1, column = 1}
	end := lexer.Pos{line = 1, column = 3}

	op := lexer.Token{kind = .Sub, content = "-"}
	expr := ast.create_ident("x", pos, end)

	unary := ast.create_unary_expr(op, expr, pos, end)

	testing.expect(t, unary != nil, "Unary_Expr should not be nil")
	testing.expect(t, unary.op.kind == .Sub, "Should be a subtraction operator")
	testing.expect(t, unary.expr == expr, "Expression mismatch")
}

@(test)
test_create_binary_expr :: proc(t: ^testing.T) {
	context.allocator = context.temp_allocator
	pos := lexer.Pos{line = 1, column = 1}
	end := lexer.Pos{line = 1, column = 5}

	left := ast.create_ident("a", pos, end)
	right := ast.create_ident("b", pos, end)
	op := lexer.Token{kind = .Add, content = "+"}

	binary := ast.create_binary_expr(left, op, right, pos, end)

	testing.expect(t, binary != nil, "Binary_Expr should not be nil")
	testing.expect(t, binary.left == left, "Left expression mismatch")
	testing.expect(t, binary.right == right, "Right expression mismatch")
	testing.expect(t, binary.op.kind == .Add, "Should be an addition operator")
}

@(test)
test_create_paren_expr :: proc(t: ^testing.T) {
	context.allocator = context.temp_allocator
	pos := lexer.Pos{line = 1, column = 1}
	end := lexer.Pos{line = 1, column = 4}

	expr := ast.create_ident("x", pos, end)
	paren := ast.create_paren_expr(expr, pos, end)

	testing.expect(t, paren != nil, "Paren_Expr should not be nil")
	testing.expect(t, paren.expr == expr, "Expression mismatch")
}

@(test)
test_create_call_expr :: proc(t: ^testing.T) {
	context.allocator = context.temp_allocator
	pos := lexer.Pos{line = 1, column = 1}
	end := lexer.Pos{line = 1, column = 10}

	expr := ast.create_ident("foo", pos, end)
	args := []^ast.Argument{
		ast.create_argument("", ast.create_ident("x", pos, end), pos, end),
	}
	ellipsis := lexer.Token{kind = .Invalid}

	call := ast.create_call_expr(expr, args, ellipsis, pos, end)

	testing.expect(t, call != nil, "Call_Expr should not be nil")
	testing.expect(t, call.expr == expr, "Function expression mismatch")
	testing.expect(t, len(call.args) == 1, fmt.tprintf("Expected 1 argument, got %d", len(call.args)))
}

@(test)
test_create_argument :: proc(t: ^testing.T) {
	context.allocator = context.temp_allocator
	pos := lexer.Pos{line = 1, column = 1}
	end := lexer.Pos{line = 1, column = 3}

	value := ast.create_ident("val", pos, end)
	arg := ast.create_argument("param", value, pos, end)

	testing.expect(t, arg != nil, "Argument should not be nil")
	testing.expect(t, arg.name == "param", fmt.tprintf("Expected 'param', got '%s'", arg.name))
	testing.expect(t, arg.value == value, "Value mismatch")
}

@(test)
test_expr_to_string :: proc(t: ^testing.T) {
	context.allocator = context.temp_allocator
	pos := lexer.Pos{line = 1, column = 1}
	end := lexer.Pos{line = 1, column = 3}

	ident := ast.create_ident("x", pos, end)
	ident_str := ast.expr_to_string(ident)
	testing.expect(t, ident_str == "x", fmt.tprintf("Expected 'x', got '%s'", ident_str))

	num := ast.create_number_lit("69", pos, end)
	num_str := ast.expr_to_string(num)
	testing.expect(t, num_str == "69", fmt.tprintf("Expected '69', got '%s'", num_str))

	left := ast.create_ident("a", pos, end)
	right := ast.create_ident("b", pos, end)
	op := lexer.Token{kind = .Add, content = "+"}
	binary := ast.create_binary_expr(left, op, right, pos, end)
	binary_str := ast.expr_to_string(binary)
	testing.expect(t, binary_str == "(a + b)", fmt.tprintf("Expected '(a + b)', got '%s'", binary_str))

	unary_op := lexer.Token{kind = .Sub, content = "-"}
	unary := ast.create_unary_expr(unary_op, ident, pos, end)
	unary_str := ast.expr_to_string(unary)
	testing.expect(t, unary_str == "(-x)", fmt.tprintf("Expected '(-x)', got '%s'", unary_str))
}

@(test)
test_node_id_increment :: proc(t: ^testing.T) {
	context.allocator = context.temp_allocator
	pos := lexer.Pos{line = 1, column = 1}
	end := lexer.Pos{line = 1, column = 3}

	nodes: [5]^ast.Ident
	for i in 0..<5 {
		nodes[i] = ast.create_ident(fmt.tprintf("node%d", i), pos, end)
	}

	for i in 1..<5 {
		testing.expect(t, nodes[i].id > nodes[i-1].id,
			fmt.tprintf("Node IDs should increment. Got: %d <= %d", nodes[i].id, nodes[i-1].id))
	}
}

@(test)
test_value_decl :: proc(t: ^testing.T) {
	context.allocator = context.temp_allocator
	pos := lexer.Pos{line = 1, column = 1}
	end := lexer.Pos{line = 1, column = 10}

	allocator := context.allocator

	decl := ast.new(ast.Value_Decl, pos, end, allocator)
	decl.name = "myVar"
	decl.type = "int"
	decl.value = ast.create_number_lit("69", pos, end)
	decl.is_const = true

	testing.expect(t, decl != nil, "Value_Decl should not be nil")
	testing.expect(t, decl.name == "myVar", fmt.tprintf("Expected 'myVar', got '%s'", decl.name))
	testing.expect(t, decl.type == "int", fmt.tprintf("Expected 'int', got '%s'", decl.type))
	testing.expect(t, decl.is_const == true, "Should be const")
	testing.expect(t, decl.value != nil, "Value should not be nil")
}

@(test)
test_param_list :: proc(t: ^testing.T) {
	context.allocator = context.temp_allocator
	pos := lexer.Pos{line = 1, column = 1}
	end := lexer.Pos{line = 1, column = 20}

	allocator := context.allocator

	param1 := ast.new(ast.Param, pos, end, allocator)
	param1.name = "x"
	param1.type = "int"

	param2 := ast.new(ast.Param, pos, end, allocator)
	param2.name = "y"
	param2.type = "float"

	param_list := ast.new(ast.Param_List, pos, end, allocator)
	param_list.list = []^ast.Param{param1, param2}

	testing.expect(t, param_list != nil, "Param_List should not be nil")
	testing.expect(t, len(param_list.list) == 2, fmt.tprintf("Expected 2 params, got %d", len(param_list.list)))
	testing.expect(t, param_list.list[0].name == "x", fmt.tprintf("Expected 'x', got '%s'", param_list.list[0].name))
	testing.expect(t, param_list.list[1].name == "y", fmt.tprintf("Expected 'y', got '%s'", param_list.list[1].name))
}

@(test)
test_func_stmt :: proc(t: ^testing.T) {
	context.allocator = context.temp_allocator
	pos := lexer.Pos{line = 1, column = 1}
	end := lexer.Pos{line = 1, column = 30}

	allocator := context.allocator

	func_stmt := ast.new(ast.Func_Stmt, pos, end, allocator)
	func_stmt.name = "myFunc"
	func_stmt.result = "int"

	param_list := ast.new(ast.Param_List, pos, end, allocator)
	param := ast.new(ast.Param, pos, end, allocator)
	param.name = "x"
	param.type = "int"
	param_list.list = []^ast.Param{param}
	func_stmt.params = param_list

	body := ast.new(ast.Block_Stmt, pos, end, allocator)
	func_stmt.body = body

	testing.expect(t, func_stmt != nil, "Func_Stmt should not be nil")
	testing.expect(t, func_stmt.name == "myFunc", fmt.tprintf("Expected 'myFunc', got '%s'", func_stmt.name))
	testing.expect(t, func_stmt.result == "int", fmt.tprintf("Expected 'int', got '%s'", func_stmt.result))
	testing.expect(t, func_stmt.params != nil, "Params should not be nil")
	testing.expect(t, func_stmt.body != nil, "Body should not be nil")
}

@(test)
test_annotations :: proc(t: ^testing.T) {
	context.allocator = context.temp_allocator
	pos := lexer.Pos{line = 1, column = 1}
	end := lexer.Pos{line = 1, column = 10}

	allocator := context.allocator

	stmt := ast.new(ast.Value_Decl, pos, end, allocator)
	stmt.name = "x"
	stmt.type = "int"
	stmt.value = ast.create_number_lit("5", pos, end)

	anno := ast.Annotation{
		name = "deprecated",
		value = ast.create_text_lit("Use y instead", pos, end),
	}
	append(&stmt.annotations, anno)

	testing.expect(t, stmt != nil, "Statement should not be nil")
	testing.expect(t, len(stmt.annotations) == 1, fmt.tprintf("Expected 1 annotation, got %d", len(stmt.annotations)))
	testing.expect(t, stmt.annotations[0].name == "deprecated",
		fmt.tprintf("Expected 'deprecated', got '%s'", stmt.annotations[0].name))
}

@(test)
test_file_node :: proc(t: ^testing.T) {
	context.allocator = context.temp_allocator
	pos := lexer.Pos{line = 1, column = 1}
	end := lexer.Pos{line = 100, column = 1}

	allocator := context.allocator

	file := ast.new(ast.File, pos, end, allocator)
	file.alloc = allocator
	file.pkg = "main"
	file.fullpath = "/path/to/file.odin"
	file.src = "package main\n\nx := 69"

	decl := ast.new(ast.Value_Decl, pos, end, allocator)
	decl.name = "x"
	decl.type = "int"
	decl.value = ast.create_number_lit("69", pos, end)
	append(&file.decls, decl)

	testing.expect(t, file != nil, "File should not be nil")
	testing.expect(t, file.pkg == "main", fmt.tprintf("Expected 'main', got '%s'", file.pkg))
	testing.expect(t, file.fullpath == "/path/to/file.odin",
		fmt.tprintf("Expected '/path/to/file.odin', got '%s'", file.fullpath))
	testing.expect(t, len(file.decls) == 1, fmt.tprintf("Expected 1 decl, got %d", len(file.decls)))
}

@(test)
test_any_node_union :: proc(t: ^testing.T) {
	context.allocator = context.temp_allocator
	pos := lexer.Pos{line = 1, column = 1}
	end := lexer.Pos{line = 1, column = 3}

	ident := ast.create_ident("test", pos, end)
	lit := ast.create_number_lit("69", pos, end)

	any_nodes: [2]ast.Any_Node
	any_nodes[0] = ident
	any_nodes[1] = lit

	#partial switch node in any_nodes[0] {
	case ^ast.Ident:
		testing.expect(t, node.name == "test", fmt.tprintf("Expected 'test', got '%s'", node.name))
	case:
		testing.fail(t)
	}

	#partial switch node in any_nodes[1] {
	case ^ast.Basic_Lit:
		testing.expect(t, node.tok.content == "69", fmt.tprintf("Expected '69', got '%s'", node.tok.content))
	case:
		testing.fail(t)
	}
}
