package update_assets

import "core:os"
import "core:path/filepath"

URL_BASE_MC :: "https://raw.githubusercontent.com/PrismarineJS/minecraft-data/refs/heads/master/data/pc/1.21.8/"
URL_BASE_JMS :: "https://raw.githubusercontent.com/donzgold/JustMC_compilator/refs/heads/master/new_data/"

main :: proc() {
	exe_path, _ := filepath.abs(os.args[0])
    exe_dir := filepath.dir(exe_path)
    assets_dir := filepath.join([]string{exe_dir, "assets"})

    events_filepath := filepath.join([]string{assets_dir, "events.odin"})
	events := extract_events()
	write_events(events_filepath, events)

	actions_filepath := filepath.join([]string{assets_dir, "actions.odin"})
	actions := extract_actions()
	write_actions(actions_filepath, actions)

	items_filepath := filepath.join([]string{assets_dir, "items.odin"})
	items := extract_items()
	write_items(items_filepath, items)

	entities_filepath := filepath.join([]string{assets_dir, "entities.odin"})
	entities := extract_entities()
	write_entities(entities_filepath, entities)

	particles_filepath := filepath.join([]string{assets_dir, "particles.odin"})
	particles := extract_particles()
	write_particles(particles_filepath, particles)
}
