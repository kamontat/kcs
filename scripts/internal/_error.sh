#!/usr/bin/env bash
## errors constants and throw function

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

export KCS_ERRCODE_UNKNOWN=1
export KCS_ERRCODE_MISSING_REQUIRED_ARGUMENT=2
export KCS_ERRCODE_CMD_NOT_FOUND=6
export KCS_ERRCODE_FILE_NOT_FOUND=7
export KCS_ERRCODE_OPTION_NOT_FOUND=12
export KCS_ERRCODE_INVALID_OPTION=13
export KCS_ERRCODE_VERIFY_FAILED=20

__KCS_CODE_WHITELIST=(
  "$KCS_ERRCODE_UNKNOWN"
  "$KCS_ERRCODE_MISSING_REQUIRED_ARGUMENT"
  "$KCS_ERRCODE_CMD_NOT_FOUND"
  "$KCS_ERRCODE_FILE_NOT_FOUND"
  "$KCS_ERRCODE_OPTION_NOT_FOUND"
  "$KCS_ERRCODE_INVALID_OPTION"
  "$KCS_ERRCODE_VERIFY_FAILED"
)

kcs_throw() {
  local code="${1:?}"
  shift 1

  if [ $# -gt 0 ]; then
    kcs_error "$@"
  fi

  for whitelist in "${__KCS_CODE_WHITELIST[@]}"; do
    if [ "$whitelist" -eq "$code" ]; then
      exit "$code"
    fi
  done

  ## $1 - namespace
  kcs_error "$1" "unknown error code %d, fallback to 1" \
    "$code"
  exit 1
}

__kcs_format_errcode_list() {
  local code="$1" desc="$2"
  printf '  [%03d] - %s\n' \
    "$code" "$desc"
}
kcs_get_errcode_help() {
  echo "# Error code"
  __kcs_format_errcode_list \
    "$KCS_ERRCODE_UNKNOWN" "unhandle error code"
  __kcs_format_errcode_list \
    "$KCS_ERRCODE_MISSING_REQUIRED_ARGUMENT" "required argument missing"
  __kcs_format_errcode_list \
    "$KCS_ERRCODE_CMD_NOT_FOUND" "command not found"
  __kcs_format_errcode_list \
    "$KCS_ERRCODE_FILE_NOT_FOUND" "file not found"
  __kcs_format_errcode_list \
    "$KCS_ERRCODE_OPTION_NOT_FOUND" "options not found"
  __kcs_format_errcode_list \
    "$KCS_ERRCODE_INVALID_OPTION" "invalid options"
  __kcs_format_errcode_list \
    "$KCS_ERRCODE_VERIFY_FAILED" "validation failed"

  exit 0
}

__kcs_error_clean() {
  unset KCS_ERRCODE_UNKNOWN \
    KCS_ERRCODE_MISSING_REQUIRED_ARGUMENT \
    KCS_ERRCODE_CMD_NOT_FOUND \
    KCS_ERRCODE_FILE_NOT_FOUND \
    KCS_ERRCODE_OPTION_NOT_FOUND \
    KCS_ERRCODE_INVALID_OPTION \
    KCS_ERRCODE_VERIFY_FAILED

  unset __KCS_CODE_WHITELIST
}
