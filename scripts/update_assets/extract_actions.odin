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
	"empty", "else",
}

Action_In_Out :: struct {
	ins: [dynamic]string,
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

extract_actions :: proc(output_file: string) -> (string, bool) {
	actions1 := fetch_url(URL_ACTIONS_1)
	actions := make([dynamic]Action)
	err := json.unmarshal(transmute([]byte)actions1, &actions)
	if err != nil {
		return "Failed to parse JSON", false
	}

	fd, _ := os.open(output_file, os.O_CREATE | os.O_RDWR | os.O_TRUNC)
	defer os.close(fd)
	os.write_string(fd, "#+feature dynamic-literals\n")
	os.write_string(fd, "package assets\n\n")
	os.write_string(fd, "import \"base:runtime\"\n\n")
	os.write_string(fd, "Action :: struct {\n\tname: string,\n\tin_slots: []string,\n\tout_slots: []string,\n\taccept_selector: bool,\n\ttype: Action_Type,\n\tslots: []Slot,\n}\n\n")
	os.write_string(fd, "Action_Type :: enum {\n\tBASIC,\n\tCONTAINER,\n\tBASIC_WITH_CONDITIONAL,\n\tCONTAINER_WITH_CONDITIONAL,\n}\n\n")
	os.write_string(fd, "Slot :: struct {\n\tname: string,\n\ttype: string,\n\t_enum: []string,\n}\n\n")
	os.write_string(fd, "actions: map[string]Action\n\n")
	os.write_string(fd, "@(init)\ninit_actions :: proc \"contextless\" () {\n")
	os.write_string(fd, "\tcontext = runtime.default_context()\n\tactions = make(map[string]Action, ")
	actions_count := 0
	for action in actions {
		if !slice.contains(ACTIONS_BLACKLIST[:], action.name) {
			actions_count += 1
		}
	}
	os.write_string(fd, fmt.tprint(actions_count))
	os.write_string(fd, ", context.allocator)\n")
	for action, action_idx in actions {
		if slice.contains(ACTIONS_BLACKLIST[:], action.name) {
			continue
		}
		action_in_out, has_in_outs := ACTION_INS_OUTS[action.name]
		os.write_string(fd, "\tactions[\"")
		os.write_string(fd, action.name)
		os.write_string(fd, "\"] = Action{\n\t\t\"")
		os.write_string(fd, action.name)
		os.write_string(fd, "\",\n\t\t")
		if has_in_outs {
			os.write_string(fd, "[]string{")
			for _in, idx in action_in_out.ins {
				os.write_string(fd, "\"")
				os.write_string(fd, _in)
				os.write_string(fd, "\"")
				if idx != len(action_in_out.ins)-1 {
				  os.write_string(fd, ", ")
				}
			}
			os.write_string(fd, "}")
		} else {
			os.write_string(fd, "nil")
		}
		os.write_string(fd, ",\n\t\t")
		if has_in_outs {
			os.write_string(fd, "[]string{")
			for out, idx in action_in_out.outs {
				os.write_string(fd, "\"")
				os.write_string(fd, out)
				os.write_string(fd, "\"")
				if idx != len(action_in_out.outs)-1 {
				  os.write_string(fd, ", ")
				}
			}
			os.write_string(fd, "}")
		} else {
			os.write_string(fd, "nil")
		}
		os.write_string(fd, ",\n")
		_, accept_selector := ACTION_SELECTORS[action.name]
		if accept_selector {
			os.write_string(fd, "\t\ttrue,\n")
		} else {
			os.write_string(fd, "\t\tfalse,\n")
		}
		os.write_string(fd, "\t\t")
		switch action.type {
		case "basic":
			os.write_string(fd, ".BASIC")
		case "basic_with_conditional":
			os.write_string(fd, ".BASIC_WITH_CONDITIONAL")
		case "container":
			os.write_string(fd, ".CONTAINER")
		case "container_with_conditional":
			os.write_string(fd, ".CONTAINER_WITH_CONDITIONAL")
		}
		os.write_string(fd, ",\n\t")
		if len(action.args) > 0 {
			os.write_string(fd, "\t[]Slot{\n")
			for slot in action.args {
				os.write_string(fd, "\t\t\tSlot{\"")
				os.write_string(fd, slot.name)
				os.write_string(fd, "\", \"")
				os.write_string(fd, slot.type)
				if slot.type == "enum" {
					os.write_string(fd, "\", {")
					vcount := len(slot.values)
					for v, vi in slot.values {
						os.write_string(fd, "\"")
						os.write_string(fd, v)
						os.write_string(fd, "\"")
						if vi != vcount-1 {
						  os.write_string(fd, ", ")
						}
					}
					os.write_string(fd, "}},\n")
				} else {
					os.write_string(fd, "\", nil},\n")
				}
			}
			os.write_string(fd, "\t\t},\n")
		} else {
			os.write_string(fd, "\tnil,\n")
		}
		os.write_string(fd, "\t}\n")
	}
	os.write_string(fd, "}\n\n")
	os.write_string(fd, "@(fini)\ncleanup_actions :: proc \"contextless\" () {\n")
	os.write_string(fd, "\tcontext = runtime.default_context()\n")
	os.write_string(fd, "\tdelete(actions)\n")
	os.write_string(fd, "}\n\n")
	os.write_string(fd, "action_native_from_mapped :: proc(action_name: string) -> (Action, bool) {\n")
	os.write_string(fd, "\treturn actions[action_name]\n")
	os.write_string(fd, "}\n\n")
	return "", true
}
