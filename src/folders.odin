package main

import "base:runtime"
import "core:strings"
import "core:log"
import "core:fmt"
import "core:os"

TEMPLATE_DIR_NAME :: "templates"

does_template_directory_exists :: proc() -> bool
{
	executable_dir, dir_err := os.get_executable_directory(context.allocator)
	if (dir_err	!= nil)
	{
		fmt.eprintfln("Fatal Error %s", dir_err)
		return false
	}
	template_dir:= fmt.tprintf("%s\\%s", executable_dir, TEMPLATE_DIR_NAME)
	return os.is_dir(template_dir)
}

create_folder_structure :: proc() -> bool
{
	executable_dir, dir_err := os.get_executable_directory(context.allocator)
	if (dir_err	!= nil)
	{
		fmt.eprintfln("Fatal Error %s", dir_err)
		return false
	}

	fmt.printfln("%s", executable_dir)

	directory:= fmt.tprintf("%s\\%s", executable_dir, TEMPLATE_DIR_NAME)

	create_err := os.make_directory(directory)
	if (create_err != nil)
	{
		fmt.eprintfln("Fatal Error While creating Directory %s", create_err)
		return false
	}
	return true
}

list_templates :: proc()
{
	if (!does_template_directory_exists())
	{
		success:= create_folder_structure()
		if (!success) {return}
	}
	executable_dir, dir_err := os.get_executable_directory(context.allocator)
	if (dir_err	!= nil)
	{
		fmt.eprintfln("Fatal Error %s", dir_err)
		return
	}

	template_directory:= fmt.tprintf("%s\\%s", executable_dir, TEMPLATE_DIR_NAME)
	file_infos, file_err:= os.read_all_directory_by_path(template_directory, context.allocator)
	if (file_err != nil)
	{
		fmt.eprintfln("Couldn't Get Any Files from directory %s", file_err)
		return
	}
	fmt.printfln("Available Templates:")
	for &info in file_infos
	{
		if info.type == .Directory
		{
			fmt.printfln("%s", info.name)
		}
	}
}

get_template_directory :: proc(allocator: runtime.Allocator = context.allocator) -> (dir: string, ok: bool)
{
	if !does_template_directory_exists()
	{
		return "", false
	}

	executable_dir, dir_err := os.get_executable_directory(context.allocator)
	if (dir_err	!= nil)
	{
		fmt.eprintfln("Fatal Error %s", dir_err)
		return "", false
	}

	template_dir:= fmt.tprintf("%s\\%s", executable_dir, TEMPLATE_DIR_NAME)
	return template_dir, true
}

create_template_directory :: proc(template_name: string)
{
	if (!does_template_directory_exists())
	{
		success:= create_folder_structure()
		if (!success) {return}
	}

	template_directory, ok:= get_template_directory(context.allocator)
	if (!ok)
	{
		fmt.eprintfln("Template Directory couln't be found")
		return
	}
	directory:= fmt.tprintf("%s\\%s", template_directory, template_name)
	if os.is_dir(directory)
	{
		fmt.printfln("Directory already Exists")
		return
	}
	create_error:= os.make_directory(directory)
	if (create_error != nil)
	{
		fmt.eprintfln("Error Creating Directory %s", create_error)
		return
	}

	create_basic_template_file(directory, template_name)

	fmt.printfln("Template Folder Created at %s", directory)
}
