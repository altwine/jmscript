package codegen

import "core:mem"

import "../ast"
import "../checker"

BLOCKS :: 88
LINES :: 23
FLOORS :: 15

Codegen :: struct {
	alloc: mem.Allocator,
	errs: [dynamic]^Codegen_Error,
}

Codegen_Error :: struct {

}

codegen_init :: proc(c: ^Codegen, allocator := context.allocator) {
	c.alloc = allocator
}

codegen_gen :: proc(c: ^Codegen, files: [dynamic]^ast.File, symbols: ^checker.Symbol_Table, minify: bool, unique_id: string) -> string {
	irb: IR_Builder
	ir_builder_init(&irb, minify, unique_id, symbols, c.alloc)
	for file in files {
		ir_builder_append_file(&irb, file)
	}
	result := ir_build(&irb)
	return result
}
