#!/usr/bin/env bash

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

export KCS_CMD_NAME="Arguments"

__kcs_arguments_hook_main() {
  local ns="$1"
  shift

  echo "key   : $_KCS_CMD_KEY"
  # shellcheck disable=SC2153
  echo "name  : $_KCS_CMD_NAME"
  echo "ns    : $ns"
  echo "args  : $# [$*]"
  echo "raw   : ${_KCS_CMD_ARGS_RAW:-<missing>}"
  echo "extra : ${_KCS_CMD_ARGS_EXTRA:-<missing>}"
}

#####################################################
##               Internal code v1.1                ##
#####################################################

if test -z "$_KCS_MAIN_MODE"; then
  export _KCS_PATH_ORIG="$PWD"
  cd "$(dirname "$0")" || exit 1

  _KCS_PATH_CURRENT="$PWD"
  while [[ "$_KCS_PATH_CURRENT" != '/' ]]; do
    ## When deploying scripts
    test -d "$_KCS_PATH_CURRENT/.kcs" &&
      _KCS_PATH_SRC="$_KCS_PATH_CURRENT/.kcs" &&
      break
    ## When local development
    test -f "$_KCS_PATH_CURRENT/main.sh" &&
      _KCS_PATH_SRC="$_KCS_PATH_CURRENT" &&
      break
    _KCS_PATH_CURRENT="$(dirname "$_KCS_PATH_CURRENT")"
  done

  cd "${_KCS_PATH_SRC:?}/.." || exit 1
  export _KCS_PATH_SRC _KCS_PATH_ROOT="$PWD"
  unset _KCS_PATH_CURRENT
fi

# shellcheck source=/dev/null
source "$_KCS_PATH_SRC/private/base.sh" || exit 1
# shellcheck source=/dev/null
source "$_KCS_PATH_SRC/private/command.sh" || exit 1

kcs_command_start "$KCS_CMD_NAME" "$@"
