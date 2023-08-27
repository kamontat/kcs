#!/usr/bin/env bash

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

__kcs_lifecycle_lc_init() {
  local ns="init.lifecycle"
  local name="$1"

  ## Hooks APIs
  kcs_ld_lib hooks
  kcs_ld_lib environment
  kcs_ld_lib configs

  export _KCS_CMD_NAME="$name"
  # shellcheck disable=SC2016
  kcs_log_debug "$ns" "initiate %s variable to '%s'" '$_KCS_CMD_NAME' "$name"

  kcs_hooks_add setup tmp
  kcs_hooks_add setup "$name" @optional
  kcs_hooks_add pre_load "$name" @optional
  kcs_hooks_add main "$name" @raw "@varargs=$name.command"
  kcs_hooks_add pre_clean "$name" @optional

  ## Cleanup temporary variables
  kcs_hooks_add post_clean tmp
  ## Cleanup logging variables
  kcs_hooks_add post_clean log
  ## Cleanup colors variables
  kcs_hooks_add post_clean color
}
__kcs_lifecycle_lc_start() {
  local name="$1"
  shift

  kcs_hooks_start "$@"
  kcs_hooks_stop

  unset _KCS_CMD_NAME
}
