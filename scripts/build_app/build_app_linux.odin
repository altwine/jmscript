package build_app

get_exe_name :: proc(is_legacy: bool) -> string {
	return "jmscript-linux-compat" if is_legacy else "jmscript-linux"
}

TARGET_FLAG :: "-target:linux_amd64"
EXTRA_DEBUG_FLAGS :: ""

get_extra_release_flags :: proc(is_legacy: bool, _, _: string) -> []string {
	return nil
}

cleanup_platform :: proc(compiled_resources_file_path: string) {
}
