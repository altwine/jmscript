package assets

Particle :: struct {
	name: string,
}

particles: map[string]Particle

init_particles :: proc(allocator := context.allocator) {
	particles = make(map[string]Particle, 114, allocator)
	particles["angry_villager"] = {"angry_villager"}
	particles["block"] = {"block"}
	particles["block_marker"] = {"block_marker"}
	particles["bubble"] = {"bubble"}
	particles["cloud"] = {"cloud"}
	particles["crit"] = {"crit"}
	particles["damage_indicator"] = {"damage_indicator"}
	particles["dragon_breath"] = {"dragon_breath"}
	particles["dripping_lava"] = {"dripping_lava"}
	particles["falling_lava"] = {"falling_lava"}
	particles["landing_lava"] = {"landing_lava"}
	particles["dripping_water"] = {"dripping_water"}
	particles["falling_water"] = {"falling_water"}
	particles["dust"] = {"dust"}
	particles["dust_color_transition"] = {"dust_color_transition"}
	particles["effect"] = {"effect"}
	particles["elder_guardian"] = {"elder_guardian"}
	particles["enchanted_hit"] = {"enchanted_hit"}
	particles["enchant"] = {"enchant"}
	particles["end_rod"] = {"end_rod"}
	particles["entity_effect"] = {"entity_effect"}
	particles["explosion_emitter"] = {"explosion_emitter"}
	particles["explosion"] = {"explosion"}
	particles["gust"] = {"gust"}
	particles["small_gust"] = {"small_gust"}
	particles["gust_emitter_large"] = {"gust_emitter_large"}
	particles["gust_emitter_small"] = {"gust_emitter_small"}
	particles["sonic_boom"] = {"sonic_boom"}
	particles["falling_dust"] = {"falling_dust"}
	particles["firework"] = {"firework"}
	particles["fishing"] = {"fishing"}
	particles["flame"] = {"flame"}
	particles["infested"] = {"infested"}
	particles["cherry_leaves"] = {"cherry_leaves"}
	particles["pale_oak_leaves"] = {"pale_oak_leaves"}
	particles["tinted_leaves"] = {"tinted_leaves"}
	particles["sculk_soul"] = {"sculk_soul"}
	particles["sculk_charge"] = {"sculk_charge"}
	particles["sculk_charge_pop"] = {"sculk_charge_pop"}
	particles["soul_fire_flame"] = {"soul_fire_flame"}
	particles["soul"] = {"soul"}
	particles["flash"] = {"flash"}
	particles["happy_villager"] = {"happy_villager"}
	particles["composter"] = {"composter"}
	particles["heart"] = {"heart"}
	particles["instant_effect"] = {"instant_effect"}
	particles["item"] = {"item"}
	particles["vibration"] = {"vibration"}
	particles["trail"] = {"trail"}
	particles["item_slime"] = {"item_slime"}
	particles["item_cobweb"] = {"item_cobweb"}
	particles["item_snowball"] = {"item_snowball"}
	particles["large_smoke"] = {"large_smoke"}
	particles["lava"] = {"lava"}
	particles["mycelium"] = {"mycelium"}
	particles["note"] = {"note"}
	particles["poof"] = {"poof"}
	particles["portal"] = {"portal"}
	particles["rain"] = {"rain"}
	particles["smoke"] = {"smoke"}
	particles["white_smoke"] = {"white_smoke"}
	particles["sneeze"] = {"sneeze"}
	particles["spit"] = {"spit"}
	particles["squid_ink"] = {"squid_ink"}
	particles["sweep_attack"] = {"sweep_attack"}
	particles["totem_of_undying"] = {"totem_of_undying"}
	particles["underwater"] = {"underwater"}
	particles["splash"] = {"splash"}
	particles["witch"] = {"witch"}
	particles["bubble_pop"] = {"bubble_pop"}
	particles["current_down"] = {"current_down"}
	particles["bubble_column_up"] = {"bubble_column_up"}
	particles["nautilus"] = {"nautilus"}
	particles["dolphin"] = {"dolphin"}
	particles["campfire_cosy_smoke"] = {"campfire_cosy_smoke"}
	particles["campfire_signal_smoke"] = {"campfire_signal_smoke"}
	particles["dripping_honey"] = {"dripping_honey"}
	particles["falling_honey"] = {"falling_honey"}
	particles["landing_honey"] = {"landing_honey"}
	particles["falling_nectar"] = {"falling_nectar"}
	particles["falling_spore_blossom"] = {"falling_spore_blossom"}
	particles["ash"] = {"ash"}
	particles["crimson_spore"] = {"crimson_spore"}
	particles["warped_spore"] = {"warped_spore"}
	particles["spore_blossom_air"] = {"spore_blossom_air"}
	particles["dripping_obsidian_tear"] = {"dripping_obsidian_tear"}
	particles["falling_obsidian_tear"] = {"falling_obsidian_tear"}
	particles["landing_obsidian_tear"] = {"landing_obsidian_tear"}
	particles["reverse_portal"] = {"reverse_portal"}
	particles["white_ash"] = {"white_ash"}
	particles["small_flame"] = {"small_flame"}
	particles["snowflake"] = {"snowflake"}
	particles["dripping_dripstone_lava"] = {"dripping_dripstone_lava"}
	particles["falling_dripstone_lava"] = {"falling_dripstone_lava"}
	particles["dripping_dripstone_water"] = {"dripping_dripstone_water"}
	particles["falling_dripstone_water"] = {"falling_dripstone_water"}
	particles["glow_squid_ink"] = {"glow_squid_ink"}
	particles["glow"] = {"glow"}
	particles["wax_on"] = {"wax_on"}
	particles["wax_off"] = {"wax_off"}
	particles["electric_spark"] = {"electric_spark"}
	particles["scrape"] = {"scrape"}
	particles["shriek"] = {"shriek"}
	particles["egg_crack"] = {"egg_crack"}
	particles["dust_plume"] = {"dust_plume"}
	particles["trial_spawner_detection"] = {"trial_spawner_detection"}
	particles["trial_spawner_detection_ominous"] = {"trial_spawner_detection_ominous"}
	particles["vault_connection"] = {"vault_connection"}
	particles["dust_pillar"] = {"dust_pillar"}
	particles["ominous_spawning"] = {"ominous_spawning"}
	particles["raid_omen"] = {"raid_omen"}
	particles["trial_omen"] = {"trial_omen"}
	particles["block_crumble"] = {"block_crumble"}
	particles["firefly"] = {"firefly"}
}

cleanup_particles :: proc() {
	delete(particles)
}

get_minecraft_particle :: proc(particle_name: string) -> (Particle, bool) {
	return particles[particle_name]
}
