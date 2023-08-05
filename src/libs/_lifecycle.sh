#!/usr/bin/env bash

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

__kcs_lifecycle_init() {
  local ns="init.lifecycle"
  local name="$1"
  shift
  local args=("$@")

  ## Hooks APIs
  kcs_ld_lib hooks

  export KCS_CMD_NAME="$name"

  kcs_hooks_add main "$name" \
    @raw "@varargs=$name.command"

  kcs_hooks_add clean commands @optional
  kcs_hooks_add post_clean log
}

__kcs_lifecycle_start() {
  kcs_hooks_start "$@"
  kcs_hooks_stop

  unset KCS_CMD_NAME
}
