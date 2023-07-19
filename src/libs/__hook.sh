#!/usr/bin/env bash

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

## cb will send callback as first parameter
export KCS_HOOK_TAG_CALLBACK="@cb"
## optional mean can be missing but cannot fail
export KCS_HOOK_TAG_OPTIONAL="@optional"
## raw will send raw user argument to callback
export KCS_HOOK_TAG_RAW="@raw"
## silent mean can be missing or fail
export KCS_HOOK_TAG_SILENT="@silent"
## add arguments from input variable name
export KCS_HOOK_TAG_VARARGS="@varargs"

_KCS_HOOK_VAR_PREFIX="__kcs_hook"
_KCS_HOOK_DISABLE_VAR_PREFIX="__kcs_hook_disabled"
_KCS_HOOK_DISABLE_ALL_VAR_PREFIX="__kcs_hook_disabled_all"

_KCS_HOOK_NAMES=(
  pre_init init post_init
  pre_main main post_main
  pre_clean clean post_clean
)

_KCS_HOOK_TAGS=(
  "$KCS_HOOK_TAG_CALLBACK"
  "$KCS_HOOK_TAG_OPTIONAL"
  "$KCS_HOOK_TAG_RAW"
  "$KCS_HOOK_TAG_SILENT"
  "$KCS_HOOK_TAG_VARARGS"
)

## add new callback to input hook
## usage: `kcs_hook_add '<hook>' '<callback>' [tags...]`
kcs_hook_add() {
  local ns="add.hook"
  local hook="$1" callback="$2"
  shift 2

  if ! [[ "${_KCS_HOOK_NAMES[*]}" =~ $hook ]]; then
    kcs_log_warn "$ns" "invalid hook name '%s'" "$hook"
    return 1
  fi

  local prev=()
  eval "prev=(\"\${${_KCS_HOOK_VAR_PREFIX}_${hook}[@]}\")"
  if [[ "${prev[*]}" =~ $callback ]]; then
    kcs_log_debug "$ns" "ignored duplicate '%s' on '%s' hook" \
      "$callback" "$hook"
    return 0
  fi
}
