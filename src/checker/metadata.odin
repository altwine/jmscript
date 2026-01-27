package checker

Metadata :: distinct map[string]Metadata_Field

Metadata_Field :: union {
	string,
	Flags,
}

Flag :: enum {
	BUILTIN,
	NATIVE,
	PURE,
}

Flags :: bit_set[Flag]
