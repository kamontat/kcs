#!/usr/bin/env bash

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

kcs_command_start() {
  if test -z "$_KCS_MAIN_MODE"; then
    kcs_argument __kcs_command_start "$@"
  else
    __kcs_command_start '' '' "$@"
  fi
}

__kcs_command_start() {
  local ns="private.command.start"
  local raw="$1" extra="$2" name="$3"
  shift 3

  test -n "$extra" && _KCS_CMD_ARGS_EXTRA="$extra"
  test -n "$raw" && _KCS_CMD_ARGS_RAW="$raw"

  _KCS_CMD_PATH="$0"
  kcs_log_debug "$ns" "set command path to '%s'" "$_KCS_CMD_PATH"
  _KCS_CMD_DIRPATH="$(dirname "$_KCS_CMD_PATH")"
  _KCS_CMD_FILENAME="$(basename "$_KCS_CMD_PATH")"

  local message="start '$name' command"
  if [ "$#" -gt 0 ]; then
    message="$message with $# args [$*]"
  else
    message="$message without args"
  fi
  test -n "${_KCS_CMD_ARGS_RAW:-}" &&
    message="$message with raw args [$_KCS_CMD_ARGS_RAW]"
  test -n "${_KCS_CMD_ARGS_EXTRA:-}" &&
    message="$message with extra args [$_KCS_CMD_ARGS_EXTRA]"

  kcs_log_debug "$ns" "$message"
  _kcs_ld_priv lifecycle "$name" "$@"
}
