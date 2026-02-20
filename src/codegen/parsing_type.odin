package codegen

import "core:strings"
import "core:encoding/json"

get_parsing_type :: proc(text: string) -> string {
	switch {
	case is_valid_json(text):  return PARSING_JSON
	case is_minimessage(text): return PARSING_STYLIZED
	case is_legacy(text):      return PARSING_COLORED
	case:                      return PARSING_PLAIN
	}
}

DUMMY: struct {}
is_valid_json :: proc(text: string) -> bool {
	return json.unmarshal_string(text, &DUMMY) == nil
}

LEGACY_RUNES := "#0123456789abcdefABCDEFklmnorKLMNOR"
is_legacy :: proc(text: string) -> bool {
	last_r: rune
	for r in text {
		if last_r == '&' && strings.index_rune(LEGACY_RUNES, r) != -1 {
			return true
		}
		last_r = r
	}
	return false
}

is_minimessage :: proc(text: string) -> bool {
	n := len(text)
	if n < 3 {
		return false
	}
	for i := 0; i < n - 2; i += 1 {
		if text[i] == '<' {
			switch text[i+1] {
			case 'a'..='z', 'A'..='Z', '0'..='9', '#', '/':
			case: continue
			}
			for j := i + 2; j < n; j += 1 {
				if text[j] == '>' {
					return true
				}
			}
			break
		}
	}
	return false
}
