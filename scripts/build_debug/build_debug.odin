package build_debug

import "core:slice"
import "core:path/filepath"
import "core:os"
import "core:fmt"

main :: proc() {
	is_legacy := slice.contains(os.args, "-l") || slice.contains(os.args, "--legacy")

	exe_path, _ := filepath.abs(os.args[0], context.temp_allocator)
    exe_dir := filepath.dir(exe_path)

    bin_dir, _ := filepath.join({exe_dir, "bin"}, context.temp_allocator)
    src_dir, _ := filepath.join({exe_dir, "src"}, context.temp_allocator)

    if !os.exists(bin_dir) {
    	os.make_directory(bin_dir)
    }

    output_file_path, _ := filepath.join({bin_dir, "jmscript-win.exe" if !is_legacy else "jmscript-win-compat.exe"}, context.temp_allocator)

    build_debug_cmd := make([dynamic]string, context.allocator)
    defer delete(build_debug_cmd)
	append(&build_debug_cmd, "odin")
	append(&build_debug_cmd, "build")
	append(&build_debug_cmd, src_dir)
	append(&build_debug_cmd, "-build-mode:exe")
	append(&build_debug_cmd, "-target:windows_amd64")
	append(&build_debug_cmd, "-subsystem:console")
	append(&build_debug_cmd, "-debug")
	append(&build_debug_cmd, "-o:none")
	append(&build_debug_cmd, "-vet-shadowing")
	append(&build_debug_cmd, "-vet-tabs")
	append(&build_debug_cmd, "-vet-cast")
	append(&build_debug_cmd, "-vet-unused-imports")
	append(&build_debug_cmd, "-vet-using-stmt")
	append(&build_debug_cmd, "-vet-semicolon")
	append(&build_debug_cmd, "-strict-style")
	append(&build_debug_cmd, "-disallow-do")
	append(&build_debug_cmd, "-warnings-as-errors")
	append(&build_debug_cmd, "-sanitize:address")
	append(&build_debug_cmd, `-extra-linker-flags:/LTCG /IGNORE:4099`)
	append(&build_debug_cmd, fmt.tprintf("-out:%s", output_file_path))

	if is_legacy {
		append(&build_debug_cmd, "-microarch:x86-64-v2")
	} else {
		append(&build_debug_cmd, "-microarch:x86-64-v3")
	}

	proc_state, stdout, stderr, err := os.process_exec(
		os.Process_Desc{command=build_debug_cmd[:]},
		context.allocator,
	)
	if err != nil {
		fmt.eprintln("Err: %v", err)
		os.exit(1)
	}
	if len(stderr) > 0 {
		fmt.eprintfln("%s", stderr)
		os.exit(1)
	}
	fmt.printfln("%s", stdout)
}
