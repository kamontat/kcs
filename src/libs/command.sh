#!/usr/bin/env bash

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

kcs_command_start() {
  ## Command default lifecycle
  kcs_ld_lib lifecycle

  if test -z "$_KCS_MAIN_MODE"; then
    kcs_argument __kcs_command_start "$@"
  else
    __kcs_command_start '' '' "$@"
  fi
}

__kcs_command_start() {
  local ns="command.lib"
  local extra="$1" raw="$2" name="$3"
  shift 3

  test -n "$extra" && KCS_CMD_ARGS_EXTRA="$extra"
  test -n "$raw" && KCS_CMD_ARGS_RAW="$raw"

  local message="start '$name' command"
  if [ "$#" -gt 0 ]; then
    message="$message with $# args [$*]"
  else
    message="$message without args"
  fi
  test -n "${KCS_CMD_ARGS_RAW:-}" &&
    message="$message with raw args [$KCS_CMD_ARGS_RAW]"
  test -n "${KCS_CMD_ARGS_EXTRA:-}" &&
    message="$message with extra args [$KCS_CMD_ARGS_EXTRA]"

  local main="__kcs_${name}_main"
  if ! command -v "$main" >/dev/null; then
    kcs_log_warn "$ns" "missing commands main (%s) function" "$main"
    return 1
  fi

  kcs_log_debug "$ns" "$message"
  __kcs_lifecycle_init "$name" "$main" "$@"
  __kcs_lifecycle_start "$@"
}
