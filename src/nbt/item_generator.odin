package nbt

import "vendor:zlib"

import "core:compress/gzip"
import "core:encoding/base64"
import "core:c"
import "core:bytes"

write_i32_be :: proc(buf: ^bytes.Buffer, value: i32) {
	bytes.buffer_write_byte(buf, byte(value >> 24))
	bytes.buffer_write_byte(buf, byte(value >> 16))
	bytes.buffer_write_byte(buf, byte(value >> 8))
	bytes.buffer_write_byte(buf, byte(value))
}

write_u16_be :: proc(buf: ^bytes.Buffer, value: u16) {
	bytes.buffer_write_byte(buf, byte(value >> 8))
	bytes.buffer_write_byte(buf, byte(value))
}

write_u32_le :: proc(buf: ^bytes.Buffer, value: u32) {
	bytes.buffer_write_byte(buf, byte(value))
	bytes.buffer_write_byte(buf, byte(value >> 8))
	bytes.buffer_write_byte(buf, byte(value >> 16))
	bytes.buffer_write_byte(buf, byte(value >> 24))
}

create_nbt :: proc(data_version: i32, id: string, count: i32, allocator := context.allocator) -> []byte {
	context.allocator = allocator
	buf: bytes.Buffer
	bytes.buffer_init(&buf, []byte{})

	bytes.buffer_write_byte(&buf, TAG_Compound)
	write_u16_be(&buf, u16(0))

	bytes.buffer_write_byte(&buf, TAG_Int)
	write_u16_be(&buf, u16(len("DataVersion")))
	bytes.buffer_write_string(&buf, "DataVersion")
	write_i32_be(&buf, data_version)

	bytes.buffer_write_byte(&buf, TAG_String)
	write_u16_be(&buf, u16(len("id")))
	bytes.buffer_write_string(&buf, "id")
	write_u16_be(&buf, u16(len(id)))
	bytes.buffer_write_string(&buf, id)

	bytes.buffer_write_byte(&buf, TAG_Int)
	write_u16_be(&buf, u16(len("count")))
	bytes.buffer_write_string(&buf, "count")
	write_i32_be(&buf, count)

	bytes.buffer_write_byte(&buf, TAG_End)

	return bytes.buffer_to_bytes(&buf)
}

compress_gzip :: proc(data: []byte, level: i32 = 6, allocator := context.allocator) -> []byte {
	bound := zlib.compressBound(c.ulong(len(data)))
	dest := make([]byte, bound, allocator)

	dest_len := c.ulong(bound)
	result := zlib.compress2(&dest[0], &dest_len, &data[0], c.ulong(len(data)), level)

	if result != zlib.OK {
		delete(dest)
		return nil
	}

	compressed := dest[:dest_len]
	defer delete(dest)

	buf: bytes.Buffer
	bytes.buffer_init(&buf, []byte{})

	bytes.buffer_write_byte(&buf, 0x1f)  // ID1
	bytes.buffer_write_byte(&buf, 0x8b)  // ID2
	bytes.buffer_write_byte(&buf, 0x08)  // CM = deflate
	bytes.buffer_write_byte(&buf, 0x00)  // FLG
	write_u32_le(&buf, 0)                // MTIME = 0
	bytes.buffer_write_byte(&buf, level == 9 ? 0x02 : 0x04)  // XFL
	bytes.buffer_write_byte(&buf, cast(u8)gzip.OS.Unknown)

	if len(compressed) >= 2 && compressed[0] == 0x78 {
		for b in compressed[2:] {
			bytes.buffer_write_byte(&buf, b)
		}
	} else {
		for b in compressed {
			bytes.buffer_write_byte(&buf, b)
		}
	}

	crc := zlib.crc32(0, &data[0], u32(len(data)))
	write_u32_le(&buf, u32(crc))
	write_u32_le(&buf, u32(len(data)))

	return bytes.buffer_to_bytes(&buf)
}

generate_item :: proc(id: string, count: int, allocator := context.allocator) -> (string, bool) {
	nbt_data := create_nbt(4440, id, i32(count), allocator)

	gzip_compressed := compress_gzip(nbt_data, 6)
	defer if gzip_compressed != nil {
		delete(gzip_compressed)
	}

	if gzip_compressed != nil {
		encoded := base64.encode(gzip_compressed, allocator=allocator)
		return encoded, true
	}
	return "", false
}
