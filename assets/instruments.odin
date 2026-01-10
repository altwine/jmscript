package assets

Instrument :: struct {
	name: string,
}

instruments: map[string]Instrument

init_instruments :: proc(allocator := context.allocator) {
	instruments = make(map[string]Instrument, 23, allocator)
	instruments["harp"] = {"harp"}
	instruments["basedrum"] = {"basedrum"}
	instruments["snare"] = {"snare"}
	instruments["hat"] = {"hat"}
	instruments["bass"] = {"bass"}
	instruments["flute"] = {"flute"}
	instruments["bell"] = {"bell"}
	instruments["guitar"] = {"guitar"}
	instruments["chime"] = {"chime"}
	instruments["xylophone"] = {"xylophone"}
	instruments["iron_xylophone"] = {"iron_xylophone"}
	instruments["cow_bell"] = {"cow_bell"}
	instruments["didgeridoo"] = {"didgeridoo"}
	instruments["bit"] = {"bit"}
	instruments["banjo"] = {"banjo"}
	instruments["pling"] = {"pling"}
	instruments["zombie"] = {"zombie"}
	instruments["skeleton"] = {"skeleton"}
	instruments["creeper"] = {"creeper"}
	instruments["dragon"] = {"dragon"}
	instruments["wither_skeleton"] = {"wither_skeleton"}
	instruments["piglin"] = {"piglin"}
	instruments["custom_head"] = {"custom_head"}
}

cleanup_instruments :: proc() {
	delete(instruments)
}

get_minecraft_instrument :: proc(instrument_name: string) -> (Instrument, bool) {
	return instruments[instrument_name]
}
