package checker

Scope :: struct {
	symbols:  [dynamic]^Symbol,
	parent:   ^Scope,
	level:	  int,
	children: [dynamic]^Scope,
	id: int,
}

scope_id_counter := 0
create_scope :: proc(parent: ^Scope, level: int, allocator := context.allocator) -> ^Scope {
	scope := new(Scope, allocator)
	scope.symbols = make([dynamic]^Symbol, allocator)
	scope.children = make([dynamic]^Scope, allocator)
	scope.parent = parent
	scope.level = level

	scope.id = scope_id_counter
	scope_id_counter += 1
	return scope
}
