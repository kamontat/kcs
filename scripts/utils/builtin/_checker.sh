#!/usr/bin/env bash
##utils-example:v1.0.0-beta.1

## builtin/checker:
##   all checker function will return error code if something wrong
##   to exit script if validation fail, please check _validator.sh
## Requirement:
##   <none>
## Public functions:
##   `kcs_check_present <input>` - check input should be exist
##   `kcs_check_cmd <cmd>` - check input should be executable command
##   `kcs_check_hostname <n>` - check current host should be expected input name
##   `kcs_check_os <os>` - check current OS should be expected input
##   `kcs_check_dir <p>` - check input directory should be exist
##   `kcs_check_file <p>` - check input file should be exist
##   `kcs_check_url <u>` - check input url should be callable
##   `kcs_check_server <ip> [p] [cmd]` - check input should be connectable

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

## check input should exist
## @param $1 - [required] input string
## @return   - either zero or non-zero
kcs_check_present() {
  local input="$2"
  if test -z "$input"; then
    return "$KCS_EC_CHECK_FAIL"
  fi
  return 0
}

## check input should be executable command
## @param $1 - [required] input command name
## @return   - either zero or non-zero
kcs_check_cmd() {
  local input="$1"
  if ! command -v "$input" >/dev/null; then
    return "$KCS_EC_CHECK_FAIL"
  fi
  return 0
}

## check current host should be expected input name
## @param $1 - [required] expected host name string
## @return   - either zero or non-zero
kcs_check_hostname() {
  local expected="$1" actual
  actual="$(hostname)"
  if [[ "$actual" != "$expected" ]]; then
    return "$KCS_EC_CHECK_FAIL"
  fi
  return 0
}

## check current OS should be expected input
## @param $1 - [required] expected os string from `uname` result
## @return   - either zero or non-zero
kcs_check_os() {
  local expected="$1" actual
  actual="$(uname -s | awk '{ print tolower($0) }')"
  if [[ "$actual" != "$expected" ]]; then
    return "$KCS_EC_CHECK_FAIL"
  fi
  return 0
}

## check input directory should be exist
## @param $1 - [required] input directory fullpath
## @return   - either zero or non-zero
kcs_check_dir() {
  local input="$1"
  if ! test -d "$input"; then
    return "$KCS_EC_CHECK_FAIL"
  fi
  return 0
}

## check input file should be exist
## @param $1 - [required] input file fullpath
## @return   - either zero or non-zero
kcs_check_file() {
  local input="$1"
  if ! test -f "$input"; then
    return "$KCS_EC_CHECK_FAIL"
  fi
  return 0
}

## check input url should be callable
## @param $1 - [required] full link
## @return   - either zero or non-zero
kcs_check_url() {
  local url="$1"
  if ! curl --silent --location --insecure --output /dev/null \
    "$url"; then
    return "$KCS_EC_CHECK_FAIL"
  fi
  return 0
}

## check input should be connectable
## @param $1 - [required] hostname or ip
##        $2 - [optional] port number (default=80)
##        $3 - [optional] force command to use (e.g. nc)
## @return   - either zero or non-zero
kcs_check_server() {
  local ns="server-checker"
  local ip="$1" port="${2:-80}"
  local cmd="$3" args=()
  local stdout="/dev/stdout"
  local stderr="/dev/stderr"

  if test -z "$cmd" &&
    command -v nc >/dev/null; then
    cmd="nc"
  elif test -z "$cmd"; then
    cmd="ping"
  fi

  case "$cmd" in
  nc)
    args+=("-w" 1 "-H" 1 "-J" 1 "-G" 1 "-z")
    args+=("$ip" "$port")
    stderr="/dev/null"
    ;;
  ping)
    args+=(-c1 -qt1)
    args+=("$ip")
    stdout="/dev/null"
    ;;
  *)
    return "$KCS_EC_INVALID_ARGS"
    ;;
  esac

  kcs_debug "$ns" "using '%s' command with %d arguments" \
    "$cmd" "${#args[@]}"

  if ! "$cmd" "${args[@]}" >$stdout 2>$stderr; then
    return "$KCS_EC_CHECK_FAIL"
  fi
  return 0
}
