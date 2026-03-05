package cli

import "core:fmt"

command_help :: #force_inline proc() {
	print_help()
}

@(private="package")
print_help :: proc() {
	fmt.println("Usage:")
	fmt.printfln("\t%s command [arguments]", exe_path)
	fmt.println("Commands:")
	fmt.println("\tcompile   Compiles directory. All .jms files in the directory must have same package.")
	fmt.println("\tversion   Prints version.")
	fmt.println("\tinit      Initialize project.")
	fmt.println("\treport    Prints system information for bug report.")
	fmt.println("\tlicense   Prints license text.")
	fmt.println("\thelp      Prints help message.")
	fmt.println("\t...       Everything else prints this message.")
}
