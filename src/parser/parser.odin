package parser

import "core:fmt"
import "core:mem"

import "../lexer"
import "../ast"

Parser :: struct {
	alloc: mem.Allocator,
	file: ^ast.File,
	tokens: [dynamic]lexer.Token,
	offset: int,
	errs: [dynamic]Parse_Error,
}

Parse_Error :: struct {
	message: string,
	offset_from: int,
	offset_to: int,
}

parser_init :: proc(p: ^Parser, allocator := context.allocator) {
	p.offset = 0
	p.alloc = allocator
	p.errs = make([dynamic]Parse_Error, allocator)
}

parse_file :: proc(p: ^Parser, fullpath: string, file_id: int) -> (^ast.File, [dynamic]Parse_Error) {
	l: lexer.Lexer
	lexer.lexer_init(&l, fullpath, p.alloc)
	p.tokens = lexer.lex(&l)
	first_token := p.tokens[0]
	last_token := p.tokens[len(p.tokens)-1]
	p.file = ast.new(ast.File, first_token.pos, last_token.pos, p.alloc)
	p.file.fullpath = fullpath
	p.file.id = file_id
	p.file.tags = parse_file_tags(p)
	p.file.pkg = parse_package(p)
	p.file.decls = parse_stmt_list(p)
	return p.file, p.errs
}

parse_file_tags :: proc(p: ^Parser) -> [dynamic]string {
	file_tags := make([dynamic]string, p.alloc)
	for match(p, .File_Tag) {
		append(&file_tags, current(p).content[2:])
		advance(p)
	}
	return file_tags
}

parse_package :: proc(p: ^Parser) -> string {
	pkg_name := "_"
	if match(p, .Package) {
		advance(p)
		if match(p, .Ident) {
			pkg_name = current(p).content
			advance(p)
		} else {
			add_error(p, "Package name should be identifier, fallback to '_'", current(p), peek(p))
		}
	} else {
		add_error(p, "Package not declared, fallback to '_'", current(p), peek(p))
	}
	return pkg_name
}

// skip_optional_semicolon :: proc(p: ^Parser) {
// 	if match(p, .Semicolon) {
// 		advance(p)
// 	}
// }

add_error :: proc(p: ^Parser, message: string, token_from, token_to: lexer.Token) {
	offset_from := token_from.pos.offset
	offset_to := token_to.pos.offset
	append(&p.errs, Parse_Error{message, offset_from, offset_to})
}

match :: proc(p: ^Parser, kind: lexer.Token_Kind) -> bool {
	return current(p).kind == kind
}

current :: proc(p: ^Parser) -> lexer.Token {
	return peek(p, 0)
}

peek :: proc(p: ^Parser, offset := 1) -> lexer.Token {
	if len(p.tokens) == 0 {
		return lexer.Token{kind = .EOF}
	}

	target_offset := p.offset + offset
	if target_offset >= len(p.tokens) {
		return lexer.Token{kind = .EOF}
	}

	return p.tokens[target_offset]
}

advance :: proc(p: ^Parser) -> lexer.Token {
	if p.offset < len(p.tokens) {
		p.offset += 1
	}
	return current(p)
}

parse_stmt_list :: proc(p: ^Parser) -> [dynamic]^ast.Stmt {
	stmt_list := make([dynamic]^ast.Stmt, p.alloc)

	for !match(p, .EOF) {
		stmt := parse_stmt(p)
		if stmt != nil {
			append(&stmt_list, stmt)
		} else if !match(p, .EOF) {
			advance(p)
		}
	}

	return stmt_list
}

parse_stmt :: proc(p: ^Parser) -> ^ast.Stmt {
	switch {
	case match(p, .For):
		return parse_for_stmt(p)
	case match(p, .If):
		return parse_if_stmt(p)
	case match(p, .Defer):
		return parse_defer_stmt(p)
	case match(p, .Return):
		return parse_return_stmt(p)
	case match(p, .Func):
		return parse_func_stmt(p)
	case match(p, .Event):
		return parse_event_stmt(p)
	case match(p, .Ident) && (peek(p).kind == .Eq || lexer.is_assignment(peek(p).kind)):
		return parse_assignment_stmt(p)
	case match(p, .Ident) && peek(p).kind == .Colon && (peek(p, 2).kind == .Eq || (peek(p, 2).kind == .Ident && peek(p, 3).kind == .Eq)):
		return parse_variable_declaration(p, false)
	case match(p, .Ident) && peek(p).kind == .Colon && (peek(p, 2).kind == .Colon || (peek(p, 2).kind == .Ident && peek(p, 3).kind == .Colon)):
		return parse_variable_declaration(p, true)
	case:
		return parse_expr_stmt(p)
	}
}

parse_for_stmt :: proc(p: ^Parser) -> ^ast.For_Stmt {
	for_tok := current(p)
	body:  ^ast.Block_Stmt
	init := make([dynamic]^ast.Ident, p.alloc)
	cond: ^ast.Expr
	range_tok: lexer.Token
	second_cond: ^ast.Expr
	advance(p)
	if match(p, .Open_Brace) {
		body = parse_block_stmt(p)
	} else {
		for match(p, .Ident) {
			ident_tok := current(p)
			advance(p)
			init1 := ast.new(ast.Ident, ident_tok.pos, ident_tok.pos, p.alloc)
			init1.name = ident_tok.content
			append(&init, init1)
			if match(p, .Comma) {
				advance(p)
			}
		}
		if match(p, .In) {
			advance(p)
		}
		cond = parse_expression(p)
		if match(p, .Open_Brace) {
			body = parse_block_stmt(p)
		} else {
			fmt.printfln("[DEBUG] Strange for loop, unhandled")
		}
	}

	for_stmt := ast.new(ast.For_Stmt, for_tok.pos, current(p).pos, p.alloc)
	for_stmt.for_pos = for_tok.pos
	for_stmt.init = init[:]
	for_stmt.cond = cond
	for_stmt.body = body
	for_stmt.range_tok = range_tok
	for_stmt.second_cond = second_cond
	return for_stmt
}

parse_expr_stmt :: proc(p: ^Parser) -> ^ast.Expr_Stmt {
	initial_tok := current(p)
	expr := parse_expression(p)
	expr_stmt := ast.new(ast.Expr_Stmt, initial_tok.pos, current(p).pos, p.alloc)
	expr_stmt.expr = expr
	return expr_stmt
}

parse_if_stmt :: proc(p: ^Parser) -> ^ast.If_Stmt {
	if_tok := current(p)
	advance(p)
	expr := parse_expression(p)
	body := parse_block_stmt(p)
	else_stmt: ^ast.Block_Stmt

	if match(p, .Else) {
		advance(p)
		else_stmt = parse_block_stmt(p)
	}

	if_stmt := ast.new(ast.If_Stmt, if_tok.pos, current(p).pos, p.alloc)
	if_stmt.if_pos = if_tok.pos
	if_stmt.cond = expr
	if_stmt.body = body
	if_stmt.else_stmt = else_stmt
	return if_stmt
}

parse_defer_stmt :: proc(p: ^Parser) -> ^ast.Defer_Stmt {
	defer_tok := current(p)
	advance(p)
	stmt := parse_stmt(p)
	defer_stmt := ast.new(ast.Defer_Stmt, defer_tok.pos, current(p).pos, p.alloc)
	defer_stmt.stmt = stmt
	return defer_stmt
}

parse_return_stmt :: proc(p: ^Parser) -> ^ast.Return_Stmt {
	return_tok := current(p)
	advance(p)
	expr := parse_expression(p)
	return_stmt := ast.new(ast.Return_Stmt, return_tok.pos, current(p).pos, p.alloc)
	return_stmt.result = expr
	return return_stmt
}

parse_assignment_stmt :: proc(p: ^Parser) -> ^ast.Assign_Stmt {
	var_name := current(p)
	op_tok := advance(p)
	advance(p)
	expr := parse_expression(p)

	assign_stmt := ast.new(ast.Assign_Stmt, var_name.pos, current(p).pos, p.alloc)
	assign_stmt.name = var_name.content
	assign_stmt.op = op_tok
	assign_stmt.expr = expr
	return assign_stmt
}

parse_variable_declaration :: proc(p: ^Parser, is_const: bool) -> ^ast.Value_Decl {
	name := current(p)
	advance(p)
	advance(p)
	type := "any"
	if match(p, .Ident) {
		type = current(p).content
		advance(p)
	}
	advance(p)
	value := parse_expression(p)

	const_decl := ast.new(ast.Value_Decl, name.pos, current(p).pos, p.alloc)
	const_decl.name = name.content
	const_decl.type = type
	const_decl.is_const = is_const
	const_decl.value = value
	return const_decl
}

parse_event_stmt :: proc(p: ^Parser) -> ^ast.Event_Stmt {
	event_keyword := current(p)
	event_name := advance(p)

	open_paren := advance(p)
	params := make([dynamic]^ast.Param, p.alloc)
	if peek(p).kind != .Close_Paren {
		for {
			param_name := advance(p)
			param_sep := advance(p)
			param_type := advance(p)
			param := ast.new(ast.Param, param_name.pos, param_type.pos, p.alloc)
			param.name = param_name.content
			param.type = param_type.content
			append(&params, param)
			advance(p)
			if match(p, .Comma) {
				continue
			}
			if match(p, .Close_Paren) || match(p, .EOF) {
				break
			}
		}
	} else {
		advance(p)
	}
	close_paren := current(p)
	params_list := ast.new(ast.Param_List, open_paren.pos, close_paren.pos, p.alloc)
	params_list.list = params[:]

	advance(p)

	block_stmt := parse_block_stmt(p)

	event_stmt := ast.new(ast.Event_Stmt, event_keyword.pos, current(p).pos, p.alloc)
	event_stmt.tok = event_keyword
	event_stmt.name = event_name.content
	event_stmt.params = params_list
	event_stmt.body = block_stmt
	return event_stmt
}

parse_func_stmt :: proc(p: ^Parser) -> ^ast.Func_Stmt {
	func_keyword := current(p)
	func_name := advance(p)

	open_paren := advance(p)
	params := make([dynamic]^ast.Param, p.alloc)
	if peek(p).kind != .Close_Paren {
		for {
			param_name := advance(p)
			param_sep := advance(p)
			param_type := advance(p)
			param := ast.new(ast.Param, param_name.pos, param_type.pos, p.alloc)
			param.name = param_name.content
			param.type = param_type.content
			append(&params, param)
			advance(p)
			if match(p, .Comma) {
				continue
			}
			if match(p, .Close_Paren) || match(p, .EOF) {
				break
			}
		}
	} else {
		advance(p)
	}
	close_paren := current(p)
	params_list := ast.new(ast.Param_List, open_paren.pos, close_paren.pos, p.alloc)
	params_list.list = params[:]

	advance(p)
	arrow_tok_pos: lexer.Pos
	result_type := "void"
	if match(p, .Arrow_Right) {
		arrow_tok_pos = current(p).pos
		result_type = advance(p).content
		advance(p)
	}

	block_stmt := parse_block_stmt(p)

	func_stmt := ast.new(ast.Func_Stmt, func_keyword.pos, current(p).pos, p.alloc)
	func_stmt.tok = func_keyword
	func_stmt.name = func_name.content
	func_stmt.params = params_list
	func_stmt.arrow = arrow_tok_pos
	func_stmt.result = result_type
	func_stmt.body = block_stmt
	return func_stmt
}

parse_block_stmt :: proc(p: ^Parser) -> ^ast.Block_Stmt {
	open_brace := current(p)
	advance(p)

	stmt_list := make([dynamic]^ast.Stmt, p.alloc)

	for !match(p, .Close_Brace) && !match(p, .EOF) {
		stmt := parse_stmt(p)
		if stmt != nil {
			append(&stmt_list, stmt)
		} else if !match(p, .Close_Brace) && !match(p, .EOF) {
			advance(p)
		}
	}

	if !match(p, .Close_Brace) {
		add_error(p, "Expected '}'", current(p), current(p))
		return nil
	}

	close_brace := current(p)
	advance(p)

	block_stmt := ast.new(ast.Block_Stmt, open_brace.pos, close_brace.pos, p.alloc)
	block_stmt.stmts = stmt_list[:]
	return block_stmt
}

parse_expression :: proc(p: ^Parser) -> ^ast.Expr {
	return parse_logical_or(p)
}

parse_logical_or :: proc(p: ^Parser) -> ^ast.Expr {
	left := parse_logical_and(p)
	if left == nil {
		return nil
	}

	for match(p, .Cmp_Or) {
		op_token := current(p)
		advance(p)
		right := parse_logical_and(p)
		if right == nil {
			add_error(p, "Expected expression after '||'", current(p), current(p))
			return left
		}

		binary_expr := ast.new(ast.Binary_Expr, left.pos, right.pos, p.alloc)
		binary_expr.left = left
		binary_expr.right = right
		binary_expr.op = op_token
		left = binary_expr
	}
	return left
}

parse_logical_and :: proc(p: ^Parser) -> ^ast.Expr {
	left := parse_comparison(p)
	if left == nil {
		return nil
	}

	for match(p, .Cmp_And) {
		op_token := current(p)
		advance(p)
		right := parse_comparison(p)
		if right == nil {
			add_error(p, "Expected expression after '&&'", current(p), current(p))
			return left
		}

		binary_expr := ast.new(ast.Binary_Expr, left.pos, right.pos, p.alloc)
		binary_expr.left = left
		binary_expr.right = right
		binary_expr.op = op_token
		left = binary_expr
	}
	return left
}

parse_comparison :: proc(p: ^Parser) -> ^ast.Expr {
	left := parse_addition(p)
	if left == nil {
		return nil
	}

	for {
		#partial switch current(p).kind {
		case .Cmp_Eq, .Not_Eq, .Lt, .Gt, .Lt_Eq, .Gt_Eq:
			op_token := current(p)
			advance(p)
			right := parse_addition(p)
			if right == nil {
				add_error(p, "Expected expression after operator", current(p), current(p))
				return left
			}

			binary_expr := ast.new(ast.Binary_Expr, left.pos, right.pos, p.alloc)
			binary_expr.left = left
			binary_expr.right = right
			binary_expr.op = op_token
			left = binary_expr
		case:
			return left
		}
	}
}

parse_addition :: proc(p: ^Parser) -> ^ast.Expr {
	left := parse_multiplication(p)
	if left == nil {
		return nil
	}

	for {
		#partial switch current(p).kind {
		case .Add, .Sub:
			op_token := current(p)
			advance(p)
			right := parse_multiplication(p)
			if right == nil {
				add_error(p, "Expected expression after operator", current(p), current(p))
				return left
			}

			binary_expr := ast.new(ast.Binary_Expr, left.pos, right.pos, p.alloc)
			binary_expr.left = left
			binary_expr.right = right
			binary_expr.op = op_token
			left = binary_expr
		case:
			return left
		}
	}
}

parse_multiplication :: proc(p: ^Parser) -> ^ast.Expr {
	left := parse_unary(p)
	if left == nil {
		return nil
	}

	for {
		#partial switch current(p).kind {
		case .Mul, .Quo, .Mod:
			op_token := current(p)
			advance(p)
			right := parse_unary(p)
			if right == nil {
				add_error(p, "Expected expression after operator", current(p), current(p))
				return left
			}

			binary_expr := ast.new(ast.Binary_Expr, left.pos, right.pos, p.alloc)
			binary_expr.left = left
			binary_expr.right = right
			binary_expr.op = op_token
			left = binary_expr
		case:
			return left
		}
	}
}

parse_call_expression :: proc(p: ^Parser, func_expr: ^ast.Expr) -> ^ast.Expr {
	open_paren := current(p)
	advance(p)

	args := make([dynamic]^ast.Expr, p.alloc)

	if !match(p, .Close_Paren) {
		for {
			arg := parse_expression(p)
			if arg == nil {
				add_error(p, "Expected expression in function call argument", current(p), current(p))
				break
			}
			append(&args, arg)

			if match(p, .Comma) {
				advance(p)
			} else {
				break
			}
		}
	}

	if !match(p, .Close_Paren) {
		add_error(p, "Expected ')' after function call arguments", current(p), current(p))
		return func_expr
	}
	close_paren := advance(p)

	call_expr := ast.new(ast.Call_Expr, func_expr.pos, close_paren.pos, p.alloc)
	call_expr.expr = func_expr
	call_expr.args = args[:]
	call_expr.open = open_paren.pos
	call_expr.close = close_paren.pos

	return call_expr
}

parse_unary :: proc(p: ^Parser) -> ^ast.Expr {
	if match(p, .Add) || match(p, .Sub) || match(p, .Not) {
		op_token := current(p)
		advance(p)
		operand := parse_unary(p)
		if operand == nil {
			return nil
		}

		unary_expr := ast.new(ast.Unary_Expr, op_token.pos, operand.pos, p.alloc)
		unary_expr.op = op_token
		unary_expr.expr = operand
		return unary_expr
	}

	return parse_access_chain(p)
}

parse_access_chain :: proc(p: ^Parser) -> ^ast.Expr {
	expr := parse_primary(p)
	if expr == nil {
		return nil
	}

	for {
		#partial switch current(p).kind {
		case .Period:
			dot_token := current(p)
			advance(p)
			if !match(p, .Ident) {
				add_error(p, "Expected identifier after '.'", current(p), current(p))
				return expr
			}
			field_token := current(p)
			advance(p)

			field_access := ast.new(ast.Field_Access, expr.pos, field_token.pos, p.alloc)
			field_access.expr = expr
			field_access.field = field_token.content
			field_access.dot = dot_token.pos
			expr = field_access

		case .Open_Bracket:
			open_bracket := current(p)
			advance(p)
			index_expr := parse_expression(p)
			if index_expr == nil {
				add_error(p, "Expected expression inside brackets", current(p), current(p))
				return expr
			}
			if !match(p, .Close_Bracket) {
				add_error(p, "Expected ']'", current(p), current(p))
				return expr
			}
			close_bracket := current(p)
			advance(p)

			index_access := ast.new(ast.Index_Expr, expr.pos, close_bracket.pos, p.alloc)
			index_access.expr = expr
			index_access.index = index_expr
			index_access.open_bracket = open_bracket.pos
			index_access.close_bracket = close_bracket.pos
			expr = index_access

		case .Open_Paren:
			expr = parse_call_expression(p, expr)

		case:
			return expr
		}
	}
}

parse_primary :: proc(p: ^Parser) -> ^ast.Expr {
	token := current(p)

	#partial switch token.kind {
	case .Ident:
		advance(p)

		ident_expr := ast.new(ast.Ident, token.pos, token.pos, p.alloc)
		ident_expr.name = token.content

		if match(p, .Open_Paren) {
			return parse_call_expression(p, ident_expr)
		}

		return ident_expr

	case .Float, .Text, .Integer, .True, .False:
		advance(p)
		basic_lit := ast.new(ast.Basic_Lit, token.pos, token.pos, p.alloc)
		basic_lit.tok = token
		return basic_lit

	case .Open_Paren:
		open_token := current(p)
		advance(p)
		expr := parse_expression(p)
		if expr == nil {
			add_error(p, "Expected expression after '('", token, current(p))
			return nil
		}
		if !match(p, .Close_Paren) {
			add_error(p, "Expected ')'", current(p), current(p))
			return nil
		}
		close_token := current(p)
		advance(p)

		paren_expr := ast.new(ast.Paren_Expr, open_token.pos, close_token.pos, p.alloc)
		paren_expr.expr = expr
		paren_expr.open = open_token.pos
		paren_expr.close = close_token.pos
		return paren_expr

	case:
		add_error(p, "Unexpected token in expression", token, token)
		return nil
	}
}
