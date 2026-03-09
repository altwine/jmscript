package parser

import "core:path/filepath"
import "core:strings"
import "core:os"

import "../ast"
import "../error"

parse_dir :: proc(ec: ^error.Collector, dir_path: string, allocator := context.allocator) -> ([dynamic]^ast.File, [dynamic]error.Error) {
	files := make([dynamic]^ast.File, allocator)
	errs := make([dynamic]error.Error, allocator)

	file_infos, err := os.read_all_directory_by_path(dir_path, context.temp_allocator)
	defer os.file_info_slice_delete(file_infos, context.temp_allocator)

	for file_info, file_info_idx in file_infos {
		if file_info.type != .Regular {
			continue
		}
		switch filepath.ext(file_info.name) {
		case ".jms", ".jmscript": // allow only these
		case: continue
		}

		p: Parser
		parser_init(&p, ec, allocator)
		file_path, _ := strings.clone(file_info.fullpath, p.alloc)
		file_node := parse_file(&p, file_path)
		append(&files, file_node)
	}

	return files, errs
}
