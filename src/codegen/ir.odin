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
	operations:  [dynamic]Operation, // can be empty
	is_inverted: bool, // can be empty
	selection:   Operation_Selection,
}

Operation_Selection :: struct {
	type: string, // can be empty
}

NamedValue :: struct {
	name:  string,
	value: Value,
}

BaseValue :: struct {
	type: string,
}

NumberValue :: struct {
	using base: BaseValue,
	number: f64,
}

TextValue :: struct {
	using base: BaseValue,
	text:    string,
	parsing: string,
}

PARSING_LEGACY :: "legacy"
PARSING_MINIMESSAGE :: "minimessage"
PARSING_PLAIN :: "plain"

VariableValue :: struct {
	using base: BaseValue,
	variable: string,
	scope:    string,
}

SCOPE_LOCAL :: "local"
SCOPE_GAME :: "game"
SCOPE_SAVE :: "save"

ArrayValue :: struct {
	using base: BaseValue,
	values: [dynamic]Value,
}

EnumValue :: struct {
	using base: BaseValue,
	_enum: string, // original key is 'enum'
}

LocationValue :: struct {
	using base: BaseValue,
	x, y, z:   f64,
	yaw, pitch: f64,
}

VectorValue :: struct {
	using base: BaseValue,
	x, y, z: f64,
}

SoundValue :: struct {
	using base: BaseValue,
	sound:     string,
	pitch:     f64,
	volume:    f64,
	variation: string,
	source:    string,
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

ItemValue :: struct {
	using base: BaseValue,
	item: string,
}

GameValue :: struct {
	using base: BaseValue,
	game_value: string,
	selection:  string,  // "{\"type\":\"default\"}" ???
}

PotionValue :: struct {
	using base: BaseValue,
	potion:    string,
	amplifier: int,
	duration:  int,
}

BlockValue :: struct {
	using base: BaseValue,
	block: string,
}

NullValue :: struct {
	using base: BaseValue,
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
}
