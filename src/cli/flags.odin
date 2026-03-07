package cli

import "core:fmt"
import "core:strings"
import "core:os"
import "base:runtime"

Flag_Kind :: enum {
	Verbose,
	Minify_Json,
	Print_To_Stdout,
	Upload_To_Server,
	Warnings_As_Errors,
}

flags: bit_set[Flag_Kind]
exe_path, command: string

@(init, private="file")
extract_flags :: proc "contextless" () {
	context = runtime.default_context()
	exe_path = os.args[0]
	if len(os.args) < 2 {
		return
	}
	command = os.args[1]
	for arg in os.args[1:] {
		switch strings.to_lower(arg, context.temp_allocator) {
		case "-v", "--verbose", "/v", "/verbose":
			flags += {.Verbose}
		case "-m", "--minify", "/m", "/minify":
			flags += {.Minify_Json}
		case "-r", "--raw", "/r", "/raw":
			flags += {.Print_To_Stdout}
		case "-w", "--warnings-as-errors", "/w", "/warnings-as-errors":
			flags += {.Warnings_As_Errors}
		case "-u", "--upload", "/u", "/upload":
			flags += {.Upload_To_Server}
		case:
			if len(arg) > 0 && (arg[0] == '-' || arg[0] == '/') {
				fmt.printfln("Unknown flag '%s' ignored", arg)
			}
		}
	}
}
