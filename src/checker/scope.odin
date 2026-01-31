package checker

Scope :: struct {
	symbols:  [dynamic]^Symbol,
	parent:   ^Scope,
	level:	  int,
	children: [dynamic]^Scope,
}

create_scope :: proc(parent: ^Scope, level: int, allocator := context.allocator) -> ^Scope {
	scope := new(Scope, allocator)
	scope.symbols = make([dynamic]^Symbol, allocator)
	scope.children = make([dynamic]^Scope, allocator)
	scope.parent = parent
	scope.level = level
	return scope
}
