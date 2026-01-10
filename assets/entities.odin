package assets

Entity :: struct {
	name: string,
}

entities: map[string]Entity

init_entities :: proc(allocator := context.allocator) {
	entities = make(map[string]Entity, 151, allocator)
	entities["acacia_boat"] = {"acacia_boat"}
	entities["acacia_chest_boat"] = {"acacia_chest_boat"}
	entities["allay"] = {"allay"}
	entities["area_effect_cloud"] = {"area_effect_cloud"}
	entities["armadillo"] = {"armadillo"}
	entities["armor_stand"] = {"armor_stand"}
	entities["arrow"] = {"arrow"}
	entities["axolotl"] = {"axolotl"}
	entities["bamboo_chest_raft"] = {"bamboo_chest_raft"}
	entities["bamboo_raft"] = {"bamboo_raft"}
	entities["bat"] = {"bat"}
	entities["bee"] = {"bee"}
	entities["birch_boat"] = {"birch_boat"}
	entities["birch_chest_boat"] = {"birch_chest_boat"}
	entities["blaze"] = {"blaze"}
	entities["block_display"] = {"block_display"}
	entities["bogged"] = {"bogged"}
	entities["breeze"] = {"breeze"}
	entities["breeze_wind_charge"] = {"breeze_wind_charge"}
	entities["camel"] = {"camel"}
	entities["cat"] = {"cat"}
	entities["cave_spider"] = {"cave_spider"}
	entities["cherry_boat"] = {"cherry_boat"}
	entities["cherry_chest_boat"] = {"cherry_chest_boat"}
	entities["chest_minecart"] = {"chest_minecart"}
	entities["chicken"] = {"chicken"}
	entities["cod"] = {"cod"}
	entities["command_block_minecart"] = {"command_block_minecart"}
	entities["cow"] = {"cow"}
	entities["creaking"] = {"creaking"}
	entities["creeper"] = {"creeper"}
	entities["dark_oak_boat"] = {"dark_oak_boat"}
	entities["dark_oak_chest_boat"] = {"dark_oak_chest_boat"}
	entities["dolphin"] = {"dolphin"}
	entities["donkey"] = {"donkey"}
	entities["dragon_fireball"] = {"dragon_fireball"}
	entities["drowned"] = {"drowned"}
	entities["egg"] = {"egg"}
	entities["elder_guardian"] = {"elder_guardian"}
	entities["enderman"] = {"enderman"}
	entities["endermite"] = {"endermite"}
	entities["ender_dragon"] = {"ender_dragon"}
	entities["ender_pearl"] = {"ender_pearl"}
	entities["end_crystal"] = {"end_crystal"}
	entities["evoker"] = {"evoker"}
	entities["evoker_fangs"] = {"evoker_fangs"}
	entities["experience_bottle"] = {"experience_bottle"}
	entities["experience_orb"] = {"experience_orb"}
	entities["eye_of_ender"] = {"eye_of_ender"}
	entities["falling_block"] = {"falling_block"}
	entities["fireball"] = {"fireball"}
	entities["firework_rocket"] = {"firework_rocket"}
	entities["fox"] = {"fox"}
	entities["frog"] = {"frog"}
	entities["furnace_minecart"] = {"furnace_minecart"}
	entities["ghast"] = {"ghast"}
	entities["happy_ghast"] = {"happy_ghast"}
	entities["giant"] = {"giant"}
	entities["glow_item_frame"] = {"glow_item_frame"}
	entities["glow_squid"] = {"glow_squid"}
	entities["goat"] = {"goat"}
	entities["guardian"] = {"guardian"}
	entities["hoglin"] = {"hoglin"}
	entities["hopper_minecart"] = {"hopper_minecart"}
	entities["horse"] = {"horse"}
	entities["husk"] = {"husk"}
	entities["illusioner"] = {"illusioner"}
	entities["interaction"] = {"interaction"}
	entities["iron_golem"] = {"iron_golem"}
	entities["item"] = {"item"}
	entities["item_display"] = {"item_display"}
	entities["item_frame"] = {"item_frame"}
	entities["jungle_boat"] = {"jungle_boat"}
	entities["jungle_chest_boat"] = {"jungle_chest_boat"}
	entities["leash_knot"] = {"leash_knot"}
	entities["lightning_bolt"] = {"lightning_bolt"}
	entities["llama"] = {"llama"}
	entities["llama_spit"] = {"llama_spit"}
	entities["magma_cube"] = {"magma_cube"}
	entities["mangrove_boat"] = {"mangrove_boat"}
	entities["mangrove_chest_boat"] = {"mangrove_chest_boat"}
	entities["marker"] = {"marker"}
	entities["minecart"] = {"minecart"}
	entities["mooshroom"] = {"mooshroom"}
	entities["mule"] = {"mule"}
	entities["oak_boat"] = {"oak_boat"}
	entities["oak_chest_boat"] = {"oak_chest_boat"}
	entities["ocelot"] = {"ocelot"}
	entities["ominous_item_spawner"] = {"ominous_item_spawner"}
	entities["painting"] = {"painting"}
	entities["pale_oak_boat"] = {"pale_oak_boat"}
	entities["pale_oak_chest_boat"] = {"pale_oak_chest_boat"}
	entities["panda"] = {"panda"}
	entities["parrot"] = {"parrot"}
	entities["phantom"] = {"phantom"}
	entities["pig"] = {"pig"}
	entities["piglin"] = {"piglin"}
	entities["piglin_brute"] = {"piglin_brute"}
	entities["pillager"] = {"pillager"}
	entities["polar_bear"] = {"polar_bear"}
	entities["splash_potion"] = {"splash_potion"}
	entities["lingering_potion"] = {"lingering_potion"}
	entities["pufferfish"] = {"pufferfish"}
	entities["rabbit"] = {"rabbit"}
	entities["ravager"] = {"ravager"}
	entities["salmon"] = {"salmon"}
	entities["sheep"] = {"sheep"}
	entities["shulker"] = {"shulker"}
	entities["shulker_bullet"] = {"shulker_bullet"}
	entities["silverfish"] = {"silverfish"}
	entities["skeleton"] = {"skeleton"}
	entities["skeleton_horse"] = {"skeleton_horse"}
	entities["slime"] = {"slime"}
	entities["small_fireball"] = {"small_fireball"}
	entities["sniffer"] = {"sniffer"}
	entities["snowball"] = {"snowball"}
	entities["snow_golem"] = {"snow_golem"}
	entities["spawner_minecart"] = {"spawner_minecart"}
	entities["spectral_arrow"] = {"spectral_arrow"}
	entities["spider"] = {"spider"}
	entities["spruce_boat"] = {"spruce_boat"}
	entities["spruce_chest_boat"] = {"spruce_chest_boat"}
	entities["squid"] = {"squid"}
	entities["stray"] = {"stray"}
	entities["strider"] = {"strider"}
	entities["tadpole"] = {"tadpole"}
	entities["text_display"] = {"text_display"}
	entities["tnt"] = {"tnt"}
	entities["tnt_minecart"] = {"tnt_minecart"}
	entities["trader_llama"] = {"trader_llama"}
	entities["trident"] = {"trident"}
	entities["tropical_fish"] = {"tropical_fish"}
	entities["turtle"] = {"turtle"}
	entities["vex"] = {"vex"}
	entities["villager"] = {"villager"}
	entities["vindicator"] = {"vindicator"}
	entities["wandering_trader"] = {"wandering_trader"}
	entities["warden"] = {"warden"}
	entities["wind_charge"] = {"wind_charge"}
	entities["witch"] = {"witch"}
	entities["wither"] = {"wither"}
	entities["wither_skeleton"] = {"wither_skeleton"}
	entities["wither_skull"] = {"wither_skull"}
	entities["wolf"] = {"wolf"}
	entities["zoglin"] = {"zoglin"}
	entities["zombie"] = {"zombie"}
	entities["zombie_horse"] = {"zombie_horse"}
	entities["zombie_villager"] = {"zombie_villager"}
	entities["zombified_piglin"] = {"zombified_piglin"}
	entities["player"] = {"player"}
	entities["fishing_bobber"] = {"fishing_bobber"}
}

cleanup_entities :: proc() {
	delete(entities)
}

get_minecraft_entity :: proc(entity_name: string) -> (Entity, bool) {
	return entities[entity_name]
}
