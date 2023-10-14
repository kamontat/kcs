#!/usr/bin/env bash

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

## Allowed list: English character, spacebar, -, _, and .
export KCS_CMD_NAME="hello"

__kcs_hello_hook_setup() {
  kcs_conf_use options default
}

__kcs_hello_hook_load() {
  kcs_ld_lib options \
    '-e|--exp|--example [str:hello(=space=)world]; EXAMPLE show example:message'
}

__kcs_hello_hook_main() {
  local ns="$1"
  shift

  # shellcheck disable=SC2153
  kcs_log_printf "$ns" "%-15s : %s" \
    "name" "$_KCS_CMD_NAME"
  kcs_log_printf "$ns" "%-15s : %s" \
    "version" "$_KCS_CMD_VERSION"
  kcs_log_printf "$ns" "%-15s : %s" \
    "namespace" "$ns"
  kcs_log_printf "$ns" "%-15s : %s" \
    "direct-args" "$# [$*]"
  kcs_log_printf "$ns" "%-15s : %s" \
    "parsed-args" "${#_KCS_CMD_ARGS[@]} [${_KCS_CMD_ARGS[*]}]"
  kcs_log_printf "$ns" "%-15s : %s" \
    "raw-args" "${_KCS_CMD_ARGS_RAW:-<missing>}"
  kcs_log_printf "$ns" "%-15s : %s" \
    "extra-args" "${_KCS_CMD_ARGS_EXTRA:-<missing>}"
  kcs_log_printf "$ns" "%-15s : %s" \
    "opt-help" "$_KCS_OPT_HELP_VALUE"
  kcs_log_printf "$ns" "%-15s : %s" \
    "opt-version" "$_KCS_OPT_VERSION_VALUE"
  kcs_log_printf "$ns" "%-15s : %s" \
    "opt-example" "$_KCS_OPT_EXAMPLE_VALUE"
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
fi

# shellcheck source=/dev/null
source "$_KCS_PATH_SRC/private/base.sh" || exit 1
# shellcheck source=/dev/null
source "$_KCS_PATH_SRC/private/command.sh" || exit 1

kcs_command_start "$KCS_CMD_NAME" "$@"
