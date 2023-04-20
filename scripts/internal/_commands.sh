#!/usr/bin/env bash

## Command functions:
##   a collection for manage commands

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

export __KCS_COMMAND_SEPARATOR="__"
export __KCS_COMMAND_DEFAULT_NAME="_default.sh"

## call command if not found, use default
_kcs_load_command() {
  _kcs_find_command \
    "kcs_must_load" "__kcs_command_load_default" "$@"
}

_kcs_find_command() {
  local ns="command-finder"
  local load_cb="$1" not_found_cb="$2"
  shift 2

  local index="$#" args=("$@") _fargs=() _targs=()
  local base_path="$_KCS_DIR_COMMANDS"
  local file_name="${args[*]}"
  file_name="${file_name// /$__KCS_COMMAND_SEPARATOR}.sh"
  local file_path="$base_path/$file_name"

  while true; do
    if [ $index -le 0 ]; then
      break
    fi

    _fargs=("${args[@]:0:$((index - 1))}")
    _targs=("${args[@]:$index}")

    kcs_debug "$ns" "index %d | checking file %s with '%s'" \
      "$index" "$file_name" "${_targs[*]}"

    if test -f "$file_path"; then
      "$load_cb" "$base_path" "$file_name" "${_targs[@]}"
      return $?
    fi

    file_name="${_fargs[*]}"
    file_name="${file_name// /$__KCS_COMMAND_SEPARATOR}.sh"
    file_path="$base_path/$file_name"

    ((index--))
  done

  "$not_found_cb" "${args[@]}"
}

__kcs_command_load_default() {
  local args=("$@")
  local base_path="$_KCS_DIR_COMMANDS"
  local default="$__KCS_COMMAND_DEFAULT_NAME"
  kcs_must_load "$base_path" "$default" "${args[@]}"
}
