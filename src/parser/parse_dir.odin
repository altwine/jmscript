package parser

import "core:strings"
import "core:os/os2"

import "../ast"

parse_dir :: proc(dir_path: string, allocator := context.allocator) -> ([dynamic]^ast.File, [dynamic]Parse_Error, [dynamic]Parse_Warning) {
	files := make([dynamic]^ast.File, allocator)
	errs := make([dynamic]Parse_Error, allocator)
	warns := make([dynamic]Parse_Warning, allocator)

	file_infos, err := os2.read_all_directory_by_path(dir_path, context.temp_allocator)
	defer os2.file_info_slice_delete(file_infos, context.temp_allocator)

	for file_info, file_info_idx in file_infos {
		if file_info.type != .Regular {
			continue
		}
		p: Parser
		parser_init(&p, allocator)
		file_path, _ := strings.clone(file_info.fullpath, p.alloc)
		file_node, file_errs, file_warns := parse_file(&p, file_path, len(files))
		for err in file_errs {
			append(&errs, err)
		}
		for warn in file_warns {
			append(&warns, warn)
		}
		append(&files, file_node)
	}

	return files, errs, warns
}
