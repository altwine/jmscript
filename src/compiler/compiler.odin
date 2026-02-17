package compiler

import "core:mem"

// import "../ast"
import "../error"
import "../parser"
import "../checker"
import "../optimizer"
import "../codegen"

Compiler :: struct {
	alloc: mem.Allocator,
	ec: error.Collector,
}

compiler_init :: proc(c: ^Compiler, allocator := context.allocator) {
	error.collector_init(&c.ec, allocator)
	c.alloc = allocator
}

compile :: proc(c: ^Compiler, dir_path: string, minify: bool, unique_id: string) -> (string, bool) {
	files, parser_errs := parser.parse_dir(&c.ec, dir_path, c.alloc)
	error.print_all(&c.ec)
	if error.has_errors(&c.ec) {
		return "", false
	}

	ch: checker.Checker
	checker.checker_init(&ch, &c.ec, c.alloc)
	symbol_table := checker.checker_check(&ch, files)
	error.print_all(&c.ec)
	if error.has_errors(&c.ec) {
		return "", false
	}

	op: optimizer.Optimizer
	optimizer.optimizer_init(&op, &c.ec, c.alloc)
	optimizer.optimizer_optimize(&op, files, symbol_table)
	error.print_all(&c.ec)
	if error.has_errors(&c.ec) {
		return "", false
	}

	cg: codegen.Codegen
	codegen.codegen_init(&cg, &c.ec, c.alloc)
	json_ir := codegen.codegen_gen(&cg, files, symbol_table, minify, unique_id)
	error.print_all(&c.ec)
	if error.has_errors(&c.ec) {
		return "", false
	}

	return json_ir, true
}
