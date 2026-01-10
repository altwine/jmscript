package update_assets

import "core:fmt"
import "core:encoding/json"
import "core:os"

Entity :: struct {
	id:            int      `json:"id"`,
    internal_id:   int      `json:"internalId"`,
    name:          string   `json:"name"`,
    display_name:  string   `json:"displayName"`,
    width:         f64      `json:"width"`,
    height:        f64      `json:"height"`,
    type:          string   `json:"type"`,
    category:      string   `json:"category"`,
    metadata_keys: []string `json:"metadataKeys"`,
}

URL_ENTITIES :: URL_BASE_MC+"entities.json"

extract_entities :: proc() -> [dynamic]Entity {
	entities1 := fetch_url(URL_ENTITIES)
	entities := make([dynamic]Entity)
	err := json.unmarshal(transmute([]byte)entities1, &entities)
	if err != nil {
		return nil
	}

	return entities
}

write_entities :: proc(output_file: string, entities: [dynamic]Entity) {
	fd, _ := os.open(output_file, os.O_CREATE | os.O_RDWR | os.O_TRUNC)
	defer os.close(fd)

	fmt.fprintln(fd, "package assets\n")

	fmt.fprintln(fd, "Entity :: struct {")
	fmt.fprintln(fd, "\tname: string,")
	fmt.fprintln(fd, "}\n")

	fmt.fprintln(fd, "entities: map[string]Entity\n")

	fmt.fprintln(fd, "init_entities :: proc(allocator := context.allocator) {")
	fmt.fprintln(fd, fmt.tprintf("\tentities = make(map[string]Entity, %d, allocator)", len(entities)))
	for entity in entities {
		fmt.fprintfln(fd, "\tentities[\"%s\"] = {{\"%s\"}", entity.name, entity.name)
	}
	fmt.fprintln(fd, "}\n")

	fmt.fprintln(fd, "cleanup_entities :: proc() {")
	fmt.fprintln(fd, "\tdelete(entities)")
	fmt.fprintln(fd, "}\n")

	fmt.fprintln(fd, "get_minecraft_entity :: proc(entity_name: string) -> (Entity, bool) {")
	fmt.fprintln(fd, "\treturn entities[entity_name]")
	fmt.fprintln(fd, "}")
}
