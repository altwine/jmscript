package run_tests

import "core:sys/windows"
import "core:strings"
import "core:path/filepath"
import "core:os"
import "core:os/os2"
import "core:fmt"

main :: proc() {
	when ODIN_OS == .Windows {
		windows.SetConsoleOutputCP(windows.CODEPAGE.UTF8)
		windows.SetConsoleCP(windows.CODEPAGE.UTF8)
	}

	exe_path, _ := filepath.abs(os.args[0])
    exe_dir := filepath.dir(exe_path)
    pdb_path := filepath.join([]string{exe_dir, "tests.pdb"})

    bin_dir := filepath.join([]string{exe_dir, "bin"})
    src_dir := filepath.join([]string{exe_dir, "src"})
    tests_dir := filepath.join([]string{exe_dir, "tests"})
    assets_dir := filepath.join([]string{exe_dir, "assets"})
    examples_dir := filepath.join([]string{exe_dir, "examples"})

    run_tests_cmd := [dynamic]string{}
    append(&run_tests_cmd, "odin")
    append(&run_tests_cmd, "test")
    append(&run_tests_cmd, tests_dir)
    append(&run_tests_cmd, strings.concatenate([]string{"-collection:src=", src_dir}))
	append(&run_tests_cmd, "-debug")
	append(&run_tests_cmd, "-sanitize:address")
	append(&run_tests_cmd, "-define:ODIN_TEST_THREADS=1")

	defer {
		if os.exists(exe_path) {
			os.remove(exe_path)
		}
		if os.exists(pdb_path) {
			os.remove(pdb_path)
		}
	}

	proc_state, stdout, stderr, err := os2.process_exec(
		os2.Process_Desc{command=run_tests_cmd[:]},
		context.allocator,
	)

	if err != nil {
		fmt.eprintln("Err: %v", err)
		os.exit(1)
	}
	if len(stderr) > 0 {
		fmt.printfln("%s", stderr)
	}
	if len(stdout) > 0 {
		fmt.printfln("%s", stdout)
	}
}
