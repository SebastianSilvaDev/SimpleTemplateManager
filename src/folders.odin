package main

import "base:runtime"
import "core:strings"
import "core:log"
import "core:fmt"
import "core:os"

TEMPLATE_DIR_NAME :: "templates"

does_template_directory_exists :: proc() -> bool
{
	executable_dir, dir_err := os.get_executable_directory(context.temp_allocator)
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
	executable_dir, dir_err := os.get_executable_directory(context.temp_allocator)
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
	executable_dir, dir_err := os.get_executable_directory(context.temp_allocator)
	if (dir_err	!= nil)
	{
		fmt.eprintfln("Fatal Error %s", dir_err)
		return
	}

	template_directory:= fmt.tprintf("%s\\%s", executable_dir, TEMPLATE_DIR_NAME)
	file_infos, file_err:= os.read_all_directory_by_path(template_directory, context.temp_allocator)
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

	executable_dir, dir_err := os.get_executable_directory(context.temp_allocator)
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

	template_directory, ok:= get_template_directory(context.temp_allocator)
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

get_template_folder :: proc(template_name: string) -> (string, bool)
{
	if !does_template_directory_exists()
	{
		fmt.eprintfln("No Templates Found")
		return "", false
	}

	templates_directory, ok:= get_template_directory(context.allocator)
	if !ok
	{
		fmt.eprintfln("No templates found")
		return "", false
	}

	template_directory := fmt.tprintf("%s\\%s", templates_directory, template_name)
	if !os.is_directory(template_directory)
	{
		fmt.eprintfln("No Template with that name exists")
		return "", false
	}

	return template_directory, true
}

copy_template_files :: proc(template_name: string, args: ^[]string)
{
	template_forlder, template_folder_ok:= get_template_folder(template_name)
	if !template_folder_ok
	{
		fmt.eprintfln("Error, couldn't find template folder")
		return
	}

	workind_directory, working_dir_err:= os.get_working_directory(context.allocator)
	if working_dir_err != nil
	{
		fmt.eprintfln("Error %s", working_dir_err)
		return
	}

	template_config, ok:= get_template_file(template_forlder)
	if (!ok)
	{
		fmt.eprintfln("Error while getting template config file")
		return
	}
	defer delete_template_config(&template_config)
	parameters_to_replace, params_ok:= fill_templates_params(&template_config)
	if (!params_ok)
	{
		fmt.eprintf("Error while loading paramters for template")
		return
	}
	copy_directory(template_forlder, workind_directory, &parameters_to_replace)
}

copy_directory :: proc (folder_directory, target_directory: string, parameters_data: ^TemplateParamsToReplace) -> bool
{
	walker:= os.walker_create(folder_directory)
	defer os.walker_destroy(&walker)
	for
	{
		file_info, ok:= os.walker_walk(&walker)
		if !ok
		{
			break
		}
		if file_info.type == .Directory
		{
			new_target_dir:= fmt.aprintf("%s\\%s", target_directory, file_info.name)
			os.make_directory(new_target_dir)
			delete(new_target_dir)
		}
		else if file_info.type == .Regular
		{
			if file_info.name == "template.json"
			{
				continue
			}
			folder_dir_length:=len(folder_directory)
			folder_string := file_info.fullpath[folder_dir_length:]
			file_data, file_ok:=os.read_entire_file_from_path(file_info.fullpath, context.allocator)
			new_file_path:= fmt.tprintf("%s\\%s", target_directory, folder_string)
			new_string_builder:= strings.builder_make()
			strings.write_bytes(&new_string_builder, file_data)
			for name, param in parameters_data.param_map
			{
				strings.builder_replace_all(&new_string_builder, name, param)
			}
			new_file_data:= strings.to_string(new_string_builder)
			data_to_write:= transmute([]byte)(new_file_data)
			write_ok:=os.write_entire_file(new_file_path, new_file_data)
			defer delete(file_data)
		}
	}
	return true
}
