#+feature dynamic-literals
package assets

import "base:runtime"

Action :: struct {
	name: string,
	in_slots: []string,
	out_slots: []string,
	accept_selector: bool,
	type: Action_Type,
	slots: []Slot,
}

Action_Type :: enum {
	BASIC,
	CONTAINER,
	BASIC_WITH_CONDITIONAL,
	CONTAINER_WITH_CONDITIONAL,
}

Slot :: struct {
	name: string,
	type: string,
	_enum: []string,
}

actions: map[string]Action

@(init)
init_actions :: proc "contextless" () {
	context = runtime.default_context()
	actions = make(map[string]Action, 814, context.allocator)
	actions["call_function"] = Action{
		"call_function",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"function_name", "text", nil},
		},
	}
	actions["control_call_exception"] = Action{
		"control_call_exception",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"id", "text", nil},
			Slot{"message", "text", nil},
			Slot{"type", "enum", {"WARNING", "ERROR", "FATAL"}},
		},
	}
	actions["control_end_thread"] = Action{
		"control_end_thread",
		nil,
		nil,
		false,
		.BASIC,
		nil,
	}
	actions["controller_async_run"] = Action{
		"controller_async_run",
		nil,
		nil,
		false,
		.CONTAINER,
		nil,
	}
	actions["controller_exception"] = Action{
		"controller_exception",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"exception_type", "enum", {"WARNING", "ERROR"}},
		},
	}
	actions["controller_measure_time"] = Action{
		"controller_measure_time",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"duration", "enum", {"NANOSECONDS", "MICROSECONDS", "MILLISECONDS"}},
		},
	}
	actions["control_return_function"] = Action{
		"control_return_function",
		nil,
		nil,
		false,
		.BASIC,
		nil,
	}
	actions["control_skip_iteration"] = Action{
		"control_skip_iteration",
		nil,
		nil,
		false,
		.BASIC,
		nil,
	}
	actions["control_stop_repeat"] = Action{
		"control_stop_repeat",
		nil,
		nil,
		false,
		.BASIC,
		nil,
	}
	actions["control_wait"] = Action{
		"control_wait",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"duration", "number", nil},
			Slot{"time_unit", "enum", {"TICKS", "SECONDS", "MINUTES"}},
		},
	}
	actions["entity_attach_lead"] = Action{
		"entity_attach_lead",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"name_or_uuid", "text", nil},
			Slot{"location", "location", nil},
		},
	}
	actions["entity_clear_merchant_recipes"] = Action{
		"entity_clear_merchant_recipes",
		nil,
		nil,
		false,
		.BASIC,
		nil,
	}
	actions["entity_celar_potion_effects"] = Action{
		"entity_celar_potion_effects",
		nil,
		nil,
		false,
		.BASIC,
		nil,
	}
	actions["entity_damage"] = Action{
		"entity_damage",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"damage", "number", nil},
			Slot{"source", "text", nil},
		},
	}
	actions["entity_disguise_as_block"] = Action{
		"entity_disguise_as_block",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"block", "block", nil},
		},
	}
	actions["entity_disguise_as_entity"] = Action{
		"entity_disguise_as_entity",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"entity_type", "item", nil},
		},
	}
	actions["entity_disguise_as_item"] = Action{
		"entity_disguise_as_item",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"item", "item", nil},
		},
	}
	actions["entity_disguise_as_player"] = Action{
		"entity_disguise_as_player",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"name_or_uuid", "text", nil},
			Slot{"display_name", "text", nil},
			Slot{"server_type", "enum", {"MOJANG", "SERVER"}},
		},
	}
	actions["entity_eat_grass"] = Action{
		"entity_eat_grass",
		nil,
		nil,
		false,
		.BASIC,
		nil,
	}
	actions["entity_eat_target"] = Action{
		"entity_eat_target",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"name_or_uuid", "text", nil},
		},
	}
	actions["entity_explode"] = Action{
		"entity_explode",
		nil,
		nil,
		false,
		.BASIC,
		nil,
	}
	actions["entity_face_location"] = Action{
		"entity_face_location",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"location", "location", nil},
		},
	}
	actions["entity_get_custom_tag"] = Action{
		"entity_get_custom_tag",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"name", "text", nil},
			Slot{"default", "any", nil},
		},
	}
	actions["entity_give_potion_effects"] = Action{
		"entity_give_potion_effects",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"potions", "potion", nil},
			Slot{"overwrite", "enum", {"TRUE", "FALSE"}},
			Slot{"show_icon", "enum", {"TRUE", "FALSE"}},
			Slot{"particle_mode", "enum", {"REGULAR", "AMBIENT", "NONE"}},
		},
	}
	actions["entity_heal"] = Action{
		"entity_heal",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"heal", "number", nil},
		},
	}
	actions["entity_ignite_creeper"] = Action{
		"entity_ignite_creeper",
		nil,
		nil,
		false,
		.BASIC,
		nil,
	}
	actions["entity_jump"] = Action{
		"entity_jump",
		nil,
		nil,
		false,
		.BASIC,
		nil,
	}
	actions["entity_launch_forward"] = Action{
		"entity_launch_forward",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"power", "number", nil},
			Slot{"increment", "enum", {"TRUE", "FALSE"}},
			Slot{"launch_axis", "enum", {"YAW_AND_PITCH", "YAW"}},
		},
	}
	actions["entity_launch_projectile"] = Action{
		"entity_launch_projectile",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"projectile", "item", nil},
			Slot{"location", "location", nil},
			Slot{"name", "text", nil},
			Slot{"speed", "number", nil},
			Slot{"inaccuracy", "number", nil},
			Slot{"trail", "particle", nil},
		},
	}
	actions["entity_launch_to_location"] = Action{
		"entity_launch_to_location",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"location", "location", nil},
			Slot{"power", "number", nil},
			Slot{"increment", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["entity_launch_up"] = Action{
		"entity_launch_up",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"power", "number", nil},
			Slot{"increment", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["entity_modify_piglin_barter_materials"] = Action{
		"entity_modify_piglin_barter_materials",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"materials", "item", nil},
			Slot{"modification_mode", "enum", {"ADD", "REMOVE"}},
		},
	}
	actions["entity_modify_piglin_interested_materials"] = Action{
		"entity_modify_piglin_interested_materials",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"materials", "item", nil},
			Slot{"modification_mode", "enum", {"ADD", "REMOVE"}},
		},
	}
	actions["entity_move_to_location"] = Action{
		"entity_move_to_location",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"location", "location", nil},
			Slot{"speed", "number", nil},
		},
	}
	actions["entity_move_to_location_stop"] = Action{
		"entity_move_to_location_stop",
		nil,
		nil,
		false,
		.BASIC,
		nil,
	}
	actions["entity_play_damage_animation"] = Action{
		"entity_play_damage_animation",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"damage_type", "enum", {"DAMAGE", "CRITICAL_DAMAGE", "MAGICAL_DAMAGE"}},
		},
	}
	actions["entity_play_hurt_animation"] = Action{
		"entity_play_hurt_animation",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"yaw", "number", nil},
		},
	}
	actions["entity_ram_target"] = Action{
		"entity_ram_target",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"name_or_uuid", "text", nil},
		},
	}
	actions["entity_remove"] = Action{
		"entity_remove",
		nil,
		nil,
		false,
		.BASIC,
		nil,
	}
	actions["entity_remove_custom_tag"] = Action{
		"entity_remove_custom_tag",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"name", "text", nil},
		},
	}
	actions["entity_remove_disguise"] = Action{
		"entity_remove_disguise",
		nil,
		nil,
		false,
		.BASIC,
		nil,
	}
	actions["entity_remove_merchant_recipe"] = Action{
		"entity_remove_merchant_recipe",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"recipe_index", "number", nil},
		},
	}
	actions["entity_remove_potion_effect"] = Action{
		"entity_remove_potion_effect",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"effects", "potion", nil},
		},
	}
	actions["entity_reset_display_brightness"] = Action{
		"entity_reset_display_brightness",
		nil,
		nil,
		false,
		.BASIC,
		nil,
	}
	actions["entity_reset_display_glow_color"] = Action{
		"entity_reset_display_glow_color",
		nil,
		nil,
		false,
		.BASIC,
		nil,
	}
	actions["entity_reset_text_display_background"] = Action{
		"entity_reset_text_display_background",
		nil,
		nil,
		false,
		.BASIC,
		nil,
	}
	actions["entity_ride_entity"] = Action{
		"entity_ride_entity",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"name_or_uuid", "text", nil},
		},
	}
	actions["entity_set_absorption_health"] = Action{
		"entity_set_absorption_health",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"health", "number", nil},
		},
	}
	actions["entity_set_ai"] = Action{
		"entity_set_ai",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"ai", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["entity_set_allay_dancing"] = Action{
		"entity_set_allay_dancing",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"dance", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["entity_set_angry"] = Action{
		"entity_set_angry",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"angry", "enum", {"TRUE", "FALSE"}},
			Slot{"target", "text", nil},
		},
	}
	actions["entity_set_animal_age"] = Action{
		"entity_set_animal_age",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"age", "number", nil},
			Slot{"lock", "enum", {"ENABLE", "DISABLE", "DONT_CHANGE"}},
		},
	}
	actions["entity_set_armor_items"] = Action{
		"entity_set_armor_items",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"helmet", "item", nil},
			Slot{"chestplate", "item", nil},
			Slot{"leggings", "item", nil},
			Slot{"boots", "item", nil},
		},
	}
	actions["entity_set_armor_stand_parts"] = Action{
		"entity_set_armor_stand_parts",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"arms", "enum", {"ENABLE", "DISABLE", "DONT_CHANGE"}},
			Slot{"base_plate", "enum", {"ENABLE", "DISABLE", "DONT_CHANGE"}},
		},
	}
	actions["entity_set_armor_stand_pose"] = Action{
		"entity_set_armor_stand_pose",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"x_rotation", "number", nil},
			Slot{"y_rotation", "number", nil},
			Slot{"z_rotation", "number", nil},
			Slot{"body_part", "enum", {"HEAD", "BODY", "LEFT_ARM", "RIGHT_ARM", "LEFT_LEG", "RIGHT_LEG"}},
		},
	}
	actions["entity_set_attribute"] = Action{
		"entity_set_attribute",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"value", "number", nil},
			Slot{"attribute_type", "enum", {}},
		},
	}
	actions["entity_set_aware"] = Action{
		"entity_set_aware",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"aware", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["entity_set_axolotl_type"] = Action{
		"entity_set_axolotl_type",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"axolotl_type", "enum", {"BLUE", "CYAN", "GOLD", "LUCY", "WILD"}},
		},
	}
	actions["entity_set_baby"] = Action{
		"entity_set_baby",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"baby", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["entity_set_bee_nectar"] = Action{
		"entity_set_bee_nectar",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"nectar", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["entity_set_block_display_block"] = Action{
		"entity_set_block_display_block",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"displayed_block", "block", nil},
		},
	}
	actions["entity_set_camel_dashing"] = Action{
		"entity_set_camel_dashing",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"dashing", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["entity_set_carrying_chest"] = Action{
		"entity_set_carrying_chest",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"carrying", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["entity_set_cat_lying_down"] = Action{
		"entity_set_cat_lying_down",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"lying_down", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["entity_set_cat_type"] = Action{
		"entity_set_cat_type",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"cat_type", "enum", {"ALL_BLACK", "BLACK", "BRITISH_SHORTHAIR", "CALICO", "JELLIE", "PERSIAN", "RAGDOLL", "RED", "SIAMESE", "TABBY", "WHITE"}},
		},
	}
	actions["entity_set_celebrating"] = Action{
		"entity_set_celebrating",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"celebrating", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["entity_set_collidable"] = Action{
		"entity_set_collidable",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"collidable", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["entity_set_creeper_charge"] = Action{
		"entity_set_creeper_charge",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"charged", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["entity_set_creeper_fuse"] = Action{
		"entity_set_creeper_fuse",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"fuse_ticks", "number", nil},
		},
	}
	actions["entity_set_current_health"] = Action{
		"entity_set_current_health",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"health", "number", nil},
		},
	}
	actions["entity_set_custom_name"] = Action{
		"entity_set_custom_name",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"custom_name", "text", nil},
		},
	}
	actions["entity_set_custom_name_visibility"] = Action{
		"entity_set_custom_name_visibility",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"visibility", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["entity_set_custom_tag"] = Action{
		"entity_set_custom_tag",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"name", "text", nil},
			Slot{"value", "text", nil},
		},
	}
	actions["entity_set_death_drops"] = Action{
		"entity_set_death_drops",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"drops", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["entity_set_death_time"] = Action{
		"entity_set_death_time",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"death_time", "number", nil},
		},
	}
	actions["entity_set_despawning"] = Action{
		"entity_set_despawning",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"despawning", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["entity_set_display_billboard"] = Action{
		"entity_set_display_billboard",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"billboard_type", "enum", {"CENTER", "FIXED", "HORIZONTAL", "VERTICAL"}},
		},
	}
	actions["entity_set_display_brightness"] = Action{
		"entity_set_display_brightness",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"block_light_level", "number", nil},
			Slot{"sky_light_level", "number", nil},
		},
	}
	actions["entity_set_display_culling_suze"] = Action{
		"entity_set_display_culling_suze",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"width", "number", nil},
			Slot{"height", "number", nil},
		},
	}
	actions["entity_set_display_glow_color"] = Action{
		"entity_set_display_glow_color",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"color_hexadecimal", "text", nil},
		},
	}
	actions["entity_set_display_interpolation"] = Action{
		"entity_set_display_interpolation",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"interpolation_duration", "number", nil},
			Slot{"interpolation_delay", "number", nil},
		},
	}
	actions["entity_set_display_rotation_from_axis_angle"] = Action{
		"entity_set_display_rotation_from_axis_angle",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"axis_vector", "vector", nil},
			Slot{"angle", "number", nil},
			Slot{"mode", "enum", {"SET", "ADD"}},
			Slot{"input", "enum", {"DEGREES", "RADIANS"}},
			Slot{"rotation", "enum", {"LEFT_ROTATION", "RIGHT_ROTATION"}},
		},
	}
	actions["entity_set_display_rotation_from_euler_angles"] = Action{
		"entity_set_display_rotation_from_euler_angles",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"pitch", "number", nil},
			Slot{"yaw", "number", nil},
			Slot{"roll", "number", nil},
			Slot{"mode", "enum", {"SET", "ADD"}},
			Slot{"input", "enum", {"DEGREES", "RADIANS"}},
			Slot{"rotation", "enum", {"LEFT_ROTATION", "RIGHT_ROTATION"}},
		},
	}
	actions["entity_set_display_scale"] = Action{
		"entity_set_display_scale",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"scale_vector", "vector", nil},
			Slot{"mode", "enum", {"SET", "ADD"}},
		},
	}
	actions["entity_set_display_shadow"] = Action{
		"entity_set_display_shadow",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"shadow_radius", "number", nil},
			Slot{"shadow_opacity_percentage", "number", nil},
		},
	}
	actions["entity_set_display_teleport_duration"] = Action{
		"entity_set_display_teleport_duration",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"duration", "number", nil},
		},
	}
	actions["entity_set_display_transformation_matrix"] = Action{
		"entity_set_display_transformation_matrix",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"row_major_matrix", "number", nil},
		},
	}
	actions["entity_set_display_translation"] = Action{
		"entity_set_display_translation",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"translation_vector", "vector", nil},
			Slot{"mode", "enum", {"SET", "ADD"}},
		},
	}
	actions["entity_set_display_view_range"] = Action{
		"entity_set_display_view_range",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"view_range", "number", nil},
		},
	}
	actions["entity_set_dragon_phase"] = Action{
		"entity_set_dragon_phase",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"phase", "enum", {"BREATH_ATTACK", "CHARGE_PLAYER", "CIRCLING", "DYING", "FLY_TO_PORTAL", "HOVER", "LAND_ON_PORTAL", "LEAVE_PORTAL", "ROAR_BEFORE_ATTACK", "SEARCH_FOR_BREATH_ATTACK_TARGET", "STRAFING"}},
		},
	}
	actions["entity_set_dye_color"] = Action{
		"entity_set_dye_color",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"color", "enum", {"BLACK", "BLUE", "BROWN", "CYAN", "GRAY", "GREEN", "LIGHT_BLUE", "LIGHT_GRAY", "LIME", "MAGENTA", "ORANGE", "PINK", "PURPLE", "RED", "WHITE", "YELLOW"}},
		},
	}
	actions["entity_set_end_crystal_beam"] = Action{
		"entity_set_end_crystal_beam",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"beam", "location", nil},
		},
	}
	actions["entity_set_enderman_block"] = Action{
		"entity_set_enderman_block",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"block", "block", nil},
		},
	}
	actions["entity_set_equipment_item"] = Action{
		"entity_set_equipment_item",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"item", "item", nil},
			Slot{"slot", "enum", {"CHEST", "FEET", "HAND", "HEAD", "LEGS", "OFF_HAND"}},
		},
	}
	actions["entity_set_explosive_power"] = Action{
		"entity_set_explosive_power",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"power", "number", nil},
		},
	}
	actions["entity_set_fall_distance"] = Action{
		"entity_set_fall_distance",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"fall_distance", "number", nil},
		},
	}
	actions["entity_set_falling_block_type"] = Action{
		"entity_set_falling_block_type",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"block", "block", nil},
		},
	}
	actions["entity_set_fire_ticks"] = Action{
		"entity_set_fire_ticks",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"ticks", "number", nil},
		},
	}
	actions["entity_set_fishing_wait"] = Action{
		"entity_set_fishing_wait",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"time", "number", nil},
		},
	}
	actions["entity_set_fox_leaping"] = Action{
		"entity_set_fox_leaping",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"leaping", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["entity_set_fox_type"] = Action{
		"entity_set_fox_type",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"fox_type", "enum", {"RED", "SNOW"}},
		},
	}
	actions["entity_set_freeze_ticks"] = Action{
		"entity_set_freeze_ticks",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"ticks", "number", nil},
			Slot{"ticking_locked", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["entity_set_frog_type"] = Action{
		"entity_set_frog_type",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"frog_variant", "enum", {"COLD", "TEMPERATE", "WARM"}},
		},
	}
	actions["entity_set_gliding"] = Action{
		"entity_set_gliding",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"is_gliding", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["entity_set_glowing"] = Action{
		"entity_set_glowing",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"glowing", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["entity_set_glow_squid_dark"] = Action{
		"entity_set_glow_squid_dark",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"dark_ticks", "number", nil},
		},
	}
	actions["entity_set_goat_screaming"] = Action{
		"entity_set_goat_screaming",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"screams", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["entity_set_gravity"] = Action{
		"entity_set_gravity",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"gravity", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["entity_set_horse_jump"] = Action{
		"entity_set_horse_jump",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"power", "number", nil},
		},
	}
	actions["entity_set_horse_pattern"] = Action{
		"entity_set_horse_pattern",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"horse_color", "enum", {"WHITE", "CREAMY", "CHESTNUT", "BROWN", "DARK_BROWN", "GRAY", "BLACK", "DO_NOT_CHANGE"}},
			Slot{"horse_style", "enum", {"NONE", "WHITE", "WHITEFIELD", "WHITE_DOTS", "BLACK_DOTS", "DO_NOT_CHANGE"}},
		},
	}
	actions["entity_set_immune_to_zombification"] = Action{
		"entity_set_immune_to_zombification",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"is_immune", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["entity_set_interaction_responsive"] = Action{
		"entity_set_interaction_responsive",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"responsive", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["entity_set_interaction_size"] = Action{
		"entity_set_interaction_size",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"width", "number", nil},
			Slot{"height", "number", nil},
		},
	}
	actions["entity_set_invisible"] = Action{
		"entity_set_invisible",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"invisible", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["entity_set_invulnerability_ticks"] = Action{
		"entity_set_invulnerability_ticks",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"ticks", "number", nil},
		},
	}
	actions["entity_set_invulnerable"] = Action{
		"entity_set_invulnerable",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"invulnerable", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["entity_set_item"] = Action{
		"entity_set_item",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"item", "item", nil},
		},
	}
	actions["entity_set_item_display_item"] = Action{
		"entity_set_item_display_item",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"displayed_item", "item", nil},
		},
	}
	actions["entity_set_item_display_model_type"] = Action{
		"entity_set_item_display_model_type",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"display_model_type", "enum", {"FIRSTPERSON_LEFTHAND", "FIRSTPERSON_RIGHTHAND", "FIXED", "GROUND", "GUI", "HEAD", "NONE", "THIRDPERSON_LEFTHAND", "THIRDPERSON_RIGHTHAND"}},
		},
	}
	actions["entity_set_item_in_frame"] = Action{
		"entity_set_item_in_frame",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"item", "item", nil},
		},
	}
	actions["entity_set_llama_type"] = Action{
		"entity_set_llama_type",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"type", "enum", {"BROWN", "CREAMY", "GRAY", "WHITE"}},
		},
	}
	actions["entity_set_marker"] = Action{
		"entity_set_marker",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"marker", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["entity_set_max_health"] = Action{
		"entity_set_max_health",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"max_health", "number", nil},
			Slot{"heal_to_max", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["entity_set_merchant_recipe"] = Action{
		"entity_set_merchant_recipe",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"result", "item", nil},
			Slot{"ingredient_one", "item", nil},
			Slot{"ingredient_two", "item", nil},
			Slot{"index", "number", nil},
			Slot{"mode", "enum", {"MERGE", "APPEND"}},
			Slot{"uses", "number", nil},
			Slot{"max_uses", "number", nil},
			Slot{"villager_experience", "number", nil},
			Slot{"price_multiplifier", "number", nil},
			Slot{"demand", "number", nil},
			Slot{"special_price", "number", nil},
			Slot{"ignore_discounts", "enum", {"TRUE", "FALSE"}},
			Slot{"experience_reward", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["entity_set_minecart_block"] = Action{
		"entity_set_minecart_block",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"block", "block", nil},
			Slot{"block_offset", "number", nil},
		},
	}
	actions["entity_set_mob_aggressive"] = Action{
		"entity_set_mob_aggressive",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"aggressive", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["entity_set_mushroom_cow_type"] = Action{
		"entity_set_mushroom_cow_type",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"cow_type", "enum", {"BROWN", "RED"}},
		},
	}
	actions["entity_set_panda_gene"] = Action{
		"entity_set_panda_gene",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"gene", "enum", {"MAIN", "HIDDEN", "BOTH"}},
			Slot{"gene_type", "enum", {"NORMAL", "LAZY", "WORRIED", "PLAYFUL", "BROWN", "WEAK", "AGGRESSIVE"}},
		},
	}
	actions["entity_set_parrot_type"] = Action{
		"entity_set_parrot_type",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"parrot_type", "enum", {"BLUE", "CYAN", "GRAY", "GREEN", "RED"}},
		},
	}
	actions["entity_set_persistence"] = Action{
		"entity_set_persistence",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"persistence", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["entity_set_pickup_delay"] = Action{
		"entity_set_pickup_delay",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"delay", "number", nil},
		},
	}
	actions["entity_set_piglin_able_to_hunt"] = Action{
		"entity_set_piglin_able_to_hunt",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"able", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["entity_set_piglin_charging_crossbow"] = Action{
		"entity_set_piglin_charging_crossbow",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"charging", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["entity_set_piglin_dancing"] = Action{
		"entity_set_piglin_dancing",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"dancing_time", "number", nil},
		},
	}
	actions["entity_set_pose"] = Action{
		"entity_set_pose",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"pose", "enum", {"CROAKING", "DIGGING", "DYING", "EMERGING", "FALL_FLYING", "LONG_JUMPING", "ROARING", "SLEEPING", "SNEAKING", "SNIFFING", "SPIN_ATTACK", "STANDING", "SWIMMING", "USING_TONGUE"}},
		},
	}
	actions["entity_set_potion_cloud_radius"] = Action{
		"entity_set_potion_cloud_radius",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"radius", "number", nil},
			Slot{"shrinking_speed", "number", nil},
		},
	}
	actions["entity_set_primed_tnt_block"] = Action{
		"entity_set_primed_tnt_block",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"block", "block", nil},
		},
	}
	actions["entity_set_projectile_display_item"] = Action{
		"entity_set_projectile_display_item",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"item", "item", nil},
		},
	}
	actions["entity_set_projectile_shooter"] = Action{
		"entity_set_projectile_shooter",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"uuid", "text", nil},
		},
	}
	actions["entity_set_rabbit_type"] = Action{
		"entity_set_rabbit_type",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"rabbit_type", "enum", {"BLACK", "BLACK_AND_WHITE", "BROWN", "GOLD", "SALT_AND_PEPPER", "THE_KILLER_BUNNY", "WHITE"}},
		},
	}
	actions["entity_set_rearing"] = Action{
		"entity_set_rearing",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"rearing", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["entity_set_riptiding"] = Action{
		"entity_set_riptiding",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"riptiding", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["entity_set_rotation"] = Action{
		"entity_set_rotation",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"yaw", "number", nil},
			Slot{"pitch", "number", nil},
		},
	}
	actions["entity_set_rotation_by_vector"] = Action{
		"entity_set_rotation_by_vector",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"vector", "vector", nil},
		},
	}
	actions["entity_set_sheep_sheared"] = Action{
		"entity_set_sheep_sheared",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"sheared", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["entity_set_shulker_bullet_target"] = Action{
		"entity_set_shulker_bullet_target",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"target", "text", nil},
		},
	}
	actions["entity_set_silenced"] = Action{
		"entity_set_silenced",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"silenced", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["entity_set_sitting"] = Action{
		"entity_set_sitting",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"sitting", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["entity_set_size"] = Action{
		"entity_set_size",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"size", "number", nil},
		},
	}
	actions["entity_set_sniffer_state"] = Action{
		"entity_set_sniffer_state",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"state", "enum", {"DIGGING", "FEELING_HAPPY", "IDLING", "RISING", "SCENTING", "SEARCHING", "SNIFFING"}},
		},
	}
	actions["entity_set_snowman_pumpkin"] = Action{
		"entity_set_snowman_pumpkin",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"pumpkin", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["entity_set_tame"] = Action{
		"entity_set_tame",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"name_or_uuid", "text", nil},
		},
	}
	actions["entity_set_target"] = Action{
		"entity_set_target",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"name_or_uuid", "text", nil},
		},
	}
	actions["entity_set_text_display_alignment"] = Action{
		"entity_set_text_display_alignment",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"text_alignment", "enum", {"CENTER", "LEFT", "RIGHT"}},
		},
	}
	actions["entity_set_text_display_background"] = Action{
		"entity_set_text_display_background",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"color_hexadecimal", "text", nil},
			Slot{"opacity", "number", nil},
		},
	}
	actions["entity_set_text_display_line_width"] = Action{
		"entity_set_text_display_line_width",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"line_width", "number", nil},
		},
	}
	actions["entity_set_text_display_opacity"] = Action{
		"entity_set_text_display_opacity",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"text_opacity", "number", nil},
		},
	}
	actions["entity_set_text_display_see_through"] = Action{
		"entity_set_text_display_see_through",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"enable_see_through", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["entity_set_text_display_text"] = Action{
		"entity_set_text_display_text",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"displayed_text", "text", nil},
			Slot{"merging_mode", "enum", {"SPACES", "CONCATENATION", "SEPARATE_LINES"}},
		},
	}
	actions["entity_set_text_display_text_shadow"] = Action{
		"entity_set_text_display_text_shadow",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"enable_text_shadow", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["entity_set_tropical_fish_pattern"] = Action{
		"entity_set_tropical_fish_pattern",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"pattern_color", "enum", {"WHITE", "ORANGE", "MAGENTA", "LIGHT_BLUE", "YELLOW", "LIME", "PINK", "GRAY", "LIGHT_GRAY", "CYAN", "PURPLE", "BLUE", "BROWN", "GREEN", "RED", "BLACK", "DO_NOT_CHANGE"}},
			Slot{"body_color", "enum", {"WHITE", "ORANGE", "MAGENTA", "LIGHT_BLUE", "YELLOW", "LIME", "PINK", "GRAY", "LIGHT_GRAY", "CYAN", "PURPLE", "BLUE", "BROWN", "GREEN", "RED", "BLACK", "DO_NOT_CHANGE"}},
			Slot{"pattern", "enum", {"KOB", "SUNSTREAK", "SNOOPER", "DASHER", "BRINELY", "SPOTTY", "FLOPPER", "STRIPEY", "GLITTER", "BLOCKFISH", "BETTY", "CLAYFISH", "DO_NOT_CHANGE"}},
		},
	}
	actions["entity_set_location"] = Action{
		"entity_set_location",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"velocity", "vector", nil},
			Slot{"increment", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["entity_set_vex_charging"] = Action{
		"entity_set_vex_charging",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"charging", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["entity_set_vex_limited_lifetime_ticks"] = Action{
		"entity_set_vex_limited_lifetime_ticks",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"lifetime", "number", nil},
		},
	}
	actions["entity_set_villager_biome"] = Action{
		"entity_set_villager_biome",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"biome", "enum", {"DESERT", "JUNGLE", "PLAINS", "SAVANNA", "SNOW", "SWAMP", "TAIGA"}},
		},
	}
	actions["entity_set_villager_experience"] = Action{
		"entity_set_villager_experience",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"experience", "number", nil},
		},
	}
	actions["entity_set_villager_profession"] = Action{
		"entity_set_villager_profession",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"profession", "enum", {"NONE", "ARMORER", "BUTCHER", "CARTOGRAPHER", "CLERIC", "FARMER", "FISHERMAN", "FLETCHER", "LEATHERWORKER", "LIBRARIAN", "MASON", "NITWIT", "SHEPHERD", "TOOLSMITH", "WEAPONSMITH"}},
		},
	}
	actions["entity_set_visual_fire"] = Action{
		"entity_set_visual_fire",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"visual_fire", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["entity_set_warden_anger_level"] = Action{
		"entity_set_warden_anger_level",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"name_or_uuid", "text", nil},
			Slot{"anger", "number", nil},
		},
	}
	actions["entity_set_warden_digging"] = Action{
		"entity_set_warden_digging",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"digging", "enum", {"EMERGE", "DIG_DOWN"}},
		},
	}
	actions["entity_set_wearing_saddle"] = Action{
		"entity_set_wearing_saddle",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"wearing", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["entity_set_wither_invulnerability_ticks"] = Action{
		"entity_set_wither_invulnerability_ticks",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"ticks", "number", nil},
		},
	}
	actions["entity_set_zombie_arms_raised"] = Action{
		"entity_set_zombie_arms_raised",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"arms_raised", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["entity_shear_sheep"] = Action{
		"entity_shear_sheep",
		nil,
		nil,
		false,
		.BASIC,
		nil,
	}
	actions["entity_sleep"] = Action{
		"entity_sleep",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"sleep", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["entity_swing_hand"] = Action{
		"entity_swing_hand",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"hand_type", "enum", {"MAIN", "OFF"}},
		},
	}
	actions["entity_teleport"] = Action{
		"entity_teleport",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"location", "location", nil},
			Slot{"keep_rotation", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["entity_use_item"] = Action{
		"entity_use_item",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"hand", "enum", {"MAIN_HAND", "OFF_HAND"}},
			Slot{"enable", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["game_block_growth"] = Action{
		"game_block_growth",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"location", "location", nil},
			Slot{"growth_stage", "number", nil},
			Slot{"growth_type", "enum", {"STAGE_NUMBER", "PERCENTAGE"}},
		},
	}
	actions["game_bloom_skulk_catalyst"] = Action{
		"game_bloom_skulk_catalyst",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"location", "location", nil},
			Slot{"bloom_location", "location", nil},
			Slot{"charge", "number", nil},
		},
	}
	actions["game_bone_meal_block"] = Action{
		"game_bone_meal_block",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"location", "location", nil},
			Slot{"count", "number", nil},
		},
	}
	actions["game_break_block"] = Action{
		"game_break_block",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"locations", "location", nil},
			Slot{"tool", "item", nil},
			Slot{"drop_exp", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["game_cancel_event"] = Action{
		"game_cancel_event",
		nil,
		nil,
		false,
		.BASIC,
		nil,
	}
	actions["game_clear_container"] = Action{
		"game_clear_container",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"location", "location", nil},
		},
	}
	actions["game_clear_container_items"] = Action{
		"game_clear_container_items",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"location", "location", nil},
			Slot{"items", "item", nil},
		},
	}
	actions["game_clear_exploded_blocks"] = Action{
		"game_clear_exploded_blocks",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"location", "location", nil},
		},
	}
	actions["game_clear_region"] = Action{
		"game_clear_region",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"pos_1", "location", nil},
			Slot{"pos_2", "location", nil},
		},
	}
	actions["game_clear_scoreboard_scores"] = Action{
		"game_clear_scoreboard_scores",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"id", "text", nil},
		},
	}
	actions["game_clone_region"] = Action{
		"game_clone_region",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"pos_1", "location", nil},
			Slot{"pos_2", "location", nil},
			Slot{"target_pos", "location", nil},
			Slot{"paste_pos", "location", nil},
			Slot{"ignore_air", "enum", {"TRUE", "FALSE"}},
			Slot{"copy_entity", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["game_create_explosion"] = Action{
		"game_create_explosion",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"location", "location", nil},
			Slot{"power", "number", nil},
		},
	}
	actions["game_create_scoreboard"] = Action{
		"game_create_scoreboard",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"id", "text", nil},
			Slot{"display_name", "text", nil},
		},
	}
	actions["game_fill_container"] = Action{
		"game_fill_container",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"location", "location", nil},
			Slot{"items", "item", nil},
		},
	}
	actions["game_generate_tree"] = Action{
		"game_generate_tree",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"location", "location", nil},
			Slot{"tree_type", "enum", {"TREE", "ACACIA", "BIG_TREE", "BIRCH", "BROWN_MUSHROOM", "CHORUS_PLANT", "COCOA_TREE", "CRIMSON_FUNGUS", "DARK_OAK", "JUNGLE", "JUNGLE_BUSH", "MEGA_REDWOOD", "REDWOOD", "RED_MUSHROOM", "SMALL_JUNGLE", "SWAMP", "TALL_BIRCH", "TALL_REDWOOD", "WARPED_FUNGUS", "AZALEA"}},
		},
	}
	actions["game_hide_event_message"] = Action{
		"game_hide_event_message",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"hide", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["game_launch_firework"] = Action{
		"game_launch_firework",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"firework", "item", nil},
			Slot{"location", "location", nil},
			Slot{"movement", "enum", {"UPWARDS", "DIRECTIONAL"}},
			Slot{"instant", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["game_launch_projectile"] = Action{
		"game_launch_projectile",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"projectile", "item", nil},
			Slot{"location", "location", nil},
			Slot{"speed", "number", nil},
			Slot{"inaccuracy", "number", nil},
			Slot{"custom_name", "text", nil},
			Slot{"trail", "particle", nil},
		},
	}
	actions["game_random_tick_block"] = Action{
		"game_random_tick_block",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"location", "location", nil},
			Slot{"times", "number", nil},
		},
	}
	actions["game_remove_container_items"] = Action{
		"game_remove_container_items",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"location", "location", nil},
			Slot{"items", "item", nil},
		},
	}
	actions["game_remove_scoreboard"] = Action{
		"game_remove_scoreboard",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"id", "text", nil},
		},
	}
	actions["game_remove_scoreboard_score_by_name"] = Action{
		"game_remove_scoreboard_score_by_name",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"id", "text", nil},
			Slot{"text", "text", nil},
		},
	}
	actions["game_remove_scoreboard_score_by_score"] = Action{
		"game_remove_scoreboard_score_by_score",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"id", "text", nil},
			Slot{"score", "number", nil},
		},
	}
	actions["game_replace_blocks_in_region"] = Action{
		"game_replace_blocks_in_region",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"old_block", "block", nil},
			Slot{"pos_1", "location", nil},
			Slot{"pos_2", "location", nil},
			Slot{"new_block", "block", nil},
		},
	}
	actions["game_replace_container_items"] = Action{
		"game_replace_container_items",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"items", "item", nil},
			Slot{"location", "location", nil},
			Slot{"replace", "item", nil},
			Slot{"count", "number", nil},
		},
	}
	actions["game_send_web_request"] = Action{
		"game_send_web_request",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"url", "text", nil},
			Slot{"content_body", "text", nil},
			Slot{"request_type", "enum", {"GET", "POST", "PUT", "DELETE"}},
			Slot{"content_type", "enum", {"TEXT_PLAIN", "APPLICATION_JSON"}},
		},
	}
	actions["game_set_age"] = Action{
		"game_set_age",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"location", "location", nil},
			Slot{"tick", "number", nil},
		},
	}
	actions["game_set_block_analogue_power"] = Action{
		"game_set_block_analogue_power",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"location", "location", nil},
			Slot{"power_level", "number", nil},
		},
	}
	actions["game_set_block"] = Action{
		"game_set_block",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"block", "block", nil},
			Slot{"locations", "location", nil},
			Slot{"update_blocks", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["game_set_block_custom_tag"] = Action{
		"game_set_block_custom_tag",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"location", "location", nil},
			Slot{"tag_name", "text", nil},
			Slot{"tag_value", "text", nil},
		},
	}
	actions["game_set_block_data"] = Action{
		"game_set_block_data",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"location", "location", nil},
			Slot{"block_data", "text", nil},
		},
	}
	actions["game_set_block_drops_enabled"] = Action{
		"game_set_block_drops_enabled",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"enable", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["game_set_block_single_data"] = Action{
		"game_set_block_single_data",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"location", "location", nil},
			Slot{"data", "text", nil},
			Slot{"value", "text", nil},
		},
	}
	actions["game_set_brushable_block_item"] = Action{
		"game_set_brushable_block_item",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"location", "location", nil},
			Slot{"item", "item", nil},
		},
	}
	actions["game_set_campfire_item"] = Action{
		"game_set_campfire_item",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"location", "location", nil},
			Slot{"item", "item", nil},
			Slot{"cooking_time", "number", nil},
			Slot{"slot", "enum", {"FIRST", "SECOND", "THIRD", "FOURTH"}},
		},
	}
	actions["game_set_container"] = Action{
		"game_set_container",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"location", "location", nil},
			Slot{"items", "item", nil},
		},
	}
	actions["game_set_container_lock"] = Action{
		"game_set_container_lock",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"location", "location", nil},
			Slot{"container_key", "text", nil},
		},
	}
	actions["game_set_container_name"] = Action{
		"game_set_container_name",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"location", "location", nil},
			Slot{"name", "text", nil},
		},
	}
	actions["game_set_decorate_pot_sherd"] = Action{
		"game_set_decorate_pot_sherd",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"location", "location", nil},
			Slot{"item", "item", nil},
			Slot{"side", "enum", {"BACK", "FRONT", "LEFT", "RIGHT"}},
		},
	}
	actions["game_set_event_damage"] = Action{
		"game_set_event_damage",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"damage", "number", nil},
		},
	}
	actions["game_set_event_exhaustion"] = Action{
		"game_set_event_exhaustion",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"exhaustion", "number", nil},
		},
	}
	actions["game_set_event_experience"] = Action{
		"game_set_event_experience",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"experience", "number", nil},
		},
	}
	actions["game_set_event_heal"] = Action{
		"game_set_event_heal",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"heal", "number", nil},
		},
	}
	actions["game_set_event_item"] = Action{
		"game_set_event_item",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"item", "item", nil},
		},
	}
	actions["game_set_event_items"] = Action{
		"game_set_event_items",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"items", "item", nil},
		},
	}
	actions["game_set_event_move_allowed"] = Action{
		"game_set_event_move_allowed",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"allowed", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["game_set_event_projectile"] = Action{
		"game_set_event_projectile",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"projectile", "item", nil},
			Slot{"name", "text", nil},
		},
	}
	actions["game_set_event_uery_info"] = Action{
		"game_set_event_uery_info",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"information", "text", nil},
		},
	}
	actions["game_set_event_sound"] = Action{
		"game_set_event_sound",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"sound", "sound", nil},
		},
	}
	actions["game_set_event_source_slot"] = Action{
		"game_set_event_source_slot",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"source_slot", "number", nil},
		},
	}
	actions["game_set_event_target_slot"] = Action{
		"game_set_event_target_slot",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"target", "number", nil},
		},
	}
	actions["game_set_furnace_cook_time"] = Action{
		"game_set_furnace_cook_time",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"location", "location", nil},
			Slot{"time", "number", nil},
		},
	}
	actions["game_set_item_in_container_slot"] = Action{
		"game_set_item_in_container_slot",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"location", "location", nil},
			Slot{"item", "item", nil},
			Slot{"slot", "number", nil},
		},
	}
	actions["game_set_lectern_book"] = Action{
		"game_set_lectern_book",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"location", "location", nil},
			Slot{"item", "item", nil},
			Slot{"page", "number", nil},
		},
	}
	actions["game_set_player_head"] = Action{
		"game_set_player_head",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"location", "location", nil},
			Slot{"name_or_uuid", "text", nil},
			Slot{"receive_type", "enum", {"NAME_OR_UUID", "VALUE"}},
		},
	}
	actions["game_set_block_powered"] = Action{
		"game_set_block_powered",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"location", "location", nil},
			Slot{"powered", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["game_set_region"] = Action{
		"game_set_region",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"block", "block", nil},
			Slot{"pos_1", "location", nil},
			Slot{"pos_2", "location", nil},
		},
	}
	actions["game_set_scoreboard_line"] = Action{
		"game_set_scoreboard_line",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"id", "text", nil},
			Slot{"line", "text", nil},
			Slot{"display", "text", nil},
			Slot{"score", "number", nil},
			Slot{"format_content", "text", nil},
			Slot{"format", "enum", {"BLANK", "FIXED", "STYLED", "RESET"}},
		},
	}
	actions["game_set_scoreboard_line_display"] = Action{
		"game_set_scoreboard_line_display",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"id", "text", nil},
			Slot{"line", "text", nil},
			Slot{"display", "text", nil},
		},
	}
	actions["game_set_scoreboard_line_format"] = Action{
		"game_set_scoreboard_line_format",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"id", "text", nil},
			Slot{"line", "text", nil},
			Slot{"format_content", "text", nil},
			Slot{"format", "enum", {"BLANK", "FIXED", "STYLED", "RESET"}},
		},
	}
	actions["game_set_scoreboard_number_format"] = Action{
		"game_set_scoreboard_number_format",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"id", "text", nil},
			Slot{"format_content", "text", nil},
			Slot{"format", "enum", {"BLANK", "FIXED", "STYLED", "RESET"}},
		},
	}
	actions["game_set_scoreboard_score"] = Action{
		"game_set_scoreboard_score",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"id", "text", nil},
			Slot{"text", "text", nil},
			Slot{"score", "number", nil},
		},
	}
	actions["game_set_scoreboard_title"] = Action{
		"game_set_scoreboard_title",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"id", "text", nil},
			Slot{"title", "text", nil},
		},
	}
	actions["game_set_sculk_shrieker_can_summon"] = Action{
		"game_set_sculk_shrieker_can_summon",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"location", "location", nil},
			Slot{"can_summon", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["game_set_sculk_shrieker_shrieking"] = Action{
		"game_set_sculk_shrieker_shrieking",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"location", "location", nil},
			Slot{"shrieking", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["game_set_sculk_shrieker_warning_level"] = Action{
		"game_set_sculk_shrieker_warning_level",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"location", "location", nil},
			Slot{"warning_level", "number", nil},
		},
	}
	actions["game_set_sign_text"] = Action{
		"game_set_sign_text",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"location", "location", nil},
			Slot{"text", "text", nil},
			Slot{"line", "number", nil},
			Slot{"side", "enum", {"FRONT", "BACK", "ALL"}},
		},
	}
	actions["game_set_sign_text_color"] = Action{
		"game_set_sign_text_color",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"location", "location", nil},
			Slot{"side", "enum", {"FRONT", "BACK", "ALL"}},
			Slot{"sign_text_color", "enum", {"BLACK", "BLUE", "BROWN", "CYAN", "GRAY", "GREEN", "LIGHT_BLUE", "LIGHT_GRAY", "LIME", "MAGENTA", "ORANGE", "PINK", "PURPLE", "RED", "WHITE", "YELLOW"}},
			Slot{"glowing", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["game_set_sign_waxed"] = Action{
		"game_set_sign_waxed",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"location", "location", nil},
			Slot{"waxed", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["game_set_spawner_entity"] = Action{
		"game_set_spawner_entity",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"location", "location", nil},
			Slot{"entity", "item", nil},
		},
	}
	actions["game_set_world_difficulty"] = Action{
		"game_set_world_difficulty",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"difficulty", "enum", {"EASY", "HARD", "NORMAL", "PEACEFUL"}},
		},
	}
	actions["game_set_world_simulation_distance"] = Action{
		"game_set_world_simulation_distance",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"distance", "number", nil},
		},
	}
	actions["game_set_world_time"] = Action{
		"game_set_world_time",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"time", "number", nil},
		},
	}
	actions["game_set_world_weather"] = Action{
		"game_set_world_weather",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"weather_type", "enum", {"CLEAR", "RAINING", "THUNDER"}},
			Slot{"weather_duration", "number", nil},
		},
	}
	actions["game_spawn_armor_stand"] = Action{
		"game_spawn_armor_stand",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"helmet", "item", nil},
			Slot{"chestplate", "item", nil},
			Slot{"leggings", "item", nil},
			Slot{"boots", "item", nil},
			Slot{"right_hand", "item", nil},
			Slot{"left_hand", "item", nil},
			Slot{"gravity", "enum", {"TRUE", "FALSE"}},
			Slot{"marker", "enum", {"TRUE", "FALSE"}},
			Slot{"small", "enum", {"TRUE", "FALSE"}},
			Slot{"show_arms", "enum", {"TRUE", "FALSE"}},
			Slot{"base_plate", "enum", {"TRUE", "FALSE"}},
			Slot{"invisible", "enum", {"TRUE", "FALSE"}},
			Slot{"location", "location", nil},
			Slot{"custom_name", "text", nil},
		},
	}
	actions["game_spawn_block_display"] = Action{
		"game_spawn_block_display",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"spawn_location", "location", nil},
			Slot{"custom_name", "text", nil},
			Slot{"block", "block", nil},
		},
	}
	actions["game_spawn_effect_cloud"] = Action{
		"game_spawn_effect_cloud",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"location", "location", nil},
			Slot{"effects", "potion", nil},
			Slot{"radius", "number", nil},
			Slot{"duration", "number", nil},
			Slot{"particle", "particle", nil},
			Slot{"custom_name", "text", nil},
		},
	}
	actions["game_spawn_end_crystal"] = Action{
		"game_spawn_end_crystal",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"location", "location", nil},
			Slot{"custom_name", "text", nil},
			Slot{"show_bottom", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["game_spawn_evoker_fangs"] = Action{
		"game_spawn_evoker_fangs",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"location", "location", nil},
			Slot{"custom_name", "text", nil},
		},
	}
	actions["game_spawn_experience_orb"] = Action{
		"game_spawn_experience_orb",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"location", "location", nil},
			Slot{"experience_amount", "number", nil},
			Slot{"custom_name", "text", nil},
		},
	}
	actions["game_spawn_eye_of_ender"] = Action{
		"game_spawn_eye_of_ender",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"location", "location", nil},
			Slot{"destination", "location", nil},
			Slot{"lifespan", "number", nil},
			Slot{"custom_name", "text", nil},
			Slot{"end_of_lifespan", "enum", {"DROP", "SHATTER", "RANDOM"}},
		},
	}
	actions["game_spawn_falling_block"] = Action{
		"game_spawn_falling_block",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"block", "block", nil},
			Slot{"location", "location", nil},
			Slot{"name", "text", nil},
			Slot{"should_expire", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["game_spawn_interaction_entity"] = Action{
		"game_spawn_interaction_entity",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"location", "location", nil},
			Slot{"custom_name", "text", nil},
			Slot{"width", "number", nil},
			Slot{"height", "number", nil},
			Slot{"responsive", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["game_spawn_item"] = Action{
		"game_spawn_item",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"item", "item", nil},
			Slot{"location", "location", nil},
			Slot{"custom_name", "text", nil},
			Slot{"apply_motion", "enum", {"TRUE", "FALSE"}},
			Slot{"can_mob_pickup", "enum", {"TRUE", "FALSE"}},
			Slot{"can_player_pickup", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["game_spawn_item_display"] = Action{
		"game_spawn_item_display",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"spawn_location", "location", nil},
			Slot{"custom_name", "text", nil},
			Slot{"displayed_item", "item", nil},
		},
	}
	actions["game_spawn_lightning_bolt"] = Action{
		"game_spawn_lightning_bolt",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"location", "location", nil},
		},
	}
	actions["game_spawn_mob"] = Action{
		"game_spawn_mob",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"mob", "item", nil},
			Slot{"location", "location", nil},
			Slot{"health", "number", nil},
			Slot{"custom_name", "text", nil},
			Slot{"potion_effects", "potion", nil},
			Slot{"main_hand", "item", nil},
			Slot{"helmet", "item", nil},
			Slot{"chestplate", "item", nil},
			Slot{"leggings", "item", nil},
			Slot{"boots", "item", nil},
			Slot{"off_hand", "item", nil},
			Slot{"natural_equipment", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["game_spawn_primed_tnt"] = Action{
		"game_spawn_primed_tnt",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"location", "location", nil},
			Slot{"tnt_power", "number", nil},
			Slot{"fuse_duration", "number", nil},
			Slot{"custom_name", "text", nil},
			Slot{"block", "block", nil},
		},
	}
	actions["game_spawn_shulker_bullet"] = Action{
		"game_spawn_shulker_bullet",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"location", "location", nil},
			Slot{"custom_name", "text", nil},
		},
	}
	actions["game_spawn_text_display"] = Action{
		"game_spawn_text_display",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"spawn_location", "location", nil},
			Slot{"custom_name", "text", nil},
			Slot{"merging_mode", "enum", {"SPACES", "CONCATENATION", "SEPARATE_LINES"}},
			Slot{"displayed_text", "text", nil},
		},
	}
	actions["game_spawn_vehicle"] = Action{
		"game_spawn_vehicle",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"vehicle", "item", nil},
			Slot{"location", "location", nil},
			Slot{"custom_name", "text", nil},
		},
	}
	actions["game_uncancel_event"] = Action{
		"game_uncancel_event",
		nil,
		nil,
		false,
		.BASIC,
		nil,
	}
	actions["game_update_block"] = Action{
		"game_update_block",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"location", "location", nil},
		},
	}
	actions["if_entity_collides_at_location"] = Action{
		"if_entity_collides_at_location",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"location", "location", nil},
		},
	}
	actions["if_entity_collides_using_hitbox"] = Action{
		"if_entity_collides_using_hitbox",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"min", "location", nil},
			Slot{"max", "location", nil},
		},
	}
	actions["if_entity_collides_with_entity"] = Action{
		"if_entity_collides_with_entity",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"name_or_uuid", "text", nil},
			Slot{"check_type", "enum", {"OVERLAPS", "CONTAINS"}},
		},
	}
	actions["if_entity_exists"] = Action{
		"if_entity_exists",
		nil,
		nil,
		false,
		.CONTAINER,
		nil,
	}
	actions["if_entity_has_custom_tag"] = Action{
		"if_entity_has_custom_tag",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"tag", "text", nil},
			Slot{"tag_value", "text", nil},
		},
	}
	actions["if_entity_has_potion_effect"] = Action{
		"if_entity_has_potion_effect",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"potions", "potion", nil},
			Slot{"check_mode", "enum", {"ANY", "ALL"}},
		},
	}
	actions["if_entity_is_disguised"] = Action{
		"if_entity_is_disguised",
		nil,
		nil,
		false,
		.CONTAINER,
		nil,
	}
	actions["if_entity_is_grounded"] = Action{
		"if_entity_is_grounded",
		nil,
		nil,
		false,
		.CONTAINER,
		nil,
	}
	actions["if_entity_in_area"] = Action{
		"if_entity_in_area",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"location_1", "location", nil},
			Slot{"location_2", "location", nil},
			Slot{"ignore_y_axis", "enum", {"TRUE", "FALSE"}},
			Slot{"intersect_type", "enum", {"POINT", "HITBOX"}},
			Slot{"check_type", "enum", {"OVERLAPS", "CONTAINS"}},
		},
	}
	actions["if_entity_is_item"] = Action{
		"if_entity_is_item",
		nil,
		nil,
		false,
		.CONTAINER,
		nil,
	}
	actions["if_entity_is_mob"] = Action{
		"if_entity_is_mob",
		nil,
		nil,
		false,
		.CONTAINER,
		nil,
	}
	actions["if_entity_is_near_location"] = Action{
		"if_entity_is_near_location",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"ignore_y_axis", "enum", {"TRUE", "FALSE"}},
			Slot{"location", "location", nil},
			Slot{"range", "number", nil},
		},
	}
	actions["if_entity_is_projectile"] = Action{
		"if_entity_is_projectile",
		nil,
		nil,
		false,
		.CONTAINER,
		nil,
	}
	actions["if_entity_is_riding_entity"] = Action{
		"if_entity_is_riding_entity",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"entity_ids", "text", nil},
			Slot{"compare_mode", "enum", {"NEAREST", "FARTHEST"}},
		},
	}
	actions["if_entity_is_standing_on_block"] = Action{
		"if_entity_is_standing_on_block",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"blocks", "block", nil},
			Slot{"locations", "location", nil},
			Slot{"only_solid", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["if_entity_is_type"] = Action{
		"if_entity_is_type",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"entity_types", "item", nil},
		},
	}
	actions["if_entity_is_vehicle"] = Action{
		"if_entity_is_vehicle",
		nil,
		nil,
		false,
		.CONTAINER,
		nil,
	}
	actions["if_entity_name_equals"] = Action{
		"if_entity_name_equals",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"names_or_uuids", "text", nil},
		},
	}
	actions["if_entity_spawn_reason_equals"] = Action{
		"if_entity_spawn_reason_equals",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"reason", "enum", {"BEEHIVE", "BREEDING", "BUILD_IRONGOLEM", "BUILD_SNOWMAN", "BUILD_WITHER", "COMMAND", "CURED", "CUSTOM", "DEFAULT", "DISPENSE_EGG", "DROWNED", "EGG", "ENDER_PEARL", "EXPLOSION", "FROZEN", "INFECTION", "JOCKEY", "LIGHTNING", "MOUNT", "NATURAL", "NETHER_PORTAL", "OCELOT_BABY", "PATROL", "PIGLIN_ZOMBIFIED", "RAID", "REINFORCEMENTS", "SHEARED", "SHOULDER_ENTITY", "SILVERFISH_BLOCK", "SLIME_SPLIT", "SPAWNER", "SPAWNER_EGG", "TRAP", "VILLAGER_DEFENSE", "VILLAGE_INVASION"}},
		},
	}
	actions["if_game_block_equals"] = Action{
		"if_game_block_equals",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"location", "location", nil},
			Slot{"blocks", "block", nil},
		},
	}
	actions["if_game_block_powered"] = Action{
		"if_game_block_powered",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"locations", "location", nil},
			Slot{"power_mode", "enum", {"DIRECT", "INDIRECT"}},
		},
	}
	actions["if_game_chunk_is_loaded"] = Action{
		"if_game_chunk_is_loaded",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"location", "location", nil},
		},
	}
	actions["if_game_container_has"] = Action{
		"if_game_container_has",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"location", "location", nil},
			Slot{"items", "item", nil},
			Slot{"check_mode", "enum", {"ANY", "ALL"}},
			Slot{"comparison_mode", "enum", {"EXACTLY", "IGNORE_STACK_SIZE", "IGNORE_DURABILITY_AND_STACK_SIZE", "TYPE_ONLY"}},
		},
	}
	actions["if_game_container_has_room_for_item"] = Action{
		"if_game_container_has_room_for_item",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"location", "location", nil},
			Slot{"items", "item", nil},
			Slot{"check_mode", "enum", {"ANY", "ALL"}},
		},
	}
	actions["if_game_damage_cause_equals"] = Action{
		"if_game_damage_cause_equals",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"cause", "enum", {"BLOCK_EXPLOSION", "CONTACT", "CRAMMING", "CUSTOM", "DRAGON_BREATH", "DROWNING", "DRYOUT", "ENTITY_ATTACK", "ENTITY_EXPLOSION", "ENTITY_SWEEP_ATTACK", "FALL", "FALLING_BLOCK", "FIRE", "FIRE_TICK", "FLY_INTO_WALL", "FREEZE", "HOT_FLOOR", "LAVA", "LIGHTNING", "MAGIC", "MELTING", "POISON", "PROJECTILE", "STARVATION", "SUFFOCATION", "SUICIDE", "THORNS", "VOID", "WITHER"}},
		},
	}
	actions["if_game_event_attack_is_critical"] = Action{
		"if_game_event_attack_is_critical",
		nil,
		nil,
		false,
		.CONTAINER,
		nil,
	}
	actions["if_game_event_block_equals"] = Action{
		"if_game_event_block_equals",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"blocks", "block", nil},
			Slot{"locations", "location", nil},
		},
	}
	actions["if_game_event_is_canceled"] = Action{
		"if_game_event_is_canceled",
		nil,
		nil,
		false,
		.CONTAINER,
		nil,
	}
	actions["if_game_event_item_equals"] = Action{
		"if_game_event_item_equals",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"items", "item", nil},
			Slot{"comparison_mode", "enum", {"EXACTLY", "IGNORE_STACK_SIZE", "IGNORE_DURABILITY_AND_STACK_SIZE", "TYPE_ONLY"}},
		},
	}
	actions["if_game_has_player"] = Action{
		"if_game_has_player",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"names_or_uuids", "text", nil},
		},
	}
	actions["if_game_heal_cause_equals"] = Action{
		"if_game_heal_cause_equals",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"heal_cause", "enum", {"CUSTOM", "EATING", "ENDER_CRYSTAL", "MAGIC", "MAGIC_REGEN", "REGEN", "SATIATED", "WITHER", "WITHER_SPAWN"}},
		},
	}
	actions["if_game_ignite_cause_equals"] = Action{
		"if_game_ignite_cause_equals",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"cause", "enum", {"ARROW", "ENDER_CRYSTAL", "EXPLOSION", "FIREBALL", "FLINT_AND_STEEL", "LAVA", "LIGHTNING", "SPREAD"}},
		},
	}
	actions["if_game_instrument_equals"] = Action{
		"if_game_instrument_equals",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"instrument", "enum", {"BANJO", "BASS_DRUM", "BASS_GUITAR", "BELL", "BIT", "CHIME", "COW_BELL", "DIDGERIDOO", "FLUTE", "GUITAR", "IRON_XYLOPHONE", "PIANO", "PLING", "SNARE_DRUM", "STICKS", "XYLOPHONE"}},
		},
	}
	actions["if_game_sign_contains"] = Action{
		"if_game_sign_contains",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"location", "location", nil},
			Slot{"texts", "text", nil},
			Slot{"check_side", "enum", {"ANY", "FRONT", "BACK"}},
			Slot{"check_mode", "enum", {"ANY", "ALL"}},
			Slot{"lines", "enum", {"FIRST", "SECOND", "THIRD", "FOURTH", "ALL"}},
		},
	}
	actions["if_player_chat_message_equals"] = Action{
		"if_player_chat_message_equals",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"chat_messages", "text", nil},
		},
	}
	actions["if_player_collides_at_location"] = Action{
		"if_player_collides_at_location",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"location", "location", nil},
		},
	}
	actions["if_player_collides_using_hitbox"] = Action{
		"if_player_collides_using_hitbox",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"min", "location", nil},
			Slot{"max", "location", nil},
		},
	}
	actions["if_player_collides_with_entity"] = Action{
		"if_player_collides_with_entity",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"name_or_uuid", "text", nil},
			Slot{"check_type", "enum", {"OVERLAPS", "CONTAINS"}},
		},
	}
	actions["if_player_cursor_item_equals"] = Action{
		"if_player_cursor_item_equals",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"items", "item", nil},
			Slot{"comparison_mode", "enum", {"EXACTLY", "IGNORE_STACK_SIZE", "IGNORE_DURABILITY_AND_STACK_SIZE", "TYPE_ONLY"}},
		},
	}
	actions["if_player_gamemode_equals"] = Action{
		"if_player_gamemode_equals",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"gamemode", "enum", {"SURVIVAL", "CREATIVE", "ADVENTURE", "SPECTATOR"}},
		},
	}
	actions["if_player_has_item"] = Action{
		"if_player_has_item",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"items", "item", nil},
			Slot{"check_mode", "enum", {"ANY", "ALL"}},
			Slot{"comparison_mode", "enum", {"EXACTLY", "IGNORE_STACK_SIZE", "IGNORE_DURABILITY_AND_STACK_SIZE", "TYPE_ONLY"}},
		},
	}
	actions["if_player_has_item_at_least"] = Action{
		"if_player_has_item_at_least",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"item", "item", nil},
			Slot{"count", "number", nil},
			Slot{"comparison_mode", "enum", {"EXACTLY", "TYPE_ONLY"}},
		},
	}
	actions["if_player_has_item_in_slot"] = Action{
		"if_player_has_item_in_slot",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"items", "item", nil},
			Slot{"slots", "number", nil},
			Slot{"comparison_mode", "enum", {"EXACTLY", "IGNORE_STACK_SIZE", "IGNORE_DURABILITY_AND_STACK_SIZE", "TYPE_ONLY"}},
		},
	}
	actions["if_player_has_potion_effect"] = Action{
		"if_player_has_potion_effect",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"potions", "potion", nil},
			Slot{"check_mode", "enum", {"ANY", "ALL"}},
		},
	}
	actions["if_player_has_privilege"] = Action{
		"if_player_has_privilege",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"privilege", "enum", {"BUILDER", "DEVELOPER", "BUILDER_AND_DEVELOPER", "WHITELISTED", "OWNER"}},
			Slot{"exact", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["if_player_has_room_for_item"] = Action{
		"if_player_has_room_for_item",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"items", "item", nil},
			Slot{"check_mode", "enum", {"ANY", "ALL"}},
			Slot{"checked_slots", "enum", {"ENTIRE_INVENTORY", "MAIN_INVENTORY", "UPPER_INVENTORY", "HOTBAR", "ARMOR"}},
		},
	}
	actions["if_player_hotbar_slot_equals"] = Action{
		"if_player_hotbar_slot_equals",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"slot", "number", nil},
		},
	}
	actions["if_player_inventory_menu_slot_equals"] = Action{
		"if_player_inventory_menu_slot_equals",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"items", "item", nil},
			Slot{"slots", "number", nil},
			Slot{"comparison_mode", "enum", {"EXACTLY", "IGNORE_STACK_SIZE", "IGNORE_DURABILITY_AND_STACK_SIZE", "TYPE_ONLY"}},
		},
	}
	actions["if_player_inventory_type_open"] = Action{
		"if_player_inventory_type_open",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"inventory_type", "enum", {"CHEST", "DISPENSER", "DROPPER", "FURNACE", "WORKBENCH", "CRAFTING", "ENCHANTING", "BREWING", "PLAYER", "CREATIVE", "MERCHANT", "ENDER_CHEST", "ANVIL", "SMITHING", "BEACON", "HOPPER", "SHULKER_BOX", "BARREL", "BLAST_FURNACE", "LECTERN", "SMOKER", "LOOM", "CARTOGRAPHY", "GRINDSTONE", "STONECUTTER", "COMPOSTER"}},
		},
	}
	actions["if_player_is_blocking"] = Action{
		"if_player_is_blocking",
		nil,
		nil,
		false,
		.CONTAINER,
		nil,
	}
	actions["if_player_is_disguised"] = Action{
		"if_player_is_disguised",
		nil,
		nil,
		false,
		.CONTAINER,
		nil,
	}
	actions["if_player_is_flying"] = Action{
		"if_player_is_flying",
		nil,
		nil,
		false,
		.CONTAINER,
		nil,
	}
	actions["if_player_is_gliding"] = Action{
		"if_player_is_gliding",
		nil,
		nil,
		false,
		.CONTAINER,
		nil,
	}
	actions["if_player_is_holding"] = Action{
		"if_player_is_holding",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"items", "item", nil},
			Slot{"hand_slot", "enum", {"EITHER_HAND", "MAIN_HAND", "OFF_HAND"}},
			Slot{"comparison_mode", "enum", {"EXACTLY", "IGNORE_STACK_SIZE", "IGNORE_DURABILITY_AND_STACK_SIZE", "TYPE_ONLY"}},
		},
	}
	actions["if_player_in_area"] = Action{
		"if_player_in_area",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"location_1", "location", nil},
			Slot{"location_2", "location", nil},
			Slot{"ignore_y_axis", "enum", {"TRUE", "FALSE"}},
			Slot{"intersect_type", "enum", {"POINT", "HITBOX"}},
			Slot{"check_type", "enum", {"OVERLAPS", "CONTAINS"}},
		},
	}
	actions["if_player_item_is_not_on_cooldown"] = Action{
		"if_player_item_is_not_on_cooldown",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"items", "item", nil},
		},
	}
	actions["if_player_is_looking_at_block"] = Action{
		"if_player_is_looking_at_block",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"blocks", "block", nil},
			Slot{"locations", "location", nil},
			Slot{"distance", "number", nil},
			Slot{"fluid_mode", "enum", {"NEVER", "SOURCE_ONLY", "ALWAYS"}},
		},
	}
	actions["if_player_is_near"] = Action{
		"if_player_is_near",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"ignore_y_axis", "enum", {"TRUE", "FALSE"}},
			Slot{"location", "location", nil},
			Slot{"range", "number", nil},
		},
	}
	actions["if_player_is_on_ground"] = Action{
		"if_player_is_on_ground",
		nil,
		nil,
		false,
		.CONTAINER,
		nil,
	}
	actions["if_player_is_online_mode"] = Action{
		"if_player_is_online_mode",
		nil,
		nil,
		false,
		.CONTAINER,
		nil,
	}
	actions["if_player_is_riding_entity"] = Action{
		"if_player_is_riding_entity",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"entity_ids", "text", nil},
			Slot{"compare_mode", "enum", {"NEAREST", "FARTHEST"}},
		},
	}
	actions["if_player_is_self_disguised"] = Action{
		"if_player_is_self_disguised",
		nil,
		nil,
		false,
		.CONTAINER,
		nil,
	}
	actions["if_player_is_sleeping"] = Action{
		"if_player_is_sleeping",
		nil,
		nil,
		false,
		.CONTAINER,
		nil,
	}
	actions["if_player_is_sneaking"] = Action{
		"if_player_is_sneaking",
		nil,
		nil,
		false,
		.CONTAINER,
		nil,
	}
	actions["if_player_is_sprinting"] = Action{
		"if_player_is_sprinting",
		nil,
		nil,
		false,
		.CONTAINER,
		nil,
	}
	actions["if_player_is_standing_on_block"] = Action{
		"if_player_is_standing_on_block",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"blocks", "block", nil},
			Slot{"locations", "location", nil},
			Slot{"only_solid", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["if_player_is_swimming"] = Action{
		"if_player_is_swimming",
		nil,
		nil,
		false,
		.CONTAINER,
		nil,
	}
	actions["if_player_is_using_item"] = Action{
		"if_player_is_using_item",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"items", "item", nil},
			Slot{"comparison_mode", "enum", {"EXACTLY", "IGNORE_STACK_SIZE", "IGNORE_DURABILITY_AND_STACK_SIZE", "TYPE_ONLY"}},
		},
	}
	actions["if_player_is_wearing_item"] = Action{
		"if_player_is_wearing_item",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"items", "item", nil},
			Slot{"check_mode", "enum", {"ANY", "ALL"}},
			Slot{"comparison_mode", "enum", {"EXACTLY", "IGNORE_STACK_SIZE", "IGNORE_DURABILITY_AND_STACK_SIZE", "TYPE_ONLY"}},
		},
	}
	actions["if_player_name_equals"] = Action{
		"if_player_name_equals",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"names_or_uuids", "text", nil},
		},
	}
	actions["if_variable_equals"] = Action{
		"if_variable_equals",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"value", "any", nil},
			Slot{"compare", "any", nil},
		},
	}
	actions["if_variable_exists"] = Action{
		"if_variable_exists",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"variable", "variable", nil},
		},
	}
	actions["if_variable_greater"] = Action{
		"if_variable_greater",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"value", "number", nil},
			Slot{"compare", "number", nil},
		},
	}
	actions["if_variable_greater_or_equals"] = Action{
		"if_variable_greater_or_equals",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"value", "number", nil},
			Slot{"compare", "number", nil},
		},
	}
	actions["if_variable_in_range"] = Action{
		"if_variable_in_range",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"value", "any", nil},
			Slot{"min", "any", nil},
			Slot{"max", "any", nil},
		},
	}
	actions["if_variable_is_type"] = Action{
		"if_variable_is_type",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"value", "any", nil},
			Slot{"variable_type", "enum", {"NUMBER", "TEXT", "LOCATION", "ITEM", "POTION", "SOUND", "PARTICLE", "VECTOR", "ARRAY", "MAP"}},
		},
	}
	actions["if_variable_item_equals"] = Action{
		"if_variable_item_equals",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"value", "item", nil},
			Slot{"compare", "item", nil},
			Slot{"comparison_mode", "enum", {"EXACTLY", "IGNORE_STACK_SIZE", "IGNORE_DURABILITY_AND_STACK_SIZE", "TYPE_ONLY"}},
		},
	}
	actions["if_variable_item_has_enchantment"] = Action{
		"if_variable_item_has_enchantment",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"item", "item", nil},
			Slot{"enchant", "text", nil},
			Slot{"level", "number", nil},
		},
	}
	actions["if_variable_item_has_tag"] = Action{
		"if_variable_item_has_tag",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"item", "item", nil},
			Slot{"tag", "text", nil},
			Slot{"value", "text", nil},
		},
	}
	actions["if_variable_less"] = Action{
		"if_variable_less",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"value", "number", nil},
			Slot{"compare", "number", nil},
		},
	}
	actions["if_variable_less_or_equals"] = Action{
		"if_variable_less_or_equals",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"value", "number", nil},
			Slot{"compare", "number", nil},
		},
	}
	actions["if_variable_list_contains_value"] = Action{
		"if_variable_list_contains_value",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"list", "list", nil},
			Slot{"values", "any", nil},
			Slot{"check_mode", "enum", {"ANY", "ALL"}},
		},
	}
	actions["if_variable_list_value_equals"] = Action{
		"if_variable_list_value_equals",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"list", "list", nil},
			Slot{"index", "number", nil},
			Slot{"values", "any", nil},
		},
	}
	actions["if_variable_location_in_range"] = Action{
		"if_variable_location_in_range",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"value", "location", nil},
			Slot{"min", "location", nil},
			Slot{"max", "location", nil},
			Slot{"border_handling", "enum", {"EXACT", "BLOCK", "FULL_BLOCK_RANGE"}},
		},
	}
	actions["if_variable_location_is_near"] = Action{
		"if_variable_location_is_near",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"location", "location", nil},
			Slot{"radius", "number", nil},
			Slot{"check", "location", nil},
			Slot{"shape", "enum", {"SPHERE", "CIRCLE", "CUBE", "SQUARE"}},
		},
	}
	actions["if_variable_map_has_key"] = Action{
		"if_variable_map_has_key",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"map", "dictionary", nil},
			Slot{"key", "any", nil},
		},
	}
	actions["if_variable_map_value_equals"] = Action{
		"if_variable_map_value_equals",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"map", "dictionary", nil},
			Slot{"key", "any", nil},
			Slot{"values", "any", nil},
		},
	}
	actions["if_variable_not_equals"] = Action{
		"if_variable_not_equals",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"value", "any", nil},
			Slot{"compare", "any", nil},
		},
	}
	actions["if_variable_range_intersects_range"] = Action{
		"if_variable_range_intersects_range",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"min1", "location", nil},
			Slot{"max1", "location", nil},
			Slot{"min2", "location", nil},
			Slot{"max2", "location", nil},
			Slot{"check_type", "enum", {"OVERLAPS", "CONTAINS"}},
		},
	}
	actions["if_variable_text_contains"] = Action{
		"if_variable_text_contains",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"value", "text", nil},
			Slot{"compare", "text", nil},
			Slot{"ignore_case", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["if_variable_text_ends_with"] = Action{
		"if_variable_text_ends_with",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"value", "text", nil},
			Slot{"compare", "text", nil},
			Slot{"ignore_case", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["if_variable_text_matches"] = Action{
		"if_variable_text_matches",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"match", "text", nil},
			Slot{"values", "text", nil},
			Slot{"ignore_case", "enum", {"TRUE", "FALSE"}},
			Slot{"regular_expressions", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["if_variable_text_starts_with"] = Action{
		"if_variable_text_starts_with",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"value", "text", nil},
			Slot{"compare", "text", nil},
			Slot{"ignore_case", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["if_variable_list_is_empty"] = Action{
		"if_variable_list_is_empty",
		nil,
		nil,
		false,
		.CONTAINER,
		[]Slot{
			Slot{"list", "any", nil},
		},
	}
	actions["player_add_inventory_menu_row"] = Action{
		"player_add_inventory_menu_row",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"items", "item", nil},
			Slot{"position", "enum", {"TOP", "BUTTON"}},
		},
	}
	actions["player_allow_placing_breaking_blocks"] = Action{
		"player_allow_placing_breaking_blocks",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"allow", "enum", {"TRUE", "FALSE"}},
			Slot{"blocks", "block", nil},
		},
	}
	actions["player_boost_elytra"] = Action{
		"player_boost_elytra",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"firework", "item", nil},
		},
	}
	actions["player_clear_chat"] = Action{
		"player_clear_chat",
		nil,
		nil,
		false,
		.BASIC,
		nil,
	}
	actions["player_clear_debug_markers"] = Action{
		"player_clear_debug_markers",
		nil,
		nil,
		false,
		.BASIC,
		nil,
	}
	actions["player_clear_ender_chest_contents"] = Action{
		"player_clear_ender_chest_contents",
		nil,
		nil,
		false,
		.BASIC,
		nil,
	}
	actions["player_clear_inventory"] = Action{
		"player_clear_inventory",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"clear_mode", "enum", {"ENTIRE", "MAIN", "UPPER", "HOTBAR", "ARMOR"}},
		},
	}
	actions["player_clear_items"] = Action{
		"player_clear_items",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"items", "item", nil},
		},
	}
	actions["player_clear_potion_effects"] = Action{
		"player_clear_potion_effects",
		nil,
		nil,
		false,
		.BASIC,
		nil,
	}
	actions["player_close_inventory"] = Action{
		"player_close_inventory",
		nil,
		nil,
		false,
		.BASIC,
		nil,
	}
	actions["player_damage"] = Action{
		"player_damage",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"damage", "number", nil},
			Slot{"source", "text", nil},
		},
	}
	actions["player_disguise_as_block"] = Action{
		"player_disguise_as_block",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"block", "block", nil},
			Slot{"visible_to_self", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["player_disguise_as_entity"] = Action{
		"player_disguise_as_entity",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"entity_type", "item", nil},
			Slot{"visible_to_self", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["player_disguise_as_item"] = Action{
		"player_disguise_as_item",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"item", "item", nil},
			Slot{"visible_to_self", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["player_display_bell_ring"] = Action{
		"player_display_bell_ring",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"location", "location", nil},
			Slot{"direction", "enum", {"DOWN", "NORTH", "SOUTH", "WEST", "EAST"}},
		},
	}
	actions["player_display_block"] = Action{
		"player_display_block",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"location", "location", nil},
			Slot{"block", "block", nil},
		},
	}
	actions["player_set_block_opened_state"] = Action{
		"player_set_block_opened_state",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"location", "location", nil},
			Slot{"is_opened", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["player_display_end_gateway_beam"] = Action{
		"player_display_end_gateway_beam",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"location", "location", nil},
			Slot{"color", "enum", {"LIGHT_PURPLE", "DARK_PURPLE"}},
		},
	}
	actions["player_display_hologram"] = Action{
		"player_display_hologram",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"location", "location", nil},
			Slot{"text", "text", nil},
		},
	}
	actions["player_display_lightning"] = Action{
		"player_display_lightning",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"location", "location", nil},
		},
	}
	actions["player_display_particle"] = Action{
		"player_display_particle",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"particle", "particle", nil},
			Slot{"location", "location", nil},
		},
	}
	actions["player_display_particle_circle"] = Action{
		"player_display_particle_circle",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"particle", "particle", nil},
			Slot{"center", "location", nil},
			Slot{"radius", "number", nil},
			Slot{"points", "number", nil},
			Slot{"start_angle", "number", nil},
			Slot{"perpendicular", "vector", nil},
			Slot{"angle_unit", "enum", {"DEGREES", "RADIANS"}},
		},
	}
	actions["player_display_particle_cube"] = Action{
		"player_display_particle_cube",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"particle", "particle", nil},
			Slot{"first_corner", "location", nil},
			Slot{"second_corner", "location", nil},
			Slot{"spacing", "number", nil},
			Slot{"type", "enum", {"SOLID", "HOLLOW", "WIREFRAME"}},
		},
	}
	actions["player_display_particle_line"] = Action{
		"player_display_particle_line",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"particle", "particle", nil},
			Slot{"start", "location", nil},
			Slot{"end", "location", nil},
			Slot{"divider", "number", nil},
			Slot{"unit_of_measurement", "enum", {"POINTS", "DISTANCE"}},
		},
	}
	actions["player_display_particle_ray"] = Action{
		"player_display_particle_ray",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"particle", "particle", nil},
			Slot{"start", "location", nil},
			Slot{"ray", "vector", nil},
			Slot{"divider", "number", nil},
			Slot{"unit_of_measurement", "enum", {"POINTS", "DISTANCE"}},
		},
	}
	actions["player_display_particle_sphere"] = Action{
		"player_display_particle_sphere",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"particle", "particle", nil},
			Slot{"center", "location", nil},
			Slot{"radius", "number", nil},
			Slot{"points", "number", nil},
		},
	}
	actions["player_display_particle_spiral"] = Action{
		"player_display_particle_spiral",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"particle", "particle", nil},
			Slot{"center", "location", nil},
			Slot{"distance", "number", nil},
			Slot{"radius", "number", nil},
			Slot{"points", "number", nil},
			Slot{"rotations", "number", nil},
			Slot{"start_angle", "number", nil},
			Slot{"angle_unit", "enum", {"DEGREES", "RADIANS"}},
		},
	}
	actions["player_display_pick_up_animation"] = Action{
		"player_display_pick_up_animation",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"collected_name_or_uuid", "text", nil},
			Slot{"collector_name_or_uuid", "text", nil},
			Slot{"amount", "number", nil},
		},
	}
	actions["player_display_sign_text"] = Action{
		"player_display_sign_text",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"location", "location", nil},
			Slot{"line_1", "text", nil},
			Slot{"line_2", "text", nil},
			Slot{"line_3", "text", nil},
			Slot{"line_4", "text", nil},
		},
	}
	actions["player_display_vibration"] = Action{
		"player_display_vibration",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"from", "location", nil},
			Slot{"to", "location", nil},
			Slot{"destination_time", "number", nil},
		},
	}
	actions["player_expand_inventory_menu"] = Action{
		"player_expand_inventory_menu",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"items", "item", nil},
			Slot{"size", "number", nil},
		},
	}
	actions["player_face_location"] = Action{
		"player_face_location",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"location", "location", nil},
		},
	}
	actions["player_force_flight_mode"] = Action{
		"player_force_flight_mode",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"is_flying", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["player_give_experience"] = Action{
		"player_give_experience",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"experience", "number", nil},
			Slot{"mode", "enum", {"POINTS", "LEVEL", "LEVEL_PERCENTAGE"}},
		},
	}
	actions["player_give_items"] = Action{
		"player_give_items",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"items", "item", nil},
			Slot{"amount", "number", nil},
		},
	}
	actions["player_give_potion_effect"] = Action{
		"player_give_potion_effect",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"potions", "potion", nil},
			Slot{"overwrite", "enum", {"TRUE", "FALSE"}},
			Slot{"show_icon", "enum", {"TRUE", "FALSE"}},
			Slot{"particle_mode", "enum", {"REGULAR", "AMBIENT", "NONE"}},
		},
	}
	actions["player_give_random_item"] = Action{
		"player_give_random_item",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"items", "item", nil},
		},
	}
	actions["player_heal"] = Action{
		"player_heal",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"heal", "number", nil},
		},
	}
	actions["player_hide_entity"] = Action{
		"player_hide_entity",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"name_or_uuid", "text", nil},
			Slot{"hide", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["player_hide_scoreboard"] = Action{
		"player_hide_scoreboard",
		nil,
		nil,
		false,
		.BASIC,
		nil,
	}
	actions["player_kick"] = Action{
		"player_kick",
		nil,
		nil,
		false,
		.BASIC,
		nil,
	}
	actions["player_launch_forward"] = Action{
		"player_launch_forward",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"power", "number", nil},
			Slot{"increment", "enum", {"TRUE", "FALSE"}},
			Slot{"launch_axis", "enum", {"YAW_AND_PITCH", "YAW"}},
		},
	}
	actions["player_launch_projectile"] = Action{
		"player_launch_projectile",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"projectile", "item", nil},
			Slot{"location", "location", nil},
			Slot{"name", "text", nil},
			Slot{"speed", "number", nil},
			Slot{"inaccuracy", "number", nil},
			Slot{"trail", "particle", nil},
		},
	}
	actions["player_launch_to_location"] = Action{
		"player_launch_to_location",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"location", "location", nil},
			Slot{"power", "number", nil},
			Slot{"increment", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["player_launch_up"] = Action{
		"player_launch_up",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"power", "number", nil},
			Slot{"increment", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["player_load_inventory"] = Action{
		"player_load_inventory",
		nil,
		nil,
		false,
		.BASIC,
		nil,
	}
	actions["player_open_book"] = Action{
		"player_open_book",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"book", "item", nil},
		},
	}
	actions["player_open_container_inventory"] = Action{
		"player_open_container_inventory",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"location", "location", nil},
		},
	}
	actions["player_play_animation_action"] = Action{
		"player_play_animation_action",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"animation", "enum", {"DAMAGE", "WAKE_UP", "TOTEM", "JUMPSCARE"}},
		},
	}
	actions["player_play_hurt_animation"] = Action{
		"player_play_hurt_animation",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"yaw", "number", nil},
		},
	}
	actions["player_play_sound"] = Action{
		"player_play_sound",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"sound", "sound", nil},
			Slot{"location", "location", nil},
		},
	}
	actions["player_play_sound_from_entity"] = Action{
		"player_play_sound_from_entity",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"sounds", "sound", nil},
			Slot{"name_or_uuid", "text", nil},
		},
	}
	actions["player_play_sound_sequence"] = Action{
		"player_play_sound_sequence",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"sounds", "sound", nil},
			Slot{"delay", "number", nil},
			Slot{"location", "location", nil},
		},
	}
	actions["player_randomized_teleport"] = Action{
		"player_randomized_teleport",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"locations", "location", nil},
			Slot{"keep_rotation", "enum", {"TRUE", "FALSE"}},
			Slot{"keep_velocity", "enum", {"TRUE", "FALSE"}},
			Slot{"dismount", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["player_redirect_world"] = Action{
		"player_redirect_world",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"world_id", "text", nil},
		},
	}
	actions["player_remove_boss_bar"] = Action{
		"player_remove_boss_bar",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"id", "text", nil},
		},
	}
	actions["player_remove_disguise"] = Action{
		"player_remove_disguise",
		nil,
		nil,
		false,
		.BASIC,
		nil,
	}
	actions["player_remove_display_blocks"] = Action{
		"player_remove_display_blocks",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"pos_1", "location", nil},
			Slot{"pos_2", "location", nil},
		},
	}
	actions["player_remove_inventory_menu_row"] = Action{
		"player_remove_inventory_menu_row",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"size", "number", nil},
			Slot{"position", "enum", {"TOP", "BUTTON"}},
		},
	}
	actions["player_remove_items"] = Action{
		"player_remove_items",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"items", "item", nil},
		},
	}
	actions["player_remove_pose"] = Action{
		"player_remove_pose",
		nil,
		nil,
		false,
		.BASIC,
		nil,
	}
	actions["player_remove_potion_effect"] = Action{
		"player_remove_potion_effect",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"potions", "potion", nil},
		},
	}
	actions["player_remove_self_disguise"] = Action{
		"player_remove_self_disguise",
		nil,
		nil,
		false,
		.BASIC,
		nil,
	}
	actions["player_remove_skin"] = Action{
		"player_remove_skin",
		nil,
		nil,
		false,
		.BASIC,
		nil,
	}
	actions["player_remove_world_border"] = Action{
		"player_remove_world_border",
		nil,
		nil,
		false,
		.BASIC,
		nil,
	}
	actions["player_replace_items"] = Action{
		"player_replace_items",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"items", "item", nil},
			Slot{"replace", "item", nil},
			Slot{"count", "number", nil},
		},
	}
	actions["player_reset_weather"] = Action{
		"player_reset_weather",
		nil,
		nil,
		false,
		.BASIC,
		nil,
	}
	actions["player_ride_entity"] = Action{
		"player_ride_entity",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"name_or_uuid", "text", nil},
		},
	}
	actions["player_save_inventory"] = Action{
		"player_save_inventory",
		nil,
		nil,
		false,
		.BASIC,
		nil,
	}
	actions["player_self_disguise_as_block"] = Action{
		"player_self_disguise_as_block",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"block", "block", nil},
		},
	}
	actions["player_self_disguise_as_entity"] = Action{
		"player_self_disguise_as_entity",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"entity_type", "item", nil},
		},
	}
	actions["player_self_disguise_as_item"] = Action{
		"player_self_disguise_as_item",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"item", "item", nil},
		},
	}
	actions["player_send_action_bar"] = Action{
		"player_send_action_bar",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"messages", "text", nil},
			Slot{"merging", "enum", {"SPACES", "CONCATENATION"}},
		},
	}
	actions["player_send_advancement"] = Action{
		"player_send_advancement",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"frame", "enum", {"TASK", "CHALLENGE", "GOAL"}},
			Slot{"name", "text", nil},
			Slot{"icon", "item", nil},
		},
	}
	actions["player_send_break_animation"] = Action{
		"player_send_break_animation",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"locations", "location", nil},
			Slot{"stage", "number", nil},
		},
	}
	actions["player_send_dialogue"] = Action{
		"player_send_dialogue",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"messages", "text", nil},
			Slot{"delay", "number", nil},
		},
	}
	actions["player_send_hover"] = Action{
		"player_send_hover",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"message", "text", nil},
			Slot{"hover", "text", nil},
		},
	}
	actions["player_send_message"] = Action{
		"player_send_message",
		nil,
		nil,
		true,
		.BASIC,
		[]Slot{
			Slot{"messages", "text", nil},
			Slot{"merging", "enum", {"SPACES", "CONCATENATION", "SEPARATE_LINES"}},
		},
	}
	actions["player_send_minimessage"] = Action{
		"player_send_minimessage",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"minimessage", "text", nil},
		},
	}
	actions["player_send_title"] = Action{
		"player_send_title",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"title", "text", nil},
			Slot{"subtitle", "text", nil},
			Slot{"fade_in", "number", nil},
			Slot{"stay", "number", nil},
			Slot{"fade_out", "number", nil},
		},
	}
	actions["player_set_absorption_health"] = Action{
		"player_set_absorption_health",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"health", "number", nil},
		},
	}
	actions["player_set_air_ticks"] = Action{
		"player_set_air_ticks",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"ticks", "number", nil},
		},
	}
	actions["player_set_allow_flying"] = Action{
		"player_set_allow_flying",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"allow_flying", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["player_set_armor"] = Action{
		"player_set_armor",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"helmet", "item", nil},
			Slot{"chestplate", "item", nil},
			Slot{"leggings", "item", nil},
			Slot{"boots", "item", nil},
		},
	}
	actions["player_set_arrows_in_body"] = Action{
		"player_set_arrows_in_body",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"amount", "number", nil},
		},
	}
	actions["player_set_attack_speed"] = Action{
		"player_set_attack_speed",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"speed", "number", nil},
		},
	}
	actions["player_set_attribute"] = Action{
		"player_set_attribute",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"value", "number", nil},
			Slot{"attribute_type", "enum", {}},
		},
	}
	actions["player_set_bee_stingers_in_body"] = Action{
		"player_set_bee_stingers_in_body",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"amount", "number", nil},
		},
	}
	actions["player_set_boss_bar"] = Action{
		"player_set_boss_bar",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"id", "text", nil},
			Slot{"title", "text", nil},
			Slot{"progress", "number", nil},
			Slot{"color", "enum", {"PINK", "BLUE", "RED", "GREEN", "YELLOW", "PURPLE", "WHITE"}},
			Slot{"style", "enum", {"PROGRESS", "NOTCHED_6", "NOTCHED_10", "NOTCHED_12", "NOTCHED_20"}},
			Slot{"sky_effect", "enum", {"NONE", "FOG", "DARK_SKY", "FOG_AND_DARK_SKY"}},
		},
	}
	actions["player_set_chat_completions"] = Action{
		"player_set_chat_completions",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"completions", "text", nil},
			Slot{"setting_mode", "enum", {"ADD", "SET", "REMOVE"}},
		},
	}
	actions["player_set_collidable"] = Action{
		"player_set_collidable",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"collidable", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["player_set_compass_target"] = Action{
		"player_set_compass_target",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"location", "location", nil},
		},
	}
	actions["player_set_cursor_item"] = Action{
		"player_set_cursor_item",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"item", "item", nil},
		},
	}
	actions["player_set_death_drops"] = Action{
		"player_set_death_drops",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"death_drops", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["player_set_ender_chest_contents"] = Action{
		"player_set_ender_chest_contents",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"items", "item", nil},
		},
	}
	actions["player_set_entity_glowing"] = Action{
		"player_set_entity_glowing",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"name_or_uuid", "text", nil},
			Slot{"color", "enum", {"WHITE", "GRAY", "DARK_GRAY", "BLACK", "DARK_RED", "RED", "GOLD", "YELLOW", "GREEN", "DARK_GREEN", "DARK_AQUA", "AQUA", "BLUE", "DARK_BLUE", "DARK_PURPLE", "PURPLE"}},
			Slot{"glow", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["player_set_equipment"] = Action{
		"player_set_equipment",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"item", "item", nil},
			Slot{"slot", "enum", {"CHEST", "FEET", "HAND", "HEAD", "LEGS", "OFF_HAND"}},
		},
	}
	actions["player_set_exhaustion"] = Action{
		"player_set_exhaustion",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"exhaustion", "number", nil},
			Slot{"mode", "enum", {"SET", "ADD"}},
		},
	}
	actions["player_set_experience"] = Action{
		"player_set_experience",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"experience", "number", nil},
			Slot{"mode", "enum", {"POINTS", "LEVEL", "LEVEL_PERCENTAGE"}},
		},
	}
	actions["player_set_fall_distance"] = Action{
		"player_set_fall_distance",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"distance", "number", nil},
		},
	}
	actions["player_set_fire_ticks"] = Action{
		"player_set_fire_ticks",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"ticks", "number", nil},
		},
	}
	actions["player_set_flying"] = Action{
		"player_set_flying",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"is_flying", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["player_set_fog_distance"] = Action{
		"player_set_fog_distance",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"distance", "number", nil},
		},
	}
	actions["player_set_food"] = Action{
		"player_set_food",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"food", "number", nil},
			Slot{"mode", "enum", {"SET", "ADD"}},
		},
	}
	actions["player_set_freeze_ticks"] = Action{
		"player_set_freeze_ticks",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"ticks", "number", nil},
			Slot{"ticking_locked", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["player_set_gamemode"] = Action{
		"player_set_gamemode",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"gamemode", "enum", {"SURVIVAL", "CREATIVE", "ADVENTURE", "SPECTATOR"}},
			Slot{"flight_mode", "enum", {"RESPECT_GAMEMODE", "KEEP_ORIGINAL"}},
		},
	}
	actions["player_set_gliding"] = Action{
		"player_set_gliding",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"is_gliding", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["player_set_health"] = Action{
		"player_set_health",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"health", "number", nil},
		},
	}
	actions["player_set_hotbar_slot"] = Action{
		"player_set_hotbar_slot",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"slot", "number", nil},
		},
	}
	actions["player_set_instant_respawn"] = Action{
		"player_set_instant_respawn",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"instant_respawn", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["player_set_inventory_kept"] = Action{
		"player_set_inventory_kept",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"kept", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["player_set_inventory_menu_item"] = Action{
		"player_set_inventory_menu_item",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"item", "item", nil},
			Slot{"slot", "number", nil},
		},
	}
	actions["player_set_inventory_menu_name"] = Action{
		"player_set_inventory_menu_name",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"text", "text", nil},
		},
	}
	actions["player_set_invulnerability_ticks"] = Action{
		"player_set_invulnerability_ticks",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"ticks", "number", nil},
		},
	}
	actions["player_set_item_cooldown"] = Action{
		"player_set_item_cooldown",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"item", "item", nil},
			Slot{"cooldown", "number", nil},
			Slot{"sound", "sound", nil},
		},
	}
	actions["player_set_items"] = Action{
		"player_set_items",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"items", "item", nil},
		},
	}
	actions["player_set_max_health"] = Action{
		"player_set_max_health",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"health", "number", nil},
			Slot{"heal", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["player_set_movement_speed"] = Action{
		"player_set_movement_speed",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"distance", "number", nil},
			Slot{"movement_type", "enum", {"WALK", "FLY"}},
		},
	}
	actions["player_set_nametag_visible"] = Action{
		"player_set_nametag_visible",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"visible", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["player_set_player_list_info"] = Action{
		"player_set_player_list_info",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"text", "text", nil},
			Slot{"position", "enum", {"HEADER", "FOOTER"}},
			Slot{"merging", "enum", {"SPACES", "CONCATENATION", "SEPARATE_LINES"}},
		},
	}
	actions["player_set_pose"] = Action{
		"player_set_pose",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"pose", "enum", {"CROAKING", "DIGGING", "DYING", "EMERGING", "FALL_FLYING", "LONG_JUMPING", "ROARING", "SLEEPING", "SNEAKING", "SNIFFING", "SPIN_ATTACK", "STANDING", "SWIMMING", "USING_TONGUE"}},
			Slot{"locked", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["player_set_pvp"] = Action{
		"player_set_pvp",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"pvp", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["player_set_rain_level"] = Action{
		"player_set_rain_level",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"rain_level", "number", nil},
		},
	}
	actions["player_set_rotation"] = Action{
		"player_set_rotation",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"yaw", "number", nil},
			Slot{"pitch", "number", nil},
		},
	}
	actions["player_set_rotation_by_vector"] = Action{
		"player_set_rotation_by_vector",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"vector", "vector", nil},
		},
	}
	actions["player_set_saturation"] = Action{
		"player_set_saturation",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"saturation", "number", nil},
			Slot{"mode", "enum", {"SET", "ADD"}},
		},
	}
	actions["player_set_simulation_distance"] = Action{
		"player_set_simulation_distance",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"distance", "number", nil},
		},
	}
	actions["player_set_skin"] = Action{
		"player_set_skin",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"name_or_uuid", "text", nil},
			Slot{"server_type", "enum", {"MOJANG", "SERVER"}},
		},
	}
	actions["player_set_slot_item"] = Action{
		"player_set_slot_item",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"item", "item", nil},
			Slot{"slot", "number", nil},
		},
	}
	actions["player_set_spawn_point"] = Action{
		"player_set_spawn_point",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"spawn_point", "location", nil},
		},
	}
	actions["player_set_thunder_level"] = Action{
		"player_set_thunder_level",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"thunder_level", "number", nil},
		},
	}
	actions["player_set_tick_rate"] = Action{
		"player_set_tick_rate",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"tick_rate", "number", nil},
		},
	}
	actions["player_set_time"] = Action{
		"player_set_time",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"time", "number", nil},
		},
	}
	actions["player_set_velocity"] = Action{
		"player_set_velocity",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"velocity", "vector", nil},
			Slot{"increment", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["player_set_visual_fire"] = Action{
		"player_set_visual_fire",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"visual_fire", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["player_set_weather"] = Action{
		"player_set_weather",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"weather_type", "enum", {"DOWNFALL", "CLEAR"}},
		},
	}
	actions["player_set_world_border"] = Action{
		"player_set_world_border",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"center", "location", nil},
			Slot{"size", "number", nil},
			Slot{"warning", "number", nil},
		},
	}
	actions["player_shift_world_border"] = Action{
		"player_shift_world_border",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"old_size", "number", nil},
			Slot{"size", "number", nil},
			Slot{"time", "number", nil},
		},
	}
	actions["player_show_debug_marker"] = Action{
		"player_show_debug_marker",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"location", "location", nil},
			Slot{"name", "text", nil},
			Slot{"duration", "number", nil},
			Slot{"red", "number", nil},
			Slot{"green", "number", nil},
			Slot{"blue", "number", nil},
			Slot{"alpha", "number", nil},
		},
	}
	actions["player_show_demo_screen"] = Action{
		"player_show_demo_screen",
		nil,
		nil,
		false,
		.BASIC,
		nil,
	}
	actions["player_show_inventory_menu"] = Action{
		"player_show_inventory_menu",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"items", "item", nil},
			Slot{"name", "text", nil},
			Slot{"inventory_type", "enum", {"CHEST", "DISPENSER", "DROPPER", "FURNACE", "WORKBENCH", "ENCHANTING", "BREWING", "ANVIL", "SMITHING", "BEACON", "HOPPER", "BLAST_FURNACE", "SMOKER", "CARTOGRAPHY", "GRINDSTONE", "STONECUTTER"}},
		},
	}
	actions["player_show_scoreboard"] = Action{
		"player_show_scoreboard",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"id", "text", nil},
		},
	}
	actions["player_show_win_screen"] = Action{
		"player_show_win_screen",
		nil,
		nil,
		false,
		.BASIC,
		nil,
	}
	actions["player_spectate_target"] = Action{
		"player_spectate_target",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"name_or_uuid", "text", nil},
		},
	}
	actions["player_stop_sound"] = Action{
		"player_stop_sound",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"sounds", "sound", nil},
		},
	}
	actions["player_stop_sounds_by_source"] = Action{
		"player_stop_sounds_by_source",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"source", "enum", {"AMBIENT", "BLOCK", "HOSTILE", "MASTER", "MUSIC", "NEUTRAL", "PLAYER", "RECORD", "VOICE", "WEATHER"}},
		},
	}
	actions["player_swing_hand"] = Action{
		"player_swing_hand",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"hand_type", "enum", {"MAIN", "OFF"}},
		},
	}
	actions["player_teleport"] = Action{
		"player_teleport",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"location", "location", nil},
			Slot{"keep_rotation", "enum", {"TRUE", "FALSE"}},
			Slot{"keep_velocity", "enum", {"TRUE", "FALSE"}},
			Slot{"dismount", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["player_teleport_sequence"] = Action{
		"player_teleport_sequence",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"delay", "number", nil},
			Slot{"locations", "location", nil},
		},
	}
	actions["repeat_adjacently"] = Action{
		"repeat_adjacently",
		[]string{"origin", "change_rotation", "include_self", "pattern"},
		[]string{"variable"},
		false,
		.CONTAINER,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"origin", "location", nil},
			Slot{"change_rotation", "enum", {"TRUE", "FALSE"}},
			Slot{"include_self", "enum", {"TRUE", "FALSE"}},
			Slot{"pattern", "enum", {"CARDINAL", "SQUARE", "ADJACENT", "CUBE"}},
		},
	}
	actions["repeat_for_each_in_list"] = Action{
		"repeat_for_each_in_list",
		[]string{"list"},
		[]string{"index_variable", "value_variable"},
		false,
		.CONTAINER,
		[]Slot{
			Slot{"index_variable", "variable", nil},
			Slot{"value_variable", "variable", nil},
			Slot{"list", "list", nil},
		},
	}
	actions["repeat_for_each_map_entry"] = Action{
		"repeat_for_each_map_entry",
		[]string{"map"},
		[]string{"key_variable", "value_variable"},
		false,
		.CONTAINER,
		[]Slot{
			Slot{"key_variable", "variable", nil},
			Slot{"value_variable", "variable", nil},
			Slot{"map", "dictionary", nil},
		},
	}
	actions["repeat_forever"] = Action{
		"repeat_forever",
		nil,
		nil,
		false,
		.CONTAINER,
		nil,
	}
	actions["repeat_multi_times"] = Action{
		"repeat_multi_times",
		[]string{"amount"},
		[]string{"variable"},
		false,
		.CONTAINER,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"amount", "number", nil},
		},
	}
	actions["repeat_on_circle"] = Action{
		"repeat_on_circle",
		[]string{"center", "radius", "circle_points", "perpendicular_to_plane", "start_angle", "angle_unit"},
		[]string{"variable"},
		false,
		.CONTAINER,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"center", "location", nil},
			Slot{"radius", "number", nil},
			Slot{"circle_points", "number", nil},
			Slot{"perpendicular_to_plane", "vector", nil},
			Slot{"start_angle", "number", nil},
			Slot{"angle_unit", "enum", {"DEGREES", "RADIANS"}},
		},
	}
	actions["repeat_on_grid"] = Action{
		"repeat_on_grid",
		[]string{"start", "end"},
		[]string{"variable"},
		false,
		.CONTAINER,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"start", "location", nil},
			Slot{"end", "location", nil},
		},
	}
	actions["repeat_on_path"] = Action{
		"repeat_on_path",
		[]string{"step", "locations", "rotation"},
		[]string{"variable"},
		false,
		.CONTAINER,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"step", "number", nil},
			Slot{"locations", "location", nil},
			Slot{"rotation", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["repeat_on_range"] = Action{
		"repeat_on_range",
		[]string{"start", "end", "interval"},
		[]string{"variable"},
		false,
		.CONTAINER,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"start", "number", nil},
			Slot{"end", "number", nil},
			Slot{"interval", "number", nil},
		},
	}
	actions["repeat_on_sphere"] = Action{
		"repeat_on_sphere",
		[]string{"center", "radius", "points", "rotate_location"},
		[]string{"variable"},
		false,
		.CONTAINER,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"center", "location", nil},
			Slot{"radius", "number", nil},
			Slot{"points", "number", nil},
			Slot{"rotate_location", "enum", {"NO_CHANGES", "INWARDS", "OUTWARDS"}},
		},
	}
	actions["repeat_while"] = Action{
		"repeat_while",
		nil,
		nil,
		false,
		.CONTAINER_WITH_CONDITIONAL,
		nil,
	}
	actions["select_add_all_entities"] = Action{
		"select_add_all_entities",
		nil,
		nil,
		false,
		.BASIC,
		nil,
	}
	actions["select_add_all_mobs"] = Action{
		"select_add_all_mobs",
		nil,
		nil,
		false,
		.BASIC,
		nil,
	}
	actions["select_add_all_players"] = Action{
		"select_add_all_players",
		nil,
		nil,
		false,
		.BASIC,
		nil,
	}
	actions["select_add_entity_by_conditional"] = Action{
		"select_add_entity_by_conditional",
		nil,
		nil,
		false,
		.BASIC,
		nil,
	}
	actions["select_add_entity_by_name"] = Action{
		"select_add_entity_by_name",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"name_or_uuid", "text", nil},
		},
	}
	actions["select_add_event_target"] = Action{
		"select_add_event_target",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"selection_type", "enum", {"DEFAULT", "KILLER", "DAMAGER", "VICTIM", "SHOOTER", "PROJECTILE"}},
		},
	}
	actions["select_add_last_entity"] = Action{
		"select_add_last_entity",
		nil,
		nil,
		false,
		.BASIC,
		nil,
	}
	actions["select_add_last_mob"] = Action{
		"select_add_last_mob",
		nil,
		nil,
		false,
		.BASIC,
		nil,
	}
	actions["select_add_mob_by_name"] = Action{
		"select_add_mob_by_name",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"name_or_uuid", "text", nil},
		},
	}
	actions["select_add_player_by_conditional"] = Action{
		"select_add_player_by_conditional",
		nil,
		nil,
		false,
		.BASIC,
		nil,
	}
	actions["select_add_player_by_name"] = Action{
		"select_add_player_by_name",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"name_or_uuid", "text", nil},
		},
	}
	actions["select_add_random_entity"] = Action{
		"select_add_random_entity",
		nil,
		nil,
		false,
		.BASIC,
		nil,
	}
	actions["select_add_random_mob"] = Action{
		"select_add_random_mob",
		nil,
		nil,
		false,
		.BASIC,
		nil,
	}
	actions["select_add_random_player"] = Action{
		"select_add_random_player",
		nil,
		nil,
		false,
		.BASIC,
		nil,
	}
	actions["select_all_entities"] = Action{
		"select_all_entities",
		nil,
		nil,
		false,
		.BASIC,
		nil,
	}
	actions["select_all_mobs"] = Action{
		"select_all_mobs",
		nil,
		nil,
		false,
		.BASIC,
		nil,
	}
	actions["select_all_players"] = Action{
		"select_all_players",
		nil,
		nil,
		false,
		.BASIC,
		nil,
	}
	actions["select_entity_by_conditional"] = Action{
		"select_entity_by_conditional",
		nil,
		nil,
		false,
		.BASIC_WITH_CONDITIONAL,
		nil,
	}
	actions["select_entity_by_name"] = Action{
		"select_entity_by_name",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"name_or_uuid", "text", nil},
		},
	}
	actions["select_event_target"] = Action{
		"select_event_target",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"selection_type", "enum", {"DEFAULT", "KILLER", "DAMAGER", "VICTIM", "SHOOTER", "PROJECTILE"}},
		},
	}
	actions["select_filter_by_conditional"] = Action{
		"select_filter_by_conditional",
		nil,
		nil,
		false,
		.BASIC_WITH_CONDITIONAL,
		nil,
	}
	actions["select_filter_by_distance"] = Action{
		"select_filter_by_distance",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"location", "location", nil},
			Slot{"selection_size", "number", nil},
			Slot{"ignore_y_axis", "enum", {"TRUE", "FALSE"}},
			Slot{"compare_mode", "enum", {"NEAREST", "FARTHEST"}},
		},
	}
	actions["select_filter_by_raycast"] = Action{
		"select_filter_by_raycast",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"origin", "location", nil},
			Slot{"max_distance", "number", nil},
			Slot{"ray_size", "number", nil},
			Slot{"selection_size", "number", nil},
			Slot{"consider_blocks", "enum", {"TRUE", "FALSE"}},
			Slot{"ignore_passable_blocks", "enum", {"TRUE", "FALSE"}},
			Slot{"fluid_collision_mode", "enum", {"NEVER", "SOURCE_ONLY", "ALWAYS"}},
		},
	}
	actions["select_filter_randomly"] = Action{
		"select_filter_randomly",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"size", "number", nil},
		},
	}
	actions["select_invert"] = Action{
		"select_invert",
		nil,
		nil,
		false,
		.BASIC,
		nil,
	}
	actions["select_last_entity"] = Action{
		"select_last_entity",
		nil,
		nil,
		false,
		.BASIC,
		nil,
	}
	actions["select_last_mob"] = Action{
		"select_last_mob",
		nil,
		nil,
		false,
		.BASIC,
		nil,
	}
	actions["select_mob_by_name"] = Action{
		"select_mob_by_name",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"name_or_uuid", "text", nil},
		},
	}
	actions["select_player_by_conditional"] = Action{
		"select_player_by_conditional",
		nil,
		nil,
		false,
		.BASIC_WITH_CONDITIONAL,
		nil,
	}
	actions["select_player_by_name"] = Action{
		"select_player_by_name",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"name_or_uuid", "text", nil},
		},
	}
	actions["select_random_entity"] = Action{
		"select_random_entity",
		nil,
		nil,
		false,
		.BASIC,
		nil,
	}
	actions["select_random_mob"] = Action{
		"select_random_mob",
		nil,
		nil,
		false,
		.BASIC,
		nil,
	}
	actions["select_random_player"] = Action{
		"select_random_player",
		nil,
		nil,
		false,
		.BASIC,
		nil,
	}
	actions["select_reset"] = Action{
		"select_reset",
		nil,
		nil,
		false,
		.BASIC,
		nil,
	}
	actions["set_variable_absolute"] = Action{
		"set_variable_absolute",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"number", "number", nil},
		},
	}
	actions["set_variable_value"] = Action{
		"set_variable_value",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"value", "any", nil},
		},
	}
	actions["set_variable_add"] = Action{
		"set_variable_add",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"value", "number", nil},
		},
	}
	actions["set_variable_add_item_enchantment"] = Action{
		"set_variable_add_item_enchantment",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"item", "item", nil},
			Slot{"enchantment", "text", nil},
			Slot{"level", "number", nil},
		},
	}
	actions["set_variable_add_item_potion_effects"] = Action{
		"set_variable_add_item_potion_effects",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"item", "item", nil},
			Slot{"potions", "potion", nil},
			Slot{"overwrite", "enum", {"TRUE", "FALSE"}},
			Slot{"show_icon", "enum", {"TRUE", "FALSE"}},
			Slot{"particle_mode", "enum", {"REGULAR", "AMBIENT", "NONE"}},
		},
	}
	actions["set_variable_add_vectors"] = Action{
		"set_variable_add_vectors",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"vectors", "vector", nil},
		},
	}
	actions["set_variable_align_location"] = Action{
		"set_variable_align_location",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"location", "location", nil},
			Slot{"rotation_mode", "enum", {"KEEP", "REMOVE"}},
			Slot{"coordinates_mode", "enum", {"ALL", "X_Z", "Y"}},
			Slot{"align_mode", "enum", {"BLOCK_CENTER", "CORNER"}},
		},
	}
	actions["set_variable_align_to_axis_vector"] = Action{
		"set_variable_align_to_axis_vector",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"vector", "vector", nil},
			Slot{"normalize", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["set_variable_append_component"] = Action{
		"set_variable_append_component",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"components", "text", nil},
			Slot{"merging", "enum", {"SPACES", "CONCATENATION", "SEPARATE_LINES"}},
		},
	}
	actions["set_variable_append_list"] = Action{
		"set_variable_append_list",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"list_1", "list", nil},
			Slot{"list_2", "list", nil},
		},
	}
	actions["set_variable_append_map"] = Action{
		"set_variable_append_map",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"map", "dictionary", nil},
			Slot{"other_map", "dictionary", nil},
		},
	}
	actions["set_variable_append_value"] = Action{
		"set_variable_append_value",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"values", "any", nil},
		},
	}
	actions["set_variable_average"] = Action{
		"set_variable_average",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"value", "number", nil},
		},
	}
	actions["set_variable_bitwise_operation"] = Action{
		"set_variable_bitwise_operation",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"operand1", "number", nil},
			Slot{"operand2", "number", nil},
			Slot{"operator", "enum", {"OR", "AND", "NOT", "XOR", "LEFT_SHIFT", "RIGHT_SHIFT", "UNSIGNED_RIGHT_SHIFT"}},
		},
	}
	actions["set_variable_center_location"] = Action{
		"set_variable_center_location",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"locations", "location", nil},
		},
	}
	actions["set_variable_change_component_parsing"] = Action{
		"set_variable_change_component_parsing",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"component", "text", nil},
			Slot{"parsing", "enum", {"PLAIN", "LEGACY", "MINIMESSAGE", "JSON"}},
		},
	}
	actions["set_variable_char_to_number"] = Action{
		"set_variable_char_to_number",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"char", "text", nil},
		},
	}
	actions["set_variable_clamp"] = Action{
		"set_variable_clamp",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"number", "number", nil},
			Slot{"min", "number", nil},
			Slot{"max", "number", nil},
		},
	}
	actions["set_variable_clear_color_codes"] = Action{
		"set_variable_clear_color_codes",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"text", "text", nil},
		},
	}
	actions["set_variable_clear_map"] = Action{
		"set_variable_clear_map",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"map", "variable", nil},
		},
	}
	actions["set_variable_compact_component"] = Action{
		"set_variable_compact_component",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"component", "text", nil},
		},
	}
	actions["set_variable_component_of_children"] = Action{
		"set_variable_component_of_children",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"components", "text", nil},
		},
	}
	actions["set_variable_convert_number_to_text"] = Action{
		"set_variable_convert_number_to_text",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"number", "number", nil},
			Slot{"radix", "number", nil},
		},
	}
	actions["set_variable_convert_text_to_number"] = Action{
		"set_variable_convert_text_to_number",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"text", "text", nil},
			Slot{"radix", "number", nil},
		},
	}
	actions["set_variable_cosine"] = Action{
		"set_variable_cosine",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"number", "number", nil},
			Slot{"variant", "enum", {"COSINE", "ARCCOSINE", "HYPERBOLIC_COSINE"}},
			Slot{"input", "enum", {"DEGREES", "RADIANS"}},
		},
	}
	actions["set_variable_cotangent"] = Action{
		"set_variable_cotangent",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"number", "number", nil},
			Slot{"variant", "enum", {"COTANGENT", "ARCCOTANGENT", "HYPERBOLIC_COTANGENT"}},
			Slot{"input", "enum", {"DEGREES", "RADIANS"}},
		},
	}
	actions["set_variable_create_keybind_component"] = Action{
		"set_variable_create_keybind_component",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"key", "text", nil},
		},
	}
	actions["set_variable_create_list"] = Action{
		"set_variable_create_list",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"values", "any", nil},
		},
	}
	actions["set_variable_create_map"] = Action{
		"set_variable_create_map",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"keys", "list", nil},
			Slot{"values", "list", nil},
		},
	}
	actions["set_variable_create_map_from_values"] = Action{
		"set_variable_create_map_from_values",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"keys", "any", nil},
			Slot{"values", "any", nil},
		},
	}
	actions["set_variable_create_translatable_component"] = Action{
		"set_variable_create_translatable_component",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"key", "text", nil},
			Slot{"args", "text", nil},
		},
	}
	actions["set_variable_vector_cross_product"] = Action{
		"set_variable_vector_cross_product",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"vector_1", "vector", nil},
			Slot{"vector_2", "vector", nil},
		},
	}
	actions["set_variable_decrement"] = Action{
		"set_variable_decrement",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"number", "number", nil},
		},
	}
	actions["set_variable_divide"] = Action{
		"set_variable_divide",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"value", "number", nil},
			Slot{"division_mode", "enum", {"DEFAULT", "ROUND_TO_INT", "FLOOR", "CEIL"}},
		},
	}
	actions["set_variable_divide_vector"] = Action{
		"set_variable_divide_vector",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"vector", "vector", nil},
			Slot{"divider", "vector", nil},
		},
	}
	actions["set_variable_vector_dot_product"] = Action{
		"set_variable_vector_dot_product",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"vector_1", "vector", nil},
			Slot{"vector_2", "vector", nil},
		},
	}
	actions["set_variable_face_location"] = Action{
		"set_variable_face_location",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"location", "location", nil},
			Slot{"target", "location", nil},
		},
	}
	actions["set_variable_flatten_list"] = Action{
		"set_variable_flatten_list",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"list", "list", nil},
		},
	}
	actions["set_variable_format_timestamp"] = Action{
		"set_variable_format_timestamp",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"time", "number", nil},
			Slot{"pattern", "text", nil},
			Slot{"zone_id", "text", nil},
			Slot{"locale", "text", nil},
			Slot{"format", "enum", {"CUSTOM", "DD_MM_YYYY_HH_MM_S", "DD_MM_YYYY", "YYYY_MM_DD_HH_MM_S", "YYYY_MM_DD", "EEE_D_MMMM", "EEE_MMMM_D", "EEEE", "HH_MM_SS", "H_MM_A", "H_H_M_M_S_S", "S_S"}},
		},
	}
	actions["set_variable_gaussian_distribution"] = Action{
		"set_variable_gaussian_distribution",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"deviant", "number", nil},
			Slot{"mean", "number", nil},
			Slot{"distribution", "enum", {"NORMAL", "FOLDER_NORMAL"}},
		},
	}
	actions["set_variable_get_all_block_data"] = Action{
		"set_variable_get_all_block_data",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"location", "location", nil},
			Slot{"hide_unspecified", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["set_variable_get_all_coordinates"] = Action{
		"set_variable_get_all_coordinates",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"location", "location", nil},
			Slot{"x", "variable", nil},
			Slot{"y", "variable", nil},
			Slot{"z", "variable", nil},
			Slot{"yaw", "variable", nil},
			Slot{"pitch", "variable", nil},
		},
	}
	actions["set_variable_get_angle_between_vectors"] = Action{
		"set_variable_get_angle_between_vectors",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"vector_1", "vector", nil},
			Slot{"vector_2", "vector", nil},
			Slot{"angle_units", "enum", {"DEGREES", "RADIANS"}},
		},
	}
	actions["set_variable_get_block_custom_tag"] = Action{
		"set_variable_get_block_custom_tag",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"location", "location", nil},
			Slot{"tag_name", "text", nil},
			Slot{"tag_value", "text", nil},
			Slot{"default_value", "any", nil},
		},
	}
	actions["set_variable_get_block_data"] = Action{
		"set_variable_get_block_data",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"location", "location", nil},
			Slot{"tag_name", "text", nil},
		},
	}
	actions["set_variable_get_block_growth"] = Action{
		"set_variable_get_block_growth",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"location", "location", nil},
			Slot{"growth_unit", "enum", {"GROWTH_STAGE", "GROWTH_PERCENTAGE"}},
		},
	}
	actions["set_variable_get_block_material"] = Action{
		"set_variable_get_block_material",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"location", "location", nil},
			Slot{"value_type", "enum", {"ID", "ID_WITH_DATA", "NAME", "ITEM"}},
		},
	}
	actions["set_variable_get_block_material_property"] = Action{
		"set_variable_get_block_material_property",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"block", "block", nil},
			Slot{"property", "enum", {"HARDNESS", "BLAST_RESISTANCE", "SLIPPERINESS"}},
		},
	}
	actions["set_variable_get_block_power"] = Action{
		"set_variable_get_block_power",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"location", "location", nil},
		},
	}
	actions["set_variable_get_book_text"] = Action{
		"set_variable_get_book_text",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"book", "item", nil},
			Slot{"page", "number", nil},
		},
	}
	actions["set_variable_get_brushable_block_item"] = Action{
		"set_variable_get_brushable_block_item",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"location", "location", nil},
		},
	}
	actions["set_variable_get_bundle_items"] = Action{
		"set_variable_get_bundle_items",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"bundle", "item", nil},
		},
	}
	actions["set_variable_get_char_at"] = Action{
		"set_variable_get_char_at",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"text", "text", nil},
			Slot{"index", "number", nil},
		},
	}
	actions["set_variable_get_color_channels"] = Action{
		"set_variable_get_color_channels",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"color", "text", nil},
			Slot{"color_channels", "enum", {"RGB", "HSB", "HSL"}},
		},
	}
	actions["set_variable_get_compass_lodestone"] = Action{
		"set_variable_get_compass_lodestone",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"item", "item", nil},
		},
	}
	actions["set_variable_get_component_children"] = Action{
		"set_variable_get_component_children",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"component", "text", nil},
		},
	}
	actions["set_variable_get_component_decorations"] = Action{
		"set_variable_get_component_decorations",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"component", "text", nil},
		},
	}
	actions["set_variable_get_component_hex_color"] = Action{
		"set_variable_get_component_hex_color",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"component", "text", nil},
		},
	}
	actions["set_variable_get_component_parsing"] = Action{
		"set_variable_get_component_parsing",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"component", "text", nil},
		},
	}
	actions["set_variable_get_container_contents"] = Action{
		"set_variable_get_container_contents",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"location", "location", nil},
			Slot{"ignore_empty_slots", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["set_variable_get_container_lock"] = Action{
		"set_variable_get_container_lock",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"location", "location", nil},
		},
	}
	actions["set_variable_get_container_name"] = Action{
		"set_variable_get_container_name",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"location", "location", nil},
		},
	}
	actions["set_variable_get_coordinate"] = Action{
		"set_variable_get_coordinate",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"location", "location", nil},
			Slot{"type", "enum", {"X", "Y", "Z", "YAW", "PITCH"}},
		},
	}
	actions["set_variable_get_decorate_pot_sherd"] = Action{
		"set_variable_get_decorate_pot_sherd",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"location", "location", nil},
			Slot{"side", "enum", {"BACK", "FRONT", "LEFT", "RIGHT"}},
		},
	}
	actions["set_variable_get_index_of_subtext"] = Action{
		"set_variable_get_index_of_subtext",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"text", "text", nil},
			Slot{"subtext", "text", nil},
			Slot{"start_index", "number", nil},
			Slot{"search_mode", "enum", {"FIRST", "LAST"}},
		},
	}
	actions["set_variable_get_item_amount"] = Action{
		"set_variable_get_item_amount",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"item", "item", nil},
		},
	}
	actions["set_variable_get_item_attribute"] = Action{
		"set_variable_get_item_attribute",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"item", "item", nil},
			Slot{"name", "text", nil},
			Slot{"attribute", "enum", {"GENERIC_ARMOR", "GENERIC_ARMOR_TOUGHNESS", "GENERIC_ATTACK_DAMAGE", "GENERIC_ATTACK_KNOCKBACK", "GENERIC_ATTACK_SPEED", "GENERIC_FLYING_SPEED", "GENERIC_FOLLOW_RANGE", "GENERIC_KNOCKBACK_RESISTANCE", "GENERIC_LUCK", "GENERIC_MAX_HEALTH", "GENERIC_MOVEMENT_SPEED", "HORSE_JUMP_STRENGTH", "ZOMBIE_SPAWN_REINFORCEMENTS"}},
			Slot{"slot", "enum", {"ALL", "MAIN_HAND", "OFF_HAND", "HEAD", "CHEST", "LEGGINGS", "BOOTS"}},
			Slot{"operation", "enum", {"MULTIPLY_SCALAR_1", "ADD_NUMBER", "ADD_SCALAR"}},
		},
	}
	actions["set_variable_get_item_color"] = Action{
		"set_variable_get_item_color",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"item", "item", nil},
		},
	}
	actions["set_variable_get_item_custom_model_data"] = Action{
		"set_variable_get_item_custom_model_data",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"item", "item", nil},
		},
	}
	actions["set_variable_get_item_custom_tag"] = Action{
		"set_variable_get_item_custom_tag",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"item", "item", nil},
			Slot{"tag_name", "text", nil},
			Slot{"default_value", "any", nil},
		},
	}
	actions["set_variable_get_item_custom_tags"] = Action{
		"set_variable_get_item_custom_tags",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"item", "item", nil},
		},
	}
	actions["set_variable_get_item_destroyable_blocks"] = Action{
		"set_variable_get_item_destroyable_blocks",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"item", "item", nil},
		},
	}
	actions["set_variable_get_item_durability"] = Action{
		"set_variable_get_item_durability",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"item", "item", nil},
			Slot{"durability_type", "enum", {"DAMAGE", "DAMAGE_PERCENTAGE", "REMAINING", "REMAINING_PERCENTAGE", "MAXIMUM"}},
		},
	}
	actions["set_variable_get_item_enchantments"] = Action{
		"set_variable_get_item_enchantments",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"item", "item", nil},
		},
	}
	actions["set_variable_get_item_lore"] = Action{
		"set_variable_get_item_lore",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"item", "item", nil},
		},
	}
	actions["set_variable_get_item_lore_line"] = Action{
		"set_variable_get_item_lore_line",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"item", "item", nil},
			Slot{"line", "number", nil},
		},
	}
	actions["set_variable_get_item_type"] = Action{
		"set_variable_get_item_type",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"type", "item", nil},
			Slot{"value", "enum", {"ID", "NAME", "ITEM"}},
		},
	}
	actions["set_variable_get_item_max_stack_size"] = Action{
		"set_variable_get_item_max_stack_size",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"item", "item", nil},
		},
	}
	actions["set_variable_get_item_name"] = Action{
		"set_variable_get_item_name",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"item", "item", nil},
		},
	}
	actions["set_variable_get_item_nbt_tags"] = Action{
		"set_variable_get_item_nbt_tags",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"item", "item", nil},
		},
	}
	actions["set_variable_get_item_placeable_blocks"] = Action{
		"set_variable_get_item_placeable_blocks",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"item", "item", nil},
		},
	}
	actions["set_variable_get_item_potion_effects"] = Action{
		"set_variable_get_item_potion_effects",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"item", "item", nil},
		},
	}
	actions["set_variable_get_item_rarity"] = Action{
		"set_variable_get_item_rarity",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"item", "item", nil},
		},
	}
	actions["set_variable_get_lectern_book"] = Action{
		"set_variable_get_lectern_book",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"location", "location", nil},
		},
	}
	actions["set_variable_get_lectern_page"] = Action{
		"set_variable_get_lectern_page",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"location", "location", nil},
		},
	}
	actions["set_variable_get_light_level"] = Action{
		"set_variable_get_light_level",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"location", "location", nil},
			Slot{"value_type", "enum", {"TOTAL", "SKY", "BLOCKS"}},
		},
	}
	actions["set_variable_get_list_index_of_value"] = Action{
		"set_variable_get_list_index_of_value",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"list", "list", nil},
			Slot{"value", "any", nil},
			Slot{"search_mode", "enum", {"FIRST", "LAST"}},
		},
	}
	actions["set_variable_get_list_length"] = Action{
		"set_variable_get_list_length",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"list", "list", nil},
		},
	}
	actions["set_variable_get_list_random_value"] = Action{
		"set_variable_get_list_random_value",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"list", "list", nil},
		},
	}
	actions["set_variable_get_list_value"] = Action{
		"set_variable_get_list_value",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"list", "list", nil},
			Slot{"number", "number", nil},
			Slot{"default_value", "any", nil},
		},
	}
	actions["set_variable_get_list_variables"] = Action{
		"set_variable_get_list_variables",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"scope", "enum", {"GAME", "SAVE", "LOCAL"}},
		},
	}
	actions["set_variable_get_location_direction"] = Action{
		"set_variable_get_location_direction",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"location", "location", nil},
		},
	}
	actions["set_variable_get_map_key_by_index"] = Action{
		"set_variable_get_map_key_by_index",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"map", "dictionary", nil},
			Slot{"index", "number", nil},
			Slot{"default_value", "any", nil},
		},
	}
	actions["set_variable_get_map_keys"] = Action{
		"set_variable_get_map_keys",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"map", "dictionary", nil},
		},
	}
	actions["set_variable_get_map_keys_by_value"] = Action{
		"set_variable_get_map_keys_by_value",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"map", "dictionary", nil},
			Slot{"value", "any", nil},
			Slot{"default_value", "any", nil},
			Slot{"find_mode", "enum", {"FIRST", "LAST", "ALL"}},
		},
	}
	actions["set_variable_get_map_size"] = Action{
		"set_variable_get_map_size",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"map", "dictionary", nil},
		},
	}
	actions["set_variable_get_map_value"] = Action{
		"set_variable_get_map_value",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"map", "dictionary", nil},
			Slot{"key", "any", nil},
			Slot{"default_value", "any", nil},
		},
	}
	actions["set_variable_get_map_value_by_index"] = Action{
		"set_variable_get_map_value_by_index",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"map", "dictionary", nil},
			Slot{"index", "number", nil},
			Slot{"default_value", "any", nil},
		},
	}
	actions["set_variable_get_map_values"] = Action{
		"set_variable_get_map_values",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"map", "dictionary", nil},
		},
	}
	actions["set_variable_get_midpoint_between_vectors"] = Action{
		"set_variable_get_midpoint_between_vectors",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"vector_1", "vector", nil},
			Slot{"vector_2", "vector", nil},
		},
	}
	actions["set_variable_get_particle_amount"] = Action{
		"set_variable_get_particle_amount",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"particle", "particle", nil},
		},
	}
	actions["set_variable_get_particle_color"] = Action{
		"set_variable_get_particle_color",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"particle", "particle", nil},
			Slot{"color_type", "enum", {"COLOR", "TO_COLOR"}},
		},
	}
	actions["set_variable_get_particle_material"] = Action{
		"set_variable_get_particle_material",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"particle", "particle", nil},
		},
	}
	actions["set_variable_get_particle_offset"] = Action{
		"set_variable_get_particle_offset",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"particle", "particle", nil},
		},
	}
	actions["set_variable_get_particle_size"] = Action{
		"set_variable_get_particle_size",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"particle", "particle", nil},
		},
	}
	actions["set_variable_get_particle_spread"] = Action{
		"set_variable_get_particle_spread",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"particle", "particle", nil},
			Slot{"type", "enum", {"VERTICAL", "HORIZONTAL"}},
		},
	}
	actions["set_variable_get_particle_type"] = Action{
		"set_variable_get_particle_type",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"particle", "particle", nil},
		},
	}
	actions["set_variable_get_player_head"] = Action{
		"set_variable_get_player_head",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"name_or_uuid", "text", nil},
			Slot{"receive_type", "enum", {"NAME_OR_UUID", "VALUE"}},
		},
	}
	actions["set_variable_get_player_head_owner"] = Action{
		"set_variable_get_player_head_owner",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"head", "item", nil},
			Slot{"return_value", "enum", {"NAME", "UUID", "VALUE"}},
		},
	}
	actions["set_variable_get_player_head_value"] = Action{
		"set_variable_get_player_head_value",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"location", "location", nil},
			Slot{"return_value", "enum", {"NAME", "UUID", "VALUE"}},
		},
	}
	actions["set_variable_get_potion_effect_amplifier"] = Action{
		"set_variable_get_potion_effect_amplifier",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"potion", "potion", nil},
		},
	}
	actions["set_variable_get_potion_effect_duration"] = Action{
		"set_variable_get_potion_effect_duration",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"potion", "potion", nil},
		},
	}
	actions["set_variable_get_potion_effect_type"] = Action{
		"set_variable_get_potion_effect_type",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"potion", "potion", nil},
		},
	}
	actions["set_variable_get_sculk_shrieker_warning_level"] = Action{
		"set_variable_get_sculk_shrieker_warning_level",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"location", "location", nil},
		},
	}
	actions["set_variable_get_sign_text"] = Action{
		"set_variable_get_sign_text",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"location", "location", nil},
			Slot{"check_side", "enum", {"FRONT", "BACK", "ALL"}},
			Slot{"sign_line", "enum", {"FIRST", "SECOND", "THIRD", "FOURTH", "ALL"}},
		},
	}
	actions["set_variable_get_sound_pitch"] = Action{
		"set_variable_get_sound_pitch",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"sound", "sound", nil},
		},
	}
	actions["set_variable_get_sound_source"] = Action{
		"set_variable_get_sound_source",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"sound", "sound", nil},
		},
	}
	actions["set_variable_get_sound_type"] = Action{
		"set_variable_get_sound_type",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"sound", "sound", nil},
		},
	}
	actions["set_variable_get_sound_variation"] = Action{
		"set_variable_get_sound_variation",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"sound", "sound", nil},
		},
	}
	actions["set_variable_get_sound_variations"] = Action{
		"set_variable_get_sound_variations",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"sound", "sound", nil},
		},
	}
	actions["set_variable_get_sound_volume_action"] = Action{
		"set_variable_get_sound_volume_action",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"sound", "sound", nil},
		},
	}
	actions["set_variable_get_template_code"] = Action{
		"set_variable_get_template_code",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"template", "item", nil},
			Slot{"return_type", "enum", {"TEXT", "MAP"}},
		},
	}
	actions["set_variable_text_length"] = Action{
		"set_variable_text_length",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"text", "text", nil},
		},
	}
	actions["set_variable_get_text_width"] = Action{
		"set_variable_get_text_width",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"text", "text", nil},
		},
	}
	actions["set_variable_get_vector_all_components"] = Action{
		"set_variable_get_vector_all_components",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"vector", "vector", nil},
			Slot{"x", "variable", nil},
			Slot{"y", "variable", nil},
			Slot{"z", "variable", nil},
		},
	}
	actions["set_variable_get_vector_between_locations"] = Action{
		"set_variable_get_vector_between_locations",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"start_location", "location", nil},
			Slot{"end_location", "location", nil},
		},
	}
	actions["set_variable_get_vector_component"] = Action{
		"set_variable_get_vector_component",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"vector", "vector", nil},
			Slot{"vector_component", "enum", {"X", "Y", "Z"}},
		},
	}
	actions["set_variable_get_vector_from_block_face"] = Action{
		"set_variable_get_vector_from_block_face",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"block_face", "text", nil},
		},
	}
	actions["set_variable_get_vector_length"] = Action{
		"set_variable_get_vector_length",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"vector", "vector", nil},
			Slot{"length_type", "enum", {"LENGTH", "LENGTH_SQUARED"}},
		},
	}
	actions["set_variable_hash"] = Action{
		"set_variable_hash",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"text", "text", nil},
			Slot{"algorithm", "enum", {"MD5", "SHA1", "SHA256"}},
		},
	}
	actions["set_variable_increment"] = Action{
		"set_variable_increment",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"number", "number", nil},
		},
	}
	actions["set_variable_insert_list_value"] = Action{
		"set_variable_insert_list_value",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"list", "list", nil},
			Slot{"number", "number", nil},
			Slot{"value", "any", nil},
		},
	}
	actions["set_variable_join_text"] = Action{
		"set_variable_join_text",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"list", "list", nil},
			Slot{"separator", "text", nil},
			Slot{"prefix", "text", nil},
			Slot{"postfix", "text", nil},
			Slot{"limit", "number", nil},
			Slot{"truncated", "text", nil},
		},
	}
	actions["set_variable_lerp_number"] = Action{
		"set_variable_lerp_number",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"start", "number", nil},
			Slot{"stop", "number", nil},
			Slot{"amount", "number", nil},
		},
	}
	actions["set_variable_location_relative"] = Action{
		"set_variable_location_relative",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"location", "location", nil},
			Slot{"distance", "number", nil},
			Slot{"block_face", "enum", {"NORTH", "EAST", "SOUTH", "WEST", "UP", "DOWN", "NORTH_EAST", "NORTH_WEST", "SOUTH_EAST", "SOUTH_WEST"}},
		},
	}
	actions["set_variable_locations_distance"] = Action{
		"set_variable_locations_distance",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"location_1", "location", nil},
			Slot{"location_2", "location", nil},
			Slot{"type", "enum", {"THREE_D", "TWO_D", "Altitude"}},
		},
	}
	actions["set_variable_log"] = Action{
		"set_variable_log",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"number", "number", nil},
			Slot{"base", "number", nil},
		},
	}
	actions["set_variable_map_range"] = Action{
		"set_variable_map_range",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"number", "number", nil},
			Slot{"from_start", "number", nil},
			Slot{"from_stop", "number", nil},
			Slot{"to_start", "number", nil},
			Slot{"to_stop", "number", nil},
		},
	}
	actions["set_variable_max"] = Action{
		"set_variable_max",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"value", "number", nil},
		},
	}
	actions["set_variable_min"] = Action{
		"set_variable_min",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"value", "number", nil},
		},
	}
	actions["set_variable_multiply"] = Action{
		"set_variable_multiply",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"value", "number", nil},
		},
	}
	actions["set_variable_multiply_vector"] = Action{
		"set_variable_multiply_vector",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"vector", "vector", nil},
			Slot{"multiplier", "number", nil},
		},
	}
	actions["set_variable_parse_json"] = Action{
		"set_variable_parse_json",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"json", "text", nil},
		},
	}
	actions["set_variable_parse_to_component"] = Action{
		"set_variable_parse_to_component",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"text", "text", nil},
			Slot{"parsing", "enum", {"PLAIN", "LEGACY", "MINIMESSAGE", "JSON"}},
		},
	}
	actions["set_variable_perlin_noise_3d"] = Action{
		"set_variable_perlin_noise_3d",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"location", "location", nil},
			Slot{"seed", "number", nil},
			Slot{"loc_frequency", "number", nil},
			Slot{"octaves", "number", nil},
			Slot{"frequency", "number", nil},
			Slot{"amplitude", "number", nil},
			Slot{"range_mode", "enum", {"ZERO_TO_ONE", "FULL_RANGE"}},
			Slot{"normalized", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["set_variable_pow"] = Action{
		"set_variable_pow",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"base", "number", nil},
			Slot{"power", "number", nil},
		},
	}
	actions["set_variable_purge"] = Action{
		"set_variable_purge",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"names", "text", nil},
			Slot{"scope", "enum", {"GAME", "SAVE", "LOCAL"}},
			Slot{"match", "enum", {"EQUALS", "NAME_CONTAINS", "PART_CONTAINS"}},
			Slot{"ignore_case", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["set_variable_random"] = Action{
		"set_variable_random",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"values", "any", nil},
		},
	}
	actions["set_variable_randomize_list_order"] = Action{
		"set_variable_randomize_list_order",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"list", "list", nil},
		},
	}
	actions["set_variable_random_location"] = Action{
		"set_variable_random_location",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"location_1", "location", nil},
			Slot{"location_2", "location", nil},
			Slot{"integer", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["set_variable_random_number"] = Action{
		"set_variable_random_number",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"min", "number", nil},
			Slot{"max", "number", nil},
			Slot{"integer", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["set_variable_ray_trace_result"] = Action{
		"set_variable_ray_trace_result",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"start", "location", nil},
			Slot{"ray_size", "number", nil},
			Slot{"max_distance", "number", nil},
			Slot{"ray_collision_mode", "enum", {"ONLY_BLOCKS", "BLOCKS_AND_ENTITIES", "ONLY_ENTITIES"}},
			Slot{"ignore_passable_blocks", "enum", {"TRUE", "FALSE"}},
			Slot{"fluid_collision_mode", "enum", {"NEVER", "SOURCE_ONLY", "ALWAYS"}},
			Slot{"variable_for_hit_location", "variable", nil},
			Slot{"variable_for_hit_block_location", "variable", nil},
			Slot{"variable_for_hit_block_face", "variable", nil},
			Slot{"variable_for_hit_entity_uuid", "variable", nil},
			Slot{"entities", "list", nil},
		},
	}
	actions["set_variable_reflect_vector_product"] = Action{
		"set_variable_reflect_vector_product",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"vector_1", "vector", nil},
			Slot{"vector_2", "vector", nil},
			Slot{"bounce", "number", nil},
		},
	}
	actions["set_variable_regex_replace_text"] = Action{
		"set_variable_regex_replace_text",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"text", "text", nil},
			Slot{"regex", "text", nil},
			Slot{"replacement", "text", nil},
			Slot{"first", "enum", {"ANY", "FIRST"}},
			Slot{"ignore_case", "enum", {"TRUE", "FALSE"}},
			Slot{"multiline", "enum", {"TRUE", "FALSE"}},
			Slot{"literal", "enum", {"TRUE", "FALSE"}},
			Slot{"unix_lines", "enum", {"TRUE", "FALSE"}},
			Slot{"comments", "enum", {"TRUE", "FALSE"}},
			Slot{"dot_matches_all", "enum", {"TRUE", "FALSE"}},
			Slot{"cannon_eq", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["set_variable_remainder"] = Action{
		"set_variable_remainder",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"dividend", "number", nil},
			Slot{"divisor", "number", nil},
			Slot{"remainder_mode", "enum", {"REMAINDER", "MODULO"}},
		},
	}
	actions["set_variable_remove_compass_lodestone"] = Action{
		"set_variable_remove_compass_lodestone",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"item", "item", nil},
		},
	}
	actions["set_variable_remove_item_attribute"] = Action{
		"set_variable_remove_item_attribute",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"item", "item", nil},
			Slot{"name_or_uuid", "text", nil},
			Slot{"attribute", "enum", {"GENERIC_ARMOR", "GENERIC_ARMOR_TOUGHNESS", "GENERIC_ATTACK_DAMAGE", "GENERIC_ATTACK_KNOCKBACK", "GENERIC_ATTACK_SPEED", "GENERIC_FLYING_SPEED", "GENERIC_FOLLOW_RANGE", "GENERIC_KNOCKBACK_RESISTANCE", "GENERIC_LUCK", "GENERIC_MAX_HEALTH", "GENERIC_MOVEMENT_SPEED", "HORSE_JUMP_STRENGTH", "ZOMBIE_SPAWN_REINFORCEMENTS"}},
		},
	}
	actions["set_variable_remove_item_custom_model_data"] = Action{
		"set_variable_remove_item_custom_model_data",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"item", "item", nil},
		},
	}
	actions["set_variable_remove_item_custom_tag"] = Action{
		"set_variable_remove_item_custom_tag",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"item", "item", nil},
			Slot{"tag_name", "text", nil},
		},
	}
	actions["set_variable_remove_enchantment"] = Action{
		"set_variable_remove_enchantment",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"item", "item", nil},
			Slot{"enchantment", "text", nil},
		},
	}
	actions["set_variable_remove_item_lore_line"] = Action{
		"set_variable_remove_item_lore_line",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"item", "item", nil},
			Slot{"line", "number", nil},
		},
	}
	actions["set_variable_remove_item_potion_effects"] = Action{
		"set_variable_remove_item_potion_effects",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"item", "item", nil},
			Slot{"effects", "potion", nil},
		},
	}
	actions["set_variable_remove_list_duplicates"] = Action{
		"set_variable_remove_list_duplicates",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"list", "list", nil},
		},
	}
	actions["set_variable_remove_list_value"] = Action{
		"set_variable_remove_list_value",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"list", "list", nil},
			Slot{"value", "any", nil},
			Slot{"remove_mode", "enum", {"FIRST", "LAST", "ALL"}},
		},
	}
	actions["set_variable_remove_list_value_at_index"] = Action{
		"set_variable_remove_list_value_at_index",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"removed_value", "variable", nil},
			Slot{"variable", "variable", nil},
			Slot{"list", "list", nil},
			Slot{"index", "number", nil},
		},
	}
	actions["set_variable_remove_map_entry"] = Action{
		"set_variable_remove_map_entry",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"removed_value", "variable", nil},
			Slot{"variable", "variable", nil},
			Slot{"map", "dictionary", nil},
			Slot{"key", "any", nil},
			Slot{"values", "any", nil},
		},
	}
	actions["set_variable_remove_text"] = Action{
		"set_variable_remove_text",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"text", "text", nil},
			Slot{"regex", "enum", {"TRUE", "FALSE"}},
			Slot{"remove", "text", nil},
		},
	}
	actions["set_variable_repeat_text"] = Action{
		"set_variable_repeat_text",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"text", "text", nil},
			Slot{"repeat", "number", nil},
		},
	}
	actions["set_variable_replace_text"] = Action{
		"set_variable_replace_text",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"text", "text", nil},
			Slot{"replace", "text", nil},
			Slot{"replacement", "text", nil},
			Slot{"first", "enum", {"ANY", "FIRST"}},
			Slot{"ignore_case", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["set_variable_reverse_list"] = Action{
		"set_variable_reverse_list",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"list", "list", nil},
		},
	}
	actions["set_variable_root"] = Action{
		"set_variable_root",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"base", "number", nil},
			Slot{"root", "number", nil},
		},
	}
	actions["set_variable_rotate_vector_around_axis"] = Action{
		"set_variable_rotate_vector_around_axis",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"vector", "vector", nil},
			Slot{"angle", "number", nil},
			Slot{"axis", "enum", {"X", "Y", "Z"}},
			Slot{"angle_units", "enum", {"DEGREES", "RADIANS"}},
		},
	}
	actions["set_variable_rotate_vector_around_vector"] = Action{
		"set_variable_rotate_vector_around_vector",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"rotating_vector", "vector", nil},
			Slot{"axis_vector", "vector", nil},
			Slot{"angle", "number", nil},
			Slot{"angle_units", "enum", {"DEGREES", "RADIANS"}},
		},
	}
	actions["set_variable_round"] = Action{
		"set_variable_round",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"number", "number", nil},
			Slot{"precision", "number", nil},
			Slot{"round_type", "enum", {"ROUND", "FLOOR", "CEIL"}},
		},
	}
	actions["set_variable_set_all_coordinates"] = Action{
		"set_variable_set_all_coordinates",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"x", "number", nil},
			Slot{"y", "number", nil},
			Slot{"z", "number", nil},
			Slot{"yaw", "number", nil},
			Slot{"pitch", "number", nil},
		},
	}
	actions["set_variable_set_armor_trim"] = Action{
		"set_variable_set_armor_trim",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"armor", "item", nil},
			Slot{"material", "item", nil},
			Slot{"pattern", "item", nil},
		},
	}
	actions["set_variable_set_book_page"] = Action{
		"set_variable_set_book_page",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"book", "item", nil},
			Slot{"text", "text", nil},
			Slot{"page", "number", nil},
			Slot{"mode", "enum", {"MERGE", "APPEND"}},
		},
	}
	actions["set_variable_set_book_pages"] = Action{
		"set_variable_set_book_pages",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"book", "item", nil},
			Slot{"text", "text", nil},
		},
	}
	actions["set_variable_set_bundle_items"] = Action{
		"set_variable_set_bundle_items",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"bundle", "item", nil},
			Slot{"items", "item", nil},
			Slot{"setting_mode", "enum", {"ADD", "SET", "REMOVE"}},
		},
	}
	actions["set_variable_set_compass_lodestone"] = Action{
		"set_variable_set_compass_lodestone",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"item", "item", nil},
			Slot{"location", "location", nil},
			Slot{"tracked", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["set_variable_set_component_children"] = Action{
		"set_variable_set_component_children",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"component", "text", nil},
			Slot{"children", "text", nil},
		},
	}
	actions["set_variable_set_component_click"] = Action{
		"set_variable_set_component_click",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"component", "text", nil},
			Slot{"value", "text", nil},
			Slot{"click_action", "enum", {"COPY_TO_CLIPBOARD", "SUGGEST_COMMAND", "OPEN_URL", "CHANGE_PAGE"}},
		},
	}
	actions["set_variable_set_component_decorations"] = Action{
		"set_variable_set_component_decorations",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"component", "text", nil},
			Slot{"bold", "enum", {"FALSE", "NOT_SET", "TRUE"}},
			Slot{"italic", "enum", {"FALSE", "NOT_SET", "TRUE"}},
			Slot{"underlined", "enum", {"FALSE", "NOT_SET", "TRUE"}},
			Slot{"strikethrough", "enum", {"FALSE", "NOT_SET", "TRUE"}},
			Slot{"obfuscated", "enum", {"FALSE", "NOT_SET", "TRUE"}},
		},
	}
	actions["set_variable_set_component_entity_hover"] = Action{
		"set_variable_set_component_entity_hover",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"component", "text", nil},
			Slot{"name_or_uuid", "text", nil},
		},
	}
	actions["set_variable_set_component_font"] = Action{
		"set_variable_set_component_font",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"component", "text", nil},
			Slot{"namespace", "text", nil},
			Slot{"value", "text", nil},
		},
	}
	actions["set_variable_set_component_hex_color"] = Action{
		"set_variable_set_component_hex_color",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"component", "text", nil},
			Slot{"color", "text", nil},
		},
	}
	actions["set_variable_set_component_hover"] = Action{
		"set_variable_set_component_hover",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"component", "text", nil},
			Slot{"hover", "text", nil},
		},
	}
	actions["set_variable_set_component_insertion"] = Action{
		"set_variable_set_component_insertion",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"component", "text", nil},
			Slot{"insertion", "text", nil},
		},
	}
	actions["set_variable_set_component_item_hover"] = Action{
		"set_variable_set_component_item_hover",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"component", "text", nil},
			Slot{"hover", "item", nil},
		},
	}
	actions["set_variable_set_coordinate"] = Action{
		"set_variable_set_coordinate",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"location", "location", nil},
			Slot{"coordinate", "number", nil},
			Slot{"type", "enum", {"X", "Y", "Z", "PITCH", "YAW"}},
		},
	}
	actions["set_variable_set_item_amount"] = Action{
		"set_variable_set_item_amount",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"item", "item", nil},
			Slot{"amount", "number", nil},
		},
	}
	actions["set_variable_set_item_attribute"] = Action{
		"set_variable_set_item_attribute",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"item", "item", nil},
			Slot{"amount", "number", nil},
			Slot{"name", "text", nil},
			Slot{"attribute", "enum", {"GENERIC_ARMOR", "GENERIC_ARMOR_TOUGHNESS", "GENERIC_ATTACK_DAMAGE", "GENERIC_ATTACK_KNOCKBACK", "GENERIC_ATTACK_SPEED", "GENERIC_FLYING_SPEED", "GENERIC_FOLLOW_RANGE", "GENERIC_KNOCKBACK_RESISTANCE", "GENERIC_LUCK", "GENERIC_MAX_HEALTH", "GENERIC_MOVEMENT_SPEED", "HORSE_JUMP_STRENGTH", "ZOMBIE_SPAWN_REINFORCEMENTS"}},
			Slot{"slot", "enum", {"ALL", "MAIN_HAND", "OFF_HAND", "HEAD", "CHEST", "LEGGINGS", "BOOTS"}},
			Slot{"operation", "enum", {"MULTIPLY_SCALAR_1", "ADD_NUMBER", "ADD_SCALAR"}},
		},
	}
	actions["set_variable_set_item_color"] = Action{
		"set_variable_set_item_color",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"item", "item", nil},
			Slot{"color", "text", nil},
		},
	}
	actions["set_variable_set_item_custom_model_data"] = Action{
		"set_variable_set_item_custom_model_data",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"item", "item", nil},
			Slot{"model", "number", nil},
		},
	}
	actions["set_variable_set_item_custom_tag"] = Action{
		"set_variable_set_item_custom_tag",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"item", "item", nil},
			Slot{"tag_name", "text", nil},
			Slot{"tag_value", "text", nil},
		},
	}
	actions["set_variable_set_item_destroyable_blocks"] = Action{
		"set_variable_set_item_destroyable_blocks",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"item", "item", nil},
			Slot{"destroyable", "item", nil},
		},
	}
	actions["set_variable_set_item_durability"] = Action{
		"set_variable_set_item_durability",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"item", "item", nil},
			Slot{"durability", "number", nil},
			Slot{"durability_type", "enum", {"DAMAGE", "DAMAGE_PERCENTAGE", "REMAINING", "REMAINING_PERCENTAGE"}},
		},
	}
	actions["set_variable_set_item_enchantments"] = Action{
		"set_variable_set_item_enchantments",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"item", "item", nil},
			Slot{"enchantments", "dictionary", nil},
		},
	}
	actions["set_variable_set_item_lore"] = Action{
		"set_variable_set_item_lore",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"lore", "text", nil},
			Slot{"item", "item", nil},
		},
	}
	actions["set_variable_set_item_lore_line"] = Action{
		"set_variable_set_item_lore_line",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"item", "item", nil},
			Slot{"text", "text", nil},
			Slot{"line", "number", nil},
			Slot{"mode", "enum", {"MERGE", "APPEND"}},
		},
	}
	actions["set_variable_set_item_type"] = Action{
		"set_variable_set_item_type",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"item", "item", nil},
			Slot{"type", "text", nil},
		},
	}
	actions["set_variable_set_item_name"] = Action{
		"set_variable_set_item_name",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"item", "item", nil},
			Slot{"text", "text", nil},
		},
	}
	actions["set_variable_set_item_placeable_blocks"] = Action{
		"set_variable_set_item_placeable_blocks",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"item", "item", nil},
			Slot{"placeable", "item", nil},
		},
	}
	actions["set_variable_set_item_unbreakable"] = Action{
		"set_variable_set_item_unbreakable",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"item", "item", nil},
			Slot{"unbreakable", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["set_variable_set_item_visibility_flags"] = Action{
		"set_variable_set_item_visibility_flags",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"item", "item", nil},
			Slot{"hide_dye", "enum", {"ON", "NO_CHANGE", "OFF"}},
			Slot{"hide_enchantments", "enum", {"ON", "NO_CHANGE", "OFF"}},
			Slot{"hide_attributes", "enum", {"ON", "NO_CHANGE", "OFF"}},
			Slot{"hide_unbreakable", "enum", {"ON", "NO_CHANGE", "OFF"}},
			Slot{"hide_place_on", "enum", {"ON", "NO_CHANGE", "OFF"}},
			Slot{"hide_destroys", "enum", {"ON", "NO_CHANGE", "OFF"}},
			Slot{"hide_potion_effects", "enum", {"ON", "NO_CHANGE", "OFF"}},
			Slot{"hide_armor_trim", "enum", {"ON", "NO_CHANGE", "OFF"}},
		},
	}
	actions["set_variable_set_list_value"] = Action{
		"set_variable_set_list_value",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"list", "list", nil},
			Slot{"number", "number", nil},
			Slot{"value", "any", nil},
		},
	}
	actions["set_variable_set_location_direction"] = Action{
		"set_variable_set_location_direction",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"location", "location", nil},
			Slot{"vector", "vector", nil},
		},
	}
	actions["set_variable_set_map_value"] = Action{
		"set_variable_set_map_value",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"map", "dictionary", nil},
			Slot{"key", "any", nil},
			Slot{"value", "any", nil},
		},
	}
	actions["set_variable_set_particle_amount"] = Action{
		"set_variable_set_particle_amount",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"particle", "particle", nil},
			Slot{"amount", "number", nil},
		},
	}
	actions["set_variable_set_particle_color"] = Action{
		"set_variable_set_particle_color",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"particle", "particle", nil},
			Slot{"hex_color", "text", nil},
			Slot{"color_type", "enum", {"COLOR", "TO_COLOR"}},
		},
	}
	actions["set_variable_set_particle_material"] = Action{
		"set_variable_set_particle_material",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"particle", "particle", nil},
			Slot{"material", "item", nil},
		},
	}
	actions["set_variable_set_particle_offset"] = Action{
		"set_variable_set_particle_offset",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"particle", "particle", nil},
			Slot{"offset", "vector", nil},
		},
	}
	actions["set_variable_set_particle_size"] = Action{
		"set_variable_set_particle_size",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"particle", "particle", nil},
			Slot{"size", "number", nil},
		},
	}
	actions["set_variable_set_particle_spread"] = Action{
		"set_variable_set_particle_spread",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"particle", "particle", nil},
			Slot{"horizontal", "number", nil},
			Slot{"vertical", "number", nil},
		},
	}
	actions["set_variable_set_particle_type"] = Action{
		"set_variable_set_particle_type",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"particle", "particle", nil},
			Slot{"type", "text", nil},
		},
	}
	actions["set_variable_set_potion_effect_amplifier"] = Action{
		"set_variable_set_potion_effect_amplifier",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"potion", "potion", nil},
			Slot{"amplifier", "number", nil},
		},
	}
	actions["set_variable_set_potion_effect_duration"] = Action{
		"set_variable_set_potion_effect_duration",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"potion", "potion", nil},
			Slot{"duration", "number", nil},
		},
	}
	actions["set_variable_set_potion_effect_type"] = Action{
		"set_variable_set_potion_effect_type",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"potion", "potion", nil},
			Slot{"effect_type", "text", nil},
		},
	}
	actions["set_variable_set_sound_pitch"] = Action{
		"set_variable_set_sound_pitch",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"sound", "sound", nil},
			Slot{"pitch", "number", nil},
		},
	}
	actions["set_variable_set_sound_source"] = Action{
		"set_variable_set_sound_source",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"sound", "sound", nil},
			Slot{"source", "enum", {"AMBIENT", "BLOCK", "HOSTILE", "MASTER", "MUSIC", "NEUTRAL", "PLAYER", "RECORD", "VOICE", "WEATHER"}},
		},
	}
	actions["set_variable_set_sound_type"] = Action{
		"set_variable_set_sound_type",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"sound", "sound", nil},
			Slot{"namespace", "text", nil},
			Slot{"value", "text", nil},
		},
	}
	actions["set_variable_set_sound_variation"] = Action{
		"set_variable_set_sound_variation",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"sound", "sound", nil},
			Slot{"variation", "text", nil},
		},
	}
	actions["set_variable_set_sound_volume_action"] = Action{
		"set_variable_set_sound_volume_action",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"sound", "sound", nil},
			Slot{"volume", "number", nil},
		},
	}
	actions["set_variable_set_template_code"] = Action{
		"set_variable_set_template_code",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"template", "item", nil},
			Slot{"code", "any", nil},
		},
	}
	actions["set_variable_set_texture_to_map"] = Action{
		"set_variable_set_texture_to_map",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"map", "item", nil},
			Slot{"url", "text", nil},
		},
	}
	actions["set_variable_set_vector_component"] = Action{
		"set_variable_set_vector_component",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"vector", "vector", nil},
			Slot{"value", "number", nil},
			Slot{"vector_component", "enum", {"X", "Y", "Z"}},
		},
	}
	actions["set_variable_set_vector_length"] = Action{
		"set_variable_set_vector_length",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"vector", "vector", nil},
			Slot{"length", "number", nil},
		},
	}
	actions["set_variable_shift_all_coordinates"] = Action{
		"set_variable_shift_all_coordinates",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"location", "location", nil},
			Slot{"x", "number", nil},
			Slot{"y", "number", nil},
			Slot{"z", "number", nil},
			Slot{"yaw", "number", nil},
			Slot{"pitch", "number", nil},
		},
	}
	actions["set_variable_shift_coordinate"] = Action{
		"set_variable_shift_coordinate",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"location", "location", nil},
			Slot{"distance", "number", nil},
			Slot{"type", "enum", {"X", "Y", "Z", "PITCH", "YAW"}},
		},
	}
	actions["set_variable_shift_location_in_direction"] = Action{
		"set_variable_shift_location_in_direction",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"location", "location", nil},
			Slot{"shift", "number", nil},
			Slot{"direction", "enum", {"FORWARD", "UPWARD", "SIDEWAYS"}},
		},
	}
	actions["set_variable_shift_location_on_vector"] = Action{
		"set_variable_shift_location_on_vector",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"location", "location", nil},
			Slot{"vector", "vector", nil},
			Slot{"length", "number", nil},
		},
	}
	actions["set_variable_shift_location_towards_location"] = Action{
		"set_variable_shift_location_towards_location",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"location_from", "location", nil},
			Slot{"location_to", "location", nil},
			Slot{"distance", "number", nil},
		},
	}
	actions["set_variable_simplex_noise_3d"] = Action{
		"set_variable_simplex_noise_3d",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"location", "location", nil},
			Slot{"seed", "number", nil},
			Slot{"loc_frequency", "number", nil},
			Slot{"octaves", "number", nil},
			Slot{"frequency", "number", nil},
			Slot{"amplitude", "number", nil},
			Slot{"range_mode", "enum", {"ZERO_TO_ONE", "FULL_RANGE"}},
			Slot{"normalized", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["set_variable_sine"] = Action{
		"set_variable_sine",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"number", "number", nil},
			Slot{"variant", "enum", {"SINE", "ARCSINE", "HYPERBOLIC_SINE"}},
			Slot{"input", "enum", {"DEGREES", "RADIANS"}},
		},
	}
	actions["set_variable_sort_any_list"] = Action{
		"set_variable_sort_any_list",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"list", "list", nil},
			Slot{"sort_mode", "enum", {"ASCENDING", "DESCENDING"}},
		},
	}
	actions["set_variable_sort_any_map"] = Action{
		"set_variable_sort_any_map",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"map", "dictionary", nil},
			Slot{"sort_order", "enum", {"ASCENDING", "DESCENDING"}},
			Slot{"sort_type", "enum", {"KEYS", "VALUES"}},
		},
	}
	actions["set_variable_split_text"] = Action{
		"set_variable_split_text",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"text", "text", nil},
			Slot{"delimiter", "text", nil},
		},
	}
	actions["set_variable_strip_text"] = Action{
		"set_variable_strip_text",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"text", "text", nil},
			Slot{"strip_type", "enum", {"ALL", "START", "END", "INDENT"}},
		},
	}
	actions["set_variable_subtract"] = Action{
		"set_variable_subtract",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"value", "number", nil},
		},
	}
	actions["set_variable_subtract_vectors"] = Action{
		"set_variable_subtract_vectors",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"vectors", "vector", nil},
		},
	}
	actions["set_variable_tangent"] = Action{
		"set_variable_tangent",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"number", "number", nil},
			Slot{"variant", "enum", {"TANGENT", "ARCTANGENT", "HYPERBOLIC_TANGENT"}},
			Slot{"input", "enum", {"DEGREES", "RADIANS"}},
		},
	}
	actions["set_variable_text"] = Action{
		"set_variable_text",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"text", "text", nil},
			Slot{"merging", "enum", {"SPACES", "CONCATENATION", "SEPARATE_LINES"}},
		},
	}
	actions["set_variable_text_case"] = Action{
		"set_variable_text_case",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"text", "text", nil},
			Slot{"case_type", "enum", {"UPPER", "LOWER", "PROPER", "INVERT", "RANDOM"}},
		},
	}
	actions["set_variable_to_char"] = Action{
		"set_variable_to_char",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"number", "number", nil},
		},
	}
	actions["set_variable_to_hsb"] = Action{
		"set_variable_to_hsb",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"hue", "number", nil},
			Slot{"saturation", "number", nil},
			Slot{"brightness", "number", nil},
		},
	}
	actions["set_variable_to_hsl"] = Action{
		"set_variable_to_hsl",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"hue", "number", nil},
			Slot{"saturation", "number", nil},
			Slot{"lightness", "number", nil},
		},
	}
	actions["set_variable_to_json"] = Action{
		"set_variable_to_json",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"value", "any", nil},
			Slot{"pretty_print", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["set_variable_to_rgb"] = Action{
		"set_variable_to_rgb",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"red", "number", nil},
			Slot{"green", "number", nil},
			Slot{"blue", "number", nil},
		},
	}
	actions["set_variable_trim_list"] = Action{
		"set_variable_trim_list",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"list", "list", nil},
			Slot{"start", "number", nil},
			Slot{"end", "number", nil},
		},
	}
	actions["set_variable_trim_text"] = Action{
		"set_variable_trim_text",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"text", "text", nil},
			Slot{"start", "number", nil},
			Slot{"end", "number", nil},
		},
	}
	actions["set_variable_vector"] = Action{
		"set_variable_vector",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"x", "number", nil},
			Slot{"y", "number", nil},
			Slot{"z", "number", nil},
		},
	}
	actions["set_variable_vector_to_direction_name"] = Action{
		"set_variable_vector_to_direction_name",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"vector", "vector", nil},
		},
	}
	actions["set_variable_voronoi_noise_3d"] = Action{
		"set_variable_voronoi_noise_3d",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"location", "location", nil},
			Slot{"seed", "number", nil},
			Slot{"frequency", "number", nil},
			Slot{"displacement", "number", nil},
			Slot{"range_mode", "enum", {"ZERO_TO_ONE", "FULL_RANGE"}},
			Slot{"enable_distance", "enum", {"TRUE", "FALSE"}},
		},
	}
	actions["set_variable_warp"] = Action{
		"set_variable_warp",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"variable", "variable", nil},
			Slot{"number", "number", nil},
			Slot{"min", "number", nil},
			Slot{"max", "number", nil},
		},
	}
	actions["start_process"] = Action{
		"start_process",
		nil,
		nil,
		false,
		.BASIC,
		[]Slot{
			Slot{"process_name", "text", nil},
			Slot{"target_mode", "enum", {"CURRENT_TARGET", "CURRENT_SELECTION", "NO_TARGET", "FOR_EACH_IN_SELECTION"}},
			Slot{"local_variables_mode", "enum", {"DONT_COPY", "COPY", "SHARE"}},
		},
	}
}

@(fini)
cleanup_actions :: proc "contextless" () {
	context = runtime.default_context()
	delete(actions)
}

action_native_from_mapped :: proc(action_name: string) -> (Action, bool) {
	return actions[action_name]
}

