#!/usr/bin/env bash

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

## Call libraries file
## usage: `kcs_ld_lib <name> <args...>`
kcs_ld_lib() {
  _kcs_ld_do \
    --key libs \
    --suffix .sh \
    --action source \
    --on-success lifecycle \
    --on-missing throw \
    --on-error throw \
    --deduplicated \
    -- "$@"
}

## Check is input lib is loaded
## usage: `kcs_ld_lib_is_loaded 'logger' && echo 'loaded'`
kcs_ld_lib_is_loaded() {
  _kcs_ld_is_loaded libs "$1"
}

## Call utilities file
## usage: `kcs_ld_utils <name> <args...>`
kcs_ld_utils() {
  _kcs_ld_do \
    --key utils \
    --suffix .sh \
    --action source \
    --on-success lifecycle \
    --on-missing throw \
    --on-error throw \
    --deduplicated \
    -- "$@"
}

## Check is input utils is loaded
## usage: `kcs_ld_utils_is_loaded 'example' && echo 'loaded'`
kcs_ld_utils_is_loaded() {
  _kcs_ld_is_loaded utils "$1"
}

## Call private libraries file
## usage: `kcs_ld_priv <name> <args...>`
_kcs_ld_priv() {
  _kcs_ld_do \
    --key private \
    --prefix _ \
    --suffix .sh \
    --action source \
    --on-success lifecycle \
    --on-missing throw \
    --on-error throw \
    --deduplicated \
    -- "$@"
}

## Check is input private is loaded
## usage: `_kcs_ld_priv_is_loaded 'example' && echo 'loaded'`
_kcs_ld_priv_is_loaded() {
  _kcs_ld_is_loaded private "$1"
}

_kcs_ld_do() {
  local ns="private.loader.do"
  local raw=("$@")
  local i arg is_arg=false args=()
  local key prefix suffix module
  local loader=filesystem deduplicated=false use_regex=false
  local action_cb success_cb error_cb miss_cb
  for ((i = 0; i < ${#raw[@]}; i++)); do
    arg="${raw[$i]}"

    ## Too many logs
    # kcs_log_debug "$ns" "parsing: '%s' (arg=%s)" "$arg" "$is_arg"
    if $is_arg; then
      args+=("$arg")
      continue
    fi
    if [[ "$arg" == "--" ]]; then
      is_arg=true
      continue
    fi

    case "$arg" in
    ## Can use on all loader
    --key) key="${raw[$((i + 1))]}" && ((i++)) ;;
    --module) module="${raw[$((i + 1))]}" && ((i++)) ;;
    --on-success) success_cb="${raw[$((i + 1))]}" && ((i++)) ;;
    --on-error) error_cb="${raw[$((i + 1))]}" && ((i++)) ;;
    --on-missing) miss_cb="${raw[$((i + 1))]}" && ((i++)) ;;
    ## Only filesystem loader
    --filesystem) loader='filesystem' ;;
    --prefix) prefix="${raw[$((i + 1))]}" && ((i++)) ;;
    --suffix) suffix="${raw[$((i + 1))]}" && ((i++)) ;;
    --regex) use_regex=true ;;
    --deduplicated) deduplicated=true ;;
    --action) action_cb="${raw[$((i + 1))]}" && ((i++)) ;;
    --action-*)
      local act_name
      act_name="$(printf '%s' "$arg" | sed 's/--action-//' | sed 's/-/_/')"
      local "action_${act_name}_cb"="${raw[$((i + 1))]}" && ((i++))
      ;;
      ## Only function loader
    --function) loader='function' ;;

    --*) kcs_log_error "$ns" "unknown loading options (%s)" "$arg" ;;
    esac
  done

  local name="${args[0]}"
  local data=("${args[@]:1}")

  test -z "$key" &&
    kcs_log_error "$ns" "option --key is required" && return 1
  test -z "$name" &&
    kcs_log_error "$ns" "first argument is required" && return 1
  test -n "$module" && module="__kcs_$module" || module="__kcs"
  success_cb="__kcs_ld_scb_${success_cb:-nothing}"
  miss_cb="__kcs_ld_mcb_${miss_cb:-warn}"
  error_cb="__kcs_ld_ecb_${error_cb:-error}"

  ## Skip duplicated modules
  if "$deduplicated" && _kcs_ld_is_loaded "$key" "$name"; then
    ## This can handle when lib try to load its dependencies
    kcs_log_debug "$ns" "skipping '%s:%s' because it has been loaded" \
      "$key" "$name"
    return 0
  fi

  ## Load script to filesystem
  if [[ "$loader" == "filesystem" ]]; then
    local basepaths=() paths=()
    test -n "$KCS_PATH" && basepaths+=("$KCS_PATH")
    basepaths+=("$_KCS_PATH_ROOT" "$_KCS_PATH_SRC")

    local index_str=('1st' '2nd' '3rd' '4th' '5th' '6th' '7th' '8th' '9th')
    local basepath filepath filename
    for ((i = 0; i < ${#basepaths[@]}; i++)); do

      ## Use regex will add * as prefix and suffix of name
      "$use_regex" && filename="*$name*" || filename="$name"
      basepath="${basepaths[$i]}"
      filepath="$(
        _kcs_ld_path_builder "$basepath" "$key" "$prefix" "$filename" "$suffix"
      )"
      paths+=("$filepath")
      kcs_log_debug "$ns" "[%s] trying '%s'" "${index_str[$i]}" "$filepath"

      local raw_ext ext fp fps=()
      for fp in $filepath; do
        fps+=("$fp")
      done

      if [ ${#fps[@]} -gt 1 ]; then
        kcs_log_error "$ns" "found '%s' more than 1 files (%s)" \
          "$filepath" "${fps[*]}"
        return 1
      elif test -f "${fp}"; then
        kcs_log_debug "$ns" "found file at '%s'" "$fp"

        raw_ext="$(basename "$fp")"
        raw_ext="${raw_ext%.*}"
        ext="${raw_ext##*.}"
        if [[ "$raw_ext" != "$ext" ]]; then
          eval "action_cb=\"\$action_${ext//-/_}_cb\""
        fi

        ## Convert action callback to correct format
        if test -n "$action_cb"; then
          action_cb="${module}_ld_acb_$action_cb"
        else
          kcs_log_error "$ns" "option --action-cb is required" && return 1
        fi

        kcs_log_debug "$ns" "execute '%s' as action callback" "$action_cb"
        if ! "$action_cb" "$key" "$name" "$fp" "${data[@]}"; then
          "$error_cb" "$key" "$name" "$fp" "${data[@]}"
          return $?
        fi
        "$deduplicated" && _kcs_ld_save "$key" "$name"
        "$success_cb" "$key" "$name" "${data[@]}"
        return $?
      fi
    done

    "$miss_cb" "$key" "$name" "${paths[*]}" "${data[@]}"
    return $?
  elif [[ "$loader" == "function" ]]; then
    local fn="${data[0]}"
    local params=("${data[@]:1}")

    ## Convert action callback to correct format
    if test -n "$action_cb"; then
      action_cb="${module}_ld_acb_$action_cb"
    else
      kcs_log_error "$ns" "option --action-cb is required" && return 1
    fi

    kcs_log_debug "$ns" "checking function '%s' (%s)" "$name" "$fn"
    if test -z "$fn"; then
      kcs_log_error "$ns" "function '%s' is not defined callback (%s)" \
        "$name" "$fn"
      "$error_cb" "$key" "$name" "$fn" "${params[@]}"
      return $?
    fi

    if command -v "$fn" >/dev/null; then
      if ! "$action_cb" "$key" "$name" "$fn" "${params[@]}"; then
        "$error_cb" "$key" "$name" "$fn" "${params[@]}"
        return $?
      fi
      "$success_cb" "$key" "$name" "${params[@]}"
      return $?
    fi
    "$miss_cb" "$key" "$name" "$fn" "$@"
    return $?
  fi

  kcs_log_error "$ns" "unknown loader type '%s'" "$loader" && return 1
}

__kcs_ld_acb_source() {
  local ns="private.loader.source"
  local key="$1" name="$2" filepath="$3"
  shift 3

  kcs_log_debug "$ns" \
    "run '%s' with %d args [%s]" "$filepath" "$#" "$*"

  # shellcheck source=/dev/null
  source "$filepath" "$@"
}

__kcs_ld_scb_nothing() {
  local ns="private.loader.cb.success"
  local key="$1" name="$2"
  shift 2

  return 0
}
__kcs_ld_scb_lifecycle() {
  local ns="private.loader.cb.success"
  local key="$1" name="$2"
  shift 2

  if command -v kcs_conf_load >/dev/null; then
    if ! kcs_conf_load "$name"; then
      return 1
    fi
  else
    kcs_log_debug "$ns" "skipping config loading (%s)" "$name"
  fi

  local init="__kcs_${name}_on_init"
  if command -v "$init" >/dev/null; then
    kcs_log_debug "$ns" \
      "found init function of '%s:%s' with [%s]" "$key" "$name" "$*"
    "$init" "$@" && unset -f "$init" || return 1
  fi

  return 0
}

__kcs_ld_mcb_mute() {
  local ns="private.loader.cb.miss"
  local key="$1" name="$2" filepath="$3"
  local suffix
  test -n "$filepath" && [[ "$name" != "$filepath" ]] &&
    suffix=" ($filepath)"
  kcs_log_debug "$ns" "missing '%s:%s'%s" "$key" "$name" "$suffix"
  return 0
}
__kcs_ld_mcb_silent() {
  local ns="private.loader.cb.miss"
  local key="$1" name="$2" filepath="$3"
  local suffix
  test -n "$filepath" && [[ "$name" != "$filepath" ]] &&
    suffix=" ($filepath)"
  kcs_log_debug "$ns" "missing '%s:%s'%s" "$key" "$name" "$suffix"
  return 1
}
__kcs_ld_mcb_warn() {
  local ns="private.loader.cb.miss"
  local key="$1" name="$2" filepath="$3"
  local suffix
  test -n "$filepath" && [[ "$name" != "$filepath" ]] &&
    suffix=" ($filepath)"
  kcs_log_warn "$ns" "missing '%s:%s'%s" "$key" "$name" "$suffix"
  return 1
}
__kcs_ld_mcb_error() {
  local ns="private.loader.cb.miss"
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
  local ns="private.loader.cb.error"
  local key="$1" name="$2" filepath="$3"
  local suffix
  test -n "$filepath" && [[ "$name" != "$filepath" ]] &&
    suffix=" ($filepath)"
  kcs_log_debug "$ns" "loading '%s:%s' failed%s" \
    "$key" "$name" "$suffix"
  return 0
}
__kcs_ld_ecb_silent() {
  local ns="private.loader.cb.error"
  local key="$1" name="$2" filepath="$3"
  local suffix
  test -n "$filepath" && [[ "$name" != "$filepath" ]] &&
    suffix=" ($filepath)"
  kcs_log_debug "$ns" "loading '%s:%s' failed%s" \
    "$key" "$name" "$suffix"
  return 1
}
__kcs_ld_ecb_warn() {
  local ns="private.loader.cb.error"
  local key="$1" name="$2" filepath="$3"
  local suffix
  test -n "$filepath" && [[ "$name" != "$filepath" ]] &&
    suffix=" ($filepath)"
  kcs_log_warn "$ns" "loading '%s:%s' failed%s" \
    "$key" "$name" "$suffix"
  return 1
}
__kcs_ld_ecb_error() {
  local ns="private.loader.cb.error"
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
_kcs_ld_save() {
  local ns="private.loader.save"
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
