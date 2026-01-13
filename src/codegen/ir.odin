package codegen

Handler :: struct {
	type:        string,
	position:    int,
	operations:  [dynamic]Operation,
	values:      [dynamic]NamedValue, // can be empty
	name:        string, // can be empty
	event:       string, // can be empty
}

Operation :: struct {
	action:      string,
	values:      [dynamic]NamedValue,
	selection:   Operation_Selection, // can be empty
	operations:  [dynamic]Operation, // can be empty
	is_inverted: bool, // can be empty
}

basic_operation :: proc(action: string, values: [dynamic]NamedValue, selection := Operation_Selection{type=""}) -> Operation {
	return Operation{action=action, values=values, selection=selection}
}

container_operation :: proc(action: string, values: [dynamic]NamedValue, operations: [dynamic]Operation, is_inverted := false, selection := Operation_Selection{type=""}) -> Operation {
	return Operation{action, values, selection, operations, is_inverted}
}

Operation_Selection :: struct {
	type: string, // can be empty
}

NamedValue :: struct {
	name:  string,
	value: Value,
}

named_value :: proc(name: string, value: Value) -> NamedValue {
	return NamedValue{name, value}
}

BaseValue :: struct {
	type: string,
}

NumberValue :: struct {
	using base: BaseValue,
	number: f64,
}

number_value :: proc(number: f64) -> NumberValue {
	return NumberValue{type="number", number=number}
}

TextValue :: struct {
	using base: BaseValue,
	text:    string,
	parsing: string,
}

text_value :: proc(text: string, parsing: string) -> TextValue {
	return TextValue{type="text", text=text, parsing=parsing}
}

PARSING_JSON     :: "json"
PARSING_COLORED  :: "legacy"
PARSING_STYLIZED :: "minimessage"
PARSING_PLAIN    :: "plain"

VariableValue :: struct {
	using base: BaseValue,
	variable: string,
	scope:    string,
}

variable_value :: proc(variable: string, scope: string) -> VariableValue {
	return VariableValue{type="variable", variable=variable, scope=scope}
}

SCOPE_LINE  :: "line"
SCOPE_LOCAL :: "local"
SCOPE_GAME  :: "game"
SCOPE_SAVE  :: "save"

ArrayValue :: struct {
	using base: BaseValue,
	values: [dynamic]Value,
}

array_value :: proc(values: [dynamic]Value) -> ArrayValue {
	return ArrayValue{type="array", values=values}
}

EnumValue :: struct {
	using base: BaseValue,
	_enum: string, // original key is 'enum'
}

enum_value :: proc(_enum: string) -> EnumValue {
	return EnumValue{type="enum", _enum=_enum}
}

LocationValue :: struct {
	using base: BaseValue,
	x, y, z, yaw, pitch: f64,
}

location_value :: proc(x, y, z, yaw, pitch: f64) -> LocationValue {
	return LocationValue{type="location", x=x, y=y, z=z, yaw=yaw, pitch=pitch}
}

VectorValue :: struct {
	using base: BaseValue,
	x, y, z: f64,
}

vector_value :: proc(x: f64, y: f64, z: f64) -> VectorValue {
	return VectorValue{type="vector", x=x, y=y, z=z}
}

SoundValue :: struct {
	using base: BaseValue,
	sound:     string,
	pitch:     f64,
	volume:    f64,
	variation: string,
	source:    string,
}

sound_value :: proc(sound: string, pitch: f64, volume: f64, variation: string, source: string) -> SoundValue {
	return SoundValue{type="sound", sound=sound, pitch=pitch, volume=volume, variation=variation, source=source}
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

particle_value :: proc(particle_type: string, count: int, first_spread: f64, second_spread: f64, x_motion: f64, y_motion: f64, z_motion: f64, color: int, size: f64) -> ParticleValue {
	return ParticleValue{type="particle", particle_type=particle_type, count=count, first_spread=first_spread, second_spread=second_spread, x_motion=x_motion, y_motion=y_motion, z_motion=z_motion, color=color, size=size}
}

ItemValue :: struct {
	using base: BaseValue,
	item: string,
}

item_value :: proc(item: string) -> ItemValue {
	return ItemValue{type="item", item=item}
}

GameValue :: struct {
	using base: BaseValue,
	game_value: string,
	selection:  string,  // "{\"type\":\"default\"}" ???
}

game_value :: proc(game_value: string, selection: string) -> GameValue {
	return GameValue{type="game_value", game_value=game_value, selection=selection}
}

PotionValue :: struct {
	using base: BaseValue,
	potion:    string,
	amplifier: int,
	duration:  int,
}

potion_value :: proc(potion: string, amplifier: int, duration: int) -> PotionValue {
	return PotionValue{type="potion", potion=potion, amplifier=amplifier, duration=duration}
}

BlockValue :: struct {
	using base: BaseValue,
	block: string,
}

block_value :: proc(block: string) -> BlockValue {
	return BlockValue{type="block", block=block}
}

LocalizedTextValue :: struct {
	using base: BaseValue,
	data: string,
}

localized_text_value :: proc(data: string) -> LocalizedTextValue {
	return LocalizedTextValue{type="localized_text", data=data}
}

NullValue :: struct {}

null_value :: proc() -> NullValue {
	return NullValue{}
}

Value :: union {
	NullValue,
	NumberValue,
	TextValue,
	VariableValue,
	ArrayValue,
	EnumValue,
	LocationValue,
	VectorValue,
	SoundValue,
	ParticleValue,
	ItemValue,
	GameValue,
	PotionValue,
	BlockValue,
	LocalizedTextValue,
}
