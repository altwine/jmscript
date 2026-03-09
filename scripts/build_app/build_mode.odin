package build_app

import "core:slice"
import "core:os"

Build_Mode :: enum {
	Unspecified,
	Release,
	Debug,
}

get_build_mode :: proc() -> Build_Mode {
	switch {
	case has_flag("-d"), has_flag("--debug"),
		has_flag("/d"), has_flag("/debug"):
		return .Debug

	case has_flag("-r"), has_flag("--release"),
		has_flag("/r"), has_flag("/release"):
		return .Release

	case:
		return .Unspecified
	}
}

@(private="file")
has_flag :: proc(flag: string) -> bool {
	return slice.contains(os.args, flag),
}
