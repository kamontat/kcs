#!/usr/bin/env bash

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

## Allowed list: English character, spacebar, -, _, and .
export KCS_CMD_NAME="example"

## For setup config data
__kcs_example_hook_setup() {
  # kcs_conf_use '<key>' '<value>'
  return 0
}

## For loading libraries or functions
__kcs_example_hook_load() {
  # kcs_ld_lib '<key>' '[args...]'
  return 0
}

## For main entry point
__kcs_example_hook_main() {
  return 0
}

## For cleanup
__kcs_example_hook_clean() {
  return 0
}

#####################################################
##                  Internal code                  ##
#####################################################

if test -z "$_KCS_MAIN_MODE"; then
  export _KCS_PATH_ORIG="$PWD"

  cd "$(dirname "$0")" || exit 1
  export _KCS_PATH_SRC="$PWD"
  while [[ "$_KCS_PATH_SRC" != '/' ]]; do
    test -f "$_KCS_PATH_SRC/main.sh" && break
    _KCS_PATH_SRC="$(dirname "$_KCS_PATH_SRC")"
  done

  cd "$_KCS_PATH_SRC/.." || exit 1
  export _KCS_PATH_ROOT="$PWD"
fi

# shellcheck source=/dev/null
source "$_KCS_PATH_SRC/private/base.sh" || exit 1
# shellcheck source=/dev/null
source "$_KCS_PATH_SRC/private/command.sh" || exit 1

kcs_command_start "$KCS_CMD_NAME" "$@"
