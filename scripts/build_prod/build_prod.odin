package build_prod

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

    build_prod_cmd := [dynamic]string{}
    append(&build_prod_cmd, "odin")
    append(&build_prod_cmd, "build")
    append(&build_prod_cmd, src_dir)
    append(&build_prod_cmd, "-build-mode:exe")
	append(&build_prod_cmd, "-target:windows_amd64")
	append(&build_prod_cmd, "-extra-linker-flags:/LTCG")
	append(&build_prod_cmd, "-subsystem:console")
	append(&build_prod_cmd, "-o:speed")
	append(&build_prod_cmd, "-no-bounds-check")
	append(&build_prod_cmd, "-no-threaded-checker")
	append(&build_prod_cmd, "-disable-assert")
	append(&build_prod_cmd, "-source-code-locations:none")
	append(&build_prod_cmd, "-vet-shadowing")
	append(&build_prod_cmd, "-vet-tabs")
	append(&build_prod_cmd, "-vet-cast")
	append(&build_prod_cmd, "-vet-using-stmt")
	append(&build_prod_cmd, "-vet-semicolon")
	append(&build_prod_cmd, "-strict-style")
	append(&build_prod_cmd, "-disallow-do")
	append(&build_prod_cmd, "-warnings-as-errors")
	append(&build_prod_cmd, strings.concatenate([]string{"-out:", output_file_path}))

	proc_state, stdout, stderr, err := os2.process_exec(
		os2.Process_Desc{command=build_prod_cmd[:]},
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
