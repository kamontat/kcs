#!/usr/bin/env bash

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

__kcs_hello_hook_init() {
  kcs_ld_lib options \
    '-h|--help; HELP show help; message' \
    '-v|--version <str>; VERSION' \
    '-e|--exp|--example [str:hello(=space=)world]; EXAMPLE show example:message'
}

__kcs_hello_hook_main() {
  local ns="$1"
  shift

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

kcs_command_start hello "$@"
