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
	return_t:    ^Type_Info,
	param_names: [dynamic]string,
	param_types: [dynamic]^Type_Info,
	metadata:    Metadata,
}

Symbol :: struct {
	name:        string,
	type:        ^Type_Info,
	decl_node:   ^ast.Node,
	metadata:    Metadata,
	is_const:    bool,
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

	c.current_file_idx = 0
	for file in files {
		c.current_file = file
		for decl in file.decls {
			check_stmt(c, decl)
		}
	}

	exit_scope(c)

	// for sym in c.symbol_table.global_scope.symbols {
	// 	fmt.printfln("[global] %s: %v", sym.name, sym.type)
	// }
	// for scope in c.symbol_table.global_scope.children {
	// 	for sym in scope.symbols {
	// 		fmt.printfln("[local] %s: %v", sym.name, sym.type)
	// 	}
	// }

	return c.symbol_table, c.errs
}

check_stmt :: proc(c: ^Checker, stmt: ^ast.Stmt) {
	#partial switch t in stmt.derived {
	case ^ast.Event_Stmt:
		check_anno(c, stmt)
		for item in t.body.stmts {
			check_stmt(c, item)
		}

		sym, found := lookup_symbol(c.symbol_table.current_scope, t.name)
		if found && check_function_is_pure(c, t.name) {
			if flags_field, has := sym.metadata["flags"]; has {
				if flags, ok := flags_field.(Flags); ok {
					flags += {.PURE}
					sym.metadata["flags"] = flags
				}
			} else {
				sym.metadata["flags"] = Flags{.PURE}
			}
		}

		if anno_is_true(t, "pure") && !check_function_is_pure(c, t.name) {
			add_error(c, fmt.tprintf("event '%s' marked as @pure but have non pure content", t.name), &t.stmt_base)
		}

	case ^ast.Func_Stmt:
		check_anno(c, stmt)
		for item in t.body.stmts {
			check_stmt(c, item)
		}

		sym, found := lookup_symbol(c.symbol_table.current_scope, t.name)
		if found {
			pure := check_function_is_pure(c, t.name)

			if pure {
				if flags_field, has := sym.metadata["flags"]; has {
					if flags, ok := flags_field.(Flags); ok {
						flags += {.PURE}
						sym.metadata["flags"] = flags
					}
				} else {
					sym.metadata["flags"] = Flags{.PURE}
				}
			}

			if anno_is_true(t, "pure") && !pure {
				add_error(c, fmt.tprintf("function '%s' marked as @pure but have non pure content", t.name), &t.stmt_base)
			}
		}

	case ^ast.Block_Stmt:
		for body_stmt in t.stmts {
			check_stmt(c, body_stmt)
		}

	case ^ast.Value_Decl:
		check_anno(c, stmt)

		if t.is_const && !check_expression_is_pure(c, t.value) {
			add_error(c, fmt.tprintf("cannot initialize constant '%s' with not constant value '%s'",
				t.name, ast.expr_to_string(t.value, context.temp_allocator)), &stmt.stmt_base)
		}

		sym, found := lookup_symbol(c.symbol_table.current_scope, t.name)
		if found && (t.is_const || anno_is_true(stmt, "pure")) {
			if check_expression_is_pure(c, t.value) {
				if flags_field, has := sym.metadata["flags"]; has {
					if flags, ok := flags_field.(Flags); ok {
						flags += {.PURE}
						sym.metadata["flags"] = flags
					}
				} else {
					sym.metadata["flags"] = Flags{.PURE}
				}
			} else if anno_is_true(stmt, "pure") {
				add_error(c, fmt.tprintf("variable '%s' marked as @pure but initialized with non pure expression",
					t.name), &stmt.stmt_base)
			}
		}

	case ^ast.Assign_Stmt:
		check_anno(c, stmt)

		sym, found := lookup_symbol(c.symbol_table.current_scope, t.name)
		if found {
			if flags_field, has := sym.metadata["flags"]; has {
				if flags, ok := flags_field.(Flags); ok && .PURE in flags {
					if !check_expression_is_pure(c, t.expr) {
						add_error(c, fmt.tprintf("cannot assign non pure value to pure variable '%s'", t.name), &stmt.stmt_base)
					}
				}
			}
		}

	case ^ast.Expr_Stmt:
		check_anno(c, stmt)

	case ^ast.Defer_Stmt:
		check_anno(c, stmt)

	case ^ast.Return_Stmt:
		check_anno(c, stmt)

	case ^ast.If_Stmt:
		check_anno(c, stmt)
		check_stmt(c, t.body)
		if t.else_stmt != nil {
			check_stmt(c, t.else_stmt)
		}

	case ^ast.For_Stmt:
		check_anno(c, stmt)
		check_stmt(c, t.body)

	case:
		check_anno(c, stmt)
	}
}

collect_handler :: proc(c: ^Checker, stmt: ^ast.Stmt) {
	#partial switch t in stmt.derived {
	case ^ast.Event_Stmt:
		symbol := make_symbol(c, t.name, make_type_event(c), stmt)
		add_symbol(c, symbol)
		enter_scope(c)
		for param in t.params.list {
			param_name := param.name
			param_type := param.type
			type_info := new(Type_Info, c.alloc)
			type_info.kind = string_to_type_kind(c, param_type, param)
			type_info.metadata = make(Metadata, c.alloc)
			param_sym := make_symbol(c, param_name, type_info, stmt)
			add_symbol(c, param_sym)
			append(&symbol.type.param_names, param_sym.name)
			append(&symbol.type.param_types, type_info)
		}
		for item in t.body.stmts {
			collect_stmt(c, item)
		}
		exit_scope(c)

	case ^ast.Func_Stmt:
		ret_type_kind := string_to_type_kind(c, t.result, t)
		ret_type := new(Type_Info, c.alloc)
		ret_type.kind = ret_type_kind
		ret_type.metadata = make(Metadata, c.alloc)
		symbol := make_symbol(c, t.name, make_type_func(c, ret_type), stmt)
		add_symbol(c, symbol)
		enter_scope(c)
		for param in t.params.list {
			param_name := param.name
			param_type := param.type
			type_info := new(Type_Info, c.alloc)
			type_info.metadata = make(Metadata, c.alloc)
			type_info.kind = string_to_type_kind(c, param_type, param)
			param_sym := make_symbol(c, param_name, type_info, stmt)
			add_symbol(c, param_sym)
			append(&symbol.type.param_names, param_sym.name)
			append(&symbol.type.param_types, type_info)
		}
		for item in t.body.stmts {
			collect_stmt(c, item)
		}
		exit_scope(c)

	case ^ast.Value_Decl:
		_, is_already_defined := lookup_symbol(c.symbol_table.current_scope, t.name)
		if is_already_defined {
			add_error(c, fmt.tprintf("variable '%s' is already defined", t.name), t)
			break
		}

		type_info := get_type_info_from_expression(c, t.value)
		if type_info.kind != .Any && t.type != "" {
			provided_type_kind := string_to_type_kind(c, t.type, t)
			if type_info.kind != provided_type_kind {
				add_error(c, fmt.tprintf("exlicitly stated type don't match variable content: '%s' != '%s'", type_kind_to_string(c, type_info.kind), type_kind_to_string(c, provided_type_kind)), t)
			}
		}
		symbol := make_symbol(c, t.name, type_info, stmt)
		symbol.is_const = t.is_const
		add_symbol(c, symbol)

	case ^ast.Defer_Stmt:
		add_error(c, "top level defers isn't allowed", t)
	}
}

collect_stmt :: proc(c: ^Checker, stmt: ^ast.Stmt) {
	#partial switch t in stmt.derived {
	case ^ast.Block_Stmt:
		enter_scope(c)
		for body_stmt in t.stmts {
			collect_stmt(c, body_stmt)
		}
		exit_scope(c)

	case ^ast.Assign_Stmt:
		sym, is_exist := lookup_symbol(c.symbol_table.current_scope, t.name)
		if !is_exist {
			add_error(c, fmt.tprintf("variable '%s' is not declared", t.name), t)
		}
		if sym.is_const {
			add_error(c, fmt.tprintf("can't assign to constant variable '%s'", t.name), t)
		}

	case ^ast.Value_Decl:
		if c.symbol_table.scope_level == 0 {
			return
		}
		if _, is_already_defined := lookup_local_symbol(c.symbol_table.current_scope, t.name);
				is_already_defined {
			add_error(c, fmt.tprintf("variable '%s' is already defined", t.name), t)
			break
		}
		type_info := get_type_info_from_expression(c, t.value)
		if type_info.kind != .Any && t.type != "" {
			provided_type_kind := string_to_type_kind(c, t.type, t)
			if type_info.kind != provided_type_kind {
				add_error(c, fmt.tprintf("exlicitly stated type don't match variable content: %s != %s", type_kind_to_string(c, type_info.kind), type_kind_to_string(c, provided_type_kind)), t)
			}
		}
		symbol := make_symbol(c, t.name, type_info, stmt)
		symbol.is_const = t.is_const
		add_symbol(c, symbol)

	case ^ast.Func_Stmt:
		if c.symbol_table.scope_level > 0 {
			add_error(c, "can't define function in nested scope", t)
		}

	case ^ast.Event_Stmt:
		if c.symbol_table.scope_level > 0 {
			add_error(c, "can't define event in nested scope", t)
		}

	case ^ast.Expr_Stmt:
		get_type_info_from_expression(c, t.expr)

	case:
		fmt.printfln("unhandled stmt: %v", t)
	}
}

get_type_info_from_expression :: proc(c: ^Checker, expr: ^ast.Expr) -> ^Type_Info {
	type_info := new(Type_Info, c.alloc)
	type_info.metadata = make(Metadata, c.alloc)
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
			fmt.printfln("got UNHANDLED literal type")
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
						if !can_casted(arg_type.kind, param_type.kind) {
							add_error(c, fmt.tprintf("invalid argument type: '%s' != '%s'", type_kind_to_string(c, arg_type.kind), type_kind_to_string(c, param_type.kind)), ident)
						}
					}
				}
				return sym.type.return_t
			} else {
				add_error(c, fmt.tprintf("function '%s' isn't defined", ident.name), ident)
				type_info.kind = .Invalid
				return type_info
			}
		} else {
			fmt.printfln("invalid call expression: %v", v)
			type_info.kind = .Invalid
			return type_info
		}

	case:
		fmt.printfln("got UNHANDLED expr: %v", v)
	}
	type_info.kind = .Invalid
	return type_info
}

make_type_event :: proc(c: ^Checker) -> ^Type_Info {
	type_info_event := new(Type_Info, c.alloc)
	type_info_event.kind = .Event
	type_info_event.param_types = make([dynamic]^Type_Info, c.alloc)
	type_info_event.param_names = make([dynamic]string, c.alloc)
	type_info_event.metadata =    make(Metadata, c.alloc)
	return type_info_event
}

make_type_func :: proc(c: ^Checker, ret_type: ^Type_Info) -> ^Type_Info {
	type_info_func := new(Type_Info, c.alloc)
	type_info_func.kind = .Function
	type_info_func.param_types = make([dynamic]^Type_Info, c.alloc)
	type_info_func.param_names = make([dynamic]string, c.alloc)
	type_info_func.metadata =    make(Metadata, c.alloc)
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
	symbol.metadata = make(Metadata, c.alloc)
	return symbol
}

add_symbol :: proc(c: ^Checker, symbol: ^Symbol) -> bool {
	if c.symbol_table.current_scope == nil {
		return false
	}

	if _, exists := lookup_local_symbol(c.symbol_table.current_scope, symbol.name); exists {
		return false
	}

	append(&c.symbol_table.current_scope.symbols, symbol)
	return true
}

lookup_symbol :: proc(scope: ^Scope, name: string) -> (^Symbol, bool) {
	scope := scope
	for scope != nil {
		for &symbol in scope.symbols {
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
	return_type.metadata = make(Metadata, c.alloc)
	return_type.kind = kind
	type_info.return_t = return_type
	type_info.metadata = make(Metadata, c.alloc)
	return type_info
}

make_type_info :: proc(kind: Type_Kind, allocator := context.allocator) -> ^Type_Info {
	type_info := new(Type_Info, allocator)
	type_info.kind = kind
	type_info.metadata = make(Metadata, allocator)
	return type_info
}

add_builtin_functions :: proc(c: ^Checker) {
	game_value_type := create_builtin_type_info(c, .GameValue)
	game_value_type.kind = .Function
	append(&game_value_type.param_names, "value")
	append(&game_value_type.param_names, "selection")
	append(&game_value_type.param_types, make_type_info(.Text, c.alloc))
	append(&game_value_type.param_types, make_type_info(.Text, c.alloc))
	symbol := make_symbol(c, "game_value", game_value_type, nil)
	symbol.metadata["flags"] = Flags{.BUILTIN}
	add_symbol(c, symbol)

	item_value_type := create_builtin_type_info(c, .Item)
	item_value_type.kind = .Function
	append(&item_value_type.param_names, "id")
	append(&item_value_type.param_names, "count")
	append(&item_value_type.param_types, make_type_info(.Text, c.alloc))
	append(&item_value_type.param_types, make_type_info(.Number, c.alloc))
	symbol = make_symbol(c, "item", item_value_type, nil)
	symbol.metadata["flags"] = Flags{.BUILTIN}
	add_symbol(c, symbol)

	array_value_type := create_builtin_type_info(c, .Array)
	array_value_type.kind = .Function
	// ...
	symbol = make_symbol(c, "array", array_value_type, nil)
	symbol.metadata["flags"] = Flags{.BUILTIN}
	add_symbol(c, symbol)

	dict_value_type := create_builtin_type_info(c, .Dict)
	dict_value_type.kind = .Function
	// ...
	symbol = make_symbol(c, "dict", dict_value_type, nil)
	symbol.metadata["flags"] = Flags{.BUILTIN}
	add_symbol(c, symbol)

	location_value_type := create_builtin_type_info(c, .Location)
	location_value_type.kind = .Function
	append(&location_value_type.param_names, "x")
	append(&location_value_type.param_names, "y")
	append(&location_value_type.param_names, "z")
	append(&location_value_type.param_names, "yaw")
	append(&location_value_type.param_names, "pitch")
	append(&location_value_type.param_types, make_type_info(.Number, c.alloc))
	append(&location_value_type.param_types, make_type_info(.Number, c.alloc))
	append(&location_value_type.param_types, make_type_info(.Number, c.alloc))
	append(&location_value_type.param_types, make_type_info(.Number, c.alloc))
	append(&location_value_type.param_types, make_type_info(.Number, c.alloc))
	symbol = make_symbol(c, "location", location_value_type, nil)
	symbol.metadata["flags"] = Flags{.BUILTIN}
	add_symbol(c, symbol)

	vec3_value_type := create_builtin_type_info(c, .Vector)
	vec3_value_type.kind = .Function
	append(&vec3_value_type.param_names, "x")
	append(&vec3_value_type.param_names, "y")
	append(&vec3_value_type.param_names, "z")
	append(&vec3_value_type.param_types, make_type_info(.Number, c.alloc))
	append(&vec3_value_type.param_types, make_type_info(.Number, c.alloc))
	append(&vec3_value_type.param_types, make_type_info(.Number, c.alloc))
	symbol = make_symbol(c, "vec3", vec3_value_type, nil)
	symbol.metadata["flags"] = Flags{.BUILTIN}
	add_symbol(c, symbol)

	sound_value_type := create_builtin_type_info(c, .Sound)
	sound_value_type.kind = .Function
	append(&sound_value_type.param_names, "sound")
	append(&sound_value_type.param_names, "pitch")
	append(&sound_value_type.param_names, "volume")
	append(&sound_value_type.param_names, "variation")
	append(&sound_value_type.param_names, "source")
	append(&sound_value_type.param_types, make_type_info(.Text, c.alloc))
	append(&sound_value_type.param_types, make_type_info(.Number, c.alloc))
	append(&sound_value_type.param_types, make_type_info(.Number, c.alloc))
	append(&sound_value_type.param_types, make_type_info(.Text, c.alloc))
	append(&sound_value_type.param_types, make_type_info(.Text, c.alloc))
	symbol = make_symbol(c, "sound", sound_value_type, nil)
	symbol.metadata["flags"] = Flags{.BUILTIN}
	add_symbol(c, symbol)

	particle_value_type := create_builtin_type_info(c, .Particle)
	particle_value_type.kind = .Function
	append(&particle_value_type.param_names, "particle_type")
	append(&particle_value_type.param_names, "count")
	append(&particle_value_type.param_names, "first_spread")
	append(&particle_value_type.param_names, "second_spread")
	append(&particle_value_type.param_names, "x_motion")
	append(&particle_value_type.param_names, "y_motion")
	append(&particle_value_type.param_names, "z_motion")
	append(&particle_value_type.param_names, "color")
	append(&particle_value_type.param_names, "size")
	append(&sound_value_type.param_types, make_type_info(.Text, c.alloc))
	append(&sound_value_type.param_types, make_type_info(.Number, c.alloc))
	append(&sound_value_type.param_types, make_type_info(.Number, c.alloc))
	append(&sound_value_type.param_types, make_type_info(.Number, c.alloc))
	append(&sound_value_type.param_types, make_type_info(.Number, c.alloc))
	append(&sound_value_type.param_types, make_type_info(.Number, c.alloc))
	append(&sound_value_type.param_types, make_type_info(.Number, c.alloc))
	append(&sound_value_type.param_types, make_type_info(.Number, c.alloc))
	append(&sound_value_type.param_types, make_type_info(.Number, c.alloc))
	symbol = make_symbol(c, "particle", particle_value_type, nil)
	symbol.metadata["flags"] = Flags{.BUILTIN}
	add_symbol(c, symbol)

	block_value_type := create_builtin_type_info(c, .Block)
	block_value_type.kind = .Function
	append(&block_value_type.param_names, "id")
	append(&block_value_type.param_types, make_type_info(.Text, c.alloc))
	symbol = make_symbol(c, "block", block_value_type, nil)
	symbol.metadata["flags"] = Flags{.BUILTIN}
	add_symbol(c, symbol)

	number_value_type := create_builtin_type_info(c, .Number)
	number_value_type.kind = .Function
	append(&number_value_type.param_names, "value")
	append(&number_value_type.param_types, make_type_info(.Any, c.alloc))
	symbol = make_symbol(c, "number", number_value_type, nil)
	symbol.metadata["flags"] = Flags{.BUILTIN}
	add_symbol(c, symbol)

	text_value_type := create_builtin_type_info(c, .Text)
	text_value_type.kind = .Function
	append(&text_value_type.param_names, "value")
	append(&text_value_type.param_types, make_type_info(.Any, c.alloc))
	symbol = make_symbol(c, "text", text_value_type, nil)
	symbol.metadata["flags"] = Flags{.BUILTIN}
	add_symbol(c, symbol)

	enum_value_type := create_builtin_type_info(c, .Enum)
	enum_value_type.kind = .Function
	append(&enum_value_type.param_names, "value")
	append(&enum_value_type.param_types, make_type_info(.Text, c.alloc))
	symbol = make_symbol(c, "enum", enum_value_type, nil)
	symbol.metadata["flags"] = Flags{.BUILTIN}
	add_symbol(c, symbol)

	potion_value_type := create_builtin_type_info(c, .Potion)
	particle_value_type.kind = .Function
	append(&enum_value_type.param_names, "potion")
	append(&enum_value_type.param_names, "amplifier")
	append(&enum_value_type.param_names, "duration")
	append(&enum_value_type.param_types, make_type_info(.Text, c.alloc))
	append(&enum_value_type.param_types, make_type_info(.Number, c.alloc))
	append(&enum_value_type.param_types, make_type_info(.Number, c.alloc))
	symbol = make_symbol(c, "potion", potion_value_type, nil)
	symbol.metadata["flags"] = Flags{.BUILTIN}
	add_symbol(c, symbol)
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
		type_info.metadata = make(Metadata, c.alloc)
		for slot in action_data.slots[:] {
			append(&type_info.param_names, slot.name)
			slot_type_info := new(Type_Info, c.alloc)
			slot_type_info.metadata = make(Metadata, c.alloc)
			slot_type_info.kind = string_to_type_kind(c, slot.type, nil)
			append(&type_info.param_types, slot_type_info)
		}
		sym := make_symbol(c, action_name, type_info, nil)
		sym.metadata["flags"] = Flags{.NATIVE}
		add_symbol(c, sym)
	}
}

can_casted :: proc(first, second: Type_Kind) -> bool {
	if first == .Any || second == .Any {
		return true
	}

	if first == second {
		return true
	}

	return false
}

check_anno :: proc(c: ^Checker, stmt: ^ast.Stmt) {
	for &anno in stmt.annotations {
		if anno.value != nil && !check_expression_is_pure(c, anno.value) {
			add_error(c, fmt.tprintf("annotation param with name '%s' is not a constant time expression", anno.name), &anno.anno_base)
		}
	}
}

check_function_is_pure :: proc(c: ^Checker, name: string) -> bool {
	sym, exists := lookup_symbol(c.symbol_table.current_scope, name)

	if !exists {
		return false
	}

	if sym.type.kind != .Function {
		return false
	}

	if is_value_factory(c, name) {
		return true
	}

	if _, action_exists := assets.action_native_from_mapped(name); action_exists {
		return false
	}

	if func_stmt, is_func_stmt := sym.decl_node.derived.(^ast.Func_Stmt); is_func_stmt {
		return check_function_body_is_pure(c, func_stmt.body)
	}

	return false
}

is_value_factory :: proc(c: ^Checker, name: string) -> bool {
	sym, found := lookup_symbol(c.symbol_table.current_scope, name)
	if !found {
		return false
	}

	if flags_field, has := sym.metadata["flags"]; has {
		if flags, ok := flags_field.(Flags); ok {
			return .BUILTIN in flags
		}
	}
	return false
}

check_function_body_is_pure :: proc(c: ^Checker, body: ^ast.Block_Stmt) -> bool {
	if body == nil {
		return true
	}

	for stmt in body.stmts {
		#partial switch s in stmt.derived {
		case ^ast.Expr_Stmt:
			if !check_expression_is_pure(c, s.expr) {
				return false
			}

		case ^ast.Value_Decl:
			if t, is_value_decl := s.derived.(^ast.Value_Decl); is_value_decl {
				if !check_expression_is_pure(c, t.value) {
					return false
				}
			}

		case ^ast.Assign_Stmt:
			if !check_expression_is_pure(c, s.expr) {
				return false
			}

		case ^ast.Return_Stmt:
			if s.result != nil && !check_expression_is_pure(c, s.result) {
				return false
			}

		case ^ast.If_Stmt:
			if !check_expression_is_pure(c, s.cond) {
				return false
			}
			if !check_function_body_is_pure(c, s.body) {
				return false
			}
			if s.else_stmt != nil && !check_function_body_is_pure(c, s.else_stmt) {
				return false
			}

		case ^ast.For_Stmt:
			if !check_for_stmt_is_pure(c, s) {
				return false
			}

		case ^ast.Block_Stmt:
			if !check_function_body_is_pure(c, s) {
				return false
			}

		case ^ast.Defer_Stmt:
			#partial switch d in s.stmt.derived {
			case ^ast.Expr_Stmt:
				if !check_expression_is_pure(c, d.expr) {
					return false
				}
			case:
				return false
			}

		case:
			return false
		}
	}

	return true
}

check_for_stmt_is_pure :: proc(c: ^Checker, for_stmt: ^ast.For_Stmt) -> bool {
	if for_stmt.init != nil {
		for ident in for_stmt.init {
			if sym, exists := lookup_symbol(c.symbol_table.current_scope, ident.name); !exists {
				return false
			}
		}
	}

	if for_stmt.cond != nil && !check_expression_is_pure(c, for_stmt.cond) {
		return false
	}
	if for_stmt.second_cond != nil && !check_expression_is_pure(c, for_stmt.second_cond) {
		return false
	}

	if for_stmt.post != nil {
		#partial switch post_stmt in for_stmt.post.derived {
		case ^ast.Expr_Stmt:
			if !check_expression_is_pure(c, post_stmt.expr) {
				return false
			}
		case ^ast.Assign_Stmt:
			if !check_expression_is_pure(c, post_stmt.expr) {
				return false
			}
		case:
			return false
		}
	}

	if for_stmt.body != nil {
		enter_scope(c)
		defer exit_scope(c)

		if for_stmt.init != nil {
			for ident in for_stmt.init {
				type_info := new(Type_Info, c.alloc)
				type_info.kind = .Any
				type_info.metadata = make(Metadata, c.alloc)
				symbol := make_symbol(c, ident.name, type_info, cast(^ast.Node)ident)
				add_symbol(c, symbol)
			}
		}

		if !check_function_body_is_pure(c, for_stmt.body) {
			return false
		}
	}

	return !contains_notpure_calls_in_for_body(c, for_stmt.body)
}

contains_notpure_calls_in_for_body :: proc(c: ^Checker, body: ^ast.Block_Stmt) -> bool {
	if body == nil {
		return false
	}

	for stmt in body.stmts {
		#partial switch s in stmt.derived {
		case ^ast.Expr_Stmt:
			if contains_notpure_calls_in_expr(c, s.expr) {
				return true
			}

		case ^ast.Value_Decl:
			if t, is_value_decl := s.derived.(^ast.Value_Decl); is_value_decl {
				if contains_notpure_calls_in_expr(c, t.value) {
					return true
				}
			}

		case ^ast.Assign_Stmt:
			if contains_notpure_calls_in_expr(c, s.expr) {
				return true
			}

		case ^ast.If_Stmt:
			if contains_notpure_calls_in_expr(c, s.cond) {
				return true
			}
			if contains_notpure_calls_in_body(c, s.body) {
				return true
			}
			if s.else_stmt != nil && contains_notpure_calls_in_body(c, s.else_stmt) {
				return true
			}

		case ^ast.For_Stmt:
			if contains_notpure_calls_in_for_body(c, s.body) {
				return true
			}

		case ^ast.Block_Stmt:
			if contains_notpure_calls_in_body(c, s) {
				return true
			}

		case ^ast.Defer_Stmt:
			#partial switch d in s.stmt.derived {
			case ^ast.Expr_Stmt:
				if contains_notpure_calls_in_expr(c, d.expr) {
					return true
				}
			case:
				return true
			}
		}
	}

	return false
}

contains_notpure_calls_in_expr :: proc(c: ^Checker, expr: ^ast.Expr) -> bool {
	if expr == nil {
		return false
	}

	#partial switch e in expr.derived {
	case ^ast.Call_Expr:
		if ident, is_ident := e.expr.derived.(^ast.Ident); is_ident {
			return !check_function_is_pure(c, ident.name)
		}

		return true

	case ^ast.Binary_Expr:
		return contains_notpure_calls_in_expr(c, e.left) ||
			   contains_notpure_calls_in_expr(c, e.right)

	case ^ast.Unary_Expr:
		return contains_notpure_calls_in_expr(c, e.expr)

	case ^ast.Paren_Expr:
		return contains_notpure_calls_in_expr(c, e.expr)

	case ^ast.Index_Expr:
		return contains_notpure_calls_in_expr(c, e.expr) ||
			   contains_notpure_calls_in_expr(c, e.index)

	case ^ast.Member_Access_Expr:
		return contains_notpure_calls_in_expr(c, e.expr)

	case ^ast.Field_Value:
		return contains_notpure_calls_in_expr(c, e.field) ||
			   contains_notpure_calls_in_expr(c, e.value)
	}

	return false
}

contains_notpure_calls_in_body :: proc(c: ^Checker, body: ^ast.Block_Stmt) -> bool {
	if body == nil {
		return false
	}

	for stmt in body.stmts {
		#partial switch s in stmt.derived {
		case ^ast.Expr_Stmt:
			if contains_notpure_calls_in_expr(c, s.expr) {
				return true
			}

		case ^ast.Value_Decl:
			if t, is_value_decl := s.derived.(^ast.Value_Decl); is_value_decl {
				if contains_notpure_calls_in_expr(c, t.value) {
					return true
				}
			}

		case ^ast.Assign_Stmt:
			if contains_notpure_calls_in_expr(c, s.expr) {
				return true
			}

		case ^ast.If_Stmt:
			if contains_notpure_calls_in_expr(c, s.cond) {
				return true
			}
			if contains_notpure_calls_in_body(c, s.body) {
				return true
			}
			if s.else_stmt != nil && contains_notpure_calls_in_body(c, s.else_stmt) {
				return true
			}

		case ^ast.For_Stmt:
			if contains_notpure_calls_in_for_body(c, s.body) {
				return true
			}

		case ^ast.Block_Stmt:
			if contains_notpure_calls_in_body(c, s) {
				return true
			}
		}
	}

	return false
}

check_expression_is_pure :: proc(c: ^Checker, expr: ^ast.Expr) -> bool {
	if expr == nil {
		return false
	}

	#partial switch t in expr.derived {
	case ^ast.Basic_Lit:
		return true
	case ^ast.Binary_Expr:
		return check_expression_is_pure(c, t.left) && check_expression_is_pure(c, t.right)
	case ^ast.Unary_Expr:
		return check_expression_is_pure(c, t.expr)
	case ^ast.Paren_Expr:
		return check_expression_is_pure(c, t.expr)
	case ^ast.Ident:
		sym, exists := lookup_symbol(c.symbol_table.current_scope, t.name)

		if !exists {
			return false
		}

		if sym.is_const {
			return true
		}

		if value_decl, is_value_decl := sym.decl_node.derived.(^ast.Value_Decl); is_value_decl {
			if value_decl.is_const {
				return check_expression_is_pure(c, value_decl.value)
			}
		}

		return false
	case ^ast.Call_Expr:
		if ident, is_ident := t.expr.derived.(^ast.Ident); is_ident {
			if !check_function_is_pure(c, ident.name) {
				return false
			}

			for arg in t.args {
				if !check_expression_is_pure(c, arg.value) {
					return false
				}
			}
			return true
		}
		return false
	case ^ast.Index_Expr:
		return check_expression_is_pure(c, t.expr) && check_expression_is_pure(c, t.index)
	case ^ast.Member_Access_Expr:
		return check_expression_is_pure(c, t.expr)
	case ^ast.Field_Value:
		return check_expression_is_pure(c, t.field) && check_expression_is_pure(c, t.value)
	case:
		return false
	}
}

get_anno :: proc(stmt: ^ast.Stmt, name: string) -> ^ast.Annotation {
	for &anno in stmt.annotations {
		if strings.equal_fold(anno.name, name) {
			return &anno
		}
	}
	return nil
}

has_anno :: proc(stmt: ^ast.Stmt, name: string) -> bool {
	return get_anno(stmt, name) != nil
}

anno_is_true :: proc(stmt: ^ast.Stmt, name: string) -> bool {
	anno := get_anno(stmt, name)
	if anno == nil {
		return false
	}

	if anno.value == nil {
		return true
	}

	#partial switch v in anno.value.derived {
	case ^ast.Basic_Lit:
		if v.tok.kind == .True {
			return true
		}
		return false

	case ^ast.Ident:
		if v.name == "true" {
			return true
		}
		return false

	case:
		return false
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
	append(&c.errs, error.Error{file=c.files[c.current_file_idx], cause_pos=cause.pos, cause_end=cause.end, message=message})
}

add_warning :: proc(c: ^Checker, message: string, cause: ^ast.Node) {
	append(&c.errs, error.Error{file=c.files[c.current_file_idx], cause_pos=cause.pos, cause_end=cause.end, message=message, severity=.Warning})
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
