package generate_docs

import "core:strings"

parse_properties :: proc(properties_raw: string, allocator := context.allocator) -> map[string]string {
	raw_lines := strings.split_lines(properties_raw, context.allocator)
	properties := make(map[string]string, len(raw_lines), context.allocator)
	for line in raw_lines {
		line := strings.trim_space(line)
		if strings.starts_with(line, "#") || line == "" {
			continue
		}
		raw_line_parsed := strings.split_n(line, "=", 2, context.allocator)
		key := raw_line_parsed[0]
		value := raw_line_parsed[1]
		properties[key] = value
	}
	return properties
}
