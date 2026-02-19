package build_debug

import "core:path/filepath"
import "core:os"
import "core:os/os2"
import "core:fmt"

main :: proc() {
	exe_path, _ := filepath.abs(os.args[0])
    exe_dir := filepath.dir(exe_path)

    bin_dir := filepath.join({exe_dir, "bin"})
    src_dir := filepath.join({exe_dir, "src"})

    if !os.exists(bin_dir) {
    	os.make_directory(bin_dir)
    }

    output_file_path := filepath.join({bin_dir, "jmscript-win.exe"})

    build_debug_cmd: []string = {
	    "odin",
	    "build",
	    src_dir,
	    "-build-mode:exe",
		"-target:windows_amd64",
		"-subsystem:console",
		"-debug",
		"-o:none",
		"-vet-shadowing",
		"-vet-tabs",
		"-vet-cast",
		"-vet-unused-imports",
		"-vet-using-stmt",
		"-vet-semicolon",
		"-strict-style",
		"-disallow-do",
		"-warnings-as-errors",
		"-linker:lld",
		"-sanitize:address",
		fmt.tprintf("-out:%s", output_file_path),
    }

	proc_state, stdout, stderr, err := os2.process_exec(
		os2.Process_Desc{command=build_debug_cmd[:]},
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
