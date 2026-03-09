package cli

import "core:mem"
import "core:fmt"
import "core:sys/info"

command_report :: #force_inline proc() {
	os_version, _ := info.os_version(context.allocator)
	total_ram, _, _, _, _ := info.ram_stats()
	cpu_name := info.cpu_name()

	fmt.printfln("If there's nothing confidential, add this to your bug report:")
	fmt.printfln("\tJMS ver: %s", #load("../../VERSION"))
	fmt.printfln("\tOS: %s", os_version.full)
	fmt.printfln("\tRAM: %d MiB", total_ram / mem.Megabyte)
	fmt.printfln("\tCPU: %s", cpu_name)
}
