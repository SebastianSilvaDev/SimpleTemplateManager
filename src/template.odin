package main

import "core:bufio"
import "core:strings"
import "core:log"
import "core:os"
import "core:fmt"
import "core:encoding/json"

TEMPLATE_CONFIG_FILE_NAME:: "template.json"
VERSION:int: 1

TemplateParamsToReplace :: struct
{
	param_map: map[string]string
}

TemplateParam :: struct
{
	name: string,
	value: string
}

TemplateConfig :: struct
{
	version: int,
	name: string,
	params: []TemplateParam
}

make_template_params_to_replace :: proc() -> TemplateParamsToReplace
{
	new_template_params_to_replace := TemplateParamsToReplace{
		param_map = make(map[string]string)
	}
	return new_template_params_to_replace
}

fill_templates_params :: proc(config : ^TemplateConfig) -> (TemplateParamsToReplace, bool)
{
	template_params_to_replace := make_template_params_to_replace()
	instream:= os.to_stream(os.stdin)
	scanner: bufio.Scanner
	bufio.scanner_init(&scanner, instream, context.temp_allocator)
	for &param in config.params
	{
		fmt.printfln("Input param %s", param.name)
		if !bufio.scanner_scan(&scanner)
		{
			return template_params_to_replace, false
		}
		inputed_value := bufio.scanner_text(&scanner)
		template_params_to_replace.param_map[param.value] = inputed_value
	}
	return template_params_to_replace, true
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

get_template_file :: proc(in_directory: string) -> (TemplateConfig, bool)
{
	filename := strings.join({in_directory, TEMPLATE_CONFIG_FILE_NAME}, "\\", context.allocator)
	file, err:= os.read_entire_file_from_path(filename, context.allocator)
	if err != nil
	{
		fmt.eprintfln("Error While Creating File %s", err)
		return {}, false
	}
	defer delete(file)
	config: TemplateConfig
	json_err:= json.unmarshal(file, &config)
	if json_err != nil
	{
		fmt.eprintfln("Error While parsing JSON %s", json_err)
		return {}, false
	}

	return config, true
}
