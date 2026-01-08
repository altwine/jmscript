#+feature dynamic-literals
package update_assets

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
	os.write_string(fd, "package assets\n\n")
	os.write_string(fd, "import \"base:runtime\"\n\n")
	os.write_string(fd, "Event :: struct {\n\tname: string,\n\tcancellable: bool,\n}\n\n")
	os.write_string(fd, "events: map[string]Event\n\n")
	os.write_string(fd, "@(init)\ninit_events :: proc \"contextless\" () {\n")
	os.write_string(fd, "\tcontext = runtime.default_context()\n\tevents = make(map[string]Event, context.allocator)\n")
	for event in events {
		os.write_string(fd, "\tevents[\"")
		os.write_string(fd, event.name)
		os.write_string(fd, "\"] = Event{name=\"")
		os.write_string(fd, event.name)
		os.write_string(fd, "\", cancellable=")
		if event.cancellable {
			os.write_string(fd, "true")
		} else {
			os.write_string(fd, "false")
		}
		os.write_string(fd, "}\n")
	}
	os.write_string(fd, "}\n\n")
	os.write_string(fd, "@(fini)\ncleanup_events :: proc \"contextless\" () {\n")
	os.write_string(fd, "\tcontext = runtime.default_context()\n\tdelete(events)\n}\n\n")
	os.write_string(fd, "event_native_from_mapped :: proc(event_name: string) -> (Event, bool) {\n")
	os.write_string(fd, "\treturn events[event_name]\n")
	os.write_string(fd, "}\n")
	return "", true
}
