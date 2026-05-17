package main

import "core:fmt"
import "core:os"

main :: proc()
{
	working_directory, err:= os.get_working_directory(context.allocator)
	fmt.printfln("%s", working_directory)
	arguments := os.args[1:]
	fmt.printfln("%v", arguments)
	delete(working_directory)
	if len(arguments) < 1
	{
		fmt.eprintfln("Error, no arguments found")
		return
	}

	for &argument in ARGUMENTS
	{
		try_run_argument(&argument, &arguments)
	}

}
