package parser

import "core:os"
import "core:fmt"
import "core:mem"

import "../lexer"
import "../ast"
import "../error"

Parser :: struct {
	alloc: mem.Allocator,
	file: ^ast.File,
	tokens: [dynamic]lexer.Token,
	offset: int,
	errs: [dynamic]error.Error,
}

parser_init :: proc(p: ^Parser, allocator := context.allocator) {
	p.offset = 0
	p.alloc = allocator
	p.errs = make([dynamic]error.Error, allocator)
}

parse_file :: proc(p: ^Parser, fullpath: string) -> (^ast.File, [dynamic]error.Error) {
	l: lexer.Lexer
	lexer.lexer_init(&l, fullpath, p.alloc)
	p.tokens = lexer.lex(&l)
	first_token := p.tokens[0]
	last_token := p.tokens[len(p.tokens)-1]
	p.file = ast.new(ast.File, first_token.pos, last_token.pos, p.alloc)
	p.file.alloc = p.alloc
	p.file.fullpath = fullpath
	src, _ := os.read_entire_file_from_filename(fullpath, p.alloc)
	p.file.src = cast(string)src // TODO: pass file src from lexer
	p.file.tags = parse_file_tags(p)
	p.file.pkg = parse_package(p)
	p.file.decls = parse_top_level_stmt_list(p)
	return p.file, p.errs
}

parse_file_tags :: proc(p: ^Parser) -> [dynamic]string {
	file_tags := make([dynamic]string, p.file.alloc)
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
			add_error(p, "package name should be identifier, fallback to '_'", current(p), peek(p))
		}
	} else {
		add_error(p, "package not declared, fallback to '_'", current(p), peek(p))
	}
	skip_optional_semicolon(p)
	return pkg_name
}

skip_optional_semicolon :: proc(p: ^Parser) {
	if match(p, .Semicolon) {
		advance(p)
	}
}

add_error :: proc(p: ^Parser, message: string, token_from, token_to: lexer.Token) {
	append(&p.errs, error.Error{file=p.file, cause_pos=token_from.pos, cause_end=token_to.pos, message=message})
}

add_warning :: proc(p: ^Parser, message: string, token_from, token_to: lexer.Token) {
	append(&p.errs, error.Error{file=p.file, cause_pos=token_from.pos, cause_end=token_to.pos, message=message, severity=.Warning})
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

parse_top_level_stmt_list :: proc(p: ^Parser) -> [dynamic]^ast.Stmt {
	stmt_list := make([dynamic]^ast.Stmt, p.file.alloc)

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
	annos := parse_annotations(p)

	stmt: ^ast.Stmt
	switch {
	case match(p, .For):
		stmt = parse_for_stmt(p)
	case match(p, .If):
		stmt = parse_if_stmt(p)
	case match(p, .Defer):
		stmt = parse_defer_stmt(p)
	case match(p, .Return):
		stmt = parse_return_stmt(p)
	case match(p, .Func):
		stmt = parse_func_stmt(p)
	case match(p, .Event):
		stmt = parse_event_stmt(p)
	case match(p, .Ident) && (peek(p).kind == .Eq || lexer.is_assignment(peek(p).kind)):
		stmt = parse_assignment_stmt(p)
	case match(p, .Ident) && peek(p).kind == .Colon && (peek(p, 2).kind == .Eq || (peek(p, 2).kind == .Ident && peek(p, 3).kind == .Eq)):
		stmt = parse_variable_declaration(p, false)
	case match(p, .Ident) && peek(p).kind == .Colon && (peek(p, 2).kind == .Colon || (peek(p, 2).kind == .Ident && peek(p, 3).kind == .Colon)):
		stmt = parse_variable_declaration(p, true)
	case match(p, .Open_Brace):
		stmt = parse_block_stmt(p)
	case:
		stmt = parse_expr_stmt(p)
	}

	if stmt != nil && len(annos) > 0 {
		stmt.annotations = annos
	}

	skip_optional_semicolon(p)
	return stmt
}

parse_annotations :: proc(p: ^Parser) -> [dynamic]ast.Annotation {
	annos := make([dynamic]ast.Annotation, p.file.alloc)

	for match(p, .At) {
		parse_annotation_or_list(p, &annos)
	}

	return annos
}

parse_annotation_or_list :: proc(p: ^Parser, annos: ^[dynamic]ast.Annotation) {
	at_tok := current(p)
	start_pos := at_tok.pos
	advance(p)

	if match(p, .Open_Paren) {
		advance(p)

		for !match(p, .Close_Paren) && !match(p, .EOF) {
			parse_single_annotation_in_paren(p, start_pos, annos)

			if match(p, .Comma) {
				advance(p)
				continue
			} else {
				break
			}
		}

		if !match(p, .Close_Paren) {
			add_error(p, "Expected ')' after annotation list", current(p), current(p))
			skip_to_close_paren(p)
			return
		}
		advance(p)

	} else {
		parse_single_anno_without_paren(p, start_pos, annos)
	}
	skip_optional_semicolon(p)
}

parse_single_annotation_in_paren :: proc(p: ^Parser, start_pos: lexer.Pos, annos: ^[dynamic]ast.Annotation) {
	if !match(p, .Ident) {
		add_error(p, "Expected annotation name", current(p), current(p))
		return
	}

	name := current(p).content
	advance(p)

	value: ^ast.Expr = nil

	if match(p, .Eq) {
		advance(p)
		value = parse_expression(p)
		if value == nil {
			add_error(p, "Expected expression after '='", current(p), current(p))
		}
	}

	anno := ast.new(ast.Annotation, start_pos, current(p).pos, p.file.alloc)
	anno.name = name
	anno.value = value
	append(annos, anno^)
}

parse_single_anno_without_paren :: proc(p: ^Parser, start_pos: lexer.Pos, annos: ^[dynamic]ast.Annotation) {
	if !match(p, .Ident) {
		add_error(p, "Expected annotation name after '@'", current(p), current(p))
		return
	}

	name := current(p).content
	end_pos := current(p).pos
	advance(p)

	anno := ast.new(ast.Annotation, start_pos, end_pos, p.file.alloc)
	anno.name = name
	anno.value = nil
	append(annos, anno^)
}

skip_to_close_paren :: proc(p: ^Parser) {
	depth := 1
	for !match(p, .EOF) {
		if match(p, .Open_Paren) {
			depth += 1
		} else if match(p, .Close_Paren) {
			depth -= 1
			if depth == 0 {
				advance(p)
				break
			}
		}
		advance(p)
	}
}

parse_for_stmt :: proc(p: ^Parser) -> ^ast.For_Stmt {
	for_tok := current(p)
	body:  ^ast.Block_Stmt
	init := make([dynamic]^ast.Ident, p.file.alloc)
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
			init1 := ast.new(ast.Ident, ident_tok.pos, ident_tok.pos, p.file.alloc)
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

	for_stmt := ast.new(ast.For_Stmt, for_tok.pos, current(p).pos, p.file.alloc)
	for_stmt.for_pos = for_tok.pos
	for_stmt.init = init[:]
	for_stmt.cond = cond
	for_stmt.body = body
	for_stmt.range_tok = range_tok
	for_stmt.second_cond = second_cond
	return for_stmt
}

parse_expr_stmt :: proc(p: ^Parser) -> ^ast.Expr_Stmt {
	start_tok := current(p)
	expr := parse_expression(p)
	if expr == nil {
		return nil
	}
	expr_stmt := ast.new(ast.Expr_Stmt, start_tok.pos, expr.end, p.file.alloc)
	expr_stmt.expr = expr
	return expr_stmt
}

parse_if_stmt :: proc(p: ^Parser) -> ^ast.If_Stmt {
	if_tok := current(p)
	advance(p)
	expr := parse_expression(p)
	body := parse_block_stmt(p)
	else_stmt: ^ast.Block_Stmt
	else_end: lexer.Pos

	if match(p, .Else) {
		advance(p)
		else_stmt = parse_block_stmt(p)
		else_end = else_stmt.end if else_stmt != nil else current(p).pos
	}

	end_pos := else_end if else_stmt != nil else body.end if body != nil else expr.end if expr != nil else current(p).pos

	if_stmt := ast.new(ast.If_Stmt, if_tok.pos, end_pos, p.file.alloc)
	if_stmt.cond = expr
	if_stmt.body = body
	if_stmt.else_stmt = else_stmt
	return if_stmt
}

parse_defer_stmt :: proc(p: ^Parser) -> ^ast.Defer_Stmt {
	defer_tok := current(p)
	advance(p)
	stmt := parse_stmt(p)
	end_pos := stmt.end if stmt != nil else current(p).pos
	defer_stmt := ast.new(ast.Defer_Stmt, defer_tok.pos, end_pos, p.file.alloc)
	defer_stmt.stmt = stmt
	return defer_stmt
}

parse_return_stmt :: proc(p: ^Parser) -> ^ast.Return_Stmt {
	return_tok := current(p)
	advance(p)
	expr := parse_expression(p)
	end_pos := expr.end if expr != nil else return_tok.pos
	return_stmt := ast.new(ast.Return_Stmt, return_tok.pos, end_pos, p.file.alloc)
	return_stmt.result = expr
	return return_stmt
}

parse_assignment_stmt :: proc(p: ^Parser) -> ^ast.Assign_Stmt {
	name_tok := current(p)
	op_tok := advance(p)
	advance(p)
	expr := parse_expression(p)
	end_pos := expr.end if expr != nil else current(p).pos

	assign_stmt := ast.new(ast.Assign_Stmt, name_tok.pos, end_pos, p.file.alloc)
	assign_stmt.name = name_tok.content
	assign_stmt.op = op_tok
	assign_stmt.expr = expr
	return assign_stmt
}

parse_variable_declaration :: proc(p: ^Parser, is_const: bool) -> ^ast.Value_Decl {
	name_tok := current(p)
	advance(p)
	advance(p)

	type := ""
	if match(p, .Ident) {
		type = current(p).content
		advance(p)
	}

	advance(p)
	value := parse_expression(p)

	end_pos := value.end if value != nil else current(p).pos

	value_decl := ast.new(ast.Value_Decl, name_tok.pos, end_pos, p.file.alloc)
	value_decl.name = name_tok.content
	value_decl.type = type
	value_decl.is_const = is_const
	value_decl.value = value
	return value_decl
}

parse_event_stmt :: proc(p: ^Parser) -> ^ast.Event_Stmt {
	event_keyword := current(p)
	event_name := advance(p)

	open_paren := advance(p)
	params := make([dynamic]^ast.Param, p.file.alloc)
	if peek(p).kind != .Close_Paren {
		for {
			param_name := advance(p)
			param_sep := advance(p)
			param_type := advance(p)
			param := ast.new(ast.Param, param_name.pos, param_type.pos, p.file.alloc)
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
	params_list := ast.new(ast.Param_List, open_paren.pos, close_paren.pos, p.file.alloc)
	params_list.list = params[:]

	advance(p)

	block_stmt := parse_block_stmt(p)

	end_pos := block_stmt.end if block_stmt != nil else current(p).pos

	event_stmt := ast.new(ast.Event_Stmt, event_keyword.pos, end_pos, p.file.alloc)
	event_stmt.name = event_name.content
	event_stmt.params = params_list
	event_stmt.body = block_stmt
	return event_stmt
}

parse_func_stmt :: proc(p: ^Parser) -> ^ast.Func_Stmt {
	func_keyword := current(p)
	func_name := advance(p)

	open_paren := advance(p)
	params := make([dynamic]^ast.Param, p.file.alloc)
	if peek(p).kind != .Close_Paren {
		for {
			param_name := advance(p)
			param_sep := advance(p)
			param_type := advance(p)
			param := ast.new(ast.Param, param_name.pos, param_type.pos, p.file.alloc)
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
	params_list := ast.new(ast.Param_List, open_paren.pos, close_paren.pos, p.file.alloc)
	params_list.list = params[:]

	advance(p)
	result_type := ""
	if match(p, .Arrow_Right) {
		result_type = advance(p).content
		advance(p)
	}

	block_stmt := parse_block_stmt(p)

	end_pos := block_stmt.end if block_stmt != nil else current(p).pos

	func_stmt := ast.new(ast.Func_Stmt, func_keyword.pos, end_pos, p.file.alloc)
	func_stmt.name = func_name.content
	func_stmt.params = params_list
	func_stmt.result = result_type
	func_stmt.body = block_stmt
	return func_stmt
}

parse_block_stmt :: proc(p: ^Parser) -> ^ast.Block_Stmt {
	open_brace := current(p)
	advance(p)

	stmt_list := make([dynamic]^ast.Stmt, p.file.alloc)
	deferred_stmt_list := make([dynamic]^ast.Stmt, p.file.alloc)

	for !match(p, .Close_Brace) && !match(p, .EOF) {
		stmt := parse_stmt(p)
		if stmt != nil {
			defer_stmt, is_defer_stmt := stmt.derived.(^ast.Defer_Stmt)
			if is_defer_stmt {
				append(&deferred_stmt_list, defer_stmt.stmt)
			} else {
				append(&stmt_list, stmt)
			}
		} else if !match(p, .Close_Brace) && !match(p, .EOF) {
			advance(p)
		}
	}

	if !match(p, .Close_Brace) {
		add_error(p, "expected '}'", current(p), current(p))
		return nil
	}

	close_brace := current(p)
	advance(p)

	#reverse for deferred_stmt in deferred_stmt_list {
		append(&stmt_list, deferred_stmt)
	}

	block_stmt := ast.new(ast.Block_Stmt, open_brace.pos, close_brace.pos, p.file.alloc)
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
			add_error(p, "expected expression after '||'", current(p), current(p))
			return left
		}

		binary_expr := ast.new(ast.Binary_Expr, left.pos, right.end, p.file.alloc)
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
			add_error(p, "expected expression after '&&'", current(p), current(p))
			return left
		}

		binary_expr := ast.new(ast.Binary_Expr, left.pos, right.end, p.file.alloc)
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
				add_error(p, "expected expression after operator", current(p), current(p))
				return left
			}

			binary_expr := ast.new(ast.Binary_Expr, left.pos, right.end, p.file.alloc)
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
				add_error(p, "expected expression after operator", current(p), current(p))
				return left
			}

			binary_expr := ast.new(ast.Binary_Expr, left.pos, right.end, p.file.alloc)
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
				add_error(p, "expected expression after operator", current(p), current(p))
				return left
			}

			binary_expr := ast.new(ast.Binary_Expr, left.pos, right.end, p.file.alloc)
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

	args := make([dynamic]^ast.Argument, p.file.alloc)
	positional_args_started := false

	if !match(p, .Close_Paren) {
		for {
			pos_arg_name := ""
			if match(p, .Ident) && peek(p).kind == .Eq {
				positional_args_started = true
				pos_arg_name = current(p).content
				advance(p)
				advance(p)
			} else if positional_args_started {
				fmt.printfln("%v", current(p))
				add_error(p, "positional arguments not allowed after keyword arguments in function call", current(p), current(p))
			}
			arg := parse_expression(p)
			if arg == nil {
				add_error(p, "expected expression in function call argument", current(p), current(p))
				break
			}
			pos_arg := ast.new(ast.Argument, arg.pos, arg.end, p.file.alloc)
			pos_arg.name = pos_arg_name
			pos_arg.value = arg
			append(&args, pos_arg)
			if match(p, .Comma) {
				advance(p)
			} else {
				break
			}
		}
	}

	if !match(p, .Close_Paren) {
		add_error(p, "expected ')' after function call arguments", current(p), current(p))
		return func_expr
	}

	close_paren := current(p)

	call_expr := ast.new(ast.Call_Expr, func_expr.pos, close_paren.pos, p.file.alloc)
	call_expr.expr = func_expr
	call_expr.args = args[:]
	advance(p)

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

		unary_expr := ast.new(ast.Unary_Expr, op_token.pos, operand.end, p.file.alloc)
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
				add_error(p, "expected identifier after '.'", current(p), current(p))
				return expr
			}
			field_token := current(p)
			advance(p)

			field_access := ast.new(ast.Field_Access, expr.pos, field_token.pos, p.file.alloc)
			field_access.expr = expr
			field_access.field = field_token.content
			expr = field_access

		case .Open_Bracket:
			open_bracket := current(p)
			advance(p)
			index_expr := parse_expression(p)
			if index_expr == nil {
				add_error(p, "expected expression inside brackets", current(p), current(p))
				return expr
			}
			if !match(p, .Close_Bracket) {
				add_error(p, "expected ']'", current(p), current(p))
				return expr
			}
			close_bracket := current(p)
			advance(p)

			index_access := ast.new(ast.Index_Expr, expr.pos, close_bracket.pos, p.file.alloc)
			index_access.expr = expr
			index_access.index = index_expr
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

		ident_expr := ast.new(ast.Ident, token.pos, token.pos, p.file.alloc)
		ident_expr.name = token.content

		if match(p, .Open_Paren) {
			return parse_call_expression(p, ident_expr)
		}

		return ident_expr

	case .Text, .Number, .True, .False:
		advance(p)
		basic_lit := ast.new(ast.Basic_Lit, token.pos, token.pos, p.file.alloc)
		basic_lit.tok = token
		return basic_lit

	case .Open_Paren:
		open_token := current(p)
		advance(p)
		expr := parse_expression(p)
		if expr == nil {
			add_error(p, "expected expression after '('", token, current(p))
			return nil
		}
		if !match(p, .Close_Paren) {
			add_error(p, "expected ')'", current(p), current(p))
			return nil
		}
		close_token := current(p)
		advance(p)

		paren_expr := ast.new(ast.Paren_Expr, open_token.pos, close_token.pos, p.file.alloc)
		paren_expr.expr = expr
		paren_expr.open = open_token.pos
		paren_expr.close = close_token.pos
		return paren_expr

	case:
		add_error(p, "unexpected token in expression", token, token)
		return nil
	}
}
