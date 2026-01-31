package ast

import "core:sync"
import "core:mem"
import "core:fmt"
import "core:strings"

import "../lexer"

Node :: struct {
	pos:     lexer.Pos,
	end:     lexer.Pos,
	derived: Any_Node,
	id:      int,
}

File :: struct {
	using node: Node,
	alloc:    mem.Allocator,
	pkg:      string,
	fullpath: string,
	src:      string,
	tags:     [dynamic]string,
	decls:    [dynamic]^Stmt,
}

Expr :: struct {
	using expr_base: Node,
}

Annotation :: struct {
	using anno_base: Node,
	name: string,
	value: ^Expr, // may be nil
}

Stmt :: struct {
	using stmt_base: Node,
	annotations:     [dynamic]Annotation,
}

Decl :: struct {
	using decl_base: Stmt,
}

Ident :: struct {
	using node: Expr,
	name: string,
}

Basic_Lit :: struct {
	using node: Expr,
	tok: lexer.Token,
}

Func_Stmt :: struct {
	using node: Stmt,
	name:   string,
	params: ^Param_List,
	result: string,
	body:   ^Block_Stmt,
}

Event_Stmt :: struct {
	using node: Stmt,
	name:   string,
	params: ^Param_List,
	body:   ^Block_Stmt,
}

Unary_Expr :: struct {
	using node: Expr,
	op:   lexer.Token,
	expr: ^Expr,
}

Binary_Expr :: struct {
	using node: Expr,
	left:  ^Expr,
	op:    lexer.Token,
	right: ^Expr,
}

Paren_Expr :: struct {
	using node: Expr,
	open:  lexer.Pos,
	expr:  ^Expr,
	close: lexer.Pos,
}

Member_Access_Expr :: struct {
	using node: Expr,
	expr:  ^Expr,
	op:    lexer.Token,
	field: ^Ident,
}

Call_Expr :: struct {
	using node: Expr,
	expr:     ^Expr,
	args:     []^Argument,
	ellipsis: lexer.Token,
}

Argument :: struct {
	using node: Expr,
	name:  string,
	value: ^Expr,
}

Field_Value :: struct {
	using node: Expr,
	field: ^Expr,
	sep:   lexer.Pos,
	value: ^Expr,
}

Expr_Stmt :: struct {
	using node: Stmt,
	expr: ^Expr,
}

Assign_Stmt :: struct {
	using node: Stmt,
	name:    string,
	op:     lexer.Token,
	expr:    ^Expr,
}

Block_Stmt :: struct {
	using node: Stmt,
	stmts: []^Stmt,
}

If_Stmt :: struct {
	using node: Stmt,
	init:      ^Stmt,
	cond:      ^Expr,
	body:      ^Block_Stmt,
	else_stmt: ^Block_Stmt,
}

Return_Stmt :: struct {
	using node: Stmt,
	result: ^Expr,
}

Defer_Stmt :: struct {
	using node: Stmt,
	stmt: ^Stmt,
}

For_Stmt :: struct {
	using node: Stmt,
	for_pos:     lexer.Pos,
	init:        []^Ident,
	cond:        ^Expr,
	post:        ^Stmt,
	body:        ^Block_Stmt,
	range_tok:   lexer.Token,
	second_cond: ^Expr,
}

Value_Decl :: struct {
	using node: Decl,
	name:     string,
	type:     string,
	value:    ^Expr,
	is_const: bool,
}

Field_Access :: struct {
	using base: Expr,
	expr:  ^Expr,
	field: string,
}

Index_Expr :: struct {
	using base: Expr,
	expr:  ^Expr,
	index: ^Expr,
}

Param :: struct {
	using node: Node,
	name: string,
	type: string,
}

Param_List :: struct {
	using node: Node,
	list: []^Param,
}

Any_Node :: union {
	^File,

	^Ident,
	^Basic_Lit,
	^Func_Stmt,
	^Event_Stmt,
	^Unary_Expr,
	^Binary_Expr,
	^Paren_Expr,
	^Member_Access_Expr,
	^Index_Expr,
	^Call_Expr,
	^Field_Value,

	^Annotation,
	^Expr_Stmt,
	^Assign_Stmt,
	^Block_Stmt,
	^If_Stmt,
	^Return_Stmt,
	^Defer_Stmt,
	^For_Stmt,

	^Value_Decl,

	^Field_Access,
	^Param,
	^Param_List,
	^Argument,
}

Any_Expr :: union {
	^Ident,
	^Basic_Lit,
	^Unary_Expr,
	^Binary_Expr,
	^Paren_Expr,
	^Member_Access_Expr,
	^Index_Expr,
	^Call_Expr,
	^Field_Value,
}

Any_Stmt :: union {
	^Expr_Stmt,
	^Func_Stmt,
	^Event_Stmt,
	^Assign_Stmt,
	^Block_Stmt,
	^If_Stmt,
	^Return_Stmt,
	^Defer_Stmt,
	^For_Stmt,

	^Value_Decl,
}

node_id := 0
new :: proc($T: typeid, pos, end: lexer.Pos, allocator := context.allocator) -> ^T {
	n, err := mem.new(T, allocator)
	assert(n != nil, "new ast node is nil")
	n.pos = pos
	n.end = end
	n.derived = n
	n.id = sync.atomic_add(&node_id, 1)
	return n
}

print_tree :: proc(node: ^Node, indent := 0) {
	if node == nil {
		print_indent(indent-1)
		fmt.println("nil")
		return
	}

	for _ in 0..<indent {
		fmt.print("  ")
	}

	switch n in node.derived {
	case ^File:
		fmt.printfln("File (pkg: '%s', path: '%s')", n.pkg, n.fullpath)
		for decl in n.decls {
			print_tree(decl, indent + 1)
		}

	case ^Field_Access:
		fmt.println("Field_Access")
	case ^Argument:
		fmt.println("Positional_Arg '%s':", n.name)
		print_inline_expr(n.value)
	case ^Ident:
		fmt.printfln("Ident('%s')", n.name)
	case ^Basic_Lit:
		fmt.printfln("Basic_Lit(%s)", n.tok.content)

	case ^Func_Stmt:
		fmt.printfln("Func_Stmt('%s' -> '%s')", n.name, n.result)
		if len(n.annotations) > 0 {
			fmt.println("Annotations:")
			print_annotations(n, indent + 1)
		}
		if n.params != nil {
			print_tree(n.params, indent + 1)
		}
		if n.body != nil {
			print_tree(n.body, indent + 1)
		}

	case ^Event_Stmt:
		fmt.printfln("Event_Stmt('%s')", n.name)
		if len(n.annotations) > 0 {
			fmt.println("Annotations:")
			print_annotations(n, indent + 1)
		}
		if n.params != nil {
			print_tree(n.params, indent + 1)
		}
		if n.body != nil {
			print_tree(n.body, indent + 1)
		}

	case ^Unary_Expr:
		fmt.printf("Unary_Expr(%s ", n.op.content)
		print_inline_expr(n.expr)
		fmt.println(")")

	case ^Binary_Expr:
		fmt.printf("Binary_Expr(%s ", n.op.content)
		print_inline_expr(n.left)
		fmt.print(" ")
		print_inline_expr(n.right)
		fmt.println(")")

	case ^Paren_Expr:
		print_inline_expr(n.expr)

	case ^Member_Access_Expr:
		fmt.println("Member_Access_Expr\nexpr:")
		print_tree(n.expr, indent + 1)
		fmt.println("field:")
		print_tree(n.field, indent + 1)

	case ^Index_Expr:
		fmt.print("Index_Expr(")
		print_inline_expr(n.expr)
		fmt.print("[")
		print_inline_expr(n.index)
		fmt.println("])")

	case ^Call_Expr:
		fmt.print("Call_Expr(")
		print_inline_expr(n.expr)
		for arg, i in n.args {
			fmt.print("(")
			if i > 0 {
				fmt.print(", ")
			}
			print_inline_expr(arg)
		}
		fmt.println("))")

	case ^Field_Value:
		fmt.print("Field_Value(")
		print_inline_expr(n.field)
		fmt.print(": ")
		print_inline_expr(n.value)
		fmt.println(")")

	case ^Expr_Stmt:
		fmt.print("Expr_Stmt(")
		print_inline_expr(n.expr)
		fmt.println(")")
		if len(n.annotations) > 0 {
			fmt.println("Annotations:")
			print_annotations(n, indent + 1)
		}

	case ^Assign_Stmt:
		fmt.printf("Assign_Stmt(name: '%s', '%s', expr: ", n.name, n.op.content)
		if len(n.annotations) > 0 {
			fmt.println("Annotations:")
			print_annotations(n, indent + 1)
		}
		print_inline_expr(n.expr)
		fmt.println(")")

	case ^Block_Stmt:
		fmt.println("Block_Stmt")
		if len(n.annotations) > 0 {
			fmt.println("Annotations:")
			print_annotations(n, indent + 1)
		}
		if len(n.stmts) > 0 {
			print_indent(indent)
			fmt.println("stmts:")
			for stmt in n.stmts {
				print_tree(stmt, indent + 2)
			}
		}

	case ^If_Stmt:
		fmt.println("If_Stmt")
		if len(n.annotations) > 0 {
			fmt.println("Annotations:")
			print_annotations(n, indent + 1)
		}
		if n.init != nil {
			print_indent(indent)
			fmt.println("init:")
			print_tree(n.init, indent + 2)
		}
		if n.cond != nil {
			print_indent(indent)
			fmt.print("cond: ")
			print_inline_expr(n.cond)
			fmt.println("")
		}
		if n.body != nil {
			print_indent(indent)
			fmt.println("body:")
			print_tree(n.body, indent + 2)
		}
		if n.else_stmt != nil {
			print_indent(indent)
			fmt.println("else:")
			print_tree(n.else_stmt, indent + 2)
		}

	case ^Return_Stmt:
		fmt.print("Return_Stmt(")
		print_inline_expr(n.result)
		fmt.println(")")

	case ^Defer_Stmt:
		fmt.println("Defer_Stmt(")
		print_tree(n.stmt, 1)
		fmt.println(")")

	case ^For_Stmt:
		fmt.println("For_Stmt")
		if len(n.annotations) > 0 {
			fmt.println("Annotations:")
			print_annotations(n, indent + 1)
		}
		if n.init != nil {
			print_indent(indent)
			fmt.println("inits:")
			for init in n.init {
				print_tree(init, indent + 2)
			}
		}
		if n.cond != nil {
			print_indent(indent)
			fmt.print("1cond: ")
			print_inline_expr(n.cond)
			fmt.println("")
		}
		if n.range_tok.kind != .Invalid {
			print_indent(indent)
			fmt.printfln("range_type: %s", n.range_tok.content)
		}
		if n.second_cond != nil {
			print_indent(indent)
			fmt.print("2cond: ")
			print_inline_expr(n.second_cond)
			fmt.println("")
		}
		if n.body != nil {
			print_indent(indent)
			fmt.println("body:")
			print_tree(n.body, indent + 2)
		}

	case ^Value_Decl:
		fmt.printf("Value_Decl(name: '%s', type: '%s', const: %v) = ", n.name, n.type, n.is_const)
		print_inline_expr(n.value)
		if len(n.annotations) > 0 {
			fmt.println("\nAnnotations:")
			print_annotations(n, indent + 1)
		}
		fmt.println("")

	case ^Param:
		fmt.printfln("Param(name: '%s', type: '%s')", n.name, n.type)

	case ^Param_List:
		fmt.print("Param_List(")
		for param, i in n.list {
			if i > 0 {
				fmt.print(", ")
			}
			fmt.printf("%s: %s", param.name, param.type)
		}
		fmt.println(")")

	case ^Annotation:
	}
}

print_annotations :: proc(stmt: ^Stmt, indent: int) {
	for anno in stmt.annotations {
		print_indent(indent)
		fmt.printf("Annotation(name: '%s', value: ", anno.name)
		print_inline_expr(anno.value)
		fmt.println(")")
	}
}

print_inline_expr :: proc(expr: ^Expr) {
	if expr == nil {
		fmt.print("nil")
		return
	}

	#partial switch n in expr.derived {
	case ^Ident:
		fmt.print(n.name)
	case ^Basic_Lit:
		fmt.print(n.tok.content)
	case ^Field_Access:
		print_inline_expr(n.expr)
		fmt.printf(".%s", n.field)
	case ^Unary_Expr:
		fmt.print("(")
		fmt.print(n.op.content)
		print_inline_expr(n.expr)
		fmt.print(")")
	case ^Binary_Expr:
		fmt.print("(")
		print_inline_expr(n.left)
		fmt.printf(" %s ", n.op.content)
		print_inline_expr(n.right)
		fmt.print(")")
	case ^Paren_Expr:
		print_inline_expr(n.expr)
	case ^Index_Expr:
		print_inline_expr(n.expr)
		fmt.print("[")
		print_inline_expr(n.index)
		fmt.print("]")
	case ^Call_Expr:
		print_inline_expr(n.expr)
		fmt.print("(")
		for arg, i in n.args {
			if i > 0 {
				fmt.print(", ")
			}
			print_inline_expr(arg)
		}
		fmt.print(")")
	case ^Field_Value:
		fmt.print("(")
		print_inline_expr(n.field)
		fmt.print(": ")
		print_inline_expr(n.value)
		fmt.print(")")
	}
}

print_inline_expr_to_builder :: proc(sb: ^strings.Builder, expr: ^Expr) {
	if expr == nil {
		strings.write_string(sb, "nil")
		return
	}

	#partial switch n in expr.derived {
	case ^Ident:
		strings.write_string(sb, n.name)
	case ^Basic_Lit:
		strings.write_string(sb, n.tok.content)
	case ^Field_Access:
		print_inline_expr_to_builder(sb, n.expr)
		strings.write_rune(sb, '.')
		strings.write_string(sb, n.field)
	case ^Unary_Expr:
		strings.write_rune(sb, '(')
		strings.write_string(sb, n.op.content)
		print_inline_expr_to_builder(sb, n.expr)
		strings.write_rune(sb, ')')
	case ^Binary_Expr:
		strings.write_rune(sb, '(')
		print_inline_expr_to_builder(sb, n.left)
		strings.write_rune(sb, ' ')
		strings.write_string(sb, n.op.content)
		strings.write_rune(sb, ' ')
		print_inline_expr_to_builder(sb, n.right)
		strings.write_rune(sb, ')')
	case ^Paren_Expr:
		print_inline_expr_to_builder(sb, n.expr)
	case ^Index_Expr:
		print_inline_expr_to_builder(sb, n.expr)
		strings.write_rune(sb, '[')
		print_inline_expr_to_builder(sb, n.index)
		strings.write_rune(sb, ']')
	case ^Call_Expr:
		print_inline_expr_to_builder(sb, n.expr)
		strings.write_rune(sb, '(')
		for arg, i in n.args {
			if i > 0 {
				strings.write_string(sb, ", ")
			}

			#partial switch a in arg.derived {
			case ^Argument:
				if a.name != "" {
					strings.write_string(sb, a.name)
					strings.write_string(sb, ": ")
				}
				print_inline_expr_to_builder(sb, a.value)
			case:
				print_inline_expr_to_builder(sb, arg)
			}
		}
		strings.write_rune(sb, ')')
	case ^Field_Value:
		strings.write_rune(sb, '(')
		print_inline_expr_to_builder(sb, n.field)
		strings.write_string(sb, ": ")
		print_inline_expr_to_builder(sb, n.value)
		strings.write_rune(sb, ')')
	case ^Member_Access_Expr:
		print_inline_expr_to_builder(sb, n.expr)
		strings.write_rune(sb, '.')
		print_inline_expr_to_builder(sb, n.field)
	}
}

expr_to_string :: proc(expr: ^Expr, allocator := context.allocator) -> string {
	sb: strings.Builder
	strings.builder_init(&sb, 0, 64, allocator)
	defer strings.builder_destroy(&sb)

	print_inline_expr_to_builder(&sb, expr)
	return strings.to_string(sb)
}

print_indent :: proc(indent: int) {
	for _ in 0..=indent {
		fmt.print("  ")
	}
}
