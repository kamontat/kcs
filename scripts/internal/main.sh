#!/usr/bin/env bash

## Main.sh utilities:
##   main utilities for main.sh entry-point

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

kcs_prepare() {
  # shellcheck disable=SC1091
  source "$PWD/internal/_base.sh"

  ## Load main specific internal and utilities
  kcs_load_internal "_commands.sh"
}

kcs_start() {
  ## Validate mode
  kcs_no_main_entry
  ## Find correct command
  _kcs_find_command "$@"
}
