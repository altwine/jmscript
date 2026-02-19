package build_prod

import "core:path/filepath"
import "core:os"
import "core:os/os2"
import "core:fmt"
import "core:strings"
import "core:slice"

main :: proc() {
	exe_path, _ := filepath.abs(os.args[0])
    exe_dir := filepath.dir(exe_path)

    bin_dir := filepath.join({exe_dir, "bin"})
    src_dir := filepath.join({exe_dir, "src"})
    resources_dir := filepath.join({exe_dir, "resources"})

    resources_file_path := filepath.join({resources_dir, "resources.rc"})
    compiled_resources_file_path := filepath.join({resources_dir, "resources.res"})

    bases := []string{
        `C:\Program Files (x86)\Windows Kits\10\bin`,
        `C:\Program Files\Windows Kits\10\bin`,
    }

    rc_exe := ""

    for base in bases {
        if !os.exists(base) {
        	continue
        }
        entries, _ := os2.read_all_directory_by_path(base, context.allocator)
        versions := make([dynamic]string)
        for entry in entries {
            if entry.type == .Directory && strings.has_prefix(entry.name, "10.") {
                append(&versions, entry.name)
            }
        }
        slice.sort_by(versions[:], proc(a, b: string) -> bool {
            return a > b
        })
        for ver in versions {
            candidate := filepath.join({base, ver, "x64", "rc.exe"})
            if os.exists(candidate) {
                rc_exe = candidate
                break
            }
        }
        if rc_exe != "" {
        	break
        }
    }

    if rc_exe == "" {
    	fmt.eprintln("Err: can't find rc.exe")
        os.exit(1)
    }

    _, _, _, err1 := os2.process_exec(
    	os2.Process_Desc{command={rc_exe, "/fo", compiled_resources_file_path, resources_file_path}},
		context.allocator,
    )
    if err1 != os2.General_Error.None {
    	fmt.eprintln("Err: %v", err1)
        os.exit(1)
    }

    if !os.exists(bin_dir) {
    	os.make_directory(bin_dir)
    }

    output_file_path := filepath.join({bin_dir, "jmscript-win.exe"})

    build_prod_cmd: []string = {
	    "odin",
	    "build",
	    src_dir,
	    "-build-mode:exe",
		"-target:windows_amd64",
		"-subsystem:console",
		"-o:speed",
		"-no-bounds-check",
		"-no-threaded-checker",
		"-disable-assert",
		"-source-code-locations:none",
		"-vet-shadowing",
		"-vet-tabs",
		"-vet-cast",
		"-vet-using-stmt",
		"-vet-semicolon",
		"-strict-style",
		"-disallow-do",
		"-warnings-as-errors",
		"-linker:lld",
		"-lto:thin",
	 	fmt.tprintf(`-extra-linker-flags:%s`, compiled_resources_file_path),
		fmt.tprintf("-out:%s", output_file_path),
	}

	_, stdout, stderr, err := os2.process_exec(
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
	if os.exists(compiled_resources_file_path) {
		os.remove(compiled_resources_file_path)
	}
	fmt.printfln("%s", stdout)
}
