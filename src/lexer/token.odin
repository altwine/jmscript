package lexer

Token :: struct {
	kind: Token_Kind,
	content: string,
	pos: Pos,
}

Pos :: struct {
	file: string,
	offset: int,
	line: int,
	column: int,
}

Token_Kind :: enum {
	Invalid,  // invalid
	EOF,      // end of file
	Comment,  // comment
	File_Tag, // #+filetag

	B_Literal_Begin,
		Ident,  // identifier, `strange identifier 🥀`
		Number, // 12345, 123.45
		Text,   // "some text"
		True,   // true
		False,  // false
	B_Literal_End,

	B_Keyword_Begin,
		Package,  // package
		Func,     // func
		Event,    // event
		For,      // for
		In,       // in
		If,       // if
		Else,     // else
		Defer,    // defer
		Return,   // return
		Continue, // continue
	B_Keyword_End,

	B_Operator_Begin,
		Eq,      // =
		Not,     // !
		Add,     // +
		Sub,     // -
		Mul,     // *
		Quo,     // /
		Mod,     // %
		Hash,    // #
		At,      // @
		Cmp_And, // &&
		Cmp_Or,  // ||

	B_Assignment_Operations_Begin,
		Add_Eq, // +=
		Sub_Eq, // -=
		Mul_Eq, // *=
		Quo_Eq, // /=
		Mod_Eq, // %=
	B_Assignment_Operations_End,

	Arrow_Right, // ->

	B_Comparison_Begin,
		Cmp_Eq, // ==
		Not_Eq, // !=
		Lt,     // <
		Gt,     // >
		Lt_Eq,  // <=
		Gt_Eq,  // >=
	B_Comparison_End,

		Open_Paren,    // (
		Close_Paren,   // )
		Open_Bracket,  // [
		Close_Bracket, // ]
		Open_Brace,    // {
		Close_Brace,   // }
		Colon,         // :
		Semicolon,     // ;
		Period,        // .
		Comma,         // ,
		Range_Half,    // ..<
		Range_Full,    // ..=
	B_Operator_End,
}

to_string :: proc(kind: Token_Kind) -> string {
	#partial switch kind {
	case .EOF: return "EOF"
	case .Comment: return "comment"
	case .File_Tag: return "file_tag"
	case .Ident: return "identifier"
	case .Number: return "number"
	case .Text: return "text"
	case .Package: return "package"
	case .Func: return "func"
	case .Event: return "event"
	case .For: return "for"
	case .In: return "in"
	case .If: return "if"
	case .Else: return "else"
	case .Defer: return "defer"
	case .Return: return "return"
	case .Continue: return "continue"
	case .True: return "true"
	case .False: return "false"
	case .Eq: return "eq"
	case .Not: return "not"
	case .Add: return "add"
	case .Sub: return "sub"
	case .Mul: return "mul"
	case .Quo: return "quo"
	case .Mod: return "mod"
	case .Hash: return "hash"
	case .At: return "at"
	case .Cmp_And: return "cmp_and"
	case .Cmp_Or: return "cmp_or"
	case .Add_Eq: return "add_eq"
	case .Sub_Eq: return "sub_eq"
	case .Mul_Eq: return "mul_eq"
	case .Quo_Eq: return "quo_eq"
	case .Mod_Eq: return "mod_eq"
	case .Arrow_Right: return "arrow_right"
	case .Cmp_Eq: return "cmp_eq"
	case .Not_Eq: return "not_eq"
	case .Lt: return "lt"
	case .Gt: return "gt"
	case .Lt_Eq: return "lt_eq"
	case .Gt_Eq: return "gt_eq"
	case .Open_Paren: return "open_paren"
	case .Close_Paren: return "close_paren"
	case .Open_Bracket: return "open_bracket"
	case .Close_Bracket: return "close_bracket"
	case .Open_Brace: return "open_brace"
	case .Close_Brace: return "close_brace"
	case .Colon: return "colon"
	case .Semicolon: return "semicolon"
	case .Period: return "period"
	case .Comma: return "comma"
	case .Range_Half: return "..<"
	case .Range_Full: return "..="
	case .Invalid: return "invalid"
	case: return ""
	}
}
