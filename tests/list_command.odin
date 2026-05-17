package tests

import "core:fmt"
import "core:log"
import "core:os"
import "core:testing"
import core "../src"

@(test)
test_list_command :: proc(t: ^testing.T)
{
	if !core.does_template_directory_exists()
	{
		core.create_folder_structure()
	}
	executable_dir, dir_err := os.get_executable_directory(context.allocator)
	if dir_err != nil
	{
		log.errorf("Couln't find executable directory %s", dir_err)
		testing.fail(t)
		return
	}
	PATTERN:: "TempFolder"
	temp_testing_dir := fmt.tprintf("%s\\%s", executable_dir, )
	// os.make_directory_temp()
}
