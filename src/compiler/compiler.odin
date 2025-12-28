package compiler

import "core:mem"
import "core:fmt"

// import "../ast"
import "../parser"
import "../checker"
import "../codegen"

Compiler :: struct {
	alloc: mem.Allocator,
}

compiler_init :: proc(c: ^Compiler, allocator := context.allocator) {
	c.alloc = allocator
}

compile :: proc(c: ^Compiler, dir_path: string, minify: bool, unique_id: string) -> string {
	files := parser.parse_dir(dir_path, c.alloc)

	// for f in files {
		// ast.print_tree(f)
	// }

	ch: checker.Checker
	checker.checker_init(&ch, c.alloc)
	symbol_table, errs := checker.checker_check(&ch, files)
	if len(errs) > 0 {
		for err in errs {
			fmt.printfln("Error in checker: %s", err.message)
		}
		return "error"
	}

	cg: codegen.Codegen
	codegen.codegen_init(&cg, c.alloc)
	result := codegen.codegen_gen(&cg, files, &symbol_table, minify, unique_id)

	return result
}
