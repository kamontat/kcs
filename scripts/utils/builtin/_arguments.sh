#!/usr/bin/env bash
##example-utils:v1

## builtin/arguments:
##   arguments modifier
## Hook: init_utils
## Public functions:
##   `kcs_argument_override <args...>` - override user argument with input args

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

## Override user input argument with
## arguments passed to this function
## The arguments normally use as raw argument
## for passing options and commands
## @param $n - [required] overrided arguments
## @example  - kcs_argument_override --help
kcs_argument_override() {
  export KCS_ARGS
  KCS_ARGS=("$@")
}
