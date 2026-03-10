package run_tests

import "core:sys/windows"
import "core:path/filepath"
import "core:os"
import "core:fmt"

main :: proc() {
	when ODIN_OS == .Windows {
		windows.SetConsoleOutputCP(windows.CODEPAGE.UTF8)
		windows.SetConsoleCP(windows.CODEPAGE.UTF8)
	}

	exe_path, _ := filepath.abs(os.args[0], context.allocator)
	exe_dir := filepath.dir(exe_path)
	pdb_path, _ := filepath.join([]string{exe_dir, "tests.pdb"}, context.allocator)

	bin_dir, _ := filepath.join([]string{exe_dir, "bin"}, context.allocator)
	src_dir, _ := filepath.join([]string{exe_dir, "src"}, context.allocator)
	tests_dir, _ := filepath.join([]string{exe_dir, "tests"}, context.allocator)
	assets_dir, _ := filepath.join([]string{exe_dir, "assets"}, context.allocator)
	examples_dir, _ := filepath.join([]string{exe_dir, "examples"}, context.allocator)

	run_tests_cmd := [dynamic]string{}
	append(&run_tests_cmd, "odin")
	append(&run_tests_cmd, "test")
	append(&run_tests_cmd, tests_dir)
	append(&run_tests_cmd, fmt.tprintf("-collection:src=%s", src_dir))
	append(&run_tests_cmd, "-vet-shadowing")
	append(&run_tests_cmd, "-vet-tabs")
	append(&run_tests_cmd, "-vet-cast")
	append(&run_tests_cmd, "-vet-unused-imports")
	append(&run_tests_cmd, "-vet-using-stmt")
	append(&run_tests_cmd, "-vet-semicolon")
	append(&run_tests_cmd, "-strict-style")
	append(&run_tests_cmd, "-disallow-do")
	append(&run_tests_cmd, "-warnings-as-errors")
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

	_, stdout, stderr, err := os.process_exec(
		os.Process_Desc{command=run_tests_cmd[:]},
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
