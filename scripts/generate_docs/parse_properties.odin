package generate_docs

import "core:strings"

parse_properties :: proc(properties_raw: string, allocator := context.allocator) -> map[string]string {
	raw_lines := strings.split_lines(properties_raw, allocator)
	properties := make(map[string]string, len(raw_lines), allocator)
	for raw_line in raw_lines {
		line := strings.trim_space(raw_line)
		if strings.starts_with(line, "#") || line == "" {
			continue
		}
		line_parsed := strings.split_n(line, "=", 2, allocator)
		key := line_parsed[0]
		value := line_parsed[1]
		properties[key] = value
	}
	return properties
}
