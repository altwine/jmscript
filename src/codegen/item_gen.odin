package codegen

import nbt "../../odin-nbt"

Minecraft_Item :: struct {
	data_ver: nbt.Int    `nbt:"DataVersion"`,
	id:       nbt.String `nbt:"id"`,
	count:    nbt.Int    `nbt:"count"`,
}

AIR_ITEM_NBT_BASE64 :: "AAAAAAAAAAA="

generate_item :: proc(id: string, count: int, allocator := context.allocator) -> (string, bool) #optional_ok {
	// NOTE: shortcut for air item
	if id == "minecraft:air" {
		return AIR_ITEM_NBT_BASE64, true
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
