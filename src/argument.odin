package main

import "core:log"
import "core:fmt"
Argument :: struct
{
	identifier: string,
	abreviation: string,
	command: proc(^[]string)
}

run_help_command :: proc(args: ^[]string)
{
	fmt.printfln("Running Help Command")
}

run_create_new_template_command :: proc(args: ^[]string)
{
	if len(args) < 2
	{
		log.errorf("Missing Name of Template Argument")
		return
	}

	name_for_template:= args[1]
	create_template_directory(name_for_template)
}

run_list_command :: proc(args: ^[]string)
{
	list_templates()
}

run_init_template :: proc(args: ^[]string)
{
	if len(args) < 2
	{
		fmt.eprintfln("There is no name in the arguments")
	}
	name_for_template:= args[1]
	copy_template_files(name_for_template, args)
}

ARGUMENTS :: []Argument{
	Argument{
		identifier = "--help",
		abreviation = "-h",
		command = run_help_command
	},
	Argument{
		identifier = "--create-new-template",
		abreviation = "-c",
		command = run_create_new_template_command
	},
	Argument{
		identifier = "--list",
		abreviation = "-l",
		command = run_list_command
	},
	Argument{
		identifier = "--init",
		abreviation = "-i",
		command = run_init_template
	}
}

try_run_argument :: proc(in_argument: ^Argument, os_arguments: ^[]string) -> bool
{
	if os_arguments[0] != in_argument.abreviation && os_arguments[0] != in_argument.identifier
	{
		return false
	}
	in_argument.command(os_arguments)
	return true
}
