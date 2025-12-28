package build_debug

import "core:strings"
import "core:path/filepath"
import "core:os"
import "core:os/os2"
import "core:fmt"

main :: proc() {
	exe_path, _ := filepath.abs(os.args[0])
    exe_dir := filepath.dir(exe_path)

    bin_dir := filepath.join([]string{exe_dir, "bin"})
    src_dir := filepath.join([]string{exe_dir, "src"})
    assets_dir := filepath.join([]string{exe_dir, "assets"})
    examples_dir := filepath.join([]string{exe_dir, "examples"})

    if !os.exists(bin_dir) {
    	os.make_directory(bin_dir)
    }

    output_file_path := filepath.join([]string{bin_dir, "jmscript-win.exe"})

    build_debug_cmd := [dynamic]string{}
    append(&build_debug_cmd, "odin")
    append(&build_debug_cmd, "build")
    append(&build_debug_cmd, src_dir)
    append(&build_debug_cmd, "-build-mode:exe")
	append(&build_debug_cmd, "-target:windows_amd64")
	append(&build_debug_cmd, "-extra-linker-flags:/LTCG")
	append(&build_debug_cmd, "-subsystem:console")
	append(&build_debug_cmd, "-debug")
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
	append(&build_debug_cmd, strings.concatenate([]string{"-out:", output_file_path}))

	proc_state, stdout, stderr, err := os2.process_exec(
		os2.Process_Desc{command=build_debug_cmd[:]},
		context.allocator,
	)
	if err != nil {
		fmt.printfln("Err: %v", err)
		return
	}
	fmt.printf("%s", stdout)
	fmt.printf("%s", stderr)
}
