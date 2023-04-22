#!/usr/bin/env bash
##utils-example:v1.0.0-beta.1

## builtin/debug:
##   add debugging hook to the script
## Requirement:
##   <none>
## Public functions:
##   <none>

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

__kcs_debug_key_value_format() {
  local ns="debugger-info"
  local key="$1" value="$2"

  kcs_debug "$ns" "%-15s: '%s'" \
    "$key" "$value"
}

## debugging hook
kcs_add_hook \
  pre_main __kcs_debug_pre_main
__kcs_debug_pre_main() {
  __kcs_debug_key_value_format \
    "$KCS_NAME" "$KCS_VERSION"
  __kcs_debug_key_value_format \
    "mode" "$KCS_MODE"
  __kcs_debug_key_value_format \
    "root" "$KCS_ROOT"
  __kcs_debug_key_value_format \
    "os" "$(uname -s)"
  __kcs_debug_key_value_format \
    "hostname" "$(hostname)"

  __kcs_debug_key_value_format \
    "original dir" "$_KCS_DIR_ORIG"
  __kcs_debug_key_value_format \
    "script dir" "$_KCS_DIR_SCRIPT"
  __kcs_debug_key_value_format \
    "root dir" "$_KCS_DIR_ROOT"
  __kcs_debug_key_value_format \
    "temp dir" "$_KCS_DIR_TEMP"
  __kcs_debug_key_value_format \
    "logs dir" "$_KCS_DIR_LOG"

  __kcs_debug_key_value_format \
    "entry mode" "$_KCS_ENTRY"
  __kcs_debug_key_value_format \
    "argument size" "$#"
  __kcs_debug_key_value_format \
    "arguments" "$*"
  __kcs_debug_key_value_format \
    "log levels" "$_KCS_LOG_LEVELS"

  __kcs_debug_key_value_format \
    "utilities" "$__KCS_LOADED_UTILS"
}
