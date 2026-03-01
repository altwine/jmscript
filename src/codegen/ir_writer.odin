package codegen

import "core:strings"
import "core:fmt"

handlers_to_string :: proc(jb: ^Json_Builder, handlers: [dynamic]^Handler) -> string {
	json_begin_object(jb)
	json_begin_array(jb, "handlers")
	for handler, handler_index in handlers {
		ir_write_handler(jb, handler, handler_index != len(handlers)-1)
	}
	json_end_array(jb, false)
	json_end_object(jb, false)
	return strings.to_string(jb.builder)
}

current_handler_pos := 0
ir_write_handler :: proc(jb: ^Json_Builder, handler: ^Handler, comma: bool) {
	json_begin_object(jb)
	switch handler.type {
	case "event":
		json_write_string(jb, "event", handler.event, true)
	case "function", "process":
		json_write_string(jb, "name", handler.name, true)
		json_begin_array(jb, "values")
		named_values_count := len(handler.values)
		for named_value, named_value_idx in handler.values {
			is_last_named_value := named_value_idx != named_values_count-1
			ir_write_named_value(jb, named_value, is_last_named_value)
		}
		json_end_array(jb, true)
	}
	json_write_string(jb, "type", handler.type, true)
	json_write_number(jb, "position", current_handler_pos, true)
	current_handler_pos += 1
	json_begin_array(jb, "operations")
	operations_count := len(handler.operations)
	for operation, operation_idx in handler.operations {
		is_last_operation := operation_idx != operations_count-1
		ir_write_operation(jb, operation, is_last_operation)
	}
	json_end_array(jb, false)
	json_end_object(jb, comma)
}

ir_write_operation :: proc(jb: ^Json_Builder, operation: ^Operation, comma: bool) {
	json_begin_object(jb)
	json_write_string(jb, "action", operation.action, true)
	if operation.selection.type != "" {
		json_begin_object(jb, "selection")
		json_write_string(jb, "type", operation.selection.type, false)
		json_end_object(jb, true)
	}
	if len(operation.operations) > 0 {
		json_begin_array(jb, "operations")
		ops_count := len(operation.operations)
		for op, op_index in operation.operations {
			is_last_operation := op_index != ops_count-1
			ir_write_operation(jb, op, is_last_operation)
		}
		json_end_array(jb, true)
	}
	json_begin_array(jb, "values")
	named_values_count := len(operation.values)
	for named_value, named_value_idx in operation.values {
		is_last_named_value := named_value_idx != named_values_count-1
		ir_write_named_value(jb, named_value, is_last_named_value)
	}
	json_end_array(jb, false)
	json_end_object(jb, comma)
}

ir_write_named_value :: proc(jb: ^Json_Builder, named_value: ^NamedValue, comma: bool) {
	json_begin_object(jb)
	json_write_string(jb, "name", named_value.name, true)
	ir_write_value(jb, named_value.value, false)
	json_end_object(jb, comma)
}

ir_write_value :: proc(jb: ^Json_Builder, value: Value, comma: bool, is_named := true) {
	if is_named {
		json_begin_object(jb, "value")
	} else {
		json_begin_object(jb)
	}
	switch typed_value in value {
	case ^NullValue:
		json_begin_object(jb)
		json_end_object(jb, false)
	case ^ArrayValue:
		json_write_string(jb, "type", "array", true)
		json_begin_array(jb, "values")
		values_count := len(typed_value.values)
		for v, value_idx in typed_value.values {
			is_last_value := value_idx == values_count-1
			ir_write_value(jb, v, !is_last_value, false)
		}
		json_end_array(jb, false)
	case ^ParameterValue:
		json_write_string(jb, "type", "parameter", true)
		json_write_string(jb, "type_key", typed_value.type_key, true)
		json_write_string(jb, "description", typed_value.description, true)
		json_write_string(jb, "name", typed_value.name, true)
		json_write_string(jb, "value_type", typed_value.value_type, true)
		json_write_string(jb, "is_required", typed_value.is_required, true)
		json_write_string(jb, "default_value", typed_value.default_value, true)
		json_write_number(jb, "slot", typed_value.slot, true)
		json_write_number(jb, "description_slot", typed_value.description_slot, false)
	case ^NumberValue:
		number_string := fmt.tprintf("%0.8f", typed_value.number)
		for strings.contains(number_string, ".") && strings.ends_with(number_string, "0") {
			number_string = number_string[:len(number_string)-1]
		}
		if strings.ends_with(number_string, ".") {
			number_string = number_string[:len(number_string)-1]
		}
		json_write_string(jb, "type", "number", true)
		json_write_string_unquoted(jb, "number", number_string, false)
	case ^TextValue:
		json_write_string(jb, "type", "text", true)
		json_write_string(jb, "text", typed_value.text, true)
		json_write_string(jb, "parsing", typed_value.parsing, false)
	case ^MapValue:
		json_write_string(jb, "type", "map", true)
		json_begin_object(jb, "values")
		keys_count := len(typed_value.keys)
		for k, key_idx in typed_value.keys {
			is_last_value := key_idx == keys_count-1
			json_write_string_unquoted(jb, k, "", false)
			ir_write_value(jb, typed_value.values[key_idx], !is_last_value, false)
		}
		json_end_object(jb, comma)
	case ^VariableValue:
		json_write_string(jb, "type", "variable", true)
		json_write_string(jb, "variable", typed_value.variable, true)
		json_write_string(jb, "scope", typed_value.scope, false)
	case ^EnumValue:
		json_write_string(jb, "type", "enum", true)
		json_write_string(jb, "enum", typed_value._enum, false)
	case ^LocationValue:
		json_write_string(jb, "type", "location", true)
		json_write_number(jb, "yaw", typed_value.yaw, true)
		json_write_number(jb, "pitch", typed_value.pitch, true)
		json_write_number(jb, "x", typed_value.x, true)
		json_write_number(jb, "y", typed_value.y, true)
		json_write_number(jb, "z", typed_value.z, false)
	case ^VectorValue:
		json_write_string(jb, "type", "vector", true)
		json_write_number(jb, "x", typed_value.x, true)
		json_write_number(jb, "y", typed_value.y, true)
		json_write_number(jb, "z", typed_value.z, false)
	case ^SoundValue:
		json_write_string(jb, "type", "sound", true)
		json_write_string(jb, "sound", typed_value.sound, true)
		json_write_string(jb, "source", typed_value.source, true)
		json_write_string(jb, "variation", typed_value.variation, true)
		json_write_number(jb, "volume", typed_value.volume, true)
		json_write_number(jb, "pitch", typed_value.pitch, false)
	case ^ParticleValue:
		json_write_string(jb, "type", "particle", true)
		json_write_string(jb, "particle_type", typed_value.particle_type, true)
		json_write_number(jb, "count", typed_value.count, true)
		json_write_number(jb, "size", typed_value.size, true)
		json_write_number(jb, "color", typed_value.color, true)
		json_write_number(jb, "first_spread", typed_value.first_spread, true)
		json_write_number(jb, "second_spread", typed_value.second_spread, true)
		json_write_number(jb, "x_motion", typed_value.x_motion, true)
		json_write_number(jb, "y_motion", typed_value.y_motion, true)
		json_write_number(jb, "z_motion", typed_value.z_motion, false)
	case ^ItemValue:
		json_write_string(jb, "type", "item", true)
		json_write_string(jb, "item", typed_value.item, false)
	case ^GameValue:
		json_write_string(jb, "type", "game_value", true)
		json_write_string(jb, "game_value", typed_value.game_value, true)
		json_write_string(jb, "selection", typed_value.selection, false)
	case ^PotionValue:
		json_write_string(jb, "type", "potion", true)
		json_write_string(jb, "potion", typed_value.potion, true)
		json_write_number(jb, "amplifier", typed_value.amplifier, true)
		json_write_number(jb, "duration", typed_value.duration, false)
	case ^BlockValue:
		json_write_string(jb, "type", "block", true)
		json_write_string(jb, "block", typed_value.block, false)
	case ^LocalizedTextValue:
		json_write_string(jb, "type", "localized_text", true)
		json_write_string(jb, "data", typed_value.data, false)
	}
	json_end_object(jb, comma)
}
