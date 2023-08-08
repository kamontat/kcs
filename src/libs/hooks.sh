#!/usr/bin/env bash

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

_KCS_HOOKS_DB_ALL="__kcs_hooks_db"
_KCS_HOOKS_DB_DISABLE="__kcs_hooks_db_disable"
## supported hooks
_KCS_HOOKS_NAMES=(
  pre_init init post_init
  pre_main main post_main
  pre_clean clean post_clean
  finish
)

## cb will send callback as first parameter
export KCS_HOOKS_TAG_CALLBACK="@callback"
## optional mean can be missing but cannot fail
export KCS_HOOKS_TAG_OPTIONAL="@optional"
## silent mean can be missing or fail
export KCS_HOOKS_TAG_SILENT="@silent"
## raw will send raw user argument to callback
export KCS_HOOKS_TAG_RAW="@raw"
## add arguments from input variable name
export KCS_HOOKS_TAG_VARARGS="@varargs"
_KCS_HOOKS_TAGS=(
  "$KCS_HOOKS_TAG_CALLBACK"
  "$KCS_HOOKS_TAG_OPTIONAL"
  "$KCS_HOOKS_TAG_SILENT"
  "$KCS_HOOKS_TAG_RAW"
  "$KCS_HOOKS_TAG_VARARGS"
)

## Adding callback on hook name
## usage `kcs_hooks_add <name> <callback> <tags...>`
## example `kcs_hooks_add 'pre_init' logger '@varargs=EXAMPLE' '@raw=hello world'`
## signature:
##   - callback: `__kcs_<callback>_hook_<name>` = `__kcs_logger_hook_pre_init`
kcs_hooks_add() {
  local ns="add.hooks"
  local name="$1" cb="$2"
  shift 2
  local tags=("$@")

  local key="${name##*_}"
  local callback="__kcs_${cb}_hook_${key}"

  if ! [[ "${_KCS_HOOKS_NAMES[*]}" =~ $name ]]; then
    kcs_log_error "$ns" "'%s' hook is not a valid hook name" "$name"
    kcs_log_error "$ns" "invalid '%s' hook name" "$name"
    return 1
  fi

  local prev=()
  eval "prev=(\"\${${_KCS_HOOKS_DB_ALL}_${name}[@]}\")"
  if [[ "${prev[*]}" =~ $callback: ]]; then
    kcs_log_debug "$ns" \
      "skipped '%s' duplicated callback on '%s' hook" "$cb" "$name"
    return 0
  fi

  local tag_raw tags_str
  local tag_key tag_value tag_keys_str
  for tag_raw in "${tags[@]}"; do
    tag_key="${tag_raw%%=*}"
    if ! [[ "${_KCS_HOOKS_TAGS[*]}" =~ $tag_key ]]; then
      kcs_log_warn "$ns" "invalid '%s' tag at '%s' hook" "$tag_key" "$name"
      continue
    fi

    tag_value="${tag_raw#*=}"
    if [[ "$tag_value" =~ [,] ]]; then
      kcs_log_warn \
        "$ns" "tag '%s' contains blacklist character (%s)" \
        "$tag_key" "$tag_value"
      continue
    fi

    test -n "$tag_keys_str" && tag_keys_str="${tag_keys_str},"
    tag_keys_str="$tag_keys_str$tag_key"

    [[ "$tag_key" == "$tag_value" ]] && tag_value=true
    test -n "$tags_str" && tags_str="${tags_str},"
    tags_str="$tags_str$tag_key=$tag_value"
  done

  local tag_msg=""
  test -n "$tag_keys_str" && tag_msg="with '$tag_keys_str' "

  kcs_log_debug "$ns" \
    "adding '%s' %sto hook name '%s'" "$callback" "$tag_msg" "$name"
  eval "${_KCS_HOOKS_DB_ALL}_${name}+=(\"$callback:$tags_str\")"
}

## Disabled callback on hook name or
## disabled all callback on hook name
## usage `kcs_hooks_add <name> [<callback>]`
kcs_hooks_disable() {
  local ns="disable.hooks" all='<all>'
  local name="$1" callback="$2"

  local prev
  eval "prev=\"\${${_KCS_HOOKS_DB_DISABLE}_${name}[*]}\""
  if [[ "$prev" =~ $all ]]; then
    kcs_log_debug "$ns" "all callback has been disabled on '%s' hook" "$name"
    return 0
  fi

  if test -z "$callback"; then
    kcs_log_debug "$ns" "disabled all callback under '%s' hook" "$name"
    eval "${_KCS_HOOKS_DB_DISABLE}_${name}=(\"$all\")"
  else
    kcs_log_debug "$ns" "disabled '%s' callback under '%s' hook" \
      "$callback" "$name"
    eval "${_KCS_HOOKS_DB_DISABLE}_${name}+=(\"$callback\")"
  fi
}

## Run all callback on input hook name
## usage `kcs_hooks_run <name> <raw_args...>`
kcs_hooks_run() {
  local ns="runner.hooks"
  local name="$1" all='<all>'
  shift
  local raw_args=("$@")

  local raw callback callbacks=()
  local tags tag_raw tag_key tag_value
  eval "callbacks=(\"\${${_KCS_HOOKS_DB_ALL}_${name}[@]}\")"
  local disables=()
  eval "disables=(\"\${${_KCS_HOOKS_DB_DISABLE}_${name}[@]}\")"

  if [[ "${disables[*]}" =~ $all ]]; then
    kcs_log_debug "$ns" "all callback on '%s' hook is disabled" "$name"
    return 0
  elif [[ "${callbacks[*]}" == '' ]]; then
    kcs_log_debug "$ns" "found %d callbacks on '%s' hook" \
      0 "$name"
    return 0
  fi

  kcs_log_debug "$ns" "found %d callbacks on '%s' hook" \
    "${#callbacks[@]}" "$name"
  for raw in "${callbacks[@]}"; do
    callback="${raw%%:*}"
    tags="${raw#*:}"

    if [[ "${disables[*]}" =~ $callback ]]; then
      kcs_log_debug "$ns" "disabled '%s' callback on '%s' hook" \
        "$callback" "$name"
      continue
    fi

    local executor=kcs_func_must
    local args=() is_tag_raw=false tag_cb tag_vararg
    while read -r tag_raw; do
      tag_key="${tag_raw%%=*}"
      tag_value="${tag_raw#*=}"

      case "$tag_key" in
      "$KCS_HOOKS_TAG_OPTIONAL") executor=kcs_func_optional ;;
      "$KCS_HOOKS_TAG_SILENT") executor=kcs_func_silent ;;
      "$KCS_HOOKS_TAG_RAW") is_tag_raw=true ;;
      "$KCS_HOOKS_TAG_CALLBACK") tag_cb="$tag_value" ;;
      "$KCS_HOOKS_TAG_VARARGS") tag_vararg="$tag_value" ;;
      esac
    done <<<"$(echo "$tags" | tr ',' '\n')"

    test -n "$tag_cb" && args=("$tag_cb")
    # shellcheck disable=SC2206
    test -n "$tag_vararg" && args+=($tag_vararg)
    "$is_tag_raw" && args+=("${raw_args[@]}")

    kcs_log_debug "$ns" "using '%s' for '%s' callback" "$executor" "$callback"
    "$executor" "$callback" "$callback" "${args[@]}"
  done
}

## Run all callback on all hooks based on life cycle
## usage `kcs_hooks_start <raw_args...>`
kcs_hooks_start() {
  local name ns="starter.hooks"
  for name in "${_KCS_HOOKS_NAMES[@]}"; do
    kcs_hooks_run "$name" "$@"
  done
}

kcs_hooks_stop() {
  unset KCS_HOOKS_TAG_CALLBACK KCS_HOOKS_TAG_OPTIONAL
  unset KCS_HOOKS_TAG_SILENT KCS_HOOKS_TAG_RAW
  unset KCS_HOOKS_TAG_VARARGS

  unset _KCS_HOOKS_DB_ALL _KCS_HOOKS_DB_DISABLE
  unset _KCS_HOOKS_TAGS _KCS_HOOKS_NAMES
}

__kcs_hooks_lc_init() {
  kcs_ld_lib functions
}
