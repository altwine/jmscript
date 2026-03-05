package cli

import "core:mem"
import "core:fmt"
import "core:sys/info"

command_report :: #force_inline proc() {
	fmt.printfln("If there's nothing confidential, add this to your bug report:")
	fmt.printfln("\tJMS ver: %s", #load("../../VERSION"))
	fmt.printfln("\tOS: %s", info.os_version.as_string)
	fmt.printfln("\tRAM: %d MiB", info.ram.total_ram / mem.Megabyte)
	fmt.printfln("\tCPU: %s", info.cpu.name)
}
