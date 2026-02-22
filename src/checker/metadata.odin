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
	VOLATILE,
}

Flags :: bit_set[Flag]
