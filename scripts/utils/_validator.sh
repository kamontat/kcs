#!/usr/bin/env bash
##example:v1.0.0-beta.1
## Above is metadata, please do not remove

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

## throw error if input string is empty
## `kcs_verify_exist "input" "$input"`
kcs_verify_exist() {
  local ns="exist validation"
  local name="$1" input="$2"
  if test -z "$input"; then
    kcs_throw "$KCS_ERRCODE_VERIFY_FAILED" \
      "$ns" "%s string is required" "$name"
  fi
}

## `kcs_verify_os "darwin"`
kcs_verify_os() {
  local ns="os validation"
  local expected="$1" actual
  actual="$(uname -s | awk '{ print tolower($0) }')"
  if [[ "$actual" != "$expected" ]]; then
    kcs_throw "$KCS_ERRCODE_VERIFY_FAILED" \
      "$ns" "expected %s but got '%s'" "$expected" "$actual"
  fi
}
