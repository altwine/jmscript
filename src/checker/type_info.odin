package checker

import "core:fmt"

import "../ast"
import "../error"

Type_Kind :: enum {
	Invalid,
	Void,
	Any,
	Number,
	Text,
	Particle,
	Sound,
	Potion,
	Block,
	Item,
	Enum,
	GameValue,
	Location,
	Vector,
	LocalizedText,
	Boolean,
	Array,
	Dict,
	Function,
	Event,
}

Type_Info :: struct {
	kind:	  	 Type_Kind,
	return_t: 	 ^Type_Info,
	param_names: [dynamic]string,
	param_types: [dynamic]^Type_Info,
	metadata:    Metadata,
}

create_type_info :: proc(kind: Type_Kind, allocator := context.allocator) -> ^Type_Info {
	type_info := new(Type_Info, allocator)
	type_info.kind = kind
	type_info.metadata = make(Metadata, allocator)
	type_info.param_types = make([dynamic]^Type_Info, allocator)
	type_info.param_names = make([dynamic]string, allocator)
	return type_info
}

string_to_type_kind :: proc(c: ^Checker, type: string, origin: ^ast.Node) -> Type_Kind {
	switch type {
	case "any":        return .Any
	case "number":	   return .Number
	case "text":	   return .Text
	case "particle":   return .Particle
	case "sound":	   return .Sound
	case "potion":	   return .Potion
	case "block":	   return .Block
	case "item":	   return .Item
	case "enum":	   return .Enum
	case "game_value": return .GameValue
	case "location":   return .Location
	case "vec3":	   return .Vector
	case "loc_text":   return .LocalizedText
	case "bool":	   return .Boolean
	case "array":	   return .Array
	case "dict":	   return .Dict
	case "void", "":   return .Void

	case "vector", "vector3":
		error.add_error(c.ec, c.files[c.current_file_idx], fmt.tprintf("invalid type %s, maybe 'vec3'?", type), origin.pos, origin.end)

	case "int", "float":
		error.add_error(c.ec, c.files[c.current_file_idx], fmt.tprintf("invalid type %s, maybe 'number'?", type), origin.pos, origin.end)

	case "string":
		error.add_error(c.ec, c.files[c.current_file_idx], fmt.tprintf("invalid type %s, maybe 'text'?", type), origin.pos, origin.end)

	case "vector2", "vec2":
		error.add_error(c.ec, c.files[c.current_file_idx], fmt.tprintf("invalid type %s, two components vector isn't supported", type), origin.pos, origin.end)

	case "quat", "quaternion":
		error.add_error(c.ec, c.files[c.current_file_idx], fmt.tprintf("invalid type %s, quaternions isn't supported", type), origin.pos, origin.end)

	case "complex":
		error.add_error(c.ec, c.files[c.current_file_idx], fmt.tprintf("invalid type %s, complex numbers isn't supported", type), origin.pos, origin.end)
	}
	error.add_error(c.ec, c.files[c.current_file_idx], fmt.tprintf("invalid type: %s", type), origin.pos, origin.end)
	return .Invalid
}

type_kind_to_string :: proc(kind: Type_Kind) -> string {
	switch kind {
	case .Void:          return "void"
	case .Any:           return "any"
	case .Number:        return "number"
	case .Text:          return "text"
	case .Particle:	     return "particle"
	case .Sound:	     return "sound"
	case .Potion:        return "potion"
	case .Block:         return "block"
	case .Item:          return "item"
	case .Enum:          return "enum"
	case .GameValue:     return "game_value"
	case .Location:      return "location"
	case .Vector:        return "vec3"
	case .LocalizedText: return "loc_text"
	case .Boolean:	     return "bool"
	case .Array:         return "array"
	case .Dict:          return "dict"
	case .Function:      return "function"
	case .Event:         return "event"
	case .Invalid:       return "invalid"
	case:                return "invalid"
	}
}
