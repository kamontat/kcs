#!/usr/bin/env bash

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

__kcs_env_no_value_hook_setup() {
  kcs_ld_env no_value
}

__kcs_env_no_value_hook_main() {
  echo "$NO_VALUE == NO_VALUE"
}

__kcs_env_no_value_hook_clean() {
  kcs_ld_unenv no_value
}

if test -z "$_KCS_MAIN_MODE"; then
  export _KCS_PATH_ORIG="$PWD"
  cd "$(dirname "$0")/.." || exit 1
  export _KCS_PATH_SRC="$PWD"
  cd ".." || exit 1
  export _KCS_PATH_ROOT="$PWD"
fi

# shellcheck source=/dev/null
source "$_KCS_PATH_SRC/private/base.sh" || exit 1
# shellcheck source=/dev/null
source "$_KCS_PATH_SRC/private/command.sh" || exit 1

kcs_command_start env_no_value "$@"
