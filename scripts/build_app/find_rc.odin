package build_app

import "core:slice"
import "core:path/filepath"
import "core:os"
import "core:strings"

find_rc_exe :: proc() -> string {
	bases := []string{
		`C:\Program Files (x86)\Windows Kits\10\bin`,
		`C:\Program Files\Windows Kits\10\bin`,
	}

	for base in bases {
		if !os.exists(base) {
			continue
		}
		entries, _ := os.read_all_directory_by_path(base, context.allocator)
		versions := make([dynamic]string)

		for entry in entries {
			if entry.type == .Directory && strings.has_prefix(entry.name, "10.") {
				append(&versions, entry.name)
			}
		}

		slice.sort_by(versions[:], proc(a, b: string) -> bool { return a > b })

		for ver in versions {
			candidate, _ := filepath.join({base, ver, "x64", "rc.exe"}, context.allocator)
			if os.exists(candidate) {
				return candidate
			}
		}
	}

	return ""
}
