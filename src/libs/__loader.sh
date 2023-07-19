#!/usr/bin/env bash

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

export KCS_LD_CODE_NOT_FOUND=11
export KCS_LD_CODE_ERROR=12

## Loading input file based on input callback
## usage: `kcs_ld_load <found-cb> <miss-cb> <key> <name> <args...>`
## supports:
##   - found-cb: `source`, `source_silent`, `source_ignore`
##   - miss-cb : `with_throw`, `with_optional`, `with_silent`, `with_ignore`
kcs_ld_load() {
  local ns="load.loader"
  local found_cb="__kcs_ld_$1" miss_cb="__kcs_ld_$2"
  local key="$3" name="$4"
  shift 4

  local dir prefix suffix
  case "$key" in
  libraries | libs | lib | l)
    dir="libs"
    prefix="_"
    suffix=".sh"
    ;;
  utilities | utils | util | u)
    dir="utils"
    prefix="_"
    suffix=".sh"
    ;;
  commands | cmds | cmd | c)
    dir="commands"
    prefix=""
    suffix=".sh"
    ;;
  *)
    kcs_log_debug "$ns" "invalid loading key (%s)" "$key"
    "$miss_cb" "$key" "$name" "$@"
    return $?
    ;;
  esac

  local dirpath="${KCS_DIR_ROOT:?}" filename="$prefix$name$suffix"
  test -n "$dir" && dirpath="$dirpath/$dir"
  local dirpaths=("$dirpath")
  kcs_log_debug "$ns" "trying '%s' on directory '%s'" "$filename" "$dirpath"

  if ! test -f "$dirpath/$filename"; then
    kcs_log_debug "$ns" "cannot found file '%s' on %s" "$filename" "$dirpath"
    dirpath="${KCS_DIR_SRC:?}"
    test -n "$dir" && dirpath="$dirpath/$dir"
    dirpaths+=("$dirpath")
    kcs_log_debug "$ns" "trying '%s' on directory '%s' instead" \
      "$filename" "$dirpath"
  fi

  if test -f "$dirpath/$filename"; then
    kcs_log_debug "$ns" "sourcing '%s/%s' with [%s]" \
      "$dirpath" "$filename" "$*"
    "$found_cb" "$dirpath" "$filename" "$@"
  else
    kcs_log_debug "$ns" "cannot found file '%s' on [%s]" \
      "$filename" "${dirpaths[*]}"
    "$miss_cb" "$key" "$filename" "$@"
    return $?
  fi
}

_kcs_ld_clean() {
  unset KCS_LD_CODE_ERROR KCS_LD_CODE_NOT_FOUND
}

__kcs_ld_source() {
  local ns="callback.loader"
  local dir="$1" file="$2"
  shift 2
  # shellcheck disable=SC1090
  if ! source "$dir/$file" "$@"; then
    kcs_log_error "$ns" "sourcing %s return error" "$dir/$file"
    return "$KCS_LD_CODE_ERROR"
  fi
}
__kcs_ld_source_must() {
  local ns="callback.loader"
  local dir="$1" file="$2"
  shift 2
  # shellcheck disable=SC1090
  if ! source "$dir/$file" "$@"; then
    kcs_log_error "$ns" "sourcing %s must return success" "$dir/$file"
    exit "$KCS_LD_CODE_ERROR"
  fi
}
__kcs_ld_source_silent() {
  local ns="callback.loader"
  local dir="$1" file="$2"
  shift 2
  # shellcheck disable=SC1090
  source "$dir/$file" "$@" || return "$KCS_LD_CODE_ERROR"
}
__kcs_ld_source_ignore() {
  local ns="callback.loader"
  local dir="$1" file="$2"
  shift 2
  # shellcheck disable=SC1090
  source "$dir/$file" "$@" || return 0
}

__kcs_ld_with_optional() {
  local ns="callback.loader"
  local key="$1" name="$2"
  shift 2
  local suffix="without argument"
  [ "$#" -gt 0 ] && suffix="with argument [$*]"
  kcs_log_error "$ns" "missing '%s' on '%s' key (%s)" \
    "$name" "$key" "$suffix"
  return "$KCS_LD_CODE_NOT_FOUND"
}
__kcs_ld_with_throw() {
  __kcs_ld_with_optional "$@"
  exit "$KCS_LD_CODE_NOT_FOUND"
}
__kcs_ld_with_ignore() {
  return 0
}
__kcs_ld_with_silent() {
  return "$KCS_LD_CODE_NOT_FOUND"
}
