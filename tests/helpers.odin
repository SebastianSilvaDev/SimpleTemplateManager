package tests

import "core:fmt"
import "core:os"
import "core:sync"
import "core:testing"
import "core:time"

// A monotonically increasing counter so that names generated within the same
// nanosecond (or across test threads) never collide.
@(private = "file")
name_counter: int

// unique_name returns a filesystem-safe name that is unique per call. Tests
// operate on the *real* templates directory next to the test executable, so
// every test must use a fresh name to stay isolated from other tests and from
// any templates the user already has on disk.
unique_name :: proc(prefix: string, allocator := context.allocator) -> string {
	n := sync.atomic_add(&name_counter, 1)
	return fmt.aprintf("%s_%d_%d", prefix, time.now()._nsec, n, allocator = allocator)
}

// make_temp_test_dir creates an empty temporary directory and returns its path.
// The caller owns the returned string and is responsible for removing the
// directory (see remove_test_dir). Fails the test if the directory cannot be
// created.
make_temp_test_dir :: proc(t: ^testing.T, loc := #caller_location) -> (dir: string, ok: bool) {
	path, err := os.make_directory_temp("", "TM_Test_*", context.allocator)
	if !testing.expectf(t, err == nil, "could not create temp directory: %v", err, loc = loc) {
		return "", false
	}
	return path, true
}

// remove_test_dir deletes a directory tree created during a test and frees the
// path string. Safe to call in a deferred statement.
remove_test_dir :: proc(dir: string) {
	if dir != "" {
		os.remove_all(dir)
		delete(dir)
	}
}
