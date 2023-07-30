#!/usr/bin/env bash

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

export _KCS_COMMANDS_SEP="__"
export _KCS_COMMANDS_DEFAULT_NAME="_default"

## Using loader APIs to execute command using shell
## usage: `kcs_commands_load <arguments...>`
kcs_commands_load() {
  kcs_argument __kcs_commands_load "$@"
}

__kcs_commands_load() {
  local ns="load.commands"
  local extra="$1" raw="$2"
  shift 2

  local commands=("$@") args=()
  local index="${#commands[@]}"
  local filename="${commands[*]}"
  filename="${filename// /$_KCS_COMMANDS_SEP}"
  while true; do
    if [ "$index" -le 0 ]; then
      break
    fi

    args=("${commands[@]:$index}")
    if KCS_CMD_ARGS_RAW="$raw" \
      KCS_CMD_ARGS_EXTRA="$extra" \
      kcs_ld_cmd "$filename" "${args[@]}"; then
      return 0
    fi

    filename="${commands[*]:0:$((index - 1))}"
    filename="${filename// /$_KCS_COMMANDS_SEP}"

    ((index--))
  done

  kcs_log_debug "$ns" "cannot found command, fallback to %s command" \
    "$_KCS_COMMANDS_DEFAULT_NAME"
  KCS_CMD_ARGS_RAW="$raw" \
    KCS_CMD_ARGS_EXTRA="$extra" \
    kcs_ld_cmd_default "$_KCS_COMMANDS_DEFAULT_NAME" "${commands[@]}"
}

_kcs_commands_clean() {
  unset _KCS_COMMANDS_SEP _KCS_COMMANDS_DEFAULT_NAME
}
