package main

import "core:mem"
import "core:fmt"
import "core:os"

main :: proc() {

	when ODIN_DEBUG
	{
		track: mem.Tracking_Allocator
		mem.tracking_allocator_init(&track, context.allocator)
		context.allocator = mem.tracking_allocator(&track)
		defer {
			mem.tracking_allocator_destroy(&track)
			if len(track.allocation_map) > 0
			{
				fmt.eprintf("Leaked allocations: %v\n", len(track.allocator_map))
			}
		}
	}

	working_directory, err := os.get_working_directory(context.allocator)
	fmt.printfln("%s", working_directory)
	arguments := os.args[1:]
	fmt.printfln("%v", arguments)
	delete(working_directory)
	if len(arguments) < 1 {
		fmt.eprintfln("Error, no arguments found")
		return
	}

	for &argument in ARGUMENTS {
		success := try_run_argument(&argument, &arguments)
		if success {
			return
		}
	}

	fmt.eprintf("Error, no valid argument found")

}
