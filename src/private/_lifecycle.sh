#!/usr/bin/env bash

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

__kcs_lifecycle_lc_init() {
  local ns="init.lifecycle"
  local name="$1"
  shift
  local args=("$@")

  ## Hooks APIs
  kcs_ld_lib hooks

  export _KCS_CMD_NAME="$name"
  # shellcheck disable=SC2016
  kcs_log_debug "$ns" "initiate %s variable to '%s'" '$_KCS_CMD_NAME' "$name"

  kcs_hooks_add pre_init "$name" @optional
  kcs_hooks_add main "$name" @raw "@varargs=$name.command"
  kcs_hooks_add pre_clean "$name" @optional

  ## Cleanup environment configuration
  kcs_hooks_add clean environment
  ## Cleanup logging variables
  kcs_hooks_add post_clean log
}
__kcs_lifecycle_lc_start() {
  local name="$1"
  shift

  kcs_hooks_start "$@"
  kcs_hooks_stop

  unset _KCS_CMD_NAME
}
