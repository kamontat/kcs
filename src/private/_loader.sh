#!/usr/bin/env bash

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

## Call libraries file
## usage: `kcs_ld_lib <name> <args...>`
kcs_ld_lib() {
  _kcs_ld_do source lifecycle throw throw libs "$@"
}

## Check is input lib is loaded
## usage: `kcs_ld_lib_is_loaded 'logger' && echo 'loaded'`
kcs_ld_lib_is_loaded() {
  __kcs_ld_is_loaded libs "$1"
}

## Call utilities file
## usage: `kcs_ld_utils <name> <args...>`
kcs_ld_utils() {
  _kcs_ld_do source lifecycle throw throw utils "$@"
}

## Load config file
## usage: `kcs_ld_config <name...>`
kcs_ld_config() {
  local name
  for name in "$@"; do
    _kcs_ld_do config nothing warn throw config "$name"
  done
}

## Unload config file
## usage: `kcs_ld_unconfig <name...>`
kcs_ld_unconfig() {
  local name
  for name in "$@"; do
    _kcs_ld_do unconfig nothing warn throw config "$name"
  done
}

## Check is input utils is loaded
## usage: `kcs_ld_utils_is_loaded 'example' && echo 'loaded'`
kcs_ld_utils_is_loaded() {
  __kcs_ld_is_loaded utils "$1"
}

## Call command file
## usage: `kcs_ld_cmd <name> <args...>`
kcs_ld_cmd() {
  _kcs_ld_do shell nothing silent throw cmd "$@"
}

## Call private libraries file
## usage: `kcs_ld_priv <name> <args...>`
_kcs_ld_priv() {
  _kcs_ld_do source lifecycle throw throw private "$@"
}

_kcs_ld_priv_is_loaded() {
  __kcs_ld_is_loaded private "$1"
}

_kcs_ld_do() {
  local ns="do.loader"
  local action_cb="__kcs_ld_acb_${1:?}"
  local success_cb="__kcs_ld_scb_${2:?}"
  local miss_cb="__kcs_ld_mcb_${3:?}"
  local error_cb="__kcs_ld_ecb_${4:?}"
  local _key="${5:?}" name="${6:?}"
  shift 6

  local fs=true saved=true
  local key prefix suffix
  case "$_key" in
  private | priv | p)
    key="private"
    prefix="_"
    suffix=".sh"
    ;;
  libraries | libs | lib | l)
    key="libs"
    prefix=""
    suffix=".sh"
    ;;
  utilities | utils | util | u)
    key="utils"
    prefix=""
    suffix=".sh"
    ;;
  commands | cmds | cmd | c)
    saved=false
    key="commands"
    prefix=""
    suffix=".sh"
    ;;
  configuration | configs | config | conf | cfg)
    saved=false
    key='configs'
    prefix="."
    suffix=''
    ;;
  functions | func | fn | f)
    key="func"
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
    basepaths+=("$_KCS_PATH_ROOT" "$_KCS_PATH_SRC")

    local index=0 index_str=('1st' '2nd' '3rd')
    local basepath filepath
    for basepath in "${basepaths[@]}"; do
      filepath="$(__kcs_ld_path_builder \
        "$basepath" "$key" "$prefix" "$name" "$suffix")"
      paths+=("$filepath")
      kcs_log_debug "$ns" "[%s] trying '%s'" "${index_str[$index]}" "$filepath"
      ((index++))
      if test -f "$filepath"; then
        if ! "$action_cb" "$key" "$name" "$filepath" "$@"; then
          "$error_cb" "$key" "$name" "$filepath" "$@"
          return $?
        fi
        "$saved" && __kcs_ld_loaded "$key" "$name"
        "$success_cb" "$key" "$name" "$@"
        return $?
      fi
    done
  else
    local fn="$1"
    shift

    kcs_log_debug "$ns" "checking function name '%s'" "$name"
    if test -z "$fn"; then
      kcs_log_error "$ns" \
        "function '%s' is not defined callback (%s)" "$name" "$fn"
      "$error_cb" "$key" "$name" "$fn" "$@"
      return $?
    fi

    if command -v "$fn" >/dev/null; then
      if ! "$action_cb" "$key" "$name" "$fn" "$@"; then
        "$error_cb" "$key" "$name" "$fn" "$@"
        return $?
      fi
      "$success_cb" "$key" "$name" "$@"
      return $?
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

  kcs_log_debug "$ns" "run '%s' using '%s' with %d args [%s]" \
    "$filepath" "$(basename "$runner")" "$#" "$*"
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
__kcs_ld_acb_config() {
  local ns="config.loader"
  local key="$1" name="$2" filepath="$3"
  shift 3
  local line key value
  while read -r line; do
    key="${line%%=*}"
    value="${line#*=}"
    export "$key"="$value"
  done <"$filepath"
}
__kcs_ld_acb_unconfig() {
  local ns="unconfig.loader"
  local key="$1" name="$2" filepath="$3"
  shift 3
  local line key value
  while read -r line; do
    key="${line%%=*}"
    value="${line#*=}"
    unset "$key"
  done <"$filepath"
}

__kcs_ld_scb_nothing() {
  local ns="success-cb.loader"
  local key="$1" name="$2"
  shift 2

  return 0
}
__kcs_ld_scb_lifecycle() {
  local ns="success-cb.loader"
  local key="$1" name="$2"
  shift 2

  ## Alias is not useful as it should be
  ## To reduce calculate time, I would comment this first
  # local alias="__kcs_${name}_lc_alias"
  # if command -v "$alias" >/dev/null; then
  #   local old="$name"
  #   name="$("$alias")"
  #   unset -f "$alias"
  #   kcs_log_debug "$ns" "found name alias of '%s:%s' as '%s'" "$key" "$old" "$name"
  # fi

  local init="__kcs_${name}_lc_init"
  if command -v "$init" >/dev/null; then
    kcs_log_debug "$ns" \
      "found init function of '%s:%s' with [%s]" "$key" "$name" "$*"
    "$init" "$@" && unset -f "$init" || return 1
  fi
  local start="__kcs_${name}_lc_start"
  if command -v "$start" >/dev/null; then
    kcs_log_debug "$ns" \
      "found start function of '%s:%s' with [%s]" "$key" "$name" "$*"
    "$start" "$@" && unset -f "$start" || return 1
  fi
  return 0
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
  local key="$1" name="$2" filepath="$3"
  kcs_exit 1 "missing '%s:%s'" \
    "$key" "$name"
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
  local key="$1" name="$2" filepath="$3"
  kcs_exit 1 "loading '%s:%s' failed (%s)" \
    "$key" "$name" "$filepath"
}

__kcs_ld_is_loaded() {
  local key="$1" name="$2"
  [[ "$_KCS_LOADED" =~ $key:$name ]]
}
__kcs_ld_loaded() {
  local ns="status.loader"
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
