package codegen

import "core:mem"

import "../ast"
import "../checker"

BLOCKS :: 88
LINES :: 23
FLOORS :: 15

Codegen :: struct {
	alloc: mem.Allocator,
	errs: [dynamic]Codegen_Error,
	warns: [dynamic]Codegen_Warning,
}

Codegen_Error :: struct {
	message: string,
	offset_from: int,
	offset_to: int,
}

Codegen_Warning :: struct {
	message: string,
	offset_from: int,
	offset_to: int,
}

codegen_init :: proc(c: ^Codegen, allocator := context.allocator) {
	c.alloc = allocator
	c.errs = make([dynamic]Codegen_Error, allocator)
	c.warns = make([dynamic]Codegen_Warning, allocator)
}

codegen_gen :: proc(c: ^Codegen, files: [dynamic]^ast.File, symbols: ^checker.Symbol_Table, minify: bool, unique_id: string) -> (string, [dynamic]Codegen_Error, [dynamic]Codegen_Warning) {
	irb: IR_Builder
	ir_builder_init(&irb, minify, unique_id, symbols, c.alloc)
	for file in files {
		ir_builder_append_file(&irb, file)
	}
	result, irb_errors, irb_warnings := ir_build(&irb)
	for irb_error in irb_errors {
		append(&c.errs, Codegen_Error{
			message=irb_error.message,
			offset_from=irb_error.offset_from,
			offset_to=irb_error.offset_to,
		})
	}
	for irb_warning in irb_warnings {
		append(&c.warns, Codegen_Warning{
			message=irb_warning.message,
			offset_from=irb_warning.offset_from,
			offset_to=irb_warning.offset_to,
		})
	}
	return result, c.errs, c.warns
}

add_error :: proc(c: ^Codegen, message: string) {
	err := Codegen_Error{message=message}
	append(&c.errs, err)
}

add_warning :: proc(c: ^Codegen, message: string) {
	warn := Codegen_Warning{message=message}
	append(&c.warns, warn)
}
