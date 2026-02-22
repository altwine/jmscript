package compiler

import "core:mem"
import "core:time"
import "core:fmt"

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

compiler_init :: proc(c: ^Compiler, warnings_as_errors: bool, allocator := context.allocator) {
	error.collector_init(&c.ec, warnings_as_errors, allocator)
	c.alloc = allocator
}

compile :: proc(c: ^Compiler, dir_path: string, minify: bool, unique_id: string) -> (string, bool) {
	total_start := time.now()

	parse_start := time.now()
	files, parser_errs := parser.parse_dir(&c.ec, dir_path, c.alloc)
	parse_time := time.duration_milliseconds(time.since(parse_start))

	error.print_all(&c.ec)
	if error.has_errors(&c.ec) {
		return "", false
	}
	error.collector_clear(&c.ec)

	check_start := time.now()
	ch: checker.Checker
	checker.checker_init(&ch, &c.ec, c.alloc)
	symbol_table := checker.checker_check(&ch, files)
	check_time := time.duration_milliseconds(time.since(check_start))

	error.print_all(&c.ec)
	if error.has_errors(&c.ec) {
		return "", false
	}
	error.collector_clear(&c.ec)

	opt_start := time.now()
	op: optimizer.Optimizer
	optimizer.optimizer_init(&op, &c.ec, c.alloc)
	optimizer.optimizer_optimize(&op, files, symbol_table)
	opt_time := time.duration_milliseconds(time.since(opt_start))

	error.print_all(&c.ec)
	if error.has_errors(&c.ec) {
		return "", false
	}
	error.collector_clear(&c.ec)

	codegen_start := time.now()
	cg: codegen.Codegen
	codegen.codegen_init(&cg, &c.ec, c.alloc)
	json_ir := codegen.codegen_gen(&cg, files, symbol_table, minify, unique_id)
	codegen_time := time.duration_milliseconds(time.since(codegen_start))

	error.print_all(&c.ec)
	if error.has_errors(&c.ec) {
		return "", false
	}
	error.collector_clear(&c.ec)

	total_time := time.duration_milliseconds(time.since(total_start))
	fmt.println("\n=== Compilation Times ===")
	fmt.println("Parse time:    ", parse_time, "ms")
	fmt.println("Check time:    ", check_time, "ms")
	fmt.println("Optimize time: ", opt_time, "ms")
	fmt.println("Codegen time:  ", codegen_time, "ms")
	fmt.println("Total time:    ", total_time, "ms")
	fmt.println("========================")

	return json_ir, true
}
