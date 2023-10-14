#!/usr/bin/env bash

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

__kcs_lifecycle_on_init() {
  local ns="private.lifecycle.on.init"
  local name="$1"
  shift

  ## Hooks APIs
  kcs_ld_lib hooks
  kcs_ld_lib environment
  kcs_ld_lib configs

  local key
  key="${name//[ -.]/_}"
  key="$(printf '%s' "$key" | tr '[:upper:]' '[:lower:]')"

  export _KCS_CMD_KEY="$key"
  kcs_log_debug "$ns" "initiate $%s variable to '%s'" '_KCS_CMD_KEY' "$key"
  export _KCS_CMD_NAME="$name"
  kcs_log_debug "$ns" "initiate $%s variable to '%s'" '_KCS_CMD_NAME' "$name"

  kcs_hooks_add setup tmp
  kcs_hooks_add setup "$key" @optional
  kcs_hooks_add pre_load "$key" @optional
  kcs_hooks_add main "$key" @raw "@varargs=cmd.$key"
  kcs_hooks_add pre_clean "$key" @optional

  ## Cleanup temporary variables
  kcs_hooks_add post_clean tmp
  ## Cleanup logging variables
  kcs_hooks_add post_clean log
  ## Cleanup colors variables
  kcs_hooks_add post_clean color

  kcs_hooks_start "$@"
  kcs_hooks_stop

  unset _KCS_CMD_KEY _KCS_CMD_NAME
}
