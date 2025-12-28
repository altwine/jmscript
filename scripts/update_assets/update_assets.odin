package update_assets

import "core:fmt"
import "core:os"
import "core:path/filepath"

URL_BASE_JMS :: "https://raw.githubusercontent.com/donzgold/JustMC_compilator/refs/heads/master/new_data/"
URL_ACTIONS_1 :: URL_BASE_JMS+"actions.json"
URL_EVENTS_1 :: URL_BASE_JMS+"events.json"
URL_EVENTS_2 :: URL_BASE_JMS+"events_map.json"

main :: proc() {
	exe_path, _ := filepath.abs(os.args[0])
    exe_dir := filepath.dir(exe_path)
    assets_dir := filepath.join([]string{exe_dir, "assets"})

	events_error_msg, events_success := extract_events(filepath.join([]string{assets_dir, "events.odin"}))
	actions_error_msg, actions_success := extract_actions(filepath.join([]string{assets_dir, "actions.odin"}))

	fmt.printfln("%s %s", events_error_msg, actions_error_msg)
}
