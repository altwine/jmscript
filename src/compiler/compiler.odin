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
}

compiler_init :: proc(c: ^Compiler, allocator := context.allocator) {
	c.alloc = allocator
}

compile :: proc(c: ^Compiler, dir_path: string, minify: bool, unique_id: string) -> (string, bool) {
	has_errors := false

	files, parser_errs := parser.parse_dir(dir_path, c.alloc)
	for parser_err in parser_errs {
		has_errors ||= parser_err.severity == .Error
		error.print(parser_err)
	}
	if has_errors {
		return "", false
	}

	ch: checker.Checker
	checker.checker_init(&ch, c.alloc)
	symbol_table, checker_errs := checker.checker_check(&ch, files)
	for checker_err in checker_errs {
		has_errors ||= checker_err.severity == .Error
		error.print(checker_err)
	}
	if has_errors {
		return "", false
	}

	op: optimizer.Optimizer
	optimizer.optimizer_init(&op, c.alloc)
	optimizer_errs := optimizer.optimizer_optimize(&op, files, symbol_table)
	for optimizer_err in optimizer_errs {
		has_errors ||= optimizer_err.severity == .Error
		error.print(optimizer_err)
	}
	if has_errors {
		return "", false
	}

	cg: codegen.Codegen
	codegen.codegen_init(&cg, c.alloc)
	result, codegen_errs := codegen.codegen_gen(&cg, files, symbol_table, minify, unique_id)
	for codegen_err in codegen_errs {
		has_errors ||= codegen_err.severity == .Error
		error.print(codegen_err)
	}
	if has_errors {
		return "", false
	}

	return result, true
}
