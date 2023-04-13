#!/usr/bin/env bash
## Main utilities for main.sh entrypoint

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
  _kcs_find_command "$@"
}
