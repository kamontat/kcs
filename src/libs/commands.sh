#!/usr/bin/env bash

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

## Throw errors either missing or failed
## kcs_commands_load_required <command> <args...>
kcs_commands_load_required() {
  _kcs_ld_do \
    --module commands \
    --key commands \
    --suffix .sh \
    --action shell \
    --on-missing throw \
    --on-error throw \
    -- "$@"
}

## Silent error message if missing or throw error if failed
## kcs_commands_load_optional <command> <args...>
kcs_commands_load_optional() {
  _kcs_ld_do \
    --module commands \
    --key commands \
    --suffix .sh \
    --action shell \
    --on-missing silent \
    --on-error throw \
    -- "$@"
}

## Mute if command is missing or write error logs if its failed
## kcs_commands_load_mute <command> <args...>
kcs_commands_load_mute() {
  _kcs_ld_do \
    --module commands \
    --key commands \
    --suffix .sh \
    --action shell \
    --on-missing mute \
    --on-error error \
    -- "$@"
}

## Finding commands based on input argument and execute using cmd loader
## usage: `kcs_commands_find <arguments...>`
## variables:
##   - KCS_CMDSEP='/' override command separator
##   - KCS_CMDDEF='_default' override default command name
kcs_commands_find() {
  kcs_argument __kcs_commands_find "$@"
}

## Alias current command to different command using cmd loader
## This should be called from setup hook
## usage: `kcs_commands_alias <commands...>`
kcs_commands_alias() {
  local ns="libs.commands.alias"

  local args=("${_KCS_CMD_ARGS[@]}")
  local raw="$_KCS_CMD_ARGS_RAW"
  local extra="$_KCS_CMD_ARGS_EXTRA"

  local sep="${KCS_CMDSEP:-/}"
  local commands=("$@")

  local filepath="${commands[*]}"
  filepath="${filepath// /$sep}"

  kcs_commands_load_required "$filepath" "${args[@]}"
  kcs_exit "$?"
}

__kcs_commands_find() {
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
        kcs_commands_load_optional "$filepath" "${args[@]}"; then
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
    kcs_commands_load_required "$default" "${commands[@]}"
}

__kcs_commands_ld_acb_shell() {
  local ns="libs.commands.loader.shell"
  local key="$1" name="$2" filepath="$3"
  shift 3

  local runner
  ## Prefer bash first. if missing, use default shell instead
  runner="$(command -v bash)"
  test -z "$runner" && runner="$SHELL"

  kcs_log_debug "$ns" "run '%s' using '%s' with %d args [%s]" \
    "$filepath" "$(basename "$runner")" "$#" "$*"
  "$runner" "$filepath" "$@"
}
