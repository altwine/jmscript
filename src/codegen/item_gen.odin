package codegen

import nbt "../../odin-nbt"

Minecraft_Item :: struct {
	data_ver: nbt.Int    `nbt:"DataVersion"`,
	id:       nbt.String `nbt:"id"`,
	count:    nbt.Int    `nbt:"count"`,
}

generate_item :: proc(id: string, count: int, allocator := context.allocator) -> (string, bool) #optional_ok {
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
