package cli

import "core:fmt"

command_version :: #force_inline proc() {
	fmt.printfln("jmscript version: %s", #load("../../VERSION"))
}
