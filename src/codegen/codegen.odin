package codegen

import "core:mem"

import "../ast"
import "../checker"
import "../error"

BLOCKS :: 88
LINES :: 23
FLOORS :: 15

Codegen :: struct {
	alloc: mem.Allocator,
	errs: [dynamic]error.Error,
}

codegen_init :: proc(c: ^Codegen, allocator := context.allocator) {
	c.alloc = allocator
	c.errs = make([dynamic]error.Error, allocator)
}

codegen_gen :: proc(c: ^Codegen, files: [dynamic]^ast.File, symbols: ^checker.Symbol_Table, minify: bool, unique_id: string) -> (string, [dynamic]error.Error) {
	irb: IR_Builder
	ir_builder_init(&irb, minify, unique_id, symbols, c.alloc)
	for file in files {
		ir_builder_append_file(&irb, file)
	}
	result, irb_errors := ir_build(&irb)
	return result,irb_errors
}

add_error :: proc(c: ^Codegen, message: string, file: ^ast.File) {
	err := error.Error{file=file, message=message}
	append(&c.errs, err)
}

add_warning :: proc(c: ^Codegen, message: string, file: ^ast.File) {
	warn := error.Error{file=file, message=message, severity=.Warning}
	append(&c.errs, warn)
}
