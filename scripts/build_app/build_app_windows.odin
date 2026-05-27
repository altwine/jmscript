package build_app

import "core:os"
import "core:fmt"

get_exe_name :: proc(is_legacy: bool) -> string {
	return "jmscript-win-compat.exe" if is_legacy else "jmscript-win.exe"
}

TARGET_FLAG :: "-target:windows_amd64"
EXTRA_DEBUG_FLAGS :: "-extra-linker-flags:/LTCG /IGNORE:4099"

get_extra_release_flags :: proc(is_legacy: bool, resources_file_path, compiled_resources_file_path: string) -> []string {
	flags: [dynamic]string
	if !is_legacy {
		rc_exe := find_rc_exe()
		if rc_exe == "" {
			fmt.eprintln("Err: can't find rc.exe")
			os.exit(1)
		}
		exec_command({rc_exe, "/fo", compiled_resources_file_path, resources_file_path})
		append(&flags, fmt.tprintf(`-extra-linker-flags:/LTCG %s`, compiled_resources_file_path))
	} else {
		append(&flags, fmt.tprintf(`-resource:%s`, resources_file_path))
		append(&flags, `-extra-linker-flags:/LTCG`)
	}
	return flags[:]
}


cleanup_platform :: proc(compiled_resources_file_path: string) {
	if os.exists(compiled_resources_file_path) {
		os.remove(compiled_resources_file_path)
	}
}
