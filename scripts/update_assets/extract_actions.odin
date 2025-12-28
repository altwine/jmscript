#+feature dynamic-literals
package update_assets

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
	"repeat_on_sphere"=Action_In_Out{ins=[dynamic]string{"center", "radius", "points", "rotate_location"}, outs=[dynamic]string{"variable"}},
	"repeat_on_range"=Action_In_Out{ins=[dynamic]string{"start", "end", "interval"}, outs=[dynamic]string{"variable"}},
	"repeat_on_path"=Action_In_Out{ins=[dynamic]string{"step", "locations", "rotation"}, outs=[dynamic]string{"variable"}},
	"repeat_on_grid"=Action_In_Out{ins=[dynamic]string{"start", "end"}, outs=[dynamic]string{"variable"}},
	"repeat_on_circle"=Action_In_Out{ins=[dynamic]string{"center", "radius", "circle_points", "perpendicular_to_plane", "start_angle", "angle_unit"}, outs=[dynamic]string{"variable"}},
	"repeat_multi_times"=Action_In_Out{ins=[dynamic]string{"amount"}, outs=[dynamic]string{"variable"}},
	"repeat_for_each_map_entry"=Action_In_Out{ins=[dynamic]string{"map"}, outs=[dynamic]string{"key_variable", "value_variable"}},
	"repeat_for_each_in_list"=Action_In_Out{ins=[dynamic]string{"list"}, outs=[dynamic]string{"index_variable", "value_variable"}},
	"repeat_adjacently"=Action_In_Out{ins=[dynamic]string{"origin", "change_rotation", "include_self", "pattern"}, outs=[dynamic]string{"variable"}},
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
	os.write_string(fd, "Action :: struct {\n\tname: string,\n\ttype: Action_Type,\n\taccept_selector: bool,\n\tslots: [dynamic]Slot,\n\tin_slots: [dynamic]string,\n\tout_slots: [dynamic]string,\n}\n\n")
	os.write_string(fd, "Action_Type :: enum {\n\tBASIC,\n\tCONTAINER,\n\tBASIC_WITH_CONDITIONAL,\n\tCONTAINER_WITH_CONDITIONAL,\n}\n\n")
	os.write_string(fd, "Slot :: struct {\n\tname: string,\n\ttype: string,\n\t_enum: [dynamic]string,\n}\n\n")
	os.write_string(fd, "action_native_from_mapped :: proc(action_name: string, slots_allocator := context.allocator) -> (Action, bool) {\n")
	os.write_string(fd, "\tcontext.allocator = slots_allocator\n\tslots := make([dynamic]Slot, slots_allocator)\n")
	os.write_string(fd, "\tswitch action_name {\n")
	for action in actions {
		if slice.contains(ACTIONS_BLACKLIST[:], action.name) {
			continue
		}
		action_in_out, has_in_outs := ACTION_INS_OUTS[action.name]
		os.write_string(fd, "\tcase \"")
		os.write_string(fd, action.name)
		os.write_string(fd, "\":\n")
		for slot in action.args {
			os.write_string(fd, "\t\tappend(&slots, Slot{name=\"")
			os.write_string(fd, slot.name)
			os.write_string(fd, "\", type=\"")
			os.write_string(fd, slot.type)
			if slot.type == "enum" {
				os.write_string(fd, "\", _enum=[dynamic]string{")
				vcount := len(slot.values)
				for v, vi in slot.values {
					os.write_string(fd, "\"")
					os.write_string(fd, v)
					os.write_string(fd, "\"")
					if vi != vcount-1 {
					  os.write_string(fd, ",")
					}
				}
				os.write_string(fd, "}})\n")
			} else {
				os.write_string(fd, "\"})\n")
			}
		}
		os.write_string(fd, "\t\treturn Action{\n\t\t\tname=\"")
		os.write_string(fd, action.name)
		os.write_string(fd, "\",\n\t\t\tin_slots=[dynamic]string{")
		if has_in_outs {
			for _in, idx in action_in_out.ins {
				os.write_string(fd, "\"")
				os.write_string(fd, _in)
				os.write_string(fd, "\"")
				if idx != len(action_in_out.ins)-1 {
				  os.write_string(fd, ",")
				}
			}
		}
		os.write_string(fd, "},\n")
		os.write_string(fd, "\t\t\tout_slots=[dynamic]string{")
		if has_in_outs {
			for out, idx in action_in_out.outs {
				os.write_string(fd, "\"")
				os.write_string(fd, out)
				os.write_string(fd, "\"")
				if idx != len(action_in_out.outs)-1 {
				  os.write_string(fd, ",")
				}
			}
		}
		os.write_string(fd, "},\n")
		_, accept_selector := ACTION_SELECTORS[action.name]
		if accept_selector {
			os.write_string(fd, "\t\t\taccept_selector=true,\n")
		} else {
			os.write_string(fd, "\t\t\taccept_selector=false,\n")
		}
		os.write_string(fd, "\t\t\ttype=")
		switch action.type {
		case "basic":
			os.write_string(fd, "Action_Type.BASIC")
		case "basic_with_conditional":
			os.write_string(fd, "Action_Type.BASIC_WITH_CONDITIONAL")
		case "container":
			os.write_string(fd, "Action_Type.CONTAINER")
		case "container_with_conditional":
			os.write_string(fd, "Action_Type.CONTAINER_WITH_CONDITIONAL")
		}
		os.write_string(fd, ",\n\t\t\tslots=slots,\n\t\t}, true\n")
	}
	os.write_string(fd, "\t}\n\treturn Action{}, false\n}\n")
	return "", true
}
