#!/usr/bin/env bash

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

__kcs_lifecycle_init() {
  local ns="init.lifecycle"
  local name="$1" main="$2" args=()
  shift 2
  args=("$@")

  ## Hooks APIs
  kcs_ld_lib hooks

  export KCS_CMD_NAME="$name"

  kcs_hooks_add main "$main" \
    @raw "@varargs=$name.command"

  kcs_hooks_add clean _kcs_commands_clean @optional

  kcs_hooks_add post_clean _kcs_log_clean
}

__kcs_lifecycle_start() {
  kcs_hooks_start "$@"
  kcs_hooks_stop

  unset KCS_CMD_NAME
}
