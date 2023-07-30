#!/usr/bin/env bash

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

kcs_main_start() {
  kcs_ld_lib commands

  _KCS_MAIN_MODE=true kcs_commands_load "$@"
}
