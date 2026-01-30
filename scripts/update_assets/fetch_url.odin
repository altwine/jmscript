package update_assets

import "base:runtime"
import "vendor:curl"
import "core:fmt"
import "core:strings"

@(init)
init_curl :: proc "contextless" () {
	curl.global_init(curl.GLOBAL_ALL)
}

@(fini)
fini_curl :: proc "contextless" () {
	curl.global_cleanup()
}

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

fetch_url :: proc(url: string) -> (string, bool) #optional_ok {
    c := curl.easy_init()
    defer curl.easy_cleanup(c)

    builder: strings.Builder
    strings.builder_init(&builder, 0, 0)
    defer strings.builder_destroy(&builder)

    c_url := strings.clone_to_cstring(url)
    defer delete(c_url)

    curl.easy_setopt(c, curl.option.URL, c_url)
    curl.easy_setopt(c, curl.option.WRITEFUNCTION, write_to_string)
    curl.easy_setopt(c, curl.option.WRITEDATA, &builder)
    curl.easy_setopt(c, curl.option.FOLLOWLOCATION, 1)
    curl.easy_setopt(c, curl.option.NOSIGNAL, true)

    res := curl.easy_perform(c)

    if res != .E_OK {
        fmt.eprintf("CURL error: %s\n", curl.easy_strerror(res))
        return "", false
    }

    return strings.clone(strings.to_string(builder)), true
}
