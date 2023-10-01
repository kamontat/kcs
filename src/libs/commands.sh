#!/usr/bin/env bash

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

## Using loader APIs to execute command using shell
## usage: `kcs_commands_load <arguments...>`
## variables:
##   - KCS_CMDSEP='/' override command separator
##   - KCS_CMDDEF='_default' override default command name
kcs_commands_load() {
  kcs_argument _kcs_commands_load "$@"
}

_kcs_commands_load() {
  local ns="libs.commands.load"
  local sep="${KCS_CMDSEP:-/}"
  local default="${KCS_CMDDEF:-_default}"
  local raw="$1" extra="$2"
  shift 2

  local commands=("$@") args=()
  local index="${#commands[@]}" current
  local filepath="${commands[*]}"
  filepath="${filepath// /$sep}"
  while true; do
    if [ "$index" -le 0 ]; then
      break
    fi

    args=("${commands[@]:$index}")
    current="${filepath##*"$sep"}"

    kcs_log_debug "$ns" "current argument is '%s'" "$current"
    kcs_log_debug "$ns" "current filepath is '%s'" "$filepath"
    if [[ "$current" =~ ^- ]]; then
      kcs_log_debug "$ns" "options cannot be path, skipped (%s)" "$current"
    else
      if _KCS_CMD_ARGS_RAW="$raw" \
        _KCS_CMD_ARGS_EXTRA="$extra" \
        kcs_ld_cmd "$filepath" "${args[@]}"; then
        return 0
      fi
    fi

    filepath="${commands[*]:0:$((index - 1))}"
    filepath="${filepath// /$sep}"
    ((index--))
  done

  kcs_log_debug "$ns" \
    "cannot found command, fallback to %s command" "$default"
  _KCS_CMD_ARGS_RAW="$raw" \
    _KCS_CMD_ARGS_EXTRA="$extra" \
    _kcs_commands_default "$default" "${commands[@]}"
}

_kcs_commands_default() {
  _kcs_ld_do shell nothing throw throw cmd "$@"
}
