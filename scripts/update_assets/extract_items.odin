package update_assets

import "core:fmt"
import "core:os"
import "core:encoding/json"

Minecraft_Item :: struct {
	id:                 int      `json:"id"`,
	name:               string   `json:"name"`,
	display_name:       string   `json:"displayName"`,
	stack_size:         int      `json:"stackSize"`,
	max_durability:     int      `json:"maxDurability"`,
	repair_with:        []string `json:"repairWith"`,
	enchant_categories: []string `json:"enchantCategories"`,
}

extract_items :: proc(output_file: string) -> (string, bool) {
	items1 := fetch_url(URL_ITEMS)
	items := make([dynamic]Minecraft_Item)
	err := json.unmarshal(transmute([]byte)items1, &items)
	if err != nil {
		return "Failed to parse JSON", false
	}

	fd, _ := os.open(output_file, os.O_CREATE | os.O_RDWR | os.O_TRUNC)
	defer os.close(fd)

	fmt.fprintln(fd, "package assets\n")

	fmt.fprintln(fd, "import \"base:runtime\"\n")

	fmt.fprintln(fd, "Minecraft_Item :: struct {")
	fmt.fprintln(fd, "\tname: string,")
	fmt.fprintln(fd, "\tdisplay_name: string,")
	fmt.fprintln(fd, "\tstack_size: Stack_Type,")
	fmt.fprintln(fd, "}\n")

	fmt.fprintln(fd, "Stack_Type :: enum {")
	fmt.fprintln(fd, "\tSingle,")
	fmt.fprintln(fd, "\tQuarter,")
	fmt.fprintln(fd, "\tEntire,")
	fmt.fprintln(fd, "}\n")

	fmt.fprintln(fd, "mc_items: map[string]Minecraft_Item\n")

	fmt.fprintln(fd, "@(init)")
	fmt.fprintln(fd, "init_mc_items :: proc \"contextless\" () {")
	fmt.fprintln(fd, "\tcontext = runtime.default_context()")
	fmt.fprintln(fd, "\tmc_items = make(map[string]Minecraft_Item, context.allocator)")
	for item in items {
		fmt.fprintfln(fd, "\tmc_items[\"%s\"] = Minecraft_Item{{", item.name)
		fmt.fprintfln(fd, "\t\t\"%s\",", item.name)
		fmt.fprintfln(fd, "\t\t\"%s\",", item.display_name)
		switch item.stack_size {
		case 64:
			fmt.fprintln(fd, "\t\t.Entire,")
		case 1:
			fmt.fprintln(fd, "\t\t.Single,")
		case 16:
			fmt.fprintln(fd, "\t\t.Quarter,")
		}
		fmt.fprintln(fd, "\t}")
	}
	fmt.fprintln(fd, "}\n")

	fmt.fprintln(fd, "@(fini)")
	fmt.fprintln(fd, "cleanup_mc_items :: proc \"contextless\" () {")
	fmt.fprintln(fd, "\tcontext = runtime.default_context()")
	fmt.fprintln(fd, "\tdelete(mc_items)")
	fmt.fprintln(fd, "}\n")

	fmt.fprintln(fd, "get_minecraft_item :: proc(item_name: string) -> (Minecraft_Item, bool) {")
	fmt.fprintln(fd, "\treturn mc_items[item_name]")
	fmt.fprintln(fd, "}")

	return "", true
}
