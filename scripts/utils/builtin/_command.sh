#!/usr/bin/env bash
##utils-example:v1.0.0-beta.2

## builtin/command:
##   call command
## Public functions:
##   `kcs_call_command <args...>` - call command by input argument

## NOTE: All utility files must formatted as `_<name>.sh`.

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

kcs_utils_register "builtin/command"

## call command by input argument
## @param $n - [required] command argument
## @exit     - error if command not found or failed
## @example  - kcs_call_command "test" "hello"
kcs_call_command() {
  ## _kcs_find_command is exported from internal _commands.sh
  _kcs_find_command \
    "kcs_must_load" "__kcs_command_load_error" "$@"
}

## internal callback for _kcs_find_command.
## this will throw error if command load failed
## @param $n - [optional] command arguments
## @exit     - error with command failed message
__kcs_command_load_error() {
  local ns="command-finder"
  kcs_throw "$KCS_EC_CMD_NOT_FOUND" "$ns" \
    "command '%s' not found" \
    "$*"
}
