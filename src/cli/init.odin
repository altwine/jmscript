package cli

import "core:fmt"
import "core:os"

command_init :: #force_inline proc() {
	if len(os.args) < 3 {
		fmt.println("Not enough arguments: name of dir is expected!")
		print_help()
		return
	}

	dir_name := os.args[2]
	if os.exists(dir_name) {
		fmt.printfln("Path '%s' already exists, aborting...", dir_name)
		return
	}

	err := os.make_directory(dir_name)
	if err != os.ERROR_NONE {
		fmt.printfln("Cannot create '%s' directory, aborting...", dir_name)
		return
	}
	fmt.printfln("Directory '%s' successfully created!", dir_name)

	example_code :: #load("../../resources/example.jms", string)
	file_path := fmt.tprintf("%s/%s", dir_name, "main.jms")

	fd, err2 := os.open(file_path, os.O_WRONLY|os.O_CREATE|os.O_TRUNC)
	if err2 != os.ERROR_NONE {
		fmt.printfln("Cannot create '%s' file, aborting...", file_path)
		return
	}

	_, err3 := os.write_string(fd, example_code)
	if err3 != os.ERROR_NONE {
		fmt.printfln("Cannot write to file '%s', aborting...", file_path)
		return
	}

	fmt.println("Project created successfully!")
}
