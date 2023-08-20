#!/usr/bin/env bash

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

## Create temporary file
## usage: `kcs_tmp_create_file [name]`
kcs_tmp_create_file() {
  _kcs_tmp_create touch "$1"
}
## Create unique temporary file
## usage: `kcs_tmp_create_ufile [name]`
kcs_tmp_create_ufile() {
  _kcs_tmp_create touch "$1" "unique"
}

## Create temporary directory
## usage: `kcs_tmp_create_dir [name]`
kcs_tmp_create_dir() {
  _kcs_tmp_create mkdir "$1"
}
## Create unique temporary directory
## usage: `kcs_tmp_create_udir [name]`
kcs_tmp_create_udir() {
  _kcs_tmp_create mkdir "$1" "unique"
}

## Create temporary based on input
## usage: `_kcs_tmp_create <mkdir|touch> [name] [unique]`
_kcs_tmp_create() {
  local ns="create.tmp"
  local cmd="$1" input="${2:-}" unique="${3:-}" base="${_KCS_PATH_TMP:?}"
  local name suffix output

  test -n "$input" && name="$input"
  test -z "$input" && name="tmp_$cmd"
  test -z "$input" || test -n "$unique" &&
    suffix="-$(__kcs_tmp_random_str 6)"

  output="$base/$name$suffix"

  if [[ "$cmd" == "mkdir" ]] && ! test -d "$output"; then
    kcs_log_debug "$ns" "create new directory at '%s'" "$output"
    mkdir -p "$output"
  elif [[ "$cmd" == "touch" ]] && ! test -f "$output"; then
    kcs_log_debug "$ns" "create new file at '%s'" "$output"
    touch "$output"
  fi

  printf "%s" "$output"
}

__kcs_tmp_random_str() {
  local size="$1"
  cat </dev/urandom | LC_ALL=C tr -dc 'a-zA-Z' | head -c "$size"
}

__kcs_tmp_hook_init() {
  local ns="hook-init.tmp"
  local basedir="${KCS_TMPDIR:-${TMPDIR:-/tmp}/kcs}"
  local timestamp="$basedir/.timestamp"
  if test -f "$timestamp"; then
    local previous current diff
    previous="$(cat "$timestamp")"
    current="$(date +"%Y%m%d%H%M")"
    diff="$((current - previous))"
    if [ -d "$basedir" ] && [ "$diff" -gt "${KCS_TMPCLE:-10000}" ]; then
      test -z "$KCS_TEST" &&
        kcs_log_debug "$ns" \
          "cleanup directory '%s' because it created at '%s' (diff=%s)" \
          "$basedir" "$previous" "$diff"
      rm -r "$basedir"
    elif test -n "$KCS_TMPBFR"; then
      test -z "$KCS_TEST" &&
        kcs_log_debug "$ns" "cleanup directory '%s' because dev mode is enabled" \
          "$basedir"
      rm -r "$basedir"
    fi
  fi

  if ! test -d "$basedir"; then
    test -z "$KCS_TEST" &&
      kcs_log_debug "$ns" "create directory at '%s'" "$basedir"
    mkdir "$basedir" || return 1
  else
    test -z "$KCS_TEST" &&
      kcs_log_debug "$ns" "reuse directory at '%s'" "$basedir"
  fi

  test -z "$KCS_TEST" &&
    kcs_log_debug "$ns" "create \$_KCS_PATH_TMP variable to '%s'" "$basedir"
  export _KCS_PATH_TMP="$basedir"
}

__kcs_tmp_hook_clean() {
  local ns="hook-clean.tmp"
  local timestamp="${_KCS_PATH_TMP:?}/.timestamp"
  if ! test -f "$timestamp"; then
    kcs_log_debug "$ns" "stamp created date of temporary directory"
    date +"%Y%m%d%H%M" >"$timestamp"
  fi
  unset _KCS_PATH_TMP
}
