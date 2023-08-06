#!/usr/bin/env bash

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

__kcs_options_lc_init() {
  local ns="init.options"

  if ! kcs_ld_lib_is_loaded 'hooks'; then
    kcs_log_error "$ns" "options is requires 'hooks' to be loaded"
    return 1
  fi

  kcs_ld_lib information

  kcs_hooks_add post_init options @raw
}

__kcs_options_hook_init() {
  # echo "$*"
  return 0
}
