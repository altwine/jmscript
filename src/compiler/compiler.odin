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

Compiler_Error :: struct {
	message: string,
	offset_from: int,
	offset_to: int,
}

Compiler_Warning :: struct {
	message: string,
	offset_from: int,
	offset_to: int,
}

compiler_init :: proc(c: ^Compiler, allocator := context.allocator) {
	c.alloc = allocator
}

compile :: proc(c: ^Compiler, dir_path: string, minify: bool, unique_id: string) -> (string, bool) {
	files, parser_errs, parser_warns := parser.parse_dir(dir_path, c.alloc)
	if len(parser_warns) > 0 {
		for parser_warn in parser_warns {
			fmt.printfln("Warning in parser: %s", parser_warn.message)
		}
	}
	if len(parser_errs) > 0 {
		for parser_err in parser_errs {
			fmt.printfln("Error in parser: %s", parser_err.message)
		}
		return "", false
	}

	ch: checker.Checker
	checker.checker_init(&ch, c.alloc)
	symbol_table, checker_errs, checker_warns := checker.checker_check(&ch, files)
	if len(checker_warns) > 0 {
		for checker_warn in checker_warns {
			fmt.printfln("Warning in checker: %s", checker_warn.message)
		}
	}
	if len(checker_errs) > 0 {
		for checker_err in checker_errs {
			fmt.printfln("Error in checker: %s", checker_err.message)
		}
		return "", false
	}

	cg: codegen.Codegen
	codegen.codegen_init(&cg, c.alloc)
	result, codegen_errs, codegen_warns := codegen.codegen_gen(&cg, files, symbol_table, minify, unique_id)
	if len(codegen_warns) > 0 {
		for codegen_warn in codegen_warns {
			fmt.printfln("Warning in codegen: %s", codegen_warn.message)
		}
	}
	if len(codegen_errs) > 0 {
		for codegen_err in codegen_errs {
			fmt.printfln("Error in codegen: %s", codegen_err.message)
		}
		return "", false
	}

	return result, true
}
