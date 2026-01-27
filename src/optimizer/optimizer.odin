package optimizer

import "core:mem"

import "../ast"
import "../checker"
import "../error"

Optimizer :: struct {
	alloc: mem.Allocator,
	files: [dynamic]^ast.File,
	symbols: ^checker.Symbol_Table,
	current_file: ^ast.File,
	pass: int,
	errs: [dynamic]error.Error,
}

optimizer_init :: proc(o: ^Optimizer, allocator := context.allocator) {
	o.alloc = allocator
	o.errs = make([dynamic]error.Error, o.alloc)
}

optimizer_optimize :: proc(o: ^Optimizer, files: [dynamic]^ast.File, symbols: ^checker.Symbol_Table) -> [dynamic]error.Error {
	o.files = files
	o.symbols = symbols
	o.pass += 1

	for file in files {
		// TODO
	}

	return o.errs
}
