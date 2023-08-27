#!/usr/bin/env bash

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

__kcs_environment_lc_init() {
  kcs_ld_env default

  kcs_hooks_add clean environment
}

__kcs_environment_hook_clean() {
  kcs_ld_unenv default
}
