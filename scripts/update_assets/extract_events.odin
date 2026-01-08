#+feature dynamic-literals
package update_assets

import "core:fmt"
import "core:encoding/json"
import "core:os"

Event :: struct {
	name: string `json:"id"`,
	category: string `json:"category"`,
	cancellable: bool `json:"cancellable"`,
	works_with: []string `json:"worksWith,omitempty"`,
	additional_info: []string `json:"additionalInfo,omitempty"`,
}

Event_Stripped :: struct {
	cancellable: bool `json:"cancellable"`,
}

extract_events :: proc(output_file: string) -> (string, bool) {
	events1 := fetch_url(URL_EVENTS_1)
	events2 := fetch_url(URL_EVENTS_2)
	events := make([dynamic]Event)
	events_stripped: map[string]Event_Stripped
	err1 := json.unmarshal(transmute([]byte)events1, &events)
	if err1 != nil {
		return "Failed to parse JSON (1)", false
	}
	err2 := json.unmarshal(transmute([]byte)events2, &events_stripped)
	if err2 != nil {
		return "Failed to parse JSON (2)", false
	}

	for name, cancellable_state in events_stripped {
		append(&events, Event{name=name, cancellable=cancellable_state.cancellable})
	}

	fd, _ := os.open(output_file, os.O_CREATE | os.O_RDWR | os.O_TRUNC)
	defer os.close(fd)
	fmt.fprintln(fd, "package assets\n")

	fmt.fprintln(fd, "import \"base:runtime\"\n")

	fmt.fprintln(fd, "Event :: struct {\n\tname: string,\n\tcancellable: bool,\n}\n")

	fmt.fprintln(fd, "events: map[string]Event\n")

	fmt.fprintln(fd, "@(init)")
	fmt.fprintln(fd, "init_events :: proc \"contextless\" () {")
	fmt.fprintln(fd, "\tcontext = runtime.default_context()")
	fmt.fprintln(fd, "\tevents = make(map[string]Event, context.allocator)")
	for event in events {
		fmt.fprintf(fd, "\tevents[\"%s\"] = Event{{name=\"%s\", cancellable=", event.name, event.name)
		if event.cancellable {
			fmt.fprint(fd, "true")
		} else {
			fmt.fprint(fd, "false")
		}
		fmt.fprintln(fd, "}")
	}
	fmt.fprintln(fd, "}\n")

	fmt.fprintln(fd, "@(fini)")
	fmt.fprintln(fd, "cleanup_events :: proc \"contextless\" () {")
	fmt.fprintln(fd, "\tcontext = runtime.default_context()")
	fmt.fprintln(fd, "\tdelete(events)")
	fmt.fprintln(fd, "}\n")

	fmt.fprintln(fd, "event_native_from_mapped :: proc(event_name: string) -> (Event, bool) {")
	fmt.fprintln(fd, "\treturn events[event_name]")
	fmt.fprintln(fd, "}")

	return "", true
}
