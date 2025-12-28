#+feature dynamic-literals
package assets

Action :: struct {
	name: string,
	type: Action_Type,
	accept_selector: bool,
	slots: [dynamic]Slot,
	in_slots: [dynamic]string,
	out_slots: [dynamic]string,
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
	_enum: [dynamic]string,
}

action_native_from_mapped :: proc(action_name: string, slots_allocator := context.allocator) -> (Action, bool) {
	context.allocator = slots_allocator
	slots := make([dynamic]Slot, slots_allocator)
	switch action_name {
	case "call_function":
		append(&slots, Slot{name="function_name", type="text"})
		return Action{
			name="call_function",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "control_call_exception":
		append(&slots, Slot{name="id", type="text"})
		append(&slots, Slot{name="message", type="text"})
		append(&slots, Slot{name="type", type="enum", _enum=[dynamic]string{"WARNING","ERROR","FATAL"}})
		return Action{
			name="control_call_exception",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "control_end_thread":
		return Action{
			name="control_end_thread",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "controller_async_run":
		return Action{
			name="controller_async_run",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "controller_exception":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="exception_type", type="enum", _enum=[dynamic]string{"WARNING","ERROR"}})
		return Action{
			name="controller_exception",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "controller_measure_time":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="duration", type="enum", _enum=[dynamic]string{"NANOSECONDS","MICROSECONDS","MILLISECONDS"}})
		return Action{
			name="controller_measure_time",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "control_return_function":
		return Action{
			name="control_return_function",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "control_skip_iteration":
		return Action{
			name="control_skip_iteration",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "control_stop_repeat":
		return Action{
			name="control_stop_repeat",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "control_wait":
		append(&slots, Slot{name="duration", type="number"})
		append(&slots, Slot{name="time_unit", type="enum", _enum=[dynamic]string{"TICKS","SECONDS","MINUTES"}})
		return Action{
			name="control_wait",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_attach_lead":
		append(&slots, Slot{name="name_or_uuid", type="text"})
		append(&slots, Slot{name="location", type="location"})
		return Action{
			name="entity_attach_lead",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_clear_merchant_recipes":
		return Action{
			name="entity_clear_merchant_recipes",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_celar_potion_effects":
		return Action{
			name="entity_celar_potion_effects",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_damage":
		append(&slots, Slot{name="damage", type="number"})
		append(&slots, Slot{name="source", type="text"})
		return Action{
			name="entity_damage",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_disguise_as_block":
		append(&slots, Slot{name="block", type="block"})
		return Action{
			name="entity_disguise_as_block",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_disguise_as_entity":
		append(&slots, Slot{name="entity_type", type="item"})
		return Action{
			name="entity_disguise_as_entity",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_disguise_as_item":
		append(&slots, Slot{name="item", type="item"})
		return Action{
			name="entity_disguise_as_item",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_disguise_as_player":
		append(&slots, Slot{name="name_or_uuid", type="text"})
		append(&slots, Slot{name="display_name", type="text"})
		append(&slots, Slot{name="server_type", type="enum", _enum=[dynamic]string{"MOJANG","SERVER"}})
		return Action{
			name="entity_disguise_as_player",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_eat_grass":
		return Action{
			name="entity_eat_grass",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_eat_target":
		append(&slots, Slot{name="name_or_uuid", type="text"})
		return Action{
			name="entity_eat_target",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_explode":
		return Action{
			name="entity_explode",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_face_location":
		append(&slots, Slot{name="location", type="location"})
		return Action{
			name="entity_face_location",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_get_custom_tag":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="name", type="text"})
		append(&slots, Slot{name="default", type="any"})
		return Action{
			name="entity_get_custom_tag",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_give_potion_effects":
		append(&slots, Slot{name="potions", type="potion"})
		append(&slots, Slot{name="overwrite", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		append(&slots, Slot{name="show_icon", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		append(&slots, Slot{name="particle_mode", type="enum", _enum=[dynamic]string{"REGULAR","AMBIENT","NONE"}})
		return Action{
			name="entity_give_potion_effects",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_heal":
		append(&slots, Slot{name="heal", type="number"})
		return Action{
			name="entity_heal",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_ignite_creeper":
		return Action{
			name="entity_ignite_creeper",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_jump":
		return Action{
			name="entity_jump",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_launch_forward":
		append(&slots, Slot{name="power", type="number"})
		append(&slots, Slot{name="increment", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		append(&slots, Slot{name="launch_axis", type="enum", _enum=[dynamic]string{"YAW_AND_PITCH","YAW"}})
		return Action{
			name="entity_launch_forward",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_launch_projectile":
		append(&slots, Slot{name="projectile", type="item"})
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="name", type="text"})
		append(&slots, Slot{name="speed", type="number"})
		append(&slots, Slot{name="inaccuracy", type="number"})
		append(&slots, Slot{name="trail", type="particle"})
		return Action{
			name="entity_launch_projectile",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_launch_to_location":
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="power", type="number"})
		append(&slots, Slot{name="increment", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="entity_launch_to_location",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_launch_up":
		append(&slots, Slot{name="power", type="number"})
		append(&slots, Slot{name="increment", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="entity_launch_up",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_modify_piglin_barter_materials":
		append(&slots, Slot{name="materials", type="item"})
		append(&slots, Slot{name="modification_mode", type="enum", _enum=[dynamic]string{"ADD","REMOVE"}})
		return Action{
			name="entity_modify_piglin_barter_materials",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_modify_piglin_interested_materials":
		append(&slots, Slot{name="materials", type="item"})
		append(&slots, Slot{name="modification_mode", type="enum", _enum=[dynamic]string{"ADD","REMOVE"}})
		return Action{
			name="entity_modify_piglin_interested_materials",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_move_to_location":
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="speed", type="number"})
		return Action{
			name="entity_move_to_location",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_move_to_location_stop":
		return Action{
			name="entity_move_to_location_stop",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_play_damage_animation":
		append(&slots, Slot{name="damage_type", type="enum", _enum=[dynamic]string{"DAMAGE","CRITICAL_DAMAGE","MAGICAL_DAMAGE"}})
		return Action{
			name="entity_play_damage_animation",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_play_hurt_animation":
		append(&slots, Slot{name="yaw", type="number"})
		return Action{
			name="entity_play_hurt_animation",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_ram_target":
		append(&slots, Slot{name="name_or_uuid", type="text"})
		return Action{
			name="entity_ram_target",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_remove":
		return Action{
			name="entity_remove",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_remove_custom_tag":
		append(&slots, Slot{name="name", type="text"})
		return Action{
			name="entity_remove_custom_tag",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_remove_disguise":
		return Action{
			name="entity_remove_disguise",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_remove_merchant_recipe":
		append(&slots, Slot{name="recipe_index", type="number"})
		return Action{
			name="entity_remove_merchant_recipe",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_remove_potion_effect":
		append(&slots, Slot{name="effects", type="potion"})
		return Action{
			name="entity_remove_potion_effect",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_reset_display_brightness":
		return Action{
			name="entity_reset_display_brightness",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_reset_display_glow_color":
		return Action{
			name="entity_reset_display_glow_color",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_reset_text_display_background":
		return Action{
			name="entity_reset_text_display_background",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_ride_entity":
		append(&slots, Slot{name="name_or_uuid", type="text"})
		return Action{
			name="entity_ride_entity",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_absorption_health":
		append(&slots, Slot{name="health", type="number"})
		return Action{
			name="entity_set_absorption_health",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_ai":
		append(&slots, Slot{name="ai", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="entity_set_ai",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_allay_dancing":
		append(&slots, Slot{name="dance", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="entity_set_allay_dancing",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_angry":
		append(&slots, Slot{name="angry", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		append(&slots, Slot{name="target", type="text"})
		return Action{
			name="entity_set_angry",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_animal_age":
		append(&slots, Slot{name="age", type="number"})
		append(&slots, Slot{name="lock", type="enum", _enum=[dynamic]string{"ENABLE","DISABLE","DONT_CHANGE"}})
		return Action{
			name="entity_set_animal_age",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_armor_items":
		append(&slots, Slot{name="helmet", type="item"})
		append(&slots, Slot{name="chestplate", type="item"})
		append(&slots, Slot{name="leggings", type="item"})
		append(&slots, Slot{name="boots", type="item"})
		return Action{
			name="entity_set_armor_items",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_armor_stand_parts":
		append(&slots, Slot{name="arms", type="enum", _enum=[dynamic]string{"ENABLE","DISABLE","DONT_CHANGE"}})
		append(&slots, Slot{name="base_plate", type="enum", _enum=[dynamic]string{"ENABLE","DISABLE","DONT_CHANGE"}})
		return Action{
			name="entity_set_armor_stand_parts",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_armor_stand_pose":
		append(&slots, Slot{name="x_rotation", type="number"})
		append(&slots, Slot{name="y_rotation", type="number"})
		append(&slots, Slot{name="z_rotation", type="number"})
		append(&slots, Slot{name="body_part", type="enum", _enum=[dynamic]string{"HEAD","BODY","LEFT_ARM","RIGHT_ARM","LEFT_LEG","RIGHT_LEG"}})
		return Action{
			name="entity_set_armor_stand_pose",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_attribute":
		append(&slots, Slot{name="value", type="number"})
		append(&slots, Slot{name="attribute_type", type="enum", _enum=[dynamic]string{}})
		return Action{
			name="entity_set_attribute",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_aware":
		append(&slots, Slot{name="aware", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="entity_set_aware",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_axolotl_type":
		append(&slots, Slot{name="axolotl_type", type="enum", _enum=[dynamic]string{"BLUE","CYAN","GOLD","LUCY","WILD"}})
		return Action{
			name="entity_set_axolotl_type",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_baby":
		append(&slots, Slot{name="baby", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="entity_set_baby",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_bee_nectar":
		append(&slots, Slot{name="nectar", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="entity_set_bee_nectar",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_block_display_block":
		append(&slots, Slot{name="displayed_block", type="block"})
		return Action{
			name="entity_set_block_display_block",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_camel_dashing":
		append(&slots, Slot{name="dashing", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="entity_set_camel_dashing",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_carrying_chest":
		append(&slots, Slot{name="carrying", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="entity_set_carrying_chest",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_cat_lying_down":
		append(&slots, Slot{name="lying_down", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="entity_set_cat_lying_down",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_cat_type":
		append(&slots, Slot{name="cat_type", type="enum", _enum=[dynamic]string{"ALL_BLACK","BLACK","BRITISH_SHORTHAIR","CALICO","JELLIE","PERSIAN","RAGDOLL","RED","SIAMESE","TABBY","WHITE"}})
		return Action{
			name="entity_set_cat_type",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_celebrating":
		append(&slots, Slot{name="celebrating", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="entity_set_celebrating",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_collidable":
		append(&slots, Slot{name="collidable", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="entity_set_collidable",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_creeper_charge":
		append(&slots, Slot{name="charged", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="entity_set_creeper_charge",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_creeper_fuse":
		append(&slots, Slot{name="fuse_ticks", type="number"})
		return Action{
			name="entity_set_creeper_fuse",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_current_health":
		append(&slots, Slot{name="health", type="number"})
		return Action{
			name="entity_set_current_health",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_custom_name":
		append(&slots, Slot{name="custom_name", type="text"})
		return Action{
			name="entity_set_custom_name",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_custom_name_visibility":
		append(&slots, Slot{name="visibility", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="entity_set_custom_name_visibility",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_custom_tag":
		append(&slots, Slot{name="name", type="text"})
		append(&slots, Slot{name="value", type="text"})
		return Action{
			name="entity_set_custom_tag",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_death_drops":
		append(&slots, Slot{name="drops", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="entity_set_death_drops",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_death_time":
		append(&slots, Slot{name="death_time", type="number"})
		return Action{
			name="entity_set_death_time",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_despawning":
		append(&slots, Slot{name="despawning", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="entity_set_despawning",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_display_billboard":
		append(&slots, Slot{name="billboard_type", type="enum", _enum=[dynamic]string{"CENTER","FIXED","HORIZONTAL","VERTICAL"}})
		return Action{
			name="entity_set_display_billboard",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_display_brightness":
		append(&slots, Slot{name="block_light_level", type="number"})
		append(&slots, Slot{name="sky_light_level", type="number"})
		return Action{
			name="entity_set_display_brightness",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_display_culling_suze":
		append(&slots, Slot{name="width", type="number"})
		append(&slots, Slot{name="height", type="number"})
		return Action{
			name="entity_set_display_culling_suze",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_display_glow_color":
		append(&slots, Slot{name="color_hexadecimal", type="text"})
		return Action{
			name="entity_set_display_glow_color",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_display_interpolation":
		append(&slots, Slot{name="interpolation_duration", type="number"})
		append(&slots, Slot{name="interpolation_delay", type="number"})
		return Action{
			name="entity_set_display_interpolation",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_display_rotation_from_axis_angle":
		append(&slots, Slot{name="axis_vector", type="vector"})
		append(&slots, Slot{name="angle", type="number"})
		append(&slots, Slot{name="mode", type="enum", _enum=[dynamic]string{"SET","ADD"}})
		append(&slots, Slot{name="input", type="enum", _enum=[dynamic]string{"DEGREES","RADIANS"}})
		append(&slots, Slot{name="rotation", type="enum", _enum=[dynamic]string{"LEFT_ROTATION","RIGHT_ROTATION"}})
		return Action{
			name="entity_set_display_rotation_from_axis_angle",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_display_rotation_from_euler_angles":
		append(&slots, Slot{name="pitch", type="number"})
		append(&slots, Slot{name="yaw", type="number"})
		append(&slots, Slot{name="roll", type="number"})
		append(&slots, Slot{name="mode", type="enum", _enum=[dynamic]string{"SET","ADD"}})
		append(&slots, Slot{name="input", type="enum", _enum=[dynamic]string{"DEGREES","RADIANS"}})
		append(&slots, Slot{name="rotation", type="enum", _enum=[dynamic]string{"LEFT_ROTATION","RIGHT_ROTATION"}})
		return Action{
			name="entity_set_display_rotation_from_euler_angles",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_display_scale":
		append(&slots, Slot{name="scale_vector", type="vector"})
		append(&slots, Slot{name="mode", type="enum", _enum=[dynamic]string{"SET","ADD"}})
		return Action{
			name="entity_set_display_scale",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_display_shadow":
		append(&slots, Slot{name="shadow_radius", type="number"})
		append(&slots, Slot{name="shadow_opacity_percentage", type="number"})
		return Action{
			name="entity_set_display_shadow",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_display_teleport_duration":
		append(&slots, Slot{name="duration", type="number"})
		return Action{
			name="entity_set_display_teleport_duration",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_display_transformation_matrix":
		append(&slots, Slot{name="row_major_matrix", type="number"})
		return Action{
			name="entity_set_display_transformation_matrix",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_display_translation":
		append(&slots, Slot{name="translation_vector", type="vector"})
		append(&slots, Slot{name="mode", type="enum", _enum=[dynamic]string{"SET","ADD"}})
		return Action{
			name="entity_set_display_translation",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_display_view_range":
		append(&slots, Slot{name="view_range", type="number"})
		return Action{
			name="entity_set_display_view_range",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_dragon_phase":
		append(&slots, Slot{name="phase", type="enum", _enum=[dynamic]string{"BREATH_ATTACK","CHARGE_PLAYER","CIRCLING","DYING","FLY_TO_PORTAL","HOVER","LAND_ON_PORTAL","LEAVE_PORTAL","ROAR_BEFORE_ATTACK","SEARCH_FOR_BREATH_ATTACK_TARGET","STRAFING"}})
		return Action{
			name="entity_set_dragon_phase",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_dye_color":
		append(&slots, Slot{name="color", type="enum", _enum=[dynamic]string{"BLACK","BLUE","BROWN","CYAN","GRAY","GREEN","LIGHT_BLUE","LIGHT_GRAY","LIME","MAGENTA","ORANGE","PINK","PURPLE","RED","WHITE","YELLOW"}})
		return Action{
			name="entity_set_dye_color",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_end_crystal_beam":
		append(&slots, Slot{name="beam", type="location"})
		return Action{
			name="entity_set_end_crystal_beam",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_enderman_block":
		append(&slots, Slot{name="block", type="block"})
		return Action{
			name="entity_set_enderman_block",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_equipment_item":
		append(&slots, Slot{name="item", type="item"})
		append(&slots, Slot{name="slot", type="enum", _enum=[dynamic]string{"CHEST","FEET","HAND","HEAD","LEGS","OFF_HAND"}})
		return Action{
			name="entity_set_equipment_item",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_explosive_power":
		append(&slots, Slot{name="power", type="number"})
		return Action{
			name="entity_set_explosive_power",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_fall_distance":
		append(&slots, Slot{name="fall_distance", type="number"})
		return Action{
			name="entity_set_fall_distance",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_falling_block_type":
		append(&slots, Slot{name="block", type="block"})
		return Action{
			name="entity_set_falling_block_type",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_fire_ticks":
		append(&slots, Slot{name="ticks", type="number"})
		return Action{
			name="entity_set_fire_ticks",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_fishing_wait":
		append(&slots, Slot{name="time", type="number"})
		return Action{
			name="entity_set_fishing_wait",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_fox_leaping":
		append(&slots, Slot{name="leaping", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="entity_set_fox_leaping",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_fox_type":
		append(&slots, Slot{name="fox_type", type="enum", _enum=[dynamic]string{"RED","SNOW"}})
		return Action{
			name="entity_set_fox_type",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_freeze_ticks":
		append(&slots, Slot{name="ticks", type="number"})
		append(&slots, Slot{name="ticking_locked", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="entity_set_freeze_ticks",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_frog_type":
		append(&slots, Slot{name="frog_variant", type="enum", _enum=[dynamic]string{"COLD","TEMPERATE","WARM"}})
		return Action{
			name="entity_set_frog_type",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_gliding":
		append(&slots, Slot{name="is_gliding", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="entity_set_gliding",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_glowing":
		append(&slots, Slot{name="glowing", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="entity_set_glowing",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_glow_squid_dark":
		append(&slots, Slot{name="dark_ticks", type="number"})
		return Action{
			name="entity_set_glow_squid_dark",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_goat_screaming":
		append(&slots, Slot{name="screams", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="entity_set_goat_screaming",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_gravity":
		append(&slots, Slot{name="gravity", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="entity_set_gravity",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_horse_jump":
		append(&slots, Slot{name="power", type="number"})
		return Action{
			name="entity_set_horse_jump",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_horse_pattern":
		append(&slots, Slot{name="horse_color", type="enum", _enum=[dynamic]string{"WHITE","CREAMY","CHESTNUT","BROWN","DARK_BROWN","GRAY","BLACK","DO_NOT_CHANGE"}})
		append(&slots, Slot{name="horse_style", type="enum", _enum=[dynamic]string{"NONE","WHITE","WHITEFIELD","WHITE_DOTS","BLACK_DOTS","DO_NOT_CHANGE"}})
		return Action{
			name="entity_set_horse_pattern",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_immune_to_zombification":
		append(&slots, Slot{name="is_immune", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="entity_set_immune_to_zombification",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_interaction_responsive":
		append(&slots, Slot{name="responsive", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="entity_set_interaction_responsive",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_interaction_size":
		append(&slots, Slot{name="width", type="number"})
		append(&slots, Slot{name="height", type="number"})
		return Action{
			name="entity_set_interaction_size",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_invisible":
		append(&slots, Slot{name="invisible", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="entity_set_invisible",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_invulnerability_ticks":
		append(&slots, Slot{name="ticks", type="number"})
		return Action{
			name="entity_set_invulnerability_ticks",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_invulnerable":
		append(&slots, Slot{name="invulnerable", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="entity_set_invulnerable",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_item":
		append(&slots, Slot{name="item", type="item"})
		return Action{
			name="entity_set_item",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_item_display_item":
		append(&slots, Slot{name="displayed_item", type="item"})
		return Action{
			name="entity_set_item_display_item",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_item_display_model_type":
		append(&slots, Slot{name="display_model_type", type="enum", _enum=[dynamic]string{"FIRSTPERSON_LEFTHAND","FIRSTPERSON_RIGHTHAND","FIXED","GROUND","GUI","HEAD","NONE","THIRDPERSON_LEFTHAND","THIRDPERSON_RIGHTHAND"}})
		return Action{
			name="entity_set_item_display_model_type",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_item_in_frame":
		append(&slots, Slot{name="item", type="item"})
		return Action{
			name="entity_set_item_in_frame",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_llama_type":
		append(&slots, Slot{name="type", type="enum", _enum=[dynamic]string{"BROWN","CREAMY","GRAY","WHITE"}})
		return Action{
			name="entity_set_llama_type",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_marker":
		append(&slots, Slot{name="marker", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="entity_set_marker",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_max_health":
		append(&slots, Slot{name="max_health", type="number"})
		append(&slots, Slot{name="heal_to_max", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="entity_set_max_health",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_merchant_recipe":
		append(&slots, Slot{name="result", type="item"})
		append(&slots, Slot{name="ingredient_one", type="item"})
		append(&slots, Slot{name="ingredient_two", type="item"})
		append(&slots, Slot{name="index", type="number"})
		append(&slots, Slot{name="mode", type="enum", _enum=[dynamic]string{"MERGE","APPEND"}})
		append(&slots, Slot{name="uses", type="number"})
		append(&slots, Slot{name="max_uses", type="number"})
		append(&slots, Slot{name="villager_experience", type="number"})
		append(&slots, Slot{name="price_multiplifier", type="number"})
		append(&slots, Slot{name="demand", type="number"})
		append(&slots, Slot{name="special_price", type="number"})
		append(&slots, Slot{name="ignore_discounts", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		append(&slots, Slot{name="experience_reward", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="entity_set_merchant_recipe",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_minecart_block":
		append(&slots, Slot{name="block", type="block"})
		append(&slots, Slot{name="block_offset", type="number"})
		return Action{
			name="entity_set_minecart_block",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_mob_aggressive":
		append(&slots, Slot{name="aggressive", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="entity_set_mob_aggressive",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_mushroom_cow_type":
		append(&slots, Slot{name="cow_type", type="enum", _enum=[dynamic]string{"BROWN","RED"}})
		return Action{
			name="entity_set_mushroom_cow_type",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_panda_gene":
		append(&slots, Slot{name="gene", type="enum", _enum=[dynamic]string{"MAIN","HIDDEN","BOTH"}})
		append(&slots, Slot{name="gene_type", type="enum", _enum=[dynamic]string{"NORMAL","LAZY","WORRIED","PLAYFUL","BROWN","WEAK","AGGRESSIVE"}})
		return Action{
			name="entity_set_panda_gene",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_parrot_type":
		append(&slots, Slot{name="parrot_type", type="enum", _enum=[dynamic]string{"BLUE","CYAN","GRAY","GREEN","RED"}})
		return Action{
			name="entity_set_parrot_type",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_persistence":
		append(&slots, Slot{name="persistence", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="entity_set_persistence",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_pickup_delay":
		append(&slots, Slot{name="delay", type="number"})
		return Action{
			name="entity_set_pickup_delay",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_piglin_able_to_hunt":
		append(&slots, Slot{name="able", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="entity_set_piglin_able_to_hunt",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_piglin_charging_crossbow":
		append(&slots, Slot{name="charging", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="entity_set_piglin_charging_crossbow",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_piglin_dancing":
		append(&slots, Slot{name="dancing_time", type="number"})
		return Action{
			name="entity_set_piglin_dancing",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_pose":
		append(&slots, Slot{name="pose", type="enum", _enum=[dynamic]string{"CROAKING","DIGGING","DYING","EMERGING","FALL_FLYING","LONG_JUMPING","ROARING","SLEEPING","SNEAKING","SNIFFING","SPIN_ATTACK","STANDING","SWIMMING","USING_TONGUE"}})
		return Action{
			name="entity_set_pose",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_potion_cloud_radius":
		append(&slots, Slot{name="radius", type="number"})
		append(&slots, Slot{name="shrinking_speed", type="number"})
		return Action{
			name="entity_set_potion_cloud_radius",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_primed_tnt_block":
		append(&slots, Slot{name="block", type="block"})
		return Action{
			name="entity_set_primed_tnt_block",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_projectile_display_item":
		append(&slots, Slot{name="item", type="item"})
		return Action{
			name="entity_set_projectile_display_item",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_projectile_shooter":
		append(&slots, Slot{name="uuid", type="text"})
		return Action{
			name="entity_set_projectile_shooter",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_rabbit_type":
		append(&slots, Slot{name="rabbit_type", type="enum", _enum=[dynamic]string{"BLACK","BLACK_AND_WHITE","BROWN","GOLD","SALT_AND_PEPPER","THE_KILLER_BUNNY","WHITE"}})
		return Action{
			name="entity_set_rabbit_type",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_rearing":
		append(&slots, Slot{name="rearing", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="entity_set_rearing",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_riptiding":
		append(&slots, Slot{name="riptiding", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="entity_set_riptiding",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_rotation":
		append(&slots, Slot{name="yaw", type="number"})
		append(&slots, Slot{name="pitch", type="number"})
		return Action{
			name="entity_set_rotation",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_rotation_by_vector":
		append(&slots, Slot{name="vector", type="vector"})
		return Action{
			name="entity_set_rotation_by_vector",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_sheep_sheared":
		append(&slots, Slot{name="sheared", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="entity_set_sheep_sheared",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_shulker_bullet_target":
		append(&slots, Slot{name="target", type="text"})
		return Action{
			name="entity_set_shulker_bullet_target",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_silenced":
		append(&slots, Slot{name="silenced", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="entity_set_silenced",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_sitting":
		append(&slots, Slot{name="sitting", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="entity_set_sitting",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_size":
		append(&slots, Slot{name="size", type="number"})
		return Action{
			name="entity_set_size",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_sniffer_state":
		append(&slots, Slot{name="state", type="enum", _enum=[dynamic]string{"DIGGING","FEELING_HAPPY","IDLING","RISING","SCENTING","SEARCHING","SNIFFING"}})
		return Action{
			name="entity_set_sniffer_state",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_snowman_pumpkin":
		append(&slots, Slot{name="pumpkin", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="entity_set_snowman_pumpkin",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_tame":
		append(&slots, Slot{name="name_or_uuid", type="text"})
		return Action{
			name="entity_set_tame",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_target":
		append(&slots, Slot{name="name_or_uuid", type="text"})
		return Action{
			name="entity_set_target",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_text_display_alignment":
		append(&slots, Slot{name="text_alignment", type="enum", _enum=[dynamic]string{"CENTER","LEFT","RIGHT"}})
		return Action{
			name="entity_set_text_display_alignment",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_text_display_background":
		append(&slots, Slot{name="color_hexadecimal", type="text"})
		append(&slots, Slot{name="opacity", type="number"})
		return Action{
			name="entity_set_text_display_background",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_text_display_line_width":
		append(&slots, Slot{name="line_width", type="number"})
		return Action{
			name="entity_set_text_display_line_width",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_text_display_opacity":
		append(&slots, Slot{name="text_opacity", type="number"})
		return Action{
			name="entity_set_text_display_opacity",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_text_display_see_through":
		append(&slots, Slot{name="enable_see_through", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="entity_set_text_display_see_through",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_text_display_text":
		append(&slots, Slot{name="displayed_text", type="text"})
		append(&slots, Slot{name="merging_mode", type="enum", _enum=[dynamic]string{"SPACES","CONCATENATION","SEPARATE_LINES"}})
		return Action{
			name="entity_set_text_display_text",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_text_display_text_shadow":
		append(&slots, Slot{name="enable_text_shadow", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="entity_set_text_display_text_shadow",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_tropical_fish_pattern":
		append(&slots, Slot{name="pattern_color", type="enum", _enum=[dynamic]string{"WHITE","ORANGE","MAGENTA","LIGHT_BLUE","YELLOW","LIME","PINK","GRAY","LIGHT_GRAY","CYAN","PURPLE","BLUE","BROWN","GREEN","RED","BLACK","DO_NOT_CHANGE"}})
		append(&slots, Slot{name="body_color", type="enum", _enum=[dynamic]string{"WHITE","ORANGE","MAGENTA","LIGHT_BLUE","YELLOW","LIME","PINK","GRAY","LIGHT_GRAY","CYAN","PURPLE","BLUE","BROWN","GREEN","RED","BLACK","DO_NOT_CHANGE"}})
		append(&slots, Slot{name="pattern", type="enum", _enum=[dynamic]string{"KOB","SUNSTREAK","SNOOPER","DASHER","BRINELY","SPOTTY","FLOPPER","STRIPEY","GLITTER","BLOCKFISH","BETTY","CLAYFISH","DO_NOT_CHANGE"}})
		return Action{
			name="entity_set_tropical_fish_pattern",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_location":
		append(&slots, Slot{name="velocity", type="vector"})
		append(&slots, Slot{name="increment", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="entity_set_location",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_vex_charging":
		append(&slots, Slot{name="charging", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="entity_set_vex_charging",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_vex_limited_lifetime_ticks":
		append(&slots, Slot{name="lifetime", type="number"})
		return Action{
			name="entity_set_vex_limited_lifetime_ticks",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_villager_biome":
		append(&slots, Slot{name="biome", type="enum", _enum=[dynamic]string{"DESERT","JUNGLE","PLAINS","SAVANNA","SNOW","SWAMP","TAIGA"}})
		return Action{
			name="entity_set_villager_biome",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_villager_experience":
		append(&slots, Slot{name="experience", type="number"})
		return Action{
			name="entity_set_villager_experience",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_villager_profession":
		append(&slots, Slot{name="profession", type="enum", _enum=[dynamic]string{"NONE","ARMORER","BUTCHER","CARTOGRAPHER","CLERIC","FARMER","FISHERMAN","FLETCHER","LEATHERWORKER","LIBRARIAN","MASON","NITWIT","SHEPHERD","TOOLSMITH","WEAPONSMITH"}})
		return Action{
			name="entity_set_villager_profession",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_visual_fire":
		append(&slots, Slot{name="visual_fire", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="entity_set_visual_fire",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_warden_anger_level":
		append(&slots, Slot{name="name_or_uuid", type="text"})
		append(&slots, Slot{name="anger", type="number"})
		return Action{
			name="entity_set_warden_anger_level",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_warden_digging":
		append(&slots, Slot{name="digging", type="enum", _enum=[dynamic]string{"EMERGE","DIG_DOWN"}})
		return Action{
			name="entity_set_warden_digging",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_wearing_saddle":
		append(&slots, Slot{name="wearing", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="entity_set_wearing_saddle",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_wither_invulnerability_ticks":
		append(&slots, Slot{name="ticks", type="number"})
		return Action{
			name="entity_set_wither_invulnerability_ticks",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_set_zombie_arms_raised":
		append(&slots, Slot{name="arms_raised", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="entity_set_zombie_arms_raised",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_shear_sheep":
		return Action{
			name="entity_shear_sheep",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_sleep":
		append(&slots, Slot{name="sleep", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="entity_sleep",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_swing_hand":
		append(&slots, Slot{name="hand_type", type="enum", _enum=[dynamic]string{"MAIN","OFF"}})
		return Action{
			name="entity_swing_hand",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_teleport":
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="keep_rotation", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="entity_teleport",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "entity_use_item":
		append(&slots, Slot{name="hand", type="enum", _enum=[dynamic]string{"MAIN_HAND","OFF_HAND"}})
		append(&slots, Slot{name="enable", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="entity_use_item",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_block_growth":
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="growth_stage", type="number"})
		append(&slots, Slot{name="growth_type", type="enum", _enum=[dynamic]string{"STAGE_NUMBER","PERCENTAGE"}})
		return Action{
			name="game_block_growth",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_bloom_skulk_catalyst":
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="bloom_location", type="location"})
		append(&slots, Slot{name="charge", type="number"})
		return Action{
			name="game_bloom_skulk_catalyst",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_bone_meal_block":
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="count", type="number"})
		return Action{
			name="game_bone_meal_block",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_break_block":
		append(&slots, Slot{name="locations", type="location"})
		append(&slots, Slot{name="tool", type="item"})
		append(&slots, Slot{name="drop_exp", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="game_break_block",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_cancel_event":
		return Action{
			name="game_cancel_event",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_clear_container":
		append(&slots, Slot{name="location", type="location"})
		return Action{
			name="game_clear_container",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_clear_container_items":
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="items", type="item"})
		return Action{
			name="game_clear_container_items",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_clear_exploded_blocks":
		append(&slots, Slot{name="location", type="location"})
		return Action{
			name="game_clear_exploded_blocks",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_clear_region":
		append(&slots, Slot{name="pos_1", type="location"})
		append(&slots, Slot{name="pos_2", type="location"})
		return Action{
			name="game_clear_region",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_clear_scoreboard_scores":
		append(&slots, Slot{name="id", type="text"})
		return Action{
			name="game_clear_scoreboard_scores",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_clone_region":
		append(&slots, Slot{name="pos_1", type="location"})
		append(&slots, Slot{name="pos_2", type="location"})
		append(&slots, Slot{name="target_pos", type="location"})
		append(&slots, Slot{name="paste_pos", type="location"})
		append(&slots, Slot{name="ignore_air", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		append(&slots, Slot{name="copy_entity", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="game_clone_region",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_create_explosion":
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="power", type="number"})
		return Action{
			name="game_create_explosion",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_create_scoreboard":
		append(&slots, Slot{name="id", type="text"})
		append(&slots, Slot{name="display_name", type="text"})
		return Action{
			name="game_create_scoreboard",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_fill_container":
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="items", type="item"})
		return Action{
			name="game_fill_container",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_generate_tree":
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="tree_type", type="enum", _enum=[dynamic]string{"TREE","ACACIA","BIG_TREE","BIRCH","BROWN_MUSHROOM","CHORUS_PLANT","COCOA_TREE","CRIMSON_FUNGUS","DARK_OAK","JUNGLE","JUNGLE_BUSH","MEGA_REDWOOD","REDWOOD","RED_MUSHROOM","SMALL_JUNGLE","SWAMP","TALL_BIRCH","TALL_REDWOOD","WARPED_FUNGUS","AZALEA"}})
		return Action{
			name="game_generate_tree",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_hide_event_message":
		append(&slots, Slot{name="hide", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="game_hide_event_message",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_launch_firework":
		append(&slots, Slot{name="firework", type="item"})
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="movement", type="enum", _enum=[dynamic]string{"UPWARDS","DIRECTIONAL"}})
		append(&slots, Slot{name="instant", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="game_launch_firework",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_launch_projectile":
		append(&slots, Slot{name="projectile", type="item"})
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="speed", type="number"})
		append(&slots, Slot{name="inaccuracy", type="number"})
		append(&slots, Slot{name="custom_name", type="text"})
		append(&slots, Slot{name="trail", type="particle"})
		return Action{
			name="game_launch_projectile",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_random_tick_block":
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="times", type="number"})
		return Action{
			name="game_random_tick_block",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_remove_container_items":
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="items", type="item"})
		return Action{
			name="game_remove_container_items",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_remove_scoreboard":
		append(&slots, Slot{name="id", type="text"})
		return Action{
			name="game_remove_scoreboard",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_remove_scoreboard_score_by_name":
		append(&slots, Slot{name="id", type="text"})
		append(&slots, Slot{name="text", type="text"})
		return Action{
			name="game_remove_scoreboard_score_by_name",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_remove_scoreboard_score_by_score":
		append(&slots, Slot{name="id", type="text"})
		append(&slots, Slot{name="score", type="number"})
		return Action{
			name="game_remove_scoreboard_score_by_score",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_replace_blocks_in_region":
		append(&slots, Slot{name="old_block", type="block"})
		append(&slots, Slot{name="pos_1", type="location"})
		append(&slots, Slot{name="pos_2", type="location"})
		append(&slots, Slot{name="new_block", type="block"})
		return Action{
			name="game_replace_blocks_in_region",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_replace_container_items":
		append(&slots, Slot{name="items", type="item"})
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="replace", type="item"})
		append(&slots, Slot{name="count", type="number"})
		return Action{
			name="game_replace_container_items",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_send_web_request":
		append(&slots, Slot{name="url", type="text"})
		append(&slots, Slot{name="content_body", type="text"})
		append(&slots, Slot{name="request_type", type="enum", _enum=[dynamic]string{"GET","POST","PUT","DELETE"}})
		append(&slots, Slot{name="content_type", type="enum", _enum=[dynamic]string{"TEXT_PLAIN","APPLICATION_JSON"}})
		return Action{
			name="game_send_web_request",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_set_age":
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="tick", type="number"})
		return Action{
			name="game_set_age",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_set_block_analogue_power":
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="power_level", type="number"})
		return Action{
			name="game_set_block_analogue_power",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_set_block":
		append(&slots, Slot{name="block", type="block"})
		append(&slots, Slot{name="locations", type="location"})
		append(&slots, Slot{name="update_blocks", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="game_set_block",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_set_block_custom_tag":
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="tag_name", type="text"})
		append(&slots, Slot{name="tag_value", type="text"})
		return Action{
			name="game_set_block_custom_tag",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_set_block_data":
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="block_data", type="text"})
		return Action{
			name="game_set_block_data",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_set_block_drops_enabled":
		append(&slots, Slot{name="enable", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="game_set_block_drops_enabled",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_set_block_single_data":
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="data", type="text"})
		append(&slots, Slot{name="value", type="text"})
		return Action{
			name="game_set_block_single_data",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_set_brushable_block_item":
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="item", type="item"})
		return Action{
			name="game_set_brushable_block_item",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_set_campfire_item":
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="item", type="item"})
		append(&slots, Slot{name="cooking_time", type="number"})
		append(&slots, Slot{name="slot", type="enum", _enum=[dynamic]string{"FIRST","SECOND","THIRD","FOURTH"}})
		return Action{
			name="game_set_campfire_item",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_set_container":
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="items", type="item"})
		return Action{
			name="game_set_container",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_set_container_lock":
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="container_key", type="text"})
		return Action{
			name="game_set_container_lock",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_set_container_name":
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="name", type="text"})
		return Action{
			name="game_set_container_name",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_set_decorate_pot_sherd":
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="item", type="item"})
		append(&slots, Slot{name="side", type="enum", _enum=[dynamic]string{"BACK","FRONT","LEFT","RIGHT"}})
		return Action{
			name="game_set_decorate_pot_sherd",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_set_event_damage":
		append(&slots, Slot{name="damage", type="number"})
		return Action{
			name="game_set_event_damage",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_set_event_exhaustion":
		append(&slots, Slot{name="exhaustion", type="number"})
		return Action{
			name="game_set_event_exhaustion",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_set_event_experience":
		append(&slots, Slot{name="experience", type="number"})
		return Action{
			name="game_set_event_experience",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_set_event_heal":
		append(&slots, Slot{name="heal", type="number"})
		return Action{
			name="game_set_event_heal",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_set_event_item":
		append(&slots, Slot{name="item", type="item"})
		return Action{
			name="game_set_event_item",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_set_event_items":
		append(&slots, Slot{name="items", type="item"})
		return Action{
			name="game_set_event_items",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_set_event_move_allowed":
		append(&slots, Slot{name="allowed", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="game_set_event_move_allowed",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_set_event_projectile":
		append(&slots, Slot{name="projectile", type="item"})
		append(&slots, Slot{name="name", type="text"})
		return Action{
			name="game_set_event_projectile",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_set_event_uery_info":
		append(&slots, Slot{name="information", type="text"})
		return Action{
			name="game_set_event_uery_info",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_set_event_sound":
		append(&slots, Slot{name="sound", type="sound"})
		return Action{
			name="game_set_event_sound",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_set_event_source_slot":
		append(&slots, Slot{name="source_slot", type="number"})
		return Action{
			name="game_set_event_source_slot",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_set_event_target_slot":
		append(&slots, Slot{name="target", type="number"})
		return Action{
			name="game_set_event_target_slot",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_set_furnace_cook_time":
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="time", type="number"})
		return Action{
			name="game_set_furnace_cook_time",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_set_item_in_container_slot":
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="item", type="item"})
		append(&slots, Slot{name="slot", type="number"})
		return Action{
			name="game_set_item_in_container_slot",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_set_lectern_book":
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="item", type="item"})
		append(&slots, Slot{name="page", type="number"})
		return Action{
			name="game_set_lectern_book",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_set_player_head":
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="name_or_uuid", type="text"})
		append(&slots, Slot{name="receive_type", type="enum", _enum=[dynamic]string{"NAME_OR_UUID","VALUE"}})
		return Action{
			name="game_set_player_head",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_set_block_powered":
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="powered", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="game_set_block_powered",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_set_region":
		append(&slots, Slot{name="block", type="block"})
		append(&slots, Slot{name="pos_1", type="location"})
		append(&slots, Slot{name="pos_2", type="location"})
		return Action{
			name="game_set_region",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_set_scoreboard_line":
		append(&slots, Slot{name="id", type="text"})
		append(&slots, Slot{name="line", type="text"})
		append(&slots, Slot{name="display", type="text"})
		append(&slots, Slot{name="score", type="number"})
		append(&slots, Slot{name="format_content", type="text"})
		append(&slots, Slot{name="format", type="enum", _enum=[dynamic]string{"BLANK","FIXED","STYLED","RESET"}})
		return Action{
			name="game_set_scoreboard_line",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_set_scoreboard_line_display":
		append(&slots, Slot{name="id", type="text"})
		append(&slots, Slot{name="line", type="text"})
		append(&slots, Slot{name="display", type="text"})
		return Action{
			name="game_set_scoreboard_line_display",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_set_scoreboard_line_format":
		append(&slots, Slot{name="id", type="text"})
		append(&slots, Slot{name="line", type="text"})
		append(&slots, Slot{name="format_content", type="text"})
		append(&slots, Slot{name="format", type="enum", _enum=[dynamic]string{"BLANK","FIXED","STYLED","RESET"}})
		return Action{
			name="game_set_scoreboard_line_format",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_set_scoreboard_number_format":
		append(&slots, Slot{name="id", type="text"})
		append(&slots, Slot{name="format_content", type="text"})
		append(&slots, Slot{name="format", type="enum", _enum=[dynamic]string{"BLANK","FIXED","STYLED","RESET"}})
		return Action{
			name="game_set_scoreboard_number_format",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_set_scoreboard_score":
		append(&slots, Slot{name="id", type="text"})
		append(&slots, Slot{name="text", type="text"})
		append(&slots, Slot{name="score", type="number"})
		return Action{
			name="game_set_scoreboard_score",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_set_scoreboard_title":
		append(&slots, Slot{name="id", type="text"})
		append(&slots, Slot{name="title", type="text"})
		return Action{
			name="game_set_scoreboard_title",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_set_sculk_shrieker_can_summon":
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="can_summon", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="game_set_sculk_shrieker_can_summon",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_set_sculk_shrieker_shrieking":
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="shrieking", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="game_set_sculk_shrieker_shrieking",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_set_sculk_shrieker_warning_level":
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="warning_level", type="number"})
		return Action{
			name="game_set_sculk_shrieker_warning_level",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_set_sign_text":
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="text", type="text"})
		append(&slots, Slot{name="line", type="number"})
		append(&slots, Slot{name="side", type="enum", _enum=[dynamic]string{"FRONT","BACK","ALL"}})
		return Action{
			name="game_set_sign_text",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_set_sign_text_color":
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="side", type="enum", _enum=[dynamic]string{"FRONT","BACK","ALL"}})
		append(&slots, Slot{name="sign_text_color", type="enum", _enum=[dynamic]string{"BLACK","BLUE","BROWN","CYAN","GRAY","GREEN","LIGHT_BLUE","LIGHT_GRAY","LIME","MAGENTA","ORANGE","PINK","PURPLE","RED","WHITE","YELLOW"}})
		append(&slots, Slot{name="glowing", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="game_set_sign_text_color",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_set_sign_waxed":
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="waxed", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="game_set_sign_waxed",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_set_spawner_entity":
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="entity", type="item"})
		return Action{
			name="game_set_spawner_entity",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_set_world_difficulty":
		append(&slots, Slot{name="difficulty", type="enum", _enum=[dynamic]string{"EASY","HARD","NORMAL","PEACEFUL"}})
		return Action{
			name="game_set_world_difficulty",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_set_world_simulation_distance":
		append(&slots, Slot{name="distance", type="number"})
		return Action{
			name="game_set_world_simulation_distance",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_set_world_time":
		append(&slots, Slot{name="time", type="number"})
		return Action{
			name="game_set_world_time",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_set_world_weather":
		append(&slots, Slot{name="weather_type", type="enum", _enum=[dynamic]string{"CLEAR","RAINING","THUNDER"}})
		append(&slots, Slot{name="weather_duration", type="number"})
		return Action{
			name="game_set_world_weather",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_spawn_armor_stand":
		append(&slots, Slot{name="helmet", type="item"})
		append(&slots, Slot{name="chestplate", type="item"})
		append(&slots, Slot{name="leggings", type="item"})
		append(&slots, Slot{name="boots", type="item"})
		append(&slots, Slot{name="right_hand", type="item"})
		append(&slots, Slot{name="left_hand", type="item"})
		append(&slots, Slot{name="gravity", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		append(&slots, Slot{name="marker", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		append(&slots, Slot{name="small", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		append(&slots, Slot{name="show_arms", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		append(&slots, Slot{name="base_plate", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		append(&slots, Slot{name="invisible", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="custom_name", type="text"})
		return Action{
			name="game_spawn_armor_stand",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_spawn_block_display":
		append(&slots, Slot{name="spawn_location", type="location"})
		append(&slots, Slot{name="custom_name", type="text"})
		append(&slots, Slot{name="block", type="block"})
		return Action{
			name="game_spawn_block_display",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_spawn_effect_cloud":
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="effects", type="potion"})
		append(&slots, Slot{name="radius", type="number"})
		append(&slots, Slot{name="duration", type="number"})
		append(&slots, Slot{name="particle", type="particle"})
		append(&slots, Slot{name="custom_name", type="text"})
		return Action{
			name="game_spawn_effect_cloud",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_spawn_end_crystal":
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="custom_name", type="text"})
		append(&slots, Slot{name="show_bottom", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="game_spawn_end_crystal",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_spawn_evoker_fangs":
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="custom_name", type="text"})
		return Action{
			name="game_spawn_evoker_fangs",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_spawn_experience_orb":
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="experience_amount", type="number"})
		append(&slots, Slot{name="custom_name", type="text"})
		return Action{
			name="game_spawn_experience_orb",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_spawn_eye_of_ender":
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="destination", type="location"})
		append(&slots, Slot{name="lifespan", type="number"})
		append(&slots, Slot{name="custom_name", type="text"})
		append(&slots, Slot{name="end_of_lifespan", type="enum", _enum=[dynamic]string{"DROP","SHATTER","RANDOM"}})
		return Action{
			name="game_spawn_eye_of_ender",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_spawn_falling_block":
		append(&slots, Slot{name="block", type="block"})
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="name", type="text"})
		append(&slots, Slot{name="should_expire", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="game_spawn_falling_block",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_spawn_interaction_entity":
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="custom_name", type="text"})
		append(&slots, Slot{name="width", type="number"})
		append(&slots, Slot{name="height", type="number"})
		append(&slots, Slot{name="responsive", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="game_spawn_interaction_entity",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_spawn_item":
		append(&slots, Slot{name="item", type="item"})
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="custom_name", type="text"})
		append(&slots, Slot{name="apply_motion", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		append(&slots, Slot{name="can_mob_pickup", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		append(&slots, Slot{name="can_player_pickup", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="game_spawn_item",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_spawn_item_display":
		append(&slots, Slot{name="spawn_location", type="location"})
		append(&slots, Slot{name="custom_name", type="text"})
		append(&slots, Slot{name="displayed_item", type="item"})
		return Action{
			name="game_spawn_item_display",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_spawn_lightning_bolt":
		append(&slots, Slot{name="location", type="location"})
		return Action{
			name="game_spawn_lightning_bolt",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_spawn_mob":
		append(&slots, Slot{name="mob", type="item"})
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="health", type="number"})
		append(&slots, Slot{name="custom_name", type="text"})
		append(&slots, Slot{name="potion_effects", type="potion"})
		append(&slots, Slot{name="main_hand", type="item"})
		append(&slots, Slot{name="helmet", type="item"})
		append(&slots, Slot{name="chestplate", type="item"})
		append(&slots, Slot{name="leggings", type="item"})
		append(&slots, Slot{name="boots", type="item"})
		append(&slots, Slot{name="off_hand", type="item"})
		append(&slots, Slot{name="natural_equipment", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="game_spawn_mob",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_spawn_primed_tnt":
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="tnt_power", type="number"})
		append(&slots, Slot{name="fuse_duration", type="number"})
		append(&slots, Slot{name="custom_name", type="text"})
		append(&slots, Slot{name="block", type="block"})
		return Action{
			name="game_spawn_primed_tnt",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_spawn_shulker_bullet":
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="custom_name", type="text"})
		return Action{
			name="game_spawn_shulker_bullet",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_spawn_text_display":
		append(&slots, Slot{name="spawn_location", type="location"})
		append(&slots, Slot{name="custom_name", type="text"})
		append(&slots, Slot{name="merging_mode", type="enum", _enum=[dynamic]string{"SPACES","CONCATENATION","SEPARATE_LINES"}})
		append(&slots, Slot{name="displayed_text", type="text"})
		return Action{
			name="game_spawn_text_display",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_spawn_vehicle":
		append(&slots, Slot{name="vehicle", type="item"})
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="custom_name", type="text"})
		return Action{
			name="game_spawn_vehicle",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_uncancel_event":
		return Action{
			name="game_uncancel_event",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "game_update_block":
		append(&slots, Slot{name="location", type="location"})
		return Action{
			name="game_update_block",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "if_entity_collides_at_location":
		append(&slots, Slot{name="location", type="location"})
		return Action{
			name="if_entity_collides_at_location",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_entity_collides_using_hitbox":
		append(&slots, Slot{name="min", type="location"})
		append(&slots, Slot{name="max", type="location"})
		return Action{
			name="if_entity_collides_using_hitbox",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_entity_collides_with_entity":
		append(&slots, Slot{name="name_or_uuid", type="text"})
		append(&slots, Slot{name="check_type", type="enum", _enum=[dynamic]string{"OVERLAPS","CONTAINS"}})
		return Action{
			name="if_entity_collides_with_entity",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_entity_exists":
		return Action{
			name="if_entity_exists",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_entity_has_custom_tag":
		append(&slots, Slot{name="tag", type="text"})
		append(&slots, Slot{name="tag_value", type="text"})
		return Action{
			name="if_entity_has_custom_tag",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_entity_has_potion_effect":
		append(&slots, Slot{name="potions", type="potion"})
		append(&slots, Slot{name="check_mode", type="enum", _enum=[dynamic]string{"ANY","ALL"}})
		return Action{
			name="if_entity_has_potion_effect",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_entity_is_disguised":
		return Action{
			name="if_entity_is_disguised",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_entity_is_grounded":
		return Action{
			name="if_entity_is_grounded",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_entity_in_area":
		append(&slots, Slot{name="location_1", type="location"})
		append(&slots, Slot{name="location_2", type="location"})
		append(&slots, Slot{name="ignore_y_axis", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		append(&slots, Slot{name="intersect_type", type="enum", _enum=[dynamic]string{"POINT","HITBOX"}})
		append(&slots, Slot{name="check_type", type="enum", _enum=[dynamic]string{"OVERLAPS","CONTAINS"}})
		return Action{
			name="if_entity_in_area",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_entity_is_item":
		return Action{
			name="if_entity_is_item",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_entity_is_mob":
		return Action{
			name="if_entity_is_mob",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_entity_is_near_location":
		append(&slots, Slot{name="ignore_y_axis", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="range", type="number"})
		return Action{
			name="if_entity_is_near_location",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_entity_is_projectile":
		return Action{
			name="if_entity_is_projectile",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_entity_is_riding_entity":
		append(&slots, Slot{name="entity_ids", type="text"})
		append(&slots, Slot{name="compare_mode", type="enum", _enum=[dynamic]string{"NEAREST","FARTHEST"}})
		return Action{
			name="if_entity_is_riding_entity",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_entity_is_standing_on_block":
		append(&slots, Slot{name="blocks", type="block"})
		append(&slots, Slot{name="locations", type="location"})
		append(&slots, Slot{name="only_solid", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="if_entity_is_standing_on_block",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_entity_is_type":
		append(&slots, Slot{name="entity_types", type="item"})
		return Action{
			name="if_entity_is_type",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_entity_is_vehicle":
		return Action{
			name="if_entity_is_vehicle",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_entity_name_equals":
		append(&slots, Slot{name="names_or_uuids", type="text"})
		return Action{
			name="if_entity_name_equals",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_entity_spawn_reason_equals":
		append(&slots, Slot{name="reason", type="enum", _enum=[dynamic]string{"BEEHIVE","BREEDING","BUILD_IRONGOLEM","BUILD_SNOWMAN","BUILD_WITHER","COMMAND","CURED","CUSTOM","DEFAULT","DISPENSE_EGG","DROWNED","EGG","ENDER_PEARL","EXPLOSION","FROZEN","INFECTION","JOCKEY","LIGHTNING","MOUNT","NATURAL","NETHER_PORTAL","OCELOT_BABY","PATROL","PIGLIN_ZOMBIFIED","RAID","REINFORCEMENTS","SHEARED","SHOULDER_ENTITY","SILVERFISH_BLOCK","SLIME_SPLIT","SPAWNER","SPAWNER_EGG","TRAP","VILLAGER_DEFENSE","VILLAGE_INVASION"}})
		return Action{
			name="if_entity_spawn_reason_equals",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_game_block_equals":
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="blocks", type="block"})
		return Action{
			name="if_game_block_equals",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_game_block_powered":
		append(&slots, Slot{name="locations", type="location"})
		append(&slots, Slot{name="power_mode", type="enum", _enum=[dynamic]string{"DIRECT","INDIRECT"}})
		return Action{
			name="if_game_block_powered",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_game_chunk_is_loaded":
		append(&slots, Slot{name="location", type="location"})
		return Action{
			name="if_game_chunk_is_loaded",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_game_container_has":
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="items", type="item"})
		append(&slots, Slot{name="check_mode", type="enum", _enum=[dynamic]string{"ANY","ALL"}})
		append(&slots, Slot{name="comparison_mode", type="enum", _enum=[dynamic]string{"EXACTLY","IGNORE_STACK_SIZE","IGNORE_DURABILITY_AND_STACK_SIZE","TYPE_ONLY"}})
		return Action{
			name="if_game_container_has",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_game_container_has_room_for_item":
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="items", type="item"})
		append(&slots, Slot{name="check_mode", type="enum", _enum=[dynamic]string{"ANY","ALL"}})
		return Action{
			name="if_game_container_has_room_for_item",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_game_damage_cause_equals":
		append(&slots, Slot{name="cause", type="enum", _enum=[dynamic]string{"BLOCK_EXPLOSION","CONTACT","CRAMMING","CUSTOM","DRAGON_BREATH","DROWNING","DRYOUT","ENTITY_ATTACK","ENTITY_EXPLOSION","ENTITY_SWEEP_ATTACK","FALL","FALLING_BLOCK","FIRE","FIRE_TICK","FLY_INTO_WALL","FREEZE","HOT_FLOOR","LAVA","LIGHTNING","MAGIC","MELTING","POISON","PROJECTILE","STARVATION","SUFFOCATION","SUICIDE","THORNS","VOID","WITHER"}})
		return Action{
			name="if_game_damage_cause_equals",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_game_event_attack_is_critical":
		return Action{
			name="if_game_event_attack_is_critical",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_game_event_block_equals":
		append(&slots, Slot{name="blocks", type="block"})
		append(&slots, Slot{name="locations", type="location"})
		return Action{
			name="if_game_event_block_equals",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_game_event_is_canceled":
		return Action{
			name="if_game_event_is_canceled",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_game_event_item_equals":
		append(&slots, Slot{name="items", type="item"})
		append(&slots, Slot{name="comparison_mode", type="enum", _enum=[dynamic]string{"EXACTLY","IGNORE_STACK_SIZE","IGNORE_DURABILITY_AND_STACK_SIZE","TYPE_ONLY"}})
		return Action{
			name="if_game_event_item_equals",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_game_has_player":
		append(&slots, Slot{name="names_or_uuids", type="text"})
		return Action{
			name="if_game_has_player",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_game_heal_cause_equals":
		append(&slots, Slot{name="heal_cause", type="enum", _enum=[dynamic]string{"CUSTOM","EATING","ENDER_CRYSTAL","MAGIC","MAGIC_REGEN","REGEN","SATIATED","WITHER","WITHER_SPAWN"}})
		return Action{
			name="if_game_heal_cause_equals",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_game_ignite_cause_equals":
		append(&slots, Slot{name="cause", type="enum", _enum=[dynamic]string{"ARROW","ENDER_CRYSTAL","EXPLOSION","FIREBALL","FLINT_AND_STEEL","LAVA","LIGHTNING","SPREAD"}})
		return Action{
			name="if_game_ignite_cause_equals",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_game_instrument_equals":
		append(&slots, Slot{name="instrument", type="enum", _enum=[dynamic]string{"BANJO","BASS_DRUM","BASS_GUITAR","BELL","BIT","CHIME","COW_BELL","DIDGERIDOO","FLUTE","GUITAR","IRON_XYLOPHONE","PIANO","PLING","SNARE_DRUM","STICKS","XYLOPHONE"}})
		return Action{
			name="if_game_instrument_equals",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_game_sign_contains":
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="texts", type="text"})
		append(&slots, Slot{name="check_side", type="enum", _enum=[dynamic]string{"ANY","FRONT","BACK"}})
		append(&slots, Slot{name="check_mode", type="enum", _enum=[dynamic]string{"ANY","ALL"}})
		append(&slots, Slot{name="lines", type="enum", _enum=[dynamic]string{"FIRST","SECOND","THIRD","FOURTH","ALL"}})
		return Action{
			name="if_game_sign_contains",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_player_chat_message_equals":
		append(&slots, Slot{name="chat_messages", type="text"})
		return Action{
			name="if_player_chat_message_equals",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_player_collides_at_location":
		append(&slots, Slot{name="location", type="location"})
		return Action{
			name="if_player_collides_at_location",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_player_collides_using_hitbox":
		append(&slots, Slot{name="min", type="location"})
		append(&slots, Slot{name="max", type="location"})
		return Action{
			name="if_player_collides_using_hitbox",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_player_collides_with_entity":
		append(&slots, Slot{name="name_or_uuid", type="text"})
		append(&slots, Slot{name="check_type", type="enum", _enum=[dynamic]string{"OVERLAPS","CONTAINS"}})
		return Action{
			name="if_player_collides_with_entity",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_player_cursor_item_equals":
		append(&slots, Slot{name="items", type="item"})
		append(&slots, Slot{name="comparison_mode", type="enum", _enum=[dynamic]string{"EXACTLY","IGNORE_STACK_SIZE","IGNORE_DURABILITY_AND_STACK_SIZE","TYPE_ONLY"}})
		return Action{
			name="if_player_cursor_item_equals",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_player_gamemode_equals":
		append(&slots, Slot{name="gamemode", type="enum", _enum=[dynamic]string{"SURVIVAL","CREATIVE","ADVENTURE","SPECTATOR"}})
		return Action{
			name="if_player_gamemode_equals",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_player_has_item":
		append(&slots, Slot{name="items", type="item"})
		append(&slots, Slot{name="check_mode", type="enum", _enum=[dynamic]string{"ANY","ALL"}})
		append(&slots, Slot{name="comparison_mode", type="enum", _enum=[dynamic]string{"EXACTLY","IGNORE_STACK_SIZE","IGNORE_DURABILITY_AND_STACK_SIZE","TYPE_ONLY"}})
		return Action{
			name="if_player_has_item",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_player_has_item_at_least":
		append(&slots, Slot{name="item", type="item"})
		append(&slots, Slot{name="count", type="number"})
		append(&slots, Slot{name="comparison_mode", type="enum", _enum=[dynamic]string{"EXACTLY","TYPE_ONLY"}})
		return Action{
			name="if_player_has_item_at_least",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_player_has_item_in_slot":
		append(&slots, Slot{name="items", type="item"})
		append(&slots, Slot{name="slots", type="number"})
		append(&slots, Slot{name="comparison_mode", type="enum", _enum=[dynamic]string{"EXACTLY","IGNORE_STACK_SIZE","IGNORE_DURABILITY_AND_STACK_SIZE","TYPE_ONLY"}})
		return Action{
			name="if_player_has_item_in_slot",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_player_has_potion_effect":
		append(&slots, Slot{name="potions", type="potion"})
		append(&slots, Slot{name="check_mode", type="enum", _enum=[dynamic]string{"ANY","ALL"}})
		return Action{
			name="if_player_has_potion_effect",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_player_has_privilege":
		append(&slots, Slot{name="privilege", type="enum", _enum=[dynamic]string{"BUILDER","DEVELOPER","BUILDER_AND_DEVELOPER","WHITELISTED","OWNER"}})
		append(&slots, Slot{name="exact", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="if_player_has_privilege",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_player_has_room_for_item":
		append(&slots, Slot{name="items", type="item"})
		append(&slots, Slot{name="check_mode", type="enum", _enum=[dynamic]string{"ANY","ALL"}})
		append(&slots, Slot{name="checked_slots", type="enum", _enum=[dynamic]string{"ENTIRE_INVENTORY","MAIN_INVENTORY","UPPER_INVENTORY","HOTBAR","ARMOR"}})
		return Action{
			name="if_player_has_room_for_item",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_player_hotbar_slot_equals":
		append(&slots, Slot{name="slot", type="number"})
		return Action{
			name="if_player_hotbar_slot_equals",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_player_inventory_menu_slot_equals":
		append(&slots, Slot{name="items", type="item"})
		append(&slots, Slot{name="slots", type="number"})
		append(&slots, Slot{name="comparison_mode", type="enum", _enum=[dynamic]string{"EXACTLY","IGNORE_STACK_SIZE","IGNORE_DURABILITY_AND_STACK_SIZE","TYPE_ONLY"}})
		return Action{
			name="if_player_inventory_menu_slot_equals",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_player_inventory_type_open":
		append(&slots, Slot{name="inventory_type", type="enum", _enum=[dynamic]string{"CHEST","DISPENSER","DROPPER","FURNACE","WORKBENCH","CRAFTING","ENCHANTING","BREWING","PLAYER","CREATIVE","MERCHANT","ENDER_CHEST","ANVIL","SMITHING","BEACON","HOPPER","SHULKER_BOX","BARREL","BLAST_FURNACE","LECTERN","SMOKER","LOOM","CARTOGRAPHY","GRINDSTONE","STONECUTTER","COMPOSTER"}})
		return Action{
			name="if_player_inventory_type_open",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_player_is_blocking":
		return Action{
			name="if_player_is_blocking",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_player_is_disguised":
		return Action{
			name="if_player_is_disguised",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_player_is_flying":
		return Action{
			name="if_player_is_flying",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_player_is_gliding":
		return Action{
			name="if_player_is_gliding",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_player_is_holding":
		append(&slots, Slot{name="items", type="item"})
		append(&slots, Slot{name="hand_slot", type="enum", _enum=[dynamic]string{"EITHER_HAND","MAIN_HAND","OFF_HAND"}})
		append(&slots, Slot{name="comparison_mode", type="enum", _enum=[dynamic]string{"EXACTLY","IGNORE_STACK_SIZE","IGNORE_DURABILITY_AND_STACK_SIZE","TYPE_ONLY"}})
		return Action{
			name="if_player_is_holding",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_player_in_area":
		append(&slots, Slot{name="location_1", type="location"})
		append(&slots, Slot{name="location_2", type="location"})
		append(&slots, Slot{name="ignore_y_axis", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		append(&slots, Slot{name="intersect_type", type="enum", _enum=[dynamic]string{"POINT","HITBOX"}})
		append(&slots, Slot{name="check_type", type="enum", _enum=[dynamic]string{"OVERLAPS","CONTAINS"}})
		return Action{
			name="if_player_in_area",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_player_item_is_not_on_cooldown":
		append(&slots, Slot{name="items", type="item"})
		return Action{
			name="if_player_item_is_not_on_cooldown",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_player_is_looking_at_block":
		append(&slots, Slot{name="blocks", type="block"})
		append(&slots, Slot{name="locations", type="location"})
		append(&slots, Slot{name="distance", type="number"})
		append(&slots, Slot{name="fluid_mode", type="enum", _enum=[dynamic]string{"NEVER","SOURCE_ONLY","ALWAYS"}})
		return Action{
			name="if_player_is_looking_at_block",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_player_is_near":
		append(&slots, Slot{name="ignore_y_axis", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="range", type="number"})
		return Action{
			name="if_player_is_near",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_player_is_on_ground":
		return Action{
			name="if_player_is_on_ground",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_player_is_online_mode":
		return Action{
			name="if_player_is_online_mode",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_player_is_riding_entity":
		append(&slots, Slot{name="entity_ids", type="text"})
		append(&slots, Slot{name="compare_mode", type="enum", _enum=[dynamic]string{"NEAREST","FARTHEST"}})
		return Action{
			name="if_player_is_riding_entity",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_player_is_self_disguised":
		return Action{
			name="if_player_is_self_disguised",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_player_is_sleeping":
		return Action{
			name="if_player_is_sleeping",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_player_is_sneaking":
		return Action{
			name="if_player_is_sneaking",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_player_is_sprinting":
		return Action{
			name="if_player_is_sprinting",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_player_is_standing_on_block":
		append(&slots, Slot{name="blocks", type="block"})
		append(&slots, Slot{name="locations", type="location"})
		append(&slots, Slot{name="only_solid", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="if_player_is_standing_on_block",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_player_is_swimming":
		return Action{
			name="if_player_is_swimming",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_player_is_using_item":
		append(&slots, Slot{name="items", type="item"})
		append(&slots, Slot{name="comparison_mode", type="enum", _enum=[dynamic]string{"EXACTLY","IGNORE_STACK_SIZE","IGNORE_DURABILITY_AND_STACK_SIZE","TYPE_ONLY"}})
		return Action{
			name="if_player_is_using_item",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_player_is_wearing_item":
		append(&slots, Slot{name="items", type="item"})
		append(&slots, Slot{name="check_mode", type="enum", _enum=[dynamic]string{"ANY","ALL"}})
		append(&slots, Slot{name="comparison_mode", type="enum", _enum=[dynamic]string{"EXACTLY","IGNORE_STACK_SIZE","IGNORE_DURABILITY_AND_STACK_SIZE","TYPE_ONLY"}})
		return Action{
			name="if_player_is_wearing_item",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_player_name_equals":
		append(&slots, Slot{name="names_or_uuids", type="text"})
		return Action{
			name="if_player_name_equals",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_variable_equals":
		append(&slots, Slot{name="value", type="any"})
		append(&slots, Slot{name="compare", type="any"})
		return Action{
			name="if_variable_equals",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_variable_exists":
		append(&slots, Slot{name="variable", type="variable"})
		return Action{
			name="if_variable_exists",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_variable_greater":
		append(&slots, Slot{name="value", type="number"})
		append(&slots, Slot{name="compare", type="number"})
		return Action{
			name="if_variable_greater",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_variable_greater_or_equals":
		append(&slots, Slot{name="value", type="number"})
		append(&slots, Slot{name="compare", type="number"})
		return Action{
			name="if_variable_greater_or_equals",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_variable_in_range":
		append(&slots, Slot{name="value", type="any"})
		append(&slots, Slot{name="min", type="any"})
		append(&slots, Slot{name="max", type="any"})
		return Action{
			name="if_variable_in_range",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_variable_is_type":
		append(&slots, Slot{name="value", type="any"})
		append(&slots, Slot{name="variable_type", type="enum", _enum=[dynamic]string{"NUMBER","TEXT","LOCATION","ITEM","POTION","SOUND","PARTICLE","VECTOR","ARRAY","MAP"}})
		return Action{
			name="if_variable_is_type",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_variable_item_equals":
		append(&slots, Slot{name="value", type="item"})
		append(&slots, Slot{name="compare", type="item"})
		append(&slots, Slot{name="comparison_mode", type="enum", _enum=[dynamic]string{"EXACTLY","IGNORE_STACK_SIZE","IGNORE_DURABILITY_AND_STACK_SIZE","TYPE_ONLY"}})
		return Action{
			name="if_variable_item_equals",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_variable_item_has_enchantment":
		append(&slots, Slot{name="item", type="item"})
		append(&slots, Slot{name="enchant", type="text"})
		append(&slots, Slot{name="level", type="number"})
		return Action{
			name="if_variable_item_has_enchantment",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_variable_item_has_tag":
		append(&slots, Slot{name="item", type="item"})
		append(&slots, Slot{name="tag", type="text"})
		append(&slots, Slot{name="value", type="text"})
		return Action{
			name="if_variable_item_has_tag",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_variable_less":
		append(&slots, Slot{name="value", type="number"})
		append(&slots, Slot{name="compare", type="number"})
		return Action{
			name="if_variable_less",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_variable_less_or_equals":
		append(&slots, Slot{name="value", type="number"})
		append(&slots, Slot{name="compare", type="number"})
		return Action{
			name="if_variable_less_or_equals",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_variable_list_contains_value":
		append(&slots, Slot{name="list", type="list"})
		append(&slots, Slot{name="values", type="any"})
		append(&slots, Slot{name="check_mode", type="enum", _enum=[dynamic]string{"ANY","ALL"}})
		return Action{
			name="if_variable_list_contains_value",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_variable_list_value_equals":
		append(&slots, Slot{name="list", type="list"})
		append(&slots, Slot{name="index", type="number"})
		append(&slots, Slot{name="values", type="any"})
		return Action{
			name="if_variable_list_value_equals",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_variable_location_in_range":
		append(&slots, Slot{name="value", type="location"})
		append(&slots, Slot{name="min", type="location"})
		append(&slots, Slot{name="max", type="location"})
		append(&slots, Slot{name="border_handling", type="enum", _enum=[dynamic]string{"EXACT","BLOCK","FULL_BLOCK_RANGE"}})
		return Action{
			name="if_variable_location_in_range",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_variable_location_is_near":
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="radius", type="number"})
		append(&slots, Slot{name="check", type="location"})
		append(&slots, Slot{name="shape", type="enum", _enum=[dynamic]string{"SPHERE","CIRCLE","CUBE","SQUARE"}})
		return Action{
			name="if_variable_location_is_near",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_variable_map_has_key":
		append(&slots, Slot{name="map", type="dictionary"})
		append(&slots, Slot{name="key", type="any"})
		return Action{
			name="if_variable_map_has_key",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_variable_map_value_equals":
		append(&slots, Slot{name="map", type="dictionary"})
		append(&slots, Slot{name="key", type="any"})
		append(&slots, Slot{name="values", type="any"})
		return Action{
			name="if_variable_map_value_equals",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_variable_not_equals":
		append(&slots, Slot{name="value", type="any"})
		append(&slots, Slot{name="compare", type="any"})
		return Action{
			name="if_variable_not_equals",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_variable_range_intersects_range":
		append(&slots, Slot{name="min1", type="location"})
		append(&slots, Slot{name="max1", type="location"})
		append(&slots, Slot{name="min2", type="location"})
		append(&slots, Slot{name="max2", type="location"})
		append(&slots, Slot{name="check_type", type="enum", _enum=[dynamic]string{"OVERLAPS","CONTAINS"}})
		return Action{
			name="if_variable_range_intersects_range",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_variable_text_contains":
		append(&slots, Slot{name="value", type="text"})
		append(&slots, Slot{name="compare", type="text"})
		append(&slots, Slot{name="ignore_case", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="if_variable_text_contains",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_variable_text_ends_with":
		append(&slots, Slot{name="value", type="text"})
		append(&slots, Slot{name="compare", type="text"})
		append(&slots, Slot{name="ignore_case", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="if_variable_text_ends_with",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_variable_text_matches":
		append(&slots, Slot{name="match", type="text"})
		append(&slots, Slot{name="values", type="text"})
		append(&slots, Slot{name="ignore_case", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		append(&slots, Slot{name="regular_expressions", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="if_variable_text_matches",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_variable_text_starts_with":
		append(&slots, Slot{name="value", type="text"})
		append(&slots, Slot{name="compare", type="text"})
		append(&slots, Slot{name="ignore_case", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="if_variable_text_starts_with",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "if_variable_list_is_empty":
		append(&slots, Slot{name="list", type="any"})
		return Action{
			name="if_variable_list_is_empty",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "player_add_inventory_menu_row":
		append(&slots, Slot{name="items", type="item"})
		append(&slots, Slot{name="position", type="enum", _enum=[dynamic]string{"TOP","BUTTON"}})
		return Action{
			name="player_add_inventory_menu_row",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_allow_placing_breaking_blocks":
		append(&slots, Slot{name="allow", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		append(&slots, Slot{name="blocks", type="block"})
		return Action{
			name="player_allow_placing_breaking_blocks",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_boost_elytra":
		append(&slots, Slot{name="firework", type="item"})
		return Action{
			name="player_boost_elytra",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_clear_chat":
		return Action{
			name="player_clear_chat",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_clear_debug_markers":
		return Action{
			name="player_clear_debug_markers",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_clear_ender_chest_contents":
		return Action{
			name="player_clear_ender_chest_contents",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_clear_inventory":
		append(&slots, Slot{name="clear_mode", type="enum", _enum=[dynamic]string{"ENTIRE","MAIN","UPPER","HOTBAR","ARMOR"}})
		return Action{
			name="player_clear_inventory",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_clear_items":
		append(&slots, Slot{name="items", type="item"})
		return Action{
			name="player_clear_items",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_clear_potion_effects":
		return Action{
			name="player_clear_potion_effects",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_close_inventory":
		return Action{
			name="player_close_inventory",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_damage":
		append(&slots, Slot{name="damage", type="number"})
		append(&slots, Slot{name="source", type="text"})
		return Action{
			name="player_damage",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_disguise_as_block":
		append(&slots, Slot{name="block", type="block"})
		append(&slots, Slot{name="visible_to_self", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="player_disguise_as_block",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_disguise_as_entity":
		append(&slots, Slot{name="entity_type", type="item"})
		append(&slots, Slot{name="visible_to_self", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="player_disguise_as_entity",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_disguise_as_item":
		append(&slots, Slot{name="item", type="item"})
		append(&slots, Slot{name="visible_to_self", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="player_disguise_as_item",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_display_bell_ring":
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="direction", type="enum", _enum=[dynamic]string{"DOWN","NORTH","SOUTH","WEST","EAST"}})
		return Action{
			name="player_display_bell_ring",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_display_block":
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="block", type="block"})
		return Action{
			name="player_display_block",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_set_block_opened_state":
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="is_opened", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="player_set_block_opened_state",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_display_end_gateway_beam":
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="color", type="enum", _enum=[dynamic]string{"LIGHT_PURPLE","DARK_PURPLE"}})
		return Action{
			name="player_display_end_gateway_beam",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_display_hologram":
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="text", type="text"})
		return Action{
			name="player_display_hologram",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_display_lightning":
		append(&slots, Slot{name="location", type="location"})
		return Action{
			name="player_display_lightning",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_display_particle":
		append(&slots, Slot{name="particle", type="particle"})
		append(&slots, Slot{name="location", type="location"})
		return Action{
			name="player_display_particle",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_display_particle_circle":
		append(&slots, Slot{name="particle", type="particle"})
		append(&slots, Slot{name="center", type="location"})
		append(&slots, Slot{name="radius", type="number"})
		append(&slots, Slot{name="points", type="number"})
		append(&slots, Slot{name="start_angle", type="number"})
		append(&slots, Slot{name="perpendicular", type="vector"})
		append(&slots, Slot{name="angle_unit", type="enum", _enum=[dynamic]string{"DEGREES","RADIANS"}})
		return Action{
			name="player_display_particle_circle",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_display_particle_cube":
		append(&slots, Slot{name="particle", type="particle"})
		append(&slots, Slot{name="first_corner", type="location"})
		append(&slots, Slot{name="second_corner", type="location"})
		append(&slots, Slot{name="spacing", type="number"})
		append(&slots, Slot{name="type", type="enum", _enum=[dynamic]string{"SOLID","HOLLOW","WIREFRAME"}})
		return Action{
			name="player_display_particle_cube",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_display_particle_line":
		append(&slots, Slot{name="particle", type="particle"})
		append(&slots, Slot{name="start", type="location"})
		append(&slots, Slot{name="end", type="location"})
		append(&slots, Slot{name="divider", type="number"})
		append(&slots, Slot{name="unit_of_measurement", type="enum", _enum=[dynamic]string{"POINTS","DISTANCE"}})
		return Action{
			name="player_display_particle_line",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_display_particle_ray":
		append(&slots, Slot{name="particle", type="particle"})
		append(&slots, Slot{name="start", type="location"})
		append(&slots, Slot{name="ray", type="vector"})
		append(&slots, Slot{name="divider", type="number"})
		append(&slots, Slot{name="unit_of_measurement", type="enum", _enum=[dynamic]string{"POINTS","DISTANCE"}})
		return Action{
			name="player_display_particle_ray",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_display_particle_sphere":
		append(&slots, Slot{name="particle", type="particle"})
		append(&slots, Slot{name="center", type="location"})
		append(&slots, Slot{name="radius", type="number"})
		append(&slots, Slot{name="points", type="number"})
		return Action{
			name="player_display_particle_sphere",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_display_particle_spiral":
		append(&slots, Slot{name="particle", type="particle"})
		append(&slots, Slot{name="center", type="location"})
		append(&slots, Slot{name="distance", type="number"})
		append(&slots, Slot{name="radius", type="number"})
		append(&slots, Slot{name="points", type="number"})
		append(&slots, Slot{name="rotations", type="number"})
		append(&slots, Slot{name="start_angle", type="number"})
		append(&slots, Slot{name="angle_unit", type="enum", _enum=[dynamic]string{"DEGREES","RADIANS"}})
		return Action{
			name="player_display_particle_spiral",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_display_pick_up_animation":
		append(&slots, Slot{name="collected_name_or_uuid", type="text"})
		append(&slots, Slot{name="collector_name_or_uuid", type="text"})
		append(&slots, Slot{name="amount", type="number"})
		return Action{
			name="player_display_pick_up_animation",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_display_sign_text":
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="line_1", type="text"})
		append(&slots, Slot{name="line_2", type="text"})
		append(&slots, Slot{name="line_3", type="text"})
		append(&slots, Slot{name="line_4", type="text"})
		return Action{
			name="player_display_sign_text",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_display_vibration":
		append(&slots, Slot{name="from", type="location"})
		append(&slots, Slot{name="to", type="location"})
		append(&slots, Slot{name="destination_time", type="number"})
		return Action{
			name="player_display_vibration",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_expand_inventory_menu":
		append(&slots, Slot{name="items", type="item"})
		append(&slots, Slot{name="size", type="number"})
		return Action{
			name="player_expand_inventory_menu",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_face_location":
		append(&slots, Slot{name="location", type="location"})
		return Action{
			name="player_face_location",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_force_flight_mode":
		append(&slots, Slot{name="is_flying", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="player_force_flight_mode",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_give_experience":
		append(&slots, Slot{name="experience", type="number"})
		append(&slots, Slot{name="mode", type="enum", _enum=[dynamic]string{"POINTS","LEVEL","LEVEL_PERCENTAGE"}})
		return Action{
			name="player_give_experience",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_give_items":
		append(&slots, Slot{name="items", type="item"})
		append(&slots, Slot{name="amount", type="number"})
		return Action{
			name="player_give_items",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_give_potion_effect":
		append(&slots, Slot{name="potions", type="potion"})
		append(&slots, Slot{name="overwrite", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		append(&slots, Slot{name="show_icon", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		append(&slots, Slot{name="particle_mode", type="enum", _enum=[dynamic]string{"REGULAR","AMBIENT","NONE"}})
		return Action{
			name="player_give_potion_effect",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_give_random_item":
		append(&slots, Slot{name="items", type="item"})
		return Action{
			name="player_give_random_item",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_heal":
		append(&slots, Slot{name="heal", type="number"})
		return Action{
			name="player_heal",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_hide_entity":
		append(&slots, Slot{name="name_or_uuid", type="text"})
		append(&slots, Slot{name="hide", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="player_hide_entity",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_hide_scoreboard":
		return Action{
			name="player_hide_scoreboard",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_kick":
		return Action{
			name="player_kick",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_launch_forward":
		append(&slots, Slot{name="power", type="number"})
		append(&slots, Slot{name="increment", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		append(&slots, Slot{name="launch_axis", type="enum", _enum=[dynamic]string{"YAW_AND_PITCH","YAW"}})
		return Action{
			name="player_launch_forward",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_launch_projectile":
		append(&slots, Slot{name="projectile", type="item"})
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="name", type="text"})
		append(&slots, Slot{name="speed", type="number"})
		append(&slots, Slot{name="inaccuracy", type="number"})
		append(&slots, Slot{name="trail", type="particle"})
		return Action{
			name="player_launch_projectile",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_launch_to_location":
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="power", type="number"})
		append(&slots, Slot{name="increment", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="player_launch_to_location",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_launch_up":
		append(&slots, Slot{name="power", type="number"})
		append(&slots, Slot{name="increment", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="player_launch_up",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_load_inventory":
		return Action{
			name="player_load_inventory",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_open_book":
		append(&slots, Slot{name="book", type="item"})
		return Action{
			name="player_open_book",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_open_container_inventory":
		append(&slots, Slot{name="location", type="location"})
		return Action{
			name="player_open_container_inventory",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_play_animation_action":
		append(&slots, Slot{name="animation", type="enum", _enum=[dynamic]string{"DAMAGE","WAKE_UP","TOTEM","JUMPSCARE"}})
		return Action{
			name="player_play_animation_action",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_play_hurt_animation":
		append(&slots, Slot{name="yaw", type="number"})
		return Action{
			name="player_play_hurt_animation",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_play_sound":
		append(&slots, Slot{name="sound", type="sound"})
		append(&slots, Slot{name="location", type="location"})
		return Action{
			name="player_play_sound",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_play_sound_from_entity":
		append(&slots, Slot{name="sounds", type="sound"})
		append(&slots, Slot{name="name_or_uuid", type="text"})
		return Action{
			name="player_play_sound_from_entity",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_play_sound_sequence":
		append(&slots, Slot{name="sounds", type="sound"})
		append(&slots, Slot{name="delay", type="number"})
		append(&slots, Slot{name="location", type="location"})
		return Action{
			name="player_play_sound_sequence",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_randomized_teleport":
		append(&slots, Slot{name="locations", type="location"})
		append(&slots, Slot{name="keep_rotation", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		append(&slots, Slot{name="keep_velocity", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		append(&slots, Slot{name="dismount", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="player_randomized_teleport",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_redirect_world":
		append(&slots, Slot{name="world_id", type="text"})
		return Action{
			name="player_redirect_world",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_remove_boss_bar":
		append(&slots, Slot{name="id", type="text"})
		return Action{
			name="player_remove_boss_bar",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_remove_disguise":
		return Action{
			name="player_remove_disguise",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_remove_display_blocks":
		append(&slots, Slot{name="pos_1", type="location"})
		append(&slots, Slot{name="pos_2", type="location"})
		return Action{
			name="player_remove_display_blocks",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_remove_inventory_menu_row":
		append(&slots, Slot{name="size", type="number"})
		append(&slots, Slot{name="position", type="enum", _enum=[dynamic]string{"TOP","BUTTON"}})
		return Action{
			name="player_remove_inventory_menu_row",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_remove_items":
		append(&slots, Slot{name="items", type="item"})
		return Action{
			name="player_remove_items",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_remove_pose":
		return Action{
			name="player_remove_pose",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_remove_potion_effect":
		append(&slots, Slot{name="potions", type="potion"})
		return Action{
			name="player_remove_potion_effect",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_remove_self_disguise":
		return Action{
			name="player_remove_self_disguise",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_remove_skin":
		return Action{
			name="player_remove_skin",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_remove_world_border":
		return Action{
			name="player_remove_world_border",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_replace_items":
		append(&slots, Slot{name="items", type="item"})
		append(&slots, Slot{name="replace", type="item"})
		append(&slots, Slot{name="count", type="number"})
		return Action{
			name="player_replace_items",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_reset_weather":
		return Action{
			name="player_reset_weather",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_ride_entity":
		append(&slots, Slot{name="name_or_uuid", type="text"})
		return Action{
			name="player_ride_entity",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_save_inventory":
		return Action{
			name="player_save_inventory",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_self_disguise_as_block":
		append(&slots, Slot{name="block", type="block"})
		return Action{
			name="player_self_disguise_as_block",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_self_disguise_as_entity":
		append(&slots, Slot{name="entity_type", type="item"})
		return Action{
			name="player_self_disguise_as_entity",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_self_disguise_as_item":
		append(&slots, Slot{name="item", type="item"})
		return Action{
			name="player_self_disguise_as_item",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_send_action_bar":
		append(&slots, Slot{name="messages", type="text"})
		append(&slots, Slot{name="merging", type="enum", _enum=[dynamic]string{"SPACES","CONCATENATION"}})
		return Action{
			name="player_send_action_bar",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_send_advancement":
		append(&slots, Slot{name="frame", type="enum", _enum=[dynamic]string{"TASK","CHALLENGE","GOAL"}})
		append(&slots, Slot{name="name", type="text"})
		append(&slots, Slot{name="icon", type="item"})
		return Action{
			name="player_send_advancement",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_send_break_animation":
		append(&slots, Slot{name="locations", type="location"})
		append(&slots, Slot{name="stage", type="number"})
		return Action{
			name="player_send_break_animation",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_send_dialogue":
		append(&slots, Slot{name="messages", type="text"})
		append(&slots, Slot{name="delay", type="number"})
		return Action{
			name="player_send_dialogue",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_send_hover":
		append(&slots, Slot{name="message", type="text"})
		append(&slots, Slot{name="hover", type="text"})
		return Action{
			name="player_send_hover",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_send_message":
		append(&slots, Slot{name="messages", type="text"})
		append(&slots, Slot{name="merging", type="enum", _enum=[dynamic]string{"SPACES","CONCATENATION","SEPARATE_LINES"}})
		return Action{
			name="player_send_message",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=true,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_send_minimessage":
		append(&slots, Slot{name="minimessage", type="text"})
		return Action{
			name="player_send_minimessage",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_send_title":
		append(&slots, Slot{name="title", type="text"})
		append(&slots, Slot{name="subtitle", type="text"})
		append(&slots, Slot{name="fade_in", type="number"})
		append(&slots, Slot{name="stay", type="number"})
		append(&slots, Slot{name="fade_out", type="number"})
		return Action{
			name="player_send_title",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_set_absorption_health":
		append(&slots, Slot{name="health", type="number"})
		return Action{
			name="player_set_absorption_health",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_set_air_ticks":
		append(&slots, Slot{name="ticks", type="number"})
		return Action{
			name="player_set_air_ticks",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_set_allow_flying":
		append(&slots, Slot{name="allow_flying", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="player_set_allow_flying",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_set_armor":
		append(&slots, Slot{name="helmet", type="item"})
		append(&slots, Slot{name="chestplate", type="item"})
		append(&slots, Slot{name="leggings", type="item"})
		append(&slots, Slot{name="boots", type="item"})
		return Action{
			name="player_set_armor",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_set_arrows_in_body":
		append(&slots, Slot{name="amount", type="number"})
		return Action{
			name="player_set_arrows_in_body",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_set_attack_speed":
		append(&slots, Slot{name="speed", type="number"})
		return Action{
			name="player_set_attack_speed",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_set_attribute":
		append(&slots, Slot{name="value", type="number"})
		append(&slots, Slot{name="attribute_type", type="enum", _enum=[dynamic]string{}})
		return Action{
			name="player_set_attribute",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_set_bee_stingers_in_body":
		append(&slots, Slot{name="amount", type="number"})
		return Action{
			name="player_set_bee_stingers_in_body",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_set_boss_bar":
		append(&slots, Slot{name="id", type="text"})
		append(&slots, Slot{name="title", type="text"})
		append(&slots, Slot{name="progress", type="number"})
		append(&slots, Slot{name="color", type="enum", _enum=[dynamic]string{"PINK","BLUE","RED","GREEN","YELLOW","PURPLE","WHITE"}})
		append(&slots, Slot{name="style", type="enum", _enum=[dynamic]string{"PROGRESS","NOTCHED_6","NOTCHED_10","NOTCHED_12","NOTCHED_20"}})
		append(&slots, Slot{name="sky_effect", type="enum", _enum=[dynamic]string{"NONE","FOG","DARK_SKY","FOG_AND_DARK_SKY"}})
		return Action{
			name="player_set_boss_bar",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_set_chat_completions":
		append(&slots, Slot{name="completions", type="text"})
		append(&slots, Slot{name="setting_mode", type="enum", _enum=[dynamic]string{"ADD","SET","REMOVE"}})
		return Action{
			name="player_set_chat_completions",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_set_collidable":
		append(&slots, Slot{name="collidable", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="player_set_collidable",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_set_compass_target":
		append(&slots, Slot{name="location", type="location"})
		return Action{
			name="player_set_compass_target",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_set_cursor_item":
		append(&slots, Slot{name="item", type="item"})
		return Action{
			name="player_set_cursor_item",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_set_death_drops":
		append(&slots, Slot{name="death_drops", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="player_set_death_drops",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_set_ender_chest_contents":
		append(&slots, Slot{name="items", type="item"})
		return Action{
			name="player_set_ender_chest_contents",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_set_entity_glowing":
		append(&slots, Slot{name="name_or_uuid", type="text"})
		append(&slots, Slot{name="color", type="enum", _enum=[dynamic]string{"WHITE","GRAY","DARK_GRAY","BLACK","DARK_RED","RED","GOLD","YELLOW","GREEN","DARK_GREEN","DARK_AQUA","AQUA","BLUE","DARK_BLUE","DARK_PURPLE","PURPLE"}})
		append(&slots, Slot{name="glow", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="player_set_entity_glowing",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_set_equipment":
		append(&slots, Slot{name="item", type="item"})
		append(&slots, Slot{name="slot", type="enum", _enum=[dynamic]string{"CHEST","FEET","HAND","HEAD","LEGS","OFF_HAND"}})
		return Action{
			name="player_set_equipment",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_set_exhaustion":
		append(&slots, Slot{name="exhaustion", type="number"})
		append(&slots, Slot{name="mode", type="enum", _enum=[dynamic]string{"SET","ADD"}})
		return Action{
			name="player_set_exhaustion",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_set_experience":
		append(&slots, Slot{name="experience", type="number"})
		append(&slots, Slot{name="mode", type="enum", _enum=[dynamic]string{"POINTS","LEVEL","LEVEL_PERCENTAGE"}})
		return Action{
			name="player_set_experience",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_set_fall_distance":
		append(&slots, Slot{name="distance", type="number"})
		return Action{
			name="player_set_fall_distance",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_set_fire_ticks":
		append(&slots, Slot{name="ticks", type="number"})
		return Action{
			name="player_set_fire_ticks",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_set_flying":
		append(&slots, Slot{name="is_flying", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="player_set_flying",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_set_fog_distance":
		append(&slots, Slot{name="distance", type="number"})
		return Action{
			name="player_set_fog_distance",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_set_food":
		append(&slots, Slot{name="food", type="number"})
		append(&slots, Slot{name="mode", type="enum", _enum=[dynamic]string{"SET","ADD"}})
		return Action{
			name="player_set_food",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_set_freeze_ticks":
		append(&slots, Slot{name="ticks", type="number"})
		append(&slots, Slot{name="ticking_locked", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="player_set_freeze_ticks",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_set_gamemode":
		append(&slots, Slot{name="gamemode", type="enum", _enum=[dynamic]string{"SURVIVAL","CREATIVE","ADVENTURE","SPECTATOR"}})
		append(&slots, Slot{name="flight_mode", type="enum", _enum=[dynamic]string{"RESPECT_GAMEMODE","KEEP_ORIGINAL"}})
		return Action{
			name="player_set_gamemode",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_set_gliding":
		append(&slots, Slot{name="is_gliding", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="player_set_gliding",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_set_health":
		append(&slots, Slot{name="health", type="number"})
		return Action{
			name="player_set_health",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_set_hotbar_slot":
		append(&slots, Slot{name="slot", type="number"})
		return Action{
			name="player_set_hotbar_slot",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_set_instant_respawn":
		append(&slots, Slot{name="instant_respawn", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="player_set_instant_respawn",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_set_inventory_kept":
		append(&slots, Slot{name="kept", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="player_set_inventory_kept",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_set_inventory_menu_item":
		append(&slots, Slot{name="item", type="item"})
		append(&slots, Slot{name="slot", type="number"})
		return Action{
			name="player_set_inventory_menu_item",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_set_inventory_menu_name":
		append(&slots, Slot{name="text", type="text"})
		return Action{
			name="player_set_inventory_menu_name",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_set_invulnerability_ticks":
		append(&slots, Slot{name="ticks", type="number"})
		return Action{
			name="player_set_invulnerability_ticks",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_set_item_cooldown":
		append(&slots, Slot{name="item", type="item"})
		append(&slots, Slot{name="cooldown", type="number"})
		append(&slots, Slot{name="sound", type="sound"})
		return Action{
			name="player_set_item_cooldown",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_set_items":
		append(&slots, Slot{name="items", type="item"})
		return Action{
			name="player_set_items",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_set_max_health":
		append(&slots, Slot{name="health", type="number"})
		append(&slots, Slot{name="heal", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="player_set_max_health",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_set_movement_speed":
		append(&slots, Slot{name="distance", type="number"})
		append(&slots, Slot{name="movement_type", type="enum", _enum=[dynamic]string{"WALK","FLY"}})
		return Action{
			name="player_set_movement_speed",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_set_nametag_visible":
		append(&slots, Slot{name="visible", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="player_set_nametag_visible",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_set_player_list_info":
		append(&slots, Slot{name="text", type="text"})
		append(&slots, Slot{name="position", type="enum", _enum=[dynamic]string{"HEADER","FOOTER"}})
		append(&slots, Slot{name="merging", type="enum", _enum=[dynamic]string{"SPACES","CONCATENATION","SEPARATE_LINES"}})
		return Action{
			name="player_set_player_list_info",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_set_pose":
		append(&slots, Slot{name="pose", type="enum", _enum=[dynamic]string{"CROAKING","DIGGING","DYING","EMERGING","FALL_FLYING","LONG_JUMPING","ROARING","SLEEPING","SNEAKING","SNIFFING","SPIN_ATTACK","STANDING","SWIMMING","USING_TONGUE"}})
		append(&slots, Slot{name="locked", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="player_set_pose",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_set_pvp":
		append(&slots, Slot{name="pvp", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="player_set_pvp",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_set_rain_level":
		append(&slots, Slot{name="rain_level", type="number"})
		return Action{
			name="player_set_rain_level",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_set_rotation":
		append(&slots, Slot{name="yaw", type="number"})
		append(&slots, Slot{name="pitch", type="number"})
		return Action{
			name="player_set_rotation",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_set_rotation_by_vector":
		append(&slots, Slot{name="vector", type="vector"})
		return Action{
			name="player_set_rotation_by_vector",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_set_saturation":
		append(&slots, Slot{name="saturation", type="number"})
		append(&slots, Slot{name="mode", type="enum", _enum=[dynamic]string{"SET","ADD"}})
		return Action{
			name="player_set_saturation",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_set_simulation_distance":
		append(&slots, Slot{name="distance", type="number"})
		return Action{
			name="player_set_simulation_distance",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_set_skin":
		append(&slots, Slot{name="name_or_uuid", type="text"})
		append(&slots, Slot{name="server_type", type="enum", _enum=[dynamic]string{"MOJANG","SERVER"}})
		return Action{
			name="player_set_skin",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_set_slot_item":
		append(&slots, Slot{name="item", type="item"})
		append(&slots, Slot{name="slot", type="number"})
		return Action{
			name="player_set_slot_item",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_set_spawn_point":
		append(&slots, Slot{name="spawn_point", type="location"})
		return Action{
			name="player_set_spawn_point",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_set_thunder_level":
		append(&slots, Slot{name="thunder_level", type="number"})
		return Action{
			name="player_set_thunder_level",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_set_tick_rate":
		append(&slots, Slot{name="tick_rate", type="number"})
		return Action{
			name="player_set_tick_rate",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_set_time":
		append(&slots, Slot{name="time", type="number"})
		return Action{
			name="player_set_time",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_set_velocity":
		append(&slots, Slot{name="velocity", type="vector"})
		append(&slots, Slot{name="increment", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="player_set_velocity",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_set_visual_fire":
		append(&slots, Slot{name="visual_fire", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="player_set_visual_fire",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_set_weather":
		append(&slots, Slot{name="weather_type", type="enum", _enum=[dynamic]string{"DOWNFALL","CLEAR"}})
		return Action{
			name="player_set_weather",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_set_world_border":
		append(&slots, Slot{name="center", type="location"})
		append(&slots, Slot{name="size", type="number"})
		append(&slots, Slot{name="warning", type="number"})
		return Action{
			name="player_set_world_border",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_shift_world_border":
		append(&slots, Slot{name="old_size", type="number"})
		append(&slots, Slot{name="size", type="number"})
		append(&slots, Slot{name="time", type="number"})
		return Action{
			name="player_shift_world_border",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_show_debug_marker":
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="name", type="text"})
		append(&slots, Slot{name="duration", type="number"})
		append(&slots, Slot{name="red", type="number"})
		append(&slots, Slot{name="green", type="number"})
		append(&slots, Slot{name="blue", type="number"})
		append(&slots, Slot{name="alpha", type="number"})
		return Action{
			name="player_show_debug_marker",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_show_demo_screen":
		return Action{
			name="player_show_demo_screen",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_show_inventory_menu":
		append(&slots, Slot{name="items", type="item"})
		append(&slots, Slot{name="name", type="text"})
		append(&slots, Slot{name="inventory_type", type="enum", _enum=[dynamic]string{"CHEST","DISPENSER","DROPPER","FURNACE","WORKBENCH","ENCHANTING","BREWING","ANVIL","SMITHING","BEACON","HOPPER","BLAST_FURNACE","SMOKER","CARTOGRAPHY","GRINDSTONE","STONECUTTER"}})
		return Action{
			name="player_show_inventory_menu",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_show_scoreboard":
		append(&slots, Slot{name="id", type="text"})
		return Action{
			name="player_show_scoreboard",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_show_win_screen":
		return Action{
			name="player_show_win_screen",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_spectate_target":
		append(&slots, Slot{name="name_or_uuid", type="text"})
		return Action{
			name="player_spectate_target",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_stop_sound":
		append(&slots, Slot{name="sounds", type="sound"})
		return Action{
			name="player_stop_sound",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_stop_sounds_by_source":
		append(&slots, Slot{name="source", type="enum", _enum=[dynamic]string{"AMBIENT","BLOCK","HOSTILE","MASTER","MUSIC","NEUTRAL","PLAYER","RECORD","VOICE","WEATHER"}})
		return Action{
			name="player_stop_sounds_by_source",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_swing_hand":
		append(&slots, Slot{name="hand_type", type="enum", _enum=[dynamic]string{"MAIN","OFF"}})
		return Action{
			name="player_swing_hand",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_teleport":
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="keep_rotation", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		append(&slots, Slot{name="keep_velocity", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		append(&slots, Slot{name="dismount", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="player_teleport",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "player_teleport_sequence":
		append(&slots, Slot{name="delay", type="number"})
		append(&slots, Slot{name="locations", type="location"})
		return Action{
			name="player_teleport_sequence",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "repeat_adjacently":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="origin", type="location"})
		append(&slots, Slot{name="change_rotation", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		append(&slots, Slot{name="include_self", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		append(&slots, Slot{name="pattern", type="enum", _enum=[dynamic]string{"CARDINAL","SQUARE","ADJACENT","CUBE"}})
		return Action{
			name="repeat_adjacently",
			in_slots=[dynamic]string{"origin","change_rotation","include_self","pattern"},
			out_slots=[dynamic]string{"variable"},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "repeat_for_each_in_list":
		append(&slots, Slot{name="index_variable", type="variable"})
		append(&slots, Slot{name="value_variable", type="variable"})
		append(&slots, Slot{name="list", type="list"})
		return Action{
			name="repeat_for_each_in_list",
			in_slots=[dynamic]string{"list"},
			out_slots=[dynamic]string{"index_variable","value_variable"},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "repeat_for_each_map_entry":
		append(&slots, Slot{name="key_variable", type="variable"})
		append(&slots, Slot{name="value_variable", type="variable"})
		append(&slots, Slot{name="map", type="dictionary"})
		return Action{
			name="repeat_for_each_map_entry",
			in_slots=[dynamic]string{"map"},
			out_slots=[dynamic]string{"key_variable","value_variable"},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "repeat_forever":
		return Action{
			name="repeat_forever",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "repeat_multi_times":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="amount", type="number"})
		return Action{
			name="repeat_multi_times",
			in_slots=[dynamic]string{"amount"},
			out_slots=[dynamic]string{"variable"},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "repeat_on_circle":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="center", type="location"})
		append(&slots, Slot{name="radius", type="number"})
		append(&slots, Slot{name="circle_points", type="number"})
		append(&slots, Slot{name="perpendicular_to_plane", type="vector"})
		append(&slots, Slot{name="start_angle", type="number"})
		append(&slots, Slot{name="angle_unit", type="enum", _enum=[dynamic]string{"DEGREES","RADIANS"}})
		return Action{
			name="repeat_on_circle",
			in_slots=[dynamic]string{"center","radius","circle_points","perpendicular_to_plane","start_angle","angle_unit"},
			out_slots=[dynamic]string{"variable"},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "repeat_on_grid":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="start", type="location"})
		append(&slots, Slot{name="end", type="location"})
		return Action{
			name="repeat_on_grid",
			in_slots=[dynamic]string{"start","end"},
			out_slots=[dynamic]string{"variable"},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "repeat_on_path":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="step", type="number"})
		append(&slots, Slot{name="locations", type="location"})
		append(&slots, Slot{name="rotation", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="repeat_on_path",
			in_slots=[dynamic]string{"step","locations","rotation"},
			out_slots=[dynamic]string{"variable"},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "repeat_on_range":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="start", type="number"})
		append(&slots, Slot{name="end", type="number"})
		append(&slots, Slot{name="interval", type="number"})
		return Action{
			name="repeat_on_range",
			in_slots=[dynamic]string{"start","end","interval"},
			out_slots=[dynamic]string{"variable"},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "repeat_on_sphere":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="center", type="location"})
		append(&slots, Slot{name="radius", type="number"})
		append(&slots, Slot{name="points", type="number"})
		append(&slots, Slot{name="rotate_location", type="enum", _enum=[dynamic]string{"NO_CHANGES","INWARDS","OUTWARDS"}})
		return Action{
			name="repeat_on_sphere",
			in_slots=[dynamic]string{"center","radius","points","rotate_location"},
			out_slots=[dynamic]string{"variable"},
			accept_selector=false,
			type=Action_Type.CONTAINER,
			slots=slots,
		}, true
	case "repeat_while":
		return Action{
			name="repeat_while",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.CONTAINER_WITH_CONDITIONAL,
			slots=slots,
		}, true
	case "select_add_all_entities":
		return Action{
			name="select_add_all_entities",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "select_add_all_mobs":
		return Action{
			name="select_add_all_mobs",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "select_add_all_players":
		return Action{
			name="select_add_all_players",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "select_add_entity_by_conditional":
		return Action{
			name="select_add_entity_by_conditional",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "select_add_entity_by_name":
		append(&slots, Slot{name="name_or_uuid", type="text"})
		return Action{
			name="select_add_entity_by_name",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "select_add_event_target":
		append(&slots, Slot{name="selection_type", type="enum", _enum=[dynamic]string{"DEFAULT","KILLER","DAMAGER","VICTIM","SHOOTER","PROJECTILE"}})
		return Action{
			name="select_add_event_target",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "select_add_last_entity":
		return Action{
			name="select_add_last_entity",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "select_add_last_mob":
		return Action{
			name="select_add_last_mob",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "select_add_mob_by_name":
		append(&slots, Slot{name="name_or_uuid", type="text"})
		return Action{
			name="select_add_mob_by_name",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "select_add_player_by_conditional":
		return Action{
			name="select_add_player_by_conditional",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "select_add_player_by_name":
		append(&slots, Slot{name="name_or_uuid", type="text"})
		return Action{
			name="select_add_player_by_name",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "select_add_random_entity":
		return Action{
			name="select_add_random_entity",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "select_add_random_mob":
		return Action{
			name="select_add_random_mob",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "select_add_random_player":
		return Action{
			name="select_add_random_player",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "select_all_entities":
		return Action{
			name="select_all_entities",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "select_all_mobs":
		return Action{
			name="select_all_mobs",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "select_all_players":
		return Action{
			name="select_all_players",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "select_entity_by_conditional":
		return Action{
			name="select_entity_by_conditional",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC_WITH_CONDITIONAL,
			slots=slots,
		}, true
	case "select_entity_by_name":
		append(&slots, Slot{name="name_or_uuid", type="text"})
		return Action{
			name="select_entity_by_name",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "select_event_target":
		append(&slots, Slot{name="selection_type", type="enum", _enum=[dynamic]string{"DEFAULT","KILLER","DAMAGER","VICTIM","SHOOTER","PROJECTILE"}})
		return Action{
			name="select_event_target",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "select_filter_by_conditional":
		return Action{
			name="select_filter_by_conditional",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC_WITH_CONDITIONAL,
			slots=slots,
		}, true
	case "select_filter_by_distance":
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="selection_size", type="number"})
		append(&slots, Slot{name="ignore_y_axis", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		append(&slots, Slot{name="compare_mode", type="enum", _enum=[dynamic]string{"NEAREST","FARTHEST"}})
		return Action{
			name="select_filter_by_distance",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "select_filter_by_raycast":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="origin", type="location"})
		append(&slots, Slot{name="max_distance", type="number"})
		append(&slots, Slot{name="ray_size", type="number"})
		append(&slots, Slot{name="selection_size", type="number"})
		append(&slots, Slot{name="consider_blocks", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		append(&slots, Slot{name="ignore_passable_blocks", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		append(&slots, Slot{name="fluid_collision_mode", type="enum", _enum=[dynamic]string{"NEVER","SOURCE_ONLY","ALWAYS"}})
		return Action{
			name="select_filter_by_raycast",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "select_filter_randomly":
		append(&slots, Slot{name="size", type="number"})
		return Action{
			name="select_filter_randomly",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "select_invert":
		return Action{
			name="select_invert",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "select_last_entity":
		return Action{
			name="select_last_entity",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "select_last_mob":
		return Action{
			name="select_last_mob",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "select_mob_by_name":
		append(&slots, Slot{name="name_or_uuid", type="text"})
		return Action{
			name="select_mob_by_name",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "select_player_by_conditional":
		return Action{
			name="select_player_by_conditional",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC_WITH_CONDITIONAL,
			slots=slots,
		}, true
	case "select_player_by_name":
		append(&slots, Slot{name="name_or_uuid", type="text"})
		return Action{
			name="select_player_by_name",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "select_random_entity":
		return Action{
			name="select_random_entity",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "select_random_mob":
		return Action{
			name="select_random_mob",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "select_random_player":
		return Action{
			name="select_random_player",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "select_reset":
		return Action{
			name="select_reset",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_absolute":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="number", type="number"})
		return Action{
			name="set_variable_absolute",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_value":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="value", type="any"})
		return Action{
			name="set_variable_value",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_add":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="value", type="number"})
		return Action{
			name="set_variable_add",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_add_item_enchantment":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="item", type="item"})
		append(&slots, Slot{name="enchantment", type="text"})
		append(&slots, Slot{name="level", type="number"})
		return Action{
			name="set_variable_add_item_enchantment",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_add_item_potion_effects":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="item", type="item"})
		append(&slots, Slot{name="potions", type="potion"})
		append(&slots, Slot{name="overwrite", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		append(&slots, Slot{name="show_icon", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		append(&slots, Slot{name="particle_mode", type="enum", _enum=[dynamic]string{"REGULAR","AMBIENT","NONE"}})
		return Action{
			name="set_variable_add_item_potion_effects",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_add_vectors":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="vectors", type="vector"})
		return Action{
			name="set_variable_add_vectors",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_align_location":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="rotation_mode", type="enum", _enum=[dynamic]string{"KEEP","REMOVE"}})
		append(&slots, Slot{name="coordinates_mode", type="enum", _enum=[dynamic]string{"ALL","X_Z","Y"}})
		append(&slots, Slot{name="align_mode", type="enum", _enum=[dynamic]string{"BLOCK_CENTER","CORNER"}})
		return Action{
			name="set_variable_align_location",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_align_to_axis_vector":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="vector", type="vector"})
		append(&slots, Slot{name="normalize", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="set_variable_align_to_axis_vector",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_append_component":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="components", type="text"})
		append(&slots, Slot{name="merging", type="enum", _enum=[dynamic]string{"SPACES","CONCATENATION","SEPARATE_LINES"}})
		return Action{
			name="set_variable_append_component",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_append_list":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="list_1", type="list"})
		append(&slots, Slot{name="list_2", type="list"})
		return Action{
			name="set_variable_append_list",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_append_map":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="map", type="dictionary"})
		append(&slots, Slot{name="other_map", type="dictionary"})
		return Action{
			name="set_variable_append_map",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_append_value":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="values", type="any"})
		return Action{
			name="set_variable_append_value",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_average":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="value", type="number"})
		return Action{
			name="set_variable_average",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_bitwise_operation":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="operand1", type="number"})
		append(&slots, Slot{name="operand2", type="number"})
		append(&slots, Slot{name="operator", type="enum", _enum=[dynamic]string{"OR","AND","NOT","XOR","LEFT_SHIFT","RIGHT_SHIFT","UNSIGNED_RIGHT_SHIFT"}})
		return Action{
			name="set_variable_bitwise_operation",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_center_location":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="locations", type="location"})
		return Action{
			name="set_variable_center_location",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_change_component_parsing":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="component", type="text"})
		append(&slots, Slot{name="parsing", type="enum", _enum=[dynamic]string{"PLAIN","LEGACY","MINIMESSAGE","JSON"}})
		return Action{
			name="set_variable_change_component_parsing",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_char_to_number":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="char", type="text"})
		return Action{
			name="set_variable_char_to_number",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_clamp":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="number", type="number"})
		append(&slots, Slot{name="min", type="number"})
		append(&slots, Slot{name="max", type="number"})
		return Action{
			name="set_variable_clamp",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_clear_color_codes":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="text", type="text"})
		return Action{
			name="set_variable_clear_color_codes",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_clear_map":
		append(&slots, Slot{name="map", type="variable"})
		return Action{
			name="set_variable_clear_map",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_compact_component":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="component", type="text"})
		return Action{
			name="set_variable_compact_component",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_component_of_children":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="components", type="text"})
		return Action{
			name="set_variable_component_of_children",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_convert_number_to_text":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="number", type="number"})
		append(&slots, Slot{name="radix", type="number"})
		return Action{
			name="set_variable_convert_number_to_text",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_convert_text_to_number":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="text", type="text"})
		append(&slots, Slot{name="radix", type="number"})
		return Action{
			name="set_variable_convert_text_to_number",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_cosine":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="number", type="number"})
		append(&slots, Slot{name="variant", type="enum", _enum=[dynamic]string{"COSINE","ARCCOSINE","HYPERBOLIC_COSINE"}})
		append(&slots, Slot{name="input", type="enum", _enum=[dynamic]string{"DEGREES","RADIANS"}})
		return Action{
			name="set_variable_cosine",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_cotangent":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="number", type="number"})
		append(&slots, Slot{name="variant", type="enum", _enum=[dynamic]string{"COTANGENT","ARCCOTANGENT","HYPERBOLIC_COTANGENT"}})
		append(&slots, Slot{name="input", type="enum", _enum=[dynamic]string{"DEGREES","RADIANS"}})
		return Action{
			name="set_variable_cotangent",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_create_keybind_component":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="key", type="text"})
		return Action{
			name="set_variable_create_keybind_component",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_create_list":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="values", type="any"})
		return Action{
			name="set_variable_create_list",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_create_map":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="keys", type="list"})
		append(&slots, Slot{name="values", type="list"})
		return Action{
			name="set_variable_create_map",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_create_map_from_values":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="keys", type="any"})
		append(&slots, Slot{name="values", type="any"})
		return Action{
			name="set_variable_create_map_from_values",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_create_translatable_component":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="key", type="text"})
		append(&slots, Slot{name="args", type="text"})
		return Action{
			name="set_variable_create_translatable_component",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_vector_cross_product":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="vector_1", type="vector"})
		append(&slots, Slot{name="vector_2", type="vector"})
		return Action{
			name="set_variable_vector_cross_product",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_decrement":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="number", type="number"})
		return Action{
			name="set_variable_decrement",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_divide":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="value", type="number"})
		append(&slots, Slot{name="division_mode", type="enum", _enum=[dynamic]string{"DEFAULT","ROUND_TO_INT","FLOOR","CEIL"}})
		return Action{
			name="set_variable_divide",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_divide_vector":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="vector", type="vector"})
		append(&slots, Slot{name="divider", type="vector"})
		return Action{
			name="set_variable_divide_vector",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_vector_dot_product":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="vector_1", type="vector"})
		append(&slots, Slot{name="vector_2", type="vector"})
		return Action{
			name="set_variable_vector_dot_product",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_face_location":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="target", type="location"})
		return Action{
			name="set_variable_face_location",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_flatten_list":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="list", type="list"})
		return Action{
			name="set_variable_flatten_list",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_format_timestamp":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="time", type="number"})
		append(&slots, Slot{name="pattern", type="text"})
		append(&slots, Slot{name="zone_id", type="text"})
		append(&slots, Slot{name="locale", type="text"})
		append(&slots, Slot{name="format", type="enum", _enum=[dynamic]string{"CUSTOM","DD_MM_YYYY_HH_MM_S","DD_MM_YYYY","YYYY_MM_DD_HH_MM_S","YYYY_MM_DD","EEE_D_MMMM","EEE_MMMM_D","EEEE","HH_MM_SS","H_MM_A","H_H_M_M_S_S","S_S"}})
		return Action{
			name="set_variable_format_timestamp",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_gaussian_distribution":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="deviant", type="number"})
		append(&slots, Slot{name="mean", type="number"})
		append(&slots, Slot{name="distribution", type="enum", _enum=[dynamic]string{"NORMAL","FOLDER_NORMAL"}})
		return Action{
			name="set_variable_gaussian_distribution",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_all_block_data":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="hide_unspecified", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="set_variable_get_all_block_data",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_all_coordinates":
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="x", type="variable"})
		append(&slots, Slot{name="y", type="variable"})
		append(&slots, Slot{name="z", type="variable"})
		append(&slots, Slot{name="yaw", type="variable"})
		append(&slots, Slot{name="pitch", type="variable"})
		return Action{
			name="set_variable_get_all_coordinates",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_angle_between_vectors":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="vector_1", type="vector"})
		append(&slots, Slot{name="vector_2", type="vector"})
		append(&slots, Slot{name="angle_units", type="enum", _enum=[dynamic]string{"DEGREES","RADIANS"}})
		return Action{
			name="set_variable_get_angle_between_vectors",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_block_custom_tag":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="tag_name", type="text"})
		append(&slots, Slot{name="tag_value", type="text"})
		append(&slots, Slot{name="default_value", type="any"})
		return Action{
			name="set_variable_get_block_custom_tag",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_block_data":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="tag_name", type="text"})
		return Action{
			name="set_variable_get_block_data",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_block_growth":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="growth_unit", type="enum", _enum=[dynamic]string{"GROWTH_STAGE","GROWTH_PERCENTAGE"}})
		return Action{
			name="set_variable_get_block_growth",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_block_material":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="value_type", type="enum", _enum=[dynamic]string{"ID","ID_WITH_DATA","NAME","ITEM"}})
		return Action{
			name="set_variable_get_block_material",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_block_material_property":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="block", type="block"})
		append(&slots, Slot{name="property", type="enum", _enum=[dynamic]string{"HARDNESS","BLAST_RESISTANCE","SLIPPERINESS"}})
		return Action{
			name="set_variable_get_block_material_property",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_block_power":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="location", type="location"})
		return Action{
			name="set_variable_get_block_power",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_book_text":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="book", type="item"})
		append(&slots, Slot{name="page", type="number"})
		return Action{
			name="set_variable_get_book_text",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_brushable_block_item":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="location", type="location"})
		return Action{
			name="set_variable_get_brushable_block_item",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_bundle_items":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="bundle", type="item"})
		return Action{
			name="set_variable_get_bundle_items",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_char_at":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="text", type="text"})
		append(&slots, Slot{name="index", type="number"})
		return Action{
			name="set_variable_get_char_at",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_color_channels":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="color", type="text"})
		append(&slots, Slot{name="color_channels", type="enum", _enum=[dynamic]string{"RGB","HSB","HSL"}})
		return Action{
			name="set_variable_get_color_channels",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_compass_lodestone":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="item", type="item"})
		return Action{
			name="set_variable_get_compass_lodestone",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_component_children":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="component", type="text"})
		return Action{
			name="set_variable_get_component_children",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_component_decorations":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="component", type="text"})
		return Action{
			name="set_variable_get_component_decorations",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_component_hex_color":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="component", type="text"})
		return Action{
			name="set_variable_get_component_hex_color",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_component_parsing":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="component", type="text"})
		return Action{
			name="set_variable_get_component_parsing",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_container_contents":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="ignore_empty_slots", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="set_variable_get_container_contents",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_container_lock":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="location", type="location"})
		return Action{
			name="set_variable_get_container_lock",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_container_name":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="location", type="location"})
		return Action{
			name="set_variable_get_container_name",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_coordinate":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="type", type="enum", _enum=[dynamic]string{"X","Y","Z","YAW","PITCH"}})
		return Action{
			name="set_variable_get_coordinate",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_decorate_pot_sherd":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="side", type="enum", _enum=[dynamic]string{"BACK","FRONT","LEFT","RIGHT"}})
		return Action{
			name="set_variable_get_decorate_pot_sherd",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_index_of_subtext":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="text", type="text"})
		append(&slots, Slot{name="subtext", type="text"})
		append(&slots, Slot{name="start_index", type="number"})
		append(&slots, Slot{name="search_mode", type="enum", _enum=[dynamic]string{"FIRST","LAST"}})
		return Action{
			name="set_variable_get_index_of_subtext",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_item_amount":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="item", type="item"})
		return Action{
			name="set_variable_get_item_amount",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_item_attribute":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="item", type="item"})
		append(&slots, Slot{name="name", type="text"})
		append(&slots, Slot{name="attribute", type="enum", _enum=[dynamic]string{"GENERIC_ARMOR","GENERIC_ARMOR_TOUGHNESS","GENERIC_ATTACK_DAMAGE","GENERIC_ATTACK_KNOCKBACK","GENERIC_ATTACK_SPEED","GENERIC_FLYING_SPEED","GENERIC_FOLLOW_RANGE","GENERIC_KNOCKBACK_RESISTANCE","GENERIC_LUCK","GENERIC_MAX_HEALTH","GENERIC_MOVEMENT_SPEED","HORSE_JUMP_STRENGTH","ZOMBIE_SPAWN_REINFORCEMENTS"}})
		append(&slots, Slot{name="slot", type="enum", _enum=[dynamic]string{"ALL","MAIN_HAND","OFF_HAND","HEAD","CHEST","LEGGINGS","BOOTS"}})
		append(&slots, Slot{name="operation", type="enum", _enum=[dynamic]string{"MULTIPLY_SCALAR_1","ADD_NUMBER","ADD_SCALAR"}})
		return Action{
			name="set_variable_get_item_attribute",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_item_color":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="item", type="item"})
		return Action{
			name="set_variable_get_item_color",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_item_custom_model_data":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="item", type="item"})
		return Action{
			name="set_variable_get_item_custom_model_data",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_item_custom_tag":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="item", type="item"})
		append(&slots, Slot{name="tag_name", type="text"})
		append(&slots, Slot{name="default_value", type="any"})
		return Action{
			name="set_variable_get_item_custom_tag",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_item_custom_tags":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="item", type="item"})
		return Action{
			name="set_variable_get_item_custom_tags",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_item_destroyable_blocks":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="item", type="item"})
		return Action{
			name="set_variable_get_item_destroyable_blocks",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_item_durability":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="item", type="item"})
		append(&slots, Slot{name="durability_type", type="enum", _enum=[dynamic]string{"DAMAGE","DAMAGE_PERCENTAGE","REMAINING","REMAINING_PERCENTAGE","MAXIMUM"}})
		return Action{
			name="set_variable_get_item_durability",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_item_enchantments":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="item", type="item"})
		return Action{
			name="set_variable_get_item_enchantments",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_item_lore":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="item", type="item"})
		return Action{
			name="set_variable_get_item_lore",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_item_lore_line":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="item", type="item"})
		append(&slots, Slot{name="line", type="number"})
		return Action{
			name="set_variable_get_item_lore_line",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_item_type":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="type", type="item"})
		append(&slots, Slot{name="value", type="enum", _enum=[dynamic]string{"ID","NAME","ITEM"}})
		return Action{
			name="set_variable_get_item_type",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_item_max_stack_size":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="item", type="item"})
		return Action{
			name="set_variable_get_item_max_stack_size",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_item_name":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="item", type="item"})
		return Action{
			name="set_variable_get_item_name",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_item_nbt_tags":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="item", type="item"})
		return Action{
			name="set_variable_get_item_nbt_tags",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_item_placeable_blocks":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="item", type="item"})
		return Action{
			name="set_variable_get_item_placeable_blocks",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_item_potion_effects":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="item", type="item"})
		return Action{
			name="set_variable_get_item_potion_effects",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_item_rarity":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="item", type="item"})
		return Action{
			name="set_variable_get_item_rarity",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_lectern_book":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="location", type="location"})
		return Action{
			name="set_variable_get_lectern_book",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_lectern_page":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="location", type="location"})
		return Action{
			name="set_variable_get_lectern_page",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_light_level":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="value_type", type="enum", _enum=[dynamic]string{"TOTAL","SKY","BLOCKS"}})
		return Action{
			name="set_variable_get_light_level",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_list_index_of_value":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="list", type="list"})
		append(&slots, Slot{name="value", type="any"})
		append(&slots, Slot{name="search_mode", type="enum", _enum=[dynamic]string{"FIRST","LAST"}})
		return Action{
			name="set_variable_get_list_index_of_value",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_list_length":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="list", type="list"})
		return Action{
			name="set_variable_get_list_length",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_list_random_value":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="list", type="list"})
		return Action{
			name="set_variable_get_list_random_value",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_list_value":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="list", type="list"})
		append(&slots, Slot{name="number", type="number"})
		append(&slots, Slot{name="default_value", type="any"})
		return Action{
			name="set_variable_get_list_value",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_list_variables":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="scope", type="enum", _enum=[dynamic]string{"GAME","SAVE","LOCAL"}})
		return Action{
			name="set_variable_get_list_variables",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_location_direction":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="location", type="location"})
		return Action{
			name="set_variable_get_location_direction",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_map_key_by_index":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="map", type="dictionary"})
		append(&slots, Slot{name="index", type="number"})
		append(&slots, Slot{name="default_value", type="any"})
		return Action{
			name="set_variable_get_map_key_by_index",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_map_keys":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="map", type="dictionary"})
		return Action{
			name="set_variable_get_map_keys",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_map_keys_by_value":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="map", type="dictionary"})
		append(&slots, Slot{name="value", type="any"})
		append(&slots, Slot{name="default_value", type="any"})
		append(&slots, Slot{name="find_mode", type="enum", _enum=[dynamic]string{"FIRST","LAST","ALL"}})
		return Action{
			name="set_variable_get_map_keys_by_value",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_map_size":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="map", type="dictionary"})
		return Action{
			name="set_variable_get_map_size",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_map_value":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="map", type="dictionary"})
		append(&slots, Slot{name="key", type="any"})
		append(&slots, Slot{name="default_value", type="any"})
		return Action{
			name="set_variable_get_map_value",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_map_value_by_index":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="map", type="dictionary"})
		append(&slots, Slot{name="index", type="number"})
		append(&slots, Slot{name="default_value", type="any"})
		return Action{
			name="set_variable_get_map_value_by_index",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_map_values":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="map", type="dictionary"})
		return Action{
			name="set_variable_get_map_values",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_midpoint_between_vectors":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="vector_1", type="vector"})
		append(&slots, Slot{name="vector_2", type="vector"})
		return Action{
			name="set_variable_get_midpoint_between_vectors",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_particle_amount":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="particle", type="particle"})
		return Action{
			name="set_variable_get_particle_amount",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_particle_color":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="particle", type="particle"})
		append(&slots, Slot{name="color_type", type="enum", _enum=[dynamic]string{"COLOR","TO_COLOR"}})
		return Action{
			name="set_variable_get_particle_color",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_particle_material":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="particle", type="particle"})
		return Action{
			name="set_variable_get_particle_material",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_particle_offset":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="particle", type="particle"})
		return Action{
			name="set_variable_get_particle_offset",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_particle_size":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="particle", type="particle"})
		return Action{
			name="set_variable_get_particle_size",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_particle_spread":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="particle", type="particle"})
		append(&slots, Slot{name="type", type="enum", _enum=[dynamic]string{"VERTICAL","HORIZONTAL"}})
		return Action{
			name="set_variable_get_particle_spread",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_particle_type":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="particle", type="particle"})
		return Action{
			name="set_variable_get_particle_type",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_player_head":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="name_or_uuid", type="text"})
		append(&slots, Slot{name="receive_type", type="enum", _enum=[dynamic]string{"NAME_OR_UUID","VALUE"}})
		return Action{
			name="set_variable_get_player_head",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_player_head_owner":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="head", type="item"})
		append(&slots, Slot{name="return_value", type="enum", _enum=[dynamic]string{"NAME","UUID","VALUE"}})
		return Action{
			name="set_variable_get_player_head_owner",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_player_head_value":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="return_value", type="enum", _enum=[dynamic]string{"NAME","UUID","VALUE"}})
		return Action{
			name="set_variable_get_player_head_value",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_potion_effect_amplifier":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="potion", type="potion"})
		return Action{
			name="set_variable_get_potion_effect_amplifier",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_potion_effect_duration":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="potion", type="potion"})
		return Action{
			name="set_variable_get_potion_effect_duration",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_potion_effect_type":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="potion", type="potion"})
		return Action{
			name="set_variable_get_potion_effect_type",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_sculk_shrieker_warning_level":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="location", type="location"})
		return Action{
			name="set_variable_get_sculk_shrieker_warning_level",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_sign_text":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="check_side", type="enum", _enum=[dynamic]string{"FRONT","BACK","ALL"}})
		append(&slots, Slot{name="sign_line", type="enum", _enum=[dynamic]string{"FIRST","SECOND","THIRD","FOURTH","ALL"}})
		return Action{
			name="set_variable_get_sign_text",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_sound_pitch":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="sound", type="sound"})
		return Action{
			name="set_variable_get_sound_pitch",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_sound_source":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="sound", type="sound"})
		return Action{
			name="set_variable_get_sound_source",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_sound_type":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="sound", type="sound"})
		return Action{
			name="set_variable_get_sound_type",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_sound_variation":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="sound", type="sound"})
		return Action{
			name="set_variable_get_sound_variation",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_sound_variations":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="sound", type="sound"})
		return Action{
			name="set_variable_get_sound_variations",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_sound_volume_action":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="sound", type="sound"})
		return Action{
			name="set_variable_get_sound_volume_action",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_template_code":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="template", type="item"})
		append(&slots, Slot{name="return_type", type="enum", _enum=[dynamic]string{"TEXT","MAP"}})
		return Action{
			name="set_variable_get_template_code",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_text_length":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="text", type="text"})
		return Action{
			name="set_variable_text_length",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_text_width":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="text", type="text"})
		return Action{
			name="set_variable_get_text_width",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_vector_all_components":
		append(&slots, Slot{name="vector", type="vector"})
		append(&slots, Slot{name="x", type="variable"})
		append(&slots, Slot{name="y", type="variable"})
		append(&slots, Slot{name="z", type="variable"})
		return Action{
			name="set_variable_get_vector_all_components",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_vector_between_locations":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="start_location", type="location"})
		append(&slots, Slot{name="end_location", type="location"})
		return Action{
			name="set_variable_get_vector_between_locations",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_vector_component":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="vector", type="vector"})
		append(&slots, Slot{name="vector_component", type="enum", _enum=[dynamic]string{"X","Y","Z"}})
		return Action{
			name="set_variable_get_vector_component",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_vector_from_block_face":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="block_face", type="text"})
		return Action{
			name="set_variable_get_vector_from_block_face",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_get_vector_length":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="vector", type="vector"})
		append(&slots, Slot{name="length_type", type="enum", _enum=[dynamic]string{"LENGTH","LENGTH_SQUARED"}})
		return Action{
			name="set_variable_get_vector_length",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_hash":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="text", type="text"})
		append(&slots, Slot{name="algorithm", type="enum", _enum=[dynamic]string{"MD5","SHA1","SHA256"}})
		return Action{
			name="set_variable_hash",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_increment":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="number", type="number"})
		return Action{
			name="set_variable_increment",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_insert_list_value":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="list", type="list"})
		append(&slots, Slot{name="number", type="number"})
		append(&slots, Slot{name="value", type="any"})
		return Action{
			name="set_variable_insert_list_value",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_join_text":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="list", type="list"})
		append(&slots, Slot{name="separator", type="text"})
		append(&slots, Slot{name="prefix", type="text"})
		append(&slots, Slot{name="postfix", type="text"})
		append(&slots, Slot{name="limit", type="number"})
		append(&slots, Slot{name="truncated", type="text"})
		return Action{
			name="set_variable_join_text",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_lerp_number":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="start", type="number"})
		append(&slots, Slot{name="stop", type="number"})
		append(&slots, Slot{name="amount", type="number"})
		return Action{
			name="set_variable_lerp_number",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_location_relative":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="distance", type="number"})
		append(&slots, Slot{name="block_face", type="enum", _enum=[dynamic]string{"NORTH","EAST","SOUTH","WEST","UP","DOWN","NORTH_EAST","NORTH_WEST","SOUTH_EAST","SOUTH_WEST"}})
		return Action{
			name="set_variable_location_relative",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_locations_distance":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="location_1", type="location"})
		append(&slots, Slot{name="location_2", type="location"})
		append(&slots, Slot{name="type", type="enum", _enum=[dynamic]string{"THREE_D","TWO_D","Altitude"}})
		return Action{
			name="set_variable_locations_distance",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_log":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="number", type="number"})
		append(&slots, Slot{name="base", type="number"})
		return Action{
			name="set_variable_log",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_map_range":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="number", type="number"})
		append(&slots, Slot{name="from_start", type="number"})
		append(&slots, Slot{name="from_stop", type="number"})
		append(&slots, Slot{name="to_start", type="number"})
		append(&slots, Slot{name="to_stop", type="number"})
		return Action{
			name="set_variable_map_range",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_max":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="value", type="number"})
		return Action{
			name="set_variable_max",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_min":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="value", type="number"})
		return Action{
			name="set_variable_min",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_multiply":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="value", type="number"})
		return Action{
			name="set_variable_multiply",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_multiply_vector":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="vector", type="vector"})
		append(&slots, Slot{name="multiplier", type="number"})
		return Action{
			name="set_variable_multiply_vector",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_parse_json":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="json", type="text"})
		return Action{
			name="set_variable_parse_json",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_parse_to_component":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="text", type="text"})
		append(&slots, Slot{name="parsing", type="enum", _enum=[dynamic]string{"PLAIN","LEGACY","MINIMESSAGE","JSON"}})
		return Action{
			name="set_variable_parse_to_component",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_perlin_noise_3d":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="seed", type="number"})
		append(&slots, Slot{name="loc_frequency", type="number"})
		append(&slots, Slot{name="octaves", type="number"})
		append(&slots, Slot{name="frequency", type="number"})
		append(&slots, Slot{name="amplitude", type="number"})
		append(&slots, Slot{name="range_mode", type="enum", _enum=[dynamic]string{"ZERO_TO_ONE","FULL_RANGE"}})
		append(&slots, Slot{name="normalized", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="set_variable_perlin_noise_3d",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_pow":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="base", type="number"})
		append(&slots, Slot{name="power", type="number"})
		return Action{
			name="set_variable_pow",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_purge":
		append(&slots, Slot{name="names", type="text"})
		append(&slots, Slot{name="scope", type="enum", _enum=[dynamic]string{"GAME","SAVE","LOCAL"}})
		append(&slots, Slot{name="match", type="enum", _enum=[dynamic]string{"EQUALS","NAME_CONTAINS","PART_CONTAINS"}})
		append(&slots, Slot{name="ignore_case", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="set_variable_purge",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_random":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="values", type="any"})
		return Action{
			name="set_variable_random",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_randomize_list_order":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="list", type="list"})
		return Action{
			name="set_variable_randomize_list_order",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_random_location":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="location_1", type="location"})
		append(&slots, Slot{name="location_2", type="location"})
		append(&slots, Slot{name="integer", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="set_variable_random_location",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_random_number":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="min", type="number"})
		append(&slots, Slot{name="max", type="number"})
		append(&slots, Slot{name="integer", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="set_variable_random_number",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_ray_trace_result":
		append(&slots, Slot{name="start", type="location"})
		append(&slots, Slot{name="ray_size", type="number"})
		append(&slots, Slot{name="max_distance", type="number"})
		append(&slots, Slot{name="ray_collision_mode", type="enum", _enum=[dynamic]string{"ONLY_BLOCKS","BLOCKS_AND_ENTITIES","ONLY_ENTITIES"}})
		append(&slots, Slot{name="ignore_passable_blocks", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		append(&slots, Slot{name="fluid_collision_mode", type="enum", _enum=[dynamic]string{"NEVER","SOURCE_ONLY","ALWAYS"}})
		append(&slots, Slot{name="variable_for_hit_location", type="variable"})
		append(&slots, Slot{name="variable_for_hit_block_location", type="variable"})
		append(&slots, Slot{name="variable_for_hit_block_face", type="variable"})
		append(&slots, Slot{name="variable_for_hit_entity_uuid", type="variable"})
		append(&slots, Slot{name="entities", type="list"})
		return Action{
			name="set_variable_ray_trace_result",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_reflect_vector_product":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="vector_1", type="vector"})
		append(&slots, Slot{name="vector_2", type="vector"})
		append(&slots, Slot{name="bounce", type="number"})
		return Action{
			name="set_variable_reflect_vector_product",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_regex_replace_text":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="text", type="text"})
		append(&slots, Slot{name="regex", type="text"})
		append(&slots, Slot{name="replacement", type="text"})
		append(&slots, Slot{name="first", type="enum", _enum=[dynamic]string{"ANY","FIRST"}})
		append(&slots, Slot{name="ignore_case", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		append(&slots, Slot{name="multiline", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		append(&slots, Slot{name="literal", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		append(&slots, Slot{name="unix_lines", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		append(&slots, Slot{name="comments", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		append(&slots, Slot{name="dot_matches_all", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		append(&slots, Slot{name="cannon_eq", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="set_variable_regex_replace_text",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_remainder":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="dividend", type="number"})
		append(&slots, Slot{name="divisor", type="number"})
		append(&slots, Slot{name="remainder_mode", type="enum", _enum=[dynamic]string{"REMAINDER","MODULO"}})
		return Action{
			name="set_variable_remainder",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_remove_compass_lodestone":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="item", type="item"})
		return Action{
			name="set_variable_remove_compass_lodestone",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_remove_item_attribute":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="item", type="item"})
		append(&slots, Slot{name="name_or_uuid", type="text"})
		append(&slots, Slot{name="attribute", type="enum", _enum=[dynamic]string{"GENERIC_ARMOR","GENERIC_ARMOR_TOUGHNESS","GENERIC_ATTACK_DAMAGE","GENERIC_ATTACK_KNOCKBACK","GENERIC_ATTACK_SPEED","GENERIC_FLYING_SPEED","GENERIC_FOLLOW_RANGE","GENERIC_KNOCKBACK_RESISTANCE","GENERIC_LUCK","GENERIC_MAX_HEALTH","GENERIC_MOVEMENT_SPEED","HORSE_JUMP_STRENGTH","ZOMBIE_SPAWN_REINFORCEMENTS"}})
		return Action{
			name="set_variable_remove_item_attribute",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_remove_item_custom_model_data":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="item", type="item"})
		return Action{
			name="set_variable_remove_item_custom_model_data",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_remove_item_custom_tag":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="item", type="item"})
		append(&slots, Slot{name="tag_name", type="text"})
		return Action{
			name="set_variable_remove_item_custom_tag",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_remove_enchantment":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="item", type="item"})
		append(&slots, Slot{name="enchantment", type="text"})
		return Action{
			name="set_variable_remove_enchantment",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_remove_item_lore_line":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="item", type="item"})
		append(&slots, Slot{name="line", type="number"})
		return Action{
			name="set_variable_remove_item_lore_line",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_remove_item_potion_effects":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="item", type="item"})
		append(&slots, Slot{name="effects", type="potion"})
		return Action{
			name="set_variable_remove_item_potion_effects",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_remove_list_duplicates":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="list", type="list"})
		return Action{
			name="set_variable_remove_list_duplicates",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_remove_list_value":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="list", type="list"})
		append(&slots, Slot{name="value", type="any"})
		append(&slots, Slot{name="remove_mode", type="enum", _enum=[dynamic]string{"FIRST","LAST","ALL"}})
		return Action{
			name="set_variable_remove_list_value",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_remove_list_value_at_index":
		append(&slots, Slot{name="removed_value", type="variable"})
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="list", type="list"})
		append(&slots, Slot{name="index", type="number"})
		return Action{
			name="set_variable_remove_list_value_at_index",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_remove_map_entry":
		append(&slots, Slot{name="removed_value", type="variable"})
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="map", type="dictionary"})
		append(&slots, Slot{name="key", type="any"})
		append(&slots, Slot{name="values", type="any"})
		return Action{
			name="set_variable_remove_map_entry",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_remove_text":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="text", type="text"})
		append(&slots, Slot{name="regex", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		append(&slots, Slot{name="remove", type="text"})
		return Action{
			name="set_variable_remove_text",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_repeat_text":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="text", type="text"})
		append(&slots, Slot{name="repeat", type="number"})
		return Action{
			name="set_variable_repeat_text",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_replace_text":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="text", type="text"})
		append(&slots, Slot{name="replace", type="text"})
		append(&slots, Slot{name="replacement", type="text"})
		append(&slots, Slot{name="first", type="enum", _enum=[dynamic]string{"ANY","FIRST"}})
		append(&slots, Slot{name="ignore_case", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="set_variable_replace_text",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_reverse_list":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="list", type="list"})
		return Action{
			name="set_variable_reverse_list",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_root":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="base", type="number"})
		append(&slots, Slot{name="root", type="number"})
		return Action{
			name="set_variable_root",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_rotate_vector_around_axis":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="vector", type="vector"})
		append(&slots, Slot{name="angle", type="number"})
		append(&slots, Slot{name="axis", type="enum", _enum=[dynamic]string{"X","Y","Z"}})
		append(&slots, Slot{name="angle_units", type="enum", _enum=[dynamic]string{"DEGREES","RADIANS"}})
		return Action{
			name="set_variable_rotate_vector_around_axis",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_rotate_vector_around_vector":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="rotating_vector", type="vector"})
		append(&slots, Slot{name="axis_vector", type="vector"})
		append(&slots, Slot{name="angle", type="number"})
		append(&slots, Slot{name="angle_units", type="enum", _enum=[dynamic]string{"DEGREES","RADIANS"}})
		return Action{
			name="set_variable_rotate_vector_around_vector",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_round":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="number", type="number"})
		append(&slots, Slot{name="precision", type="number"})
		append(&slots, Slot{name="round_type", type="enum", _enum=[dynamic]string{"ROUND","FLOOR","CEIL"}})
		return Action{
			name="set_variable_round",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_set_all_coordinates":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="x", type="number"})
		append(&slots, Slot{name="y", type="number"})
		append(&slots, Slot{name="z", type="number"})
		append(&slots, Slot{name="yaw", type="number"})
		append(&slots, Slot{name="pitch", type="number"})
		return Action{
			name="set_variable_set_all_coordinates",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_set_armor_trim":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="armor", type="item"})
		append(&slots, Slot{name="material", type="item"})
		append(&slots, Slot{name="pattern", type="item"})
		return Action{
			name="set_variable_set_armor_trim",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_set_book_page":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="book", type="item"})
		append(&slots, Slot{name="text", type="text"})
		append(&slots, Slot{name="page", type="number"})
		append(&slots, Slot{name="mode", type="enum", _enum=[dynamic]string{"MERGE","APPEND"}})
		return Action{
			name="set_variable_set_book_page",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_set_book_pages":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="book", type="item"})
		append(&slots, Slot{name="text", type="text"})
		return Action{
			name="set_variable_set_book_pages",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_set_bundle_items":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="bundle", type="item"})
		append(&slots, Slot{name="items", type="item"})
		append(&slots, Slot{name="setting_mode", type="enum", _enum=[dynamic]string{"ADD","SET","REMOVE"}})
		return Action{
			name="set_variable_set_bundle_items",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_set_compass_lodestone":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="item", type="item"})
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="tracked", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="set_variable_set_compass_lodestone",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_set_component_children":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="component", type="text"})
		append(&slots, Slot{name="children", type="text"})
		return Action{
			name="set_variable_set_component_children",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_set_component_click":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="component", type="text"})
		append(&slots, Slot{name="value", type="text"})
		append(&slots, Slot{name="click_action", type="enum", _enum=[dynamic]string{"COPY_TO_CLIPBOARD","SUGGEST_COMMAND","OPEN_URL","CHANGE_PAGE"}})
		return Action{
			name="set_variable_set_component_click",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_set_component_decorations":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="component", type="text"})
		append(&slots, Slot{name="bold", type="enum", _enum=[dynamic]string{"FALSE","NOT_SET","TRUE"}})
		append(&slots, Slot{name="italic", type="enum", _enum=[dynamic]string{"FALSE","NOT_SET","TRUE"}})
		append(&slots, Slot{name="underlined", type="enum", _enum=[dynamic]string{"FALSE","NOT_SET","TRUE"}})
		append(&slots, Slot{name="strikethrough", type="enum", _enum=[dynamic]string{"FALSE","NOT_SET","TRUE"}})
		append(&slots, Slot{name="obfuscated", type="enum", _enum=[dynamic]string{"FALSE","NOT_SET","TRUE"}})
		return Action{
			name="set_variable_set_component_decorations",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_set_component_entity_hover":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="component", type="text"})
		append(&slots, Slot{name="name_or_uuid", type="text"})
		return Action{
			name="set_variable_set_component_entity_hover",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_set_component_font":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="component", type="text"})
		append(&slots, Slot{name="namespace", type="text"})
		append(&slots, Slot{name="value", type="text"})
		return Action{
			name="set_variable_set_component_font",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_set_component_hex_color":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="component", type="text"})
		append(&slots, Slot{name="color", type="text"})
		return Action{
			name="set_variable_set_component_hex_color",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_set_component_hover":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="component", type="text"})
		append(&slots, Slot{name="hover", type="text"})
		return Action{
			name="set_variable_set_component_hover",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_set_component_insertion":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="component", type="text"})
		append(&slots, Slot{name="insertion", type="text"})
		return Action{
			name="set_variable_set_component_insertion",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_set_component_item_hover":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="component", type="text"})
		append(&slots, Slot{name="hover", type="item"})
		return Action{
			name="set_variable_set_component_item_hover",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_set_coordinate":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="coordinate", type="number"})
		append(&slots, Slot{name="type", type="enum", _enum=[dynamic]string{"X","Y","Z","PITCH","YAW"}})
		return Action{
			name="set_variable_set_coordinate",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_set_item_amount":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="item", type="item"})
		append(&slots, Slot{name="amount", type="number"})
		return Action{
			name="set_variable_set_item_amount",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_set_item_attribute":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="item", type="item"})
		append(&slots, Slot{name="amount", type="number"})
		append(&slots, Slot{name="name", type="text"})
		append(&slots, Slot{name="attribute", type="enum", _enum=[dynamic]string{"GENERIC_ARMOR","GENERIC_ARMOR_TOUGHNESS","GENERIC_ATTACK_DAMAGE","GENERIC_ATTACK_KNOCKBACK","GENERIC_ATTACK_SPEED","GENERIC_FLYING_SPEED","GENERIC_FOLLOW_RANGE","GENERIC_KNOCKBACK_RESISTANCE","GENERIC_LUCK","GENERIC_MAX_HEALTH","GENERIC_MOVEMENT_SPEED","HORSE_JUMP_STRENGTH","ZOMBIE_SPAWN_REINFORCEMENTS"}})
		append(&slots, Slot{name="slot", type="enum", _enum=[dynamic]string{"ALL","MAIN_HAND","OFF_HAND","HEAD","CHEST","LEGGINGS","BOOTS"}})
		append(&slots, Slot{name="operation", type="enum", _enum=[dynamic]string{"MULTIPLY_SCALAR_1","ADD_NUMBER","ADD_SCALAR"}})
		return Action{
			name="set_variable_set_item_attribute",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_set_item_color":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="item", type="item"})
		append(&slots, Slot{name="color", type="text"})
		return Action{
			name="set_variable_set_item_color",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_set_item_custom_model_data":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="item", type="item"})
		append(&slots, Slot{name="model", type="number"})
		return Action{
			name="set_variable_set_item_custom_model_data",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_set_item_custom_tag":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="item", type="item"})
		append(&slots, Slot{name="tag_name", type="text"})
		append(&slots, Slot{name="tag_value", type="text"})
		return Action{
			name="set_variable_set_item_custom_tag",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_set_item_destroyable_blocks":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="item", type="item"})
		append(&slots, Slot{name="destroyable", type="item"})
		return Action{
			name="set_variable_set_item_destroyable_blocks",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_set_item_durability":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="item", type="item"})
		append(&slots, Slot{name="durability", type="number"})
		append(&slots, Slot{name="durability_type", type="enum", _enum=[dynamic]string{"DAMAGE","DAMAGE_PERCENTAGE","REMAINING","REMAINING_PERCENTAGE"}})
		return Action{
			name="set_variable_set_item_durability",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_set_item_enchantments":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="item", type="item"})
		append(&slots, Slot{name="enchantments", type="dictionary"})
		return Action{
			name="set_variable_set_item_enchantments",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_set_item_lore":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="lore", type="text"})
		append(&slots, Slot{name="item", type="item"})
		return Action{
			name="set_variable_set_item_lore",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_set_item_lore_line":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="item", type="item"})
		append(&slots, Slot{name="text", type="text"})
		append(&slots, Slot{name="line", type="number"})
		append(&slots, Slot{name="mode", type="enum", _enum=[dynamic]string{"MERGE","APPEND"}})
		return Action{
			name="set_variable_set_item_lore_line",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_set_item_type":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="item", type="item"})
		append(&slots, Slot{name="type", type="text"})
		return Action{
			name="set_variable_set_item_type",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_set_item_name":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="item", type="item"})
		append(&slots, Slot{name="text", type="text"})
		return Action{
			name="set_variable_set_item_name",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_set_item_placeable_blocks":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="item", type="item"})
		append(&slots, Slot{name="placeable", type="item"})
		return Action{
			name="set_variable_set_item_placeable_blocks",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_set_item_unbreakable":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="item", type="item"})
		append(&slots, Slot{name="unbreakable", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="set_variable_set_item_unbreakable",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_set_item_visibility_flags":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="item", type="item"})
		append(&slots, Slot{name="hide_dye", type="enum", _enum=[dynamic]string{"ON","NO_CHANGE","OFF"}})
		append(&slots, Slot{name="hide_enchantments", type="enum", _enum=[dynamic]string{"ON","NO_CHANGE","OFF"}})
		append(&slots, Slot{name="hide_attributes", type="enum", _enum=[dynamic]string{"ON","NO_CHANGE","OFF"}})
		append(&slots, Slot{name="hide_unbreakable", type="enum", _enum=[dynamic]string{"ON","NO_CHANGE","OFF"}})
		append(&slots, Slot{name="hide_place_on", type="enum", _enum=[dynamic]string{"ON","NO_CHANGE","OFF"}})
		append(&slots, Slot{name="hide_destroys", type="enum", _enum=[dynamic]string{"ON","NO_CHANGE","OFF"}})
		append(&slots, Slot{name="hide_potion_effects", type="enum", _enum=[dynamic]string{"ON","NO_CHANGE","OFF"}})
		append(&slots, Slot{name="hide_armor_trim", type="enum", _enum=[dynamic]string{"ON","NO_CHANGE","OFF"}})
		return Action{
			name="set_variable_set_item_visibility_flags",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_set_list_value":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="list", type="list"})
		append(&slots, Slot{name="number", type="number"})
		append(&slots, Slot{name="value", type="any"})
		return Action{
			name="set_variable_set_list_value",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_set_location_direction":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="vector", type="vector"})
		return Action{
			name="set_variable_set_location_direction",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_set_map_value":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="map", type="dictionary"})
		append(&slots, Slot{name="key", type="any"})
		append(&slots, Slot{name="value", type="any"})
		return Action{
			name="set_variable_set_map_value",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_set_particle_amount":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="particle", type="particle"})
		append(&slots, Slot{name="amount", type="number"})
		return Action{
			name="set_variable_set_particle_amount",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_set_particle_color":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="particle", type="particle"})
		append(&slots, Slot{name="hex_color", type="text"})
		append(&slots, Slot{name="color_type", type="enum", _enum=[dynamic]string{"COLOR","TO_COLOR"}})
		return Action{
			name="set_variable_set_particle_color",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_set_particle_material":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="particle", type="particle"})
		append(&slots, Slot{name="material", type="item"})
		return Action{
			name="set_variable_set_particle_material",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_set_particle_offset":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="particle", type="particle"})
		append(&slots, Slot{name="offset", type="vector"})
		return Action{
			name="set_variable_set_particle_offset",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_set_particle_size":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="particle", type="particle"})
		append(&slots, Slot{name="size", type="number"})
		return Action{
			name="set_variable_set_particle_size",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_set_particle_spread":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="particle", type="particle"})
		append(&slots, Slot{name="horizontal", type="number"})
		append(&slots, Slot{name="vertical", type="number"})
		return Action{
			name="set_variable_set_particle_spread",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_set_particle_type":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="particle", type="particle"})
		append(&slots, Slot{name="type", type="text"})
		return Action{
			name="set_variable_set_particle_type",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_set_potion_effect_amplifier":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="potion", type="potion"})
		append(&slots, Slot{name="amplifier", type="number"})
		return Action{
			name="set_variable_set_potion_effect_amplifier",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_set_potion_effect_duration":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="potion", type="potion"})
		append(&slots, Slot{name="duration", type="number"})
		return Action{
			name="set_variable_set_potion_effect_duration",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_set_potion_effect_type":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="potion", type="potion"})
		append(&slots, Slot{name="effect_type", type="text"})
		return Action{
			name="set_variable_set_potion_effect_type",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_set_sound_pitch":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="sound", type="sound"})
		append(&slots, Slot{name="pitch", type="number"})
		return Action{
			name="set_variable_set_sound_pitch",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_set_sound_source":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="sound", type="sound"})
		append(&slots, Slot{name="source", type="enum", _enum=[dynamic]string{"AMBIENT","BLOCK","HOSTILE","MASTER","MUSIC","NEUTRAL","PLAYER","RECORD","VOICE","WEATHER"}})
		return Action{
			name="set_variable_set_sound_source",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_set_sound_type":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="sound", type="sound"})
		append(&slots, Slot{name="namespace", type="text"})
		append(&slots, Slot{name="value", type="text"})
		return Action{
			name="set_variable_set_sound_type",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_set_sound_variation":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="sound", type="sound"})
		append(&slots, Slot{name="variation", type="text"})
		return Action{
			name="set_variable_set_sound_variation",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_set_sound_volume_action":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="sound", type="sound"})
		append(&slots, Slot{name="volume", type="number"})
		return Action{
			name="set_variable_set_sound_volume_action",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_set_template_code":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="template", type="item"})
		append(&slots, Slot{name="code", type="any"})
		return Action{
			name="set_variable_set_template_code",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_set_texture_to_map":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="map", type="item"})
		append(&slots, Slot{name="url", type="text"})
		return Action{
			name="set_variable_set_texture_to_map",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_set_vector_component":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="vector", type="vector"})
		append(&slots, Slot{name="value", type="number"})
		append(&slots, Slot{name="vector_component", type="enum", _enum=[dynamic]string{"X","Y","Z"}})
		return Action{
			name="set_variable_set_vector_component",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_set_vector_length":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="vector", type="vector"})
		append(&slots, Slot{name="length", type="number"})
		return Action{
			name="set_variable_set_vector_length",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_shift_all_coordinates":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="x", type="number"})
		append(&slots, Slot{name="y", type="number"})
		append(&slots, Slot{name="z", type="number"})
		append(&slots, Slot{name="yaw", type="number"})
		append(&slots, Slot{name="pitch", type="number"})
		return Action{
			name="set_variable_shift_all_coordinates",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_shift_coordinate":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="distance", type="number"})
		append(&slots, Slot{name="type", type="enum", _enum=[dynamic]string{"X","Y","Z","PITCH","YAW"}})
		return Action{
			name="set_variable_shift_coordinate",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_shift_location_in_direction":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="shift", type="number"})
		append(&slots, Slot{name="direction", type="enum", _enum=[dynamic]string{"FORWARD","UPWARD","SIDEWAYS"}})
		return Action{
			name="set_variable_shift_location_in_direction",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_shift_location_on_vector":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="vector", type="vector"})
		append(&slots, Slot{name="length", type="number"})
		return Action{
			name="set_variable_shift_location_on_vector",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_shift_location_towards_location":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="location_from", type="location"})
		append(&slots, Slot{name="location_to", type="location"})
		append(&slots, Slot{name="distance", type="number"})
		return Action{
			name="set_variable_shift_location_towards_location",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_simplex_noise_3d":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="seed", type="number"})
		append(&slots, Slot{name="loc_frequency", type="number"})
		append(&slots, Slot{name="octaves", type="number"})
		append(&slots, Slot{name="frequency", type="number"})
		append(&slots, Slot{name="amplitude", type="number"})
		append(&slots, Slot{name="range_mode", type="enum", _enum=[dynamic]string{"ZERO_TO_ONE","FULL_RANGE"}})
		append(&slots, Slot{name="normalized", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="set_variable_simplex_noise_3d",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_sine":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="number", type="number"})
		append(&slots, Slot{name="variant", type="enum", _enum=[dynamic]string{"SINE","ARCSINE","HYPERBOLIC_SINE"}})
		append(&slots, Slot{name="input", type="enum", _enum=[dynamic]string{"DEGREES","RADIANS"}})
		return Action{
			name="set_variable_sine",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_sort_any_list":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="list", type="list"})
		append(&slots, Slot{name="sort_mode", type="enum", _enum=[dynamic]string{"ASCENDING","DESCENDING"}})
		return Action{
			name="set_variable_sort_any_list",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_sort_any_map":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="map", type="dictionary"})
		append(&slots, Slot{name="sort_order", type="enum", _enum=[dynamic]string{"ASCENDING","DESCENDING"}})
		append(&slots, Slot{name="sort_type", type="enum", _enum=[dynamic]string{"KEYS","VALUES"}})
		return Action{
			name="set_variable_sort_any_map",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_split_text":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="text", type="text"})
		append(&slots, Slot{name="delimiter", type="text"})
		return Action{
			name="set_variable_split_text",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_strip_text":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="text", type="text"})
		append(&slots, Slot{name="strip_type", type="enum", _enum=[dynamic]string{"ALL","START","END","INDENT"}})
		return Action{
			name="set_variable_strip_text",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_subtract":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="value", type="number"})
		return Action{
			name="set_variable_subtract",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_subtract_vectors":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="vectors", type="vector"})
		return Action{
			name="set_variable_subtract_vectors",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_tangent":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="number", type="number"})
		append(&slots, Slot{name="variant", type="enum", _enum=[dynamic]string{"TANGENT","ARCTANGENT","HYPERBOLIC_TANGENT"}})
		append(&slots, Slot{name="input", type="enum", _enum=[dynamic]string{"DEGREES","RADIANS"}})
		return Action{
			name="set_variable_tangent",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_text":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="text", type="text"})
		append(&slots, Slot{name="merging", type="enum", _enum=[dynamic]string{"SPACES","CONCATENATION","SEPARATE_LINES"}})
		return Action{
			name="set_variable_text",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_text_case":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="text", type="text"})
		append(&slots, Slot{name="case_type", type="enum", _enum=[dynamic]string{"UPPER","LOWER","PROPER","INVERT","RANDOM"}})
		return Action{
			name="set_variable_text_case",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_to_char":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="number", type="number"})
		return Action{
			name="set_variable_to_char",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_to_hsb":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="hue", type="number"})
		append(&slots, Slot{name="saturation", type="number"})
		append(&slots, Slot{name="brightness", type="number"})
		return Action{
			name="set_variable_to_hsb",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_to_hsl":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="hue", type="number"})
		append(&slots, Slot{name="saturation", type="number"})
		append(&slots, Slot{name="lightness", type="number"})
		return Action{
			name="set_variable_to_hsl",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_to_json":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="value", type="any"})
		append(&slots, Slot{name="pretty_print", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="set_variable_to_json",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_to_rgb":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="red", type="number"})
		append(&slots, Slot{name="green", type="number"})
		append(&slots, Slot{name="blue", type="number"})
		return Action{
			name="set_variable_to_rgb",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_trim_list":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="list", type="list"})
		append(&slots, Slot{name="start", type="number"})
		append(&slots, Slot{name="end", type="number"})
		return Action{
			name="set_variable_trim_list",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_trim_text":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="text", type="text"})
		append(&slots, Slot{name="start", type="number"})
		append(&slots, Slot{name="end", type="number"})
		return Action{
			name="set_variable_trim_text",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_vector":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="x", type="number"})
		append(&slots, Slot{name="y", type="number"})
		append(&slots, Slot{name="z", type="number"})
		return Action{
			name="set_variable_vector",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_vector_to_direction_name":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="vector", type="vector"})
		return Action{
			name="set_variable_vector_to_direction_name",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_voronoi_noise_3d":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="location", type="location"})
		append(&slots, Slot{name="seed", type="number"})
		append(&slots, Slot{name="frequency", type="number"})
		append(&slots, Slot{name="displacement", type="number"})
		append(&slots, Slot{name="range_mode", type="enum", _enum=[dynamic]string{"ZERO_TO_ONE","FULL_RANGE"}})
		append(&slots, Slot{name="enable_distance", type="enum", _enum=[dynamic]string{"TRUE","FALSE"}})
		return Action{
			name="set_variable_voronoi_noise_3d",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "set_variable_warp":
		append(&slots, Slot{name="variable", type="variable"})
		append(&slots, Slot{name="number", type="number"})
		append(&slots, Slot{name="min", type="number"})
		append(&slots, Slot{name="max", type="number"})
		return Action{
			name="set_variable_warp",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	case "start_process":
		append(&slots, Slot{name="process_name", type="text"})
		append(&slots, Slot{name="target_mode", type="enum", _enum=[dynamic]string{"CURRENT_TARGET","CURRENT_SELECTION","NO_TARGET","FOR_EACH_IN_SELECTION"}})
		append(&slots, Slot{name="local_variables_mode", type="enum", _enum=[dynamic]string{"DONT_COPY","COPY","SHARE"}})
		return Action{
			name="start_process",
			in_slots=[dynamic]string{},
			out_slots=[dynamic]string{},
			accept_selector=false,
			type=Action_Type.BASIC,
			slots=slots,
		}, true
	}
	return Action{}, false
}
