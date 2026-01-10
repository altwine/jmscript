package update_assets

import "core:fmt"
import "core:encoding/json"
import "core:os"

Instrument :: struct {
	name: string `json:"name"`,
}

URL_INSTRUMENTS :: URL_BASE_MC+"instruments.json"

extract_instruments :: proc() -> [dynamic]Instrument {
	instruments1 := fetch_url(URL_INSTRUMENTS)
	instruments := make([dynamic]Instrument)
	err := json.unmarshal(transmute([]byte)instruments1, &instruments)
	if err != nil {
		return nil
	}

	return instruments
}

write_instruments :: proc(output_file: string, instruments: [dynamic]Instrument) {
	fd, _ := os.open(output_file, os.O_CREATE | os.O_RDWR | os.O_TRUNC)
	defer os.close(fd)

	fmt.fprintln(fd, "package assets\n")

	fmt.fprintln(fd, "Instrument :: struct {")
	fmt.fprintln(fd, "\tname: string,")
	fmt.fprintln(fd, "}\n")

	fmt.fprintln(fd, "instruments: map[string]Instrument\n")

	fmt.fprintln(fd, "init_instruments :: proc(allocator := context.allocator) {")
	fmt.fprintln(fd, fmt.tprintf("\tinstruments = make(map[string]Instrument, %d, allocator)", len(instruments)))
	for instrument in instruments {
		fmt.fprintfln(fd, "\tinstruments[\"%s\"] = {{\"%s\"}", instrument.name, instrument.name)
	}
	fmt.fprintln(fd, "}\n")

	fmt.fprintln(fd, "cleanup_instruments :: proc() {")
	fmt.fprintln(fd, "\tdelete(instruments)")
	fmt.fprintln(fd, "}\n")

	fmt.fprintln(fd, "get_minecraft_instrument :: proc(instrument_name: string) -> (Instrument, bool) {")
	fmt.fprintln(fd, "\treturn instruments[instrument_name]")
	fmt.fprintln(fd, "}")
}
