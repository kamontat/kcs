#!/usr/bin/env bash
## hooking debug information on each stage

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

__kcs_debug_pre_init() {
  local ns="pre_init info"

  kcs_debug "$ns" "%s: '%s'" \
    "$KCS_NAME" "$KCS_VERSION"
  kcs_debug "$ns" "Mode: '%s'" \
    "$KCS_MODE"
  kcs_debug "$ns" "Entry mode: '%s'" \
    "$_KCS_ENTRY"
}
