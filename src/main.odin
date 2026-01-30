package main

import "core:sys/info"
import "core:thread"
import "core:strconv"
import "core:strings"
import "base:runtime"
import "core:slice"
import "vendor:curl"
import "core:encoding/hex"
import "core:math/rand"
import "core:time"
import "core:sys/windows"
import "core:path/filepath"
import "core:os"
import "core:mem"
import vmem "core:mem/virtual"
import "core:fmt"

import "./compiler"
import "../assets"

@(init)
setup_encoding :: proc "contextless"() {
	when ODIN_OS == .Windows {
		windows.SetConsoleOutputCP(windows.CODEPAGE.UTF8)
		windows.SetConsoleCP(windows.CODEPAGE.UTF8)
	}
}

main :: proc() {
	sw: time.Stopwatch
	time.stopwatch_start(&sw)
	defer {
		ms_duration := time.stopwatch_duration(sw)
		fmt.printfln("[DEBUG] %0.2fms", time.duration_milliseconds(ms_duration))
	}

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

	if len(os.args) < 2 {
		print_help()
		return
	}

	switch os.args[1] {
	case "compile":
		command_compile()
	case "version":
		command_version()
	case "init":
		command_init()
	case "report":
		command_report()
	case "license":
		command_license()
	case "help":
		command_help()
	case:
		print_help()
	}
}

command_compile :: proc() {
	when thread.IS_SUPPORTED {
		thread_count := max(1, os.processor_core_count())
		fmt.printfln("[DEBUG] [Threading] Supported. Available threads: %d", thread_count)
	} else {
		fmt.println("[DEBUG] [Threading] Not supported.")
	}
	fmt.println("[DEBUG] [Threading] Not implemented right now.")

	if len(os.args) < 3 {
		fmt.println("Not enough arguments: path to dir is expected!")
		print_help()
		return
	}

	dir_path_raw := os.args[2]
	dir_path, _ := filepath.abs(dir_path_raw, context.allocator)
	defer delete(dir_path)

	arena: vmem.Arena
	err := vmem.arena_init_growing(&arena, mem.Megabyte)
	alloc := vmem.arena_allocator(&arena)
	defer vmem.arena_destroy(&arena)

	assets.init_actions(alloc)
	defer assets.cleanup_actions()
	assets.init_entities(alloc)
	defer assets.cleanup_entities()
	assets.init_events(alloc)
	defer assets.cleanup_events()
	assets.init_mc_items(alloc)
	defer assets.cleanup_mc_items()
	assets.init_particles(alloc)
	defer assets.cleanup_particles()
	assets.init_instruments(alloc)
	defer assets.cleanup_instruments()

	c: compiler.Compiler
	compiler.compiler_init(&c, alloc)

	minify := slice.contains(os.args, "-m")
	unique_id_raw := transmute([16]byte)rand.uint128()
	unique_id := string(hex.encode(unique_id_raw[:], c.alloc))
	result_code, success := compiler.compile(&c, dir_path, minify, unique_id)

	if !success {
		return
	}

	if slice.contains(os.args, "-r") {
		fmt.printfln("%s", result_code)
	}

	if slice.contains(os.args, "-u") {
		code_url, ok := upload_code(result_code, alloc)
		if !ok {
			fmt.println("Code not uploaded for some reason!!!!!")
			return
		}
		fmt.printfln("Your code is uploaded: /module loadUrl force %s", code_url)
	}
}

command_version :: proc() {
	fmt.printfln("jmscript version: %s", #load("../VERSION"))
}

command_report :: proc() {
	fmt.printfln("If there's nothing confidential, add this to your bug report:")
	fmt.printfln("\tJMS ver: %s", #load("../VERSION"))
	fmt.printfln("\tOS: %s", info.os_version.as_string)
	fmt.printfln("\tRAM: %d MiB", info.ram.total_ram / mem.Megabyte)
	fmt.printfln("\tCPU: %s", info.cpu.name)
}

command_license :: proc() {
	LICENSE_TEXT : string : #load("../LICENSE")
	fmt.println(LICENSE_TEXT)
}

command_help :: proc() {
	print_help()
}

CODE_SERVER_URL :: "https://m.justmc.ru/api/upload"

write_to_string :: proc "c" (ptr: rawptr, size: uint, nmemb: uint, userdata: rawptr) -> uint {
	context	= runtime.default_context()
	realsize := size * nmemb
	if realsize == 0 {
		return 0
	}
	builder := cast(^strings.Builder)userdata
	data_ptr := cast([^]u8)ptr
	strings.write_bytes(builder, data_ptr[:realsize])
	return realsize
}

upload_code :: proc(code: string, allocator := context.allocator) -> (string, bool) {
	context.allocator = allocator
	curl.global_init(curl.GLOBAL_ALL)
	defer curl.global_cleanup()

	builder: strings.Builder
	strings.builder_init(&builder, 0, 0)
	defer strings.builder_destroy(&builder)

	ce := curl.easy_init()
	defer curl.easy_cleanup(ce)
	opt1_res := curl.easy_setopt(ce, curl.option.URL, CODE_SERVER_URL)
	if opt1_res != .E_OK {
		fmt.printfln("Can't upload code: %s", curl.easy_strerror(opt1_res))
		return "", false
	}

	opt2_res := curl.easy_setopt(ce, curl.option.POST, true)
	if opt2_res != .E_OK {
		fmt.printfln("Can't upload code: %s", curl.easy_strerror(opt2_res))
		return "", false
	}

	opt3_res := curl.easy_setopt(ce, curl.option.WRITEFUNCTION, write_to_string)
	if opt3_res != .E_OK {
		fmt.printfln("Can't upload code: %s", curl.easy_strerror(opt3_res))
		return "", false
	}

	opt4_res := curl.easy_setopt(ce, curl.option.WRITEDATA, &builder)
	if opt4_res != .E_OK {
		fmt.printfln("Can't upload code: %s", curl.easy_strerror(opt4_res))
		return "", false
	}

	opt5_res := curl.easy_setopt(ce, curl.option.POSTFIELDS, code)
	if opt5_res != .E_OK {
		fmt.printfln("Can't upload code: %s", curl.easy_strerror(opt5_res))
		return "", false
	}

	header_content_type := cstring("Content-Type: application/json")
	headers := curl.slist_append(nil, header_content_type)
	defer curl.slist_free_all(headers)

	opt6_res := curl.easy_setopt(ce, curl.option.HTTPHEADER, headers)
	if opt6_res != .E_OK {
		fmt.printfln("Can't upload code: %s", curl.easy_strerror(opt6_res))
		return "", false
	}

	opt7_res := curl.easy_setopt(ce, curl.option.NOSIGNAL, true)
	if opt7_res != .E_OK {
		fmt.printfln("Can't upload code: %s", curl.easy_strerror(opt7_res))
		return "", false
	}

	perform_res := curl.easy_perform(ce)
	if perform_res != .E_OK {
		fmt.printfln("Can't upload code: %s", curl.easy_strerror(perform_res))
		return "", false
	}

	response := strings.to_string(builder)
	if strings.contains(response, "Неправильный формат JSON файла") {
		fmt.printfln("This is purely compiler (codegen) error, please contact jmscript developers")
		fmt.printfln("%v", code)
		return "", false
	}
	result_id := response[7:len(response)-2]

	buf: [64]byte
	timestamp := time.time_to_unix(time.now())
	ts := strconv.write_int(buf[:], timestamp, 10)
	code_url := strings.clone(strings.concatenate([]string{"https://m.justmc.ru/api/", result_id, "#origin=jms,timestamp=", ts}))
	return code_url, true
}

command_init :: proc() {
	if len(os.args) < 3 {
		fmt.println("Not enough arguments: name of dir is expected!")
		print_help()
		return
	}

	dir_name := os.args[2]
	if os.exists(dir_name) {
		fmt.printfln("Path '%s' already exists, aborting...", dir_name)
		return
	}

	err := os.make_directory(dir_name)
	if err != os.ERROR_NONE {
		fmt.printfln("Cannot create '%s' directory, aborting...", dir_name)
		return
	}
	fmt.printfln("Directory '%s' successfully created!", dir_name)

	example_code :: #load("../resources/example.jms", string)
	file_path := fmt.tprintf("%s/%s", dir_name, "main.jms")

	fd, err2 := os.open(file_path, os.O_WRONLY|os.O_CREATE|os.O_TRUNC)
	if err2 != os.ERROR_NONE {
		fmt.printfln("Cannot create '%s' file, aborting...", file_path)
		return
	}

	_, err3 := os.write_string(fd, example_code)
	if err3 != os.ERROR_NONE {
		fmt.printfln("Cannot write to file '%s', aborting...", file_path)
		return
	}

	fmt.println("Project created successfully!")
}

print_help :: proc() {
	fmt.println("Usage:")
	fmt.printfln("\t%s command [arguments]", os.args[0])
	fmt.println("Commands:")
	fmt.println("\tcompile   Compiles directory. All .jms files in the directory must have same package.")
	fmt.println("\tversion   Prints version.")
	fmt.println("\tinit      Initialize project.")
	fmt.println("\treport    Prints system information for bug report.")
	fmt.println("\tlicense   Prints license text.")
	fmt.println("\thelp      Prints help message.")
	fmt.println("\t...       Everything else prints this message.")
}
