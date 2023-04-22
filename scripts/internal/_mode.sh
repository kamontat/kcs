#!/usr/bin/env bash

## Mode manager:
##   a collection of mode functions and constants

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

export _KCS_MODE_COMMAND="command"
export _KCS_MODE_LIBRARY="library"

## Check current entry is not main
## otherwise, throw error to use command entry instead.
kcs_no_main_entry() {
  local ns="mode-validator"
  local actual="$KCS_MODE" expected="$_KCS_MODE_LIBRARY"
  local entry="$_KCS_ENTRY"

  if [[ $entry == "main" ]] &&
    [[ "$actual" == "$expected" ]]; then
    kcs_throw "$KCS_EC_INVALID_MODE" \
      "$ns" "You cannot run '%s' mode in '%s' entry, please use '%s' instead" \
      "$expected" "$entry" "/commands"
  fi
}

__kcs_mode_init() {
  local actual="$KCS_MODE" expected="$_KCS_MODE_LIBRARY"
  if [[ "$actual" == "$expected" ]]; then
    local disable_hooks=(
      pre_main main post_main
      pre_clean clean post_clean
    )

    for hook in "${disable_hooks[@]}"; do
      kcs_disable_hook "$hook"
    done
  fi
}

__kcs_mode_clean() {
  unset _KCS_MODE_LIBRARY \
    _KCS_MODE_COMMAND
}
