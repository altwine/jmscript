package update_assets

// import "core:slice"
// import "core:strconv"
// import "core:os"
// import "core:text/regex"
// import "core:fmt"

// extract_events :: proc(output_file: string) -> (string, bool) {
// 	events1 := fetch_url(URL_EVENTS_1)
// 	events2 := fetch_url(URL_EVENTS_2)

// 	Event :: struct {
// 		name: string,
// 		cancellable: bool,
// 	}
// 	events := make([dynamic]Event)

// 	iter1, err1 := regex.create_iterator(events2, "\"(\\w+?)\": \\{\"cancellable\": (\\w+?)}")
// 	if err1 != nil {
// 		return fmt.tprint(err1), false
// 	}

// 	for {
// 		capture, index, ok := regex.match_iterator(&iter1)
// 		if !ok {
// 			break
// 		}
// 		event_name := capture.groups[1]
// 		event_cancellable_raw := capture.groups[2]
// 		append(&events, Event{name=event_name, cancellable=event_cancellable_raw == "true"})
// 	}

// 	iter2, err2 := regex.create_iterator(events1, "\"id\": \"(\\w+?)\",.*?\"cancellable\": (\\w+?)\n")
// 	if err2 != nil {
// 		return fmt.tprint(err2), false
// 	}

// 	for {
// 		capture, index, ok := regex.match_iterator(&iter2)
// 		if !ok {
// 			break
// 		}
// 		event_name := capture.groups[1]
// 		event_cancellable_raw := capture.groups[2]
// 		append(&events, Event{name=event_name, cancellable=event_cancellable_raw == "true"})
// 	}

// 	event_names := make([dynamic]string)
// 	buf: [16]byte
// 	for event in events {
// 		append(&event_names, event.name)
// 	}
// 	c := remove_duplicates(event_names[:])
// 	resize(&event_names, c)
// 	slice.sort(event_names[:])

// 	fd, _ := os.open(output_file, os.O_CREATE | os.O_RDWR | os.O_TRUNC)
// 	defer os.close(fd)
// 	os.write_string(fd, "package assets\n\n")
// 	os.write_string(fd, "import \"core:slice\"\n\n")
// 	os.write_string(fd, "event_is_valid :: proc(event_name: string) -> bool {\n")
// 	os.write_string(fd, "\t_, found := slice.binary_search(EVENT_NAMES[:], event_name)\n")
// 	os.write_string(fd, "\treturn found\n")
// 	os.write_string(fd, "}\n\n")
// 	os.write_string(fd, "event_is_cancellable :: proc(event_name: string) -> bool {\n")
// 	os.write_string(fd, "\tswitch event_name {\n")
// 	for event in events {
// 		if !event.cancellable {
// 			continue
// 		}
// 		os.write_string(fd, "\tcase \"")
// 		os.write_string(fd, event.name)
// 		os.write_string(fd, "\":\n\t\treturn true\n")
// 	}
// 	os.write_string(fd, "\tcase:\n\t\treturn false\n")
// 	os.write_string(fd, "\t}\n")
// 	os.write_string(fd, "}\n\n")
// 	os.write_string(fd, "@(rodata)\n")
// 	os.write_string(fd, "EVENT_NAMES := [")
// 	os.write_string(fd, strconv.write_int(buf[:], cast(i64)len(event_names), 10))
// 	os.write_string(fd, "]string{\n")
// 	for event_name in event_names {
// 		os.write_string(fd, "\t\"")
// 		os.write_string(fd, event_name)
// 		os.write_string(fd, "\",\n")
// 	}
// 	os.write_string(fd, "}\n")

// 	return "", true
// }
