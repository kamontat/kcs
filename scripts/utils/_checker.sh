#!/usr/bin/env bash
##utils-example:v1.0.0-beta.1

## Checker:
##   all checker function will return error code if something wrong
##   to exit script if validation fail, please check _validator.sh
## Requirement:
##   <none>
## Public functions:
##   `kcs_check_present <input>` - check input must not be empty string
##   `kcs_check_os <os>` - check current os must equal to input expected

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

## check input must not be empty string
## @param $1 - [required] input string
## @return   - return verify failed code or 0
kcs_check_present() {
  local input="$2"
  if test -z "$input"; then
    return "$KCS_ERRCODE_VERIFY_FAILED"
  fi

  return 0
}

## check current os must equal to input expected
## @param $1 - [required] expected os string from `uname` result
## @return   - return verify failed code or 0
kcs_check_os() {
  local expected="$1" actual
  actual="$(uname -s | awk '{ print tolower($0) }')"
  if [[ "$actual" != "$expected" ]]; then
    return "$KCS_ERRCODE_VERIFY_FAILED"
  fi

  return 0
}
