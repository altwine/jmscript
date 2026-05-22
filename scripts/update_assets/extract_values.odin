package update_assets

import "core:fmt"
import "core:encoding/json"
import "core:os"

Game_Value :: struct {
	id:   string `json:"id"`,
    type: string `json:"type"`,
}

URL_GAME_VALUES :: URL_BASE_JMS+"game_values.json"

extract_game_values :: proc() -> [dynamic]Game_Value {
	game_values1 := fetch_url(URL_GAME_VALUES)
	game_values := make([dynamic]Game_Value)
	err := json.unmarshal(transmute([]byte)game_values1, &game_values)
	if err != nil {
		return nil
	}

	return game_values
}

write_game_values :: proc(output_file: string, game_values: [dynamic]Game_Value) {
	fd, _ := os.open(output_file, os.O_CREATE | os.O_RDWR | os.O_TRUNC)
	defer os.close(fd)

	fmt.fprintln(fd, "package assets\n")

	fmt.fprintln(fd, "Game_Value :: struct {")
	fmt.fprintln(fd, "\tid: string,")
	fmt.fprintln(fd, "\ttype: string,")
	fmt.fprintln(fd, "}\n")

	fmt.fprintln(fd, "game_values: map[string]Game_Value\n")

	fmt.fprintln(fd, "init_game_values :: proc(allocator := context.allocator) {")
	fmt.fprintln(fd, fmt.tprintf("\tgame_values = make(map[string]Game_Value, %d, allocator)", len(game_values)))
	for game_value in game_values {
		fmt.fprintfln(fd, "\tgame_values[\"%s\"] = {{\"%s\", \"%s\"}", game_value.id, game_value.id, game_value.type)
	}
	fmt.fprintln(fd, "}\n")

	fmt.fprintln(fd, "cleanup_game_values :: proc() {")
	fmt.fprintln(fd, "\tdelete(game_values)")
	fmt.fprintln(fd, "}\n")

	fmt.fprintln(fd, "get_minecraft_game_value :: proc(game_value_name: string) -> (Game_Value, bool) {")
	fmt.fprintln(fd, "\treturn game_values[game_value_name]")
	fmt.fprintln(fd, "}")
}
