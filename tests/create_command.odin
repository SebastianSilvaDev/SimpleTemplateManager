package tests

import "core:fmt"
import "core:os"
import "core:testing"
import core "../src"

// These tests cover the create command (src: run_create_new_template_command ->
// create_template_directory). create_template_directory works against the real
// templates directory next to the test executable, so each test uses a unique
// template name and removes the folder it creates.

@(test)
test_create_template_directory_creates_folder_and_config :: proc(t: ^testing.T) {
	name := unique_name("CreateTest")
	defer delete(name)

	templates_dir, ok := create_and_locate(t, name)
	if !ok {
		return
	}
	template_dir := fmt.tprintf("%s\\%s", templates_dir, name)
	defer os.remove_all(template_dir)

	testing.expect(t, os.is_dir(template_dir), "template folder should be created")

	config_path := fmt.tprintf("%s\\%s", template_dir, core.TEMPLATE_CONFIG_FILE_NAME)
	testing.expectf(t, os.exists(config_path), "template folder should contain %s", core.TEMPLATE_CONFIG_FILE_NAME)
}

@(test)
test_create_template_directory_is_idempotent :: proc(t: ^testing.T) {
	name := unique_name("IdempotentTest")
	defer delete(name)

	templates_dir, ok := create_and_locate(t, name)
	if !ok {
		return
	}
	template_dir := fmt.tprintf("%s\\%s", templates_dir, name)
	defer os.remove_all(template_dir)

	// Creating the same template again should be a no-op, not a crash, and the
	// folder must still be there afterwards.
	core.create_template_directory(name)
	testing.expect(t, os.is_dir(template_dir), "template folder should still exist after second create")
}

// create_and_locate creates a template and returns the templates root directory
// so callers can build the expected path. Fails the test if the templates
// directory cannot be located.
@(private = "file")
create_and_locate :: proc(t: ^testing.T, name: string) -> (templates_dir: string, ok: bool) {
	core.create_template_directory(name)
	dir, found := core.get_template_directory(context.allocator)
	if !testing.expect(t, found, "templates directory should exist after create_template_directory") {
		return "", false
	}
	return dir, true
}
