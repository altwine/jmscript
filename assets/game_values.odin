package assets

Game_Value :: struct {
	id: string,
	type: string,
}

game_values: map[string]Game_Value

init_game_values :: proc(allocator := context.allocator) {
	game_values = make(map[string]Game_Value, 139, allocator)
	game_values["current_health"] = {"current_health", "number"}
	game_values["max_health"] = {"max_health", "number"}
	game_values["absorption_health"] = {"absorption_health", "number"}
	game_values["food_level"] = {"food_level", "number"}
	game_values["food_saturation"] = {"food_saturation", "number"}
	game_values["food_exhaustion"] = {"food_exhaustion", "number"}
	game_values["attack_damage"] = {"attack_damage", "number"}
	game_values["attack_speed"] = {"attack_speed", "number"}
	game_values["attack_cooldown_ticks"] = {"attack_cooldown_ticks", "number"}
	game_values["attack_cooldown_strength"] = {"attack_cooldown_strength", "number"}
	game_values["armor_points"] = {"armor_points", "number"}
	game_values["armor_toughness"] = {"armor_toughness", "number"}
	game_values["invulnerability_ticks"] = {"invulnerability_ticks", "number"}
	game_values["experience_level"] = {"experience_level", "number"}
	game_values["experience_progress"] = {"experience_progress", "number"}
	game_values["fire_ticks"] = {"fire_ticks", "number"}
	game_values["freeze_ticks"] = {"freeze_ticks", "number"}
	game_values["remaining_air"] = {"remaining_air", "number"}
	game_values["fall_distance"] = {"fall_distance", "number"}
	game_values["held_slot"] = {"held_slot", "number"}
	game_values["walking_speed"] = {"walking_speed", "number"}
	game_values["flying_speed"] = {"flying_speed", "number"}
	game_values["ping"] = {"ping", "number"}
	game_values["protocol_version"] = {"protocol_version", "number"}
	game_values["item_usage_progress"] = {"item_usage_progress", "number"}
	game_values["entity_ticks_lived"] = {"entity_ticks_lived", "number"}
	game_values["arrows_in_body"] = {"arrows_in_body", "number"}
	game_values["age"] = {"age", "number"}
	game_values["steer_forward"] = {"steer_forward", "number"}
	game_values["steer_sideways"] = {"steer_sideways", "number"}
	game_values["merchant_recipe_count"] = {"merchant_recipe_count", "number"}
	game_values["open_inventory_size"] = {"open_inventory_size", "number"}
	game_values["entity_width_x"] = {"entity_width_x", "number"}
	game_values["entity_height"] = {"entity_height", "number"}
	game_values["entity_width_z"] = {"entity_width_z", "number"}
	game_values["location"] = {"location", "location"}
	game_values["target_block_location"] = {"target_block_location", "location"}
	game_values["target_fluid_location"] = {"target_fluid_location", "location"}
	game_values["target_block_face"] = {"target_block_face", "text"}
	game_values["eye_location"] = {"eye_location", "location"}
	game_values["x_coordinate"] = {"x_coordinate", "number"}
	game_values["y_coordinate"] = {"y_coordinate", "number"}
	game_values["z_coordinate"] = {"z_coordinate", "number"}
	game_values["pitch"] = {"pitch", "number"}
	game_values["yaw"] = {"yaw", "number"}
	game_values["direction_of_view"] = {"direction_of_view", "vector"}
	game_values["cardinal_direction"] = {"cardinal_direction", "text"}
	game_values["hitbox_midpoint_location"] = {"hitbox_midpoint_location", "location"}
	game_values["spawn_location"] = {"spawn_location", "location"}
	game_values["origin"] = {"origin", "location"}
	game_values["velocity"] = {"velocity", "vector"}
	game_values["body_yaw"] = {"body_yaw", "number"}
	game_values["block_beneath"] = {"block_beneath", "location"}
	game_values["blocks_beneath"] = {"blocks_beneath", "list"}
	game_values["main_hand_item"] = {"main_hand_item", "item"}
	game_values["off_hand_item"] = {"off_hand_item", "item"}
	game_values["armor_items"] = {"armor_items", "list"}
	game_values["hotbar_items"] = {"hotbar_items", "list"}
	game_values["inventory_items"] = {"inventory_items", "list"}
	game_values["custom_inventory_items"] = {"custom_inventory_items", "list"}
	game_values["cursor_item"] = {"cursor_item", "item"}
	game_values["saddle_item"] = {"saddle_item", "item"}
	game_values["entity_item"] = {"entity_item", "item"}
	game_values["name"] = {"name", "text"}
	game_values["uuid"] = {"uuid", "text"}
	game_values["display_name"] = {"display_name", "text"}
	game_values["entity_type"] = {"entity_type", "text"}
	game_values["client_brand_name"] = {"client_brand_name", "text"}
	game_values["user_locale"] = {"user_locale", "text"}
	game_values["open_inventory_title"] = {"open_inventory_title", "text"}
	game_values["open_inventory_type"] = {"open_inventory_type", "text"}
	game_values["gamemode"] = {"gamemode", "text"}
	game_values["last_damage_cause"] = {"last_damage_cause", "text"}
	game_values["potion_effects"] = {"potion_effects", "list"}
	game_values["vehicle"] = {"vehicle", "text"}
	game_values["passengers"] = {"passengers", "list"}
	game_values["lead_holder"] = {"lead_holder", "text"}
	game_values["attached_leads"] = {"attached_leads", "list"}
	game_values["targeted_entity"] = {"targeted_entity", "text"}
	game_values["spawn_reason"] = {"spawn_reason", "text"}
	game_values["main_hand"] = {"main_hand", "text"}
	game_values["event_block_location"] = {"event_block_location", "location"}
	game_values["event_block_face"] = {"event_block_face", "text"}
	game_values["event_blocks_involved"] = {"event_blocks_involved", "list"}
	game_values["event_interaction"] = {"event_interaction", "text"}
	game_values["event_new_location"] = {"event_new_location", "location"}
	game_values["event_damage"] = {"event_damage", "number"}
	game_values["event_damage_cause"] = {"event_damage_cause", "text"}
	game_values["event_chat_message"] = {"event_chat_message", "text"}
	game_values["event_message"] = {"event_message", "text"}
	game_values["event_heal_amount"] = {"event_heal_amount", "number"}
	game_values["event_heal_cause"] = {"event_heal_cause", "text"}
	game_values["event_exhaustion_amount"] = {"event_exhaustion_amount", "number"}
	game_values["event_exhaustion_reason"] = {"event_exhaustion_reason", "text"}
	game_values["event_new_potion_effect"] = {"event_new_potion_effect", "potion"}
	game_values["event_power"] = {"event_power", "number"}
	game_values["event_item"] = {"event_item", "item"}
	game_values["event_items"] = {"event_items", "list"}
	game_values["event_equipment_slot"] = {"event_equipment_slot", "text"}
	game_values["event_slot"] = {"event_slot", "number"}
	game_values["event_hotbar_slot"] = {"event_hotbar_slot", "number"}
	game_values["event_added_items"] = {"event_added_items", "dictionary"}
	game_values["event_slot_type"] = {"event_slot_type", "text"}
	game_values["event_close_inventory_cause"] = {"event_close_inventory_cause", "text"}
	game_values["event_inventory_click_type"] = {"event_inventory_click_type", "text"}
	game_values["event_inventory_action"] = {"event_inventory_action", "text"}
	game_values["event_drag_type"] = {"event_drag_type", "text"}
	game_values["event_slots_involved"] = {"event_slots_involved", "list"}
	game_values["event_fish_state"] = {"event_fish_state", "text"}
	game_values["event_tree_type"] = {"event_tree_type", "text"}
	game_values["event_experience"] = {"event_experience", "number"}
	game_values["event_hanging_break_cause"] = {"event_hanging_break_cause", "text"}
	game_values["event_time_skip_reason"] = {"event_time_skip_reason", "text"}
	game_values["event_time_skip_amount"] = {"event_time_skip_amount", "number"}
	game_values["event_food_level"] = {"event_food_level", "number"}
	game_values["event_projectile_item"] = {"event_projectile_item", "item"}
	game_values["event_teleport_cause"] = {"event_teleport_cause", "text"}
	game_values["event_ticks_held_for"] = {"event_ticks_held_for", "number"}
	game_values["event_query_info"] = {"event_query_info", "text"}
	game_values["event_fail_move_reason"] = {"event_fail_move_reason", "text"}
	game_values["event_transformed_entities"] = {"event_transformed_entities", "list"}
	game_values["event_transform_reason"] = {"event_transform_reason", "text"}
	game_values["event_replaced_block"] = {"event_replaced_block", "text"}
	game_values["player_count"] = {"player_count", "number"}
	game_values["cpu_usage"] = {"cpu_usage", "number"}
	game_values["server_tps"] = {"server_tps", "number"}
	game_values["timestamp"] = {"timestamp", "number"}
	game_values["server_current_tick"] = {"server_current_tick", "number"}
	game_values["selection_size"] = {"selection_size", "number"}
	game_values["selection_target_names"] = {"selection_target_names", "list"}
	game_values["selection_target_uuids"] = {"selection_target_uuids", "list"}
	game_values["url_response"] = {"url_response", "text"}
	game_values["url_response_code"] = {"url_response_code", "number"}
	game_values["url"] = {"url", "text"}
	game_values["world_time"] = {"world_time", "number"}
	game_values["world_weather"] = {"world_weather", "text"}
	game_values["owner_uuid"] = {"owner_uuid", "text"}
	game_values["world_size"] = {"world_size", "number"}
	game_values["world_id"] = {"world_id", "text"}
}

cleanup_game_values :: proc() {
	delete(game_values)
}

get_minecraft_game_value :: proc(game_value_name: string) -> (Game_Value, bool) {
	return game_values[game_value_name]
}
