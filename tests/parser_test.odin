package tests

import "core:testing"
import "core:fmt"
import "core:os"
import "core:log"

import "src:parser"
import "src:lexer"
import "src:ast"
import "src:error"

@(test)
test_parser_init :: proc(t: ^testing.T) {
	ec: error.Collector
	error.collector_init(&ec, false, context.temp_allocator)

	p: parser.Parser
	parser.parser_init(&p, &ec, context.temp_allocator)

	testing.expect(t, p.offset == 0, "Parser offset should be 0 after init")
	testing.expect(t, p.tokens == nil, "Tokens should be nil after init")
	testing.expect(t, p.file == nil, "File should be nil after init")
	testing.expect(t, error.is_empty(&ec), "Error list should be empty after init")
}

@(test)
test_parse_file_tags :: proc(t: ^testing.T) {
	allocator := context.temp_allocator
	source := "#+tag1\n#+tag2\npackage test"

	ec: error.Collector
	error.collector_init(&ec, false, allocator)

	p: parser.Parser
	parser.parser_init(&p, &ec, allocator)

	l: lexer.Lexer
	lexer.lexer_init(&l, "test.jms", allocator)
	l.src = source
	p.tokens = lexer.lex(&l)
	p.alloc = allocator

	p.file = ast.new(ast.File, {file="test.jms", line=0, column=0}, {file="test.jms", line=2, column=14}, allocator)
	p.file.alloc = allocator
	p.file.src = source

	tags := parser.parse_file_tags(&p)

	testing.expect(t, len(tags) == 2, "Should parse 2 file tags")
	testing.expect(t, tags[0] == "tag1", "First tag should be 'tag1'")
	testing.expect(t, tags[1] == "tag2", "Second tag should be 'tag2'")
	testing.expect(t, p.offset == 2, "Offset should advance past file tags")
	testing.expect_value(t, parser.current(&p).kind, lexer.Token_Kind.Package)
}

@(test)
test_parse_package :: proc(t: ^testing.T) {
	test_cases := []struct {
		source: string,
		expected_pkg: string,
		should_error: bool,
	}{
		{"package mypkg", "mypkg", false},
		{"package", "_", true},
		{"", "_", true},
		{"package my_pkg123", "my_pkg123", false},
	}

	for tc, i in test_cases {
		allocator := context.temp_allocator
		ec: error.Collector
		error.collector_init(&ec, false, allocator)

		p: parser.Parser
		parser.parser_init(&p, &ec, allocator)

		l: lexer.Lexer
		lexer.lexer_init(&l, "test.jms", allocator)
		l.src = tc.source
		p.tokens = lexer.lex(&l)
		p.alloc = allocator

		p.file = ast.new(ast.File, {file="test.jms", line=0, column=0}, {file="test.jms", line=0, column=len(tc.source)}, allocator)
		p.file.alloc = allocator

		pkg_name := parser.parse_package(&p)

		testing.expect(t, pkg_name == tc.expected_pkg, fmt.tprintf("Package name should be '%s', got '%s'", tc.expected_pkg, pkg_name))

		if tc.should_error {
			testing.expect(t, !error.is_empty(&ec), "Should have errors for invalid package declaration")
		} else {
			testing.expect(t, error.is_empty(&ec), "Should not have errors for valid package declaration")
		}
	}
}

@(test)
test_parse_ident_expression :: proc(t: ^testing.T) {
	source := "my_variable"

	allocator := context.temp_allocator
	ec: error.Collector
	error.collector_init(&ec, false, allocator)

	p: parser.Parser
	parser.parser_init(&p, &ec, allocator)

	l: lexer.Lexer
	lexer.lexer_init(&l, "test.jms", allocator)
	l.src = source
	p.tokens = lexer.lex(&l)
	p.alloc = allocator
	p.file = ast.new(ast.File, {file="test.jms", line=0, column=0},
					{file="test.jms", line=0, column=len(source)}, allocator)
	p.file.alloc = allocator

	expr := parser.parse_expression(&p)

	testing.expect(t, expr != nil, "Should parse identifier expression")
	if expr != nil {
		ident, ok := expr.derived.(^ast.Ident)
		testing.expect(t, ok, "Expression should be Ident")
		testing.expect(t, ident.name == "my_variable", fmt.tprintf("Identifier name should be 'my_variable', got '%s'", ident.name))
	}
}

@(test)
test_parse_binary_expression :: proc(t: ^testing.T) {
	test_cases := []struct {
		source: string,
		expected_op: lexer.Token_Kind,
	}{
		{"a + b", .Add},
		{"x - y", .Sub},
		{"p * q", .Mul},
		{"m / n", .Quo},
		{"a == b", .Cmp_Eq},
		{"x != y", .Not_Eq},
		{"a && b", .Cmp_And},
		{"x || y", .Cmp_Or},
		{"a < b", .Lt},
		{"x > y", .Gt},
	}

	for tc, i in test_cases {
		allocator := context.temp_allocator
		ec: error.Collector
		error.collector_init(&ec, false, allocator)

		p: parser.Parser
		parser.parser_init(&p, &ec, allocator)

		l: lexer.Lexer
		lexer.lexer_init(&l, "test.jms", allocator)
		l.src = tc.source
		p.tokens = lexer.lex(&l)
		p.alloc = allocator
		p.file = ast.new(ast.File, {file="test.jms", line=0, column=0},
						{file="test.jms", line=0, column=len(tc.source)}, allocator)
		p.file.alloc = allocator

		expr := parser.parse_expression(&p)

		testing.expect(t, expr != nil, fmt.tprintf("Should parse expression: %s", tc.source))
		if expr != nil {
			binary, ok := expr.derived.(^ast.Binary_Expr)
			testing.expect(t, ok, "Expression should be Binary_Expr")
			testing.expect(t, binary.op.kind == tc.expected_op,
				fmt.tprintf("Operator should be %v, got %v", tc.expected_op, binary.op.kind))
		}
	}
}

@(test)
test_parse_assignment_statement :: proc(t: ^testing.T) {
	test_cases := []struct {
		source: string,
		expected_name: string,
		expected_op: lexer.Token_Kind,
	}{
		{"x = 42", "x", .Eq},
		{"y += 10", "y", .Add_Eq},
		{"z *= 2", "z", .Mul_Eq},
	}

	for tc, i in test_cases {
		allocator := context.temp_allocator
		ec: error.Collector
		error.collector_init(&ec, false, allocator)

		p: parser.Parser
		parser.parser_init(&p, &ec, allocator)

		l: lexer.Lexer
		lexer.lexer_init(&l, "test.jms", allocator)
		l.src = tc.source
		p.tokens = lexer.lex(&l)
		p.alloc = allocator
		p.file = ast.new(ast.File, {file="test.jms", line=0, column=0},
						{file="test.jms", line=0, column=len(tc.source)}, allocator)
		p.file.alloc = allocator

		stmt := parser.parse_stmt(&p)

		testing.expect(t, stmt != nil, fmt.tprintf("Should parse statement: %s", tc.source))
		if stmt != nil {
			assign, ok := stmt.derived.(^ast.Assign_Stmt)
			testing.expect(t, ok, "Statement should be Assign_Stmt")
			testing.expect(t, assign.name == tc.expected_name,
				fmt.tprintf("Variable name should be '%s', got '%s'", tc.expected_name, assign.name))
			testing.expect(t, assign.op.kind == tc.expected_op,
				fmt.tprintf("Operator should be %v, got %v", tc.expected_op, assign.op.kind))
		}
	}
}

@(test)
test_parse_if_statement :: proc(t: ^testing.T) {
	source := `if x > 0 {
	return x
} else {
	return 0
}`

	allocator := context.temp_allocator
	ec: error.Collector
	error.collector_init(&ec, false, allocator)

	p: parser.Parser
	parser.parser_init(&p, &ec, allocator)

	l: lexer.Lexer
	lexer.lexer_init(&l, "test.jms", allocator)
	l.src = source
	p.tokens = lexer.lex(&l)
	p.alloc = allocator

	p.file = ast.new(ast.File, {file="test.jms", line=0, column=0},
					{file="test.jms", line=4, column=1}, allocator)
	p.file.alloc = allocator

	stmt := parser.parse_stmt(&p)

	testing.expect(t, stmt != nil, "Should parse if statement")
	if stmt != nil {
		if_stmt, ok := stmt.derived.(^ast.If_Stmt)
		testing.expect(t, ok, "Statement should be If_Stmt")
		testing.expect(t, if_stmt.cond != nil, "If statement should have condition")
		testing.expect(t, if_stmt.body != nil, "If statement should have body")
		testing.expect(t, if_stmt.else_stmt != nil, "If statement should have else block")
	}
}

@(test)
test_parse_function_statement :: proc(t: ^testing.T) {
	source := `func add(a: int, b: int) -> int {
	return a + b
}`

	allocator := context.temp_allocator
	ec: error.Collector
	error.collector_init(&ec, false, allocator)

	p: parser.Parser
	parser.parser_init(&p, &ec, allocator)

	l: lexer.Lexer
	lexer.lexer_init(&l, "test.jms", allocator)
	l.src = source
	p.tokens = lexer.lex(&l)
	p.alloc = allocator

	p.file = ast.new(ast.File, {file="test.jms", line=0, column=0},
					{file="test.jms", line=2, column=1}, allocator)
	p.file.alloc = allocator

	stmt := parser.parse_stmt(&p)

	testing.expect(t, stmt != nil, "Should parse function statement")
	if stmt != nil {
		func_stmt, ok := stmt.derived.(^ast.Func_Stmt)
		testing.expect(t, ok, "Statement should be Func_Stmt")
		testing.expect(t, func_stmt.name == "add", fmt.tprintf("Function name should be 'add', got '%s'", func_stmt.name))
		testing.expect(t, func_stmt.params != nil, "Function should have parameters")
		testing.expect(t, func_stmt.result == "int", fmt.tprintf("Return type should be 'int', got '%s'", func_stmt.result))
		testing.expect(t, func_stmt.body != nil, "Function should have body")

		if func_stmt.params != nil {
			testing.expect(t, len(func_stmt.params.list) == 2, "Function should have 2 parameters")
		}
	}
}

@(test)
test_parse_for_statement :: proc(t: ^testing.T) {
	test_cases := []struct {
		source: string,
		description: string,
	}{
		{`for {
	// infinite loop
}`, "infinite loop"},
		{`for i in 0..=10 {
	process(i)
}`, "range-based for loop"},
	}

	for tc, i in test_cases {
		allocator := context.temp_allocator
		ec: error.Collector
		error.collector_init(&ec, false, allocator)

		p: parser.Parser
		parser.parser_init(&p, &ec, allocator)

		l: lexer.Lexer
		lexer.lexer_init(&l, "test.jms", allocator)
		l.src = tc.source
		p.tokens = lexer.lex(&l)
		p.alloc = allocator

		p.file = ast.new(ast.File, {file="test.jms", line=0, column=0},
						{file="test.jms", line=2, column=1}, allocator)
		p.file.alloc = allocator

		stmt := parser.parse_stmt(&p)

		testing.expect(t, stmt != nil, fmt.tprintf("Should parse for statement: %s", tc.description))
		if stmt != nil {
			for_stmt, ok := stmt.derived.(^ast.For_Stmt)
			testing.expect(t, ok, "Statement should be For_Stmt")
			testing.expect(t, for_stmt.body != nil, "For statement should have body")
		}
	}
}

@(test)
test_parse_annotations :: proc(t: ^testing.T) {
    source := `@deprecated
@(test = "unit test")
func old_func() {
}`

    allocator := context.temp_allocator
    ec: error.Collector
	error.collector_init(&ec, false, allocator)

	p: parser.Parser
    parser.parser_init(&p, &ec, allocator)

    l: lexer.Lexer
    lexer.lexer_init(&l, "test.jms", allocator)
    l.src = source
    p.tokens = lexer.lex(&l)
    p.alloc = allocator

    p.file = ast.new(ast.File, {file="test.jms", line=0, column=0},
                    {file="test.jms", line=3, column=1}, allocator)
    p.file.alloc = allocator

    stmt := parser.parse_stmt(&p)
    testing.expect(t, stmt != nil, "Should parse function statement with annotations")

    if stmt != nil {
        testing.expect(t, len(stmt.annotations) == 2,
               fmt.tprintf("Function statement should have 2 annotations, got %d", len(stmt.annotations)))

        if len(stmt.annotations) >= 2 {
            testing.expect(t, stmt.annotations[0].name == "deprecated",
                   "First annotation should be 'deprecated'")
            testing.expect(t, stmt.annotations[0].value == nil,
                   "First annotation should not have value")

            testing.expect(t, stmt.annotations[1].name == "test",
                   "Second annotation should be 'test'")
            testing.expect(t, stmt.annotations[1].value != nil,
                   "Second annotation should have value")

            func_stmt, ok := stmt.derived.(^ast.Func_Stmt)
            testing.expect(t, ok, "Should be a function statement")
            if ok {
                testing.expect(t, func_stmt.name == "old_func",
                       fmt.tprintf("Function name should be 'old_func', got '%s'", func_stmt.name))
            }
        }
    }
}

@(test)
test_parse_call_expression :: proc(t: ^testing.T) {
	test_cases := []struct {
		source: string,
		expected_func_name: string,
		expected_arg_count: int,
	}{
		{"print()", "print", 0},
		{"sqrt(4)", "sqrt", 1},
		{"max(a, b, c)", "max", 3},
		{"configure(key=\"value\")", "configure", 1},
	}

	for tc, i in test_cases {
		allocator := context.temp_allocator
		ec: error.Collector
		error.collector_init(&ec, false, allocator)

		p: parser.Parser
		parser.parser_init(&p, &ec, allocator)

		l: lexer.Lexer
		lexer.lexer_init(&l, "test.jms", allocator)
		l.src = tc.source
		p.tokens = lexer.lex(&l)
		p.alloc = allocator
		p.file = ast.new(ast.File, {file="test.jms", line=0, column=0},
						{file="test.jms", line=0, column=len(tc.source)}, allocator)
		p.file.alloc = allocator

		expr := parser.parse_expression(&p)

		testing.expect(t, expr != nil, fmt.tprintf("Should parse call expression: %s", tc.source))
		if expr != nil {
			call_expr, ok := expr.derived.(^ast.Call_Expr)
			testing.expect(t, ok, "Expression should be Call_Expr")

			ident, ident_ok := call_expr.expr.derived.(^ast.Ident)
			if ident_ok {
				testing.expect(t, ident.name == tc.expected_func_name,
					fmt.tprintf("Function name should be '%s', got '%s'", tc.expected_func_name, ident.name))
			}

			testing.expect(t, len(call_expr.args) == tc.expected_arg_count,
				fmt.tprintf("Should have %d arguments, got %d", tc.expected_arg_count, len(call_expr.args)))
		}
	}
}

@(test)
test_parse_variable_declaration :: proc(t: ^testing.T) {
	test_cases := []struct {
		source: string,
		expected_name: string,
		expected_type: string,
		expected_is_const: bool,
	}{
		{"x: int = 42", "x", "int", false},
		{"y: = 10", "y", "", false},
		{"PI :: 3.14", "PI", "", true},
		{"name: string : \"test\"", "name", "string", true},
	}

	for tc, i in test_cases {
		allocator := context.temp_allocator
		ec: error.Collector
		error.collector_init(&ec, false, allocator)

		p: parser.Parser
		parser.parser_init(&p, &ec, allocator)

		l: lexer.Lexer
		lexer.lexer_init(&l, "test.jms", allocator)
		l.src = tc.source
		p.tokens = lexer.lex(&l)
		p.alloc = allocator

		p.file = ast.new(ast.File, {file="test.jms", line=0, column=0},
						{file="test.jms", line=0, column=len(tc.source)}, allocator)
		p.file.alloc = allocator

		stmt := parser.parse_stmt(&p)

		testing.expect(t, stmt != nil, fmt.tprintf("Should parse variable declaration: %s", tc.source))
		if stmt != nil {
			value_decl, ok := stmt.derived.(^ast.Value_Decl)
			testing.expect(t, ok, "Statement should be Value_Decl")
			testing.expect(t, value_decl.name == tc.expected_name,
				fmt.tprintf("Variable name should be '%s', got '%s'", tc.expected_name, value_decl.name))
			testing.expect(t, value_decl.type == tc.expected_type,
				fmt.tprintf("Variable type should be '%s', got '%s'", tc.expected_type, value_decl.type))
			testing.expect(t, value_decl.is_const == tc.expected_is_const,
				fmt.tprintf("is_const should be %v, got %v", tc.expected_is_const, value_decl.is_const))
			testing.expect(t, value_decl.value != nil, "Variable should have initial value")
		}
	}
}

@(test)
test_error_recovery :: proc(t: ^testing.T) {
	source := `x =
y = 10
if {
	z = 20
}`

	allocator := context.temp_allocator
	ec: error.Collector
	error.collector_init(&ec, false, allocator)

	p: parser.Parser
	parser.parser_init(&p, &ec, allocator)

	l: lexer.Lexer
	lexer.lexer_init(&l, "test.jms", allocator)
	l.src = source
	p.tokens = lexer.lex(&l)
	p.alloc = allocator

	p.file = ast.new(ast.File, {file="test.jms", line=0, column=0},
					{file="test.jms", line=4, column=1}, allocator)
	p.file.alloc = allocator
	p.file.src = source

	stmts := parser.parse_top_level_stmt_list(&p)

	testing.expect(t, !error.is_empty(&ec), "Should have parsing errors")
	testing.expect(t, len(stmts) > 0, "Should still parse some statements despite errors")
}

@(test)
test_complete_file_parsing :: proc(t: ^testing.T) {
	context.allocator = context.temp_allocator

	source := `#+test
#+unit_test
package math_utils

PI :: 3.14159

func square(x: number) -> number {
	return x * x
}

func max(a: number, b: number) -> number {
	if a > b {
		return a
	} else {
		return b
	}
}

@benchmark
func calculate() {
	result = 0
	for i in 0..=10 {
		result += square(i)
	}
	print(result)
}`

	temp_file := "test.jms"
	testing.cleanup(t, proc(_: rawptr) {
		os.remove("test.jms")
	}, nil)

	os.write_entire_file(temp_file, transmute([]u8)source)

	ec: error.Collector
	error.collector_init(&ec, false, context.allocator)

	p: parser.Parser
	parser.parser_init(&p, &ec, context.allocator)

	file_node := parser.parse_file(&p, temp_file)

	testing.expect(t, file_node != nil, "Should parse complete file")
	testing.expect(t, error.is_empty(&ec), "Should parse without errors")
	if !error.is_empty(&ec) {
		for e in ec.errs {
	 		log.info(e)
	 	}
	}

	if file_node != nil {
		testing.expect(t, len(file_node.tags) == 2, "Should parse file tags")
		testing.expect(t, file_node.pkg == "math_utils", fmt.tprintf("Package should be 'math_utils', got '%s'", file_node.pkg))
		testing.expect(t, len(file_node.decls) == 4, "Should parse 4 top-level declarations")

		const_count, func_count := 0, 0
		for decl in file_node.decls {
			#partial switch stmt in decl.derived {
			case ^ast.Value_Decl:
				const_count += 1
				testing.expect(t, stmt.name == "PI", "Constant should be named 'PI'")
			case ^ast.Func_Stmt:
				func_count += 1
			}
		}

		testing.expect(t, const_count == 1, "Should have 1 constant declaration")
		testing.expect(t, func_count == 3, "Should have 3 function declarations")
	}
}
