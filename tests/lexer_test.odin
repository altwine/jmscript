package tests

import "core:strings"
import "core:log"
import "core:testing"
import "core:unicode/utf8"

import "src:lexer"

Test_Case :: struct {
	name: string,
	input: string,
	expected: []lexer.Token_Kind,
}

@(test)
test_lexer :: proc(t: ^testing.T) {
	test_cases := []Test_Case{
		{
			name = "package declaration",
			input = "package test",
			expected = {.Package, .Ident, .EOF},
		},
		{
			name = "simple arithmetic",
			input = "4 + a + b * 3",
			expected = {.Number, .Add, .Ident, .Add, .Ident, .Mul, .Number, .EOF},
		},
		{
			name = "comparison operators",
			input = "x == y && z > 10",
			expected = {.Ident, .Cmp_Eq, .Ident, .Cmp_And, .Ident, .Gt, .Number, .EOF},
		},
		{
			name = "assignment operators",
			input = "x += 5; y -= 3",
			expected = {.Ident, .Add_Eq, .Number, .Semicolon, .Ident, .Sub_Eq, .Number, .EOF},
		},
		{
			name = "string literals",
			input = `"hello" 'world'`,
			expected = {.Text, .Text, .EOF},
		},
		{
			name = "backtick identifiers",
			input = "`some weird name` normal",
			expected = {.Ident, .Ident, .EOF},
		},
		{
			name = "numbers",
			input = "123 45.67 0",
			expected = {.Number, .Number, .Number, .EOF},
		},
		{
			name = "boolean literals",
			input = "true false",
			expected = {.True, .False, .EOF},
		},
		{
			name = "keywords",
			input = "func if else for in return defer continue event",
			expected = {
				.Func, .If, .Else, .For, .In, .Return, .Defer, .Continue, .Event, .EOF
			},
		},
		{
			name = "delimiters",
			input = "() {} [] ; : , . @",
			expected = {
				.Open_Paren, .Close_Paren,
				.Open_Brace, .Close_Brace,
				.Open_Bracket, .Close_Bracket,
				.Semicolon, .Colon, .Comma, .Period, .At, .EOF
			},
		},
		{
			name = "range operators",
			input = "..< ..=",
			expected = {.Range_Half, .Range_Full, .EOF},
		},
		{
			name = "comment",
			input = "// single line",
			expected = {.EOF},
		},
		{
			name = "multiline comment",
		 	input = "/" + "* multi\nline *" + "/",
		 	expected = {.EOF},
		},
		{
			name = "file tag",
			input = "#+filetag\npackage main",
			expected = {.File_Tag, .Package, .Ident, .EOF},
		},
		{
			name = "arrow operator",
			input = "->",
			expected = {.Arrow_Right, .EOF},
		},
		{
			name = "mixed operators",
			input = "x != y <= 5 >= 3",
			expected = {.Ident, .Not_Eq, .Ident, .Lt_Eq, .Number, .Gt_Eq, .Number, .EOF},
		},
		{
			name = "empty input",
			input = "",
			expected = {.EOF},
		},
		{
			name = "whitespace handling",
			input = "  x  \n  \t y  ",
			expected = {.Ident, .Ident, .EOF},
		},
		{
			name = "unicode in identifiers",
			input = "`привет世界_test`",
			expected = {.Ident, .EOF},
		},
		{
			name = "invalid characters",
			input = "x $ y",
			expected = {.Ident, .Invalid, .Ident, .EOF},
		},
		{
			name = "hash symbol",
			input = "# comment",
			expected = {.Hash, .Ident, .EOF},
		},
		{
			name = "division operators",
			input = "a / b /= 2",
			expected = {.Ident, .Quo, .Ident, .Quo_Eq, .Number, .EOF},
		},
		{
			name = "modulo operators",
			input = "a % b %= 2",
			expected = {.Ident, .Mod, .Ident, .Mod_Eq, .Number, .EOF},
		},
	}

	for test_case in test_cases {
		l: lexer.Lexer
		l.src = test_case.input
		l.path = "test.odin"
		l.alloc = context.allocator
		l.offset = 0
		l.read_offset = 0
		l.line = 0
		l.column = 0

		if len(test_case.input) == 0 {
			l.ch = -1
		} else {
			lexer.advance(&l)
			if l.ch == utf8.RUNE_BOM {
				lexer.advance(&l)
			}
		}

		tokens := make([dynamic]lexer.Token, context.allocator)
		defer delete(tokens)

		for {
			token := lexer.scan(&l)
			if token.kind != .Comment {
				append(&tokens, token)
			}
			if token.kind == .EOF {
				break
			}
		}

		expected_len := len(test_case.expected)
		actual_len := len(tokens)
		testing.expectf(
			t,
			actual_len == expected_len,
			"%s: expected %d tokens, got %d",
			test_case.name,
			expected_len,
			actual_len,
		)

		if actual_len != expected_len {
			continue
		}

		for token, i in tokens {
			expected_kind := test_case.expected[i]
			testing.expectf(
				t,
				token.kind == expected_kind,
				"%s: token[%d]: expected %v, got %v (content: '%s')",
				test_case.name,
				i,
				expected_kind,
				token.kind,
				token.content,
			)

			#partial switch token.kind {
			case .Ident:
				testing.expectf(
					t,
					len(token.content) > 0,
					"%s: token[%d]: identifier should have content",
					test_case.name,
					i,
				)
			case .Number:
				testing.expectf(
					t,
					len(token.content) > 0,
					"%s: token[%d]: number should have content",
					test_case.name,
					i,
				)
			case .Text:
				testing.expectf(
					t,
					len(token.content) >= 2,
					"%s: token[%d]: string literal too short",
					test_case.name,
					i,
				)
			}
		}
	}
}

@(test)
test_lexer_positions :: proc(t: ^testing.T) {
	input := `package test
func main() {
	x = 42
}
`

	l: lexer.Lexer
	l.src = input
	l.path = "test.odin"
	l.alloc = context.allocator

	if len(input) == 0 {
		l.ch = -1
	} else {
		lexer.advance(&l)
		if l.ch == utf8.RUNE_BOM {
			lexer.advance(&l)
		}
	}

	tokens := make([dynamic]lexer.Token, context.allocator)
	defer delete(tokens)

	for {
		token := lexer.scan(&l)
		if token.kind != .Comment {
			append(&tokens, token)
		}
		if token.kind == .EOF {
			break
		}
	}

	testing.expect(t, len(tokens) >= 4, "should have at least 4 tokens")

	if len(tokens) >= 4 {
		testing.expect(t, tokens[0].kind == .Package)
		testing.expect(t, tokens[0].pos.line == 0)
		testing.expect(t, tokens[0].pos.column == 1)

		testing.expect(t, tokens[1].kind == .Ident)
		testing.expect(t, tokens[1].pos.line == 0)
		testing.expect(t, tokens[1].pos.column == 9)

		testing.expect(t, tokens[2].kind == .Func)
		testing.expect(t, tokens[2].pos.line == 1)
		testing.expect(t, tokens[2].pos.column == 1)
	}
}

@(test)
test_lexer_unicode_bom :: proc(t: ^testing.T) {
	input := "\xEF\xBB\xBFpackage test"

	l: lexer.Lexer
	l.src = input
	l.path = "test.odin"
	l.alloc = context.allocator
	l.offset = 0
	l.read_offset = 0
	l.line = 0
	l.column = 0

	tokens := lexer.lex(&l)
	defer delete(tokens)

	testing.expect(t, len(tokens) >= 2, "Should have at least 2 tokens")

	if len(tokens) >= 2 {
		testing.expect(t, tokens[0].kind == .Package, "First token should be Package")
		testing.expect(t, tokens[0].content == "package", "Package token content should be 'package'")

		testing.expect(t, tokens[1].kind == .Ident, "Second token should be Ident")
		testing.expect(t, tokens[1].content == "test", "Ident token content should be 'test'")
	}
}

@(test)
test_lexer_invalid_strings :: proc(t: ^testing.T) {
	test_cases := []struct {
		name: string,
		input: string,
		expect_invalid: bool,
	}{
		{"unterminated string", `"hello`, true},
		{"unterminated string newline", `"hello`, true},
		{"unterminated backtick", "`hello", true},
	}

	for test_case in test_cases {
		l: lexer.Lexer
		l.src = test_case.input
		l.path = "test.odin"
		l.alloc = context.allocator

		lexer.advance(&l)

		tokens := make([dynamic]lexer.Token, context.allocator)
		defer delete(tokens)

		for {
			token := lexer.scan(&l)
			append(&tokens, token)
			if token.kind == .EOF || token.kind == .Invalid {
				break
			}
		}

		if test_case.expect_invalid {
			found_invalid := false
			for token in tokens {
				if token.kind == .Invalid {
					found_invalid = true
					break
				}
			}
			testing.expectf(
				t,
				found_invalid,
				"%s: should have invalid token",
				test_case.name,
			)
		}
	}
}

@(test)
test_lexer_helper_functions :: proc(t: ^testing.T) {
	testing.expect(t, lexer.is_letter('a'))
	testing.expect(t, lexer.is_letter('Z'))
	testing.expect(t, lexer.is_letter('_'))
	testing.expect(t, !lexer.is_letter('1'))
	testing.expect(t, !lexer.is_letter('@'))

	testing.expect(t, lexer.is_digit('0'))
	testing.expect(t, lexer.is_digit('9'))
	testing.expect(t, !lexer.is_digit('a'))
	testing.expect(t, !lexer.is_digit('_'))

	testing.expect(t, lexer.is_literal(.Ident))
	testing.expect(t, lexer.is_literal(.Number))
	testing.expect(t, lexer.is_literal(.Text))
	testing.expect(t, lexer.is_literal(.True))
	testing.expect(t, lexer.is_literal(.False))
	testing.expect(t, !lexer.is_literal(.Package))
	testing.expect(t, !lexer.is_literal(.EOF))

	testing.expect(t, lexer.is_assignment(.Add_Eq))
	testing.expect(t, lexer.is_assignment(.Sub_Eq))
	testing.expect(t, lexer.is_assignment(.Mul_Eq))
	testing.expect(t, lexer.is_assignment(.Quo_Eq))
	testing.expect(t, lexer.is_assignment(.Mod_Eq))
	testing.expect(t, !lexer.is_assignment(.Eq))
	testing.expect(t, !lexer.is_assignment(.Add))

	testing.expect(t, lexer.is_comparsion(.Cmp_Eq))
	testing.expect(t, lexer.is_comparsion(.Not_Eq))
	testing.expect(t, lexer.is_comparsion(.Lt))
	testing.expect(t, lexer.is_comparsion(.Gt))
	testing.expect(t, lexer.is_comparsion(.Lt_Eq))
	testing.expect(t, lexer.is_comparsion(.Gt_Eq))
	testing.expect(t, !lexer.is_comparsion(.Add))
	testing.expect(t, !lexer.is_comparsion(.Ident))

	testing.expect(t, lexer.is_keyword(.Package))
	testing.expect(t, lexer.is_keyword(.Func))
	testing.expect(t, lexer.is_keyword(.Event))
	testing.expect(t, lexer.is_keyword(.For))
	testing.expect(t, lexer.is_keyword(.In))
	testing.expect(t, lexer.is_keyword(.If))
	testing.expect(t, lexer.is_keyword(.Else))
	testing.expect(t, lexer.is_keyword(.Defer))
	testing.expect(t, lexer.is_keyword(.Return))
	testing.expect(t, lexer.is_keyword(.Continue))
	testing.expect(t, !lexer.is_keyword(.Ident))
	testing.expect(t, !lexer.is_keyword(.EOF))
}

@(test)
test_to_string :: proc(t: ^testing.T) {
	test_cases := []struct {
		kind: lexer.Token_Kind,
		expected: string,
	}{
		{.Package, "package"},
		{.Func, "func"},
		{.Ident, "identifier"},
		{.Number, "number"},
		{.Add, "add"},
		{.Sub, "sub"},
		{.EOF, "EOF"},
		{.Invalid, "invalid"},
	}

	for test_case in test_cases {
		result := lexer.to_string(test_case.kind)
		testing.expectf(
			t,
			result == test_case.expected,
			"to_string(%v): expected '%s', got '%s'",
			test_case.kind,
			test_case.expected,
			result,
		)
	}
}

@(test)
test_lexer_peek :: proc(t: ^testing.T) {
	input := "abc 123"

	l: lexer.Lexer
	l.src = input
	l.path = "test.odin"
	l.alloc = context.allocator
	l.offset = 0
	l.read_offset = 0
	l.line = 1
	l.column = 1

	lexer.advance(&l)

	testing.expect(t, l.ch == 'a')

	testing.expect(t, lexer.peek(&l) == 'b')

	lexer.advance(&l)
	testing.expect(t, l.ch == 'b')
	testing.expect(t, lexer.peek(&l) == 'c')

	for i in 0..<len(input) {
		lexer.advance(&l)
	}
	testing.expect(t, lexer.peek(&l) == -1)
	testing.expect(t, l.ch == -1)
}

@(test)
test_lexer_skip_whitespaces :: proc(t: ^testing.T) {
	input := "  \t\n  x"

	l: lexer.Lexer
	l.src = input
	l.path = "test.odin"
	l.alloc = context.allocator

	lexer.advance(&l)
	lexer.skip_whitespaces(&l)

	testing.expect(t, l.ch == 'x')

	testing.expect(t, l.line == 1)
	testing.expect(t, l.column == 3)
}
