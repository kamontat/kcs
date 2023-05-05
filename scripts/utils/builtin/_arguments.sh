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

## Pass custom argument overwrote what user input
## @param $n - [required] overwrote arguments
## @example  - kcs_argument_override --help
kcs_argument_override() {
  export __KCS_CUSTOM_ARGS=true
  export KCS_ARGS
  KCS_ARGS=("$@")
}

kcs_add_hook clean \
  __kcs_argument_clean
__kcs_argument_clean() {
  unset KCS_ARGS __KCS_CUSTOM_ARGS
}
