#!/usr/bin/env bash

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

# shellcheck source=/dev/null
source "${KCS_DIR_SRC:?}/libs/_base.sh" || exit 1

## Because main script didn't start lifecycle
## So we have to initiate here instead
_kcs_log_init

## Start main scripts
_kcs_main_start() {
  kcs_ld_load source with_throw lib command

  local ns="main.lib"

  kcs_log_debug "$ns" "start main libraries scripts"
  kcs_cmd_find source with_throw "$@"
}
