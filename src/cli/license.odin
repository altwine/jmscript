package cli

import "core:fmt"

command_license :: #force_inline proc() {
	LICENSE_TEXT : string : #load("../../LICENSE")
	fmt.println(LICENSE_TEXT)
}
