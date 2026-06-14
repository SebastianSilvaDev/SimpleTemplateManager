package build

import "core:fmt"
import "core:log"
import "core:strings"
import os "core:os"

main :: proc ()
{
    context.logger = log.create_console_logger()

    arguments:= os.args[1:]

    is_debug: bool = false

    for argument in arguments
    {
   		switch argument
     	{
      		case "-debug":
      			is_debug = true
        	case:
     	}
    }

    DIR := "build" if is_debug else "bin"
    build_directory:= fmt.tprintf("%s%s", "./", DIR)
    if os.exists(build_directory)
    {}
    else
    {
        err := os.make_directory(DIR)
        if err != nil
        {
            log.errorf("Error creating build directory: {}", err)
            os.exit(1)
        }
    }

    EXE :: "TemplateManager"
    OUT :: EXE + ".exe" when ODIN_OS == .Windows else EXE
    DEBUG_FLAG :: "-debug"
    COMMAND:: "odin build src"
    out_dir:= fmt.tprintf("-out:%s/%s", DIR, OUT)
    command_args := make([dynamic]string, 0, 10) // maybe capacity can be more lets see
    defer delete(command_args)
    append(&command_args, COMMAND)
    if is_debug
    {
    	append(&command_args, DEBUG_FLAG)
    }
    append(&command_args, out_dir);
    append(&command_args, "-error-pos-style:unix")
    final_command : string = strings.join(command_args[:], " ")
    run_str(final_command)

}

run_str :: proc(cmd: string)
{
    run(strings.split(cmd, " "))
}

run :: proc(cmd: []string)
{
    log.infof("Running {}", cmd)
    code, err := exec(cmd)
    if err != nil
    {
        log.errorf("Error executing process: {}", err)
        os.exit(1)
    }
    if code != 0
    {
        log.errorf("Process exited with non-zero code {}", code)
        os.exit(code)
    }
}

exec :: proc(cmd: []string) -> (code: int, error: os.Error)
{
    process := os.process_start({command = cmd, stdin = os.stdin, stdout = os.stdout, stderr = os.stderr}) or_return
    state:= os.process_wait(process) or_return
    os.process_terminate(process) or_return
    return state.exit_code, nil;
}
