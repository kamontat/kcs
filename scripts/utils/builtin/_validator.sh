#!/usr/bin/env bash
##example-utils:v1

## builtin/validator:
##   all validator function will throw error if check failed
##   to checking only, please check _checker.sh
## Hook: <any>
## Public functions:
##   `kcs_verify_present <input> <name>` - validate input must be exist
##   `kcs_verify_cmd <cmd>` - validate input must be executable command
##   `kcs_verify_hostname <n>` - validate current host must be expected input
##   `kcs_verify_os <os>` - validate current OS must be expected input
##   `kcs_verify_dir <p>` - validate input directory must be exist
##   `kcs_verify_file <p>` - validate input file must be exist
##   `kcs_verify_url <url>` - validate input url must be callable
##   `kcs_verify_server <ip> [p] [cmd]` - validate input must be connectable
##   `kcs_verify_args <size>` - validate arguments must be same size
##   `kcs_verify_git_clean` - validate current git must be clean
##   `kcs_verify_raw <cmd> <args>` - validate raw commands must not failed

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

kcs_utils_register "builtin/validator"

## validate input must be exist
## @param $1 - [required] input value
##        $2 - [required] variable name
## @exit     - error if input is empty string
kcs_verify_present() {
  local ns="str-verifier"
  local input="$1" name="$2"
  if test -z "$input"; then
    kcs_throw "$KCS_EC_CHECK_FAIL" \
      "$ns" "'%s' is required" "$name"
  fi
}

## validate input must be executable command
## @param $1 - [required] input command name
## @exit     - error if input invalid command
kcs_verify_cmd() {
  local ns="cmd-verifier"
  local input="$1"
  if ! command -v "$input" >/dev/null; then
    kcs_throw "$KCS_EC_CHECK_FAIL" \
      "$ns" "missing command '%s'" "$input"
  fi
}

## validate current host must be expected input name
## @param $1 - [required] expected host name string
## @exit     - error if hostname is not expected
kcs_verify_hostname() {
  local ns="host-verifier"
  local expected="$1" actual
  actual="$(hostname)"
  if [[ "$actual" != "$expected" ]]; then
    kcs_throw "$KCS_EC_CHECK_FAIL" \
      "$ns" "expected hostname '%s' (current '%s')" \
      "$expected" "$actual"
  fi
  return 0
}

## validate current OS must be expected input
## @param $1 - [required] expected os name (result from `uname`)
## @exit     - error if os is not expected
kcs_verify_os() {
  local ns="os-verifier"
  local expected="$1" actual
  actual="$(uname -s | awk '{ print tolower($0) }')"
  if [[ "$actual" != "$expected" ]]; then
    kcs_throw "$KCS_EC_CHECK_FAIL" \
      "$ns" "expected os '%s' (current '%s')" "$expected" "$actual"
  fi
}

## validate directory file must be exist
## @param $1 - [required] input directory fullpath
## @exit     - error if input directory not found
kcs_verify_dir() {
  local ns="dir-verifier"
  local input="$1"
  if ! test -d "$input"; then
    kcs_throw "$KCS_EC_CHECK_FAIL" \
      "$ns" "directory (%s) not found" "$input"
  fi
}

## validate input file must be exist
## @param $1 - [required] input file fullpath
## @exit     - error if input file not found
kcs_verify_file() {
  local ns="file-verifier"
  local input="$1"
  if ! test -f "$input"; then
    kcs_throw "$KCS_EC_CHECK_FAIL" \
      "$ns" "file (%s) not found" "$input"
  fi
}

## validate input url must be callable
## @param $1 - [required] full link
## @exit     - error if input url cannot be called
kcs_verify_url() {
  local ns="url-verifier"
  local url="$1"
  if ! curl --silent --location --insecure --output /dev/null \
    "$url"; then
    kcs_throw "$KCS_EC_CHECK_FAIL" \
      "$ns" "couldn't connect to %s" "$url"
  fi
}

## validate input must be connectable
## @param $1 - [required] hostname or ip
##        $2 - [optional] port number (default=80)
##           - when using ping, ignore port number
##        $3 - [optional] force command to use (e.g. nc)
## @exit     - error if input server cannot be connected
kcs_verify_server() {
  local ns="server-verifier"
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
    kcs_throw "$KCS_EC_CHECK_FAIL" \
      "$ns" "server %s:%s couldn't connect" \
      "$ip" "$port"
  fi
  return 0
}

## validate arguments must be same size
## @param $1 - [required] expected argument size
##        $n - [optional] argument array to check (default=$KCS_COMMANDS)
## @exit     - error if size is not matched
## @example  - `kcs_verify_args 3`
##           - `kcs_verify_args 7 "$@"`
kcs_verify_args() {
  local ns="args-verifier"
  local expected="$1" actual="${#KCS_COMMANDS[@]}"
  if [ "$expected" -ne "$actual" ]; then
    kcs_throw "$KCS_EC_CHECK_FAIL" \
      "$ns" "expected '%s' arguments, but got '%s'" \
      "$expected" "$actual"
  fi
}

## validate current git must be clean
## @exit     - error if current git repo is not clean
## @example  - `kcs_verify_git_clean`
kcs_verify_git_clean() {
  local ns="git-verifier"
  if ! git diff-files --quiet; then
    kcs_throw "$KCS_EC_CHECK_FAIL" \
      "$ns" "current git (%s) is not clean" \
      "$PWD"
  fi
}

## validate raw commands must not failed
## @param $1 - [required] command name
##        $n - [optional] command arguments
## @exit     - error if input command cannot execute
## @example  - `kcs_verify_raw test -f 'hello.txt'`
kcs_verify_raw() {
  local ns="raw-verifier"
  local cmd="$1" args=()
  shift
  args=("$@")

  if ! "$cmd" "${args[@]}"; then
    kcs_throw "$KCS_EC_CHECK_FAIL" \
      "$ns" "command '%s' return non-zero exit-code" \
      "$cmd"
  fi
}
