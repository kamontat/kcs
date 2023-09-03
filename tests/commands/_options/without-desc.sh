#!/usr/bin/env bash

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

__kcs_opt_with_desc_hook_setup() {
  kcs_conf_use options default
}

__kcs_opt_with_desc_hook_load() {
  kcs_ld_lib options
}

__kcs_opt_with_desc_hook_main() {
  ## If user pass -h|--help main will never run
  return 1
}

if test -z "$_KCS_MAIN_MODE"; then
  export _KCS_PATH_DIR_ORIG="$PWD"
  cd "$(dirname "$0")/.." || exit 1
  export _KCS_PATH_SRC="$PWD"
  cd ".." || exit 1
  export _KCS_PATH_ROOT="$PWD"
fi

# shellcheck source=/dev/null
source "$_KCS_PATH_SRC/private/base.sh" || exit 1
# shellcheck source=/dev/null
source "$_KCS_PATH_SRC/private/command.sh" || exit 1

kcs_command_start opt_with_desc "$@"
