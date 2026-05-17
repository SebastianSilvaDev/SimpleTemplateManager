package main

import "core:strings"
import "core:log"
import "core:os"
import "core:fmt"
import "core:encoding/json"

TEMPLATE_CONFIG_FILE_NAME:: ".template"
VERSION:int: 1

TemplateConfig :: struct
{
	version: int,
	name: string
}

create_basic_template_file :: proc(in_directory: string, template_name: string)
{

	filename := strings.join({in_directory, TEMPLATE_CONFIG_FILE_NAME}, "\\", context.allocator)
	file, err:= os.open(filename, {.Create})
	if err != nil
	{
		log.errorf("Error While Creating File %s", err)
		return
	}
	defer os.close(file)
	new_template_config:= TemplateConfig{
		version = VERSION,
		name = template_name
	}
	data, json_err:=json.marshal(new_template_config)
	if json_err != nil
	{
		log.errorf("Error While Creating JSON Data %s")
		return
	}
	defer delete(data)

	bites_written, write_err:= os.write(file, data)
	if write_err != nil
	{
		log.errorf("Error while writting the base config file")
		return
	}
}
