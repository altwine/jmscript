#+feature dynamic-literals
package update_assets

import "core:fmt"
import "core:slice"
import "core:encoding/json"
import "core:os"

Action_Argument :: struct {
	name:              string   `json:"id"`,
	plural:            bool     `json:"plural"`,
	type:              string   `json:"type"`,
	value_slots:       []int    `json:"valueSlots"`,
	description_slots: []int    `json:"descriptionSlots"`,
	size:              string   `json:"size,omitempty"`,
	values:            []string `json:"values,omitempty"`,
	default_value:     string   `json:"defaultValue,omitempty"`,
	element_type:      string   `json:"elementType,omitempty"`,
	key_type:          string   `json:"keyType,omitempty"`,
	value_type:        string   `json:"valueType,omitempty"`,
}

Action :: struct {
	name:            string            `json:"id"`,
	category:        string            `json:"category"`,
	subcategory:     string            `json:"subcategory"`,
	type:            string            `json:"type"`,
	args:            []Action_Argument `json:"args"`,
	additional_info: []string          `json:"additionalInfo,omitempty"`,
	works_with:      []string          `json:"worksWith,omitempty"`,
}

ACTIONS_BLACKLIST := []string{
	"empty", "else", // "set_variable_dummy", "repeat_dummy",
	// "controller_dummy", "control_dummy", "select_dummy",
	// "if_game_dummy", "game_dummy", "if_variable_dummy",
	// "if_entity_dummy", "entity_dummy", "if_player_dummy",
	// "player_dummy",
}

Action_In_Out :: struct {
	ins:  [dynamic]string,
	outs: [dynamic]string,
}

ACTION_SELECTORS := map[string]bool {
	"player_send_message"=true,
}

ACTION_INS_OUTS := map[string]Action_In_Out {
	"repeat_on_sphere"={
		ins={"center", "radius", "points", "rotate_location"},
		outs={"variable"},
	},
	"repeat_on_range"={
		ins={"start", "end", "interval"},
		outs={"variable"},
	},
	"repeat_on_path"={
		ins={"step", "locations", "rotation"},
		outs={"variable"},
	},
	"repeat_on_grid"={
		ins={"start", "end"},
		outs={"variable"},
	},
	"repeat_on_circle"={
		ins={"center", "radius", "circle_points", "perpendicular_to_plane", "start_angle", "angle_unit"},
		outs={"variable"},
	},
	"repeat_multi_times"={
		ins={"amount"}, outs={"variable"},
	},
	"repeat_for_each_map_entry"={
		ins={"map"},
		outs={"key_variable", "value_variable"},
	},
	"repeat_for_each_in_list"={
		ins={"list"},
		outs={"index_variable", "value_variable"},
	},
	"repeat_adjacently"={
		ins={"origin", "change_rotation", "include_self", "pattern"},
		outs={"variable"},
	},
}

URL_ACTIONS_1 :: URL_BASE_JMS+"actions.json"

extract_actions :: proc() -> ([dynamic]Action) {
	actions1 := fetch_url(URL_ACTIONS_1)
	actions := make([dynamic]Action)
	err := json.unmarshal(transmute([]byte)actions1, &actions)
	if err != nil {
		return nil
	}
	return actions
}

write_actions :: proc(output_file: string, actions: [dynamic]Action) {
	fd, _ := os.open(output_file, os.O_CREATE | os.O_RDWR | os.O_TRUNC)
	defer os.close(fd)

	fmt.fprintln(fd, "#+feature dynamic-literals")
	fmt.fprintln(fd, "package assets\n")

	fmt.fprintln(fd, "Action :: struct {")
	fmt.fprintln(fd, "\tname:            string,")
	fmt.fprintln(fd, "\tin_slots:        [dynamic]string,")
	fmt.fprintln(fd, "\tout_slots:       [dynamic]string,")
	fmt.fprintln(fd, "\taccept_selector: bool,")
	fmt.fprintln(fd, "\ttype:            Action_Type,")
	fmt.fprintln(fd, "\tslots:           [dynamic]Slot,")
	fmt.fprintln(fd, "}\n")

	fmt.fprintln(fd, "Action_Type :: enum {")
	fmt.fprintln(fd, "\tBASIC,")
	fmt.fprintln(fd, "\tCONTAINER,")
	fmt.fprintln(fd, "\tBASIC_WITH_CONDITIONAL,")
	fmt.fprintln(fd, "\tCONTAINER_WITH_CONDITIONAL,")
	fmt.fprintln(fd, "}\n")

	fmt.fprintln(fd, "Slot :: struct {")
	fmt.fprintln(fd, "\tname:  string,")
	fmt.fprintln(fd, "\ttype:  string,")
	fmt.fprintln(fd, "\t_enum: [dynamic]string,")
	fmt.fprintln(fd, "}\n")

	fmt.fprintln(fd, "actions: map[string]Action\n")

	fmt.fprintln(fd, "init_actions :: proc(allocator := context.allocator) {")
	actions_count := len(actions) - len(ACTIONS_BLACKLIST)
	fmt.fprintfln(fd, "\tactions = make(map[string]Action, %d, allocator)", actions_count)
	for action in actions {
		if slice.contains(ACTIONS_BLACKLIST[:], action.name) {
			continue
		}
		action_in_out, has_in_outs := ACTION_INS_OUTS[action.name]
		fmt.fprintfln(fd, "\tactions[\"%s\"] = Action{{", action.name)
		fmt.fprintfln(fd, "\t\t\"%s\",", action.name)
		if has_in_outs {
			fmt.fprint(fd, "\t\t[dynamic]string{")
			for _in, idx in action_in_out.ins {
				fmt.fprintf(fd, "\"%s\"", _in)
				if idx != len(action_in_out.ins)-1 {
				  fmt.fprint(fd, ", ")
				}
			}
			fmt.fprintln(fd, "},")
		} else {
			fmt.fprintln(fd, "\t\tnil,")
		}
		if has_in_outs {
			fmt.fprint(fd, "\t\t[dynamic]string{")
			for out, idx in action_in_out.outs {
				fmt.fprintf(fd, "\"%s\"", out)
				if idx != len(action_in_out.outs)-1 {
				  fmt.fprint(fd, ", ")
				}
			}
			fmt.fprintln(fd, "},")
		} else {
			fmt.fprintln(fd, "\t\tnil,")
		}
		_, accept_selector := ACTION_SELECTORS[action.name]
		if accept_selector {
			fmt.fprintln(fd, "\t\ttrue,")
		} else {
			fmt.fprintln(fd, "\t\tfalse,")
		}
		switch action.type {
		case "basic":
			fmt.fprintln(fd, "\t\t.BASIC,")
		case "basic_with_conditional":
			fmt.fprintln(fd, "\t\t.BASIC_WITH_CONDITIONAL,")
		case "container":
			fmt.fprintln(fd, "\t\t.CONTAINER,")
		case "container_with_conditional":
			fmt.fprintln(fd, "\t\t.CONTAINER_WITH_CONDITIONAL,")
		}
		if len(action.args) > 0 {
			fmt.fprintln(fd, "\t\t[dynamic]Slot{")
			for slot in action.args {
				slot_type_new := slot.type
				switch slot_type_new {
				case "variable": slot_type_new = "any" // temp
				case "vector": slot_type_new = "vec3"
				case "list": slot_type_new = "array"
				case "dictionary": slot_type_new = "dict"
				}
				fmt.fprintf(fd, "\t\t\tSlot{{\"%s\", \"%s", slot.name, slot_type_new)
				if slot.type == "enum" {
					fmt.fprint(fd, "\", {")
					values_count := len(slot.values)
					for value, value_idx in slot.values {
						fmt.fprintf(fd, "\"%s\"", value)
						if value_idx != values_count-1 {
						  fmt.fprint(fd, ", ")
						}
					}
					fmt.fprintln(fd, "}},")
				} else {
					fmt.fprintln(fd, "\", nil},")
				}
			}
			fmt.fprintln(fd, "\t\t},")
		} else {
			fmt.fprintln(fd, "\t\tnil,")
		}
		fmt.fprintln(fd, "\t}")
	}
	fmt.fprintln(fd, "}\n")

	fmt.fprintln(fd, "cleanup_actions :: proc() {")
	fmt.fprintln(fd, "\tfor _, action in actions {")
	fmt.fprintln(fd, "\t\tdelete(action.in_slots)")
	fmt.fprintln(fd, "\t\tdelete(action.out_slots)")
	fmt.fprintln(fd, "\t\tfor slot in action.slots {")
	fmt.fprintln(fd, "\t\t\tdelete(slot._enum)")
	fmt.fprintln(fd, "\t\t}")
	fmt.fprintln(fd, "\t\tdelete(action.slots)")
	fmt.fprintln(fd, "\t}")
	fmt.fprintln(fd, "\tdelete(actions)")
	fmt.fprintln(fd, "}\n")

	fmt.fprintln(fd, "action_native_from_mapped :: proc(action_name: string) -> (Action, bool) {")
	fmt.fprintln(fd, "\treturn actions[action_name]")
	fmt.fprintln(fd, "}")
}
