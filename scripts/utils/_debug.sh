#!/usr/bin/env bash
## hooking debug information on each stage

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

__kcs_debug_pre_main() {
  local ns="$KCS_HOOK_NAME info"

  kcs_debug "$ns" "%s: '%s'" \
    "$KCS_NAME" "$KCS_VERSION"
  kcs_debug "$ns" "mode: '%s'" \
    "$KCS_MODE"
  kcs_debug "$ns" "entry mode: '%s'" \
    "$_KCS_ENTRY"
  kcs_debug "$ns" "arguments: '%s' (size=%d)" \
    "$*" "$#"
  kcs_debug "$ns" "log levels: '%s'" \
    "$_KCS_LOG_LEVELS"
}
