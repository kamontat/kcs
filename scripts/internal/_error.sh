#!/usr/bin/env bash

## Error functions:
##   an error constants including some helpful functions

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

__KCS_EC_VARIABLES=()
__KCS_EC_WHITELIST=()
__KCS_EC_HELP="# Error codes"

## register new errcode
## code must be between 0 - 255
__kcs_register_error() {
  local name="$1" code="$2" desc="$3"

  ## create errcode variable
  eval "export $name=$code"
  ## add errcode to code whitelist
  __KCS_EC_VARIABLES+=("$name")
  __KCS_EC_WHITELIST+=("$code")
  __KCS_EC_HELP="$__KCS_EC_HELP
  - $(printf "[%03d]: %s" "$code" "$desc")"
}

__kcs_register_error \
  "KCS_EC_UNKNOWN" 1 "unknown error"

__kcs_register_error \
  "KCS_EC_INVALID_ARGS" 11 "invalid argument"
__kcs_register_error \
  "KCS_EC_INVALID_OPTS" 12 "invalid option"
__kcs_register_error \
  "KCS_EC_INVALID_MODE" 13 "invalid kcs mode (\$KCS_MODE)"

__kcs_register_error \
  "KCS_EC_CHECK_FAIL" 30 "validation failed"

__kcs_register_error \
  "KCS_EC_CMD_NOT_FOUND" 127 "command not found"
__kcs_register_error \
  "KCS_EC_ARG_NOT_FOUND" 128 "missing required argument"
__kcs_register_error \
  "KCS_EC_OPT_NOT_FOUND" 129 "missing required option"
__kcs_register_error \
  "KCS_EC_FILE_NOT_FOUND" 130 "file not found"
__kcs_register_error \
  "KCS_EC_UTIL_NOT_FOUND" 131 "missing required utility file"

unset __kcs_register_error

kcs_throw() {
  local code="${1:?}"
  shift

  [ $# -gt 0 ] && kcs_error "$@"

  for whitelist in "${__KCS_EC_WHITELIST[@]}"; do
    if [ "$whitelist" -eq "$code" ]; then
      exit "$code"
    fi
  done

  ## $1 - namespace
  kcs_warn "$1" "unknown error code %d, fallback to 1" \
    "$code"
  exit 1
}

kcs_get_errcode_help() {
  printf "%s\n" "$__KCS_EC_HELP"
  exit 0
}

__kcs_error_clean() {
  for var in "${__KCS_EC_VARIABLES[@]}"; do
    unset "$var"
  done

  unset __KCS_EC_VARIABLES \
    __KCS_EC_WHITELIST \
    __KCS_EC_HELP
}
