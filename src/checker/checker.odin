package checker

import "core:mem"
import "core:slice"
import "core:strings"
import "core:fmt"

import "../ast"
import "../error"
import "../../assets"

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

string_to_type_kind :: proc(c: ^Checker, type: string, origin: ^ast.Node) -> Type_Kind {
	switch type {
	case "any":        return .Any
	case "number":     return .Number
	case "text":       return .Text
	case "particle":   return .Particle
	case "sound":      return .Sound
	case "potion":     return .Potion
	case "block":      return .Block
	case "item":       return .Item
	case "enum":       return .Enum
	case "game_value": return .GameValue
	case "location":   return .Location
	case "vec3":       return .Vector
	case "loc_text":   return .LocalizedText
	case "bool":       return .Boolean
	case "array":      return .Array
	case "dict":       return .Dict
	case "void", "":   return .Void

	case "vector", "vector3":
		add_error(c, fmt.tprintf("invalid type %s, maybe 'vec3'?", type), origin)

	case "int", "float":
		add_error(c, fmt.tprintf("invalid type %s, maybe 'number'?", type), origin)

	case "string":
		add_error(c, fmt.tprintf("invalid type %s, maybe 'text'?", type), origin)

	case "vector2", "vec2":
		add_error(c, fmt.tprintf("invalid type %s, two components vector isn't supported", type), origin)

	case "quat", "quaternion":
		add_error(c, fmt.tprintf("invalid type %s, quaternions isn't supported", type), origin)

	case "complex":
		add_error(c, fmt.tprintf("invalid type %s, complex numbers isn't supported", type), origin)
	}
	add_error(c, fmt.tprintf("invalid type: %s", type), origin)
	return .Invalid
}

type_kind_to_string :: proc(c: ^Checker, kind: Type_Kind) -> string {
	switch kind {
	case .Void:          return "void"
	case .Any:           return "any"
	case .Number:        return "number"
	case .Text:          return "text"
	case .Particle:      return "particle"
	case .Sound:         return "sound"
	case .Potion:        return "potion"
	case .Block:         return "block"
	case .Item:          return "item"
	case .Enum:          return "enum"
	case .GameValue:     return "game_value"
	case .Location:      return "location"
	case .Vector:        return "vec3"
	case .LocalizedText: return "loc_text"
	case .Boolean:       return "bool"
	case .Array:         return "array"
	case .Dict:          return "dict"
	case .Function:      return "function"
	case .Event:         return "event"
	case .Invalid:       return "invalid"
	}
	return "invalid"
}

Type_Info :: struct {
	kind:        Type_Kind,
	is_const:    bool,
	return_t:    ^Type_Info,
	param_names: [dynamic]string,
	param_types: [dynamic]^Type_Info,
}

Symbol :: struct {
	name:        string,
	type:        ^Type_Info,
	decl_node:   ^ast.Node,
}

Symbol_Table :: struct {
	global_scope:  ^Scope,
	current_scope: ^Scope,
	scope_level:   int,
}

Scope :: struct {
	symbols:  [dynamic]^Symbol,
	parent:   ^Scope,
	level:    int,
	children: [dynamic]^Scope,
}

Checker :: struct {
	alloc:        mem.Allocator,
	symbol_table: ^Symbol_Table,
	files:        [dynamic]^ast.File,
	errs:         [dynamic]error.Error,
	current_file: ^ast.File,
	current_file_idx: int,
}

checker_init :: proc(c: ^Checker, allocator := context.allocator) {
	c.alloc = allocator
	c.errs = make([dynamic]error.Error, allocator)
	c.symbol_table = new(Symbol_Table, allocator)
	c.symbol_table.scope_level = -1
}

checker_check :: proc(c: ^Checker, files: [dynamic]^ast.File) -> (^Symbol_Table, [dynamic]error.Error) {
	c.files = files
	enter_scope(c)
	add_builtin_functions(c)
	add_native_functions(c)
	c.current_file_idx = 0
	for file in files {
		c.current_file = file
		for decl in file.decls {
			collect_handler(c, decl)
		}
		c.current_file_idx += 1
	}
	c.current_file_idx = 0
	for file in files {
		c.current_file = file
		for decl in file.decls {
			collect_stmt(c, decl)
		}
		c.current_file_idx += 1
	}
	exit_scope(c)

	// for sym_name, sym_data in c.symbol_table.global_scope.symbols {
	// 	fmt.printfln("[global] %s: %v", sym_name, sym_data.type)
	// }
	// for scope in c.symbol_table.global_scope.children {
	// 	for sym_name, sym_data in scope.symbols {
	// 		fmt.printfln("[local] %s: %v", sym_name, sym_data.type)
	// 	}
	// }

	return c.symbol_table, c.errs
}

collect_handler :: proc(c: ^Checker, stmt: ^ast.Stmt) {
	#partial switch typed_stmt in stmt.derived {
	case ^ast.Event_Stmt:
		symbol := make_symbol(c, typed_stmt.name, make_type_event(c), stmt)
		add_symbol(c, symbol)
		enter_scope(c)
		for param in typed_stmt.params.list {
			param_name := param.name
			param_type := param.type
			type_info := new(Type_Info, c.alloc)
			type_info.kind = string_to_type_kind(c, param_type, param)
			param_sym := make_symbol(c, param_name, type_info, stmt)
			add_symbol(c, param_sym)
			append(&symbol.type.param_names, param_sym.name)
			append(&symbol.type.param_types, type_info)
		}
		for item in typed_stmt.body.stmts {
			collect_stmt(c, item)
		}
		exit_scope(c)

	case ^ast.Func_Stmt:
		ret_type_kind := string_to_type_kind(c, typed_stmt.result, typed_stmt)
		ret_type := new(Type_Info, c.alloc)
		ret_type.kind = ret_type_kind
		symbol := make_symbol(c, typed_stmt.name, make_type_func(c, ret_type), stmt)
		add_symbol(c, symbol)
		enter_scope(c)
		for param in typed_stmt.params.list {
			param_name := param.name
			param_type := param.type
			type_info := new(Type_Info, c.alloc)
			type_info.kind = string_to_type_kind(c, param_type, param)
			param_sym := make_symbol(c, param_name, type_info, stmt)
			add_symbol(c, param_sym)
			append(&symbol.type.param_names, param_sym.name)
			append(&symbol.type.param_types, type_info)
		}
		for item in typed_stmt.body.stmts {
			collect_stmt(c, item)
		}
		exit_scope(c)

	case ^ast.Value_Decl:
		_, is_already_defined := lookup_symbol(c.symbol_table.current_scope, typed_stmt.name)
		if is_already_defined {
			add_error(c, fmt.tprintf("variable '%s' is already defined", typed_stmt.name), typed_stmt)
			break
		}

		type_info := get_type_info_from_expression(c, typed_stmt.value)
		type_info.is_const = typed_stmt.is_const
		if type_info.kind != .Any && typed_stmt.type != "" {
			provided_type_kind := string_to_type_kind(c, typed_stmt.type, typed_stmt)
			if type_info.kind != provided_type_kind {
				add_error(c, fmt.tprintf("exlicitly stated type don't match variable content: '%s' != '%s'", type_kind_to_string(c, type_info.kind), type_kind_to_string(c, provided_type_kind)), typed_stmt)
			}
		}
		symbol := make_symbol(c, typed_stmt.name, type_info, stmt)
		add_symbol(c, symbol)

	case ^ast.Defer_Stmt:
		add_error(c, "top level defers isn't allowed", typed_stmt)
	}
}

collect_stmt :: proc(c: ^Checker, stmt: ^ast.Stmt) {
	#partial switch typed_stmt in stmt.derived {
	case ^ast.Block_Stmt:
		enter_scope(c)
		for body_stmt in typed_stmt.stmts {
			collect_stmt(c, body_stmt)
		}
		exit_scope(c)

	case ^ast.Assign_Stmt:
		sym, is_exist := lookup_symbol(c.symbol_table.current_scope, typed_stmt.name)
		if !is_exist {
			add_error(c, fmt.tprintf("variable '%s' is not declared", typed_stmt.name), typed_stmt)
		}
		if sym.type.is_const {
			add_error(c, fmt.tprintf("can't assign to constant variable '%s'", typed_stmt.name), typed_stmt)
		}

	case ^ast.Value_Decl:
		// TODO: make sure it's not duplicated
		if c.symbol_table.scope_level == 0 {
			return
		}
		type_info := get_type_info_from_expression(c, typed_stmt.value)
		type_info.is_const = typed_stmt.is_const
		if type_info.kind != .Any && typed_stmt.type != "" {
			provided_type_kind := string_to_type_kind(c, typed_stmt.type, typed_stmt)
			if type_info.kind != provided_type_kind {
				add_error(c, fmt.tprintf("exlicitly stated type don't match variable content: %s != %s", type_kind_to_string(c, type_info.kind), type_kind_to_string(c, provided_type_kind)), typed_stmt)
			}
		}
		symbol := make_symbol(c, typed_stmt.name, type_info, stmt)
		add_symbol(c, symbol)

	case ^ast.Func_Stmt:
		if c.symbol_table.scope_level > 0 {
			add_error(c, "can't define function in nested scope", typed_stmt)
		}

	case ^ast.Event_Stmt:
		if c.symbol_table.scope_level > 0 {
			add_error(c, "can't define event in nested scope", typed_stmt)
		}

	case ^ast.Expr_Stmt:
		get_type_info_from_expression(c, typed_stmt.expr)

	case:
		fmt.printfln("unhandled stmt: %v", typed_stmt)
	}
}

get_type_info_from_expression :: proc(c: ^Checker, expr: ^ast.Expr) -> ^Type_Info {
	type_info := new(Type_Info, c.alloc)
	#partial switch v in expr.derived {
	case ^ast.Ident:
		sym, is_exist := lookup_symbol(c.symbol_table.current_scope, v.name)
		if !is_exist {
			add_error(c, fmt.tprintf("variable '%s' is not declared", v.name), v)
			type_info.kind = .Invalid
			return type_info
		}
		return sym.type

	case ^ast.Basic_Lit:
		#partial switch v.tok.kind {
		case .Text: type_info.kind = .Text
		case .Number: type_info.kind = .Number
		case .True, .False: type_info.kind = .Boolean
		case:
			fmt.printfln("Got UNHANDLED literal type")
		}
		return type_info

	case ^ast.Binary_Expr:
		left_kind := get_type_info_from_expression(c, v.left).kind
		right_kind := get_type_info_from_expression(c, v.right).kind
		if left_kind == .Any || right_kind == .Any {
			type_info.kind = .Any
			return type_info
		}
		if left_kind != right_kind {
			left_kind_str := type_kind_to_string(c, left_kind)
			right_kind_str := type_kind_to_string(c, right_kind)
			add_error(c, fmt.tprintf("incompatible types: '%s' and '%s'", left_kind_str, right_kind_str), v)
			type_info.kind = .Invalid
			return type_info
		}
		type_info.kind = left_kind
		return type_info

	case ^ast.Paren_Expr:
		return get_type_info_from_expression(c, v.expr)

	case ^ast.Unary_Expr:
		return get_type_info_from_expression(c, v.expr)

	case ^ast.Call_Expr:
		if ident, is_ident := v.expr.derived.(^ast.Ident); is_ident {
			if sym, sym_exists := lookup_symbol(c.symbol_table.current_scope, ident.name); sym_exists {
				if len(v.args) != len(sym.type.param_types) {
					add_error(c, fmt.tprintf("invalid arguments count in function call: %d != %d", len(v.args), len(sym.type.param_types)), v)
					type_info.kind = .Invalid
					return type_info
				}
				for arg, i in v.args {
					real_index := i
					arg_type, param_type: ^Type_Info
					if arg.name == "" {
						arg_type = get_type_info_from_expression(c, arg.value)
						param_type = sym.type.param_types[i]
					} else {
						real_index = -1
						for param_name, arg_i in sym.type.param_names {
							if param_name == arg.name {
								real_index = arg_i
								break
							}
						}
						if real_index == -1 {
							closest := _find_closest(c, arg.name, sym.type.param_names[:])
							add_error(c, fmt.tprintf("invalid named argument: '%s', maybe '%s'?", arg.name, closest), v)
							continue
						}
						arg_type = get_type_info_from_expression(c, arg.value)
						param_type = sym.type.param_types[real_index]
					}

					if arg_type.kind == .Text && param_type.kind == .Enum {
						// TODO: support enum for regular functions
						action, action_exist := assets.action_native_from_mapped(ident.name)
						if !action_exist {
							add_error(c, "not implemented", v)
							continue
						}
						text_lit, is_text_lit := arg.value.derived.(^ast.Basic_Lit)
						if is_text_lit {
							content := text_lit.tok.content[1:len(text_lit.tok.content)-1]
							if !slice.contains(action.slots[real_index]._enum[:], content) {
								closest := _find_closest(c, content, action.slots[real_index]._enum[:])
								add_error(c, fmt.tprintf("invalid value for enum: '%s', maybe '%s'?", content, closest), text_lit)
							}
						} else {
							add_error(c, fmt.tprintf("can't convert '%s' to 'enum'", type_kind_to_string(c, arg_type.kind)), text_lit)
						}
						continue
					}

					if arg_type.kind != param_type.kind {
						add_error(c, fmt.tprintf("invalid argument type: '%s' != '%s'", type_kind_to_string(c, arg_type.kind), type_kind_to_string(c, param_type.kind)), ident)
					}
				}
				return sym.type.return_t
			} else {
				add_error(c, fmt.tprintf("function '%s' isn't defined", ident.name), ident)
				type_info.kind = .Invalid
				return type_info
			}
		} else {
			fmt.printfln("Invalid call expression: %v", v)
			type_info.kind = .Invalid
			return type_info
		}

	case:
		fmt.printfln("Got UNHANDLED expr: %v", v)
	}
	type_info.kind = .Invalid
	return type_info
}

make_type_event :: proc(c: ^Checker) -> ^Type_Info {
	type_info_event := new(Type_Info, c.alloc)
	type_info_event.kind = .Event
	type_info_event.param_types = make([dynamic]^Type_Info, c.alloc)
	type_info_event.param_names = make([dynamic]string, c.alloc)
	return type_info_event
}

make_type_func :: proc(c: ^Checker, ret_type: ^Type_Info) -> ^Type_Info {
	type_info_func := new(Type_Info, c.alloc)
	type_info_func.kind = .Function
	type_info_func.param_types = make([dynamic]^Type_Info, c.alloc)
	type_info_func.param_names = make([dynamic]string, c.alloc)
	if ret_type != nil {
		type_info_func.return_t = ret_type
	}
	return type_info_func
}

make_symbol :: proc(c: ^Checker, name: string, type: ^Type_Info, node: ^ast.Node) -> ^Symbol {
	symbol := new(Symbol, c.alloc)
	symbol.name = name
	symbol.type = type
	symbol.decl_node = node
	return symbol
}

add_symbol :: proc(c: ^Checker, symbol: ^Symbol) -> bool {
	if c.symbol_table.current_scope == nil {
		return false
	}

	if _, exists := lookup_symbol(c.symbol_table.current_scope, symbol.name); exists {
		return false
	}

	append(&c.symbol_table.current_scope.symbols, symbol)
	return true
}

lookup_symbol :: proc(scope: ^Scope, name: string) -> (^Symbol, bool) {
	scope := scope
	for scope != nil {
		for symbol in scope.symbols {
			if symbol.name == name {
				return symbol, true
			}
		}
		scope = scope.parent
	}
	return nil, false
}

lookup_local_symbol :: proc(scope: ^Scope, name: string) -> (^Symbol, bool) {
	if scope != nil {
		for symbol in scope.symbols {
			if symbol.name == name {
				return symbol, true
			}
		}
	}
	return nil, false
}

create_builtin_type_info :: proc(c: ^Checker, kind: Type_Kind) -> ^Type_Info {
	type_info := new(Type_Info, c.alloc)
	type_info.param_names = make([dynamic]string, c.alloc)
	type_info.param_types = make([dynamic]^Type_Info, c.alloc)
	return_type := new(Type_Info, c.alloc)
	return_type.kind = kind
	type_info.return_t = return_type
	return type_info
}

make_type_info :: proc(kind: Type_Kind, allocator := context.allocator) -> ^Type_Info {
	type_info := new(Type_Info, allocator)
	type_info.kind = kind
	return type_info
}

add_builtin_functions :: proc(c: ^Checker) {
	game_value_type := create_builtin_type_info(c, .GameValue)
	append(&game_value_type.param_names, "value")
	append(&game_value_type.param_types, make_type_info(.Text, c.alloc))
	add_symbol(c, make_symbol(c, "game_value", game_value_type, nil))

	item_value_type := create_builtin_type_info(c, .Item)
	append(&game_value_type.param_names, "id")
	append(&game_value_type.param_names, "count")
	append(&game_value_type.param_types, make_type_info(.Text, c.alloc))
	append(&game_value_type.param_types, make_type_info(.Number, c.alloc))
	add_symbol(c, make_symbol(c, "item", item_value_type, nil))

	array_value_type := create_builtin_type_info(c, .Array)
	add_symbol(c, make_symbol(c, "array", array_value_type, nil))

	dict_value_type := create_builtin_type_info(c, .Dict)
	add_symbol(c, make_symbol(c, "dict", dict_value_type, nil))

	location_value_type := create_builtin_type_info(c, .Location)
	append(&game_value_type.param_names, "x")
	append(&game_value_type.param_names, "y")
	append(&game_value_type.param_names, "z")
	append(&game_value_type.param_types, make_type_info(.Number, c.alloc))
	append(&game_value_type.param_types, make_type_info(.Number, c.alloc))
	append(&game_value_type.param_types, make_type_info(.Number, c.alloc))
	add_symbol(c, make_symbol(c, "location", location_value_type, nil))

	vec3_value_type := create_builtin_type_info(c, .Vector)
	append(&game_value_type.param_names, "x")
	append(&game_value_type.param_names, "y")
	append(&game_value_type.param_names, "z")
	append(&game_value_type.param_types, make_type_info(.Number, c.alloc))
	append(&game_value_type.param_types, make_type_info(.Number, c.alloc))
	append(&game_value_type.param_types, make_type_info(.Number, c.alloc))
	add_symbol(c, make_symbol(c, "vec3", vec3_value_type, nil))

	sound_value_type := create_builtin_type_info(c, .Sound)
	// TODO
	add_symbol(c, make_symbol(c, "sound", sound_value_type, nil))

	particle_value_type := create_builtin_type_info(c, .Particle)
	// TODO
	add_symbol(c, make_symbol(c, "particle", particle_value_type, nil))

	block_value_type := create_builtin_type_info(c, .Block)
	// TODO
	add_symbol(c, make_symbol(c, "block", block_value_type, nil))

	number_value_type := create_builtin_type_info(c, .Number)
	// TODO
	add_symbol(c, make_symbol(c, "number", number_value_type, nil))

	text_value_type := create_builtin_type_info(c, .Text)
	// TODO
	add_symbol(c, make_symbol(c, "text", text_value_type, nil))

	enum_value_type := create_builtin_type_info(c, .Enum)
	append(&game_value_type.param_names, "value")
	append(&game_value_type.param_types, make_type_info(.Text, c.alloc))
	add_symbol(c, make_symbol(c, "enum", enum_value_type, nil))

	potion_value_type := create_builtin_type_info(c, .Potion)
	// TODO
	add_symbol(c, make_symbol(c, "potion", potion_value_type, nil))
}

add_native_functions :: proc(c: ^Checker) {
	for action_name, action_data in assets.actions {
		if action_data.type != .BASIC {
			continue
		}
		type_info := new(Type_Info, c.alloc)
		type_info.kind = .Function
		type_info.param_names = make([dynamic]string, c.alloc)
		type_info.param_types = make([dynamic]^Type_Info, c.alloc)
		for slot in action_data.slots[:] {
			append(&type_info.param_names, slot.name)
			slot_type_info := new(Type_Info, c.alloc)
			slot_type_info.kind = string_to_type_kind(c, slot.type, nil)
			append(&type_info.param_types, slot_type_info)
		}
		sym := make_symbol(c, action_name, type_info, nil)
		add_symbol(c, sym)
	}
}

enter_scope :: proc(c: ^Checker) {
	new_scope := new(Scope, c.alloc)
	new_scope.symbols = make([dynamic]^Symbol, c.alloc)
	new_scope.parent = c.symbol_table.current_scope
	new_scope.level = c.symbol_table.scope_level + 1
	new_scope.children = make([dynamic]^Scope, 0, c.alloc)

	if c.symbol_table.current_scope == nil {
		c.symbol_table.global_scope = new_scope
	} else {
		append(&c.symbol_table.current_scope.children, new_scope)
	}

	c.symbol_table.current_scope = new_scope
	c.symbol_table.scope_level += 1
}

exit_scope :: proc(c: ^Checker) {
	if c.symbol_table.current_scope != nil {
		c.symbol_table.current_scope = c.symbol_table.current_scope.parent
		c.symbol_table.scope_level -= 1
	}
}

add_error :: proc(c: ^Checker, message: string, cause: ^ast.Node) {
	append(&c.errs, error.Error{file=c.files[c.current_file_idx], cause=cause, message=message})
}

add_warning :: proc(c: ^Checker, message: string, cause: ^ast.Node) {
	append(&c.errs, error.Error{file=c.files[c.current_file_idx], cause=cause, message=message, severity=.Warning})
}

@(private="file")
_find_closest :: proc(c: ^Checker, word: string, words: []string) -> string {
	if len(words) == 0 {
		return ""
	}
	closest := words[0]
	closest_distance := max(int)
	for item in words {
		distance := strings.levenshtein_distance(word, item, c.alloc)
		if distance < closest_distance {
			closest = item
			closest_distance = distance
		}
		if distance == 0 {
			break
		}
	}
	return closest
}
