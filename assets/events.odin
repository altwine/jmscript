package assets

import "base:runtime"

Event :: struct {
	name:        string,
	cancellable: bool,
}

events: map[string]Event

@(init)
init_events :: proc "contextless" () {
	context = runtime.default_context()
	events = make(map[string]Event, 186, context.allocator)
	events["player_join"] = {"player_join", false}
	events["player_quit"] = {"player_quit", false}
	events["player_rejoin"] = {"player_rejoin", true}
	events["player_chat"] = {"player_chat", true}
	events["player_interact"] = {"player_interact", true}
	events["player_right_click"] = {"player_right_click", true}
	events["player_left_click"] = {"player_left_click", true}
	events["player_place_block"] = {"player_place_block", true}
	events["player_break_block"] = {"player_break_block", true}
	events["block_damage"] = {"block_damage", true}
	events["block_damage_abort"] = {"block_damage_abort", false}
	events["player_structure_grow"] = {"player_structure_grow", true}
	events["player_query_block_info"] = {"player_query_block_info", true}
	events["player_arm_swing"] = {"player_arm_swing", true}
	events["player_right_click_entity"] = {"player_right_click_entity", true}
	events["player_right_click_player"] = {"player_right_click_player", true}
	events["player_imbue_potion_cloud"] = {"player_imbue_potion_cloud", true}
	events["player_pickup_projectile"] = {"player_pickup_projectile", true}
	events["player_pickup_experience"] = {"player_pickup_experience", true}
	events["player_tame_entity"] = {"player_tame_entity", true}
	events["player_leash_entity"] = {"player_leash_entity", true}
	events["player_start_spectating_entity"] = {"player_start_spectating_entity", true}
	events["player_stop_spectating_entity"] = {"player_stop_spectating_entity", true}
	events["player_query_entity_info"] = {"player_query_entity_info", true}
	events["player_open_inventory"] = {"player_open_inventory", true}
	events["player_click_inventory"] = {"player_click_inventory", true}
	events["player_drag_inventory"] = {"player_drag_inventory", true}
	events["player_click_own_inventory"] = {"player_click_own_inventory", true}
	events["player_craft_item"] = {"player_craft_item", true}
	events["player_close_inventory"] = {"player_close_inventory", false}
	events["player_swap_hands"] = {"player_swap_hands", true}
	events["player_change_slot"] = {"player_change_slot", true}
	events["player_pick_item"] = {"player_pick_item", true}
	events["player_furnace_extract"] = {"player_furnace_extract", false}
	events["player_shot_bow"] = {"player_shot_bow", true}
	events["player_launch_projectile"] = {"player_launch_projectile", true}
	events["player_pickup_item"] = {"player_pickup_item", true}
	events["player_drop_item"] = {"player_drop_item", true}
	events["player_consume_item"] = {"player_consume_item", true}
	events["player_break_item"] = {"player_break_item", false}
	events["player_stop_using_item"] = {"player_stop_using_item", false}
	events["player_edit_book"] = {"player_edit_book", true}
	events["player_fish"] = {"player_fish", true}
	events["player_move"] = {"player_move", true}
	events["player_fail_move"] = {"player_fail_move", false}
	events["player_load_crossbow"] = {"player_load_crossbow", true}
	events["player_jump"] = {"player_jump", true}
	events["player_sneak"] = {"player_sneak", true}
	events["player_unsneak"] = {"player_unsneak", true}
	events["player_teleport"] = {"player_teleport", true}
	events["player_start_sprint"] = {"player_start_sprint", true}
	events["player_stop_sprint"] = {"player_stop_sprint", true}
	events["player_start_flight"] = {"player_start_flight", true}
	events["player_stop_flight"] = {"player_stop_flight", true}
	events["player_riptide"] = {"player_riptide", true}
	events["player_dismount"] = {"player_dismount", true}
	events["player_horse_jump"] = {"player_horse_jump", true}
	events["player_vehicle_jump"] = {"player_vehicle_jump", false}
	events["player_vehicle_move"] = {"player_vehicle_move", false}
	events["player_take_damage"] = {"player_take_damage", true}
	events["player_damage_player"] = {"player_damage_player", true}
	events["entity_damage_player"] = {"entity_damage_player", true}
	events["player_damage_entity"] = {"player_damage_entity", true}
	events["player_resurrect"] = {"player_resurrect", true}
	events["player_heal"] = {"player_heal", true}
	events["player_food_level_change"] = {"player_food_level_change", true}
	events["player_exhaustion"] = {"player_exhaustion", true}
	events["player_projectile_hit"] = {"player_projectile_hit", true}
	events["projectile_damage_player"] = {"projectile_damage_player", true}
	events["player_pre_attack_entity"] = {"player_pre_attack_entity", true}
	events["elder_guardian_appears_at_player"] = {"elder_guardian_appears_at_player", true}
	events["player_death"] = {"player_death", true}
	events["player_kill_player"] = {"player_kill_player", true}
	events["player_kill_mob"] = {"player_kill_mob", true}
	events["mob_kill_player"] = {"mob_kill_player", true}
	events["player_respawn"] = {"player_respawn", false}
	events["entity_spawn"] = {"entity_spawn", true}
	events["entity_removed_from_world"] = {"entity_removed_from_world", false}
	events["entity_damage_entity"] = {"entity_damage_entity", true}
	events["entity_kill_entity"] = {"entity_kill_entity", true}
	events["entity_take_damage"] = {"entity_take_damage", true}
	events["entity_heal"] = {"entity_heal", true}
	events["entity_resurrect"] = {"entity_resurrect", true}
	events["entity_death"] = {"entity_death", true}
	events["entity_spell_cast"] = {"entity_spell_cast", true}
	events["enderman_escape"] = {"enderman_escape", true}
	events["enderman_attack_player"] = {"enderman_attack_player", true}
	events["firework_explode"] = {"firework_explode", true}
	events["hanging_break"] = {"hanging_break", true}
	events["projectile_launch"] = {"projectile_launch", true}
	events["projectile_damage_entity"] = {"projectile_damage_entity", true}
	events["projectile_kill_entity"] = {"projectile_kill_entity", true}
	events["projectile_hit"] = {"projectile_hit", true}
	events["projective_collide"] = {"projective_collide", true}
	events["entity_drop_item"] = {"entity_drop_item", true}
	events["entity_pickup_item"] = {"entity_pickup_item", true}
	events["item_despawn"] = {"item_despawn", true}
	events["vehicle_take_damage"] = {"vehicle_take_damage", true}
	events["block_fall"] = {"block_fall", true}
	events["entity_interact"] = {"entity_interact", true}
	events["dispenser_shear_sheep"] = {"dispenser_shear_sheep", true}
	events["sheep_regrow_wool"] = {"sheep_regrow_wool", true}
	events["witch_throw_potion"] = {"witch_throw_potion", true}
	events["entity_shot_bow"] = {"entity_shot_bow", true}
	events["entity_load_crossbow"] = {"entity_load_crossbow", true}
	events["piglin_barter"] = {"piglin_barter", true}
	events["goat_ram_entity"] = {"goat_ram_entity", true}
	events["entity_transform"] = {"entity_transform", true}
	events["world_start"] = {"world_start", false}
	events["world_stop"] = {"world_stop", false}
	events["time_skip"] = {"time_skip", true}
	events["world_web_response"] = {"world_web_response", false}
	events["block_ignite"] = {"block_ignite", false}
	events["block_burn"] = {"block_burn", true}
	events["block_fade"] = {"block_fade", true}
	events["tnt_prime"] = {"tnt_prime", true}
	events["block_explode"] = {"block_explode", true}
	events["entity_explode"] = {"entity_explode", true}
	events["entity_explosion"] = {"entity_explosion", true}
	events["block_piston_extend"] = {"block_piston_extend", true}
	events["block_piston_retract"] = {"block_piston_retract", true}
	events["leaves_decay"] = {"leaves_decay", true}
	events["structure_grow"] = {"structure_grow", true}
	events["block_grow"] = {"block_grow", true}
	events["block_flow"] = {"block_flow", true}
	events["block_fertilize"] = {"block_fertilize", true}
	events["redstone_level_change"] = {"redstone_level_change", false}
	events["brew_complete"] = {"brew_complete", true}
	events["block_form"] = {"block_form", true}
	events["block_spread"] = {"block_spread", true}
	events["block_form_by_entity"] = {"block_form_by_entity", true}
	events["portal_create"] = {"portal_create", true}
	events["bell_ring"] = {"bell_ring", true}
	events["entity_bell_ring"] = {"entity_bell_ring", true}
	events["note_play"] = {"note_play", true}
	events["dispenser_dispense_item"] = {"dispenser_dispense_item", true}
	events["dispenser_equip_armor"] = {"dispenser_equip_armor", true}
	events["fluid_level_change"] = {"fluid_level_change", true}
	events["sponge_absorb"] = {"sponge_absorb", true}
	events["sculk_bloom"] = {"sculk_bloom", true}
	events["falling_block_land"] = {"falling_block_land", true}
	events["item_moved_into_container"] = {"item_moved_into_container", true}
	events["hopper_pickup_item"] = {"hopper_pickup_item", true}
	events["furnace_smelt"] = {"furnace_smelt", true}
	events["furnace_start_smelt"] = {"furnace_start_smelt", false}
	events["furnace_burn"] = {"furnace_burn", true}
	events["player_input_event"] = {"player_input_event", false}
	events["player_rotate"] = {"player_rotate", true}
	events["entity_stop_gliding"] = {"entity_stop_gliding", true}
	events["player_item_cooldown"] = {"player_item_cooldown", true}
	events["world_dummy"] = {"world_dummy", false}
	events["fishing_hook_state_change"] = {"fishing_hook_state_change", true}
	events["player_combust"] = {"player_combust", true}
	events["vault_display_item"] = {"vault_display_item", true}
	events["entity_knockback"] = {"entity_knockback", true}
	events["entity_equipment_changed"] = {"entity_equipment_changed", false}
	events["player_stop_gliding"] = {"player_stop_gliding", true}
	events["player_sign_change"] = {"player_sign_change", true}
	events["crafter_craft"] = {"crafter_craft", true}
	events["player_knockback"] = {"player_knockback", true}
	events["entity_teleport"] = {"entity_teleport", true}
	events["player_item_group_cooldown"] = {"player_item_group_cooldown", true}
	events["player_custom_click"] = {"player_custom_click", false}
	events["entity_start_gliding"] = {"entity_start_gliding", true}
	events["entity_dummy"] = {"entity_dummy", false}
	events["player_pick_entity"] = {"player_pick_entity", true}
	events["player_anvil_rename_input"] = {"player_anvil_rename_input", false}
	events["moisture_change"] = {"moisture_change", true}
	events["player_prepare_result"] = {"player_prepare_result", true}
	events["item_merge"] = {"item_merge", true}
	events["player_dummy"] = {"player_dummy", false}
	events["player_ask_gamemode_change"] = {"player_ask_gamemode_change", true}
	events["player_prepare_item_enchant"] = {"player_prepare_item_enchant", true}
	events["player_vault_change_state"] = {"player_vault_change_state", true}
	events["player_item_mend"] = {"player_item_mend", false}
	events["world_web_exception"] = {"world_web_exception", false}
	events["player_open_advancements_tab"] = {"player_open_advancements_tab", true}
	events["player_velocity"] = {"player_velocity", true}
	events["player_pick_block"] = {"player_pick_block", true}
	events["player_equipment_changed"] = {"player_equipment_changed", false}
	events["vault_change_state"] = {"vault_change_state", true}
	events["player_location_change"] = {"player_location_change", true}
	events["player_close_advancements_menu"] = {"player_close_advancements_menu", false}
	events["player_enchant_item"] = {"player_enchant_item", true}
	events["entity_combust"] = {"entity_combust", true}
	events["player_start_gliding"] = {"player_start_gliding", true}
}

@(fini)
cleanup_events :: proc "contextless" () {
	context = runtime.default_context()
	delete(events)
}

event_native_from_mapped :: proc(event_name: string) -> (Event, bool) {
	return events[event_name]
}
