# Events
## Player joined
Executes code when a player enters the world.
```
event player_join() {
	// Your code here
}
```

## Player left
Executes code when a player exits the world.
```
event player_quit() {
	// Your code here
}
```

## Player rejoined (Cancellable)
Executes code when a player re-enters the world using /play.
```
event player_rejoin() {
	// Your code here
}
```

## Player sends a message (Cancellable)
Executes code when a player writes a message in chat.
```
event player_chat() {
	// Your code here
}
```

## Player interacts with world (Cancellable)
Runs code when a player interacts with the world.
```
event player_interact() {
	// Your code here
}
```
Additional information:
*	Works with left click, right click, pressure plate interactions, trip wires, etc.

## Player right clicks (Cancellable)
Executes code when a player right-clicks.
```
event player_right_click() {
	// Your code here
}
```

## Player left clicks (Cancellable)
Executes code when a player left-clicks.
```
event player_left_click() {
	// Your code here
}
```

## Player places a block (Cancellable)
Executes code when a player places a block.
```
event player_place_block() {
	// Your code here
}
```

## Player breaks a block (Cancellable)
Executes code when a player breaks a block.
```
event player_break_block() {
	// Your code here
}
```

## Player starts breaking a block (Cancellable)
Runs code when a player starts breaking a block.
```
event block_damage() {
	// Your code here
}
```

## Player stops breaking a block
Runs code when a player stops breaking a block.
```
event block_damage_abort() {
	// Your code here
}
```

## Player grows a tree (Cancellable)
Runs code when a player grows a tree or mushroom.
```
event player_structure_grow() {
	// Your code here
}
```

## Player gets info about a block (Cancellable)
Executes code when a player receives debug information about a block (f3 + i).
```
event player_query_block_info() {
	// Your code here
}
```
Additional information:
*	The event will not fire if the player is sneaking.

## Player swings hand (Cancellable)
Executes code when a player waves their right or left hand.
```
event player_arm_swing() {
	// Your code here
}
```

## Player right-clicks an entity (Cancellable)
Executes code when a player right-clicks on an entity.
```
event player_right_click_entity() {
	// Your code here
}
```

## Player right-clicks a player (Cancellable)
Executes code when a player right-clicks another player.
```
event player_right_click_player() {
	// Your code here
}
```

## Player gets an effect from a lingering potion (Cancellable)
Executes code when a player gets an effect from a lingering potion.
```
event player_imbue_potion_cloud() {
	// Your code here
}
```

## Player picks up a projectile (Cancellable)
Executes code when a player picks up a projectile.
```
event player_pickup_projectile() {
	// Your code here
}
```

## Player collects an experience orb (Cancellable)
Executes code when a player picks up an experience orb.
```
event player_pickup_experience() {
	// Your code here
}
```

## Player tames an entity (Cancellable)
Executes code when a player tames an entity.
```
event player_tame_entity() {
	// Your code here
}
```

## Player leashes an entity (Cancellable)
Executes code when a player puts a leash on an entity.
```
event player_leash_entity() {
	// Your code here
}
```

## Player start spectating entity (Cancellable)
Executes code, when a players in spectator mode starts spectating an entity.
```
event player_start_spectating_entity() {
	// Your code here
}
```

## Player stop spectating entity (Cancellable)
Executes code, when a players in spectator mode stops spectating an entity.
```
event player_stop_spectating_entity() {
	// Your code here
}
```

## Player gets info about an entity (Cancellable)
Runs code when a player receives debug information about an entity (f3 + i).
```
event player_query_entity_info() {
	// Your code here
}
```
Additional information:
*	The event will not fire if the player is sneaking.

## Player opens inventory (Cancellable)
Executes code when a player opens their inventory menu.
```
event player_open_inventory() {
	// Your code here
}
```

## Player clicks in an inventory (Cancellable)
Executes code when a player clicks in an inventory menu.
```
event player_click_inventory() {
	// Your code here
}
```

## Player drags item in an inventory (Cancellable)
Executes code when a player drags an item in an inventory.
```
event player_drag_inventory() {
	// Your code here
}
```

## Player clicks in their inventory (Cancellable)
Executes code when a player clicks in their own inventory.
```
event player_click_own_inventory() {
	// Your code here
}
```

## Player crafts an item (Cancellable)
Executes code when a player crafts an item.
```
event player_craft_item() {
	// Your code here
}
```

## Player closes an inventory
Executes code when a player closes inventory.
```
event player_close_inventory() {
	// Your code here
}
```

## Player swaps hands (Cancellable)
Executes code when a player swaps hands.
```
event player_swap_hands() {
	// Your code here
}
```

## Player changes hotbar slot (Cancellable)
Executes code when a player changes a hotbar slot.
```
event player_change_slot() {
	// Your code here
}
```

## Player pick item (Cancellable)
Executes when the player middle-clicks an item in an inventory.
```
event player_pick_item() {
	// Your code here
}
```
Additional information:
*	This event will not trigger if the player is in creative mode.

## Player extract furnace
Triggers when the player extracts items from a furnace
```
event player_furnace_extract() {
	// Your code here
}
```
Works with:
*	Furnaces
*	Blast furnaces
*	Smokers

## Player shoots (Cancellable)
Executes code when a player shoots a bow or crossbow.
```
event player_shot_bow() {
	// Your code here
}
```
Works with:
*	Bow
*	Crossbow

## Player launches a projectile (Cancellable)
Executes code when a player launches a projectile.
```
event player_launch_projectile() {
	// Your code here
}
```
Works with:
*	Eggs
*	Snowballs
*	Potions

## Player picks up an item (Cancellable)
Executes code when a player picks up an item.
```
event player_pickup_item() {
	// Your code here
}
```

## Player drops an item (Cancellable)
Executes code when a player drops an item.
```
event player_drop_item() {
	// Your code here
}
```

## Player consumes an item (Cancellable)
Runs code when a player eats or drinks an item.
```
event player_consume_item() {
	// Your code here
}
```
Works with:
*	Food
*	Potions
*	Milk

## Player breaks an item
Executes code when a player breaks an item.
```
event player_break_item() {
	// Your code here
}
```

## Player stops using item
Runs code when a player stops using an item.
```
event player_stop_using_item() {
	// Your code here
}
```

## Player edit a book (Cancellable)
Executes code when a player edits text or signs the book.
```
event player_edit_book() {
	// Your code here
}
```

## Player fishes (Cancellable)
Runs code when a player fishes something.
```
event player_fish() {
	// Your code here
}
```

## Player moves (Cancellable)
Executes code when a player moves.
```
event player_move() {
	// Your code here
}
```

## Player failed to move
Runs code when a player fails to move.
```
event player_fail_move() {
	// Your code here
}
```

## Player load crossbow (Cancellable)
Triggers when the player loads a crossbow.
```
event player_load_crossbow() {
	// Your code here
}
```
Works with:
*	Crossbow

## Player jumps (Cancellable)
Executes code when a player jumps.
```
event player_jump() {
	// Your code here
}
```

## Player starts sneaking (Cancellable)
Executes code when a player starts sneaking.
```
event player_sneak() {
	// Your code here
}
```

## Player stops sneaking (Cancellable)
Executes code when a player stops sneaking.
```
event player_unsneak() {
	// Your code here
}
```

## Player teleports (Cancellable)
Executes code when a player teleports.
```
event player_teleport() {
	// Your code here
}
```

## Player starts sprinting (Cancellable)
Executes code when a player starts running.
```
event player_start_sprint() {
	// Your code here
}
```

## Player stops sprinting (Cancellable)
Executes code when a player stops running.
```
event player_stop_sprint() {
	// Your code here
}
```

## Player starts flying (Cancellable)
Executes code when a player starts flying.
```
event player_start_flight() {
	// Your code here
}
```

## Player stops flying (Cancellable)
Executes code when a player stops flying.
```
event player_stop_flight() {
	// Your code here
}
```

## Player uses riptide (Cancellable)
Executes code when a player uses a trident with the riptide enchantment.
```
event player_riptide() {
	// Your code here
}
```

## Player dismounts (Cancellable)
Executes code when a player dismounts from a boat, a horse, or another entity.
```
event player_dismount() {
	// Your code here
}
```

## Player jumps while riding (Cancellable)
Executes code when a player performs a jump on horse, donkey or mule.
```
event player_horse_jump() {
	// Your code here
}
```

## Player jump while riding a vehicle
Executes code when a player presses jump button while sitting in a boat or a minecart.
```
event player_vehicle_jump() {
	// Your code here
}
```
Additional information:
*	Can be used to check if the jump button was pressed.

## Player move on vehicle
Executes code, when a player presses movement keys, while sitting in transport.
```
event player_vehicle_move() {
	// Your code here
}
```

## Player takes damage (Cancellable)
Runs code when a player takes damage.
```
event player_take_damage() {
	// Your code here
}
```

## Player damages another player (Cancellable)
Executes code when a player hurts another player.
```
event player_damage_player() {
	// Your code here
}
```

## Entity damages a player (Cancellable)
Executes code when the entity damages a player.
```
event entity_damage_player() {
	// Your code here
}
```

## Player damages an entity (Cancellable)
Executes code when a player damages an entity.
```
event player_damage_entity() {
	// Your code here
}
```

## Player gets ressurected (Cancellable)
Runs code when a player is resurrected by the totem of undying.
```
event player_resurrect() {
	// Your code here
}
```

## Player restores health (Cancellable)
Executes code when a player regenerates health in any way.
```
event player_heal() {
	// Your code here
}
```

## Player\'s hunger level changes (Cancellable)
Executes code when the player\'s hunger level changes.
```
event player_food_level_change() {
	// Your code here
}
```

## Player exhaustion (Cancellable)
Triggers when the player gains exhaustion.
```
event player_exhaustion() {
	// Your code here
}
```

## Player\'s projectile hits (Cancellable)
Executes code when a projectile launched by a player hits a block, a creature, or another player.
```
event player_projectile_hit() {
	// Your code here
}
```

## Player takes damage from a projectile (Cancellable)
Executes code when a projectile hits a player.
```
event projectile_damage_player() {
	// Your code here
}
```

## Player is about to damage an entity (Cancellable)
Executes code when a player is about to damage an entity. cancelling the event also cancels the attack sounds.
```
event player_pre_attack_entity() {
	// Your code here
}
```

## Guardian appears at player (Cancellable)
Triggers when an elder guardian curses a player.
```
event elder_guardian_appears_at_player() {
	// Your code here
}
```

## Player dies (Cancellable)
Executes code when a player dies.
```
event player_death() {
	// Your code here
}
```

## Player kills another player (Cancellable)
Executes code when a player kills another player.
```
event player_kill_player() {
	// Your code here
}
```

## Player kills a mob (Cancellable)
Executes code when a player kills a mob.
```
event player_kill_mob() {
	// Your code here
}
```

## Mob kills a player (Cancellable)
Executes code when a mob kills a player.
```
event mob_kill_player() {
	// Your code here
}
```

## Player respawns
Runs code when a player is respawned.
```
event player_respawn() {
	// Your code here
}
```
Additional information:
*	It is recommended to use the wait block before other code to work correctly.

## Entity spawns (Cancellable)
Executes code when a new entity spawns in the world.
```
event entity_spawn() {
	// Your code here
}
```

## Entity removed
Executes code when an entity is removed from the world.
```
event entity_removed_from_world() {
	// Your code here
}
```

## Mob damages another mob (Cancellable)
Runs code when a mob deals damage to another mob.
```
event entity_damage_entity() {
	// Your code here
}
```

## Mob kills another mob (Cancellable)
Runs code when a mob kills another mob.
```
event entity_kill_entity() {
	// Your code here
}
```

## Entity takes damage (Cancellable)
Runs code when an entity takes damage.
```
event entity_take_damage() {
	// Your code here
}
```

## Entity restores health (Cancellable)
Runs code when an entity regenerates health in any way.
```
event entity_heal() {
	// Your code here
}
```

## Entity gets ressurected (Cancellable)
Runs code when an entity is resurrected by a totem of undying.
```
event entity_resurrect() {
	// Your code here
}
```

## Entity dies (Cancellable)
Executes code when an entity dies.
```
event entity_death() {
	// Your code here
}
```

## Entity casts a spell (Cancellable)
Executes code when an entity performs a spell.
```
event entity_spell_cast() {
	// Your code here
}
```
Works with:
*	Evokers
*	Illusioners

## Enderman escapes (Cancellable)
Runs code when an enderman teleports to escape something.
```
event enderman_escape() {
	// Your code here
}
```

## Enderman gets angry (Cancellable)
Runs code when an enderman gets mad at a player.
```
event enderman_attack_player() {
	// Your code here
}
```

## Firework explodes (Cancellable)
Runs code when a firework explodes.
```
event firework_explode() {
	// Your code here
}
```

## Hanging entity breaks (Cancellable)
Runs code when a hanging entity breaks.
```
event hanging_break() {
	// Your code here
}
```
Works with:
*	Item frames
*	Paintings
*	Leashes

## Projectile launch (Cancellable)
Triggers when a projectile is launched.
```
event projectile_launch() {
	// Your code here
}
```

## Projectile damages an entity (Cancellable)
Executes code when a projectile damages an entity.
```
event projectile_damage_entity() {
	// Your code here
}
```

## Projectile kills an entity (Cancellable)
Executes code when a projectile kills an entity.
```
event projectile_kill_entity() {
	// Your code here
}
```

## Projectile hits a block (Cancellable)
Runs code when a projectile hits a block.
```
event projectile_hit() {
	// Your code here
}
```

## Projectile collides (Cancellable)
Runs code when a projectile collides with a block or entity.
```
event projective_collide() {
	// Your code here
}
```

## Entity drops an item (Cancellable)
Executes code when an entity drops an item.
```
event entity_drop_item() {
	// Your code here
}
```

## Entity pickups an item (Cancellable)
Executes code when an entity picks up an item.
```
event entity_pickup_item() {
	// Your code here
}
```

## Item disappears (Cancellable)
Runs code when an item disappears from the world 5 minutes after it was created.
```
event item_despawn() {
	// Your code here
}
```

## Vehicle damage (Cancellable)
Runs code when a vehicle takes damage.
```
event vehicle_take_damage() {
	// Your code here
}
```

## Block starts falling (Cancellable)
Runs code when a block affected by gravity becomes a falling block.
```
event block_fall() {
	// Your code here
}
```

## Entity interacts with the world (Cancellable)
Runs code when an entity interacts with the world.
```
event entity_interact() {
	// Your code here
}
```

## Dispenser shears a sheep (Cancellable)
Executes code when a dispenser cuts wool from a sheep.
```
event dispenser_shear_sheep() {
	// Your code here
}
```

## Sheep regrows wool (Cancellable)
Runs code when a sheep grows wool.
```
event sheep_regrow_wool() {
	// Your code here
}
```

## Witch throws a potion (Cancellable)
Runs code when the witch throws a potion.
```
event witch_throw_potion() {
	// Your code here
}
```

## Entity shot bow (Cancellable)
Triggers when an entity shoots a bow.
```
event entity_shot_bow() {
	// Your code here
}
```

## Entity load crossbow (Cancellable)
Triggers when an entity loads a crossbow.
```
event entity_load_crossbow() {
	// Your code here
}
```

## Piglin barter (Cancellable)
Triggers when a piglin barters.
```
event piglin_barter() {
	// Your code here
}
```

## Goat ram entity (Cancellable)
Triggers when a goat rams into an entity.
```
event goat_ram_entity() {
	// Your code here
}
```

## Entity transform (Cancellable)
Triggers when an entity transforms into another entity.
```
event entity_transform() {
	// Your code here
}
```

## World starts
Runs code when the world starts in game mode.
```
event world_start() {
	// Your code here
}
```

## World stops
Runs code when game mode stops in the world.
```
event world_stop() {
	// Your code here
}
```

## Time skips (Cancellable)
Runs code if a time skip occurs.
```
event time_skip() {
	// Your code here
}
```
Works with:
*	Sleep
*	Setting time in code

## Server responds
Runs code when the server responds to the web request.
```
event world_web_response() {
	// Your code here
}
```

## Block ignites
Runs code when a block is ignited.
```
event block_ignite() {
	// Your code here
}
```

## Block burns (Cancellable)
Runs code when a block burns.
```
event block_burn() {
	// Your code here
}
```

## Block fades (Cancellable)
Runs code when a block fades, such as when ice or snow melts, fire goes out, or coral dries out.
```
event block_fade() {
	// Your code here
}
```
Works with:
*	Snow
*	Ice
*	Fire
*	Corals
*	Turtle eggs
*	Grass

## TNT ingites (Cancellable)
Runs code when a block of tnt is ignited.
```
event tnt_prime() {
	// Your code here
}
```

## Block explodes (Cancellable)
Runs code when a block explodes.
```
event block_explode() {
	// Your code here
}
```

## Entity explodes (Cancellable)
Runs code when an entity explodes.
```
event entity_explode() {
	// Your code here
}
```

## Entity starts exploding (Cancellable)
Runs code when an entity starts to explode.
```
event entity_explosion() {
	// Your code here
}
```

## Piston extends (Cancellable)
Runs code when a piston extends a block.
```
event block_piston_extend() {
	// Your code here
}
```

## Piston retracts (Cancellable)
Runs code when a piston retracts a block.
```
event block_piston_retract() {
	// Your code here
}
```

## Leaves decay (Cancellable)
Runs code when leaves decay by time.
```
event leaves_decay() {
	// Your code here
}
```

## Tree grows (Cancellable)
Runs code when a tree or a mushroom grows.
```
event structure_grow() {
	// Your code here
}
```

## Block grows (Cancellable)
Runs code when a block grows.
```
event block_grow() {
	// Your code here
}
```
Works with:
*	Seeds
*	Pumpkins and watermelons
*	Turtle eggs

## Block moves (Cancellable)
Runs code when a block is moved.
```
event block_flow() {
	// Your code here
}
```
Works with:
*	Liquids
*	Dragon egg

## Block gets bonemealed (Cancellable)
Executes code when a block is bonemealed.
```
event block_fertilize() {
	// Your code here
}
```

## Redstone power changes
Runs code when power of a redstone dust changes.
```
event redstone_level_change() {
	// Your code here
}
```

## Brewing is completed (Cancellable)
Executes code when potions in a block are brewed.
```
event brew_complete() {
	// Your code here
}
```

## Block generates (Cancellable)
Runs code when a block is generated after block interactions.
```
event block_form() {
	// Your code here
}
```
Works with:
*	Snow
*	Ice
*	Generating cobblestone etc.
*	Concrete hardening

## Block spreads (Cancellable)
Executes code when a block spreads.
```
event block_spread() {
	// Your code here
}
```
Works with:
*	Mushrooms
*	Fire

## Block generated by an entity (Cancellable)
Runs code when a block is generated after blocks and entities interact.
```
event block_form_by_entity() {
	// Your code here
}
```
Works with:
*	Snow golems
*	Frost walker enchantment

## Portal created (Cancellable)
Runs code when a portal is created in the world.
```
event portal_create() {
	// Your code here
}
```

## Bell rings (Cancellable)
Runs code when a bell rings in the world.
```
event bell_ring() {
	// Your code here
}
```

## Entity rings a bell (Cancellable)
Runs code when an entity rings a bell.
```
event entity_bell_ring() {
	// Your code here
}
```

## Note block playing (Cancellable)
Runs code when a note block in the world plays a sound.
```
event note_play() {
	// Your code here
}
```

## Block dispenses an item (Cancellable)
Executes code when a block dispenses an item.
```
event dispenser_dispense_item() {
	// Your code here
}
```

## Dispenser puts armor on an entity (Cancellable)
Runs code when a dispenser equips an entity with armor.
```
event dispenser_equip_armor() {
	// Your code here
}
```

## Fluid level change (Cancellable)
Runs code when the water level in a block changes.
```
event fluid_level_change() {
	// Your code here
}
```

## Sponge absorbs water (Cancellable)
Executes code when a sponge absorbs water.
```
event sponge_absorb() {
	// Your code here
}
```

## Sculk bloom (Cancellable)
Triggers when a sculk blooms.
```
event sculk_bloom() {
	// Your code here
}
```

## Falling block lands (Cancellable)
Runs code when a falling block turns into a regular block.
```
event falling_block_land() {
	// Your code here
}
```

## Item moved into container (Cancellable)
Runs code when an item is moved into a container.
```
event item_moved_into_container() {
	// Your code here
}
```

## Hopper pickups item (Cancellable)
Runs code when the hopper picks up an item.
```
event hopper_pickup_item() {
	// Your code here
}
```
Additional information:
*	Use the victim target to select an item as an entity.

## Furnace end smelt (Cancellable)
Triggers when a furnace finishes smelting an item.
```
event furnace_smelt() {
	// Your code here
}
```
Works with:
*	Furnaces
*	Blast furnaces
*	Smokers

## Furnace start smelt
Triggers when a furnace starts smelting items.
```
event furnace_start_smelt() {
	// Your code here
}
```
Works with:
*	Furnaces
*	Blast furnaces
*	Smokers

## Furnace uses fuel (Cancellable)
Triggers when a furnace burns another object as fuel.
```
event furnace_burn() {
	// Your code here
}
```
Works with:
*	Furnaces
*	Blast furnaces
*	Smokers

## moisture_change (Cancellable)
...
```
event moisture_change() {
	// Your code here
}
```

## Close advancements
Triggers when the player closes the advancements tab.
```
event player_close_advancements_menu() {
	// Your code here
}
```

## player_custom_click
...
```
event player_custom_click() {
	// Your code here
}
```

## Player changes a sign (Cancellable)
Executes code when a player makes changes to a sign.
```
event player_sign_change() {
	// Your code here
}
```

## Open advancements (Cancellable)
Triggers when the player opens the advancements tab.
```
event player_open_advancements_tab() {
	// Your code here
}
```

## entity_combust (Cancellable)
...
```
event entity_combust() {
	// Your code here
}
```

## crafter_craft (Cancellable)
...
```
event crafter_craft() {
	// Your code here
}
```

## player_input_event
...
```
event player_input_event() {
	// Your code here
}
```

## Player change velocity vector (Cancellable)
Executes code when a player\'s velocity vector is updated.
```
event player_velocity() {
	// Your code here
}
```

## player_enchant_item (Cancellable)
...
```
event player_enchant_item() {
	// Your code here
}
```

## player_start_gliding (Cancellable)
...
```
event player_start_gliding() {
	// Your code here
}
```

## fishing_hook_state_change (Cancellable)
...
```
event fishing_hook_state_change() {
	// Your code here
}
```

## Items merge (Cancellable)
Executes code when nearby items combine into a single stack.
```
event item_merge() {
	// Your code here
}
```

## Player renames item
Executes code when a player renames an item using an anvil.
```
event player_anvil_rename_input() {
	// Your code here
}
```

## Entity teleports (Cancellable)
Executes code when an entity teleports or is teleported.
```
event entity_teleport() {
	// Your code here
}
```

## entity_equipment_changed
...
```
event entity_equipment_changed() {
	// Your code here
}
```

## player_ask_gamemode_change (Cancellable)
...
```
event player_ask_gamemode_change() {
	// Your code here
}
```

## player_stop_gliding (Cancellable)
...
```
event player_stop_gliding() {
	// Your code here
}
```

## Player mends item
Executes code when a player repairs an item using the \"mending\" enchantment.
```
event player_item_mend() {
	// Your code here
}
```

## player_item_group_cooldown (Cancellable)
...
```
event player_item_group_cooldown() {
	// Your code here
}
```

## player_pick_block (Cancellable)
...
```
event player_pick_block() {
	// Your code here
}
```

## Player take knockback (Cancellable)
Executes code when a player is knocked back.
```
event player_knockback() {
	// Your code here
}
```

## Player changes location (Cancellable)
Executes code when a player changes their location (including staying on the same block).
```
event player_location_change() {
	// Your code here
}
```

## player_pick_entity (Cancellable)
...
```
event player_pick_entity() {
	// Your code here
}
```

## Entity take knockback (Cancellable)
Executes code when an entity is knocked back.
```
event entity_knockback() {
	// Your code here
}
```

## Web request error
Triggers when a request responds with an error.
```
event world_web_exception() {
	// Your code here
}
```

## vault_change_state (Cancellable)
...
```
event vault_change_state() {
	// Your code here
}
```

## player_prepare_result (Cancellable)
...
```
event player_prepare_result() {
	// Your code here
}
```

## player_combust (Cancellable)
...
```
event player_combust() {
	// Your code here
}
```

## player_equipment_changed
...
```
event player_equipment_changed() {
	// Your code here
}
```

## entity_start_gliding (Cancellable)
...
```
event entity_start_gliding() {
	// Your code here
}
```

## entity_stop_gliding (Cancellable)
...
```
event entity_stop_gliding() {
	// Your code here
}
```

## player_prepare_item_enchant (Cancellable)
...
```
event player_prepare_item_enchant() {
	// Your code here
}
```

## Player rotates (Cancellable)
Executes code when the player rotates (changes their yaw or pitch).
```
event player_rotate() {
	// Your code here
}
```

## player_vault_change_state (Cancellable)
...
```
event player_vault_change_state() {
	// Your code here
}
```

## vault_display_item (Cancellable)
...
```
event vault_display_item() {
	// Your code here
}
```

## player_item_cooldown (Cancellable)
...
```
event player_item_cooldown() {
	// Your code here
}
```
