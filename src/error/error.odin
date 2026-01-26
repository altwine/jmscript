package error

import "core:strings"
// import "core:strings"
import "core:fmt"

import "../ast"

Error_Severity :: enum {
	Error,
	Warning,
}

Error :: struct {
	file: ^ast.File,
	cause: ^ast.Node,
	message: string,
	severity: Error_Severity,
}

print :: proc(error: Error) {
	error_type: string
	switch error.severity {
	case .Error:   error_type = "Error"
	case .Warning: error_type = "Warning"
	}
	fmt.printfln("%s: %s", error_type, error.message)
	if error.file == nil || error.cause == nil {
		return
	}
	lines := strings.split_lines(error.file.src, context.temp_allocator)
	line := lines[error.cause.pos.line]
	line_trimmed := strings.trim_space(line)
	delta := len(line) - len(line_trimmed)
	line_number := fmt.tprintf("%d", error.cause.pos.line+1)
	spaces := strings.repeat(" ", error.cause.pos.column-1-delta-len(line_number)+7, context.temp_allocator)
	arrows := strings.repeat("^", error.cause.end.offset-error.cause.pos.offset+1, context.temp_allocator)
	fmt.printfln("  %s.    %s", line_number, line_trimmed)
	fmt.printfln("    %s%s", spaces, arrows)
}
