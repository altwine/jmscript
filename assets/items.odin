package assets

import "base:runtime"

Minecraft_Item :: struct {
	name:         string,
	display_name: string,
	stack_size:   Stack_Type,
}

Stack_Type :: enum {
	Single,
	Quarter,
	Entire,
}

mc_items: map[string]Minecraft_Item

@(init)
init_mc_items :: proc "contextless" () {
	context = runtime.default_context()
	mc_items = make(map[string]Minecraft_Item, context.allocator)
	mc_items["air"] = Minecraft_Item{
		"air",
		"Air",
		.Entire,
	}
	mc_items["stone"] = Minecraft_Item{
		"stone",
		"Stone",
		.Entire,
	}
	mc_items["granite"] = Minecraft_Item{
		"granite",
		"Granite",
		.Entire,
	}
	mc_items["polished_granite"] = Minecraft_Item{
		"polished_granite",
		"Polished Granite",
		.Entire,
	}
	mc_items["diorite"] = Minecraft_Item{
		"diorite",
		"Diorite",
		.Entire,
	}
	mc_items["polished_diorite"] = Minecraft_Item{
		"polished_diorite",
		"Polished Diorite",
		.Entire,
	}
	mc_items["andesite"] = Minecraft_Item{
		"andesite",
		"Andesite",
		.Entire,
	}
	mc_items["polished_andesite"] = Minecraft_Item{
		"polished_andesite",
		"Polished Andesite",
		.Entire,
	}
	mc_items["deepslate"] = Minecraft_Item{
		"deepslate",
		"Deepslate",
		.Entire,
	}
	mc_items["cobbled_deepslate"] = Minecraft_Item{
		"cobbled_deepslate",
		"Cobbled Deepslate",
		.Entire,
	}
	mc_items["polished_deepslate"] = Minecraft_Item{
		"polished_deepslate",
		"Polished Deepslate",
		.Entire,
	}
	mc_items["calcite"] = Minecraft_Item{
		"calcite",
		"Calcite",
		.Entire,
	}
	mc_items["tuff"] = Minecraft_Item{
		"tuff",
		"Tuff",
		.Entire,
	}
	mc_items["tuff_slab"] = Minecraft_Item{
		"tuff_slab",
		"Tuff Slab",
		.Entire,
	}
	mc_items["tuff_stairs"] = Minecraft_Item{
		"tuff_stairs",
		"Tuff Stairs",
		.Entire,
	}
	mc_items["tuff_wall"] = Minecraft_Item{
		"tuff_wall",
		"Tuff Wall",
		.Entire,
	}
	mc_items["chiseled_tuff"] = Minecraft_Item{
		"chiseled_tuff",
		"Chiseled Tuff",
		.Entire,
	}
	mc_items["polished_tuff"] = Minecraft_Item{
		"polished_tuff",
		"Polished Tuff",
		.Entire,
	}
	mc_items["polished_tuff_slab"] = Minecraft_Item{
		"polished_tuff_slab",
		"Polished Tuff Slab",
		.Entire,
	}
	mc_items["polished_tuff_stairs"] = Minecraft_Item{
		"polished_tuff_stairs",
		"Polished Tuff Stairs",
		.Entire,
	}
	mc_items["polished_tuff_wall"] = Minecraft_Item{
		"polished_tuff_wall",
		"Polished Tuff Wall",
		.Entire,
	}
	mc_items["tuff_bricks"] = Minecraft_Item{
		"tuff_bricks",
		"Tuff Bricks",
		.Entire,
	}
	mc_items["tuff_brick_slab"] = Minecraft_Item{
		"tuff_brick_slab",
		"Tuff Brick Slab",
		.Entire,
	}
	mc_items["tuff_brick_stairs"] = Minecraft_Item{
		"tuff_brick_stairs",
		"Tuff Brick Stairs",
		.Entire,
	}
	mc_items["tuff_brick_wall"] = Minecraft_Item{
		"tuff_brick_wall",
		"Tuff Brick Wall",
		.Entire,
	}
	mc_items["chiseled_tuff_bricks"] = Minecraft_Item{
		"chiseled_tuff_bricks",
		"Chiseled Tuff Bricks",
		.Entire,
	}
	mc_items["dripstone_block"] = Minecraft_Item{
		"dripstone_block",
		"Dripstone Block",
		.Entire,
	}
	mc_items["grass_block"] = Minecraft_Item{
		"grass_block",
		"Grass Block",
		.Entire,
	}
	mc_items["dirt"] = Minecraft_Item{
		"dirt",
		"Dirt",
		.Entire,
	}
	mc_items["coarse_dirt"] = Minecraft_Item{
		"coarse_dirt",
		"Coarse Dirt",
		.Entire,
	}
	mc_items["podzol"] = Minecraft_Item{
		"podzol",
		"Podzol",
		.Entire,
	}
	mc_items["rooted_dirt"] = Minecraft_Item{
		"rooted_dirt",
		"Rooted Dirt",
		.Entire,
	}
	mc_items["mud"] = Minecraft_Item{
		"mud",
		"Mud",
		.Entire,
	}
	mc_items["crimson_nylium"] = Minecraft_Item{
		"crimson_nylium",
		"Crimson Nylium",
		.Entire,
	}
	mc_items["warped_nylium"] = Minecraft_Item{
		"warped_nylium",
		"Warped Nylium",
		.Entire,
	}
	mc_items["cobblestone"] = Minecraft_Item{
		"cobblestone",
		"Cobblestone",
		.Entire,
	}
	mc_items["oak_planks"] = Minecraft_Item{
		"oak_planks",
		"Oak Planks",
		.Entire,
	}
	mc_items["spruce_planks"] = Minecraft_Item{
		"spruce_planks",
		"Spruce Planks",
		.Entire,
	}
	mc_items["birch_planks"] = Minecraft_Item{
		"birch_planks",
		"Birch Planks",
		.Entire,
	}
	mc_items["jungle_planks"] = Minecraft_Item{
		"jungle_planks",
		"Jungle Planks",
		.Entire,
	}
	mc_items["acacia_planks"] = Minecraft_Item{
		"acacia_planks",
		"Acacia Planks",
		.Entire,
	}
	mc_items["cherry_planks"] = Minecraft_Item{
		"cherry_planks",
		"Cherry Planks",
		.Entire,
	}
	mc_items["dark_oak_planks"] = Minecraft_Item{
		"dark_oak_planks",
		"Dark Oak Planks",
		.Entire,
	}
	mc_items["pale_oak_planks"] = Minecraft_Item{
		"pale_oak_planks",
		"Pale Oak Planks",
		.Entire,
	}
	mc_items["mangrove_planks"] = Minecraft_Item{
		"mangrove_planks",
		"Mangrove Planks",
		.Entire,
	}
	mc_items["bamboo_planks"] = Minecraft_Item{
		"bamboo_planks",
		"Bamboo Planks",
		.Entire,
	}
	mc_items["crimson_planks"] = Minecraft_Item{
		"crimson_planks",
		"Crimson Planks",
		.Entire,
	}
	mc_items["warped_planks"] = Minecraft_Item{
		"warped_planks",
		"Warped Planks",
		.Entire,
	}
	mc_items["bamboo_mosaic"] = Minecraft_Item{
		"bamboo_mosaic",
		"Bamboo Mosaic",
		.Entire,
	}
	mc_items["oak_sapling"] = Minecraft_Item{
		"oak_sapling",
		"Oak Sapling",
		.Entire,
	}
	mc_items["spruce_sapling"] = Minecraft_Item{
		"spruce_sapling",
		"Spruce Sapling",
		.Entire,
	}
	mc_items["birch_sapling"] = Minecraft_Item{
		"birch_sapling",
		"Birch Sapling",
		.Entire,
	}
	mc_items["jungle_sapling"] = Minecraft_Item{
		"jungle_sapling",
		"Jungle Sapling",
		.Entire,
	}
	mc_items["acacia_sapling"] = Minecraft_Item{
		"acacia_sapling",
		"Acacia Sapling",
		.Entire,
	}
	mc_items["cherry_sapling"] = Minecraft_Item{
		"cherry_sapling",
		"Cherry Sapling",
		.Entire,
	}
	mc_items["dark_oak_sapling"] = Minecraft_Item{
		"dark_oak_sapling",
		"Dark Oak Sapling",
		.Entire,
	}
	mc_items["pale_oak_sapling"] = Minecraft_Item{
		"pale_oak_sapling",
		"Pale Oak Sapling",
		.Entire,
	}
	mc_items["mangrove_propagule"] = Minecraft_Item{
		"mangrove_propagule",
		"Mangrove Propagule",
		.Entire,
	}
	mc_items["bedrock"] = Minecraft_Item{
		"bedrock",
		"Bedrock",
		.Entire,
	}
	mc_items["sand"] = Minecraft_Item{
		"sand",
		"Sand",
		.Entire,
	}
	mc_items["suspicious_sand"] = Minecraft_Item{
		"suspicious_sand",
		"Suspicious Sand",
		.Entire,
	}
	mc_items["suspicious_gravel"] = Minecraft_Item{
		"suspicious_gravel",
		"Suspicious Gravel",
		.Entire,
	}
	mc_items["red_sand"] = Minecraft_Item{
		"red_sand",
		"Red Sand",
		.Entire,
	}
	mc_items["gravel"] = Minecraft_Item{
		"gravel",
		"Gravel",
		.Entire,
	}
	mc_items["coal_ore"] = Minecraft_Item{
		"coal_ore",
		"Coal Ore",
		.Entire,
	}
	mc_items["deepslate_coal_ore"] = Minecraft_Item{
		"deepslate_coal_ore",
		"Deepslate Coal Ore",
		.Entire,
	}
	mc_items["iron_ore"] = Minecraft_Item{
		"iron_ore",
		"Iron Ore",
		.Entire,
	}
	mc_items["deepslate_iron_ore"] = Minecraft_Item{
		"deepslate_iron_ore",
		"Deepslate Iron Ore",
		.Entire,
	}
	mc_items["copper_ore"] = Minecraft_Item{
		"copper_ore",
		"Copper Ore",
		.Entire,
	}
	mc_items["deepslate_copper_ore"] = Minecraft_Item{
		"deepslate_copper_ore",
		"Deepslate Copper Ore",
		.Entire,
	}
	mc_items["gold_ore"] = Minecraft_Item{
		"gold_ore",
		"Gold Ore",
		.Entire,
	}
	mc_items["deepslate_gold_ore"] = Minecraft_Item{
		"deepslate_gold_ore",
		"Deepslate Gold Ore",
		.Entire,
	}
	mc_items["redstone_ore"] = Minecraft_Item{
		"redstone_ore",
		"Redstone Ore",
		.Entire,
	}
	mc_items["deepslate_redstone_ore"] = Minecraft_Item{
		"deepslate_redstone_ore",
		"Deepslate Redstone Ore",
		.Entire,
	}
	mc_items["emerald_ore"] = Minecraft_Item{
		"emerald_ore",
		"Emerald Ore",
		.Entire,
	}
	mc_items["deepslate_emerald_ore"] = Minecraft_Item{
		"deepslate_emerald_ore",
		"Deepslate Emerald Ore",
		.Entire,
	}
	mc_items["lapis_ore"] = Minecraft_Item{
		"lapis_ore",
		"Lapis Lazuli Ore",
		.Entire,
	}
	mc_items["deepslate_lapis_ore"] = Minecraft_Item{
		"deepslate_lapis_ore",
		"Deepslate Lapis Lazuli Ore",
		.Entire,
	}
	mc_items["diamond_ore"] = Minecraft_Item{
		"diamond_ore",
		"Diamond Ore",
		.Entire,
	}
	mc_items["deepslate_diamond_ore"] = Minecraft_Item{
		"deepslate_diamond_ore",
		"Deepslate Diamond Ore",
		.Entire,
	}
	mc_items["nether_gold_ore"] = Minecraft_Item{
		"nether_gold_ore",
		"Nether Gold Ore",
		.Entire,
	}
	mc_items["nether_quartz_ore"] = Minecraft_Item{
		"nether_quartz_ore",
		"Nether Quartz Ore",
		.Entire,
	}
	mc_items["ancient_debris"] = Minecraft_Item{
		"ancient_debris",
		"Ancient Debris",
		.Entire,
	}
	mc_items["coal_block"] = Minecraft_Item{
		"coal_block",
		"Block of Coal",
		.Entire,
	}
	mc_items["raw_iron_block"] = Minecraft_Item{
		"raw_iron_block",
		"Block of Raw Iron",
		.Entire,
	}
	mc_items["raw_copper_block"] = Minecraft_Item{
		"raw_copper_block",
		"Block of Raw Copper",
		.Entire,
	}
	mc_items["raw_gold_block"] = Minecraft_Item{
		"raw_gold_block",
		"Block of Raw Gold",
		.Entire,
	}
	mc_items["heavy_core"] = Minecraft_Item{
		"heavy_core",
		"Heavy Core",
		.Entire,
	}
	mc_items["amethyst_block"] = Minecraft_Item{
		"amethyst_block",
		"Block of Amethyst",
		.Entire,
	}
	mc_items["budding_amethyst"] = Minecraft_Item{
		"budding_amethyst",
		"Budding Amethyst",
		.Entire,
	}
	mc_items["iron_block"] = Minecraft_Item{
		"iron_block",
		"Block of Iron",
		.Entire,
	}
	mc_items["copper_block"] = Minecraft_Item{
		"copper_block",
		"Block of Copper",
		.Entire,
	}
	mc_items["gold_block"] = Minecraft_Item{
		"gold_block",
		"Block of Gold",
		.Entire,
	}
	mc_items["diamond_block"] = Minecraft_Item{
		"diamond_block",
		"Block of Diamond",
		.Entire,
	}
	mc_items["netherite_block"] = Minecraft_Item{
		"netherite_block",
		"Block of Netherite",
		.Entire,
	}
	mc_items["exposed_copper"] = Minecraft_Item{
		"exposed_copper",
		"Exposed Copper",
		.Entire,
	}
	mc_items["weathered_copper"] = Minecraft_Item{
		"weathered_copper",
		"Weathered Copper",
		.Entire,
	}
	mc_items["oxidized_copper"] = Minecraft_Item{
		"oxidized_copper",
		"Oxidized Copper",
		.Entire,
	}
	mc_items["chiseled_copper"] = Minecraft_Item{
		"chiseled_copper",
		"Chiseled Copper",
		.Entire,
	}
	mc_items["exposed_chiseled_copper"] = Minecraft_Item{
		"exposed_chiseled_copper",
		"Exposed Chiseled Copper",
		.Entire,
	}
	mc_items["weathered_chiseled_copper"] = Minecraft_Item{
		"weathered_chiseled_copper",
		"Weathered Chiseled Copper",
		.Entire,
	}
	mc_items["oxidized_chiseled_copper"] = Minecraft_Item{
		"oxidized_chiseled_copper",
		"Oxidized Chiseled Copper",
		.Entire,
	}
	mc_items["cut_copper"] = Minecraft_Item{
		"cut_copper",
		"Cut Copper",
		.Entire,
	}
	mc_items["exposed_cut_copper"] = Minecraft_Item{
		"exposed_cut_copper",
		"Exposed Cut Copper",
		.Entire,
	}
	mc_items["weathered_cut_copper"] = Minecraft_Item{
		"weathered_cut_copper",
		"Weathered Cut Copper",
		.Entire,
	}
	mc_items["oxidized_cut_copper"] = Minecraft_Item{
		"oxidized_cut_copper",
		"Oxidized Cut Copper",
		.Entire,
	}
	mc_items["cut_copper_stairs"] = Minecraft_Item{
		"cut_copper_stairs",
		"Cut Copper Stairs",
		.Entire,
	}
	mc_items["exposed_cut_copper_stairs"] = Minecraft_Item{
		"exposed_cut_copper_stairs",
		"Exposed Cut Copper Stairs",
		.Entire,
	}
	mc_items["weathered_cut_copper_stairs"] = Minecraft_Item{
		"weathered_cut_copper_stairs",
		"Weathered Cut Copper Stairs",
		.Entire,
	}
	mc_items["oxidized_cut_copper_stairs"] = Minecraft_Item{
		"oxidized_cut_copper_stairs",
		"Oxidized Cut Copper Stairs",
		.Entire,
	}
	mc_items["cut_copper_slab"] = Minecraft_Item{
		"cut_copper_slab",
		"Cut Copper Slab",
		.Entire,
	}
	mc_items["exposed_cut_copper_slab"] = Minecraft_Item{
		"exposed_cut_copper_slab",
		"Exposed Cut Copper Slab",
		.Entire,
	}
	mc_items["weathered_cut_copper_slab"] = Minecraft_Item{
		"weathered_cut_copper_slab",
		"Weathered Cut Copper Slab",
		.Entire,
	}
	mc_items["oxidized_cut_copper_slab"] = Minecraft_Item{
		"oxidized_cut_copper_slab",
		"Oxidized Cut Copper Slab",
		.Entire,
	}
	mc_items["waxed_copper_block"] = Minecraft_Item{
		"waxed_copper_block",
		"Waxed Block of Copper",
		.Entire,
	}
	mc_items["waxed_exposed_copper"] = Minecraft_Item{
		"waxed_exposed_copper",
		"Waxed Exposed Copper",
		.Entire,
	}
	mc_items["waxed_weathered_copper"] = Minecraft_Item{
		"waxed_weathered_copper",
		"Waxed Weathered Copper",
		.Entire,
	}
	mc_items["waxed_oxidized_copper"] = Minecraft_Item{
		"waxed_oxidized_copper",
		"Waxed Oxidized Copper",
		.Entire,
	}
	mc_items["waxed_chiseled_copper"] = Minecraft_Item{
		"waxed_chiseled_copper",
		"Waxed Chiseled Copper",
		.Entire,
	}
	mc_items["waxed_exposed_chiseled_copper"] = Minecraft_Item{
		"waxed_exposed_chiseled_copper",
		"Waxed Exposed Chiseled Copper",
		.Entire,
	}
	mc_items["waxed_weathered_chiseled_copper"] = Minecraft_Item{
		"waxed_weathered_chiseled_copper",
		"Waxed Weathered Chiseled Copper",
		.Entire,
	}
	mc_items["waxed_oxidized_chiseled_copper"] = Minecraft_Item{
		"waxed_oxidized_chiseled_copper",
		"Waxed Oxidized Chiseled Copper",
		.Entire,
	}
	mc_items["waxed_cut_copper"] = Minecraft_Item{
		"waxed_cut_copper",
		"Waxed Cut Copper",
		.Entire,
	}
	mc_items["waxed_exposed_cut_copper"] = Minecraft_Item{
		"waxed_exposed_cut_copper",
		"Waxed Exposed Cut Copper",
		.Entire,
	}
	mc_items["waxed_weathered_cut_copper"] = Minecraft_Item{
		"waxed_weathered_cut_copper",
		"Waxed Weathered Cut Copper",
		.Entire,
	}
	mc_items["waxed_oxidized_cut_copper"] = Minecraft_Item{
		"waxed_oxidized_cut_copper",
		"Waxed Oxidized Cut Copper",
		.Entire,
	}
	mc_items["waxed_cut_copper_stairs"] = Minecraft_Item{
		"waxed_cut_copper_stairs",
		"Waxed Cut Copper Stairs",
		.Entire,
	}
	mc_items["waxed_exposed_cut_copper_stairs"] = Minecraft_Item{
		"waxed_exposed_cut_copper_stairs",
		"Waxed Exposed Cut Copper Stairs",
		.Entire,
	}
	mc_items["waxed_weathered_cut_copper_stairs"] = Minecraft_Item{
		"waxed_weathered_cut_copper_stairs",
		"Waxed Weathered Cut Copper Stairs",
		.Entire,
	}
	mc_items["waxed_oxidized_cut_copper_stairs"] = Minecraft_Item{
		"waxed_oxidized_cut_copper_stairs",
		"Waxed Oxidized Cut Copper Stairs",
		.Entire,
	}
	mc_items["waxed_cut_copper_slab"] = Minecraft_Item{
		"waxed_cut_copper_slab",
		"Waxed Cut Copper Slab",
		.Entire,
	}
	mc_items["waxed_exposed_cut_copper_slab"] = Minecraft_Item{
		"waxed_exposed_cut_copper_slab",
		"Waxed Exposed Cut Copper Slab",
		.Entire,
	}
	mc_items["waxed_weathered_cut_copper_slab"] = Minecraft_Item{
		"waxed_weathered_cut_copper_slab",
		"Waxed Weathered Cut Copper Slab",
		.Entire,
	}
	mc_items["waxed_oxidized_cut_copper_slab"] = Minecraft_Item{
		"waxed_oxidized_cut_copper_slab",
		"Waxed Oxidized Cut Copper Slab",
		.Entire,
	}
	mc_items["oak_log"] = Minecraft_Item{
		"oak_log",
		"Oak Log",
		.Entire,
	}
	mc_items["spruce_log"] = Minecraft_Item{
		"spruce_log",
		"Spruce Log",
		.Entire,
	}
	mc_items["birch_log"] = Minecraft_Item{
		"birch_log",
		"Birch Log",
		.Entire,
	}
	mc_items["jungle_log"] = Minecraft_Item{
		"jungle_log",
		"Jungle Log",
		.Entire,
	}
	mc_items["acacia_log"] = Minecraft_Item{
		"acacia_log",
		"Acacia Log",
		.Entire,
	}
	mc_items["cherry_log"] = Minecraft_Item{
		"cherry_log",
		"Cherry Log",
		.Entire,
	}
	mc_items["pale_oak_log"] = Minecraft_Item{
		"pale_oak_log",
		"Pale Oak Log",
		.Entire,
	}
	mc_items["dark_oak_log"] = Minecraft_Item{
		"dark_oak_log",
		"Dark Oak Log",
		.Entire,
	}
	mc_items["mangrove_log"] = Minecraft_Item{
		"mangrove_log",
		"Mangrove Log",
		.Entire,
	}
	mc_items["mangrove_roots"] = Minecraft_Item{
		"mangrove_roots",
		"Mangrove Roots",
		.Entire,
	}
	mc_items["muddy_mangrove_roots"] = Minecraft_Item{
		"muddy_mangrove_roots",
		"Muddy Mangrove Roots",
		.Entire,
	}
	mc_items["crimson_stem"] = Minecraft_Item{
		"crimson_stem",
		"Crimson Stem",
		.Entire,
	}
	mc_items["warped_stem"] = Minecraft_Item{
		"warped_stem",
		"Warped Stem",
		.Entire,
	}
	mc_items["bamboo_block"] = Minecraft_Item{
		"bamboo_block",
		"Block of Bamboo",
		.Entire,
	}
	mc_items["stripped_oak_log"] = Minecraft_Item{
		"stripped_oak_log",
		"Stripped Oak Log",
		.Entire,
	}
	mc_items["stripped_spruce_log"] = Minecraft_Item{
		"stripped_spruce_log",
		"Stripped Spruce Log",
		.Entire,
	}
	mc_items["stripped_birch_log"] = Minecraft_Item{
		"stripped_birch_log",
		"Stripped Birch Log",
		.Entire,
	}
	mc_items["stripped_jungle_log"] = Minecraft_Item{
		"stripped_jungle_log",
		"Stripped Jungle Log",
		.Entire,
	}
	mc_items["stripped_acacia_log"] = Minecraft_Item{
		"stripped_acacia_log",
		"Stripped Acacia Log",
		.Entire,
	}
	mc_items["stripped_cherry_log"] = Minecraft_Item{
		"stripped_cherry_log",
		"Stripped Cherry Log",
		.Entire,
	}
	mc_items["stripped_dark_oak_log"] = Minecraft_Item{
		"stripped_dark_oak_log",
		"Stripped Dark Oak Log",
		.Entire,
	}
	mc_items["stripped_pale_oak_log"] = Minecraft_Item{
		"stripped_pale_oak_log",
		"Stripped Pale Oak Log",
		.Entire,
	}
	mc_items["stripped_mangrove_log"] = Minecraft_Item{
		"stripped_mangrove_log",
		"Stripped Mangrove Log",
		.Entire,
	}
	mc_items["stripped_crimson_stem"] = Minecraft_Item{
		"stripped_crimson_stem",
		"Stripped Crimson Stem",
		.Entire,
	}
	mc_items["stripped_warped_stem"] = Minecraft_Item{
		"stripped_warped_stem",
		"Stripped Warped Stem",
		.Entire,
	}
	mc_items["stripped_oak_wood"] = Minecraft_Item{
		"stripped_oak_wood",
		"Stripped Oak Wood",
		.Entire,
	}
	mc_items["stripped_spruce_wood"] = Minecraft_Item{
		"stripped_spruce_wood",
		"Stripped Spruce Wood",
		.Entire,
	}
	mc_items["stripped_birch_wood"] = Minecraft_Item{
		"stripped_birch_wood",
		"Stripped Birch Wood",
		.Entire,
	}
	mc_items["stripped_jungle_wood"] = Minecraft_Item{
		"stripped_jungle_wood",
		"Stripped Jungle Wood",
		.Entire,
	}
	mc_items["stripped_acacia_wood"] = Minecraft_Item{
		"stripped_acacia_wood",
		"Stripped Acacia Wood",
		.Entire,
	}
	mc_items["stripped_cherry_wood"] = Minecraft_Item{
		"stripped_cherry_wood",
		"Stripped Cherry Wood",
		.Entire,
	}
	mc_items["stripped_dark_oak_wood"] = Minecraft_Item{
		"stripped_dark_oak_wood",
		"Stripped Dark Oak Wood",
		.Entire,
	}
	mc_items["stripped_pale_oak_wood"] = Minecraft_Item{
		"stripped_pale_oak_wood",
		"Stripped Pale Oak Wood",
		.Entire,
	}
	mc_items["stripped_mangrove_wood"] = Minecraft_Item{
		"stripped_mangrove_wood",
		"Stripped Mangrove Wood",
		.Entire,
	}
	mc_items["stripped_crimson_hyphae"] = Minecraft_Item{
		"stripped_crimson_hyphae",
		"Stripped Crimson Hyphae",
		.Entire,
	}
	mc_items["stripped_warped_hyphae"] = Minecraft_Item{
		"stripped_warped_hyphae",
		"Stripped Warped Hyphae",
		.Entire,
	}
	mc_items["stripped_bamboo_block"] = Minecraft_Item{
		"stripped_bamboo_block",
		"Block of Stripped Bamboo",
		.Entire,
	}
	mc_items["oak_wood"] = Minecraft_Item{
		"oak_wood",
		"Oak Wood",
		.Entire,
	}
	mc_items["spruce_wood"] = Minecraft_Item{
		"spruce_wood",
		"Spruce Wood",
		.Entire,
	}
	mc_items["birch_wood"] = Minecraft_Item{
		"birch_wood",
		"Birch Wood",
		.Entire,
	}
	mc_items["jungle_wood"] = Minecraft_Item{
		"jungle_wood",
		"Jungle Wood",
		.Entire,
	}
	mc_items["acacia_wood"] = Minecraft_Item{
		"acacia_wood",
		"Acacia Wood",
		.Entire,
	}
	mc_items["cherry_wood"] = Minecraft_Item{
		"cherry_wood",
		"Cherry Wood",
		.Entire,
	}
	mc_items["pale_oak_wood"] = Minecraft_Item{
		"pale_oak_wood",
		"Pale Oak Wood",
		.Entire,
	}
	mc_items["dark_oak_wood"] = Minecraft_Item{
		"dark_oak_wood",
		"Dark Oak Wood",
		.Entire,
	}
	mc_items["mangrove_wood"] = Minecraft_Item{
		"mangrove_wood",
		"Mangrove Wood",
		.Entire,
	}
	mc_items["crimson_hyphae"] = Minecraft_Item{
		"crimson_hyphae",
		"Crimson Hyphae",
		.Entire,
	}
	mc_items["warped_hyphae"] = Minecraft_Item{
		"warped_hyphae",
		"Warped Hyphae",
		.Entire,
	}
	mc_items["oak_leaves"] = Minecraft_Item{
		"oak_leaves",
		"Oak Leaves",
		.Entire,
	}
	mc_items["spruce_leaves"] = Minecraft_Item{
		"spruce_leaves",
		"Spruce Leaves",
		.Entire,
	}
	mc_items["birch_leaves"] = Minecraft_Item{
		"birch_leaves",
		"Birch Leaves",
		.Entire,
	}
	mc_items["jungle_leaves"] = Minecraft_Item{
		"jungle_leaves",
		"Jungle Leaves",
		.Entire,
	}
	mc_items["acacia_leaves"] = Minecraft_Item{
		"acacia_leaves",
		"Acacia Leaves",
		.Entire,
	}
	mc_items["cherry_leaves"] = Minecraft_Item{
		"cherry_leaves",
		"Cherry Leaves",
		.Entire,
	}
	mc_items["dark_oak_leaves"] = Minecraft_Item{
		"dark_oak_leaves",
		"Dark Oak Leaves",
		.Entire,
	}
	mc_items["pale_oak_leaves"] = Minecraft_Item{
		"pale_oak_leaves",
		"Pale Oak Leaves",
		.Entire,
	}
	mc_items["mangrove_leaves"] = Minecraft_Item{
		"mangrove_leaves",
		"Mangrove Leaves",
		.Entire,
	}
	mc_items["azalea_leaves"] = Minecraft_Item{
		"azalea_leaves",
		"Azalea Leaves",
		.Entire,
	}
	mc_items["flowering_azalea_leaves"] = Minecraft_Item{
		"flowering_azalea_leaves",
		"Flowering Azalea Leaves",
		.Entire,
	}
	mc_items["sponge"] = Minecraft_Item{
		"sponge",
		"Sponge",
		.Entire,
	}
	mc_items["wet_sponge"] = Minecraft_Item{
		"wet_sponge",
		"Wet Sponge",
		.Entire,
	}
	mc_items["glass"] = Minecraft_Item{
		"glass",
		"Glass",
		.Entire,
	}
	mc_items["tinted_glass"] = Minecraft_Item{
		"tinted_glass",
		"Tinted Glass",
		.Entire,
	}
	mc_items["lapis_block"] = Minecraft_Item{
		"lapis_block",
		"Block of Lapis Lazuli",
		.Entire,
	}
	mc_items["sandstone"] = Minecraft_Item{
		"sandstone",
		"Sandstone",
		.Entire,
	}
	mc_items["chiseled_sandstone"] = Minecraft_Item{
		"chiseled_sandstone",
		"Chiseled Sandstone",
		.Entire,
	}
	mc_items["cut_sandstone"] = Minecraft_Item{
		"cut_sandstone",
		"Cut Sandstone",
		.Entire,
	}
	mc_items["cobweb"] = Minecraft_Item{
		"cobweb",
		"Cobweb",
		.Entire,
	}
	mc_items["short_grass"] = Minecraft_Item{
		"short_grass",
		"Short Grass",
		.Entire,
	}
	mc_items["fern"] = Minecraft_Item{
		"fern",
		"Fern",
		.Entire,
	}
	mc_items["bush"] = Minecraft_Item{
		"bush",
		"Bush",
		.Entire,
	}
	mc_items["azalea"] = Minecraft_Item{
		"azalea",
		"Azalea",
		.Entire,
	}
	mc_items["flowering_azalea"] = Minecraft_Item{
		"flowering_azalea",
		"Flowering Azalea",
		.Entire,
	}
	mc_items["dead_bush"] = Minecraft_Item{
		"dead_bush",
		"Dead Bush",
		.Entire,
	}
	mc_items["firefly_bush"] = Minecraft_Item{
		"firefly_bush",
		"Firefly Bush",
		.Entire,
	}
	mc_items["short_dry_grass"] = Minecraft_Item{
		"short_dry_grass",
		"Short Dry Grass",
		.Entire,
	}
	mc_items["tall_dry_grass"] = Minecraft_Item{
		"tall_dry_grass",
		"Tall Dry Grass",
		.Entire,
	}
	mc_items["seagrass"] = Minecraft_Item{
		"seagrass",
		"Seagrass",
		.Entire,
	}
	mc_items["sea_pickle"] = Minecraft_Item{
		"sea_pickle",
		"Sea Pickle",
		.Entire,
	}
	mc_items["white_wool"] = Minecraft_Item{
		"white_wool",
		"White Wool",
		.Entire,
	}
	mc_items["orange_wool"] = Minecraft_Item{
		"orange_wool",
		"Orange Wool",
		.Entire,
	}
	mc_items["magenta_wool"] = Minecraft_Item{
		"magenta_wool",
		"Magenta Wool",
		.Entire,
	}
	mc_items["light_blue_wool"] = Minecraft_Item{
		"light_blue_wool",
		"Light Blue Wool",
		.Entire,
	}
	mc_items["yellow_wool"] = Minecraft_Item{
		"yellow_wool",
		"Yellow Wool",
		.Entire,
	}
	mc_items["lime_wool"] = Minecraft_Item{
		"lime_wool",
		"Lime Wool",
		.Entire,
	}
	mc_items["pink_wool"] = Minecraft_Item{
		"pink_wool",
		"Pink Wool",
		.Entire,
	}
	mc_items["gray_wool"] = Minecraft_Item{
		"gray_wool",
		"Gray Wool",
		.Entire,
	}
	mc_items["light_gray_wool"] = Minecraft_Item{
		"light_gray_wool",
		"Light Gray Wool",
		.Entire,
	}
	mc_items["cyan_wool"] = Minecraft_Item{
		"cyan_wool",
		"Cyan Wool",
		.Entire,
	}
	mc_items["purple_wool"] = Minecraft_Item{
		"purple_wool",
		"Purple Wool",
		.Entire,
	}
	mc_items["blue_wool"] = Minecraft_Item{
		"blue_wool",
		"Blue Wool",
		.Entire,
	}
	mc_items["brown_wool"] = Minecraft_Item{
		"brown_wool",
		"Brown Wool",
		.Entire,
	}
	mc_items["green_wool"] = Minecraft_Item{
		"green_wool",
		"Green Wool",
		.Entire,
	}
	mc_items["red_wool"] = Minecraft_Item{
		"red_wool",
		"Red Wool",
		.Entire,
	}
	mc_items["black_wool"] = Minecraft_Item{
		"black_wool",
		"Black Wool",
		.Entire,
	}
	mc_items["dandelion"] = Minecraft_Item{
		"dandelion",
		"Dandelion",
		.Entire,
	}
	mc_items["open_eyeblossom"] = Minecraft_Item{
		"open_eyeblossom",
		"Open Eyeblossom",
		.Entire,
	}
	mc_items["closed_eyeblossom"] = Minecraft_Item{
		"closed_eyeblossom",
		"Closed Eyeblossom",
		.Entire,
	}
	mc_items["poppy"] = Minecraft_Item{
		"poppy",
		"Poppy",
		.Entire,
	}
	mc_items["blue_orchid"] = Minecraft_Item{
		"blue_orchid",
		"Blue Orchid",
		.Entire,
	}
	mc_items["allium"] = Minecraft_Item{
		"allium",
		"Allium",
		.Entire,
	}
	mc_items["azure_bluet"] = Minecraft_Item{
		"azure_bluet",
		"Azure Bluet",
		.Entire,
	}
	mc_items["red_tulip"] = Minecraft_Item{
		"red_tulip",
		"Red Tulip",
		.Entire,
	}
	mc_items["orange_tulip"] = Minecraft_Item{
		"orange_tulip",
		"Orange Tulip",
		.Entire,
	}
	mc_items["white_tulip"] = Minecraft_Item{
		"white_tulip",
		"White Tulip",
		.Entire,
	}
	mc_items["pink_tulip"] = Minecraft_Item{
		"pink_tulip",
		"Pink Tulip",
		.Entire,
	}
	mc_items["oxeye_daisy"] = Minecraft_Item{
		"oxeye_daisy",
		"Oxeye Daisy",
		.Entire,
	}
	mc_items["cornflower"] = Minecraft_Item{
		"cornflower",
		"Cornflower",
		.Entire,
	}
	mc_items["lily_of_the_valley"] = Minecraft_Item{
		"lily_of_the_valley",
		"Lily of the Valley",
		.Entire,
	}
	mc_items["wither_rose"] = Minecraft_Item{
		"wither_rose",
		"Wither Rose",
		.Entire,
	}
	mc_items["torchflower"] = Minecraft_Item{
		"torchflower",
		"Torchflower",
		.Entire,
	}
	mc_items["pitcher_plant"] = Minecraft_Item{
		"pitcher_plant",
		"Pitcher Plant",
		.Entire,
	}
	mc_items["spore_blossom"] = Minecraft_Item{
		"spore_blossom",
		"Spore Blossom",
		.Entire,
	}
	mc_items["brown_mushroom"] = Minecraft_Item{
		"brown_mushroom",
		"Brown Mushroom",
		.Entire,
	}
	mc_items["red_mushroom"] = Minecraft_Item{
		"red_mushroom",
		"Red Mushroom",
		.Entire,
	}
	mc_items["crimson_fungus"] = Minecraft_Item{
		"crimson_fungus",
		"Crimson Fungus",
		.Entire,
	}
	mc_items["warped_fungus"] = Minecraft_Item{
		"warped_fungus",
		"Warped Fungus",
		.Entire,
	}
	mc_items["crimson_roots"] = Minecraft_Item{
		"crimson_roots",
		"Crimson Roots",
		.Entire,
	}
	mc_items["warped_roots"] = Minecraft_Item{
		"warped_roots",
		"Warped Roots",
		.Entire,
	}
	mc_items["nether_sprouts"] = Minecraft_Item{
		"nether_sprouts",
		"Nether Sprouts",
		.Entire,
	}
	mc_items["weeping_vines"] = Minecraft_Item{
		"weeping_vines",
		"Weeping Vines",
		.Entire,
	}
	mc_items["twisting_vines"] = Minecraft_Item{
		"twisting_vines",
		"Twisting Vines",
		.Entire,
	}
	mc_items["sugar_cane"] = Minecraft_Item{
		"sugar_cane",
		"Sugar Cane",
		.Entire,
	}
	mc_items["kelp"] = Minecraft_Item{
		"kelp",
		"Kelp",
		.Entire,
	}
	mc_items["pink_petals"] = Minecraft_Item{
		"pink_petals",
		"Pink Petals",
		.Entire,
	}
	mc_items["wildflowers"] = Minecraft_Item{
		"wildflowers",
		"Wildflowers",
		.Entire,
	}
	mc_items["leaf_litter"] = Minecraft_Item{
		"leaf_litter",
		"Leaf Litter",
		.Entire,
	}
	mc_items["moss_carpet"] = Minecraft_Item{
		"moss_carpet",
		"Moss Carpet",
		.Entire,
	}
	mc_items["moss_block"] = Minecraft_Item{
		"moss_block",
		"Moss Block",
		.Entire,
	}
	mc_items["pale_moss_carpet"] = Minecraft_Item{
		"pale_moss_carpet",
		"Pale Moss Carpet",
		.Entire,
	}
	mc_items["pale_hanging_moss"] = Minecraft_Item{
		"pale_hanging_moss",
		"Pale Hanging Moss",
		.Entire,
	}
	mc_items["pale_moss_block"] = Minecraft_Item{
		"pale_moss_block",
		"Pale Moss Block",
		.Entire,
	}
	mc_items["hanging_roots"] = Minecraft_Item{
		"hanging_roots",
		"Hanging Roots",
		.Entire,
	}
	mc_items["big_dripleaf"] = Minecraft_Item{
		"big_dripleaf",
		"Big Dripleaf",
		.Entire,
	}
	mc_items["small_dripleaf"] = Minecraft_Item{
		"small_dripleaf",
		"Small Dripleaf",
		.Entire,
	}
	mc_items["bamboo"] = Minecraft_Item{
		"bamboo",
		"Bamboo",
		.Entire,
	}
	mc_items["oak_slab"] = Minecraft_Item{
		"oak_slab",
		"Oak Slab",
		.Entire,
	}
	mc_items["spruce_slab"] = Minecraft_Item{
		"spruce_slab",
		"Spruce Slab",
		.Entire,
	}
	mc_items["birch_slab"] = Minecraft_Item{
		"birch_slab",
		"Birch Slab",
		.Entire,
	}
	mc_items["jungle_slab"] = Minecraft_Item{
		"jungle_slab",
		"Jungle Slab",
		.Entire,
	}
	mc_items["acacia_slab"] = Minecraft_Item{
		"acacia_slab",
		"Acacia Slab",
		.Entire,
	}
	mc_items["cherry_slab"] = Minecraft_Item{
		"cherry_slab",
		"Cherry Slab",
		.Entire,
	}
	mc_items["dark_oak_slab"] = Minecraft_Item{
		"dark_oak_slab",
		"Dark Oak Slab",
		.Entire,
	}
	mc_items["pale_oak_slab"] = Minecraft_Item{
		"pale_oak_slab",
		"Pale Oak Slab",
		.Entire,
	}
	mc_items["mangrove_slab"] = Minecraft_Item{
		"mangrove_slab",
		"Mangrove Slab",
		.Entire,
	}
	mc_items["bamboo_slab"] = Minecraft_Item{
		"bamboo_slab",
		"Bamboo Slab",
		.Entire,
	}
	mc_items["bamboo_mosaic_slab"] = Minecraft_Item{
		"bamboo_mosaic_slab",
		"Bamboo Mosaic Slab",
		.Entire,
	}
	mc_items["crimson_slab"] = Minecraft_Item{
		"crimson_slab",
		"Crimson Slab",
		.Entire,
	}
	mc_items["warped_slab"] = Minecraft_Item{
		"warped_slab",
		"Warped Slab",
		.Entire,
	}
	mc_items["stone_slab"] = Minecraft_Item{
		"stone_slab",
		"Stone Slab",
		.Entire,
	}
	mc_items["smooth_stone_slab"] = Minecraft_Item{
		"smooth_stone_slab",
		"Smooth Stone Slab",
		.Entire,
	}
	mc_items["sandstone_slab"] = Minecraft_Item{
		"sandstone_slab",
		"Sandstone Slab",
		.Entire,
	}
	mc_items["cut_sandstone_slab"] = Minecraft_Item{
		"cut_sandstone_slab",
		"Cut Sandstone Slab",
		.Entire,
	}
	mc_items["petrified_oak_slab"] = Minecraft_Item{
		"petrified_oak_slab",
		"Petrified Oak Slab",
		.Entire,
	}
	mc_items["cobblestone_slab"] = Minecraft_Item{
		"cobblestone_slab",
		"Cobblestone Slab",
		.Entire,
	}
	mc_items["brick_slab"] = Minecraft_Item{
		"brick_slab",
		"Brick Slab",
		.Entire,
	}
	mc_items["stone_brick_slab"] = Minecraft_Item{
		"stone_brick_slab",
		"Stone Brick Slab",
		.Entire,
	}
	mc_items["mud_brick_slab"] = Minecraft_Item{
		"mud_brick_slab",
		"Mud Brick Slab",
		.Entire,
	}
	mc_items["nether_brick_slab"] = Minecraft_Item{
		"nether_brick_slab",
		"Nether Brick Slab",
		.Entire,
	}
	mc_items["quartz_slab"] = Minecraft_Item{
		"quartz_slab",
		"Quartz Slab",
		.Entire,
	}
	mc_items["red_sandstone_slab"] = Minecraft_Item{
		"red_sandstone_slab",
		"Red Sandstone Slab",
		.Entire,
	}
	mc_items["cut_red_sandstone_slab"] = Minecraft_Item{
		"cut_red_sandstone_slab",
		"Cut Red Sandstone Slab",
		.Entire,
	}
	mc_items["purpur_slab"] = Minecraft_Item{
		"purpur_slab",
		"Purpur Slab",
		.Entire,
	}
	mc_items["prismarine_slab"] = Minecraft_Item{
		"prismarine_slab",
		"Prismarine Slab",
		.Entire,
	}
	mc_items["prismarine_brick_slab"] = Minecraft_Item{
		"prismarine_brick_slab",
		"Prismarine Brick Slab",
		.Entire,
	}
	mc_items["dark_prismarine_slab"] = Minecraft_Item{
		"dark_prismarine_slab",
		"Dark Prismarine Slab",
		.Entire,
	}
	mc_items["smooth_quartz"] = Minecraft_Item{
		"smooth_quartz",
		"Smooth Quartz Block",
		.Entire,
	}
	mc_items["smooth_red_sandstone"] = Minecraft_Item{
		"smooth_red_sandstone",
		"Smooth Red Sandstone",
		.Entire,
	}
	mc_items["smooth_sandstone"] = Minecraft_Item{
		"smooth_sandstone",
		"Smooth Sandstone",
		.Entire,
	}
	mc_items["smooth_stone"] = Minecraft_Item{
		"smooth_stone",
		"Smooth Stone",
		.Entire,
	}
	mc_items["bricks"] = Minecraft_Item{
		"bricks",
		"Bricks",
		.Entire,
	}
	mc_items["bookshelf"] = Minecraft_Item{
		"bookshelf",
		"Bookshelf",
		.Entire,
	}
	mc_items["chiseled_bookshelf"] = Minecraft_Item{
		"chiseled_bookshelf",
		"Chiseled Bookshelf",
		.Entire,
	}
	mc_items["decorated_pot"] = Minecraft_Item{
		"decorated_pot",
		"Decorated Pot",
		.Entire,
	}
	mc_items["mossy_cobblestone"] = Minecraft_Item{
		"mossy_cobblestone",
		"Mossy Cobblestone",
		.Entire,
	}
	mc_items["obsidian"] = Minecraft_Item{
		"obsidian",
		"Obsidian",
		.Entire,
	}
	mc_items["torch"] = Minecraft_Item{
		"torch",
		"Torch",
		.Entire,
	}
	mc_items["end_rod"] = Minecraft_Item{
		"end_rod",
		"End Rod",
		.Entire,
	}
	mc_items["chorus_plant"] = Minecraft_Item{
		"chorus_plant",
		"Chorus Plant",
		.Entire,
	}
	mc_items["chorus_flower"] = Minecraft_Item{
		"chorus_flower",
		"Chorus Flower",
		.Entire,
	}
	mc_items["purpur_block"] = Minecraft_Item{
		"purpur_block",
		"Purpur Block",
		.Entire,
	}
	mc_items["purpur_pillar"] = Minecraft_Item{
		"purpur_pillar",
		"Purpur Pillar",
		.Entire,
	}
	mc_items["purpur_stairs"] = Minecraft_Item{
		"purpur_stairs",
		"Purpur Stairs",
		.Entire,
	}
	mc_items["spawner"] = Minecraft_Item{
		"spawner",
		"Monster Spawner",
		.Entire,
	}
	mc_items["creaking_heart"] = Minecraft_Item{
		"creaking_heart",
		"Creaking Heart",
		.Entire,
	}
	mc_items["chest"] = Minecraft_Item{
		"chest",
		"Chest",
		.Entire,
	}
	mc_items["crafting_table"] = Minecraft_Item{
		"crafting_table",
		"Crafting Table",
		.Entire,
	}
	mc_items["farmland"] = Minecraft_Item{
		"farmland",
		"Farmland",
		.Entire,
	}
	mc_items["furnace"] = Minecraft_Item{
		"furnace",
		"Furnace",
		.Entire,
	}
	mc_items["ladder"] = Minecraft_Item{
		"ladder",
		"Ladder",
		.Entire,
	}
	mc_items["cobblestone_stairs"] = Minecraft_Item{
		"cobblestone_stairs",
		"Cobblestone Stairs",
		.Entire,
	}
	mc_items["snow"] = Minecraft_Item{
		"snow",
		"Snow",
		.Entire,
	}
	mc_items["ice"] = Minecraft_Item{
		"ice",
		"Ice",
		.Entire,
	}
	mc_items["snow_block"] = Minecraft_Item{
		"snow_block",
		"Snow Block",
		.Entire,
	}
	mc_items["cactus"] = Minecraft_Item{
		"cactus",
		"Cactus",
		.Entire,
	}
	mc_items["cactus_flower"] = Minecraft_Item{
		"cactus_flower",
		"Cactus Flower",
		.Entire,
	}
	mc_items["clay"] = Minecraft_Item{
		"clay",
		"Clay",
		.Entire,
	}
	mc_items["jukebox"] = Minecraft_Item{
		"jukebox",
		"Jukebox",
		.Entire,
	}
	mc_items["oak_fence"] = Minecraft_Item{
		"oak_fence",
		"Oak Fence",
		.Entire,
	}
	mc_items["spruce_fence"] = Minecraft_Item{
		"spruce_fence",
		"Spruce Fence",
		.Entire,
	}
	mc_items["birch_fence"] = Minecraft_Item{
		"birch_fence",
		"Birch Fence",
		.Entire,
	}
	mc_items["jungle_fence"] = Minecraft_Item{
		"jungle_fence",
		"Jungle Fence",
		.Entire,
	}
	mc_items["acacia_fence"] = Minecraft_Item{
		"acacia_fence",
		"Acacia Fence",
		.Entire,
	}
	mc_items["cherry_fence"] = Minecraft_Item{
		"cherry_fence",
		"Cherry Fence",
		.Entire,
	}
	mc_items["dark_oak_fence"] = Minecraft_Item{
		"dark_oak_fence",
		"Dark Oak Fence",
		.Entire,
	}
	mc_items["pale_oak_fence"] = Minecraft_Item{
		"pale_oak_fence",
		"Pale Oak Fence",
		.Entire,
	}
	mc_items["mangrove_fence"] = Minecraft_Item{
		"mangrove_fence",
		"Mangrove Fence",
		.Entire,
	}
	mc_items["bamboo_fence"] = Minecraft_Item{
		"bamboo_fence",
		"Bamboo Fence",
		.Entire,
	}
	mc_items["crimson_fence"] = Minecraft_Item{
		"crimson_fence",
		"Crimson Fence",
		.Entire,
	}
	mc_items["warped_fence"] = Minecraft_Item{
		"warped_fence",
		"Warped Fence",
		.Entire,
	}
	mc_items["pumpkin"] = Minecraft_Item{
		"pumpkin",
		"Pumpkin",
		.Entire,
	}
	mc_items["carved_pumpkin"] = Minecraft_Item{
		"carved_pumpkin",
		"Carved Pumpkin",
		.Entire,
	}
	mc_items["jack_o_lantern"] = Minecraft_Item{
		"jack_o_lantern",
		"Jack o'Lantern",
		.Entire,
	}
	mc_items["netherrack"] = Minecraft_Item{
		"netherrack",
		"Netherrack",
		.Entire,
	}
	mc_items["soul_sand"] = Minecraft_Item{
		"soul_sand",
		"Soul Sand",
		.Entire,
	}
	mc_items["soul_soil"] = Minecraft_Item{
		"soul_soil",
		"Soul Soil",
		.Entire,
	}
	mc_items["basalt"] = Minecraft_Item{
		"basalt",
		"Basalt",
		.Entire,
	}
	mc_items["polished_basalt"] = Minecraft_Item{
		"polished_basalt",
		"Polished Basalt",
		.Entire,
	}
	mc_items["smooth_basalt"] = Minecraft_Item{
		"smooth_basalt",
		"Smooth Basalt",
		.Entire,
	}
	mc_items["soul_torch"] = Minecraft_Item{
		"soul_torch",
		"Soul Torch",
		.Entire,
	}
	mc_items["glowstone"] = Minecraft_Item{
		"glowstone",
		"Glowstone",
		.Entire,
	}
	mc_items["infested_stone"] = Minecraft_Item{
		"infested_stone",
		"Infested Stone",
		.Entire,
	}
	mc_items["infested_cobblestone"] = Minecraft_Item{
		"infested_cobblestone",
		"Infested Cobblestone",
		.Entire,
	}
	mc_items["infested_stone_bricks"] = Minecraft_Item{
		"infested_stone_bricks",
		"Infested Stone Bricks",
		.Entire,
	}
	mc_items["infested_mossy_stone_bricks"] = Minecraft_Item{
		"infested_mossy_stone_bricks",
		"Infested Mossy Stone Bricks",
		.Entire,
	}
	mc_items["infested_cracked_stone_bricks"] = Minecraft_Item{
		"infested_cracked_stone_bricks",
		"Infested Cracked Stone Bricks",
		.Entire,
	}
	mc_items["infested_chiseled_stone_bricks"] = Minecraft_Item{
		"infested_chiseled_stone_bricks",
		"Infested Chiseled Stone Bricks",
		.Entire,
	}
	mc_items["infested_deepslate"] = Minecraft_Item{
		"infested_deepslate",
		"Infested Deepslate",
		.Entire,
	}
	mc_items["stone_bricks"] = Minecraft_Item{
		"stone_bricks",
		"Stone Bricks",
		.Entire,
	}
	mc_items["mossy_stone_bricks"] = Minecraft_Item{
		"mossy_stone_bricks",
		"Mossy Stone Bricks",
		.Entire,
	}
	mc_items["cracked_stone_bricks"] = Minecraft_Item{
		"cracked_stone_bricks",
		"Cracked Stone Bricks",
		.Entire,
	}
	mc_items["chiseled_stone_bricks"] = Minecraft_Item{
		"chiseled_stone_bricks",
		"Chiseled Stone Bricks",
		.Entire,
	}
	mc_items["packed_mud"] = Minecraft_Item{
		"packed_mud",
		"Packed Mud",
		.Entire,
	}
	mc_items["mud_bricks"] = Minecraft_Item{
		"mud_bricks",
		"Mud Bricks",
		.Entire,
	}
	mc_items["deepslate_bricks"] = Minecraft_Item{
		"deepslate_bricks",
		"Deepslate Bricks",
		.Entire,
	}
	mc_items["cracked_deepslate_bricks"] = Minecraft_Item{
		"cracked_deepslate_bricks",
		"Cracked Deepslate Bricks",
		.Entire,
	}
	mc_items["deepslate_tiles"] = Minecraft_Item{
		"deepslate_tiles",
		"Deepslate Tiles",
		.Entire,
	}
	mc_items["cracked_deepslate_tiles"] = Minecraft_Item{
		"cracked_deepslate_tiles",
		"Cracked Deepslate Tiles",
		.Entire,
	}
	mc_items["chiseled_deepslate"] = Minecraft_Item{
		"chiseled_deepslate",
		"Chiseled Deepslate",
		.Entire,
	}
	mc_items["reinforced_deepslate"] = Minecraft_Item{
		"reinforced_deepslate",
		"Reinforced Deepslate",
		.Entire,
	}
	mc_items["brown_mushroom_block"] = Minecraft_Item{
		"brown_mushroom_block",
		"Brown Mushroom Block",
		.Entire,
	}
	mc_items["red_mushroom_block"] = Minecraft_Item{
		"red_mushroom_block",
		"Red Mushroom Block",
		.Entire,
	}
	mc_items["mushroom_stem"] = Minecraft_Item{
		"mushroom_stem",
		"Mushroom Stem",
		.Entire,
	}
	mc_items["iron_bars"] = Minecraft_Item{
		"iron_bars",
		"Iron Bars",
		.Entire,
	}
	mc_items["chain"] = Minecraft_Item{
		"chain",
		"Chain",
		.Entire,
	}
	mc_items["glass_pane"] = Minecraft_Item{
		"glass_pane",
		"Glass Pane",
		.Entire,
	}
	mc_items["melon"] = Minecraft_Item{
		"melon",
		"Melon",
		.Entire,
	}
	mc_items["vine"] = Minecraft_Item{
		"vine",
		"Vines",
		.Entire,
	}
	mc_items["glow_lichen"] = Minecraft_Item{
		"glow_lichen",
		"Glow Lichen",
		.Entire,
	}
	mc_items["resin_clump"] = Minecraft_Item{
		"resin_clump",
		"Resin Clump",
		.Entire,
	}
	mc_items["resin_block"] = Minecraft_Item{
		"resin_block",
		"Block of Resin",
		.Entire,
	}
	mc_items["resin_bricks"] = Minecraft_Item{
		"resin_bricks",
		"Resin Bricks",
		.Entire,
	}
	mc_items["resin_brick_stairs"] = Minecraft_Item{
		"resin_brick_stairs",
		"Resin Brick Stairs",
		.Entire,
	}
	mc_items["resin_brick_slab"] = Minecraft_Item{
		"resin_brick_slab",
		"Resin Brick Slab",
		.Entire,
	}
	mc_items["resin_brick_wall"] = Minecraft_Item{
		"resin_brick_wall",
		"Resin Brick Wall",
		.Entire,
	}
	mc_items["chiseled_resin_bricks"] = Minecraft_Item{
		"chiseled_resin_bricks",
		"Chiseled Resin Bricks",
		.Entire,
	}
	mc_items["brick_stairs"] = Minecraft_Item{
		"brick_stairs",
		"Brick Stairs",
		.Entire,
	}
	mc_items["stone_brick_stairs"] = Minecraft_Item{
		"stone_brick_stairs",
		"Stone Brick Stairs",
		.Entire,
	}
	mc_items["mud_brick_stairs"] = Minecraft_Item{
		"mud_brick_stairs",
		"Mud Brick Stairs",
		.Entire,
	}
	mc_items["mycelium"] = Minecraft_Item{
		"mycelium",
		"Mycelium",
		.Entire,
	}
	mc_items["lily_pad"] = Minecraft_Item{
		"lily_pad",
		"Lily Pad",
		.Entire,
	}
	mc_items["nether_bricks"] = Minecraft_Item{
		"nether_bricks",
		"Nether Bricks",
		.Entire,
	}
	mc_items["cracked_nether_bricks"] = Minecraft_Item{
		"cracked_nether_bricks",
		"Cracked Nether Bricks",
		.Entire,
	}
	mc_items["chiseled_nether_bricks"] = Minecraft_Item{
		"chiseled_nether_bricks",
		"Chiseled Nether Bricks",
		.Entire,
	}
	mc_items["nether_brick_fence"] = Minecraft_Item{
		"nether_brick_fence",
		"Nether Brick Fence",
		.Entire,
	}
	mc_items["nether_brick_stairs"] = Minecraft_Item{
		"nether_brick_stairs",
		"Nether Brick Stairs",
		.Entire,
	}
	mc_items["sculk"] = Minecraft_Item{
		"sculk",
		"Sculk",
		.Entire,
	}
	mc_items["sculk_vein"] = Minecraft_Item{
		"sculk_vein",
		"Sculk Vein",
		.Entire,
	}
	mc_items["sculk_catalyst"] = Minecraft_Item{
		"sculk_catalyst",
		"Sculk Catalyst",
		.Entire,
	}
	mc_items["sculk_shrieker"] = Minecraft_Item{
		"sculk_shrieker",
		"Sculk Shrieker",
		.Entire,
	}
	mc_items["enchanting_table"] = Minecraft_Item{
		"enchanting_table",
		"Enchanting Table",
		.Entire,
	}
	mc_items["end_portal_frame"] = Minecraft_Item{
		"end_portal_frame",
		"End Portal Frame",
		.Entire,
	}
	mc_items["end_stone"] = Minecraft_Item{
		"end_stone",
		"End Stone",
		.Entire,
	}
	mc_items["end_stone_bricks"] = Minecraft_Item{
		"end_stone_bricks",
		"End Stone Bricks",
		.Entire,
	}
	mc_items["dragon_egg"] = Minecraft_Item{
		"dragon_egg",
		"Dragon Egg",
		.Entire,
	}
	mc_items["sandstone_stairs"] = Minecraft_Item{
		"sandstone_stairs",
		"Sandstone Stairs",
		.Entire,
	}
	mc_items["ender_chest"] = Minecraft_Item{
		"ender_chest",
		"Ender Chest",
		.Entire,
	}
	mc_items["emerald_block"] = Minecraft_Item{
		"emerald_block",
		"Block of Emerald",
		.Entire,
	}
	mc_items["oak_stairs"] = Minecraft_Item{
		"oak_stairs",
		"Oak Stairs",
		.Entire,
	}
	mc_items["spruce_stairs"] = Minecraft_Item{
		"spruce_stairs",
		"Spruce Stairs",
		.Entire,
	}
	mc_items["birch_stairs"] = Minecraft_Item{
		"birch_stairs",
		"Birch Stairs",
		.Entire,
	}
	mc_items["jungle_stairs"] = Minecraft_Item{
		"jungle_stairs",
		"Jungle Stairs",
		.Entire,
	}
	mc_items["acacia_stairs"] = Minecraft_Item{
		"acacia_stairs",
		"Acacia Stairs",
		.Entire,
	}
	mc_items["cherry_stairs"] = Minecraft_Item{
		"cherry_stairs",
		"Cherry Stairs",
		.Entire,
	}
	mc_items["dark_oak_stairs"] = Minecraft_Item{
		"dark_oak_stairs",
		"Dark Oak Stairs",
		.Entire,
	}
	mc_items["pale_oak_stairs"] = Minecraft_Item{
		"pale_oak_stairs",
		"Pale Oak Stairs",
		.Entire,
	}
	mc_items["mangrove_stairs"] = Minecraft_Item{
		"mangrove_stairs",
		"Mangrove Stairs",
		.Entire,
	}
	mc_items["bamboo_stairs"] = Minecraft_Item{
		"bamboo_stairs",
		"Bamboo Stairs",
		.Entire,
	}
	mc_items["bamboo_mosaic_stairs"] = Minecraft_Item{
		"bamboo_mosaic_stairs",
		"Bamboo Mosaic Stairs",
		.Entire,
	}
	mc_items["crimson_stairs"] = Minecraft_Item{
		"crimson_stairs",
		"Crimson Stairs",
		.Entire,
	}
	mc_items["warped_stairs"] = Minecraft_Item{
		"warped_stairs",
		"Warped Stairs",
		.Entire,
	}
	mc_items["command_block"] = Minecraft_Item{
		"command_block",
		"Command Block",
		.Entire,
	}
	mc_items["beacon"] = Minecraft_Item{
		"beacon",
		"Beacon",
		.Entire,
	}
	mc_items["cobblestone_wall"] = Minecraft_Item{
		"cobblestone_wall",
		"Cobblestone Wall",
		.Entire,
	}
	mc_items["mossy_cobblestone_wall"] = Minecraft_Item{
		"mossy_cobblestone_wall",
		"Mossy Cobblestone Wall",
		.Entire,
	}
	mc_items["brick_wall"] = Minecraft_Item{
		"brick_wall",
		"Brick Wall",
		.Entire,
	}
	mc_items["prismarine_wall"] = Minecraft_Item{
		"prismarine_wall",
		"Prismarine Wall",
		.Entire,
	}
	mc_items["red_sandstone_wall"] = Minecraft_Item{
		"red_sandstone_wall",
		"Red Sandstone Wall",
		.Entire,
	}
	mc_items["mossy_stone_brick_wall"] = Minecraft_Item{
		"mossy_stone_brick_wall",
		"Mossy Stone Brick Wall",
		.Entire,
	}
	mc_items["granite_wall"] = Minecraft_Item{
		"granite_wall",
		"Granite Wall",
		.Entire,
	}
	mc_items["stone_brick_wall"] = Minecraft_Item{
		"stone_brick_wall",
		"Stone Brick Wall",
		.Entire,
	}
	mc_items["mud_brick_wall"] = Minecraft_Item{
		"mud_brick_wall",
		"Mud Brick Wall",
		.Entire,
	}
	mc_items["nether_brick_wall"] = Minecraft_Item{
		"nether_brick_wall",
		"Nether Brick Wall",
		.Entire,
	}
	mc_items["andesite_wall"] = Minecraft_Item{
		"andesite_wall",
		"Andesite Wall",
		.Entire,
	}
	mc_items["red_nether_brick_wall"] = Minecraft_Item{
		"red_nether_brick_wall",
		"Red Nether Brick Wall",
		.Entire,
	}
	mc_items["sandstone_wall"] = Minecraft_Item{
		"sandstone_wall",
		"Sandstone Wall",
		.Entire,
	}
	mc_items["end_stone_brick_wall"] = Minecraft_Item{
		"end_stone_brick_wall",
		"End Stone Brick Wall",
		.Entire,
	}
	mc_items["diorite_wall"] = Minecraft_Item{
		"diorite_wall",
		"Diorite Wall",
		.Entire,
	}
	mc_items["blackstone_wall"] = Minecraft_Item{
		"blackstone_wall",
		"Blackstone Wall",
		.Entire,
	}
	mc_items["polished_blackstone_wall"] = Minecraft_Item{
		"polished_blackstone_wall",
		"Polished Blackstone Wall",
		.Entire,
	}
	mc_items["polished_blackstone_brick_wall"] = Minecraft_Item{
		"polished_blackstone_brick_wall",
		"Polished Blackstone Brick Wall",
		.Entire,
	}
	mc_items["cobbled_deepslate_wall"] = Minecraft_Item{
		"cobbled_deepslate_wall",
		"Cobbled Deepslate Wall",
		.Entire,
	}
	mc_items["polished_deepslate_wall"] = Minecraft_Item{
		"polished_deepslate_wall",
		"Polished Deepslate Wall",
		.Entire,
	}
	mc_items["deepslate_brick_wall"] = Minecraft_Item{
		"deepslate_brick_wall",
		"Deepslate Brick Wall",
		.Entire,
	}
	mc_items["deepslate_tile_wall"] = Minecraft_Item{
		"deepslate_tile_wall",
		"Deepslate Tile Wall",
		.Entire,
	}
	mc_items["anvil"] = Minecraft_Item{
		"anvil",
		"Anvil",
		.Entire,
	}
	mc_items["chipped_anvil"] = Minecraft_Item{
		"chipped_anvil",
		"Chipped Anvil",
		.Entire,
	}
	mc_items["damaged_anvil"] = Minecraft_Item{
		"damaged_anvil",
		"Damaged Anvil",
		.Entire,
	}
	mc_items["chiseled_quartz_block"] = Minecraft_Item{
		"chiseled_quartz_block",
		"Chiseled Quartz Block",
		.Entire,
	}
	mc_items["quartz_block"] = Minecraft_Item{
		"quartz_block",
		"Block of Quartz",
		.Entire,
	}
	mc_items["quartz_bricks"] = Minecraft_Item{
		"quartz_bricks",
		"Quartz Bricks",
		.Entire,
	}
	mc_items["quartz_pillar"] = Minecraft_Item{
		"quartz_pillar",
		"Quartz Pillar",
		.Entire,
	}
	mc_items["quartz_stairs"] = Minecraft_Item{
		"quartz_stairs",
		"Quartz Stairs",
		.Entire,
	}
	mc_items["white_terracotta"] = Minecraft_Item{
		"white_terracotta",
		"White Terracotta",
		.Entire,
	}
	mc_items["orange_terracotta"] = Minecraft_Item{
		"orange_terracotta",
		"Orange Terracotta",
		.Entire,
	}
	mc_items["magenta_terracotta"] = Minecraft_Item{
		"magenta_terracotta",
		"Magenta Terracotta",
		.Entire,
	}
	mc_items["light_blue_terracotta"] = Minecraft_Item{
		"light_blue_terracotta",
		"Light Blue Terracotta",
		.Entire,
	}
	mc_items["yellow_terracotta"] = Minecraft_Item{
		"yellow_terracotta",
		"Yellow Terracotta",
		.Entire,
	}
	mc_items["lime_terracotta"] = Minecraft_Item{
		"lime_terracotta",
		"Lime Terracotta",
		.Entire,
	}
	mc_items["pink_terracotta"] = Minecraft_Item{
		"pink_terracotta",
		"Pink Terracotta",
		.Entire,
	}
	mc_items["gray_terracotta"] = Minecraft_Item{
		"gray_terracotta",
		"Gray Terracotta",
		.Entire,
	}
	mc_items["light_gray_terracotta"] = Minecraft_Item{
		"light_gray_terracotta",
		"Light Gray Terracotta",
		.Entire,
	}
	mc_items["cyan_terracotta"] = Minecraft_Item{
		"cyan_terracotta",
		"Cyan Terracotta",
		.Entire,
	}
	mc_items["purple_terracotta"] = Minecraft_Item{
		"purple_terracotta",
		"Purple Terracotta",
		.Entire,
	}
	mc_items["blue_terracotta"] = Minecraft_Item{
		"blue_terracotta",
		"Blue Terracotta",
		.Entire,
	}
	mc_items["brown_terracotta"] = Minecraft_Item{
		"brown_terracotta",
		"Brown Terracotta",
		.Entire,
	}
	mc_items["green_terracotta"] = Minecraft_Item{
		"green_terracotta",
		"Green Terracotta",
		.Entire,
	}
	mc_items["red_terracotta"] = Minecraft_Item{
		"red_terracotta",
		"Red Terracotta",
		.Entire,
	}
	mc_items["black_terracotta"] = Minecraft_Item{
		"black_terracotta",
		"Black Terracotta",
		.Entire,
	}
	mc_items["barrier"] = Minecraft_Item{
		"barrier",
		"Barrier",
		.Entire,
	}
	mc_items["light"] = Minecraft_Item{
		"light",
		"Light",
		.Entire,
	}
	mc_items["hay_block"] = Minecraft_Item{
		"hay_block",
		"Hay Bale",
		.Entire,
	}
	mc_items["white_carpet"] = Minecraft_Item{
		"white_carpet",
		"White Carpet",
		.Entire,
	}
	mc_items["orange_carpet"] = Minecraft_Item{
		"orange_carpet",
		"Orange Carpet",
		.Entire,
	}
	mc_items["magenta_carpet"] = Minecraft_Item{
		"magenta_carpet",
		"Magenta Carpet",
		.Entire,
	}
	mc_items["light_blue_carpet"] = Minecraft_Item{
		"light_blue_carpet",
		"Light Blue Carpet",
		.Entire,
	}
	mc_items["yellow_carpet"] = Minecraft_Item{
		"yellow_carpet",
		"Yellow Carpet",
		.Entire,
	}
	mc_items["lime_carpet"] = Minecraft_Item{
		"lime_carpet",
		"Lime Carpet",
		.Entire,
	}
	mc_items["pink_carpet"] = Minecraft_Item{
		"pink_carpet",
		"Pink Carpet",
		.Entire,
	}
	mc_items["gray_carpet"] = Minecraft_Item{
		"gray_carpet",
		"Gray Carpet",
		.Entire,
	}
	mc_items["light_gray_carpet"] = Minecraft_Item{
		"light_gray_carpet",
		"Light Gray Carpet",
		.Entire,
	}
	mc_items["cyan_carpet"] = Minecraft_Item{
		"cyan_carpet",
		"Cyan Carpet",
		.Entire,
	}
	mc_items["purple_carpet"] = Minecraft_Item{
		"purple_carpet",
		"Purple Carpet",
		.Entire,
	}
	mc_items["blue_carpet"] = Minecraft_Item{
		"blue_carpet",
		"Blue Carpet",
		.Entire,
	}
	mc_items["brown_carpet"] = Minecraft_Item{
		"brown_carpet",
		"Brown Carpet",
		.Entire,
	}
	mc_items["green_carpet"] = Minecraft_Item{
		"green_carpet",
		"Green Carpet",
		.Entire,
	}
	mc_items["red_carpet"] = Minecraft_Item{
		"red_carpet",
		"Red Carpet",
		.Entire,
	}
	mc_items["black_carpet"] = Minecraft_Item{
		"black_carpet",
		"Black Carpet",
		.Entire,
	}
	mc_items["terracotta"] = Minecraft_Item{
		"terracotta",
		"Terracotta",
		.Entire,
	}
	mc_items["packed_ice"] = Minecraft_Item{
		"packed_ice",
		"Packed Ice",
		.Entire,
	}
	mc_items["dirt_path"] = Minecraft_Item{
		"dirt_path",
		"Dirt Path",
		.Entire,
	}
	mc_items["sunflower"] = Minecraft_Item{
		"sunflower",
		"Sunflower",
		.Entire,
	}
	mc_items["lilac"] = Minecraft_Item{
		"lilac",
		"Lilac",
		.Entire,
	}
	mc_items["rose_bush"] = Minecraft_Item{
		"rose_bush",
		"Rose Bush",
		.Entire,
	}
	mc_items["peony"] = Minecraft_Item{
		"peony",
		"Peony",
		.Entire,
	}
	mc_items["tall_grass"] = Minecraft_Item{
		"tall_grass",
		"Tall Grass",
		.Entire,
	}
	mc_items["large_fern"] = Minecraft_Item{
		"large_fern",
		"Large Fern",
		.Entire,
	}
	mc_items["white_stained_glass"] = Minecraft_Item{
		"white_stained_glass",
		"White Stained Glass",
		.Entire,
	}
	mc_items["orange_stained_glass"] = Minecraft_Item{
		"orange_stained_glass",
		"Orange Stained Glass",
		.Entire,
	}
	mc_items["magenta_stained_glass"] = Minecraft_Item{
		"magenta_stained_glass",
		"Magenta Stained Glass",
		.Entire,
	}
	mc_items["light_blue_stained_glass"] = Minecraft_Item{
		"light_blue_stained_glass",
		"Light Blue Stained Glass",
		.Entire,
	}
	mc_items["yellow_stained_glass"] = Minecraft_Item{
		"yellow_stained_glass",
		"Yellow Stained Glass",
		.Entire,
	}
	mc_items["lime_stained_glass"] = Minecraft_Item{
		"lime_stained_glass",
		"Lime Stained Glass",
		.Entire,
	}
	mc_items["pink_stained_glass"] = Minecraft_Item{
		"pink_stained_glass",
		"Pink Stained Glass",
		.Entire,
	}
	mc_items["gray_stained_glass"] = Minecraft_Item{
		"gray_stained_glass",
		"Gray Stained Glass",
		.Entire,
	}
	mc_items["light_gray_stained_glass"] = Minecraft_Item{
		"light_gray_stained_glass",
		"Light Gray Stained Glass",
		.Entire,
	}
	mc_items["cyan_stained_glass"] = Minecraft_Item{
		"cyan_stained_glass",
		"Cyan Stained Glass",
		.Entire,
	}
	mc_items["purple_stained_glass"] = Minecraft_Item{
		"purple_stained_glass",
		"Purple Stained Glass",
		.Entire,
	}
	mc_items["blue_stained_glass"] = Minecraft_Item{
		"blue_stained_glass",
		"Blue Stained Glass",
		.Entire,
	}
	mc_items["brown_stained_glass"] = Minecraft_Item{
		"brown_stained_glass",
		"Brown Stained Glass",
		.Entire,
	}
	mc_items["green_stained_glass"] = Minecraft_Item{
		"green_stained_glass",
		"Green Stained Glass",
		.Entire,
	}
	mc_items["red_stained_glass"] = Minecraft_Item{
		"red_stained_glass",
		"Red Stained Glass",
		.Entire,
	}
	mc_items["black_stained_glass"] = Minecraft_Item{
		"black_stained_glass",
		"Black Stained Glass",
		.Entire,
	}
	mc_items["white_stained_glass_pane"] = Minecraft_Item{
		"white_stained_glass_pane",
		"White Stained Glass Pane",
		.Entire,
	}
	mc_items["orange_stained_glass_pane"] = Minecraft_Item{
		"orange_stained_glass_pane",
		"Orange Stained Glass Pane",
		.Entire,
	}
	mc_items["magenta_stained_glass_pane"] = Minecraft_Item{
		"magenta_stained_glass_pane",
		"Magenta Stained Glass Pane",
		.Entire,
	}
	mc_items["light_blue_stained_glass_pane"] = Minecraft_Item{
		"light_blue_stained_glass_pane",
		"Light Blue Stained Glass Pane",
		.Entire,
	}
	mc_items["yellow_stained_glass_pane"] = Minecraft_Item{
		"yellow_stained_glass_pane",
		"Yellow Stained Glass Pane",
		.Entire,
	}
	mc_items["lime_stained_glass_pane"] = Minecraft_Item{
		"lime_stained_glass_pane",
		"Lime Stained Glass Pane",
		.Entire,
	}
	mc_items["pink_stained_glass_pane"] = Minecraft_Item{
		"pink_stained_glass_pane",
		"Pink Stained Glass Pane",
		.Entire,
	}
	mc_items["gray_stained_glass_pane"] = Minecraft_Item{
		"gray_stained_glass_pane",
		"Gray Stained Glass Pane",
		.Entire,
	}
	mc_items["light_gray_stained_glass_pane"] = Minecraft_Item{
		"light_gray_stained_glass_pane",
		"Light Gray Stained Glass Pane",
		.Entire,
	}
	mc_items["cyan_stained_glass_pane"] = Minecraft_Item{
		"cyan_stained_glass_pane",
		"Cyan Stained Glass Pane",
		.Entire,
	}
	mc_items["purple_stained_glass_pane"] = Minecraft_Item{
		"purple_stained_glass_pane",
		"Purple Stained Glass Pane",
		.Entire,
	}
	mc_items["blue_stained_glass_pane"] = Minecraft_Item{
		"blue_stained_glass_pane",
		"Blue Stained Glass Pane",
		.Entire,
	}
	mc_items["brown_stained_glass_pane"] = Minecraft_Item{
		"brown_stained_glass_pane",
		"Brown Stained Glass Pane",
		.Entire,
	}
	mc_items["green_stained_glass_pane"] = Minecraft_Item{
		"green_stained_glass_pane",
		"Green Stained Glass Pane",
		.Entire,
	}
	mc_items["red_stained_glass_pane"] = Minecraft_Item{
		"red_stained_glass_pane",
		"Red Stained Glass Pane",
		.Entire,
	}
	mc_items["black_stained_glass_pane"] = Minecraft_Item{
		"black_stained_glass_pane",
		"Black Stained Glass Pane",
		.Entire,
	}
	mc_items["prismarine"] = Minecraft_Item{
		"prismarine",
		"Prismarine",
		.Entire,
	}
	mc_items["prismarine_bricks"] = Minecraft_Item{
		"prismarine_bricks",
		"Prismarine Bricks",
		.Entire,
	}
	mc_items["dark_prismarine"] = Minecraft_Item{
		"dark_prismarine",
		"Dark Prismarine",
		.Entire,
	}
	mc_items["prismarine_stairs"] = Minecraft_Item{
		"prismarine_stairs",
		"Prismarine Stairs",
		.Entire,
	}
	mc_items["prismarine_brick_stairs"] = Minecraft_Item{
		"prismarine_brick_stairs",
		"Prismarine Brick Stairs",
		.Entire,
	}
	mc_items["dark_prismarine_stairs"] = Minecraft_Item{
		"dark_prismarine_stairs",
		"Dark Prismarine Stairs",
		.Entire,
	}
	mc_items["sea_lantern"] = Minecraft_Item{
		"sea_lantern",
		"Sea Lantern",
		.Entire,
	}
	mc_items["red_sandstone"] = Minecraft_Item{
		"red_sandstone",
		"Red Sandstone",
		.Entire,
	}
	mc_items["chiseled_red_sandstone"] = Minecraft_Item{
		"chiseled_red_sandstone",
		"Chiseled Red Sandstone",
		.Entire,
	}
	mc_items["cut_red_sandstone"] = Minecraft_Item{
		"cut_red_sandstone",
		"Cut Red Sandstone",
		.Entire,
	}
	mc_items["red_sandstone_stairs"] = Minecraft_Item{
		"red_sandstone_stairs",
		"Red Sandstone Stairs",
		.Entire,
	}
	mc_items["repeating_command_block"] = Minecraft_Item{
		"repeating_command_block",
		"Repeating Command Block",
		.Entire,
	}
	mc_items["chain_command_block"] = Minecraft_Item{
		"chain_command_block",
		"Chain Command Block",
		.Entire,
	}
	mc_items["magma_block"] = Minecraft_Item{
		"magma_block",
		"Magma Block",
		.Entire,
	}
	mc_items["nether_wart_block"] = Minecraft_Item{
		"nether_wart_block",
		"Nether Wart Block",
		.Entire,
	}
	mc_items["warped_wart_block"] = Minecraft_Item{
		"warped_wart_block",
		"Warped Wart Block",
		.Entire,
	}
	mc_items["red_nether_bricks"] = Minecraft_Item{
		"red_nether_bricks",
		"Red Nether Bricks",
		.Entire,
	}
	mc_items["bone_block"] = Minecraft_Item{
		"bone_block",
		"Bone Block",
		.Entire,
	}
	mc_items["structure_void"] = Minecraft_Item{
		"structure_void",
		"Structure Void",
		.Entire,
	}
	mc_items["shulker_box"] = Minecraft_Item{
		"shulker_box",
		"Shulker Box",
		.Single,
	}
	mc_items["white_shulker_box"] = Minecraft_Item{
		"white_shulker_box",
		"White Shulker Box",
		.Single,
	}
	mc_items["orange_shulker_box"] = Minecraft_Item{
		"orange_shulker_box",
		"Orange Shulker Box",
		.Single,
	}
	mc_items["magenta_shulker_box"] = Minecraft_Item{
		"magenta_shulker_box",
		"Magenta Shulker Box",
		.Single,
	}
	mc_items["light_blue_shulker_box"] = Minecraft_Item{
		"light_blue_shulker_box",
		"Light Blue Shulker Box",
		.Single,
	}
	mc_items["yellow_shulker_box"] = Minecraft_Item{
		"yellow_shulker_box",
		"Yellow Shulker Box",
		.Single,
	}
	mc_items["lime_shulker_box"] = Minecraft_Item{
		"lime_shulker_box",
		"Lime Shulker Box",
		.Single,
	}
	mc_items["pink_shulker_box"] = Minecraft_Item{
		"pink_shulker_box",
		"Pink Shulker Box",
		.Single,
	}
	mc_items["gray_shulker_box"] = Minecraft_Item{
		"gray_shulker_box",
		"Gray Shulker Box",
		.Single,
	}
	mc_items["light_gray_shulker_box"] = Minecraft_Item{
		"light_gray_shulker_box",
		"Light Gray Shulker Box",
		.Single,
	}
	mc_items["cyan_shulker_box"] = Minecraft_Item{
		"cyan_shulker_box",
		"Cyan Shulker Box",
		.Single,
	}
	mc_items["purple_shulker_box"] = Minecraft_Item{
		"purple_shulker_box",
		"Purple Shulker Box",
		.Single,
	}
	mc_items["blue_shulker_box"] = Minecraft_Item{
		"blue_shulker_box",
		"Blue Shulker Box",
		.Single,
	}
	mc_items["brown_shulker_box"] = Minecraft_Item{
		"brown_shulker_box",
		"Brown Shulker Box",
		.Single,
	}
	mc_items["green_shulker_box"] = Minecraft_Item{
		"green_shulker_box",
		"Green Shulker Box",
		.Single,
	}
	mc_items["red_shulker_box"] = Minecraft_Item{
		"red_shulker_box",
		"Red Shulker Box",
		.Single,
	}
	mc_items["black_shulker_box"] = Minecraft_Item{
		"black_shulker_box",
		"Black Shulker Box",
		.Single,
	}
	mc_items["white_glazed_terracotta"] = Minecraft_Item{
		"white_glazed_terracotta",
		"White Glazed Terracotta",
		.Entire,
	}
	mc_items["orange_glazed_terracotta"] = Minecraft_Item{
		"orange_glazed_terracotta",
		"Orange Glazed Terracotta",
		.Entire,
	}
	mc_items["magenta_glazed_terracotta"] = Minecraft_Item{
		"magenta_glazed_terracotta",
		"Magenta Glazed Terracotta",
		.Entire,
	}
	mc_items["light_blue_glazed_terracotta"] = Minecraft_Item{
		"light_blue_glazed_terracotta",
		"Light Blue Glazed Terracotta",
		.Entire,
	}
	mc_items["yellow_glazed_terracotta"] = Minecraft_Item{
		"yellow_glazed_terracotta",
		"Yellow Glazed Terracotta",
		.Entire,
	}
	mc_items["lime_glazed_terracotta"] = Minecraft_Item{
		"lime_glazed_terracotta",
		"Lime Glazed Terracotta",
		.Entire,
	}
	mc_items["pink_glazed_terracotta"] = Minecraft_Item{
		"pink_glazed_terracotta",
		"Pink Glazed Terracotta",
		.Entire,
	}
	mc_items["gray_glazed_terracotta"] = Minecraft_Item{
		"gray_glazed_terracotta",
		"Gray Glazed Terracotta",
		.Entire,
	}
	mc_items["light_gray_glazed_terracotta"] = Minecraft_Item{
		"light_gray_glazed_terracotta",
		"Light Gray Glazed Terracotta",
		.Entire,
	}
	mc_items["cyan_glazed_terracotta"] = Minecraft_Item{
		"cyan_glazed_terracotta",
		"Cyan Glazed Terracotta",
		.Entire,
	}
	mc_items["purple_glazed_terracotta"] = Minecraft_Item{
		"purple_glazed_terracotta",
		"Purple Glazed Terracotta",
		.Entire,
	}
	mc_items["blue_glazed_terracotta"] = Minecraft_Item{
		"blue_glazed_terracotta",
		"Blue Glazed Terracotta",
		.Entire,
	}
	mc_items["brown_glazed_terracotta"] = Minecraft_Item{
		"brown_glazed_terracotta",
		"Brown Glazed Terracotta",
		.Entire,
	}
	mc_items["green_glazed_terracotta"] = Minecraft_Item{
		"green_glazed_terracotta",
		"Green Glazed Terracotta",
		.Entire,
	}
	mc_items["red_glazed_terracotta"] = Minecraft_Item{
		"red_glazed_terracotta",
		"Red Glazed Terracotta",
		.Entire,
	}
	mc_items["black_glazed_terracotta"] = Minecraft_Item{
		"black_glazed_terracotta",
		"Black Glazed Terracotta",
		.Entire,
	}
	mc_items["white_concrete"] = Minecraft_Item{
		"white_concrete",
		"White Concrete",
		.Entire,
	}
	mc_items["orange_concrete"] = Minecraft_Item{
		"orange_concrete",
		"Orange Concrete",
		.Entire,
	}
	mc_items["magenta_concrete"] = Minecraft_Item{
		"magenta_concrete",
		"Magenta Concrete",
		.Entire,
	}
	mc_items["light_blue_concrete"] = Minecraft_Item{
		"light_blue_concrete",
		"Light Blue Concrete",
		.Entire,
	}
	mc_items["yellow_concrete"] = Minecraft_Item{
		"yellow_concrete",
		"Yellow Concrete",
		.Entire,
	}
	mc_items["lime_concrete"] = Minecraft_Item{
		"lime_concrete",
		"Lime Concrete",
		.Entire,
	}
	mc_items["pink_concrete"] = Minecraft_Item{
		"pink_concrete",
		"Pink Concrete",
		.Entire,
	}
	mc_items["gray_concrete"] = Minecraft_Item{
		"gray_concrete",
		"Gray Concrete",
		.Entire,
	}
	mc_items["light_gray_concrete"] = Minecraft_Item{
		"light_gray_concrete",
		"Light Gray Concrete",
		.Entire,
	}
	mc_items["cyan_concrete"] = Minecraft_Item{
		"cyan_concrete",
		"Cyan Concrete",
		.Entire,
	}
	mc_items["purple_concrete"] = Minecraft_Item{
		"purple_concrete",
		"Purple Concrete",
		.Entire,
	}
	mc_items["blue_concrete"] = Minecraft_Item{
		"blue_concrete",
		"Blue Concrete",
		.Entire,
	}
	mc_items["brown_concrete"] = Minecraft_Item{
		"brown_concrete",
		"Brown Concrete",
		.Entire,
	}
	mc_items["green_concrete"] = Minecraft_Item{
		"green_concrete",
		"Green Concrete",
		.Entire,
	}
	mc_items["red_concrete"] = Minecraft_Item{
		"red_concrete",
		"Red Concrete",
		.Entire,
	}
	mc_items["black_concrete"] = Minecraft_Item{
		"black_concrete",
		"Black Concrete",
		.Entire,
	}
	mc_items["white_concrete_powder"] = Minecraft_Item{
		"white_concrete_powder",
		"White Concrete Powder",
		.Entire,
	}
	mc_items["orange_concrete_powder"] = Minecraft_Item{
		"orange_concrete_powder",
		"Orange Concrete Powder",
		.Entire,
	}
	mc_items["magenta_concrete_powder"] = Minecraft_Item{
		"magenta_concrete_powder",
		"Magenta Concrete Powder",
		.Entire,
	}
	mc_items["light_blue_concrete_powder"] = Minecraft_Item{
		"light_blue_concrete_powder",
		"Light Blue Concrete Powder",
		.Entire,
	}
	mc_items["yellow_concrete_powder"] = Minecraft_Item{
		"yellow_concrete_powder",
		"Yellow Concrete Powder",
		.Entire,
	}
	mc_items["lime_concrete_powder"] = Minecraft_Item{
		"lime_concrete_powder",
		"Lime Concrete Powder",
		.Entire,
	}
	mc_items["pink_concrete_powder"] = Minecraft_Item{
		"pink_concrete_powder",
		"Pink Concrete Powder",
		.Entire,
	}
	mc_items["gray_concrete_powder"] = Minecraft_Item{
		"gray_concrete_powder",
		"Gray Concrete Powder",
		.Entire,
	}
	mc_items["light_gray_concrete_powder"] = Minecraft_Item{
		"light_gray_concrete_powder",
		"Light Gray Concrete Powder",
		.Entire,
	}
	mc_items["cyan_concrete_powder"] = Minecraft_Item{
		"cyan_concrete_powder",
		"Cyan Concrete Powder",
		.Entire,
	}
	mc_items["purple_concrete_powder"] = Minecraft_Item{
		"purple_concrete_powder",
		"Purple Concrete Powder",
		.Entire,
	}
	mc_items["blue_concrete_powder"] = Minecraft_Item{
		"blue_concrete_powder",
		"Blue Concrete Powder",
		.Entire,
	}
	mc_items["brown_concrete_powder"] = Minecraft_Item{
		"brown_concrete_powder",
		"Brown Concrete Powder",
		.Entire,
	}
	mc_items["green_concrete_powder"] = Minecraft_Item{
		"green_concrete_powder",
		"Green Concrete Powder",
		.Entire,
	}
	mc_items["red_concrete_powder"] = Minecraft_Item{
		"red_concrete_powder",
		"Red Concrete Powder",
		.Entire,
	}
	mc_items["black_concrete_powder"] = Minecraft_Item{
		"black_concrete_powder",
		"Black Concrete Powder",
		.Entire,
	}
	mc_items["turtle_egg"] = Minecraft_Item{
		"turtle_egg",
		"Turtle Egg",
		.Entire,
	}
	mc_items["sniffer_egg"] = Minecraft_Item{
		"sniffer_egg",
		"Sniffer Egg",
		.Entire,
	}
	mc_items["dried_ghast"] = Minecraft_Item{
		"dried_ghast",
		"Dried Ghast",
		.Entire,
	}
	mc_items["dead_tube_coral_block"] = Minecraft_Item{
		"dead_tube_coral_block",
		"Dead Tube Coral Block",
		.Entire,
	}
	mc_items["dead_brain_coral_block"] = Minecraft_Item{
		"dead_brain_coral_block",
		"Dead Brain Coral Block",
		.Entire,
	}
	mc_items["dead_bubble_coral_block"] = Minecraft_Item{
		"dead_bubble_coral_block",
		"Dead Bubble Coral Block",
		.Entire,
	}
	mc_items["dead_fire_coral_block"] = Minecraft_Item{
		"dead_fire_coral_block",
		"Dead Fire Coral Block",
		.Entire,
	}
	mc_items["dead_horn_coral_block"] = Minecraft_Item{
		"dead_horn_coral_block",
		"Dead Horn Coral Block",
		.Entire,
	}
	mc_items["tube_coral_block"] = Minecraft_Item{
		"tube_coral_block",
		"Tube Coral Block",
		.Entire,
	}
	mc_items["brain_coral_block"] = Minecraft_Item{
		"brain_coral_block",
		"Brain Coral Block",
		.Entire,
	}
	mc_items["bubble_coral_block"] = Minecraft_Item{
		"bubble_coral_block",
		"Bubble Coral Block",
		.Entire,
	}
	mc_items["fire_coral_block"] = Minecraft_Item{
		"fire_coral_block",
		"Fire Coral Block",
		.Entire,
	}
	mc_items["horn_coral_block"] = Minecraft_Item{
		"horn_coral_block",
		"Horn Coral Block",
		.Entire,
	}
	mc_items["tube_coral"] = Minecraft_Item{
		"tube_coral",
		"Tube Coral",
		.Entire,
	}
	mc_items["brain_coral"] = Minecraft_Item{
		"brain_coral",
		"Brain Coral",
		.Entire,
	}
	mc_items["bubble_coral"] = Minecraft_Item{
		"bubble_coral",
		"Bubble Coral",
		.Entire,
	}
	mc_items["fire_coral"] = Minecraft_Item{
		"fire_coral",
		"Fire Coral",
		.Entire,
	}
	mc_items["horn_coral"] = Minecraft_Item{
		"horn_coral",
		"Horn Coral",
		.Entire,
	}
	mc_items["dead_brain_coral"] = Minecraft_Item{
		"dead_brain_coral",
		"Dead Brain Coral",
		.Entire,
	}
	mc_items["dead_bubble_coral"] = Minecraft_Item{
		"dead_bubble_coral",
		"Dead Bubble Coral",
		.Entire,
	}
	mc_items["dead_fire_coral"] = Minecraft_Item{
		"dead_fire_coral",
		"Dead Fire Coral",
		.Entire,
	}
	mc_items["dead_horn_coral"] = Minecraft_Item{
		"dead_horn_coral",
		"Dead Horn Coral",
		.Entire,
	}
	mc_items["dead_tube_coral"] = Minecraft_Item{
		"dead_tube_coral",
		"Dead Tube Coral",
		.Entire,
	}
	mc_items["tube_coral_fan"] = Minecraft_Item{
		"tube_coral_fan",
		"Tube Coral Fan",
		.Entire,
	}
	mc_items["brain_coral_fan"] = Minecraft_Item{
		"brain_coral_fan",
		"Brain Coral Fan",
		.Entire,
	}
	mc_items["bubble_coral_fan"] = Minecraft_Item{
		"bubble_coral_fan",
		"Bubble Coral Fan",
		.Entire,
	}
	mc_items["fire_coral_fan"] = Minecraft_Item{
		"fire_coral_fan",
		"Fire Coral Fan",
		.Entire,
	}
	mc_items["horn_coral_fan"] = Minecraft_Item{
		"horn_coral_fan",
		"Horn Coral Fan",
		.Entire,
	}
	mc_items["dead_tube_coral_fan"] = Minecraft_Item{
		"dead_tube_coral_fan",
		"Dead Tube Coral Fan",
		.Entire,
	}
	mc_items["dead_brain_coral_fan"] = Minecraft_Item{
		"dead_brain_coral_fan",
		"Dead Brain Coral Fan",
		.Entire,
	}
	mc_items["dead_bubble_coral_fan"] = Minecraft_Item{
		"dead_bubble_coral_fan",
		"Dead Bubble Coral Fan",
		.Entire,
	}
	mc_items["dead_fire_coral_fan"] = Minecraft_Item{
		"dead_fire_coral_fan",
		"Dead Fire Coral Fan",
		.Entire,
	}
	mc_items["dead_horn_coral_fan"] = Minecraft_Item{
		"dead_horn_coral_fan",
		"Dead Horn Coral Fan",
		.Entire,
	}
	mc_items["blue_ice"] = Minecraft_Item{
		"blue_ice",
		"Blue Ice",
		.Entire,
	}
	mc_items["conduit"] = Minecraft_Item{
		"conduit",
		"Conduit",
		.Entire,
	}
	mc_items["polished_granite_stairs"] = Minecraft_Item{
		"polished_granite_stairs",
		"Polished Granite Stairs",
		.Entire,
	}
	mc_items["smooth_red_sandstone_stairs"] = Minecraft_Item{
		"smooth_red_sandstone_stairs",
		"Smooth Red Sandstone Stairs",
		.Entire,
	}
	mc_items["mossy_stone_brick_stairs"] = Minecraft_Item{
		"mossy_stone_brick_stairs",
		"Mossy Stone Brick Stairs",
		.Entire,
	}
	mc_items["polished_diorite_stairs"] = Minecraft_Item{
		"polished_diorite_stairs",
		"Polished Diorite Stairs",
		.Entire,
	}
	mc_items["mossy_cobblestone_stairs"] = Minecraft_Item{
		"mossy_cobblestone_stairs",
		"Mossy Cobblestone Stairs",
		.Entire,
	}
	mc_items["end_stone_brick_stairs"] = Minecraft_Item{
		"end_stone_brick_stairs",
		"End Stone Brick Stairs",
		.Entire,
	}
	mc_items["stone_stairs"] = Minecraft_Item{
		"stone_stairs",
		"Stone Stairs",
		.Entire,
	}
	mc_items["smooth_sandstone_stairs"] = Minecraft_Item{
		"smooth_sandstone_stairs",
		"Smooth Sandstone Stairs",
		.Entire,
	}
	mc_items["smooth_quartz_stairs"] = Minecraft_Item{
		"smooth_quartz_stairs",
		"Smooth Quartz Stairs",
		.Entire,
	}
	mc_items["granite_stairs"] = Minecraft_Item{
		"granite_stairs",
		"Granite Stairs",
		.Entire,
	}
	mc_items["andesite_stairs"] = Minecraft_Item{
		"andesite_stairs",
		"Andesite Stairs",
		.Entire,
	}
	mc_items["red_nether_brick_stairs"] = Minecraft_Item{
		"red_nether_brick_stairs",
		"Red Nether Brick Stairs",
		.Entire,
	}
	mc_items["polished_andesite_stairs"] = Minecraft_Item{
		"polished_andesite_stairs",
		"Polished Andesite Stairs",
		.Entire,
	}
	mc_items["diorite_stairs"] = Minecraft_Item{
		"diorite_stairs",
		"Diorite Stairs",
		.Entire,
	}
	mc_items["cobbled_deepslate_stairs"] = Minecraft_Item{
		"cobbled_deepslate_stairs",
		"Cobbled Deepslate Stairs",
		.Entire,
	}
	mc_items["polished_deepslate_stairs"] = Minecraft_Item{
		"polished_deepslate_stairs",
		"Polished Deepslate Stairs",
		.Entire,
	}
	mc_items["deepslate_brick_stairs"] = Minecraft_Item{
		"deepslate_brick_stairs",
		"Deepslate Brick Stairs",
		.Entire,
	}
	mc_items["deepslate_tile_stairs"] = Minecraft_Item{
		"deepslate_tile_stairs",
		"Deepslate Tile Stairs",
		.Entire,
	}
	mc_items["polished_granite_slab"] = Minecraft_Item{
		"polished_granite_slab",
		"Polished Granite Slab",
		.Entire,
	}
	mc_items["smooth_red_sandstone_slab"] = Minecraft_Item{
		"smooth_red_sandstone_slab",
		"Smooth Red Sandstone Slab",
		.Entire,
	}
	mc_items["mossy_stone_brick_slab"] = Minecraft_Item{
		"mossy_stone_brick_slab",
		"Mossy Stone Brick Slab",
		.Entire,
	}
	mc_items["polished_diorite_slab"] = Minecraft_Item{
		"polished_diorite_slab",
		"Polished Diorite Slab",
		.Entire,
	}
	mc_items["mossy_cobblestone_slab"] = Minecraft_Item{
		"mossy_cobblestone_slab",
		"Mossy Cobblestone Slab",
		.Entire,
	}
	mc_items["end_stone_brick_slab"] = Minecraft_Item{
		"end_stone_brick_slab",
		"End Stone Brick Slab",
		.Entire,
	}
	mc_items["smooth_sandstone_slab"] = Minecraft_Item{
		"smooth_sandstone_slab",
		"Smooth Sandstone Slab",
		.Entire,
	}
	mc_items["smooth_quartz_slab"] = Minecraft_Item{
		"smooth_quartz_slab",
		"Smooth Quartz Slab",
		.Entire,
	}
	mc_items["granite_slab"] = Minecraft_Item{
		"granite_slab",
		"Granite Slab",
		.Entire,
	}
	mc_items["andesite_slab"] = Minecraft_Item{
		"andesite_slab",
		"Andesite Slab",
		.Entire,
	}
	mc_items["red_nether_brick_slab"] = Minecraft_Item{
		"red_nether_brick_slab",
		"Red Nether Brick Slab",
		.Entire,
	}
	mc_items["polished_andesite_slab"] = Minecraft_Item{
		"polished_andesite_slab",
		"Polished Andesite Slab",
		.Entire,
	}
	mc_items["diorite_slab"] = Minecraft_Item{
		"diorite_slab",
		"Diorite Slab",
		.Entire,
	}
	mc_items["cobbled_deepslate_slab"] = Minecraft_Item{
		"cobbled_deepslate_slab",
		"Cobbled Deepslate Slab",
		.Entire,
	}
	mc_items["polished_deepslate_slab"] = Minecraft_Item{
		"polished_deepslate_slab",
		"Polished Deepslate Slab",
		.Entire,
	}
	mc_items["deepslate_brick_slab"] = Minecraft_Item{
		"deepslate_brick_slab",
		"Deepslate Brick Slab",
		.Entire,
	}
	mc_items["deepslate_tile_slab"] = Minecraft_Item{
		"deepslate_tile_slab",
		"Deepslate Tile Slab",
		.Entire,
	}
	mc_items["scaffolding"] = Minecraft_Item{
		"scaffolding",
		"Scaffolding",
		.Entire,
	}
	mc_items["redstone"] = Minecraft_Item{
		"redstone",
		"Redstone Dust",
		.Entire,
	}
	mc_items["redstone_torch"] = Minecraft_Item{
		"redstone_torch",
		"Redstone Torch",
		.Entire,
	}
	mc_items["redstone_block"] = Minecraft_Item{
		"redstone_block",
		"Block of Redstone",
		.Entire,
	}
	mc_items["repeater"] = Minecraft_Item{
		"repeater",
		"Redstone Repeater",
		.Entire,
	}
	mc_items["comparator"] = Minecraft_Item{
		"comparator",
		"Redstone Comparator",
		.Entire,
	}
	mc_items["piston"] = Minecraft_Item{
		"piston",
		"Piston",
		.Entire,
	}
	mc_items["sticky_piston"] = Minecraft_Item{
		"sticky_piston",
		"Sticky Piston",
		.Entire,
	}
	mc_items["slime_block"] = Minecraft_Item{
		"slime_block",
		"Slime Block",
		.Entire,
	}
	mc_items["honey_block"] = Minecraft_Item{
		"honey_block",
		"Honey Block",
		.Entire,
	}
	mc_items["observer"] = Minecraft_Item{
		"observer",
		"Observer",
		.Entire,
	}
	mc_items["hopper"] = Minecraft_Item{
		"hopper",
		"Hopper",
		.Entire,
	}
	mc_items["dispenser"] = Minecraft_Item{
		"dispenser",
		"Dispenser",
		.Entire,
	}
	mc_items["dropper"] = Minecraft_Item{
		"dropper",
		"Dropper",
		.Entire,
	}
	mc_items["lectern"] = Minecraft_Item{
		"lectern",
		"Lectern",
		.Entire,
	}
	mc_items["target"] = Minecraft_Item{
		"target",
		"Target",
		.Entire,
	}
	mc_items["lever"] = Minecraft_Item{
		"lever",
		"Lever",
		.Entire,
	}
	mc_items["lightning_rod"] = Minecraft_Item{
		"lightning_rod",
		"Lightning Rod",
		.Entire,
	}
	mc_items["daylight_detector"] = Minecraft_Item{
		"daylight_detector",
		"Daylight Detector",
		.Entire,
	}
	mc_items["sculk_sensor"] = Minecraft_Item{
		"sculk_sensor",
		"Sculk Sensor",
		.Entire,
	}
	mc_items["calibrated_sculk_sensor"] = Minecraft_Item{
		"calibrated_sculk_sensor",
		"Calibrated Sculk Sensor",
		.Entire,
	}
	mc_items["tripwire_hook"] = Minecraft_Item{
		"tripwire_hook",
		"Tripwire Hook",
		.Entire,
	}
	mc_items["trapped_chest"] = Minecraft_Item{
		"trapped_chest",
		"Trapped Chest",
		.Entire,
	}
	mc_items["tnt"] = Minecraft_Item{
		"tnt",
		"TNT",
		.Entire,
	}
	mc_items["redstone_lamp"] = Minecraft_Item{
		"redstone_lamp",
		"Redstone Lamp",
		.Entire,
	}
	mc_items["note_block"] = Minecraft_Item{
		"note_block",
		"Note Block",
		.Entire,
	}
	mc_items["stone_button"] = Minecraft_Item{
		"stone_button",
		"Stone Button",
		.Entire,
	}
	mc_items["polished_blackstone_button"] = Minecraft_Item{
		"polished_blackstone_button",
		"Polished Blackstone Button",
		.Entire,
	}
	mc_items["oak_button"] = Minecraft_Item{
		"oak_button",
		"Oak Button",
		.Entire,
	}
	mc_items["spruce_button"] = Minecraft_Item{
		"spruce_button",
		"Spruce Button",
		.Entire,
	}
	mc_items["birch_button"] = Minecraft_Item{
		"birch_button",
		"Birch Button",
		.Entire,
	}
	mc_items["jungle_button"] = Minecraft_Item{
		"jungle_button",
		"Jungle Button",
		.Entire,
	}
	mc_items["acacia_button"] = Minecraft_Item{
		"acacia_button",
		"Acacia Button",
		.Entire,
	}
	mc_items["cherry_button"] = Minecraft_Item{
		"cherry_button",
		"Cherry Button",
		.Entire,
	}
	mc_items["dark_oak_button"] = Minecraft_Item{
		"dark_oak_button",
		"Dark Oak Button",
		.Entire,
	}
	mc_items["pale_oak_button"] = Minecraft_Item{
		"pale_oak_button",
		"Pale Oak Button",
		.Entire,
	}
	mc_items["mangrove_button"] = Minecraft_Item{
		"mangrove_button",
		"Mangrove Button",
		.Entire,
	}
	mc_items["bamboo_button"] = Minecraft_Item{
		"bamboo_button",
		"Bamboo Button",
		.Entire,
	}
	mc_items["crimson_button"] = Minecraft_Item{
		"crimson_button",
		"Crimson Button",
		.Entire,
	}
	mc_items["warped_button"] = Minecraft_Item{
		"warped_button",
		"Warped Button",
		.Entire,
	}
	mc_items["stone_pressure_plate"] = Minecraft_Item{
		"stone_pressure_plate",
		"Stone Pressure Plate",
		.Entire,
	}
	mc_items["polished_blackstone_pressure_plate"] = Minecraft_Item{
		"polished_blackstone_pressure_plate",
		"Polished Blackstone Pressure Plate",
		.Entire,
	}
	mc_items["light_weighted_pressure_plate"] = Minecraft_Item{
		"light_weighted_pressure_plate",
		"Light Weighted Pressure Plate",
		.Entire,
	}
	mc_items["heavy_weighted_pressure_plate"] = Minecraft_Item{
		"heavy_weighted_pressure_plate",
		"Heavy Weighted Pressure Plate",
		.Entire,
	}
	mc_items["oak_pressure_plate"] = Minecraft_Item{
		"oak_pressure_plate",
		"Oak Pressure Plate",
		.Entire,
	}
	mc_items["spruce_pressure_plate"] = Minecraft_Item{
		"spruce_pressure_plate",
		"Spruce Pressure Plate",
		.Entire,
	}
	mc_items["birch_pressure_plate"] = Minecraft_Item{
		"birch_pressure_plate",
		"Birch Pressure Plate",
		.Entire,
	}
	mc_items["jungle_pressure_plate"] = Minecraft_Item{
		"jungle_pressure_plate",
		"Jungle Pressure Plate",
		.Entire,
	}
	mc_items["acacia_pressure_plate"] = Minecraft_Item{
		"acacia_pressure_plate",
		"Acacia Pressure Plate",
		.Entire,
	}
	mc_items["cherry_pressure_plate"] = Minecraft_Item{
		"cherry_pressure_plate",
		"Cherry Pressure Plate",
		.Entire,
	}
	mc_items["dark_oak_pressure_plate"] = Minecraft_Item{
		"dark_oak_pressure_plate",
		"Dark Oak Pressure Plate",
		.Entire,
	}
	mc_items["pale_oak_pressure_plate"] = Minecraft_Item{
		"pale_oak_pressure_plate",
		"Pale Oak Pressure Plate",
		.Entire,
	}
	mc_items["mangrove_pressure_plate"] = Minecraft_Item{
		"mangrove_pressure_plate",
		"Mangrove Pressure Plate",
		.Entire,
	}
	mc_items["bamboo_pressure_plate"] = Minecraft_Item{
		"bamboo_pressure_plate",
		"Bamboo Pressure Plate",
		.Entire,
	}
	mc_items["crimson_pressure_plate"] = Minecraft_Item{
		"crimson_pressure_plate",
		"Crimson Pressure Plate",
		.Entire,
	}
	mc_items["warped_pressure_plate"] = Minecraft_Item{
		"warped_pressure_plate",
		"Warped Pressure Plate",
		.Entire,
	}
	mc_items["iron_door"] = Minecraft_Item{
		"iron_door",
		"Iron Door",
		.Entire,
	}
	mc_items["oak_door"] = Minecraft_Item{
		"oak_door",
		"Oak Door",
		.Entire,
	}
	mc_items["spruce_door"] = Minecraft_Item{
		"spruce_door",
		"Spruce Door",
		.Entire,
	}
	mc_items["birch_door"] = Minecraft_Item{
		"birch_door",
		"Birch Door",
		.Entire,
	}
	mc_items["jungle_door"] = Minecraft_Item{
		"jungle_door",
		"Jungle Door",
		.Entire,
	}
	mc_items["acacia_door"] = Minecraft_Item{
		"acacia_door",
		"Acacia Door",
		.Entire,
	}
	mc_items["cherry_door"] = Minecraft_Item{
		"cherry_door",
		"Cherry Door",
		.Entire,
	}
	mc_items["dark_oak_door"] = Minecraft_Item{
		"dark_oak_door",
		"Dark Oak Door",
		.Entire,
	}
	mc_items["pale_oak_door"] = Minecraft_Item{
		"pale_oak_door",
		"Pale Oak Door",
		.Entire,
	}
	mc_items["mangrove_door"] = Minecraft_Item{
		"mangrove_door",
		"Mangrove Door",
		.Entire,
	}
	mc_items["bamboo_door"] = Minecraft_Item{
		"bamboo_door",
		"Bamboo Door",
		.Entire,
	}
	mc_items["crimson_door"] = Minecraft_Item{
		"crimson_door",
		"Crimson Door",
		.Entire,
	}
	mc_items["warped_door"] = Minecraft_Item{
		"warped_door",
		"Warped Door",
		.Entire,
	}
	mc_items["copper_door"] = Minecraft_Item{
		"copper_door",
		"Copper Door",
		.Entire,
	}
	mc_items["exposed_copper_door"] = Minecraft_Item{
		"exposed_copper_door",
		"Exposed Copper Door",
		.Entire,
	}
	mc_items["weathered_copper_door"] = Minecraft_Item{
		"weathered_copper_door",
		"Weathered Copper Door",
		.Entire,
	}
	mc_items["oxidized_copper_door"] = Minecraft_Item{
		"oxidized_copper_door",
		"Oxidized Copper Door",
		.Entire,
	}
	mc_items["waxed_copper_door"] = Minecraft_Item{
		"waxed_copper_door",
		"Waxed Copper Door",
		.Entire,
	}
	mc_items["waxed_exposed_copper_door"] = Minecraft_Item{
		"waxed_exposed_copper_door",
		"Waxed Exposed Copper Door",
		.Entire,
	}
	mc_items["waxed_weathered_copper_door"] = Minecraft_Item{
		"waxed_weathered_copper_door",
		"Waxed Weathered Copper Door",
		.Entire,
	}
	mc_items["waxed_oxidized_copper_door"] = Minecraft_Item{
		"waxed_oxidized_copper_door",
		"Waxed Oxidized Copper Door",
		.Entire,
	}
	mc_items["iron_trapdoor"] = Minecraft_Item{
		"iron_trapdoor",
		"Iron Trapdoor",
		.Entire,
	}
	mc_items["oak_trapdoor"] = Minecraft_Item{
		"oak_trapdoor",
		"Oak Trapdoor",
		.Entire,
	}
	mc_items["spruce_trapdoor"] = Minecraft_Item{
		"spruce_trapdoor",
		"Spruce Trapdoor",
		.Entire,
	}
	mc_items["birch_trapdoor"] = Minecraft_Item{
		"birch_trapdoor",
		"Birch Trapdoor",
		.Entire,
	}
	mc_items["jungle_trapdoor"] = Minecraft_Item{
		"jungle_trapdoor",
		"Jungle Trapdoor",
		.Entire,
	}
	mc_items["acacia_trapdoor"] = Minecraft_Item{
		"acacia_trapdoor",
		"Acacia Trapdoor",
		.Entire,
	}
	mc_items["cherry_trapdoor"] = Minecraft_Item{
		"cherry_trapdoor",
		"Cherry Trapdoor",
		.Entire,
	}
	mc_items["dark_oak_trapdoor"] = Minecraft_Item{
		"dark_oak_trapdoor",
		"Dark Oak Trapdoor",
		.Entire,
	}
	mc_items["pale_oak_trapdoor"] = Minecraft_Item{
		"pale_oak_trapdoor",
		"Pale Oak Trapdoor",
		.Entire,
	}
	mc_items["mangrove_trapdoor"] = Minecraft_Item{
		"mangrove_trapdoor",
		"Mangrove Trapdoor",
		.Entire,
	}
	mc_items["bamboo_trapdoor"] = Minecraft_Item{
		"bamboo_trapdoor",
		"Bamboo Trapdoor",
		.Entire,
	}
	mc_items["crimson_trapdoor"] = Minecraft_Item{
		"crimson_trapdoor",
		"Crimson Trapdoor",
		.Entire,
	}
	mc_items["warped_trapdoor"] = Minecraft_Item{
		"warped_trapdoor",
		"Warped Trapdoor",
		.Entire,
	}
	mc_items["copper_trapdoor"] = Minecraft_Item{
		"copper_trapdoor",
		"Copper Trapdoor",
		.Entire,
	}
	mc_items["exposed_copper_trapdoor"] = Minecraft_Item{
		"exposed_copper_trapdoor",
		"Exposed Copper Trapdoor",
		.Entire,
	}
	mc_items["weathered_copper_trapdoor"] = Minecraft_Item{
		"weathered_copper_trapdoor",
		"Weathered Copper Trapdoor",
		.Entire,
	}
	mc_items["oxidized_copper_trapdoor"] = Minecraft_Item{
		"oxidized_copper_trapdoor",
		"Oxidized Copper Trapdoor",
		.Entire,
	}
	mc_items["waxed_copper_trapdoor"] = Minecraft_Item{
		"waxed_copper_trapdoor",
		"Waxed Copper Trapdoor",
		.Entire,
	}
	mc_items["waxed_exposed_copper_trapdoor"] = Minecraft_Item{
		"waxed_exposed_copper_trapdoor",
		"Waxed Exposed Copper Trapdoor",
		.Entire,
	}
	mc_items["waxed_weathered_copper_trapdoor"] = Minecraft_Item{
		"waxed_weathered_copper_trapdoor",
		"Waxed Weathered Copper Trapdoor",
		.Entire,
	}
	mc_items["waxed_oxidized_copper_trapdoor"] = Minecraft_Item{
		"waxed_oxidized_copper_trapdoor",
		"Waxed Oxidized Copper Trapdoor",
		.Entire,
	}
	mc_items["oak_fence_gate"] = Minecraft_Item{
		"oak_fence_gate",
		"Oak Fence Gate",
		.Entire,
	}
	mc_items["spruce_fence_gate"] = Minecraft_Item{
		"spruce_fence_gate",
		"Spruce Fence Gate",
		.Entire,
	}
	mc_items["birch_fence_gate"] = Minecraft_Item{
		"birch_fence_gate",
		"Birch Fence Gate",
		.Entire,
	}
	mc_items["jungle_fence_gate"] = Minecraft_Item{
		"jungle_fence_gate",
		"Jungle Fence Gate",
		.Entire,
	}
	mc_items["acacia_fence_gate"] = Minecraft_Item{
		"acacia_fence_gate",
		"Acacia Fence Gate",
		.Entire,
	}
	mc_items["cherry_fence_gate"] = Minecraft_Item{
		"cherry_fence_gate",
		"Cherry Fence Gate",
		.Entire,
	}
	mc_items["dark_oak_fence_gate"] = Minecraft_Item{
		"dark_oak_fence_gate",
		"Dark Oak Fence Gate",
		.Entire,
	}
	mc_items["pale_oak_fence_gate"] = Minecraft_Item{
		"pale_oak_fence_gate",
		"Pale Oak Fence Gate",
		.Entire,
	}
	mc_items["mangrove_fence_gate"] = Minecraft_Item{
		"mangrove_fence_gate",
		"Mangrove Fence Gate",
		.Entire,
	}
	mc_items["bamboo_fence_gate"] = Minecraft_Item{
		"bamboo_fence_gate",
		"Bamboo Fence Gate",
		.Entire,
	}
	mc_items["crimson_fence_gate"] = Minecraft_Item{
		"crimson_fence_gate",
		"Crimson Fence Gate",
		.Entire,
	}
	mc_items["warped_fence_gate"] = Minecraft_Item{
		"warped_fence_gate",
		"Warped Fence Gate",
		.Entire,
	}
	mc_items["powered_rail"] = Minecraft_Item{
		"powered_rail",
		"Powered Rail",
		.Entire,
	}
	mc_items["detector_rail"] = Minecraft_Item{
		"detector_rail",
		"Detector Rail",
		.Entire,
	}
	mc_items["rail"] = Minecraft_Item{
		"rail",
		"Rail",
		.Entire,
	}
	mc_items["activator_rail"] = Minecraft_Item{
		"activator_rail",
		"Activator Rail",
		.Entire,
	}
	mc_items["saddle"] = Minecraft_Item{
		"saddle",
		"Saddle",
		.Single,
	}
	mc_items["white_harness"] = Minecraft_Item{
		"white_harness",
		"White Harness",
		.Single,
	}
	mc_items["orange_harness"] = Minecraft_Item{
		"orange_harness",
		"Orange Harness",
		.Single,
	}
	mc_items["magenta_harness"] = Minecraft_Item{
		"magenta_harness",
		"Magenta Harness",
		.Single,
	}
	mc_items["light_blue_harness"] = Minecraft_Item{
		"light_blue_harness",
		"Light Blue Harness",
		.Single,
	}
	mc_items["yellow_harness"] = Minecraft_Item{
		"yellow_harness",
		"Yellow Harness",
		.Single,
	}
	mc_items["lime_harness"] = Minecraft_Item{
		"lime_harness",
		"Lime Harness",
		.Single,
	}
	mc_items["pink_harness"] = Minecraft_Item{
		"pink_harness",
		"Pink Harness",
		.Single,
	}
	mc_items["gray_harness"] = Minecraft_Item{
		"gray_harness",
		"Gray Harness",
		.Single,
	}
	mc_items["light_gray_harness"] = Minecraft_Item{
		"light_gray_harness",
		"Light Gray Harness",
		.Single,
	}
	mc_items["cyan_harness"] = Minecraft_Item{
		"cyan_harness",
		"Cyan Harness",
		.Single,
	}
	mc_items["purple_harness"] = Minecraft_Item{
		"purple_harness",
		"Purple Harness",
		.Single,
	}
	mc_items["blue_harness"] = Minecraft_Item{
		"blue_harness",
		"Blue Harness",
		.Single,
	}
	mc_items["brown_harness"] = Minecraft_Item{
		"brown_harness",
		"Brown Harness",
		.Single,
	}
	mc_items["green_harness"] = Minecraft_Item{
		"green_harness",
		"Green Harness",
		.Single,
	}
	mc_items["red_harness"] = Minecraft_Item{
		"red_harness",
		"Red Harness",
		.Single,
	}
	mc_items["black_harness"] = Minecraft_Item{
		"black_harness",
		"Black Harness",
		.Single,
	}
	mc_items["minecart"] = Minecraft_Item{
		"minecart",
		"Minecart",
		.Single,
	}
	mc_items["chest_minecart"] = Minecraft_Item{
		"chest_minecart",
		"Minecart with Chest",
		.Single,
	}
	mc_items["furnace_minecart"] = Minecraft_Item{
		"furnace_minecart",
		"Minecart with Furnace",
		.Single,
	}
	mc_items["tnt_minecart"] = Minecraft_Item{
		"tnt_minecart",
		"Minecart with TNT",
		.Single,
	}
	mc_items["hopper_minecart"] = Minecraft_Item{
		"hopper_minecart",
		"Minecart with Hopper",
		.Single,
	}
	mc_items["carrot_on_a_stick"] = Minecraft_Item{
		"carrot_on_a_stick",
		"Carrot on a Stick",
		.Single,
	}
	mc_items["warped_fungus_on_a_stick"] = Minecraft_Item{
		"warped_fungus_on_a_stick",
		"Warped Fungus on a Stick",
		.Single,
	}
	mc_items["phantom_membrane"] = Minecraft_Item{
		"phantom_membrane",
		"Phantom Membrane",
		.Entire,
	}
	mc_items["elytra"] = Minecraft_Item{
		"elytra",
		"Elytra",
		.Single,
	}
	mc_items["oak_boat"] = Minecraft_Item{
		"oak_boat",
		"Oak Boat",
		.Single,
	}
	mc_items["oak_chest_boat"] = Minecraft_Item{
		"oak_chest_boat",
		"Oak Boat with Chest",
		.Single,
	}
	mc_items["spruce_boat"] = Minecraft_Item{
		"spruce_boat",
		"Spruce Boat",
		.Single,
	}
	mc_items["spruce_chest_boat"] = Minecraft_Item{
		"spruce_chest_boat",
		"Spruce Boat with Chest",
		.Single,
	}
	mc_items["birch_boat"] = Minecraft_Item{
		"birch_boat",
		"Birch Boat",
		.Single,
	}
	mc_items["birch_chest_boat"] = Minecraft_Item{
		"birch_chest_boat",
		"Birch Boat with Chest",
		.Single,
	}
	mc_items["jungle_boat"] = Minecraft_Item{
		"jungle_boat",
		"Jungle Boat",
		.Single,
	}
	mc_items["jungle_chest_boat"] = Minecraft_Item{
		"jungle_chest_boat",
		"Jungle Boat with Chest",
		.Single,
	}
	mc_items["acacia_boat"] = Minecraft_Item{
		"acacia_boat",
		"Acacia Boat",
		.Single,
	}
	mc_items["acacia_chest_boat"] = Minecraft_Item{
		"acacia_chest_boat",
		"Acacia Boat with Chest",
		.Single,
	}
	mc_items["cherry_boat"] = Minecraft_Item{
		"cherry_boat",
		"Cherry Boat",
		.Single,
	}
	mc_items["cherry_chest_boat"] = Minecraft_Item{
		"cherry_chest_boat",
		"Cherry Boat with Chest",
		.Single,
	}
	mc_items["dark_oak_boat"] = Minecraft_Item{
		"dark_oak_boat",
		"Dark Oak Boat",
		.Single,
	}
	mc_items["dark_oak_chest_boat"] = Minecraft_Item{
		"dark_oak_chest_boat",
		"Dark Oak Boat with Chest",
		.Single,
	}
	mc_items["pale_oak_boat"] = Minecraft_Item{
		"pale_oak_boat",
		"Pale Oak Boat",
		.Single,
	}
	mc_items["pale_oak_chest_boat"] = Minecraft_Item{
		"pale_oak_chest_boat",
		"Pale Oak Boat with Chest",
		.Single,
	}
	mc_items["mangrove_boat"] = Minecraft_Item{
		"mangrove_boat",
		"Mangrove Boat",
		.Single,
	}
	mc_items["mangrove_chest_boat"] = Minecraft_Item{
		"mangrove_chest_boat",
		"Mangrove Boat with Chest",
		.Single,
	}
	mc_items["bamboo_raft"] = Minecraft_Item{
		"bamboo_raft",
		"Bamboo Raft",
		.Single,
	}
	mc_items["bamboo_chest_raft"] = Minecraft_Item{
		"bamboo_chest_raft",
		"Bamboo Raft with Chest",
		.Single,
	}
	mc_items["structure_block"] = Minecraft_Item{
		"structure_block",
		"Structure Block",
		.Entire,
	}
	mc_items["jigsaw"] = Minecraft_Item{
		"jigsaw",
		"Jigsaw Block",
		.Entire,
	}
	mc_items["test_block"] = Minecraft_Item{
		"test_block",
		"Test Block",
		.Entire,
	}
	mc_items["test_instance_block"] = Minecraft_Item{
		"test_instance_block",
		"Test Instance Block",
		.Entire,
	}
	mc_items["turtle_helmet"] = Minecraft_Item{
		"turtle_helmet",
		"Turtle Shell",
		.Single,
	}
	mc_items["turtle_scute"] = Minecraft_Item{
		"turtle_scute",
		"Turtle Scute",
		.Entire,
	}
	mc_items["armadillo_scute"] = Minecraft_Item{
		"armadillo_scute",
		"Armadillo Scute",
		.Entire,
	}
	mc_items["wolf_armor"] = Minecraft_Item{
		"wolf_armor",
		"Wolf Armor",
		.Single,
	}
	mc_items["flint_and_steel"] = Minecraft_Item{
		"flint_and_steel",
		"Flint and Steel",
		.Single,
	}
	mc_items["bowl"] = Minecraft_Item{
		"bowl",
		"Bowl",
		.Entire,
	}
	mc_items["apple"] = Minecraft_Item{
		"apple",
		"Apple",
		.Entire,
	}
	mc_items["bow"] = Minecraft_Item{
		"bow",
		"Bow",
		.Single,
	}
	mc_items["arrow"] = Minecraft_Item{
		"arrow",
		"Arrow",
		.Entire,
	}
	mc_items["coal"] = Minecraft_Item{
		"coal",
		"Coal",
		.Entire,
	}
	mc_items["charcoal"] = Minecraft_Item{
		"charcoal",
		"Charcoal",
		.Entire,
	}
	mc_items["diamond"] = Minecraft_Item{
		"diamond",
		"Diamond",
		.Entire,
	}
	mc_items["emerald"] = Minecraft_Item{
		"emerald",
		"Emerald",
		.Entire,
	}
	mc_items["lapis_lazuli"] = Minecraft_Item{
		"lapis_lazuli",
		"Lapis Lazuli",
		.Entire,
	}
	mc_items["quartz"] = Minecraft_Item{
		"quartz",
		"Nether Quartz",
		.Entire,
	}
	mc_items["amethyst_shard"] = Minecraft_Item{
		"amethyst_shard",
		"Amethyst Shard",
		.Entire,
	}
	mc_items["raw_iron"] = Minecraft_Item{
		"raw_iron",
		"Raw Iron",
		.Entire,
	}
	mc_items["iron_ingot"] = Minecraft_Item{
		"iron_ingot",
		"Iron Ingot",
		.Entire,
	}
	mc_items["raw_copper"] = Minecraft_Item{
		"raw_copper",
		"Raw Copper",
		.Entire,
	}
	mc_items["copper_ingot"] = Minecraft_Item{
		"copper_ingot",
		"Copper Ingot",
		.Entire,
	}
	mc_items["raw_gold"] = Minecraft_Item{
		"raw_gold",
		"Raw Gold",
		.Entire,
	}
	mc_items["gold_ingot"] = Minecraft_Item{
		"gold_ingot",
		"Gold Ingot",
		.Entire,
	}
	mc_items["netherite_ingot"] = Minecraft_Item{
		"netherite_ingot",
		"Netherite Ingot",
		.Entire,
	}
	mc_items["netherite_scrap"] = Minecraft_Item{
		"netherite_scrap",
		"Netherite Scrap",
		.Entire,
	}
	mc_items["wooden_sword"] = Minecraft_Item{
		"wooden_sword",
		"Wooden Sword",
		.Single,
	}
	mc_items["wooden_shovel"] = Minecraft_Item{
		"wooden_shovel",
		"Wooden Shovel",
		.Single,
	}
	mc_items["wooden_pickaxe"] = Minecraft_Item{
		"wooden_pickaxe",
		"Wooden Pickaxe",
		.Single,
	}
	mc_items["wooden_axe"] = Minecraft_Item{
		"wooden_axe",
		"Wooden Axe",
		.Single,
	}
	mc_items["wooden_hoe"] = Minecraft_Item{
		"wooden_hoe",
		"Wooden Hoe",
		.Single,
	}
	mc_items["stone_sword"] = Minecraft_Item{
		"stone_sword",
		"Stone Sword",
		.Single,
	}
	mc_items["stone_shovel"] = Minecraft_Item{
		"stone_shovel",
		"Stone Shovel",
		.Single,
	}
	mc_items["stone_pickaxe"] = Minecraft_Item{
		"stone_pickaxe",
		"Stone Pickaxe",
		.Single,
	}
	mc_items["stone_axe"] = Minecraft_Item{
		"stone_axe",
		"Stone Axe",
		.Single,
	}
	mc_items["stone_hoe"] = Minecraft_Item{
		"stone_hoe",
		"Stone Hoe",
		.Single,
	}
	mc_items["golden_sword"] = Minecraft_Item{
		"golden_sword",
		"Golden Sword",
		.Single,
	}
	mc_items["golden_shovel"] = Minecraft_Item{
		"golden_shovel",
		"Golden Shovel",
		.Single,
	}
	mc_items["golden_pickaxe"] = Minecraft_Item{
		"golden_pickaxe",
		"Golden Pickaxe",
		.Single,
	}
	mc_items["golden_axe"] = Minecraft_Item{
		"golden_axe",
		"Golden Axe",
		.Single,
	}
	mc_items["golden_hoe"] = Minecraft_Item{
		"golden_hoe",
		"Golden Hoe",
		.Single,
	}
	mc_items["iron_sword"] = Minecraft_Item{
		"iron_sword",
		"Iron Sword",
		.Single,
	}
	mc_items["iron_shovel"] = Minecraft_Item{
		"iron_shovel",
		"Iron Shovel",
		.Single,
	}
	mc_items["iron_pickaxe"] = Minecraft_Item{
		"iron_pickaxe",
		"Iron Pickaxe",
		.Single,
	}
	mc_items["iron_axe"] = Minecraft_Item{
		"iron_axe",
		"Iron Axe",
		.Single,
	}
	mc_items["iron_hoe"] = Minecraft_Item{
		"iron_hoe",
		"Iron Hoe",
		.Single,
	}
	mc_items["diamond_sword"] = Minecraft_Item{
		"diamond_sword",
		"Diamond Sword",
		.Single,
	}
	mc_items["diamond_shovel"] = Minecraft_Item{
		"diamond_shovel",
		"Diamond Shovel",
		.Single,
	}
	mc_items["diamond_pickaxe"] = Minecraft_Item{
		"diamond_pickaxe",
		"Diamond Pickaxe",
		.Single,
	}
	mc_items["diamond_axe"] = Minecraft_Item{
		"diamond_axe",
		"Diamond Axe",
		.Single,
	}
	mc_items["diamond_hoe"] = Minecraft_Item{
		"diamond_hoe",
		"Diamond Hoe",
		.Single,
	}
	mc_items["netherite_sword"] = Minecraft_Item{
		"netherite_sword",
		"Netherite Sword",
		.Single,
	}
	mc_items["netherite_shovel"] = Minecraft_Item{
		"netherite_shovel",
		"Netherite Shovel",
		.Single,
	}
	mc_items["netherite_pickaxe"] = Minecraft_Item{
		"netherite_pickaxe",
		"Netherite Pickaxe",
		.Single,
	}
	mc_items["netherite_axe"] = Minecraft_Item{
		"netherite_axe",
		"Netherite Axe",
		.Single,
	}
	mc_items["netherite_hoe"] = Minecraft_Item{
		"netherite_hoe",
		"Netherite Hoe",
		.Single,
	}
	mc_items["stick"] = Minecraft_Item{
		"stick",
		"Stick",
		.Entire,
	}
	mc_items["mushroom_stew"] = Minecraft_Item{
		"mushroom_stew",
		"Mushroom Stew",
		.Single,
	}
	mc_items["string"] = Minecraft_Item{
		"string",
		"String",
		.Entire,
	}
	mc_items["feather"] = Minecraft_Item{
		"feather",
		"Feather",
		.Entire,
	}
	mc_items["gunpowder"] = Minecraft_Item{
		"gunpowder",
		"Gunpowder",
		.Entire,
	}
	mc_items["wheat_seeds"] = Minecraft_Item{
		"wheat_seeds",
		"Wheat Seeds",
		.Entire,
	}
	mc_items["wheat"] = Minecraft_Item{
		"wheat",
		"Wheat",
		.Entire,
	}
	mc_items["bread"] = Minecraft_Item{
		"bread",
		"Bread",
		.Entire,
	}
	mc_items["leather_helmet"] = Minecraft_Item{
		"leather_helmet",
		"Leather Cap",
		.Single,
	}
	mc_items["leather_chestplate"] = Minecraft_Item{
		"leather_chestplate",
		"Leather Tunic",
		.Single,
	}
	mc_items["leather_leggings"] = Minecraft_Item{
		"leather_leggings",
		"Leather Pants",
		.Single,
	}
	mc_items["leather_boots"] = Minecraft_Item{
		"leather_boots",
		"Leather Boots",
		.Single,
	}
	mc_items["chainmail_helmet"] = Minecraft_Item{
		"chainmail_helmet",
		"Chainmail Helmet",
		.Single,
	}
	mc_items["chainmail_chestplate"] = Minecraft_Item{
		"chainmail_chestplate",
		"Chainmail Chestplate",
		.Single,
	}
	mc_items["chainmail_leggings"] = Minecraft_Item{
		"chainmail_leggings",
		"Chainmail Leggings",
		.Single,
	}
	mc_items["chainmail_boots"] = Minecraft_Item{
		"chainmail_boots",
		"Chainmail Boots",
		.Single,
	}
	mc_items["iron_helmet"] = Minecraft_Item{
		"iron_helmet",
		"Iron Helmet",
		.Single,
	}
	mc_items["iron_chestplate"] = Minecraft_Item{
		"iron_chestplate",
		"Iron Chestplate",
		.Single,
	}
	mc_items["iron_leggings"] = Minecraft_Item{
		"iron_leggings",
		"Iron Leggings",
		.Single,
	}
	mc_items["iron_boots"] = Minecraft_Item{
		"iron_boots",
		"Iron Boots",
		.Single,
	}
	mc_items["diamond_helmet"] = Minecraft_Item{
		"diamond_helmet",
		"Diamond Helmet",
		.Single,
	}
	mc_items["diamond_chestplate"] = Minecraft_Item{
		"diamond_chestplate",
		"Diamond Chestplate",
		.Single,
	}
	mc_items["diamond_leggings"] = Minecraft_Item{
		"diamond_leggings",
		"Diamond Leggings",
		.Single,
	}
	mc_items["diamond_boots"] = Minecraft_Item{
		"diamond_boots",
		"Diamond Boots",
		.Single,
	}
	mc_items["golden_helmet"] = Minecraft_Item{
		"golden_helmet",
		"Golden Helmet",
		.Single,
	}
	mc_items["golden_chestplate"] = Minecraft_Item{
		"golden_chestplate",
		"Golden Chestplate",
		.Single,
	}
	mc_items["golden_leggings"] = Minecraft_Item{
		"golden_leggings",
		"Golden Leggings",
		.Single,
	}
	mc_items["golden_boots"] = Minecraft_Item{
		"golden_boots",
		"Golden Boots",
		.Single,
	}
	mc_items["netherite_helmet"] = Minecraft_Item{
		"netherite_helmet",
		"Netherite Helmet",
		.Single,
	}
	mc_items["netherite_chestplate"] = Minecraft_Item{
		"netherite_chestplate",
		"Netherite Chestplate",
		.Single,
	}
	mc_items["netherite_leggings"] = Minecraft_Item{
		"netherite_leggings",
		"Netherite Leggings",
		.Single,
	}
	mc_items["netherite_boots"] = Minecraft_Item{
		"netherite_boots",
		"Netherite Boots",
		.Single,
	}
	mc_items["flint"] = Minecraft_Item{
		"flint",
		"Flint",
		.Entire,
	}
	mc_items["porkchop"] = Minecraft_Item{
		"porkchop",
		"Raw Porkchop",
		.Entire,
	}
	mc_items["cooked_porkchop"] = Minecraft_Item{
		"cooked_porkchop",
		"Cooked Porkchop",
		.Entire,
	}
	mc_items["painting"] = Minecraft_Item{
		"painting",
		"Painting",
		.Entire,
	}
	mc_items["golden_apple"] = Minecraft_Item{
		"golden_apple",
		"Golden Apple",
		.Entire,
	}
	mc_items["enchanted_golden_apple"] = Minecraft_Item{
		"enchanted_golden_apple",
		"Enchanted Golden Apple",
		.Entire,
	}
	mc_items["oak_sign"] = Minecraft_Item{
		"oak_sign",
		"Oak Sign",
		.Quarter,
	}
	mc_items["spruce_sign"] = Minecraft_Item{
		"spruce_sign",
		"Spruce Sign",
		.Quarter,
	}
	mc_items["birch_sign"] = Minecraft_Item{
		"birch_sign",
		"Birch Sign",
		.Quarter,
	}
	mc_items["jungle_sign"] = Minecraft_Item{
		"jungle_sign",
		"Jungle Sign",
		.Quarter,
	}
	mc_items["acacia_sign"] = Minecraft_Item{
		"acacia_sign",
		"Acacia Sign",
		.Quarter,
	}
	mc_items["cherry_sign"] = Minecraft_Item{
		"cherry_sign",
		"Cherry Sign",
		.Quarter,
	}
	mc_items["dark_oak_sign"] = Minecraft_Item{
		"dark_oak_sign",
		"Dark Oak Sign",
		.Quarter,
	}
	mc_items["pale_oak_sign"] = Minecraft_Item{
		"pale_oak_sign",
		"Pale Oak Sign",
		.Quarter,
	}
	mc_items["mangrove_sign"] = Minecraft_Item{
		"mangrove_sign",
		"Mangrove Sign",
		.Quarter,
	}
	mc_items["bamboo_sign"] = Minecraft_Item{
		"bamboo_sign",
		"Bamboo Sign",
		.Quarter,
	}
	mc_items["crimson_sign"] = Minecraft_Item{
		"crimson_sign",
		"Crimson Sign",
		.Quarter,
	}
	mc_items["warped_sign"] = Minecraft_Item{
		"warped_sign",
		"Warped Sign",
		.Quarter,
	}
	mc_items["oak_hanging_sign"] = Minecraft_Item{
		"oak_hanging_sign",
		"Oak Hanging Sign",
		.Quarter,
	}
	mc_items["spruce_hanging_sign"] = Minecraft_Item{
		"spruce_hanging_sign",
		"Spruce Hanging Sign",
		.Quarter,
	}
	mc_items["birch_hanging_sign"] = Minecraft_Item{
		"birch_hanging_sign",
		"Birch Hanging Sign",
		.Quarter,
	}
	mc_items["jungle_hanging_sign"] = Minecraft_Item{
		"jungle_hanging_sign",
		"Jungle Hanging Sign",
		.Quarter,
	}
	mc_items["acacia_hanging_sign"] = Minecraft_Item{
		"acacia_hanging_sign",
		"Acacia Hanging Sign",
		.Quarter,
	}
	mc_items["cherry_hanging_sign"] = Minecraft_Item{
		"cherry_hanging_sign",
		"Cherry Hanging Sign",
		.Quarter,
	}
	mc_items["dark_oak_hanging_sign"] = Minecraft_Item{
		"dark_oak_hanging_sign",
		"Dark Oak Hanging Sign",
		.Quarter,
	}
	mc_items["pale_oak_hanging_sign"] = Minecraft_Item{
		"pale_oak_hanging_sign",
		"Pale Oak Hanging Sign",
		.Quarter,
	}
	mc_items["mangrove_hanging_sign"] = Minecraft_Item{
		"mangrove_hanging_sign",
		"Mangrove Hanging Sign",
		.Quarter,
	}
	mc_items["bamboo_hanging_sign"] = Minecraft_Item{
		"bamboo_hanging_sign",
		"Bamboo Hanging Sign",
		.Quarter,
	}
	mc_items["crimson_hanging_sign"] = Minecraft_Item{
		"crimson_hanging_sign",
		"Crimson Hanging Sign",
		.Quarter,
	}
	mc_items["warped_hanging_sign"] = Minecraft_Item{
		"warped_hanging_sign",
		"Warped Hanging Sign",
		.Quarter,
	}
	mc_items["bucket"] = Minecraft_Item{
		"bucket",
		"Bucket",
		.Quarter,
	}
	mc_items["water_bucket"] = Minecraft_Item{
		"water_bucket",
		"Water Bucket",
		.Single,
	}
	mc_items["lava_bucket"] = Minecraft_Item{
		"lava_bucket",
		"Lava Bucket",
		.Single,
	}
	mc_items["powder_snow_bucket"] = Minecraft_Item{
		"powder_snow_bucket",
		"Powder Snow Bucket",
		.Single,
	}
	mc_items["snowball"] = Minecraft_Item{
		"snowball",
		"Snowball",
		.Quarter,
	}
	mc_items["leather"] = Minecraft_Item{
		"leather",
		"Leather",
		.Entire,
	}
	mc_items["milk_bucket"] = Minecraft_Item{
		"milk_bucket",
		"Milk Bucket",
		.Single,
	}
	mc_items["pufferfish_bucket"] = Minecraft_Item{
		"pufferfish_bucket",
		"Bucket of Pufferfish",
		.Single,
	}
	mc_items["salmon_bucket"] = Minecraft_Item{
		"salmon_bucket",
		"Bucket of Salmon",
		.Single,
	}
	mc_items["cod_bucket"] = Minecraft_Item{
		"cod_bucket",
		"Bucket of Cod",
		.Single,
	}
	mc_items["tropical_fish_bucket"] = Minecraft_Item{
		"tropical_fish_bucket",
		"Bucket of Tropical Fish",
		.Single,
	}
	mc_items["axolotl_bucket"] = Minecraft_Item{
		"axolotl_bucket",
		"Bucket of Axolotl",
		.Single,
	}
	mc_items["tadpole_bucket"] = Minecraft_Item{
		"tadpole_bucket",
		"Bucket of Tadpole",
		.Single,
	}
	mc_items["brick"] = Minecraft_Item{
		"brick",
		"Brick",
		.Entire,
	}
	mc_items["clay_ball"] = Minecraft_Item{
		"clay_ball",
		"Clay Ball",
		.Entire,
	}
	mc_items["dried_kelp_block"] = Minecraft_Item{
		"dried_kelp_block",
		"Dried Kelp Block",
		.Entire,
	}
	mc_items["paper"] = Minecraft_Item{
		"paper",
		"Paper",
		.Entire,
	}
	mc_items["book"] = Minecraft_Item{
		"book",
		"Book",
		.Entire,
	}
	mc_items["slime_ball"] = Minecraft_Item{
		"slime_ball",
		"Slimeball",
		.Entire,
	}
	mc_items["egg"] = Minecraft_Item{
		"egg",
		"Egg",
		.Quarter,
	}
	mc_items["blue_egg"] = Minecraft_Item{
		"blue_egg",
		"Blue Egg",
		.Quarter,
	}
	mc_items["brown_egg"] = Minecraft_Item{
		"brown_egg",
		"Brown Egg",
		.Quarter,
	}
	mc_items["compass"] = Minecraft_Item{
		"compass",
		"Compass",
		.Entire,
	}
	mc_items["recovery_compass"] = Minecraft_Item{
		"recovery_compass",
		"Recovery Compass",
		.Entire,
	}
	mc_items["bundle"] = Minecraft_Item{
		"bundle",
		"Bundle",
		.Single,
	}
	mc_items["white_bundle"] = Minecraft_Item{
		"white_bundle",
		"White Bundle",
		.Single,
	}
	mc_items["orange_bundle"] = Minecraft_Item{
		"orange_bundle",
		"Orange Bundle",
		.Single,
	}
	mc_items["magenta_bundle"] = Minecraft_Item{
		"magenta_bundle",
		"Magenta Bundle",
		.Single,
	}
	mc_items["light_blue_bundle"] = Minecraft_Item{
		"light_blue_bundle",
		"Light Blue Bundle",
		.Single,
	}
	mc_items["yellow_bundle"] = Minecraft_Item{
		"yellow_bundle",
		"Yellow Bundle",
		.Single,
	}
	mc_items["lime_bundle"] = Minecraft_Item{
		"lime_bundle",
		"Lime Bundle",
		.Single,
	}
	mc_items["pink_bundle"] = Minecraft_Item{
		"pink_bundle",
		"Pink Bundle",
		.Single,
	}
	mc_items["gray_bundle"] = Minecraft_Item{
		"gray_bundle",
		"Gray Bundle",
		.Single,
	}
	mc_items["light_gray_bundle"] = Minecraft_Item{
		"light_gray_bundle",
		"Light Gray Bundle",
		.Single,
	}
	mc_items["cyan_bundle"] = Minecraft_Item{
		"cyan_bundle",
		"Cyan Bundle",
		.Single,
	}
	mc_items["purple_bundle"] = Minecraft_Item{
		"purple_bundle",
		"Purple Bundle",
		.Single,
	}
	mc_items["blue_bundle"] = Minecraft_Item{
		"blue_bundle",
		"Blue Bundle",
		.Single,
	}
	mc_items["brown_bundle"] = Minecraft_Item{
		"brown_bundle",
		"Brown Bundle",
		.Single,
	}
	mc_items["green_bundle"] = Minecraft_Item{
		"green_bundle",
		"Green Bundle",
		.Single,
	}
	mc_items["red_bundle"] = Minecraft_Item{
		"red_bundle",
		"Red Bundle",
		.Single,
	}
	mc_items["black_bundle"] = Minecraft_Item{
		"black_bundle",
		"Black Bundle",
		.Single,
	}
	mc_items["fishing_rod"] = Minecraft_Item{
		"fishing_rod",
		"Fishing Rod",
		.Single,
	}
	mc_items["clock"] = Minecraft_Item{
		"clock",
		"Clock",
		.Entire,
	}
	mc_items["spyglass"] = Minecraft_Item{
		"spyglass",
		"Spyglass",
		.Single,
	}
	mc_items["glowstone_dust"] = Minecraft_Item{
		"glowstone_dust",
		"Glowstone Dust",
		.Entire,
	}
	mc_items["cod"] = Minecraft_Item{
		"cod",
		"Raw Cod",
		.Entire,
	}
	mc_items["salmon"] = Minecraft_Item{
		"salmon",
		"Raw Salmon",
		.Entire,
	}
	mc_items["tropical_fish"] = Minecraft_Item{
		"tropical_fish",
		"Tropical Fish",
		.Entire,
	}
	mc_items["pufferfish"] = Minecraft_Item{
		"pufferfish",
		"Pufferfish",
		.Entire,
	}
	mc_items["cooked_cod"] = Minecraft_Item{
		"cooked_cod",
		"Cooked Cod",
		.Entire,
	}
	mc_items["cooked_salmon"] = Minecraft_Item{
		"cooked_salmon",
		"Cooked Salmon",
		.Entire,
	}
	mc_items["ink_sac"] = Minecraft_Item{
		"ink_sac",
		"Ink Sac",
		.Entire,
	}
	mc_items["glow_ink_sac"] = Minecraft_Item{
		"glow_ink_sac",
		"Glow Ink Sac",
		.Entire,
	}
	mc_items["cocoa_beans"] = Minecraft_Item{
		"cocoa_beans",
		"Cocoa Beans",
		.Entire,
	}
	mc_items["white_dye"] = Minecraft_Item{
		"white_dye",
		"White Dye",
		.Entire,
	}
	mc_items["orange_dye"] = Minecraft_Item{
		"orange_dye",
		"Orange Dye",
		.Entire,
	}
	mc_items["magenta_dye"] = Minecraft_Item{
		"magenta_dye",
		"Magenta Dye",
		.Entire,
	}
	mc_items["light_blue_dye"] = Minecraft_Item{
		"light_blue_dye",
		"Light Blue Dye",
		.Entire,
	}
	mc_items["yellow_dye"] = Minecraft_Item{
		"yellow_dye",
		"Yellow Dye",
		.Entire,
	}
	mc_items["lime_dye"] = Minecraft_Item{
		"lime_dye",
		"Lime Dye",
		.Entire,
	}
	mc_items["pink_dye"] = Minecraft_Item{
		"pink_dye",
		"Pink Dye",
		.Entire,
	}
	mc_items["gray_dye"] = Minecraft_Item{
		"gray_dye",
		"Gray Dye",
		.Entire,
	}
	mc_items["light_gray_dye"] = Minecraft_Item{
		"light_gray_dye",
		"Light Gray Dye",
		.Entire,
	}
	mc_items["cyan_dye"] = Minecraft_Item{
		"cyan_dye",
		"Cyan Dye",
		.Entire,
	}
	mc_items["purple_dye"] = Minecraft_Item{
		"purple_dye",
		"Purple Dye",
		.Entire,
	}
	mc_items["blue_dye"] = Minecraft_Item{
		"blue_dye",
		"Blue Dye",
		.Entire,
	}
	mc_items["brown_dye"] = Minecraft_Item{
		"brown_dye",
		"Brown Dye",
		.Entire,
	}
	mc_items["green_dye"] = Minecraft_Item{
		"green_dye",
		"Green Dye",
		.Entire,
	}
	mc_items["red_dye"] = Minecraft_Item{
		"red_dye",
		"Red Dye",
		.Entire,
	}
	mc_items["black_dye"] = Minecraft_Item{
		"black_dye",
		"Black Dye",
		.Entire,
	}
	mc_items["bone_meal"] = Minecraft_Item{
		"bone_meal",
		"Bone Meal",
		.Entire,
	}
	mc_items["bone"] = Minecraft_Item{
		"bone",
		"Bone",
		.Entire,
	}
	mc_items["sugar"] = Minecraft_Item{
		"sugar",
		"Sugar",
		.Entire,
	}
	mc_items["cake"] = Minecraft_Item{
		"cake",
		"Cake",
		.Single,
	}
	mc_items["white_bed"] = Minecraft_Item{
		"white_bed",
		"White Bed",
		.Single,
	}
	mc_items["orange_bed"] = Minecraft_Item{
		"orange_bed",
		"Orange Bed",
		.Single,
	}
	mc_items["magenta_bed"] = Minecraft_Item{
		"magenta_bed",
		"Magenta Bed",
		.Single,
	}
	mc_items["light_blue_bed"] = Minecraft_Item{
		"light_blue_bed",
		"Light Blue Bed",
		.Single,
	}
	mc_items["yellow_bed"] = Minecraft_Item{
		"yellow_bed",
		"Yellow Bed",
		.Single,
	}
	mc_items["lime_bed"] = Minecraft_Item{
		"lime_bed",
		"Lime Bed",
		.Single,
	}
	mc_items["pink_bed"] = Minecraft_Item{
		"pink_bed",
		"Pink Bed",
		.Single,
	}
	mc_items["gray_bed"] = Minecraft_Item{
		"gray_bed",
		"Gray Bed",
		.Single,
	}
	mc_items["light_gray_bed"] = Minecraft_Item{
		"light_gray_bed",
		"Light Gray Bed",
		.Single,
	}
	mc_items["cyan_bed"] = Minecraft_Item{
		"cyan_bed",
		"Cyan Bed",
		.Single,
	}
	mc_items["purple_bed"] = Minecraft_Item{
		"purple_bed",
		"Purple Bed",
		.Single,
	}
	mc_items["blue_bed"] = Minecraft_Item{
		"blue_bed",
		"Blue Bed",
		.Single,
	}
	mc_items["brown_bed"] = Minecraft_Item{
		"brown_bed",
		"Brown Bed",
		.Single,
	}
	mc_items["green_bed"] = Minecraft_Item{
		"green_bed",
		"Green Bed",
		.Single,
	}
	mc_items["red_bed"] = Minecraft_Item{
		"red_bed",
		"Red Bed",
		.Single,
	}
	mc_items["black_bed"] = Minecraft_Item{
		"black_bed",
		"Black Bed",
		.Single,
	}
	mc_items["cookie"] = Minecraft_Item{
		"cookie",
		"Cookie",
		.Entire,
	}
	mc_items["crafter"] = Minecraft_Item{
		"crafter",
		"Crafter",
		.Entire,
	}
	mc_items["filled_map"] = Minecraft_Item{
		"filled_map",
		"Map",
		.Entire,
	}
	mc_items["shears"] = Minecraft_Item{
		"shears",
		"Shears",
		.Single,
	}
	mc_items["melon_slice"] = Minecraft_Item{
		"melon_slice",
		"Melon Slice",
		.Entire,
	}
	mc_items["dried_kelp"] = Minecraft_Item{
		"dried_kelp",
		"Dried Kelp",
		.Entire,
	}
	mc_items["pumpkin_seeds"] = Minecraft_Item{
		"pumpkin_seeds",
		"Pumpkin Seeds",
		.Entire,
	}
	mc_items["melon_seeds"] = Minecraft_Item{
		"melon_seeds",
		"Melon Seeds",
		.Entire,
	}
	mc_items["beef"] = Minecraft_Item{
		"beef",
		"Raw Beef",
		.Entire,
	}
	mc_items["cooked_beef"] = Minecraft_Item{
		"cooked_beef",
		"Steak",
		.Entire,
	}
	mc_items["chicken"] = Minecraft_Item{
		"chicken",
		"Raw Chicken",
		.Entire,
	}
	mc_items["cooked_chicken"] = Minecraft_Item{
		"cooked_chicken",
		"Cooked Chicken",
		.Entire,
	}
	mc_items["rotten_flesh"] = Minecraft_Item{
		"rotten_flesh",
		"Rotten Flesh",
		.Entire,
	}
	mc_items["ender_pearl"] = Minecraft_Item{
		"ender_pearl",
		"Ender Pearl",
		.Quarter,
	}
	mc_items["blaze_rod"] = Minecraft_Item{
		"blaze_rod",
		"Blaze Rod",
		.Entire,
	}
	mc_items["ghast_tear"] = Minecraft_Item{
		"ghast_tear",
		"Ghast Tear",
		.Entire,
	}
	mc_items["gold_nugget"] = Minecraft_Item{
		"gold_nugget",
		"Gold Nugget",
		.Entire,
	}
	mc_items["nether_wart"] = Minecraft_Item{
		"nether_wart",
		"Nether Wart",
		.Entire,
	}
	mc_items["glass_bottle"] = Minecraft_Item{
		"glass_bottle",
		"Glass Bottle",
		.Entire,
	}
	mc_items["potion"] = Minecraft_Item{
		"potion",
		"Potion",
		.Single,
	}
	mc_items["spider_eye"] = Minecraft_Item{
		"spider_eye",
		"Spider Eye",
		.Entire,
	}
	mc_items["fermented_spider_eye"] = Minecraft_Item{
		"fermented_spider_eye",
		"Fermented Spider Eye",
		.Entire,
	}
	mc_items["blaze_powder"] = Minecraft_Item{
		"blaze_powder",
		"Blaze Powder",
		.Entire,
	}
	mc_items["magma_cream"] = Minecraft_Item{
		"magma_cream",
		"Magma Cream",
		.Entire,
	}
	mc_items["brewing_stand"] = Minecraft_Item{
		"brewing_stand",
		"Brewing Stand",
		.Entire,
	}
	mc_items["cauldron"] = Minecraft_Item{
		"cauldron",
		"Cauldron",
		.Entire,
	}
	mc_items["ender_eye"] = Minecraft_Item{
		"ender_eye",
		"Eye of Ender",
		.Entire,
	}
	mc_items["glistering_melon_slice"] = Minecraft_Item{
		"glistering_melon_slice",
		"Glistering Melon Slice",
		.Entire,
	}
	mc_items["armadillo_spawn_egg"] = Minecraft_Item{
		"armadillo_spawn_egg",
		"Armadillo Spawn Egg",
		.Entire,
	}
	mc_items["allay_spawn_egg"] = Minecraft_Item{
		"allay_spawn_egg",
		"Allay Spawn Egg",
		.Entire,
	}
	mc_items["axolotl_spawn_egg"] = Minecraft_Item{
		"axolotl_spawn_egg",
		"Axolotl Spawn Egg",
		.Entire,
	}
	mc_items["bat_spawn_egg"] = Minecraft_Item{
		"bat_spawn_egg",
		"Bat Spawn Egg",
		.Entire,
	}
	mc_items["bee_spawn_egg"] = Minecraft_Item{
		"bee_spawn_egg",
		"Bee Spawn Egg",
		.Entire,
	}
	mc_items["blaze_spawn_egg"] = Minecraft_Item{
		"blaze_spawn_egg",
		"Blaze Spawn Egg",
		.Entire,
	}
	mc_items["bogged_spawn_egg"] = Minecraft_Item{
		"bogged_spawn_egg",
		"Bogged Spawn Egg",
		.Entire,
	}
	mc_items["breeze_spawn_egg"] = Minecraft_Item{
		"breeze_spawn_egg",
		"Breeze Spawn Egg",
		.Entire,
	}
	mc_items["cat_spawn_egg"] = Minecraft_Item{
		"cat_spawn_egg",
		"Cat Spawn Egg",
		.Entire,
	}
	mc_items["camel_spawn_egg"] = Minecraft_Item{
		"camel_spawn_egg",
		"Camel Spawn Egg",
		.Entire,
	}
	mc_items["cave_spider_spawn_egg"] = Minecraft_Item{
		"cave_spider_spawn_egg",
		"Cave Spider Spawn Egg",
		.Entire,
	}
	mc_items["chicken_spawn_egg"] = Minecraft_Item{
		"chicken_spawn_egg",
		"Chicken Spawn Egg",
		.Entire,
	}
	mc_items["cod_spawn_egg"] = Minecraft_Item{
		"cod_spawn_egg",
		"Cod Spawn Egg",
		.Entire,
	}
	mc_items["cow_spawn_egg"] = Minecraft_Item{
		"cow_spawn_egg",
		"Cow Spawn Egg",
		.Entire,
	}
	mc_items["creeper_spawn_egg"] = Minecraft_Item{
		"creeper_spawn_egg",
		"Creeper Spawn Egg",
		.Entire,
	}
	mc_items["dolphin_spawn_egg"] = Minecraft_Item{
		"dolphin_spawn_egg",
		"Dolphin Spawn Egg",
		.Entire,
	}
	mc_items["donkey_spawn_egg"] = Minecraft_Item{
		"donkey_spawn_egg",
		"Donkey Spawn Egg",
		.Entire,
	}
	mc_items["drowned_spawn_egg"] = Minecraft_Item{
		"drowned_spawn_egg",
		"Drowned Spawn Egg",
		.Entire,
	}
	mc_items["elder_guardian_spawn_egg"] = Minecraft_Item{
		"elder_guardian_spawn_egg",
		"Elder Guardian Spawn Egg",
		.Entire,
	}
	mc_items["ender_dragon_spawn_egg"] = Minecraft_Item{
		"ender_dragon_spawn_egg",
		"Ender Dragon Spawn Egg",
		.Entire,
	}
	mc_items["enderman_spawn_egg"] = Minecraft_Item{
		"enderman_spawn_egg",
		"Enderman Spawn Egg",
		.Entire,
	}
	mc_items["endermite_spawn_egg"] = Minecraft_Item{
		"endermite_spawn_egg",
		"Endermite Spawn Egg",
		.Entire,
	}
	mc_items["evoker_spawn_egg"] = Minecraft_Item{
		"evoker_spawn_egg",
		"Evoker Spawn Egg",
		.Entire,
	}
	mc_items["fox_spawn_egg"] = Minecraft_Item{
		"fox_spawn_egg",
		"Fox Spawn Egg",
		.Entire,
	}
	mc_items["frog_spawn_egg"] = Minecraft_Item{
		"frog_spawn_egg",
		"Frog Spawn Egg",
		.Entire,
	}
	mc_items["ghast_spawn_egg"] = Minecraft_Item{
		"ghast_spawn_egg",
		"Ghast Spawn Egg",
		.Entire,
	}
	mc_items["happy_ghast_spawn_egg"] = Minecraft_Item{
		"happy_ghast_spawn_egg",
		"Happy Ghast Spawn Egg",
		.Entire,
	}
	mc_items["glow_squid_spawn_egg"] = Minecraft_Item{
		"glow_squid_spawn_egg",
		"Glow Squid Spawn Egg",
		.Entire,
	}
	mc_items["goat_spawn_egg"] = Minecraft_Item{
		"goat_spawn_egg",
		"Goat Spawn Egg",
		.Entire,
	}
	mc_items["guardian_spawn_egg"] = Minecraft_Item{
		"guardian_spawn_egg",
		"Guardian Spawn Egg",
		.Entire,
	}
	mc_items["hoglin_spawn_egg"] = Minecraft_Item{
		"hoglin_spawn_egg",
		"Hoglin Spawn Egg",
		.Entire,
	}
	mc_items["horse_spawn_egg"] = Minecraft_Item{
		"horse_spawn_egg",
		"Horse Spawn Egg",
		.Entire,
	}
	mc_items["husk_spawn_egg"] = Minecraft_Item{
		"husk_spawn_egg",
		"Husk Spawn Egg",
		.Entire,
	}
	mc_items["iron_golem_spawn_egg"] = Minecraft_Item{
		"iron_golem_spawn_egg",
		"Iron Golem Spawn Egg",
		.Entire,
	}
	mc_items["llama_spawn_egg"] = Minecraft_Item{
		"llama_spawn_egg",
		"Llama Spawn Egg",
		.Entire,
	}
	mc_items["magma_cube_spawn_egg"] = Minecraft_Item{
		"magma_cube_spawn_egg",
		"Magma Cube Spawn Egg",
		.Entire,
	}
	mc_items["mooshroom_spawn_egg"] = Minecraft_Item{
		"mooshroom_spawn_egg",
		"Mooshroom Spawn Egg",
		.Entire,
	}
	mc_items["mule_spawn_egg"] = Minecraft_Item{
		"mule_spawn_egg",
		"Mule Spawn Egg",
		.Entire,
	}
	mc_items["ocelot_spawn_egg"] = Minecraft_Item{
		"ocelot_spawn_egg",
		"Ocelot Spawn Egg",
		.Entire,
	}
	mc_items["panda_spawn_egg"] = Minecraft_Item{
		"panda_spawn_egg",
		"Panda Spawn Egg",
		.Entire,
	}
	mc_items["parrot_spawn_egg"] = Minecraft_Item{
		"parrot_spawn_egg",
		"Parrot Spawn Egg",
		.Entire,
	}
	mc_items["phantom_spawn_egg"] = Minecraft_Item{
		"phantom_spawn_egg",
		"Phantom Spawn Egg",
		.Entire,
	}
	mc_items["pig_spawn_egg"] = Minecraft_Item{
		"pig_spawn_egg",
		"Pig Spawn Egg",
		.Entire,
	}
	mc_items["piglin_spawn_egg"] = Minecraft_Item{
		"piglin_spawn_egg",
		"Piglin Spawn Egg",
		.Entire,
	}
	mc_items["piglin_brute_spawn_egg"] = Minecraft_Item{
		"piglin_brute_spawn_egg",
		"Piglin Brute Spawn Egg",
		.Entire,
	}
	mc_items["pillager_spawn_egg"] = Minecraft_Item{
		"pillager_spawn_egg",
		"Pillager Spawn Egg",
		.Entire,
	}
	mc_items["polar_bear_spawn_egg"] = Minecraft_Item{
		"polar_bear_spawn_egg",
		"Polar Bear Spawn Egg",
		.Entire,
	}
	mc_items["pufferfish_spawn_egg"] = Minecraft_Item{
		"pufferfish_spawn_egg",
		"Pufferfish Spawn Egg",
		.Entire,
	}
	mc_items["rabbit_spawn_egg"] = Minecraft_Item{
		"rabbit_spawn_egg",
		"Rabbit Spawn Egg",
		.Entire,
	}
	mc_items["ravager_spawn_egg"] = Minecraft_Item{
		"ravager_spawn_egg",
		"Ravager Spawn Egg",
		.Entire,
	}
	mc_items["salmon_spawn_egg"] = Minecraft_Item{
		"salmon_spawn_egg",
		"Salmon Spawn Egg",
		.Entire,
	}
	mc_items["sheep_spawn_egg"] = Minecraft_Item{
		"sheep_spawn_egg",
		"Sheep Spawn Egg",
		.Entire,
	}
	mc_items["shulker_spawn_egg"] = Minecraft_Item{
		"shulker_spawn_egg",
		"Shulker Spawn Egg",
		.Entire,
	}
	mc_items["silverfish_spawn_egg"] = Minecraft_Item{
		"silverfish_spawn_egg",
		"Silverfish Spawn Egg",
		.Entire,
	}
	mc_items["skeleton_spawn_egg"] = Minecraft_Item{
		"skeleton_spawn_egg",
		"Skeleton Spawn Egg",
		.Entire,
	}
	mc_items["skeleton_horse_spawn_egg"] = Minecraft_Item{
		"skeleton_horse_spawn_egg",
		"Skeleton Horse Spawn Egg",
		.Entire,
	}
	mc_items["slime_spawn_egg"] = Minecraft_Item{
		"slime_spawn_egg",
		"Slime Spawn Egg",
		.Entire,
	}
	mc_items["sniffer_spawn_egg"] = Minecraft_Item{
		"sniffer_spawn_egg",
		"Sniffer Spawn Egg",
		.Entire,
	}
	mc_items["snow_golem_spawn_egg"] = Minecraft_Item{
		"snow_golem_spawn_egg",
		"Snow Golem Spawn Egg",
		.Entire,
	}
	mc_items["spider_spawn_egg"] = Minecraft_Item{
		"spider_spawn_egg",
		"Spider Spawn Egg",
		.Entire,
	}
	mc_items["squid_spawn_egg"] = Minecraft_Item{
		"squid_spawn_egg",
		"Squid Spawn Egg",
		.Entire,
	}
	mc_items["stray_spawn_egg"] = Minecraft_Item{
		"stray_spawn_egg",
		"Stray Spawn Egg",
		.Entire,
	}
	mc_items["strider_spawn_egg"] = Minecraft_Item{
		"strider_spawn_egg",
		"Strider Spawn Egg",
		.Entire,
	}
	mc_items["tadpole_spawn_egg"] = Minecraft_Item{
		"tadpole_spawn_egg",
		"Tadpole Spawn Egg",
		.Entire,
	}
	mc_items["trader_llama_spawn_egg"] = Minecraft_Item{
		"trader_llama_spawn_egg",
		"Trader Llama Spawn Egg",
		.Entire,
	}
	mc_items["tropical_fish_spawn_egg"] = Minecraft_Item{
		"tropical_fish_spawn_egg",
		"Tropical Fish Spawn Egg",
		.Entire,
	}
	mc_items["turtle_spawn_egg"] = Minecraft_Item{
		"turtle_spawn_egg",
		"Turtle Spawn Egg",
		.Entire,
	}
	mc_items["vex_spawn_egg"] = Minecraft_Item{
		"vex_spawn_egg",
		"Vex Spawn Egg",
		.Entire,
	}
	mc_items["villager_spawn_egg"] = Minecraft_Item{
		"villager_spawn_egg",
		"Villager Spawn Egg",
		.Entire,
	}
	mc_items["vindicator_spawn_egg"] = Minecraft_Item{
		"vindicator_spawn_egg",
		"Vindicator Spawn Egg",
		.Entire,
	}
	mc_items["wandering_trader_spawn_egg"] = Minecraft_Item{
		"wandering_trader_spawn_egg",
		"Wandering Trader Spawn Egg",
		.Entire,
	}
	mc_items["warden_spawn_egg"] = Minecraft_Item{
		"warden_spawn_egg",
		"Warden Spawn Egg",
		.Entire,
	}
	mc_items["witch_spawn_egg"] = Minecraft_Item{
		"witch_spawn_egg",
		"Witch Spawn Egg",
		.Entire,
	}
	mc_items["wither_spawn_egg"] = Minecraft_Item{
		"wither_spawn_egg",
		"Wither Spawn Egg",
		.Entire,
	}
	mc_items["wither_skeleton_spawn_egg"] = Minecraft_Item{
		"wither_skeleton_spawn_egg",
		"Wither Skeleton Spawn Egg",
		.Entire,
	}
	mc_items["wolf_spawn_egg"] = Minecraft_Item{
		"wolf_spawn_egg",
		"Wolf Spawn Egg",
		.Entire,
	}
	mc_items["zoglin_spawn_egg"] = Minecraft_Item{
		"zoglin_spawn_egg",
		"Zoglin Spawn Egg",
		.Entire,
	}
	mc_items["creaking_spawn_egg"] = Minecraft_Item{
		"creaking_spawn_egg",
		"Creaking Spawn Egg",
		.Entire,
	}
	mc_items["zombie_spawn_egg"] = Minecraft_Item{
		"zombie_spawn_egg",
		"Zombie Spawn Egg",
		.Entire,
	}
	mc_items["zombie_horse_spawn_egg"] = Minecraft_Item{
		"zombie_horse_spawn_egg",
		"Zombie Horse Spawn Egg",
		.Entire,
	}
	mc_items["zombie_villager_spawn_egg"] = Minecraft_Item{
		"zombie_villager_spawn_egg",
		"Zombie Villager Spawn Egg",
		.Entire,
	}
	mc_items["zombified_piglin_spawn_egg"] = Minecraft_Item{
		"zombified_piglin_spawn_egg",
		"Zombified Piglin Spawn Egg",
		.Entire,
	}
	mc_items["experience_bottle"] = Minecraft_Item{
		"experience_bottle",
		"Bottle o' Enchanting",
		.Entire,
	}
	mc_items["fire_charge"] = Minecraft_Item{
		"fire_charge",
		"Fire Charge",
		.Entire,
	}
	mc_items["wind_charge"] = Minecraft_Item{
		"wind_charge",
		"Wind Charge",
		.Entire,
	}
	mc_items["writable_book"] = Minecraft_Item{
		"writable_book",
		"Book and Quill",
		.Single,
	}
	mc_items["written_book"] = Minecraft_Item{
		"written_book",
		"Written Book",
		.Quarter,
	}
	mc_items["breeze_rod"] = Minecraft_Item{
		"breeze_rod",
		"Breeze Rod",
		.Entire,
	}
	mc_items["mace"] = Minecraft_Item{
		"mace",
		"Mace",
		.Single,
	}
	mc_items["item_frame"] = Minecraft_Item{
		"item_frame",
		"Item Frame",
		.Entire,
	}
	mc_items["glow_item_frame"] = Minecraft_Item{
		"glow_item_frame",
		"Glow Item Frame",
		.Entire,
	}
	mc_items["flower_pot"] = Minecraft_Item{
		"flower_pot",
		"Flower Pot",
		.Entire,
	}
	mc_items["carrot"] = Minecraft_Item{
		"carrot",
		"Carrot",
		.Entire,
	}
	mc_items["potato"] = Minecraft_Item{
		"potato",
		"Potato",
		.Entire,
	}
	mc_items["baked_potato"] = Minecraft_Item{
		"baked_potato",
		"Baked Potato",
		.Entire,
	}
	mc_items["poisonous_potato"] = Minecraft_Item{
		"poisonous_potato",
		"Poisonous Potato",
		.Entire,
	}
	mc_items["map"] = Minecraft_Item{
		"map",
		"Empty Map",
		.Entire,
	}
	mc_items["golden_carrot"] = Minecraft_Item{
		"golden_carrot",
		"Golden Carrot",
		.Entire,
	}
	mc_items["skeleton_skull"] = Minecraft_Item{
		"skeleton_skull",
		"Skeleton Skull",
		.Entire,
	}
	mc_items["wither_skeleton_skull"] = Minecraft_Item{
		"wither_skeleton_skull",
		"Wither Skeleton Skull",
		.Entire,
	}
	mc_items["player_head"] = Minecraft_Item{
		"player_head",
		"Player Head",
		.Entire,
	}
	mc_items["zombie_head"] = Minecraft_Item{
		"zombie_head",
		"Zombie Head",
		.Entire,
	}
	mc_items["creeper_head"] = Minecraft_Item{
		"creeper_head",
		"Creeper Head",
		.Entire,
	}
	mc_items["dragon_head"] = Minecraft_Item{
		"dragon_head",
		"Dragon Head",
		.Entire,
	}
	mc_items["piglin_head"] = Minecraft_Item{
		"piglin_head",
		"Piglin Head",
		.Entire,
	}
	mc_items["nether_star"] = Minecraft_Item{
		"nether_star",
		"Nether Star",
		.Entire,
	}
	mc_items["pumpkin_pie"] = Minecraft_Item{
		"pumpkin_pie",
		"Pumpkin Pie",
		.Entire,
	}
	mc_items["firework_rocket"] = Minecraft_Item{
		"firework_rocket",
		"Firework Rocket",
		.Entire,
	}
	mc_items["firework_star"] = Minecraft_Item{
		"firework_star",
		"Firework Star",
		.Entire,
	}
	mc_items["enchanted_book"] = Minecraft_Item{
		"enchanted_book",
		"Enchanted Book",
		.Single,
	}
	mc_items["nether_brick"] = Minecraft_Item{
		"nether_brick",
		"Nether Brick",
		.Entire,
	}
	mc_items["resin_brick"] = Minecraft_Item{
		"resin_brick",
		"Resin Brick",
		.Entire,
	}
	mc_items["prismarine_shard"] = Minecraft_Item{
		"prismarine_shard",
		"Prismarine Shard",
		.Entire,
	}
	mc_items["prismarine_crystals"] = Minecraft_Item{
		"prismarine_crystals",
		"Prismarine Crystals",
		.Entire,
	}
	mc_items["rabbit"] = Minecraft_Item{
		"rabbit",
		"Raw Rabbit",
		.Entire,
	}
	mc_items["cooked_rabbit"] = Minecraft_Item{
		"cooked_rabbit",
		"Cooked Rabbit",
		.Entire,
	}
	mc_items["rabbit_stew"] = Minecraft_Item{
		"rabbit_stew",
		"Rabbit Stew",
		.Single,
	}
	mc_items["rabbit_foot"] = Minecraft_Item{
		"rabbit_foot",
		"Rabbit's Foot",
		.Entire,
	}
	mc_items["rabbit_hide"] = Minecraft_Item{
		"rabbit_hide",
		"Rabbit Hide",
		.Entire,
	}
	mc_items["armor_stand"] = Minecraft_Item{
		"armor_stand",
		"Armor Stand",
		.Quarter,
	}
	mc_items["iron_horse_armor"] = Minecraft_Item{
		"iron_horse_armor",
		"Iron Horse Armor",
		.Single,
	}
	mc_items["golden_horse_armor"] = Minecraft_Item{
		"golden_horse_armor",
		"Golden Horse Armor",
		.Single,
	}
	mc_items["diamond_horse_armor"] = Minecraft_Item{
		"diamond_horse_armor",
		"Diamond Horse Armor",
		.Single,
	}
	mc_items["leather_horse_armor"] = Minecraft_Item{
		"leather_horse_armor",
		"Leather Horse Armor",
		.Single,
	}
	mc_items["lead"] = Minecraft_Item{
		"lead",
		"Lead",
		.Entire,
	}
	mc_items["name_tag"] = Minecraft_Item{
		"name_tag",
		"Name Tag",
		.Entire,
	}
	mc_items["command_block_minecart"] = Minecraft_Item{
		"command_block_minecart",
		"Minecart with Command Block",
		.Single,
	}
	mc_items["mutton"] = Minecraft_Item{
		"mutton",
		"Raw Mutton",
		.Entire,
	}
	mc_items["cooked_mutton"] = Minecraft_Item{
		"cooked_mutton",
		"Cooked Mutton",
		.Entire,
	}
	mc_items["white_banner"] = Minecraft_Item{
		"white_banner",
		"White Banner",
		.Quarter,
	}
	mc_items["orange_banner"] = Minecraft_Item{
		"orange_banner",
		"Orange Banner",
		.Quarter,
	}
	mc_items["magenta_banner"] = Minecraft_Item{
		"magenta_banner",
		"Magenta Banner",
		.Quarter,
	}
	mc_items["light_blue_banner"] = Minecraft_Item{
		"light_blue_banner",
		"Light Blue Banner",
		.Quarter,
	}
	mc_items["yellow_banner"] = Minecraft_Item{
		"yellow_banner",
		"Yellow Banner",
		.Quarter,
	}
	mc_items["lime_banner"] = Minecraft_Item{
		"lime_banner",
		"Lime Banner",
		.Quarter,
	}
	mc_items["pink_banner"] = Minecraft_Item{
		"pink_banner",
		"Pink Banner",
		.Quarter,
	}
	mc_items["gray_banner"] = Minecraft_Item{
		"gray_banner",
		"Gray Banner",
		.Quarter,
	}
	mc_items["light_gray_banner"] = Minecraft_Item{
		"light_gray_banner",
		"Light Gray Banner",
		.Quarter,
	}
	mc_items["cyan_banner"] = Minecraft_Item{
		"cyan_banner",
		"Cyan Banner",
		.Quarter,
	}
	mc_items["purple_banner"] = Minecraft_Item{
		"purple_banner",
		"Purple Banner",
		.Quarter,
	}
	mc_items["blue_banner"] = Minecraft_Item{
		"blue_banner",
		"Blue Banner",
		.Quarter,
	}
	mc_items["brown_banner"] = Minecraft_Item{
		"brown_banner",
		"Brown Banner",
		.Quarter,
	}
	mc_items["green_banner"] = Minecraft_Item{
		"green_banner",
		"Green Banner",
		.Quarter,
	}
	mc_items["red_banner"] = Minecraft_Item{
		"red_banner",
		"Red Banner",
		.Quarter,
	}
	mc_items["black_banner"] = Minecraft_Item{
		"black_banner",
		"Black Banner",
		.Quarter,
	}
	mc_items["end_crystal"] = Minecraft_Item{
		"end_crystal",
		"End Crystal",
		.Entire,
	}
	mc_items["chorus_fruit"] = Minecraft_Item{
		"chorus_fruit",
		"Chorus Fruit",
		.Entire,
	}
	mc_items["popped_chorus_fruit"] = Minecraft_Item{
		"popped_chorus_fruit",
		"Popped Chorus Fruit",
		.Entire,
	}
	mc_items["torchflower_seeds"] = Minecraft_Item{
		"torchflower_seeds",
		"Torchflower Seeds",
		.Entire,
	}
	mc_items["pitcher_pod"] = Minecraft_Item{
		"pitcher_pod",
		"Pitcher Pod",
		.Entire,
	}
	mc_items["beetroot"] = Minecraft_Item{
		"beetroot",
		"Beetroot",
		.Entire,
	}
	mc_items["beetroot_seeds"] = Minecraft_Item{
		"beetroot_seeds",
		"Beetroot Seeds",
		.Entire,
	}
	mc_items["beetroot_soup"] = Minecraft_Item{
		"beetroot_soup",
		"Beetroot Soup",
		.Single,
	}
	mc_items["dragon_breath"] = Minecraft_Item{
		"dragon_breath",
		"Dragon's Breath",
		.Entire,
	}
	mc_items["splash_potion"] = Minecraft_Item{
		"splash_potion",
		"Splash Potion",
		.Single,
	}
	mc_items["spectral_arrow"] = Minecraft_Item{
		"spectral_arrow",
		"Spectral Arrow",
		.Entire,
	}
	mc_items["tipped_arrow"] = Minecraft_Item{
		"tipped_arrow",
		"Tipped Arrow",
		.Entire,
	}
	mc_items["lingering_potion"] = Minecraft_Item{
		"lingering_potion",
		"Lingering Potion",
		.Single,
	}
	mc_items["shield"] = Minecraft_Item{
		"shield",
		"Shield",
		.Single,
	}
	mc_items["totem_of_undying"] = Minecraft_Item{
		"totem_of_undying",
		"Totem of Undying",
		.Single,
	}
	mc_items["shulker_shell"] = Minecraft_Item{
		"shulker_shell",
		"Shulker Shell",
		.Entire,
	}
	mc_items["iron_nugget"] = Minecraft_Item{
		"iron_nugget",
		"Iron Nugget",
		.Entire,
	}
	mc_items["knowledge_book"] = Minecraft_Item{
		"knowledge_book",
		"Knowledge Book",
		.Single,
	}
	mc_items["debug_stick"] = Minecraft_Item{
		"debug_stick",
		"Debug Stick",
		.Single,
	}
	mc_items["music_disc_13"] = Minecraft_Item{
		"music_disc_13",
		"Music Disc",
		.Single,
	}
	mc_items["music_disc_cat"] = Minecraft_Item{
		"music_disc_cat",
		"Music Disc",
		.Single,
	}
	mc_items["music_disc_blocks"] = Minecraft_Item{
		"music_disc_blocks",
		"Music Disc",
		.Single,
	}
	mc_items["music_disc_chirp"] = Minecraft_Item{
		"music_disc_chirp",
		"Music Disc",
		.Single,
	}
	mc_items["music_disc_creator"] = Minecraft_Item{
		"music_disc_creator",
		"Music Disc",
		.Single,
	}
	mc_items["music_disc_creator_music_box"] = Minecraft_Item{
		"music_disc_creator_music_box",
		"Music Disc",
		.Single,
	}
	mc_items["music_disc_far"] = Minecraft_Item{
		"music_disc_far",
		"Music Disc",
		.Single,
	}
	mc_items["music_disc_lava_chicken"] = Minecraft_Item{
		"music_disc_lava_chicken",
		"Music Disc",
		.Single,
	}
	mc_items["music_disc_mall"] = Minecraft_Item{
		"music_disc_mall",
		"Music Disc",
		.Single,
	}
	mc_items["music_disc_mellohi"] = Minecraft_Item{
		"music_disc_mellohi",
		"Music Disc",
		.Single,
	}
	mc_items["music_disc_stal"] = Minecraft_Item{
		"music_disc_stal",
		"Music Disc",
		.Single,
	}
	mc_items["music_disc_strad"] = Minecraft_Item{
		"music_disc_strad",
		"Music Disc",
		.Single,
	}
	mc_items["music_disc_ward"] = Minecraft_Item{
		"music_disc_ward",
		"Music Disc",
		.Single,
	}
	mc_items["music_disc_11"] = Minecraft_Item{
		"music_disc_11",
		"Music Disc",
		.Single,
	}
	mc_items["music_disc_wait"] = Minecraft_Item{
		"music_disc_wait",
		"Music Disc",
		.Single,
	}
	mc_items["music_disc_otherside"] = Minecraft_Item{
		"music_disc_otherside",
		"Music Disc",
		.Single,
	}
	mc_items["music_disc_relic"] = Minecraft_Item{
		"music_disc_relic",
		"Music Disc",
		.Single,
	}
	mc_items["music_disc_5"] = Minecraft_Item{
		"music_disc_5",
		"Music Disc",
		.Single,
	}
	mc_items["music_disc_pigstep"] = Minecraft_Item{
		"music_disc_pigstep",
		"Music Disc",
		.Single,
	}
	mc_items["music_disc_precipice"] = Minecraft_Item{
		"music_disc_precipice",
		"Music Disc",
		.Single,
	}
	mc_items["music_disc_tears"] = Minecraft_Item{
		"music_disc_tears",
		"Music Disc",
		.Single,
	}
	mc_items["disc_fragment_5"] = Minecraft_Item{
		"disc_fragment_5",
		"Disc Fragment",
		.Entire,
	}
	mc_items["trident"] = Minecraft_Item{
		"trident",
		"Trident",
		.Single,
	}
	mc_items["nautilus_shell"] = Minecraft_Item{
		"nautilus_shell",
		"Nautilus Shell",
		.Entire,
	}
	mc_items["heart_of_the_sea"] = Minecraft_Item{
		"heart_of_the_sea",
		"Heart of the Sea",
		.Entire,
	}
	mc_items["crossbow"] = Minecraft_Item{
		"crossbow",
		"Crossbow",
		.Single,
	}
	mc_items["suspicious_stew"] = Minecraft_Item{
		"suspicious_stew",
		"Suspicious Stew",
		.Single,
	}
	mc_items["loom"] = Minecraft_Item{
		"loom",
		"Loom",
		.Entire,
	}
	mc_items["flower_banner_pattern"] = Minecraft_Item{
		"flower_banner_pattern",
		"Flower Charge Banner Pattern",
		.Single,
	}
	mc_items["creeper_banner_pattern"] = Minecraft_Item{
		"creeper_banner_pattern",
		"Creeper Charge Banner Pattern",
		.Single,
	}
	mc_items["skull_banner_pattern"] = Minecraft_Item{
		"skull_banner_pattern",
		"Skull Charge Banner Pattern",
		.Single,
	}
	mc_items["mojang_banner_pattern"] = Minecraft_Item{
		"mojang_banner_pattern",
		"Thing Banner Pattern",
		.Single,
	}
	mc_items["globe_banner_pattern"] = Minecraft_Item{
		"globe_banner_pattern",
		"Globe Banner Pattern",
		.Single,
	}
	mc_items["piglin_banner_pattern"] = Minecraft_Item{
		"piglin_banner_pattern",
		"Snout Banner Pattern",
		.Single,
	}
	mc_items["flow_banner_pattern"] = Minecraft_Item{
		"flow_banner_pattern",
		"Flow Banner Pattern",
		.Single,
	}
	mc_items["guster_banner_pattern"] = Minecraft_Item{
		"guster_banner_pattern",
		"Guster Banner Pattern",
		.Single,
	}
	mc_items["field_masoned_banner_pattern"] = Minecraft_Item{
		"field_masoned_banner_pattern",
		"Field Masoned Banner Pattern",
		.Single,
	}
	mc_items["bordure_indented_banner_pattern"] = Minecraft_Item{
		"bordure_indented_banner_pattern",
		"Bordure Indented Banner Pattern",
		.Single,
	}
	mc_items["goat_horn"] = Minecraft_Item{
		"goat_horn",
		"Goat Horn",
		.Single,
	}
	mc_items["composter"] = Minecraft_Item{
		"composter",
		"Composter",
		.Entire,
	}
	mc_items["barrel"] = Minecraft_Item{
		"barrel",
		"Barrel",
		.Entire,
	}
	mc_items["smoker"] = Minecraft_Item{
		"smoker",
		"Smoker",
		.Entire,
	}
	mc_items["blast_furnace"] = Minecraft_Item{
		"blast_furnace",
		"Blast Furnace",
		.Entire,
	}
	mc_items["cartography_table"] = Minecraft_Item{
		"cartography_table",
		"Cartography Table",
		.Entire,
	}
	mc_items["fletching_table"] = Minecraft_Item{
		"fletching_table",
		"Fletching Table",
		.Entire,
	}
	mc_items["grindstone"] = Minecraft_Item{
		"grindstone",
		"Grindstone",
		.Entire,
	}
	mc_items["smithing_table"] = Minecraft_Item{
		"smithing_table",
		"Smithing Table",
		.Entire,
	}
	mc_items["stonecutter"] = Minecraft_Item{
		"stonecutter",
		"Stonecutter",
		.Entire,
	}
	mc_items["bell"] = Minecraft_Item{
		"bell",
		"Bell",
		.Entire,
	}
	mc_items["lantern"] = Minecraft_Item{
		"lantern",
		"Lantern",
		.Entire,
	}
	mc_items["soul_lantern"] = Minecraft_Item{
		"soul_lantern",
		"Soul Lantern",
		.Entire,
	}
	mc_items["sweet_berries"] = Minecraft_Item{
		"sweet_berries",
		"Sweet Berries",
		.Entire,
	}
	mc_items["glow_berries"] = Minecraft_Item{
		"glow_berries",
		"Glow Berries",
		.Entire,
	}
	mc_items["campfire"] = Minecraft_Item{
		"campfire",
		"Campfire",
		.Entire,
	}
	mc_items["soul_campfire"] = Minecraft_Item{
		"soul_campfire",
		"Soul Campfire",
		.Entire,
	}
	mc_items["shroomlight"] = Minecraft_Item{
		"shroomlight",
		"Shroomlight",
		.Entire,
	}
	mc_items["honeycomb"] = Minecraft_Item{
		"honeycomb",
		"Honeycomb",
		.Entire,
	}
	mc_items["bee_nest"] = Minecraft_Item{
		"bee_nest",
		"Bee Nest",
		.Entire,
	}
	mc_items["beehive"] = Minecraft_Item{
		"beehive",
		"Beehive",
		.Entire,
	}
	mc_items["honey_bottle"] = Minecraft_Item{
		"honey_bottle",
		"Honey Bottle",
		.Quarter,
	}
	mc_items["honeycomb_block"] = Minecraft_Item{
		"honeycomb_block",
		"Honeycomb Block",
		.Entire,
	}
	mc_items["lodestone"] = Minecraft_Item{
		"lodestone",
		"Lodestone",
		.Entire,
	}
	mc_items["crying_obsidian"] = Minecraft_Item{
		"crying_obsidian",
		"Crying Obsidian",
		.Entire,
	}
	mc_items["blackstone"] = Minecraft_Item{
		"blackstone",
		"Blackstone",
		.Entire,
	}
	mc_items["blackstone_slab"] = Minecraft_Item{
		"blackstone_slab",
		"Blackstone Slab",
		.Entire,
	}
	mc_items["blackstone_stairs"] = Minecraft_Item{
		"blackstone_stairs",
		"Blackstone Stairs",
		.Entire,
	}
	mc_items["gilded_blackstone"] = Minecraft_Item{
		"gilded_blackstone",
		"Gilded Blackstone",
		.Entire,
	}
	mc_items["polished_blackstone"] = Minecraft_Item{
		"polished_blackstone",
		"Polished Blackstone",
		.Entire,
	}
	mc_items["polished_blackstone_slab"] = Minecraft_Item{
		"polished_blackstone_slab",
		"Polished Blackstone Slab",
		.Entire,
	}
	mc_items["polished_blackstone_stairs"] = Minecraft_Item{
		"polished_blackstone_stairs",
		"Polished Blackstone Stairs",
		.Entire,
	}
	mc_items["chiseled_polished_blackstone"] = Minecraft_Item{
		"chiseled_polished_blackstone",
		"Chiseled Polished Blackstone",
		.Entire,
	}
	mc_items["polished_blackstone_bricks"] = Minecraft_Item{
		"polished_blackstone_bricks",
		"Polished Blackstone Bricks",
		.Entire,
	}
	mc_items["polished_blackstone_brick_slab"] = Minecraft_Item{
		"polished_blackstone_brick_slab",
		"Polished Blackstone Brick Slab",
		.Entire,
	}
	mc_items["polished_blackstone_brick_stairs"] = Minecraft_Item{
		"polished_blackstone_brick_stairs",
		"Polished Blackstone Brick Stairs",
		.Entire,
	}
	mc_items["cracked_polished_blackstone_bricks"] = Minecraft_Item{
		"cracked_polished_blackstone_bricks",
		"Cracked Polished Blackstone Bricks",
		.Entire,
	}
	mc_items["respawn_anchor"] = Minecraft_Item{
		"respawn_anchor",
		"Respawn Anchor",
		.Entire,
	}
	mc_items["candle"] = Minecraft_Item{
		"candle",
		"Candle",
		.Entire,
	}
	mc_items["white_candle"] = Minecraft_Item{
		"white_candle",
		"White Candle",
		.Entire,
	}
	mc_items["orange_candle"] = Minecraft_Item{
		"orange_candle",
		"Orange Candle",
		.Entire,
	}
	mc_items["magenta_candle"] = Minecraft_Item{
		"magenta_candle",
		"Magenta Candle",
		.Entire,
	}
	mc_items["light_blue_candle"] = Minecraft_Item{
		"light_blue_candle",
		"Light Blue Candle",
		.Entire,
	}
	mc_items["yellow_candle"] = Minecraft_Item{
		"yellow_candle",
		"Yellow Candle",
		.Entire,
	}
	mc_items["lime_candle"] = Minecraft_Item{
		"lime_candle",
		"Lime Candle",
		.Entire,
	}
	mc_items["pink_candle"] = Minecraft_Item{
		"pink_candle",
		"Pink Candle",
		.Entire,
	}
	mc_items["gray_candle"] = Minecraft_Item{
		"gray_candle",
		"Gray Candle",
		.Entire,
	}
	mc_items["light_gray_candle"] = Minecraft_Item{
		"light_gray_candle",
		"Light Gray Candle",
		.Entire,
	}
	mc_items["cyan_candle"] = Minecraft_Item{
		"cyan_candle",
		"Cyan Candle",
		.Entire,
	}
	mc_items["purple_candle"] = Minecraft_Item{
		"purple_candle",
		"Purple Candle",
		.Entire,
	}
	mc_items["blue_candle"] = Minecraft_Item{
		"blue_candle",
		"Blue Candle",
		.Entire,
	}
	mc_items["brown_candle"] = Minecraft_Item{
		"brown_candle",
		"Brown Candle",
		.Entire,
	}
	mc_items["green_candle"] = Minecraft_Item{
		"green_candle",
		"Green Candle",
		.Entire,
	}
	mc_items["red_candle"] = Minecraft_Item{
		"red_candle",
		"Red Candle",
		.Entire,
	}
	mc_items["black_candle"] = Minecraft_Item{
		"black_candle",
		"Black Candle",
		.Entire,
	}
	mc_items["small_amethyst_bud"] = Minecraft_Item{
		"small_amethyst_bud",
		"Small Amethyst Bud",
		.Entire,
	}
	mc_items["medium_amethyst_bud"] = Minecraft_Item{
		"medium_amethyst_bud",
		"Medium Amethyst Bud",
		.Entire,
	}
	mc_items["large_amethyst_bud"] = Minecraft_Item{
		"large_amethyst_bud",
		"Large Amethyst Bud",
		.Entire,
	}
	mc_items["amethyst_cluster"] = Minecraft_Item{
		"amethyst_cluster",
		"Amethyst Cluster",
		.Entire,
	}
	mc_items["pointed_dripstone"] = Minecraft_Item{
		"pointed_dripstone",
		"Pointed Dripstone",
		.Entire,
	}
	mc_items["ochre_froglight"] = Minecraft_Item{
		"ochre_froglight",
		"Ochre Froglight",
		.Entire,
	}
	mc_items["verdant_froglight"] = Minecraft_Item{
		"verdant_froglight",
		"Verdant Froglight",
		.Entire,
	}
	mc_items["pearlescent_froglight"] = Minecraft_Item{
		"pearlescent_froglight",
		"Pearlescent Froglight",
		.Entire,
	}
	mc_items["frogspawn"] = Minecraft_Item{
		"frogspawn",
		"Frogspawn",
		.Entire,
	}
	mc_items["echo_shard"] = Minecraft_Item{
		"echo_shard",
		"Echo Shard",
		.Entire,
	}
	mc_items["brush"] = Minecraft_Item{
		"brush",
		"Brush",
		.Single,
	}
	mc_items["netherite_upgrade_smithing_template"] = Minecraft_Item{
		"netherite_upgrade_smithing_template",
		"Netherite Upgrade",
		.Entire,
	}
	mc_items["sentry_armor_trim_smithing_template"] = Minecraft_Item{
		"sentry_armor_trim_smithing_template",
		"Sentry Armor Trim",
		.Entire,
	}
	mc_items["dune_armor_trim_smithing_template"] = Minecraft_Item{
		"dune_armor_trim_smithing_template",
		"Dune Armor Trim",
		.Entire,
	}
	mc_items["coast_armor_trim_smithing_template"] = Minecraft_Item{
		"coast_armor_trim_smithing_template",
		"Coast Armor Trim",
		.Entire,
	}
	mc_items["wild_armor_trim_smithing_template"] = Minecraft_Item{
		"wild_armor_trim_smithing_template",
		"Wild Armor Trim",
		.Entire,
	}
	mc_items["ward_armor_trim_smithing_template"] = Minecraft_Item{
		"ward_armor_trim_smithing_template",
		"Ward Armor Trim",
		.Entire,
	}
	mc_items["eye_armor_trim_smithing_template"] = Minecraft_Item{
		"eye_armor_trim_smithing_template",
		"Eye Armor Trim",
		.Entire,
	}
	mc_items["vex_armor_trim_smithing_template"] = Minecraft_Item{
		"vex_armor_trim_smithing_template",
		"Vex Armor Trim",
		.Entire,
	}
	mc_items["tide_armor_trim_smithing_template"] = Minecraft_Item{
		"tide_armor_trim_smithing_template",
		"Tide Armor Trim",
		.Entire,
	}
	mc_items["snout_armor_trim_smithing_template"] = Minecraft_Item{
		"snout_armor_trim_smithing_template",
		"Snout Armor Trim",
		.Entire,
	}
	mc_items["rib_armor_trim_smithing_template"] = Minecraft_Item{
		"rib_armor_trim_smithing_template",
		"Rib Armor Trim",
		.Entire,
	}
	mc_items["spire_armor_trim_smithing_template"] = Minecraft_Item{
		"spire_armor_trim_smithing_template",
		"Spire Armor Trim",
		.Entire,
	}
	mc_items["wayfinder_armor_trim_smithing_template"] = Minecraft_Item{
		"wayfinder_armor_trim_smithing_template",
		"Wayfinder Armor Trim",
		.Entire,
	}
	mc_items["shaper_armor_trim_smithing_template"] = Minecraft_Item{
		"shaper_armor_trim_smithing_template",
		"Shaper Armor Trim",
		.Entire,
	}
	mc_items["silence_armor_trim_smithing_template"] = Minecraft_Item{
		"silence_armor_trim_smithing_template",
		"Silence Armor Trim",
		.Entire,
	}
	mc_items["raiser_armor_trim_smithing_template"] = Minecraft_Item{
		"raiser_armor_trim_smithing_template",
		"Raiser Armor Trim",
		.Entire,
	}
	mc_items["host_armor_trim_smithing_template"] = Minecraft_Item{
		"host_armor_trim_smithing_template",
		"Host Armor Trim",
		.Entire,
	}
	mc_items["flow_armor_trim_smithing_template"] = Minecraft_Item{
		"flow_armor_trim_smithing_template",
		"Flow Armor Trim",
		.Entire,
	}
	mc_items["bolt_armor_trim_smithing_template"] = Minecraft_Item{
		"bolt_armor_trim_smithing_template",
		"Bolt Armor Trim",
		.Entire,
	}
	mc_items["angler_pottery_sherd"] = Minecraft_Item{
		"angler_pottery_sherd",
		"Angler Pottery Sherd",
		.Entire,
	}
	mc_items["archer_pottery_sherd"] = Minecraft_Item{
		"archer_pottery_sherd",
		"Archer Pottery Sherd",
		.Entire,
	}
	mc_items["arms_up_pottery_sherd"] = Minecraft_Item{
		"arms_up_pottery_sherd",
		"Arms Up Pottery Sherd",
		.Entire,
	}
	mc_items["blade_pottery_sherd"] = Minecraft_Item{
		"blade_pottery_sherd",
		"Blade Pottery Sherd",
		.Entire,
	}
	mc_items["brewer_pottery_sherd"] = Minecraft_Item{
		"brewer_pottery_sherd",
		"Brewer Pottery Sherd",
		.Entire,
	}
	mc_items["burn_pottery_sherd"] = Minecraft_Item{
		"burn_pottery_sherd",
		"Burn Pottery Sherd",
		.Entire,
	}
	mc_items["danger_pottery_sherd"] = Minecraft_Item{
		"danger_pottery_sherd",
		"Danger Pottery Sherd",
		.Entire,
	}
	mc_items["explorer_pottery_sherd"] = Minecraft_Item{
		"explorer_pottery_sherd",
		"Explorer Pottery Sherd",
		.Entire,
	}
	mc_items["flow_pottery_sherd"] = Minecraft_Item{
		"flow_pottery_sherd",
		"Flow Pottery Sherd",
		.Entire,
	}
	mc_items["friend_pottery_sherd"] = Minecraft_Item{
		"friend_pottery_sherd",
		"Friend Pottery Sherd",
		.Entire,
	}
	mc_items["guster_pottery_sherd"] = Minecraft_Item{
		"guster_pottery_sherd",
		"Guster Pottery Sherd",
		.Entire,
	}
	mc_items["heart_pottery_sherd"] = Minecraft_Item{
		"heart_pottery_sherd",
		"Heart Pottery Sherd",
		.Entire,
	}
	mc_items["heartbreak_pottery_sherd"] = Minecraft_Item{
		"heartbreak_pottery_sherd",
		"Heartbreak Pottery Sherd",
		.Entire,
	}
	mc_items["howl_pottery_sherd"] = Minecraft_Item{
		"howl_pottery_sherd",
		"Howl Pottery Sherd",
		.Entire,
	}
	mc_items["miner_pottery_sherd"] = Minecraft_Item{
		"miner_pottery_sherd",
		"Miner Pottery Sherd",
		.Entire,
	}
	mc_items["mourner_pottery_sherd"] = Minecraft_Item{
		"mourner_pottery_sherd",
		"Mourner Pottery Sherd",
		.Entire,
	}
	mc_items["plenty_pottery_sherd"] = Minecraft_Item{
		"plenty_pottery_sherd",
		"Plenty Pottery Sherd",
		.Entire,
	}
	mc_items["prize_pottery_sherd"] = Minecraft_Item{
		"prize_pottery_sherd",
		"Prize Pottery Sherd",
		.Entire,
	}
	mc_items["scrape_pottery_sherd"] = Minecraft_Item{
		"scrape_pottery_sherd",
		"Scrape Pottery Sherd",
		.Entire,
	}
	mc_items["sheaf_pottery_sherd"] = Minecraft_Item{
		"sheaf_pottery_sherd",
		"Sheaf Pottery Sherd",
		.Entire,
	}
	mc_items["shelter_pottery_sherd"] = Minecraft_Item{
		"shelter_pottery_sherd",
		"Shelter Pottery Sherd",
		.Entire,
	}
	mc_items["skull_pottery_sherd"] = Minecraft_Item{
		"skull_pottery_sherd",
		"Skull Pottery Sherd",
		.Entire,
	}
	mc_items["snort_pottery_sherd"] = Minecraft_Item{
		"snort_pottery_sherd",
		"Snort Pottery Sherd",
		.Entire,
	}
	mc_items["copper_grate"] = Minecraft_Item{
		"copper_grate",
		"Copper Grate",
		.Entire,
	}
	mc_items["exposed_copper_grate"] = Minecraft_Item{
		"exposed_copper_grate",
		"Exposed Copper Grate",
		.Entire,
	}
	mc_items["weathered_copper_grate"] = Minecraft_Item{
		"weathered_copper_grate",
		"Weathered Copper Grate",
		.Entire,
	}
	mc_items["oxidized_copper_grate"] = Minecraft_Item{
		"oxidized_copper_grate",
		"Oxidized Copper Grate",
		.Entire,
	}
	mc_items["waxed_copper_grate"] = Minecraft_Item{
		"waxed_copper_grate",
		"Waxed Copper Grate",
		.Entire,
	}
	mc_items["waxed_exposed_copper_grate"] = Minecraft_Item{
		"waxed_exposed_copper_grate",
		"Waxed Exposed Copper Grate",
		.Entire,
	}
	mc_items["waxed_weathered_copper_grate"] = Minecraft_Item{
		"waxed_weathered_copper_grate",
		"Waxed Weathered Copper Grate",
		.Entire,
	}
	mc_items["waxed_oxidized_copper_grate"] = Minecraft_Item{
		"waxed_oxidized_copper_grate",
		"Waxed Oxidized Copper Grate",
		.Entire,
	}
	mc_items["copper_bulb"] = Minecraft_Item{
		"copper_bulb",
		"Copper Bulb",
		.Entire,
	}
	mc_items["exposed_copper_bulb"] = Minecraft_Item{
		"exposed_copper_bulb",
		"Exposed Copper Bulb",
		.Entire,
	}
	mc_items["weathered_copper_bulb"] = Minecraft_Item{
		"weathered_copper_bulb",
		"Weathered Copper Bulb",
		.Entire,
	}
	mc_items["oxidized_copper_bulb"] = Minecraft_Item{
		"oxidized_copper_bulb",
		"Oxidized Copper Bulb",
		.Entire,
	}
	mc_items["waxed_copper_bulb"] = Minecraft_Item{
		"waxed_copper_bulb",
		"Waxed Copper Bulb",
		.Entire,
	}
	mc_items["waxed_exposed_copper_bulb"] = Minecraft_Item{
		"waxed_exposed_copper_bulb",
		"Waxed Exposed Copper Bulb",
		.Entire,
	}
	mc_items["waxed_weathered_copper_bulb"] = Minecraft_Item{
		"waxed_weathered_copper_bulb",
		"Waxed Weathered Copper Bulb",
		.Entire,
	}
	mc_items["waxed_oxidized_copper_bulb"] = Minecraft_Item{
		"waxed_oxidized_copper_bulb",
		"Waxed Oxidized Copper Bulb",
		.Entire,
	}
	mc_items["trial_spawner"] = Minecraft_Item{
		"trial_spawner",
		"Trial Spawner",
		.Entire,
	}
	mc_items["trial_key"] = Minecraft_Item{
		"trial_key",
		"Trial Key",
		.Entire,
	}
	mc_items["ominous_trial_key"] = Minecraft_Item{
		"ominous_trial_key",
		"Ominous Trial Key",
		.Entire,
	}
	mc_items["vault"] = Minecraft_Item{
		"vault",
		"Vault",
		.Entire,
	}
	mc_items["ominous_bottle"] = Minecraft_Item{
		"ominous_bottle",
		"Ominous Bottle",
		.Entire,
	}
}

@(fini)
cleanup_mc_items :: proc "contextless" () {
	context = runtime.default_context()
	delete(mc_items)
}

get_minecraft_item :: proc(item_name: string) -> (Minecraft_Item, bool) {
	return mc_items[item_name]
}
