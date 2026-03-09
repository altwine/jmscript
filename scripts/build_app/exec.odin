package build_app

import "core:fmt"
import "core:os"

exec_command :: proc(command: []string) {
	_, stdout, stderr, err := os.process_exec(
		os.Process_Desc{command=command},
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
}
