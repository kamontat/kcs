#!/usr/bin/env bash

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

## Call libraries file
## usage: `kcs_ld_lib <name> <args...>`
kcs_ld_lib() {
  __kcs_ld_do source throw throw libs "$@"
}

## Call command file
## usage: `kcs_ld_cmd <name> <args...>`
kcs_ld_cmd() {
  __kcs_ld_do shell silent throw cmd "$@"
}

## Call default command file
## usage: `kcs_ld_cmd_default <name> <args...>`
kcs_ld_cmd_default() {
  __kcs_ld_do shell throw throw cmd "$@"
}

## Call utilities file
## usage: `kcs_ld_utils <name> <args...>`
kcs_ld_utils() {
  __kcs_ld_do source throw throw utils "$@"
}

## Call function
## usage: `kcs_ld_func <name> <func> <args...>`
kcs_ld_func() {
  __kcs_ld_do function throw throw func "$@"
}

## Call optional function
## usage: `kcs_ld_func_optional <name> <func> <args...>`
kcs_ld_func_optional() {
  __kcs_ld_do function mute throw func "$@"
}

## Silently call function
## usage: `kcs_ld_func_silent <name> <func> <args...>`
kcs_ld_func_silent() {
  __kcs_ld_do function mute silent func "$@"
}

__kcs_ld_do() {
  local ns="do.loader"
  local action_cb="__kcs_ld_acb_${1:?}"
  local miss_cb="__kcs_ld_mcb_${2:?}"
  local error_cb="__kcs_ld_ecb_${3:?}"
  local key="${4:?}" name="${5:?}"
  shift 5

  local fs=true saved=true
  local dir prefix suffix
  case "$key" in
  libraries | libs | lib | l)
    dir="libs"
    prefix="_"
    suffix=".sh"
    ;;
  utilities | utils | util | u)
    dir="utils"
    prefix=""
    suffix=".sh"
    ;;
  commands | cmds | cmd | c)
    saved=false
    dir="commands"
    prefix=""
    suffix=".sh"
    ;;
  functions | func | fn | f)
    saved=false
    fs=false
    ;;
  *)
    kcs_log_debug "$ns" "invalid loading key (%s)" "$key"
    "$miss_cb" "$key" "$name" "" "$@"
    return $?
    ;;
  esac

  if "$saved" && __kcs_ld_is_loaded "$key" "$name"; then
    kcs_log_debug "$ns" "skipped loaded '%s:%s'" "$key" "$name"
    return 0
  fi

  if "$fs"; then
    local basepaths=() paths=()
    test -n "$KCS_PATH" && basepaths+=("$KCS_PATH")
    basepaths+=("$KCS_PATH_DIR_ROOT" "$KCS_PATH_DIR_SRC")

    local index=0 index_str=('1st' '2nd' '3rd')
    local basepath filepath
    for basepath in "${basepaths[@]}"; do
      filepath="$(__kcs_ld_path_builder \
        "$basepath" "$dir" "$prefix" "$name" "$suffix")"
      paths+=("$filepath")
      kcs_log_debug "$ns" "[%s] trying '%s'" "${index_str[$index]}" "$filepath"
      ((index++))
      if test -f "$filepath"; then
        if ! "$action_cb" "$key" "$name" "$filepath" "$@"; then
          "$error_cb" "$key" "$name" "$filepath" "$@"
          return $?
        fi
        "$saved" && __kcs_ld_loaded "$key" "$name"
        return 0
      fi
    done
  else
    local fn="$1"
    shift

    kcs_log_debug "$ns" "checking '%s' function" "$name"
    if command -v "$fn" >/dev/null; then
      if ! "$action_cb" "$key" "$name" "$fn" "$@"; then
        "$error_cb" "$key" "$name" "$fn" "$@"
        return $?
      fi
      return 0
    fi
  fi

  "$miss_cb" "$key" "$name" "${paths[*]}" "$@"
}

__kcs_ld_acb_source() {
  local ns="source.loader"
  local key="$1" name="$2" filepath="$3"
  shift 3

  kcs_log_debug "$ns" \
    "run '%s' with %d args [%s]" "$filepath" "$#" "$*"
  # shellcheck source=/dev/null
  source "$filepath" "$@"
}
__kcs_ld_acb_shell() {
  local ns="shell.loader"
  local key="$1" name="$2" filepath="$3"
  shift 3

  local runner
  ## Prefer bash first, if no use default shell instead
  runner="$(command -v bash)"
  test -z "$runner" && runner="$SHELL"

  kcs_log_debug "$ns" \
    "run '%s' using '%s' with %d args [%s]" "$filepath" "$runner" "$#" "$*"
  "$runner" "$filepath" "$@"
}
__kcs_ld_acb_function() {
  local ns="function.loader"
  local key="$1" name="$2" fn="$3"
  shift 3

  kcs_log_debug "$ns" \
    "run '%s' function with %d args [%s]" "$fn" "$#" "$*"
  "$fn" "$@"
}

__kcs_ld_mcb_mute() {
  local ns="miss-cb.loader"
  local key="$1" name="$2" filepath="$3"
  kcs_log_debug "$ns" "missing '%s:%s'" \
    "$key" "$name"
  return 0
}
__kcs_ld_mcb_silent() {
  local ns="miss-cb.loader"
  local key="$1" name="$2" filepath="$3"
  kcs_log_debug "$ns" "missing '%s:%s'" \
    "$key" "$name"
  return 1
}
__kcs_ld_mcb_warn() {
  local ns="miss-cb.loader"
  local key="$1" name="$2" filepath="$3"
  kcs_log_warn "$ns" "missing '%s:%s'" \
    "$key" "$name"
  return 1
}
__kcs_ld_mcb_error() {
  local ns="miss-cb.loader"
  local key="$1" name="$2" filepath="$3"
  kcs_log_error "$ns" "missing '%s:%s'" \
    "$key" "$name"
  return 1
}
__kcs_ld_mcb_throw() {
  local ns="miss-cb.loader"
  local key="$1" name="$2" filepath="$3"
  kcs_log_error "$ns" "missing '%s:%s'" \
    "$key" "$name"
  exit 1
}

__kcs_ld_ecb_mute() {
  local ns="error-cb.loader"
  local key="$1" name="$2" filepath="$3"
  kcs_log_debug "$ns" "loading '%s:%s' failed (%s)" \
    "$key" "$name" "$filepath"
  return 0
}
__kcs_ld_ecb_silent() {
  local ns="error-cb.loader"
  local key="$1" name="$2" filepath="$3"
  kcs_log_debug "$ns" "loading '%s:%s' failed (%s)" \
    "$key" "$name" "$filepath"
  return 1
}
__kcs_ld_ecb_warn() {
  local ns="error-cb.loader"
  local key="$1" name="$2" filepath="$3"
  kcs_log_warn "$ns" "loading '%s:%s' failed (%s)" \
    "$key" "$name" "$filepath"
  return 1
}
__kcs_ld_ecb_error() {
  local ns="error-cb.loader"
  local key="$1" name="$2" filepath="$3"
  kcs_log_error "$ns" "loading '%s:%s' failed (%s)" \
    "$key" "$name" "$filepath"
  return 1
}
__kcs_ld_ecb_throw() {
  local ns="error-cb.loader"
  local key="$1" name="$2" filepath="$3"
  kcs_log_error "$ns" "loading '%s:%s' failed (%s)" \
    "$key" "$name" "$filepath"
  exit 1
}

__kcs_ld_is_loaded() {
  local key="$1" name="$2"
  [[ "$_KCS_LOADED" =~ $key:$name ]]
}
__kcs_ld_loaded() {
  local ns="loaded.loader"
  local key="$1" name="$2"
  kcs_log_debug "$ns" "saving '%s:%s' as loaded module" \
    "$key" "$name"
  if test -z "$_KCS_LOADED"; then
    _KCS_LOADED="$key:$name"
  else
    _KCS_LOADED="$_KCS_LOADED,$key:$name"
  fi
}

__kcs_ld_path_builder() {
  local filepath="${1:?}" dir="$2" prefix="$3" name="$4" suffix="$5"
  test -n "$dir" && filepath="$filepath/$dir"
  printf '%s/%s%s%s' "$filepath" "$prefix" "$name" "$suffix"
}
