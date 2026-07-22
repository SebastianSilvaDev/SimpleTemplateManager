package tests

import "core:os"
import "core:strings"
import "core:testing"
import core "../src"

// These tests cover the template config file layer in src/template.odin:
// writing a base template.json (create_basic_template_file) and reading it
// back (get_template_file). Both take an explicit directory, so they can run
// against an isolated temp directory.

@(test)
test_create_basic_template_file_writes_config :: proc(t: ^testing.T) {
	dir, dir_ok := make_temp_test_dir(t)
	if !dir_ok {
		return
	}
	defer remove_test_dir(dir)

	core.create_basic_template_file(dir, "MyTemplate")

	config_path := strings.join({dir, core.TEMPLATE_CONFIG_FILE_NAME}, "\\", context.allocator)
	defer delete(config_path)

	testing.expectf(
		t,
		os.exists(config_path),
		"expected %s to be created",
		core.TEMPLATE_CONFIG_FILE_NAME,
	)
}

@(test)
test_get_template_file_round_trips :: proc(t: ^testing.T) {
	dir, dir_ok := make_temp_test_dir(t)
	if !dir_ok {
		return
	}
	defer remove_test_dir(dir)

	NAME :: "RoundTripTemplate"
	core.create_basic_template_file(dir, NAME)

	config, ok := core.get_template_file(dir)
	if !testing.expect(t, ok, "get_template_file should succeed for a written config") {
		return
	}
	defer core.delete_template_config(&config)

	testing.expect_value(t, config.name, NAME)
	testing.expect_value(t, config.version, core.VERSION)
}

@(test)
test_get_template_file_missing_returns_false :: proc(t: ^testing.T) {
	// A fresh temp directory has no template.json, so reading it must fail
	// cleanly rather than crash.
	dir, dir_ok := make_temp_test_dir(t)
	if !dir_ok {
		return
	}
	defer remove_test_dir(dir)

	config, ok := core.get_template_file(dir)
	testing.expect(t, !ok, "get_template_file should fail when template.json is absent")
	if (ok)
	{
		core.delete_template_config(&config)
	}
}
