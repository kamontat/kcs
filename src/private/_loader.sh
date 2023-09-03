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
  _kcs_ld_is_loaded libs "$1"
}

## Call utilities file
## usage: `kcs_ld_utils <name> <args...>`
kcs_ld_utils() {
  _kcs_ld_do source lifecycle throw throw utils "$@"
}

## Load env file (this env has priority lower than external environment)
## This will skipped if environment is declared
## usage: `kcs_ld_env_default <name...>`
kcs_ld_env_default() {
  local name
  for name in "$@"; do
    _kcs_ld_do env_default nothing warn throw env "$name"
  done
}

## Load env file
## usage: `kcs_ld_env <name...>`
kcs_ld_env() {
  local name
  for name in "$@"; do
    _kcs_ld_do env nothing error throw env "$name"
  done
}

## Unload env file
## usage: `kcs_ld_unenv <name...>`
kcs_ld_unenv() {
  local name
  for name in "$@"; do
    _kcs_ld_do unenv nothing mute throw env "$name"
  done
}

## Check is input utils is loaded
## usage: `kcs_ld_utils_is_loaded 'example' && echo 'loaded'`
kcs_ld_utils_is_loaded() {
  _kcs_ld_is_loaded utils "$1"
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
  _kcs_ld_is_loaded private "$1"
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
  environment | env | e)
    saved=false
    key='envs'
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

  if "$saved" && _kcs_ld_is_loaded "$key" "$name"; then
    ## This can handle when lib try to load its dependencies
    kcs_log_debug "$ns" \
      "skipping '%s:%s' because it has been loaded" "$key" "$name"
    return 0
  fi

  if "$fs"; then
    local basepaths=() paths=()
    test -n "$KCS_PATH" && basepaths+=("$KCS_PATH")
    basepaths+=("$_KCS_PATH_ROOT" "$_KCS_PATH_SRC")

    local index=0 index_str=('1st' '2nd' '3rd')
    local basepath filepath
    for basepath in "${basepaths[@]}"; do
      filepath="$(_kcs_ld_path_builder \
        "$basepath" "$key" "$prefix" "$name" "$suffix")"
      paths+=("$filepath")
      kcs_log_debug "$ns" "[%s] trying '%s'" "${index_str[$index]}" "$filepath"
      ((index++))
      if test -f "$filepath"; then
        if ! "$action_cb" "$key" "$name" "$filepath" "$@"; then
          "$error_cb" "$key" "$name" "$filepath" "$@"
          return $?
        fi
        "$saved" && _kcs_ld_loaded "$key" "$name"
        "$success_cb" "$key" "$name" "$@"
        return $?
      fi
    done
    "$miss_cb" "$key" "$name" "${paths[*]}" "$@"
  else
    local fn="$1"
    shift

    kcs_log_debug "$ns" "checking function '%s' (%s)" "$name" "$fn"
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
    "$miss_cb" "$key" "$name" "$fn" "$@"
  fi
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
__kcs_ld_acb_env_default() {
  local ns="env-default.loader"
  local key="$1" name="$2" filepath="$3"
  shift 3
  local line key value keys=()
  while read -r line; do
    if test -n "$line"; then
      key="${line%%=*}"
      value="${line#*=}"
      keys+=("$key")
      if ! declare -p "$key" >/dev/null 2>&1; then
        export "$key"="$value"
      else
        kcs_log_debug "$ns" "variable '%s' is created, skipped" "$key"
      fi
    fi
  done <"$filepath"
  kcs_log_debug "$ns" "export '%d' variables [%s]" "${#keys[@]}" "${keys[*]}"
}
__kcs_ld_acb_env() {
  local ns="env.loader"
  local key="$1" name="$2" filepath="$3"
  shift 3
  local line key value keys=()
  while read -r line; do
    if test -n "$line"; then
      key="${line%%=*}"
      value="${line#*=}"
      keys+=("$key")
      export "$key"="$value"
    fi
  done <"$filepath"
  kcs_log_debug "$ns" "export '%d' variables [%s]" "${#keys[@]}" "${keys[*]}"
}
__kcs_ld_acb_unenv() {
  local ns="unenv.loader"
  local key="$1" name="$2" filepath="$3"
  shift 3
  local line key value keys=()
  while read -r line; do
    if test -n "$line"; then
      key="${line%%=*}"
      value="${line#*=}"
      keys+=("$key")
      unset "$key"
    fi
  done <"$filepath"
  kcs_log_debug "$ns" "unset '%d' variables [%s]" "${#keys[@]}" "${keys[*]}"
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

  if command -v kcs_conf_load >/dev/null; then
    if ! kcs_conf_load "$name"; then
      return 1
    fi
  else
    kcs_log_debug "$ns" "skipping config loading (%s)" "$name"
  fi

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
  local suffix
  test -n "$filepath" && [[ "$name" != "$filepath" ]] &&
    suffix=" ($filepath)"
  kcs_log_debug "$ns" "missing '%s:%s'%s" "$key" "$name" "$suffix"
  return 0
}
__kcs_ld_mcb_silent() {
  local ns="miss-cb.loader"
  local key="$1" name="$2" filepath="$3"
  local suffix
  test -n "$filepath" && [[ "$name" != "$filepath" ]] &&
    suffix=" ($filepath)"
  kcs_log_debug "$ns" "missing '%s:%s'%s" "$key" "$name" "$suffix"
  return 1
}
__kcs_ld_mcb_warn() {
  local ns="miss-cb.loader"
  local key="$1" name="$2" filepath="$3"
  local suffix
  test -n "$filepath" && [[ "$name" != "$filepath" ]] &&
    suffix=" ($filepath)"
  kcs_log_warn "$ns" "missing '%s:%s'%s" "$key" "$name" "$suffix"
  return 1
}
__kcs_ld_mcb_error() {
  local ns="miss-cb.loader"
  local key="$1" name="$2" filepath="$3"
  local suffix
  test -n "$filepath" && [[ "$name" != "$filepath" ]] &&
    suffix=" ($filepath)"
  kcs_log_error "$ns" "missing '%s:%s'%s" "$key" "$name" "$suffix"
  return 1
}
__kcs_ld_mcb_throw() {
  local key="$1" name="$2" filepath="$3"
  local suffix
  test -n "$filepath" && [[ "$name" != "$filepath" ]] &&
    suffix=" ($filepath)"
  kcs_exit 1 "missing '%s:%s'%s" "$key" "$name" "$suffix"
}

__kcs_ld_ecb_mute() {
  local ns="error-cb.loader"
  local key="$1" name="$2" filepath="$3"
  local suffix
  test -n "$filepath" && [[ "$name" != "$filepath" ]] &&
    suffix=" ($filepath)"
  kcs_log_debug "$ns" "loading '%s:%s' failed%s" \
    "$key" "$name" "$suffix"
  return 0
}
__kcs_ld_ecb_silent() {
  local ns="error-cb.loader"
  local key="$1" name="$2" filepath="$3"
  local suffix
  test -n "$filepath" && [[ "$name" != "$filepath" ]] &&
    suffix=" ($filepath)"
  kcs_log_debug "$ns" "loading '%s:%s' failed%s" \
    "$key" "$name" "$suffix"
  return 1
}
__kcs_ld_ecb_warn() {
  local ns="error-cb.loader"
  local key="$1" name="$2" filepath="$3"
  local suffix
  test -n "$filepath" && [[ "$name" != "$filepath" ]] &&
    suffix=" ($filepath)"
  kcs_log_warn "$ns" "loading '%s:%s' failed%s" \
    "$key" "$name" "$suffix"
  return 1
}
__kcs_ld_ecb_error() {
  local ns="error-cb.loader"
  local key="$1" name="$2" filepath="$3"
  local suffix
  test -n "$filepath" && [[ "$name" != "$filepath" ]] &&
    suffix=" ($filepath)"
  kcs_log_error "$ns" "loading '%s:%s' failed%s" \
    "$key" "$name" "$suffix"
  return 1
}
__kcs_ld_ecb_throw() {
  local key="$1" name="$2" filepath="$3"
  local suffix
  test -n "$filepath" && [[ "$name" != "$filepath" ]] &&
    suffix=" ($filepath)"
  kcs_exit 1 "loading '%s:%s' failed%s" \
    "$key" "$name" "$suffix"
}

_kcs_ld_is_loaded() {
  local key="$1" name="$2"
  [[ "$_KCS_LOADED" =~ $key:$name ]]
}
_kcs_ld_loaded() {
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

_kcs_ld_path_builder() {
  local filepath="${1:?}" dir="$2" prefix="$3" name="$4" suffix="$5"
  test -n "$dir" && filepath="$filepath/$dir"
  printf '%s/%s%s%s' "$filepath" "$prefix" "$name" "$suffix"
}
