package assets

Event :: struct {
	name: string,
	cancellable: bool,
}

event_native_from_mapped :: proc(event_name: string) -> (Event, bool) {
	switch event_name {
	case "bell_ring":
		return Event{name="bell_ring", cancellable=true}, true
	case "block_burn":
		return Event{name="block_burn", cancellable=true}, true
	case "block_damage":
		return Event{name="block_damage", cancellable=true}, true
	case "block_damage_abort":
		return Event{name="block_damage_abort", cancellable=false}, true
	case "block_explode":
		return Event{name="block_explode", cancellable=true}, true
	case "block_fade":
		return Event{name="block_fade", cancellable=true}, true
	case "block_fall":
		return Event{name="block_fall", cancellable=true}, true
	case "block_fertilize":
		return Event{name="block_fertilize", cancellable=true}, true
	case "block_flow":
		return Event{name="block_flow", cancellable=true}, true
	case "block_form":
		return Event{name="block_form", cancellable=true}, true
	case "block_form_by_entity":
		return Event{name="block_form_by_entity", cancellable=true}, true
	case "block_grow":
		return Event{name="block_grow", cancellable=true}, true
	case "block_ignite":
		return Event{name="block_ignite", cancellable=false}, true
	case "block_piston_extend":
		return Event{name="block_piston_extend", cancellable=true}, true
	case "block_piston_retract":
		return Event{name="block_piston_retract", cancellable=true}, true
	case "block_spread":
		return Event{name="block_spread", cancellable=true}, true
	case "brew_complete":
		return Event{name="brew_complete", cancellable=true}, true
	case "crafter_craft":
		return Event{name="crafter_craft", cancellable=true}, true
	case "dispenser_dispense_item":
		return Event{name="dispenser_dispense_item", cancellable=true}, true
	case "dispenser_equip_armor":
		return Event{name="dispenser_equip_armor", cancellable=true}, true
	case "dispenser_shear_sheep":
		return Event{name="dispenser_shear_sheep", cancellable=true}, true
	case "elder_guardian_appears_at_player":
		return Event{name="elder_guardian_appears_at_player", cancellable=true}, true
	case "enderman_attack_player":
		return Event{name="enderman_attack_player", cancellable=true}, true
	case "enderman_escape":
		return Event{name="enderman_escape", cancellable=true}, true
	case "entity_bell_ring":
		return Event{name="entity_bell_ring", cancellable=true}, true
	case "entity_combust":
		return Event{name="entity_combust", cancellable=true}, true
	case "entity_damage_entity":
		return Event{name="entity_damage_entity", cancellable=true}, true
	case "entity_damage_player":
		return Event{name="entity_damage_player", cancellable=true}, true
	case "entity_death":
		return Event{name="entity_death", cancellable=true}, true
	case "entity_drop_item":
		return Event{name="entity_drop_item", cancellable=true}, true
	case "entity_dummy":
		return Event{name="entity_dummy", cancellable=false}, true
	case "entity_equipment_changed":
		return Event{name="entity_equipment_changed", cancellable=false}, true
	case "entity_explode":
		return Event{name="entity_explode", cancellable=true}, true
	case "entity_explosion":
		return Event{name="entity_explosion", cancellable=true}, true
	case "entity_heal":
		return Event{name="entity_heal", cancellable=true}, true
	case "entity_interact":
		return Event{name="entity_interact", cancellable=true}, true
	case "entity_kill_entity":
		return Event{name="entity_kill_entity", cancellable=true}, true
	case "entity_knockback":
		return Event{name="entity_knockback", cancellable=true}, true
	case "entity_load_crossbow":
		return Event{name="entity_load_crossbow", cancellable=true}, true
	case "entity_pickup_item":
		return Event{name="entity_pickup_item", cancellable=true}, true
	case "entity_removed_from_world":
		return Event{name="entity_removed_from_world", cancellable=false}, true
	case "entity_resurrect":
		return Event{name="entity_resurrect", cancellable=true}, true
	case "entity_shot_bow":
		return Event{name="entity_shot_bow", cancellable=true}, true
	case "entity_spawn":
		return Event{name="entity_spawn", cancellable=true}, true
	case "entity_spell_cast":
		return Event{name="entity_spell_cast", cancellable=true}, true
	case "entity_start_gliding":
		return Event{name="entity_start_gliding", cancellable=true}, true
	case "entity_stop_gliding":
		return Event{name="entity_stop_gliding", cancellable=true}, true
	case "entity_take_damage":
		return Event{name="entity_take_damage", cancellable=true}, true
	case "entity_teleport":
		return Event{name="entity_teleport", cancellable=true}, true
	case "entity_transform":
		return Event{name="entity_transform", cancellable=true}, true
	case "falling_block_land":
		return Event{name="falling_block_land", cancellable=true}, true
	case "firework_explode":
		return Event{name="firework_explode", cancellable=true}, true
	case "fishing_hook_state_change":
		return Event{name="fishing_hook_state_change", cancellable=true}, true
	case "fluid_level_change":
		return Event{name="fluid_level_change", cancellable=true}, true
	case "furnace_burn":
		return Event{name="furnace_burn", cancellable=true}, true
	case "furnace_smelt":
		return Event{name="furnace_smelt", cancellable=true}, true
	case "furnace_start_smelt":
		return Event{name="furnace_start_smelt", cancellable=false}, true
	case "goat_ram_entity":
		return Event{name="goat_ram_entity", cancellable=true}, true
	case "hanging_break":
		return Event{name="hanging_break", cancellable=true}, true
	case "hopper_pickup_item":
		return Event{name="hopper_pickup_item", cancellable=true}, true
	case "item_despawn":
		return Event{name="item_despawn", cancellable=true}, true
	case "item_merge":
		return Event{name="item_merge", cancellable=true}, true
	case "item_moved_into_container":
		return Event{name="item_moved_into_container", cancellable=true}, true
	case "leaves_decay":
		return Event{name="leaves_decay", cancellable=true}, true
	case "mob_kill_player":
		return Event{name="mob_kill_player", cancellable=true}, true
	case "moisture_change":
		return Event{name="moisture_change", cancellable=true}, true
	case "note_play":
		return Event{name="note_play", cancellable=true}, true
	case "piglin_barter":
		return Event{name="piglin_barter", cancellable=true}, true
	case "player_anvil_rename_input":
		return Event{name="player_anvil_rename_input", cancellable=false}, true
	case "player_arm_swing":
		return Event{name="player_arm_swing", cancellable=true}, true
	case "player_ask_gamemode_change":
		return Event{name="player_ask_gamemode_change", cancellable=true}, true
	case "player_break_block":
		return Event{name="player_break_block", cancellable=true}, true
	case "player_break_item":
		return Event{name="player_break_item", cancellable=false}, true
	case "player_change_slot":
		return Event{name="player_change_slot", cancellable=true}, true
	case "player_chat":
		return Event{name="player_chat", cancellable=true}, true
	case "player_click_inventory":
		return Event{name="player_click_inventory", cancellable=true}, true
	case "player_click_own_inventory":
		return Event{name="player_click_own_inventory", cancellable=true}, true
	case "player_close_advancements_menu":
		return Event{name="player_close_advancements_menu", cancellable=false}, true
	case "player_close_inventory":
		return Event{name="player_close_inventory", cancellable=false}, true
	case "player_combust":
		return Event{name="player_combust", cancellable=true}, true
	case "player_consume_item":
		return Event{name="player_consume_item", cancellable=true}, true
	case "player_craft_item":
		return Event{name="player_craft_item", cancellable=true}, true
	case "player_custom_click":
		return Event{name="player_custom_click", cancellable=false}, true
	case "player_damage_entity":
		return Event{name="player_damage_entity", cancellable=true}, true
	case "player_damage_player":
		return Event{name="player_damage_player", cancellable=true}, true
	case "player_death":
		return Event{name="player_death", cancellable=true}, true
	case "player_dismount":
		return Event{name="player_dismount", cancellable=true}, true
	case "player_drag_inventory":
		return Event{name="player_drag_inventory", cancellable=true}, true
	case "player_drop_item":
		return Event{name="player_drop_item", cancellable=true}, true
	case "player_dummy":
		return Event{name="player_dummy", cancellable=false}, true
	case "player_edit_book":
		return Event{name="player_edit_book", cancellable=true}, true
	case "player_enchant_item":
		return Event{name="player_enchant_item", cancellable=true}, true
	case "player_equipment_changed":
		return Event{name="player_equipment_changed", cancellable=false}, true
	case "player_exhaustion":
		return Event{name="player_exhaustion", cancellable=true}, true
	case "player_fail_move":
		return Event{name="player_fail_move", cancellable=false}, true
	case "player_fish":
		return Event{name="player_fish", cancellable=true}, true
	case "player_food_level_change":
		return Event{name="player_food_level_change", cancellable=true}, true
	case "player_furnace_extract":
		return Event{name="player_furnace_extract", cancellable=false}, true
	case "player_heal":
		return Event{name="player_heal", cancellable=true}, true
	case "player_horse_jump":
		return Event{name="player_horse_jump", cancellable=true}, true
	case "player_imbue_potion_cloud":
		return Event{name="player_imbue_potion_cloud", cancellable=true}, true
	case "player_input_event":
		return Event{name="player_input_event", cancellable=false}, true
	case "player_interact":
		return Event{name="player_interact", cancellable=true}, true
	case "player_item_cooldown":
		return Event{name="player_item_cooldown", cancellable=true}, true
	case "player_item_group_cooldown":
		return Event{name="player_item_group_cooldown", cancellable=true}, true
	case "player_item_mend":
		return Event{name="player_item_mend", cancellable=false}, true
	case "player_join":
		return Event{name="player_join", cancellable=false}, true
	case "player_jump":
		return Event{name="player_jump", cancellable=true}, true
	case "player_kill_mob":
		return Event{name="player_kill_mob", cancellable=true}, true
	case "player_kill_player":
		return Event{name="player_kill_player", cancellable=true}, true
	case "player_knockback":
		return Event{name="player_knockback", cancellable=true}, true
	case "player_launch_projectile":
		return Event{name="player_launch_projectile", cancellable=true}, true
	case "player_leash_entity":
		return Event{name="player_leash_entity", cancellable=true}, true
	case "player_left_click":
		return Event{name="player_left_click", cancellable=true}, true
	case "player_load_crossbow":
		return Event{name="player_load_crossbow", cancellable=true}, true
	case "player_location_change":
		return Event{name="player_location_change", cancellable=true}, true
	case "player_move":
		return Event{name="player_move", cancellable=true}, true
	case "player_open_advancements_tab":
		return Event{name="player_open_advancements_tab", cancellable=true}, true
	case "player_open_inventory":
		return Event{name="player_open_inventory", cancellable=true}, true
	case "player_pickup_experience":
		return Event{name="player_pickup_experience", cancellable=true}, true
	case "player_pickup_item":
		return Event{name="player_pickup_item", cancellable=true}, true
	case "player_pickup_projectile":
		return Event{name="player_pickup_projectile", cancellable=true}, true
	case "player_pick_block":
		return Event{name="player_pick_block", cancellable=false}, true
	case "player_pick_entity":
		return Event{name="player_pick_entity", cancellable=true}, true
	case "player_pick_item":
		return Event{name="player_pick_item", cancellable=true}, true
	case "player_place_block":
		return Event{name="player_place_block", cancellable=true}, true
	case "player_prepare_item_enchant":
		return Event{name="player_prepare_item_enchant", cancellable=true}, true
	case "player_prepare_result":
		return Event{name="player_prepare_result", cancellable=true}, true
	case "player_pre_attack_entity":
		return Event{name="player_pre_attack_entity", cancellable=true}, true
	case "player_projectile_hit":
		return Event{name="player_projectile_hit", cancellable=true}, true
	case "player_query_block_info":
		return Event{name="player_query_block_info", cancellable=true}, true
	case "player_query_entity_info":
		return Event{name="player_query_entity_info", cancellable=true}, true
	case "player_quit":
		return Event{name="player_quit", cancellable=false}, true
	case "player_rejoin":
		return Event{name="player_rejoin", cancellable=true}, true
	case "player_respawn":
		return Event{name="player_respawn", cancellable=false}, true
	case "player_resurrect":
		return Event{name="player_resurrect", cancellable=true}, true
	case "player_right_click":
		return Event{name="player_right_click", cancellable=true}, true
	case "player_right_click_entity":
		return Event{name="player_right_click_entity", cancellable=true}, true
	case "player_right_click_player":
		return Event{name="player_right_click_player", cancellable=true}, true
	case "player_riptide":
		return Event{name="player_riptide", cancellable=true}, true
	case "player_rotate":
		return Event{name="player_rotate", cancellable=true}, true
	case "player_shot_bow":
		return Event{name="player_shot_bow", cancellable=true}, true
	case "player_sign_change":
		return Event{name="player_sign_change", cancellable=true}, true
	case "player_sneak":
		return Event{name="player_sneak", cancellable=true}, true
	case "player_start_flight":
		return Event{name="player_start_flight", cancellable=true}, true
	case "player_start_gliding":
		return Event{name="player_start_gliding", cancellable=true}, true
	case "player_start_spectating_entity":
		return Event{name="player_start_spectating_entity", cancellable=true}, true
	case "player_start_sprint":
		return Event{name="player_start_sprint", cancellable=true}, true
	case "player_stop_flight":
		return Event{name="player_stop_flight", cancellable=true}, true
	case "player_stop_gliding":
		return Event{name="player_stop_gliding", cancellable=true}, true
	case "player_stop_spectating_entity":
		return Event{name="player_stop_spectating_entity", cancellable=true}, true
	case "player_stop_sprint":
		return Event{name="player_stop_sprint", cancellable=true}, true
	case "player_stop_using_item":
		return Event{name="player_stop_using_item", cancellable=false}, true
	case "player_structure_grow":
		return Event{name="player_structure_grow", cancellable=true}, true
	case "player_swap_hands":
		return Event{name="player_swap_hands", cancellable=true}, true
	case "player_take_damage":
		return Event{name="player_take_damage", cancellable=true}, true
	case "player_tame_entity":
		return Event{name="player_tame_entity", cancellable=true}, true
	case "player_teleport":
		return Event{name="player_teleport", cancellable=true}, true
	case "player_unsneak":
		return Event{name="player_unsneak", cancellable=true}, true
	case "player_vault_change_state":
		return Event{name="player_vault_change_state", cancellable=true}, true
	case "player_vehicle_jump":
		return Event{name="player_vehicle_jump", cancellable=false}, true
	case "player_vehicle_move":
		return Event{name="player_vehicle_move", cancellable=false}, true
	case "player_velocity":
		return Event{name="player_velocity", cancellable=true}, true
	case "portal_create":
		return Event{name="portal_create", cancellable=true}, true
	case "projectile_damage_entity":
		return Event{name="projectile_damage_entity", cancellable=true}, true
	case "projectile_damage_player":
		return Event{name="projectile_damage_player", cancellable=true}, true
	case "projectile_hit":
		return Event{name="projectile_hit", cancellable=true}, true
	case "projectile_kill_entity":
		return Event{name="projectile_kill_entity", cancellable=true}, true
	case "projectile_launch":
		return Event{name="projectile_launch", cancellable=true}, true
	case "projective_collide":
		return Event{name="projective_collide", cancellable=true}, true
	case "redstone_level_change":
		return Event{name="redstone_level_change", cancellable=false}, true
	case "sculk_bloom":
		return Event{name="sculk_bloom", cancellable=true}, true
	case "sheep_regrow_wool":
		return Event{name="sheep_regrow_wool", cancellable=true}, true
	case "sponge_absorb":
		return Event{name="sponge_absorb", cancellable=true}, true
	case "structure_grow":
		return Event{name="structure_grow", cancellable=true}, true
	case "time_skip":
		return Event{name="time_skip", cancellable=true}, true
	case "tnt_prime":
		return Event{name="tnt_prime", cancellable=true}, true
	case "vault_change_state":
		return Event{name="vault_change_state", cancellable=true}, true
	case "vault_display_item":
		return Event{name="vault_display_item", cancellable=true}, true
	case "vehicle_take_damage":
		return Event{name="vehicle_take_damage", cancellable=true}, true
	case "witch_throw_potion":
		return Event{name="witch_throw_potion", cancellable=true}, true
	case "world_dummy":
		return Event{name="world_dummy", cancellable=false}, true
	case "world_start":
		return Event{name="world_start", cancellable=false}, true
	case "world_stop":
		return Event{name="world_stop", cancellable=false}, true
	case "world_web_exception":
		return Event{name="world_web_exception", cancellable=false}, true
	case "world_web_response":
		return Event{name="world_web_response", cancellable=false}, true
	case:
		return Event{}, false
	}
}
