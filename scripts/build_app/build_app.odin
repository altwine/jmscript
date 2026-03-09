package build_app

import "core:slice"
import "core:path/filepath"
import "core:os"
import "core:fmt"

main :: proc() {
	build_mode := get_build_mode()

	if build_mode == .Unspecified {
		fmt.printfln("Can't build app: flag --release or --debug unspecified (-r or -d)")
		os.exit(2)
	}

	is_legacy := slice.contains(os.args, "-l") || slice.contains(os.args, "--legacy")
	microarch := "-microarch:x86-64-v2" if is_legacy else "-microarch:x86-64-v3"
	exe_name := "jmscript-win-compat.exe" if is_legacy else "jmscript-win.exe"

	exe_path, _ := filepath.abs(os.args[0], context.allocator)
	exe_dir := filepath.dir(exe_path)

	bin_dir, _ := filepath.join({exe_dir, "bin"}, context.temp_allocator)
	src_dir, _ := filepath.join({exe_dir, "src"}, context.temp_allocator)

	output_file_path, _ := filepath.join({bin_dir, exe_name}, context.temp_allocator)

	resources_dir, _ := filepath.join({exe_dir, "resources"}, context.temp_allocator)
	resources_file_path, _ := filepath.join({resources_dir, "resources.rc"}, context.temp_allocator)
	compiled_resources_file_path, _ := filepath.join({resources_dir, "resources.res"}, context.temp_allocator)

	if !os.exists(bin_dir) {
		os.make_directory(bin_dir)
	}

	build_app_cmd := make([dynamic]string, context.allocator)
	defer delete(build_app_cmd)

	append(&build_app_cmd, "odin")
	append(&build_app_cmd, "build")
	append(&build_app_cmd, src_dir)
	append(&build_app_cmd, "-build-mode:exe")
	append(&build_app_cmd, "-target:windows_amd64")
	append(&build_app_cmd, "-subsystem:console")
	append(&build_app_cmd, "-vet-shadowing")
	append(&build_app_cmd, "-vet-tabs")
	append(&build_app_cmd, "-vet-cast")
	append(&build_app_cmd, "-vet-using-stmt")
	append(&build_app_cmd, "-vet-semicolon")
	append(&build_app_cmd, "-strict-style")
	append(&build_app_cmd, "-disallow-do")
	append(&build_app_cmd, "-warnings-as-errors")
	append(&build_app_cmd, fmt.tprintf("-out:%s", output_file_path))
	append(&build_app_cmd, microarch)

	if build_mode == .Release {
		if !is_legacy {
			rc_exe := find_rc_exe()
			if rc_exe == "" {
				fmt.eprintln("Err: can't find rc.exe")
				os.exit(1)
			}
			exec_command({rc_exe, "/fo", compiled_resources_file_path, resources_file_path})
		}

		append(&build_app_cmd, "-o:speed")
		append(&build_app_cmd, "-no-bounds-check")
		append(&build_app_cmd, "-no-threaded-checker")
		append(&build_app_cmd, "-disable-assert")
		append(&build_app_cmd, "-source-code-locations:none")

		if is_legacy {
			append(&build_app_cmd, fmt.tprintf(`-resource:%s`, resources_file_path))
			append(&build_app_cmd, `-extra-linker-flags:/LTCG`)
		} else {
			append(&build_app_cmd, fmt.tprintf(`-extra-linker-flags:/LTCG %s`, compiled_resources_file_path))
		}
	}

	if build_mode == .Debug {
		append(&build_app_cmd, "-debug")
		append(&build_app_cmd, "-o:none")
		append(&build_app_cmd, "-sanitize:address")
		append(&build_app_cmd, `-extra-linker-flags:/LTCG /IGNORE:4099`)
	}

	exec_command(build_app_cmd[:])

	if os.exists(compiled_resources_file_path) {
		os.remove(compiled_resources_file_path)
	}
}
