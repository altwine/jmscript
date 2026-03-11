package ir

import "core:strings"
import "core:mem"

Json_Builder :: struct {
	builder: strings.Builder,
	indent_level: int,
	minified: bool,
	alloc: mem.Allocator,
}

json_builder_init :: proc(jb: ^Json_Builder, minified := false, alloc := context.allocator) {
	strings.builder_init(&jb.builder, alloc)
	jb.alloc = alloc
	jb.indent_level = 0
	jb.minified = minified
}

json_builder_destroy :: proc(jb: ^Json_Builder) {
	strings.builder_destroy(&jb.builder)
}

json_write_indent :: proc(jb: ^Json_Builder) {
	if !jb.minified {
		for i in 0..<jb.indent_level {
			strings.write_string(&jb.builder, "    ")
		}
	}
}

json_write_newline :: proc(jb: ^Json_Builder) {
	if !jb.minified {
		strings.write_string(&jb.builder, "\n")
	}
}

json_write_quote :: proc(jb: ^Json_Builder) {
	strings.write_string(&jb.builder, "\"")
}

json_write_colon :: proc(jb: ^Json_Builder) {
	if jb.minified {
		strings.write_string(&jb.builder, ":")
	} else {
		strings.write_string(&jb.builder, ": ")
	}
}

json_begin_object :: proc(jb: ^Json_Builder, key := "") {
	json_write_indent(jb)
	if key != "" {
		json_write_quote(jb)
		strings.write_string(&jb.builder, key)
		json_write_quote(jb)
		json_write_colon(jb)
	}
	strings.write_string(&jb.builder, "{")
	json_write_newline(jb)
	jb.indent_level += 1
}

json_end_object :: proc(jb: ^Json_Builder, comma: bool) {
	jb.indent_level -= 1
	json_write_indent(jb)
	strings.write_string(&jb.builder, "}")
	if comma {
		strings.write_string(&jb.builder, ",")
	}
	json_write_newline(jb)
}

json_begin_array :: proc(jb: ^Json_Builder, key := "") {
	json_write_indent(jb)
	if key != "" {
		json_write_quote(jb)
		strings.write_string(&jb.builder, key)
		json_write_quote(jb)
		json_write_colon(jb)
	}
	strings.write_string(&jb.builder, "[")
	json_write_newline(jb)
	jb.indent_level += 1
}

json_end_array :: proc(jb: ^Json_Builder, comma: bool) {
	jb.indent_level -= 1
	json_write_indent(jb)
	strings.write_string(&jb.builder, "]")
	if comma {
		strings.write_string(&jb.builder, ",")
	}
	json_write_newline(jb)
}

json_write_string :: proc(jb: ^Json_Builder, key: string, value: string, comma: bool) {
	json_write_indent(jb)
	json_write_quote(jb)
	strings.write_string(&jb.builder, key)
	json_write_quote(jb)
	json_write_colon(jb)
	json_write_quote(jb)
	strings.write_string(&jb.builder, value)
	json_write_quote(jb)
	if comma {
		strings.write_string(&jb.builder, ",")
	}
	json_write_newline(jb)
}

json_write_string_unquoted :: proc(jb: ^Json_Builder, key: string, value: string, comma: bool) {
	json_write_indent(jb)
	json_write_quote(jb)
	strings.write_string(&jb.builder, key)
	json_write_quote(jb)
	json_write_colon(jb)
	strings.write_string(&jb.builder, value)
	if comma {
		strings.write_string(&jb.builder, ",")
	}
	json_write_newline(jb)
}

json_write_boolean :: proc(jb: ^Json_Builder, key: string, value: bool, comma: bool) {
	json_write_indent(jb)
	json_write_quote(jb)
	strings.write_string(&jb.builder, key)
	json_write_quote(jb)
	json_write_colon(jb)
	if value {
		strings.write_string(&jb.builder, "true")
	} else {
		strings.write_string(&jb.builder, "false")
	}
	if comma {
		strings.write_string(&jb.builder, ",")
	}
	json_write_newline(jb)
}

json_write_number :: proc(jb: ^Json_Builder, key: string, value: union{ int, f64 }, comma: bool) {
	json_write_indent(jb)
	json_write_quote(jb)
	strings.write_string(&jb.builder, key)
	json_write_quote(jb)
	json_write_colon(jb)
	switch v in value {
	case int:
		strings.write_int(&jb.builder, value.(int))
	case f64:
		strings.write_f64(&jb.builder, value.(f64), 'g')
	}
	if comma {
		strings.write_string(&jb.builder, ",")
	}
	json_write_newline(jb)
}
