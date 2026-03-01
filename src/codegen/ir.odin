package codegen

Handler :: struct {
	type:        string,
	position:    int,
	operations:  [dynamic]^Operation,
	values:      [dynamic]^NamedValue, // can be empty
	name:        string, // can be empty
	event:       string, // can be empty
}

make_handlers :: proc(allocator := context.allocator) -> [dynamic]^Handler {
	return make([dynamic]^Handler, allocator)
}

create_event_handler :: proc(event: string, operations: [dynamic]^Operation, allocator := context.allocator) -> ^Handler {
	event_handler := new(Handler, allocator)
	event_handler.event = event
	event_handler.type = "event"
	event_handler.operations = operations
	return event_handler
}

create_func_handler :: proc(name: string, operations: [dynamic]^Operation, allocator := context.allocator) -> ^Handler {
	func_handler := new(Handler, allocator)
	func_handler.name = name
	func_handler.type = "function"
	func_handler.operations = operations
	func_handler.values = make_named_values(allocator)
	return func_handler
}

Operation :: struct {
	action:      string,
	values:      [dynamic]^NamedValue,
	selection:   ^Operation_Selection, // can be empty
	operations:  [dynamic]^Operation, // can be empty
	is_inverted: bool,
}

make_operations :: proc(allocator := context.allocator) -> [dynamic]^Operation {
	return make([dynamic]^Operation, allocator)
}

create_basic_operation :: proc(action: string, values: [dynamic]^NamedValue, selection := "", allocator := context.allocator) -> ^Operation {
	basic_operation := new(Operation, allocator)
	basic_operation.action = action
	basic_operation.values = values
	basic_operation.selection = new(Operation_Selection, allocator)
	basic_operation.selection.type = selection
	return basic_operation
}

create_container_operation :: proc(action: string, values: [dynamic]^NamedValue, operations: [dynamic]^Operation, is_inverted := false, selection := "", allocator := context.allocator) -> ^Operation {
	container_operation := new(Operation, allocator)
	container_operation.action = action
	container_operation.values = values
	container_operation.selection = new(Operation_Selection, allocator)
	container_operation.selection.type = selection
	container_operation.operations = operations
	container_operation.is_inverted = is_inverted
	return container_operation
}

Operation_Selection :: struct {
	type: string, // can be empty
}

NamedValue :: struct {
	name:  string,
	value: Value,
}

make_named_values :: proc(allocator := context.allocator) -> [dynamic]^NamedValue {
	return make([dynamic]^NamedValue, allocator)
}

create_named_value :: proc(name: string, value: Value, allocator := context.allocator) -> ^NamedValue {
	named_value := new(NamedValue, allocator)
	named_value.name = name
	heap_value := new(Value, allocator)
	heap_value^ = value
	named_value.value = heap_value^
	return named_value
}

BaseValue :: struct {
	type: string,
}

NumberValue :: struct {
	using base: BaseValue,
	number: f64,
}

create_number_value :: proc(number: f64, allocator := context.allocator) -> ^NumberValue {
	number_value := new(NumberValue, allocator)
	number_value.type = "number"
	number_value.number = number
	return number_value
}

TextValue :: struct {
	using base: BaseValue,
	text:    string,
	parsing: string,
}

create_text_value :: proc(text: string, parsing: string, allocator := context.allocator) -> ^TextValue {
	text_value := new(TextValue, allocator)
	text_value.type = "text"
	text_value.text = text
	text_value.parsing = parsing
	return text_value
}

PARSING_JSON     :: "json"
PARSING_COLORED  :: "legacy"
PARSING_STYLIZED :: "minimessage"
PARSING_PLAIN    :: "plain"

MapValue :: struct {
	using base: BaseValue,
	keys:    [dynamic]string,
	values:  [dynamic]Value,
}

create_map_value :: proc(keys: [dynamic]string, values: [dynamic]Value, allocator := context.allocator) -> ^MapValue {
	map_value := new(MapValue, allocator)
	map_value.type = "map"
	map_value.keys = keys
	map_value.values = values
	return map_value
}

VariableValue :: struct {
	using base: BaseValue,
	variable: string,
	scope:    string,
}

create_variable_value :: proc(variable: string, scope: string, allocator := context.allocator) -> ^VariableValue {
	variable_value := new(VariableValue, allocator)
	variable_value.type = "variable"
	variable_value.variable = variable
	variable_value.scope = scope
	return variable_value
}

SCOPE_LINE  :: "line"
SCOPE_LOCAL :: "local"
SCOPE_GAME  :: "game"
SCOPE_SAVE  :: "save"

ArrayValue :: struct {
	using base: BaseValue,
	values: [dynamic]Value,
}

create_array_value :: proc(values: [dynamic]Value, allocator := context.allocator) -> ^ArrayValue {
	array_value := new(ArrayValue, allocator)
	array_value.type = "array"
	array_value.values = values
	return array_value
}

ParameterValue :: struct {
	using base: BaseValue,
	type_key: string,
	description: string,
	name: string,
	value_type: string,
	is_required: string,
	default_value: string,
	slot: f64,
	description_slot: f64,
}

create_parameter_value :: proc(type_key, description, name, value_type: string, slot, description_slot: f64, is_required := "true", default_value := "{}", allocator := context.allocator) -> ^ParameterValue {
	parameter_value := new(ParameterValue, allocator)
	parameter_value.type = "parameter"
	parameter_value.type_key = type_key
	parameter_value.description = description
	parameter_value.name = name
	parameter_value.value_type = value_type
	parameter_value.is_required = is_required
	parameter_value.default_value = default_value
	parameter_value.slot = slot
	parameter_value.description_slot = description_slot
	return parameter_value
}

EnumValue :: struct {
	using base: BaseValue,
	_enum: string, // original key is 'enum'
}

create_enum_value :: proc(_enum: string, allocator := context.allocator) -> ^EnumValue {
	enum_value := new(EnumValue, allocator)
	enum_value.type = "enum"
	enum_value._enum = _enum
	return enum_value
}

LocationValue :: struct {
	using base: BaseValue,
	x, y, z, yaw, pitch: f64,
}

create_location_value :: proc(x, y, z, yaw, pitch: f64, allocator := context.allocator) -> ^LocationValue {
	location_value := new(LocationValue, allocator)
	location_value.type = "location"
	location_value.x = x
	location_value.y = y
	location_value.z = z
	location_value.yaw = yaw
	location_value.pitch = pitch
	return location_value
}

VectorValue :: struct {
	using base: BaseValue,
	x, y, z: f64,
}

create_vector_value :: proc(x: f64, y: f64, z: f64, allocator := context.allocator) -> ^VectorValue {
	vector_value := new(VectorValue, allocator)
	vector_value.type = "vector"
	vector_value.x = x
	vector_value.y = y
	vector_value.z = z
	return vector_value
}

SoundValue :: struct {
	using base: BaseValue,
	sound:     string,
	pitch:     f64,
	volume:    f64,
	variation: string,
	source:    string,
}

create_sound_value :: proc(sound: string, pitch: f64, volume: f64, variation: string, source: string, allocator := context.allocator) -> ^SoundValue {
	sound_value := new(SoundValue, allocator)
	sound_value.type = "sound"
	sound_value.sound = sound
	sound_value.pitch = pitch
	sound_value.volume = volume
	sound_value.variation = variation
	sound_value.source = source
	return sound_value
}

ParticleValue :: struct {
	using base: BaseValue,
	particle_type: string,
	count:         int,
	first_spread:  f64,
	second_spread: f64,
	x_motion:      f64,
	y_motion:      f64,
	z_motion:      f64,
	color:         int,
	size:          f64,
}

create_particle_value :: proc(particle_type: string, count: int, first_spread: f64, second_spread: f64, x_motion: f64, y_motion: f64, z_motion: f64, color: int, size: f64, allocator := context.allocator) -> ^ParticleValue {
	particle_value := new(ParticleValue, allocator)
	particle_value.type = "particle"
	particle_value.particle_type = particle_type
	particle_value.count = count
	particle_value.first_spread = first_spread
	particle_value.second_spread = second_spread
	particle_value.x_motion = x_motion
	particle_value.y_motion = y_motion
	particle_value.z_motion = z_motion
	particle_value.color = color
	particle_value.size = size
	return particle_value
}

ItemValue :: struct {
	using base: BaseValue,
	item: string,
}

create_item_value :: proc(item: string, allocator := context.allocator) -> ^ItemValue {
	item_value := new(ItemValue, allocator)
	item_value.type = "item"
	item_value.item = item
	return item_value
}

GameValue :: struct {
	using base: BaseValue,
	game_value: string,
	selection:  string,  // "{\"type\":\"default\"}" ???
}

create_game_value :: proc(game_value: string, selection: string, allocator := context.allocator) -> ^GameValue {
	game_value_value := new(GameValue, allocator)
	game_value_value.type = "game_value"
	game_value_value.game_value = game_value
	game_value_value.selection = selection
	return game_value_value
}

PotionValue :: struct {
	using base: BaseValue,
	potion:     string,
	amplifier:  int,
	duration:   int,
}

create_potion_value :: proc(potion: string, amplifier: int, duration: int, allocator := context.allocator) -> ^PotionValue {
	potion_value := new(PotionValue, allocator)
	potion_value.type = "potion"
	potion_value.potion = potion
	potion_value.amplifier = amplifier
	potion_value.duration = duration
	return potion_value
}

BlockValue :: struct {
	using base: BaseValue,
	block: string,
}

create_block_value :: proc(block: string, allocator := context.allocator) -> ^BlockValue {
	block_value := new(BlockValue, allocator)
	block_value.type = "block"
	block_value.block = block
	return block_value
}

LocalizedTextValue :: struct {
	using base: BaseValue,
	data: string,
}

create_localized_text_value :: proc(data: string, allocator := context.allocator) -> ^LocalizedTextValue {
	localized_text_value := new(LocalizedTextValue, allocator)
	localized_text_value.type = "localized_text"
	localized_text_value.data = data
	return localized_text_value
}

NullValue :: struct {}

create_null_value :: proc(allocator := context.allocator) -> ^NullValue {
	null_value := new(NullValue, allocator)
	return null_value
}

Value :: union {
	^NullValue,
	^NumberValue,
	^TextValue,
	^MapValue,
	^VariableValue,
	^ArrayValue,
	^ParameterValue,
	^EnumValue,
	^LocationValue,
	^VectorValue,
	^SoundValue,
	^ParticleValue,
	^ItemValue,
	^GameValue,
	^PotionValue,
	^BlockValue,
	^LocalizedTextValue,
}
