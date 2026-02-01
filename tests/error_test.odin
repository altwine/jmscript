package tests

import "core:testing"
import "core:fmt"

import "src:ast"
import "src:lexer"
import "src:error"

@(test)
test_error_creation :: proc(t: ^testing.T) {
	context.allocator = context.temp_allocator
    pos := lexer.Pos{line = 0, column = 1, offset = 10}
    end := lexer.Pos{line = 0, column = 3, offset = 12}

    file := ast.new(ast.File, pos, end)
    file.pkg = "test"
    file.fullpath = "test.odin"
    file.src = "package test\n\nx := y + 5\n"

    err := error.Error{
        file = file,
        cause_pos = pos,
        cause_end = end,
        message = "Undefined variable 'y'",
        severity = error.Error_Severity.Error,
    }

    testing.expect(t, err.file == file, "File should match")
    testing.expect(t, err.cause_pos == pos, "Cause position should match")
    testing.expect(t, err.cause_end == end, "Cause end should match")
    testing.expect(t, err.message == "Undefined variable 'y'",
        fmt.tprintf("Expected 'Undefined variable \\'y\\'', got '%s'", err.message))
    testing.expect(t, err.severity == error.Error_Severity.Error, "Should be an error")
}

@(test)
test_warning_creation :: proc(t: ^testing.T) {
	context.allocator = context.temp_allocator
    pos := lexer.Pos{line = 1, column = 5, offset = 20}
    end := lexer.Pos{line = 1, column = 10, offset = 25}

    file := ast.new(ast.File, pos, end)
    file.pkg = "test"
    file.fullpath = "warning.odin"
    file.src = "package test\n\n// Deprecated function\nold_func :: proc() {}\n"

    warning := error.Error{
        file = file,
        cause_pos = pos,
        cause_end = end,
        message = "Function is deprecated",
        severity = error.Error_Severity.Warning,
    }

    testing.expect(t, warning.severity == error.Error_Severity.Warning, "Should be a warning")
    testing.expect(t, warning.message == "Function is deprecated", "Message should match")
}

@(test)
test_error_without_file :: proc(t: ^testing.T) {
	context.allocator = context.temp_allocator
    err := error.Error{
        file = nil,
        cause_pos = {},
        cause_end = {},
        message = "Internal compiler error",
        severity = error.Error_Severity.Error,
    }

    testing.expect(t, err.file == nil, "File should be nil")
    testing.expect(t, err.cause_pos.offset == 0, "Position offset should be 0")
    testing.expect(t, err.message == "Internal compiler error", "Message should match")
}

@(test)
test_error_with_zero_positions :: proc(t: ^testing.T) {
	context.allocator = context.temp_allocator
    file := ast.new(ast.File, {}, {})
    file.pkg = "test"
    file.fullpath = "test.odin"
    file.src = "package test\n"

    err := error.Error{
        file = file,
        cause_pos = {},
        cause_end = {},
        message = "Syntax error",
        severity = error.Error_Severity.Error,
    }

    testing.expect(t, err.cause_pos.offset == 0, "Position offset should be 0")
    testing.expect(t, err.cause_end.offset == 0, "End offset should be 0")
}

@(test)
test_error_severity_comparison :: proc(t: ^testing.T) {
	context.allocator = context.temp_allocator
    error1 := error.Error_Severity.Error
    error2 := error.Error_Severity.Error
    warning := error.Error_Severity.Warning

    testing.expect(t, error1 == error2, "Same severity should be equal")
    testing.expect(t, error1 != warning, "Different severity should not be equal")
    testing.expect(t, int(error1) < int(warning), "Error should have lower value than Warning")
}
