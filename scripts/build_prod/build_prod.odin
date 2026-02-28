package build_prod

import "core:path/filepath"
import "core:os"
import "core:os/os2"
import "core:fmt"
import "core:strings"
import "core:slice"

main :: proc() {
	is_legacy := slice.contains(os.args, "-l") || slice.contains(os.args, "--legacy")

	exe_path, _ := filepath.abs(os.args[0])
    exe_dir := filepath.dir(exe_path)

    bin_dir := filepath.join({exe_dir, "bin"})
    src_dir := filepath.join({exe_dir, "src"})
    resources_dir := filepath.join({exe_dir, "resources"})

    resources_file_path := filepath.join({resources_dir, "resources.rc"})
    compiled_resources_file_path := filepath.join({resources_dir, "resources.res"})

    if !is_legacy {
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
    }

    if !os.exists(bin_dir) {
    	os.make_directory(bin_dir)
    }

    output_file_path := filepath.join({bin_dir, "jmscript-win.exe" if !is_legacy else "jmscript-win-compat.exe"})

    build_prod_cmd := make([dynamic]string, context.allocator)
    defer delete(build_prod_cmd)
    append(&build_prod_cmd, "odin")
    append(&build_prod_cmd, "build")
    append(&build_prod_cmd, src_dir)
    append(&build_prod_cmd, "-build-mode:exe")
    append(&build_prod_cmd, "-target:windows_amd64")
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
    append(&build_prod_cmd, fmt.tprintf("-out:%s", output_file_path))

	if is_legacy {
		append(&build_prod_cmd, fmt.tprintf(`-resource:%s`, resources_file_path))
		append(&build_prod_cmd, `-extra-linker-flags:/LTCG`)
		append(&build_prod_cmd, "-microarch:x86-64-v2")
	} else {
		append(&build_prod_cmd, fmt.tprintf(`-extra-linker-flags:%s /LTCG`, compiled_resources_file_path))
		append(&build_prod_cmd, "-microarch:x86-64-v3")
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
