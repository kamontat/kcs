#!/usr/bin/env bash

## Hook manager:
##   a collection of hook functions and constants

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

_KCS_HOOK_VAR_PREFIX="__kcs_hooks"
_KCS_HOOK_DISABLE_VAR_PREFIX="__kcs_hooks_disabled"
_KCS_HOOK_DISABLE_ALL_VAR_PREFIX="__kcs_hooks_disabled_all"

_KCS_HOOK_NAMES=(
  pre_init init post_init
  pre_load load post_load
  pre_main main post_main
  pre_clean clean post_clean
)

## optional mean can be missing but cannot fail
export KCS_HOOK_TAG_OPTIONAL="@optional"
## silent mean can be missing or fail
export KCS_HOOK_TAG_SILENT="@silent"
## raw will send raw user argument to hook
export KCS_HOOK_TAG_RAW="@raw"
## cb will send callback as first parameter
export KCS_HOOK_TAG_CALLBACK="@cb"
## add arguments from input variable name
export KCS_HOOK_TAG_ARGS="@args"

_KCS_HOOK_TAGS=(
  "$KCS_HOOK_TAG_CALLBACK"
  "$KCS_HOOK_TAG_OPTIONAL"
  "$KCS_HOOK_TAG_SILENT"
  "$KCS_HOOK_TAG_RAW"
  "$KCS_HOOK_TAG_ARGS"
)

## Add new callback $2 on hook name $1
## callback syntax:
##   - <callback>:<tags>,<tags>,...
##     tag syntax:
##       - <tag_name>=<tag_value>
##       - tag_name must prefix with '@'
kcs_add_hook() {
  local ns="hook-adder"
  local name="$1" raw="$2"

  local command="${raw%%:*}"
  local tags="" raw_tag tag_key

  if [[ "${_KCS_HOOK_NAMES[*]}" =~ $name ]]; then
    local prev=()
    eval "prev=(\"\${${_KCS_HOOK_VAR_PREFIX}_${name}[@]}\")"

    if [[ "${prev[*]}" =~ $command ]]; then
      kcs_debug "$ns" "duplicated command '%s' at '%s' hook, skipped" \
        "$command" "$name"
      return 0
    fi

    for raw_tag in $(__kcs_parse_tags "${raw#*:}"); do
      tag_key="${raw_tag%%=*}"

      test -n "$tags" && tags="$tags,"
      tags="$tags$tag_key"
    done

    local tag_msg=""
    test -n "$tags" && tag_msg="with '$tags' "

    kcs_debug "$ns" "adding '%s' %sto hook name '%s'" \
      "$command" "$tag_msg" "$name"

    eval "${_KCS_HOOK_VAR_PREFIX}_${name}+=(\"$raw\")"
  else
    kcs_warn "$ns" "adding invalid hook name '%s'" \
      "$name"
  fi
}

## @example kcs_disable_hook "pre_init:example"
## @example kcs_disable_hook "check"
kcs_disable_hook() {
  local ns="hook-remover"
  local prefix="__kcs_"
  local raw="$1" name cb
  name="${raw%%:*}"
  cb="${raw#*:}"

  if [[ "${_KCS_HOOK_NAMES[*]}" =~ $name ]]; then
    if [[ "$name" == "$cb" ]]; then
      kcs_debug "$ns" "disabling '<all>' on '%s' hook" \
        "$name"
      eval "${_KCS_HOOK_DISABLE_ALL_VAR_PREFIX}_${name}=true"
    else
      kcs_debug "$ns" "disabling '%s' on '%s' hook" \
        "$prefix$cb" "$name"
      eval "${_KCS_HOOK_DISABLE_VAR_PREFIX}_${name}+=(\"$prefix$cb\")"
    fi

  else
    kcs_warn "$ns" "disabling invalid hook name '%s'" \
      "$name"
  fi
}

_kcs_run_hook() {
  local name="$1" raw_args=()
  shift
  raw_args=("$@")

  local ns="hook-runner"
  local commands=() disables=() disabled=""

  ## Load commands from hooks variable
  eval "commands=(\"\${${_KCS_HOOK_VAR_PREFIX}_${name}[@]}\")"
  eval "disables=(\"\${${_KCS_HOOK_DISABLE_VAR_PREFIX}_${name}[@]}\")"
  eval "disabled=(\"\${${_KCS_HOOK_DISABLE_ALL_VAR_PREFIX}_${name}}\")"

  if test -n "$disabled"; then
    kcs_debug "$ns" "disabled all %03d %s hook commands" \
      "${#commands[@]}" \
      "$name"
    return 0
  fi

  kcs_debug "$ns" "running %d %11s hook commands (disabled=%d)" \
    "${#commands[@]}" \
    "$name" \
    "${#disables[@]}"

  export KCS_HOOK_NAME="$name"
  disabled="${disables[*]}"

  for raw in "${commands[@]}"; do
    local command="${raw%%:*}"
    if [[ "$disabled" =~ $command ]]; then
      kcs_debug "$ns" "disabled command '%s' on %s hook" \
        "$command" "$name"
      continue
    fi

    local executor="kcs_must_exec"
    local _callback="" _raw_args=() _args=()
    for raw_tag in $(__kcs_parse_tags "${raw#*:}"); do
      tag_key="${raw_tag%%=*}"
      tag_value="${raw_tag#*=}"

      case "$tag_key" in
      "$KCS_HOOK_TAG_OPTIONAL")
        executor="kcs_optional_exec"
        ;;
      "$KCS_HOOK_TAG_SILENT")
        executor="kcs_ignore_exec"
        ;;
      "$KCS_HOOK_TAG_CALLBACK")
        _callback="$tag_value"
        ;;
      "$KCS_HOOK_TAG_RAW")
        _raw_args+=("${raw_args[@]}")
        ;;
      "$KCS_HOOK_TAG_ARGS")
        eval "_args+=(\"\${${tag_value}[@]}\")"
        ;;
      esac
    done

    local args=()
    test -n "$_callback" &&
      args+=("$_callback")
    [ "${#_args[@]}" -gt 0 ] &&
      args+=("${_args[@]}")
    [ "${#_raw_args[@]}" -gt 0 ] &&
      args+=("${_raw_args[@]}")

    ## If on dry run hook mode
    if test -n "$DRY_HOOK"; then
      kcs_logf "dry-exec" "%s: %s '%s'" \
        "$executor" "$command" "${args[*]}"
      continue
    fi

    "$executor" "$command" "${args[@]}"
  done

  unset KCS_HOOK_NAME
}

_kcs_run_hooks() {
  local args=()
  for name in "${_KCS_HOOK_NAMES[@]}"; do
    if [ "${#KCS_ARGS[@]}" -gt 0 ]; then
      args=("${KCS_ARGS[@]}")
    else
      args=("$@")
    fi

    _kcs_run_hook "$name" "${args[@]}"
  done
}

__kcs_parse_tags() {
  local raw="$1" output=()

  printf "%s" "$raw" | grep -q "@" ||
    return 0

  local tag tag_key tag_value
  ## Load tag to _tag_<key>=<value>
  for tag in ${raw//,/ }; do
    tag_key="${tag%%=*}"
    tag_value="${tag#*=}"

    [[ "$tag_key" == "$tag_value" ]] && tag_value=true
    tag_value="${tag_value// /}"

    output+=("$tag_key=$tag_value")
  done

  printf "%s" "${output[*]}"
}

_kcs_clean_hooks() {
  unset _KCS_HOOK_VAR_PREFIX \
    _KCS_HOOK_DISABLE_VAR_PREFIX \
    _KCS_HOOK_DISABLE_ALL_VAR_PREFIX \
    _KCS_HOOK_NAMES

  unset KCS_HOOK_TAG_OPTIONAL \
    KCS_HOOK_TAG_SILENT \
    KCS_HOOK_TAG_CALLBACK \
    KCS_HOOK_TAG_RAW \
    KCS_HOOK_TAG_ARGS \
    _KCS_HOOK_TAGS
}
