#!/usr/bin/env bash

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

export KCS_CMD_NAME="ghi_success"

__kcs_ghi_success_hook_main() {
  kcs_log_printf "$1" "key        : %s" "$_KCS_CMD_KEY"
  # shellcheck disable=SC2153
  kcs_log_printf "$1" "name       : %s" "$_KCS_CMD_NAME"
  kcs_log_printf "$1" "args       : %d (%s)" "$#" "$*"
  kcs_log_printf "$1" "cmd args   : %d (%s)" \
    "${#_KCS_CMD_ARGS[@]}" "${_KCS_CMD_ARGS[*]}"
  kcs_log_printf "$1" "raw args   : ${_KCS_CMD_ARGS_RAW:-<missing>}"
  kcs_log_printf "$1" "extra args : ${_KCS_CMD_ARGS_EXTRA:-<missing>}"

  return 0
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
