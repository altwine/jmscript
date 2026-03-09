package cli

import "core:time"
import "base:runtime"
import "vendor:curl"

import "core:strconv"
import "core:strings"
import "core:mem"
import "core:encoding/hex"
import "core:math/rand"
import "core:path/filepath"
import "core:fmt"
import "core:os"
import "core:log"
import "core:thread"
import vmem "core:mem/virtual"

import "../compiler"
import "../../assets"

command_compile :: #force_inline proc() {
	when thread.IS_SUPPORTED {
		thread_count := max(1, os.get_processor_core_count())
		log.debugf("Threading is supported. Available threads: %d", thread_count)
	} else {
		log.debugf("Threading not supported.")
	}
	log.debugf("Threading isn't implemented right now.")

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
	// assets.init_entities(alloc)
	assets.init_events(alloc)
	assets.init_mc_items(alloc)
	// assets.init_particles(alloc)
	// assets.init_instruments(alloc)
	// defer assets.cleanup_actions()
	// defer assets.cleanup_entities()
	// defer assets.cleanup_events()
	// defer assets.cleanup_mc_items()
	// defer assets.cleanup_particles()
	// defer assets.cleanup_instruments()

	c: compiler.Compiler
	compiler.compiler_init(&c, .Warnings_As_Errors in flags, alloc)

	unique_id_raw := transmute([16]byte)rand.uint128()
	unique_id := string(hex.encode(unique_id_raw[:], c.alloc))
	result_code, success := compiler.compile(&c, dir_path, .Minify_Json in flags, unique_id)

	if !success {
		return
	}

	if .Print_To_Stdout in flags {
		fmt.printfln("%s", result_code)
	}

	if .Upload_To_Server in flags {
		code_url, ok := upload_code(result_code, alloc)
		if !ok {
			fmt.println("Code not uploaded for some reason!!!!!")
			return
		}
		fmt.printfln("Your code is uploaded: /module loadUrl force %s", code_url)
	}
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

	if opt_res := curl.easy_setopt(ce, curl.option.URL, CODE_SERVER_URL); opt_res != .E_OK {
		fmt.printfln("Can't upload code: %s", curl.easy_strerror(opt_res))
		return "", false
	}

	if opt_res := curl.easy_setopt(ce, curl.option.POST, true); opt_res != .E_OK {
		fmt.printfln("Can't upload code: %s", curl.easy_strerror(opt_res))
		return "", false
	}

	if opt_res := curl.easy_setopt(ce, curl.option.WRITEFUNCTION, write_to_string); opt_res != .E_OK {
		fmt.printfln("Can't upload code: %s", curl.easy_strerror(opt_res))
		return "", false
	}

	if opt_res := curl.easy_setopt(ce, curl.option.WRITEDATA, &builder); opt_res != .E_OK {
		fmt.printfln("Can't upload code: %s", curl.easy_strerror(opt_res))
		return "", false
	}

	if opt_res := curl.easy_setopt(ce, curl.option.POSTFIELDS, code); opt_res != .E_OK {
		fmt.printfln("Can't upload code: %s", curl.easy_strerror(opt_res))
		return "", false
	}

	header_content_type := cstring("Content-Type: application/json")
	headers := curl.slist_append(nil, header_content_type)
	defer curl.slist_free_all(headers)

	if opt_res := curl.easy_setopt(ce, curl.option.HTTPHEADER, headers); opt_res != .E_OK {
		fmt.printfln("Can't upload code: %s", curl.easy_strerror(opt_res))
		return "", false
	}

	if opt_res := curl.easy_setopt(ce, curl.option.NOSIGNAL, true); opt_res != .E_OK {
		fmt.printfln("Can't upload code: %s", curl.easy_strerror(opt_res))
		return "", false
	}

	if perform_res := curl.easy_perform(ce); perform_res != .E_OK {
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
	code_url := fmt.tprintf("https://m.justmc.ru/api/%s#origin=jms,timestamp=%s", result_id, ts)
	return code_url, true
}
