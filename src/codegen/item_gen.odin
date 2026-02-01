package codegen

import "core:fmt"
import "core:strings"

import "../../assets"
import nbt "../../odin-nbt"

Minecraft_Item :: struct {
	data_ver: nbt.Int    `nbt:"DataVersion"`,
	id:       nbt.String `nbt:"id"`,
	count:    nbt.Int    `nbt:"count"`,
}

AIR_ITEM_NBT_BASE64 :: "AAAAAAAAAAA="

generate_item :: proc(irb: ^IR_Builder, id: string, count: int, allocator := context.allocator) -> (string, bool) #optional_ok {
	id := id
	if !strings.starts_with(id, "minecraft:") {
		id = fmt.tprintf("minecraft:%s", id)
	}

	// NOTE: shortcut for air item
	if id == "minecraft:air" {
		return AIR_ITEM_NBT_BASE64, true
	}

	item_id := strings.trim_prefix(id, "minecraft:")
	if _, is_valid := assets.get_minecraft_item(item_id); !is_valid {
		ir_add_error(irb, fmt.tprintf("invalid item id: '%s'", item_id), nil)
		return AIR_ITEM_NBT_BASE64, false
	}

	w: nbt.Writer
	nbt.writer_init(&w, allocator)
	defer nbt.writer_destroy(&w)
	nbt.writer_write_compound(&w, Minecraft_Item{
		data_ver=4440,
		id=id,
		count=nbt.Int(count),
	})
	result_item := nbt.writer_to_base64(&w)
	return result_item, true
}
