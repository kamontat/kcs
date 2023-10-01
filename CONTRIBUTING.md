# Contributors

Thank you for investing your time in contributing to our project!

## Conventions

Because how bash script works, we need to set some convention
to make our code clean and easy to read.

There are 2 parts for naming convention: **variables** and **functions**.

### Variables

- For publicly **read-write** variables (setting), should be `KCS_<name>` template
- For publicly **read-only** variables (data), should be `_KCS_<name>` template
- For internal **read-write** variables (internal), should be `__KCS_<name>` template
    - Subject to change without notice

For Testing all variables should be `KCT_<name>` template.

### Functions

- For public APIs, should be `kcs_<module>_<name>` template
    - This can be used on either place including commands
    - It has notice period before deprecate and remove
- For private APIs, should be `_kcs_<module>_<name>` template
    - This should not use on any directory except 'private' and 'internal' lib
    - It has notice period before deprecate and remove
- For formatted APIs, should be `__kcs_<module>_<name>` template
    - All formatted APIs function will automatically called by internal process
    - This should not call directly

### Libraries and Utilities

Both libraries and utilities are the same in term of a helper functions
for developer. The main difference is libraries is internal provided
but utilities is user defined functions.
This is to prevent user accidently override internal libraries with same name.

There are few convention for create new library or utility listed below

1. All logic should insulate in function.
2. All exported variables should be cleanup afterward

Both libraries and utilities contains several lifecycle callback for setup

1. `__kcs_<name>_on_init <args...>` - This will called after loaded successfully
    - Use for loading dependencies (`kcs_ld_lib`)
    - Use for adding hooks (`kcs_hooks_add`)

## Commands

On commands script, we expose several variables to use

1. `$_KCS_CMD_NAME` - the command name (use for command callback and logging)
2. `$_KCS_CMD_KEY` - the command key (normallize command name for function safe)
3. `$_KCS_CMD_DESCRIPTION` - the command description (received from `KCS_CMD_DESCRIPTION=<desc>` on default environment)
4. `$_KCS_CMD_VERSION` - the command version (received from `KCS_CMD_VERSION=<0.0.0>` on default environment)
5. `$_KCS_CMD_PATH` - the full path of executing command
6. `$_KCS_CMD_DIRPATH` - the directory contains command script
7. `$_KCS_CMD_FILENAME` - the command filename
8. `$_KCS_CMD_ARGS` - the parsed arguments array
9. `$_KCS_CMD_ARGS_RAW` - the space separated string of raw arguments
10. `$_KCS_CMD_ARGS_EXTRA` - the space separated string of extra arguments
11. `$_KCS_OPT_<NAME>_VALUE` - the option value from user

## Arguments

The argument is string input from someone each pass to function. We specific argument to 4 types.

1. Direct Arguments (DA) - This is a argument send directly to function.
    - You can access by `$@` (array)
2. Parsed Arguments (PA) - This is a parsed argument that commands doesn't know what to do with it
    - You can access by `${_KCS_CMD_ARGS[@]}` (array)
3. Extra Arguments (EA) - This is a extra argument for extra command (arguments after '--' will consider as extra)
    - You can access by `$_KCS_CMD_ARGS_EXTRA` (string)
4. Raw Arguments (RA) - This is a raw argument as is from input (ALL arguments after '<>' will consider as raw)
    - You can access by `$_KCS_CMD_ARGS_RAW` (string)

## Tests

To simulate tests on Linux:

```bash
docker run --rm --interactive --tty --entrypoint /bin/bash --workdir "/work" -v "$PWD:/work" debian:stable-slim
```
