package update_assets

import "core:slice"
import "core:fmt"
import "core:encoding/json"
import "core:os"

Event :: struct {
	name:            string   `json:"id"`,
	category:        string   `json:"category"`,
	cancellable:     bool     `json:"cancellable"`,
	works_with:      []string `json:"worksWith,omitempty"`,
	additional_info: []string `json:"additionalInfo,omitempty"`,
}

Event_Stripped :: struct {
	cancellable: bool `json:"cancellable"`,
}

EVENTS_BLACKLIST := []string{
	"player_dummy", "entity_dummy", "world_dummy"
}

URL_EVENTS_1 :: URL_BASE_JMS+"events.json"
URL_EVENTS_2 :: URL_BASE_JMS+"events_map.json"

extract_events :: proc() -> [dynamic]Event {
	events1 := fetch_url(URL_EVENTS_1)
	events2 := fetch_url(URL_EVENTS_2)
	events := make([dynamic]Event)
	events_stripped: map[string]Event_Stripped
	err1 := json.unmarshal(transmute([]byte)events1, &events)
	if err1 != nil {
		return nil
	}
	err2 := json.unmarshal(transmute([]byte)events2, &events_stripped)
	if err2 != nil {
		return nil
	}

	for name, cancellable_state in events_stripped {
		append(&events, Event{name=name, cancellable=cancellable_state.cancellable})
	}

	return events
}

write_events :: proc(output_file: string, events: [dynamic]Event) {
	fd, _ := os.open(output_file, os.O_CREATE | os.O_RDWR | os.O_TRUNC)
	defer os.close(fd)

	fmt.fprintln(fd, "package assets\n")

	fmt.fprintln(fd, "Event :: struct {")
	fmt.fprintln(fd, "\tname:        string,")
	fmt.fprintln(fd, "\tcancellable: bool,")
	fmt.fprintln(fd, "}\n")

	fmt.fprintln(fd, "events: map[string]Event\n")

	fmt.fprintln(fd, "init_events :: proc(allocator := context.allocator) {")
	fmt.fprintln(fd, fmt.tprintf("\tevents = make(map[string]Event, %d, allocator)", len(events) - len(EVENTS_BLACKLIST)))
	for event in events {
		if slice.contains(EVENTS_BLACKLIST[:], event.name) {
			continue
		}
		fmt.fprintf(fd, "\tevents[\"%s\"] = {{\"%s\", ", event.name, event.name)
		if event.cancellable {
			fmt.fprint(fd, "true")
		} else {
			fmt.fprint(fd, "false")
		}
		fmt.fprintln(fd, "}")
	}
	fmt.fprintln(fd, "}\n")

	fmt.fprintln(fd, "cleanup_events :: proc() {")
	fmt.fprintln(fd, "\tdelete(events)")
	fmt.fprintln(fd, "}\n")

	fmt.fprintln(fd, "event_native_from_mapped :: proc(event_name: string) -> (Event, bool) {")
	fmt.fprintln(fd, "\treturn events[event_name]")
	fmt.fprintln(fd, "}")
}
