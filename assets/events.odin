package assets

import "base:runtime"

Event :: struct {
	name: string,
	cancellable: bool,
}

events: map[string]Event

@(init)
init_events :: proc "contextless" () {
	context = runtime.default_context()
	events = make(map[string]Event, context.allocator)
	events["player_join"] = Event{name="player_join", cancellable=false}
	events["player_quit"] = Event{name="player_quit", cancellable=false}
	events["player_rejoin"] = Event{name="player_rejoin", cancellable=true}
	events["player_chat"] = Event{name="player_chat", cancellable=true}
	events["player_interact"] = Event{name="player_interact", cancellable=true}
	events["player_right_click"] = Event{name="player_right_click", cancellable=true}
	events["player_left_click"] = Event{name="player_left_click", cancellable=true}
	events["player_place_block"] = Event{name="player_place_block", cancellable=true}
	events["player_break_block"] = Event{name="player_break_block", cancellable=true}
	events["block_damage"] = Event{name="block_damage", cancellable=true}
	events["block_damage_abort"] = Event{name="block_damage_abort", cancellable=false}
	events["player_structure_grow"] = Event{name="player_structure_grow", cancellable=true}
	events["player_query_block_info"] = Event{name="player_query_block_info", cancellable=true}
	events["player_arm_swing"] = Event{name="player_arm_swing", cancellable=true}
	events["player_right_click_entity"] = Event{name="player_right_click_entity", cancellable=true}
	events["player_right_click_player"] = Event{name="player_right_click_player", cancellable=true}
	events["player_imbue_potion_cloud"] = Event{name="player_imbue_potion_cloud", cancellable=true}
	events["player_pickup_projectile"] = Event{name="player_pickup_projectile", cancellable=true}
	events["player_pickup_experience"] = Event{name="player_pickup_experience", cancellable=true}
	events["player_tame_entity"] = Event{name="player_tame_entity", cancellable=true}
	events["player_leash_entity"] = Event{name="player_leash_entity", cancellable=true}
	events["player_start_spectating_entity"] = Event{name="player_start_spectating_entity", cancellable=true}
	events["player_stop_spectating_entity"] = Event{name="player_stop_spectating_entity", cancellable=true}
	events["player_query_entity_info"] = Event{name="player_query_entity_info", cancellable=true}
	events["player_open_inventory"] = Event{name="player_open_inventory", cancellable=true}
	events["player_click_inventory"] = Event{name="player_click_inventory", cancellable=true}
	events["player_drag_inventory"] = Event{name="player_drag_inventory", cancellable=true}
	events["player_click_own_inventory"] = Event{name="player_click_own_inventory", cancellable=true}
	events["player_craft_item"] = Event{name="player_craft_item", cancellable=true}
	events["player_close_inventory"] = Event{name="player_close_inventory", cancellable=false}
	events["player_swap_hands"] = Event{name="player_swap_hands", cancellable=true}
	events["player_change_slot"] = Event{name="player_change_slot", cancellable=true}
	events["player_pick_item"] = Event{name="player_pick_item", cancellable=true}
	events["player_furnace_extract"] = Event{name="player_furnace_extract", cancellable=false}
	events["player_shot_bow"] = Event{name="player_shot_bow", cancellable=true}
	events["player_launch_projectile"] = Event{name="player_launch_projectile", cancellable=true}
	events["player_pickup_item"] = Event{name="player_pickup_item", cancellable=true}
	events["player_drop_item"] = Event{name="player_drop_item", cancellable=true}
	events["player_consume_item"] = Event{name="player_consume_item", cancellable=true}
	events["player_break_item"] = Event{name="player_break_item", cancellable=false}
	events["player_stop_using_item"] = Event{name="player_stop_using_item", cancellable=false}
	events["player_edit_book"] = Event{name="player_edit_book", cancellable=true}
	events["player_fish"] = Event{name="player_fish", cancellable=true}
	events["player_move"] = Event{name="player_move", cancellable=true}
	events["player_fail_move"] = Event{name="player_fail_move", cancellable=false}
	events["player_load_crossbow"] = Event{name="player_load_crossbow", cancellable=true}
	events["player_jump"] = Event{name="player_jump", cancellable=true}
	events["player_sneak"] = Event{name="player_sneak", cancellable=true}
	events["player_unsneak"] = Event{name="player_unsneak", cancellable=true}
	events["player_teleport"] = Event{name="player_teleport", cancellable=true}
	events["player_start_sprint"] = Event{name="player_start_sprint", cancellable=true}
	events["player_stop_sprint"] = Event{name="player_stop_sprint", cancellable=true}
	events["player_start_flight"] = Event{name="player_start_flight", cancellable=true}
	events["player_stop_flight"] = Event{name="player_stop_flight", cancellable=true}
	events["player_riptide"] = Event{name="player_riptide", cancellable=true}
	events["player_dismount"] = Event{name="player_dismount", cancellable=true}
	events["player_horse_jump"] = Event{name="player_horse_jump", cancellable=true}
	events["player_vehicle_jump"] = Event{name="player_vehicle_jump", cancellable=false}
	events["player_vehicle_move"] = Event{name="player_vehicle_move", cancellable=false}
	events["player_take_damage"] = Event{name="player_take_damage", cancellable=true}
	events["player_damage_player"] = Event{name="player_damage_player", cancellable=true}
	events["entity_damage_player"] = Event{name="entity_damage_player", cancellable=true}
	events["player_damage_entity"] = Event{name="player_damage_entity", cancellable=true}
	events["player_resurrect"] = Event{name="player_resurrect", cancellable=true}
	events["player_heal"] = Event{name="player_heal", cancellable=true}
	events["player_food_level_change"] = Event{name="player_food_level_change", cancellable=true}
	events["player_exhaustion"] = Event{name="player_exhaustion", cancellable=true}
	events["player_projectile_hit"] = Event{name="player_projectile_hit", cancellable=true}
	events["projectile_damage_player"] = Event{name="projectile_damage_player", cancellable=true}
	events["player_pre_attack_entity"] = Event{name="player_pre_attack_entity", cancellable=true}
	events["elder_guardian_appears_at_player"] = Event{name="elder_guardian_appears_at_player", cancellable=true}
	events["player_death"] = Event{name="player_death", cancellable=true}
	events["player_kill_player"] = Event{name="player_kill_player", cancellable=true}
	events["player_kill_mob"] = Event{name="player_kill_mob", cancellable=true}
	events["mob_kill_player"] = Event{name="mob_kill_player", cancellable=true}
	events["player_respawn"] = Event{name="player_respawn", cancellable=false}
	events["entity_spawn"] = Event{name="entity_spawn", cancellable=true}
	events["entity_removed_from_world"] = Event{name="entity_removed_from_world", cancellable=false}
	events["entity_damage_entity"] = Event{name="entity_damage_entity", cancellable=true}
	events["entity_kill_entity"] = Event{name="entity_kill_entity", cancellable=true}
	events["entity_take_damage"] = Event{name="entity_take_damage", cancellable=true}
	events["entity_heal"] = Event{name="entity_heal", cancellable=true}
	events["entity_resurrect"] = Event{name="entity_resurrect", cancellable=true}
	events["entity_death"] = Event{name="entity_death", cancellable=true}
	events["entity_spell_cast"] = Event{name="entity_spell_cast", cancellable=true}
	events["enderman_escape"] = Event{name="enderman_escape", cancellable=true}
	events["enderman_attack_player"] = Event{name="enderman_attack_player", cancellable=true}
	events["firework_explode"] = Event{name="firework_explode", cancellable=true}
	events["hanging_break"] = Event{name="hanging_break", cancellable=true}
	events["projectile_launch"] = Event{name="projectile_launch", cancellable=true}
	events["projectile_damage_entity"] = Event{name="projectile_damage_entity", cancellable=true}
	events["projectile_kill_entity"] = Event{name="projectile_kill_entity", cancellable=true}
	events["projectile_hit"] = Event{name="projectile_hit", cancellable=true}
	events["projective_collide"] = Event{name="projective_collide", cancellable=true}
	events["entity_drop_item"] = Event{name="entity_drop_item", cancellable=true}
	events["entity_pickup_item"] = Event{name="entity_pickup_item", cancellable=true}
	events["item_despawn"] = Event{name="item_despawn", cancellable=true}
	events["vehicle_take_damage"] = Event{name="vehicle_take_damage", cancellable=true}
	events["block_fall"] = Event{name="block_fall", cancellable=true}
	events["entity_interact"] = Event{name="entity_interact", cancellable=true}
	events["dispenser_shear_sheep"] = Event{name="dispenser_shear_sheep", cancellable=true}
	events["sheep_regrow_wool"] = Event{name="sheep_regrow_wool", cancellable=true}
	events["witch_throw_potion"] = Event{name="witch_throw_potion", cancellable=true}
	events["entity_shot_bow"] = Event{name="entity_shot_bow", cancellable=true}
	events["entity_load_crossbow"] = Event{name="entity_load_crossbow", cancellable=true}
	events["piglin_barter"] = Event{name="piglin_barter", cancellable=true}
	events["goat_ram_entity"] = Event{name="goat_ram_entity", cancellable=true}
	events["entity_transform"] = Event{name="entity_transform", cancellable=true}
	events["world_start"] = Event{name="world_start", cancellable=false}
	events["world_stop"] = Event{name="world_stop", cancellable=false}
	events["time_skip"] = Event{name="time_skip", cancellable=true}
	events["world_web_response"] = Event{name="world_web_response", cancellable=false}
	events["block_ignite"] = Event{name="block_ignite", cancellable=false}
	events["block_burn"] = Event{name="block_burn", cancellable=true}
	events["block_fade"] = Event{name="block_fade", cancellable=true}
	events["tnt_prime"] = Event{name="tnt_prime", cancellable=true}
	events["block_explode"] = Event{name="block_explode", cancellable=true}
	events["entity_explode"] = Event{name="entity_explode", cancellable=true}
	events["entity_explosion"] = Event{name="entity_explosion", cancellable=true}
	events["block_piston_extend"] = Event{name="block_piston_extend", cancellable=true}
	events["block_piston_retract"] = Event{name="block_piston_retract", cancellable=true}
	events["leaves_decay"] = Event{name="leaves_decay", cancellable=true}
	events["structure_grow"] = Event{name="structure_grow", cancellable=true}
	events["block_grow"] = Event{name="block_grow", cancellable=true}
	events["block_flow"] = Event{name="block_flow", cancellable=true}
	events["block_fertilize"] = Event{name="block_fertilize", cancellable=true}
	events["redstone_level_change"] = Event{name="redstone_level_change", cancellable=false}
	events["brew_complete"] = Event{name="brew_complete", cancellable=true}
	events["block_form"] = Event{name="block_form", cancellable=true}
	events["block_spread"] = Event{name="block_spread", cancellable=true}
	events["block_form_by_entity"] = Event{name="block_form_by_entity", cancellable=true}
	events["portal_create"] = Event{name="portal_create", cancellable=true}
	events["bell_ring"] = Event{name="bell_ring", cancellable=true}
	events["entity_bell_ring"] = Event{name="entity_bell_ring", cancellable=true}
	events["note_play"] = Event{name="note_play", cancellable=true}
	events["dispenser_dispense_item"] = Event{name="dispenser_dispense_item", cancellable=true}
	events["dispenser_equip_armor"] = Event{name="dispenser_equip_armor", cancellable=true}
	events["fluid_level_change"] = Event{name="fluid_level_change", cancellable=true}
	events["sponge_absorb"] = Event{name="sponge_absorb", cancellable=true}
	events["sculk_bloom"] = Event{name="sculk_bloom", cancellable=true}
	events["falling_block_land"] = Event{name="falling_block_land", cancellable=true}
	events["item_moved_into_container"] = Event{name="item_moved_into_container", cancellable=true}
	events["hopper_pickup_item"] = Event{name="hopper_pickup_item", cancellable=true}
	events["furnace_smelt"] = Event{name="furnace_smelt", cancellable=true}
	events["furnace_start_smelt"] = Event{name="furnace_start_smelt", cancellable=false}
	events["furnace_burn"] = Event{name="furnace_burn", cancellable=true}
	events["player_combust"] = Event{name="player_combust", cancellable=true}
	events["world_dummy"] = Event{name="world_dummy", cancellable=false}
	events["player_equipment_changed"] = Event{name="player_equipment_changed", cancellable=false}
	events["entity_start_gliding"] = Event{name="entity_start_gliding", cancellable=true}
	events["entity_stop_gliding"] = Event{name="entity_stop_gliding", cancellable=true}
	events["fishing_hook_state_change"] = Event{name="fishing_hook_state_change", cancellable=true}
	events["player_prepare_item_enchant"] = Event{name="player_prepare_item_enchant", cancellable=true}
	events["player_anvil_rename_input"] = Event{name="player_anvil_rename_input", cancellable=false}
	events["vault_display_item"] = Event{name="vault_display_item", cancellable=true}
	events["player_vault_change_state"] = Event{name="player_vault_change_state", cancellable=true}
	events["player_item_cooldown"] = Event{name="player_item_cooldown", cancellable=true}
	events["player_close_advancements_menu"] = Event{name="player_close_advancements_menu", cancellable=false}
	events["player_custom_click"] = Event{name="player_custom_click", cancellable=false}
	events["player_open_advancements_tab"] = Event{name="player_open_advancements_tab", cancellable=true}
	events["entity_combust"] = Event{name="entity_combust", cancellable=true}
	events["crafter_craft"] = Event{name="crafter_craft", cancellable=true}
	events["player_item_mend"] = Event{name="player_item_mend", cancellable=false}
	events["player_knockback"] = Event{name="player_knockback", cancellable=true}
	events["player_location_change"] = Event{name="player_location_change", cancellable=true}
	events["entity_knockback"] = Event{name="entity_knockback", cancellable=true}
	events["vault_change_state"] = Event{name="vault_change_state", cancellable=true}
	events["player_start_gliding"] = Event{name="player_start_gliding", cancellable=true}
	events["player_prepare_result"] = Event{name="player_prepare_result", cancellable=true}
	events["item_merge"] = Event{name="item_merge", cancellable=true}
	events["entity_dummy"] = Event{name="entity_dummy", cancellable=false}
	events["player_rotate"] = Event{name="player_rotate", cancellable=true}
	events["moisture_change"] = Event{name="moisture_change", cancellable=true}
	events["entity_teleport"] = Event{name="entity_teleport", cancellable=true}
	events["entity_equipment_changed"] = Event{name="entity_equipment_changed", cancellable=false}
	events["player_dummy"] = Event{name="player_dummy", cancellable=false}
	events["player_ask_gamemode_change"] = Event{name="player_ask_gamemode_change", cancellable=true}
	events["player_stop_gliding"] = Event{name="player_stop_gliding", cancellable=true}
	events["player_sign_change"] = Event{name="player_sign_change", cancellable=true}
	events["player_velocity"] = Event{name="player_velocity", cancellable=true}
	events["player_input_event"] = Event{name="player_input_event", cancellable=false}
	events["player_item_group_cooldown"] = Event{name="player_item_group_cooldown", cancellable=true}
	events["player_pick_block"] = Event{name="player_pick_block", cancellable=true}
	events["world_web_exception"] = Event{name="world_web_exception", cancellable=false}
	events["player_enchant_item"] = Event{name="player_enchant_item", cancellable=true}
	events["player_pick_entity"] = Event{name="player_pick_entity", cancellable=true}
}

@(fini)
cleanup_events :: proc "contextless" () {
	context = runtime.default_context()
	delete(events)
}

event_native_from_mapped :: proc(event_name: string) -> (Event, bool) {
	return events[event_name]
}
