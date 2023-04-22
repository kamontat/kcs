#!/usr/bin/env bash

## Command functions:
##   a collection for manage commands

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

export __KCS_COMMAND_SEPARATOR="__"
export __KCS_ARGS_SEPARATOR="<>"
export __KCS_COMMAND_DEFAULT_NAME="_default.sh"

## call command if not found, use default
_kcs_load_command() {
  _kcs_find_command \
    "kcs_must_load" "__kcs_command_load_default" "$@"
}

## @param $1 - loading callback
##           - $cb "<base_path>" "<filename>" "<args...>"
##        $2 - not found callback
##           - $cb "<raw_args...>"
##        $n - raw arguments
##           - you can add `<>` to ensure value
##           - after must be argument not command name
##           - you after `<>` will send to callback as first args
_kcs_find_command() {
  local ns="command-finder"
  local load_cb="$1" miss_cb="$2"
  shift 2

  ## Split input array to command resolver list
  ## and force arguments
  local raw=("$@")
  local commands=() args=() is_arg arg
  for arg in "${raw[@]}"; do
    kcs_debug "$ns" "checking input %s" "$arg"
    if test -z "$is_arg"; then
      if [[ "$arg" == "$__KCS_ARGS_SEPARATOR" ]]; then
        is_arg=true
        continue
      fi
      kcs_debug "$ns" "add '%s' to commands resolver" "$arg"
      commands+=("$arg")
    else
      kcs_debug "$ns" "add '%s' to arguments" "$arg"
      args+=("$arg")
    fi
  done

  local base_path="$_KCS_DIR_COMMANDS"
  local index="${#commands[@]}" _fargs=() _targs=()
  local file_name="${commands[*]}"
  file_name="${file_name// /$__KCS_COMMAND_SEPARATOR}.sh"

  local file_path="$base_path/$file_name"

  while true; do
    if [ "$index" -le 0 ]; then
      break
    fi

    _fargs=("${commands[@]:0:$((index - 1))}")
    _targs=("${args[@]}")
    _targs+=("${commands[@]:$index}")

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

  ## This will remove <> separator out
  "$miss_cb" "${commands[@]}" "${args[@]}"
}

__kcs_command_load_default() {
  local args=("$@")
  local base_path="$_KCS_DIR_COMMANDS"
  local default="$__KCS_COMMAND_DEFAULT_NAME"
  kcs_must_load "$base_path" "$default" "${args[@]}"
}
