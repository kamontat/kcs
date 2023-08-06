#!/usr/bin/env bash

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

__kcs_environment_lc_init() {
  kcs_ld_config env
}

__kcs_environment_hook_clean() {
  kcs_ld_unconfig env
}
