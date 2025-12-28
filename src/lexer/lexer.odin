package lexer

import "core:mem"
import "core:os/os2"
import "core:unicode/utf8"

Lexer :: struct {
	alloc: mem.Allocator,
	src: string,
	path: string,
	ch: rune,
	offset: int,
	read_offset: int,
	line: int,
	column: int,
}

lexer_init :: proc(l: ^Lexer, path: string, allocator := context.allocator) {
	src, _ := os2.read_entire_file_from_path(path, allocator)
	l.src = string(src)
	l.path = path
	l.offset = 0
	l.read_offset = 0
	l.alloc = allocator
}

lex :: proc(l: ^Lexer) -> [dynamic]Token {
	tokens := make([dynamic]Token, l.alloc)
	reserve(&tokens, len(l.src))

	if len(l.src) == 0 {
		l.ch = -1
		append(&tokens, Token{kind=.EOF, pos=Pos{file=l.path}})
		return tokens
	}

	advance(l)
	if l.ch == utf8.RUNE_BOM {
		advance(l)
	}

	for {
		token := scan(l)
		if token.kind != .Comment {
			append(&tokens, token)
		}
		if token.kind == .EOF {
			break
		}
	}

	return tokens
}

scan :: proc(l: ^Lexer) -> Token {
	skip_whitespaces(l)

	kind: Token_Kind

	offset := l.offset
	pos := Pos{ file=l.path, offset=offset, line=l.line, column=l.column }

	switch l.ch {
	case 'A'..='Z', 'a'..='z', '_':
		for is_letter(l.ch) || is_digit(l.ch) || l.ch == '_' {
			advance(l)
		}
		switch l.src[offset:l.offset] {
		case "package": kind = .Package
		case "func": kind = .Func
		case "event": kind = .Event
		case "for": kind = .For
		case "in": kind = .In
		case "if": kind = .If
		case "else": kind = .Else
		case "defer": kind = .Defer
		case "return": kind = .Return
		case "continue": kind = .Continue
		case "true": kind = .True
		case "false": kind = .False
		case: kind = .Ident
		}
	case '0'..='9':
		for is_digit(l.ch) {
			advance(l)
		}
		if l.ch == '.' && is_digit(peek(l)) {
			kind = .Float
			advance(l)
			for is_digit(l.ch) {
				advance(l)
			}
		} else {
			kind = .Integer
		}
	case '"', '\'':
		kind = .Text
		quote := l.ch
		advance(l)
		for l.ch != quote {
			if l.ch == -1 || l.ch == '\n' {
				ct := l.src[offset:l.offset]
				return Token{.Invalid, ct, pos}
			}
			advance(l)
		}
		advance(l)
	case '#':
		advance(l)
		if l.ch == '+' {
			advance(l)
			for l.ch != '\n' && l.ch != -1 {
				advance(l)
			}
			kind = .File_Tag
		} else {
			kind = .Hash
		}
	case '/':
		advance(l)
		if l.ch == '/' {
			for l.ch != '\n' && l.ch != -1 {
				advance(l)
			}
			kind = .Comment
		} else if l.ch == '*' {
			advance(l)
			for {
				if l.ch == -1 {
					ct := l.src[offset:l.offset]
					return Token{.Invalid, ct, pos}
				}
				if l.ch == '*' && peek(l) == '/' {
					advance(l)
					advance(l)
					break
				}
				advance(l)
			}
			kind = .Comment
		} else if l.ch == '=' {
			kind = .Quo_Eq
			advance(l)
		} else {
			kind = .Quo
		}
	case '+':
		advance(l)
		if l.ch == '=' {
			kind = .Add_Eq
			advance(l)
		} else {
			kind = .Add
		}
	case '-':
		advance(l)
		if l.ch == '=' {
			kind = .Sub_Eq
			advance(l)
		} else if l.ch == '>' {
			kind = .Arrow_Right
			advance(l)
		} else {
			kind = .Sub
		}
	case '%':
		advance(l)
		if l.ch == '=' {
			kind = .Mod_Eq
			advance(l)
		} else {
			kind = .Mod
		}
	case '=':
		advance(l)
		if l.ch == '=' {
			kind = .Cmp_Eq
			advance(l)
		} else {
			kind = .Eq
		}
	case '!':
		advance(l)
		if l.ch == '=' {
			kind = .Not_Eq
			advance(l)
		} else {
			kind = .Not
		}
	case '*':
		advance(l)
		if l.ch == '=' {
			kind = .Mul_Eq
			advance(l)
		} else {
			kind = .Mul
		}
	case '<':
		advance(l)
		if l.ch == '=' {
			kind = .Lt_Eq
			advance(l)
		} else {
			kind = .Lt
		}
	case '>':
		advance(l)
		if l.ch == '=' {
			kind = .Gt_Eq
			advance(l)
		} else {
			kind = .Gt
		}
	case '&':
		advance(l)
		if l.ch == '&' {
			kind = .Cmp_And
			advance(l)
		} else {
			kind = .Invalid
		}
	case '|':
		advance(l)
		if l.ch == '|' {
			kind = .Cmp_Or
			advance(l)
		} else {
			kind = .Invalid
		}
	case '(':
		kind = .Open_Paren
		advance(l)
	case ')':
		kind = .Close_Paren
		advance(l)
	case '[':
		kind = .Open_Bracket
		advance(l)
	case ']':
		kind = .Close_Bracket
		advance(l)
	case '{':
		kind = .Open_Brace
		advance(l)
	case '}':
		kind = .Close_Brace
		advance(l)
	case ':':
		kind = .Colon
		advance(l)
	case ';':
		kind = .Semicolon
		advance(l)
	case '.':
		advance(l)
		if l.ch == '.' {
			advance(l)
			if l.ch == '<' {
				kind = .Range_Half
				advance(l)
			} else if l.ch == '=' {
				kind = .Range_Full
				advance(l)
			} else {
				kind = .Invalid
			}
		} else {
			kind = .Period
		}
	case ',':
		kind = .Comma
		advance(l)
	case '@':
		kind = .At
		advance(l)
	case -1:
		kind = .EOF
		advance(l)
	case:
		kind = .Invalid
		advance(l)
	}
	content := l.src[offset:l.offset]
	return { kind, content, pos }
}

skip_whitespaces :: proc(l: ^Lexer) {
	for l.ch == ' ' || l.ch == '\t' || l.ch == '\r' || l.ch == '\n' {
		advance(l)
	}
}

advance :: proc(l: ^Lexer) {
	if l.read_offset >= len(l.src) {
		l.ch = -1
		return
	}
	l.offset = l.read_offset
	r, w := utf8.decode_rune(l.src[l.read_offset:])
	l.read_offset += w
	if l.ch == '\n' {
		l.line += 1
		l.column = 1
	} else if l.ch != 0 {
		l.column += 1
	}
	l.ch = r
}

peek :: proc(l: ^Lexer) -> rune {
	if l.read_offset >= len(l.src) {
		return -1
	}
	r, _ := utf8.decode_rune(l.src[l.read_offset:])
	return r
}

is_letter :: proc(r: rune) -> bool {
	return ('a' <= r && r <= 'z') || ('A' <= r && r <= 'Z') || r == '_'
}

is_digit :: proc(r: rune) -> bool {
	return '0' <= r && r <= '9'
}

is_literal :: proc(kind: Token_Kind) -> bool {
	return .B_Literal_Begin < kind && kind < .B_Literal_End
}

is_assignment :: proc(kind: Token_Kind) -> bool {
	return .B_Assignment_Operations_Begin < kind && kind < .B_Assignment_Operations_End
}

is_comparsion :: proc(kind: Token_Kind) -> bool {
	return .B_Comparison_Begin < kind && kind < .B_Comparison_End
}

is_keyword :: proc(kind : Token_Kind) -> bool {
	return .B_Keyword_Begin < kind && kind < .B_Keyword_End
}
