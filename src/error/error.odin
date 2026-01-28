package error

import "core:strings"
import "core:fmt"

import "../ast"
import "../lexer"

Error_Severity :: enum {
	Error,
	Warning,
}

Error :: struct {
	file:      ^ast.File,
	cause_pos: lexer.Pos,
	cause_end: lexer.Pos,
	message:   string,
	severity:  Error_Severity,
}

print :: proc(error: Error) {
	error_type: string
	switch error.severity {
	case .Error:   error_type = "Error"
	case .Warning: error_type = "Warning"
	}
	pos_offset := error.cause_pos.offset
	end_offset := error.cause_end.offset
	if error.file == nil || pos_offset == 0 || end_offset == 0 {
		fmt.println(error.message)
		return
	}
	lines := strings.split_lines(error.file.src, context.temp_allocator)
	line := lines[error.cause_pos.line]
	line_trimmed := strings.trim_space(line)
	leading_whitespace := len(line) - len(strings.trim_left_space(line))
	cause_pos_column := error.cause_pos.column
	spaces := strings.repeat(" ", cause_pos_column - leading_whitespace - 1, context.temp_allocator)
	arrows_count := min(end_offset-pos_offset+1, len(strings.trim_space(line)))
	arrows := strings.repeat("^", arrows_count, context.temp_allocator)
	fmt.printfln("%s:%d:%d %s: %s", error.file.fullpath, error.cause_pos.line+1, cause_pos_column, error_type, error.message)
	fmt.printfln("\t%s", line_trimmed)
	fmt.printfln("\t%s%s", spaces, arrows)
}
