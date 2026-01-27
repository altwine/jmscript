package error

import "core:strings"
import "core:fmt"

import "../ast"

Error_Severity :: enum {
	Error,
	Warning,
}

Error :: struct {
	file:     ^ast.File,
	cause:    ^ast.Node,
	message:  string,
	severity: Error_Severity,
}

print :: proc(error: Error) {
	error_type: string
	switch error.severity {
	case .Error:   error_type = "Error"
	case .Warning: error_type = "Warning"
	}
	if error.file == nil || error.cause == nil {
		fmt.println(error.message)
		return
	}
	cause_pos :=  error.cause.pos
	lines := strings.split_lines(error.file.src, context.temp_allocator)
	line := lines[cause_pos.line]
	line_trimmed := strings.trim_space(line)
	leading_whitespace := len(line) - len(strings.trim_left_space(line))
	spaces := strings.repeat(" ", cause_pos.column - leading_whitespace - 1, context.temp_allocator)
	arrows := strings.repeat("^", error.cause.end.offset-cause_pos.offset+1, context.temp_allocator)
	fmt.printfln("%s:%d:%d %s: %s", error.file.fullpath, cause_pos.line+1, cause_pos.column, error_type, error.message)
	fmt.printfln("\t%s", line_trimmed)
	fmt.printfln("\t%s%s", spaces, arrows)
}
