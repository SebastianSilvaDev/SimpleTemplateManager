package tests

import "core:fmt"
import "core:os"
import "core:testing"
import core "../src"

// These tests cover the list command (src: run_list_command -> list_templates)
// and the folder-structure helpers it relies on. list_templates only prints to
// stdout, so the tests assert on the observable state it reads from:
// does_template_directory_exists and the contents of the templates directory.

@(test)
test_templates_directory_is_ensured :: proc(t: ^testing.T) {
	if !core.does_template_directory_exists() {
		testing.expect(t, core.create_folder_structure(), "create_folder_structure should succeed")
	}
	testing.expect(t, core.does_template_directory_exists(), "templates directory should exist")
}

@(test)
test_created_template_appears_in_listing :: proc(t: ^testing.T) {
	name := unique_name("ListTest")
	defer delete(name)

	core.create_template_directory(name)

	templates_dir, ok := core.get_template_directory(context.allocator)
	if !testing.expect(t, ok, "templates directory should exist") {
		return
	}
	template_dir := fmt.tprintf("%s\\%s", templates_dir, name)
	defer os.remove_all(template_dir)

	// Mirror what list_templates prints: the directory entries under the
	// templates root. The template we just created must be one of them.
	infos, err := os.read_all_directory_by_path(templates_dir, context.allocator)
	if !testing.expectf(t, err == nil, "should read templates directory: %v", err) {
		return
	}
	defer os.file_info_slice_delete(infos, context.allocator)

	found := false
	for info in infos {
		if info.type == .Directory && info.name == name {
			found = true
			break
		}
	}
	testing.expectf(t, found, "expected template %q to appear in the listing", name)
}

@(test)
test_list_templates_runs_without_crashing :: proc(t: ^testing.T) {
	// list_templates has no return value; this is a smoke test that it creates
	// the folder structure if needed and completes.
	core.list_templates()
	testing.expect(t, core.does_template_directory_exists(), "templates directory should exist after list_templates")
}
