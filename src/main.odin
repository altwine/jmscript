package main

import "core:log"
import "core:sys/windows"
import "core:mem"
import "core:fmt"

import "./cli"

@(init)
setup_encoding :: proc "contextless"() {
	when ODIN_OS == .Windows {
		windows.SetConsoleOutputCP(windows.CODEPAGE.UTF8)
		windows.SetConsoleCP(windows.CODEPAGE.UTF8)
	}
}

main :: proc() {
	when ODIN_DEBUG {
		track: mem.Tracking_Allocator
		mem.tracking_allocator_init(&track, context.allocator)
		context.allocator = mem.tracking_allocator(&track)

		defer {
			if len(track.allocation_map) > 0 {
				fmt.eprintf("=== %v allocations not freed: ===\n", len(track.allocation_map))
				for _, entry in track.allocation_map {
					fmt.eprintf("- %v bytes @ %v\n", entry.size, entry.location)
				}
			}
			if len(track.bad_free_array) > 0 {
				fmt.eprintf("=== %v incorrect frees: ===\n", len(track.bad_free_array))
				for entry in track.bad_free_array {
					fmt.eprintf("- %p @ %v\n", entry.memory, entry.location)
				}
			}
			mem.tracking_allocator_destroy(&track)
		}
	}

	error_level: log.Level = .Debug if ODIN_DEBUG else .Info if .Verbose in cli.flags else .Error
	logger_opts: log.Options = {.Level, .Terminal_Color, .Time}
	context.logger = log.create_console_logger(error_level, logger_opts, "", context.allocator)
	defer log.destroy_console_logger(context.logger, context.allocator)

	switch cli.command {
	case "compile": cli.command_compile()
	case "version": cli.command_version()
	case "init":    cli.command_init()
	case "report":  cli.command_report()
	case "license": cli.command_license()
	case:           cli.command_help()
	}
}
