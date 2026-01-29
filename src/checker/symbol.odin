package checker

import "../ast"

Symbol :: struct {
	name:		string,
	type:		^Type_Info,
	decl_node:   ^ast.Node,
	metadata:	Metadata,
	is_const:	bool,
}

create_symbol :: proc(name: string, type: ^Type_Info, node: ^ast.Node, allocator := context.allocator) -> ^Symbol {
	symbol := new(Symbol, allocator)
	symbol.name = name
	symbol.type = type
	symbol.decl_node = node
	symbol.metadata = make(Metadata, allocator)
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
