#!/usr/bin/env bash

## Hook manager:
##   a collection of hook functions and constants

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

_KCS_HOOK_VARIABLE_PREFIX="__kcs_hooks"
_KCS_HOOK_DISABLE_VARIABLE_PREFIX="__kcs_hooks_disabled"

_KCS_HOOK_NAMES=(
  pre_init init post_init
  pre_check check post_check
  pre_main main post_main
  pre_clean clean post_clean
)

export KCS_HOOK_TAG_OPTIONAL="@optional"
export KCS_HOOK_TAG_RAW="@raw"
export KCS_HOOK_TAG_CALLBACK="@cb"

_KCS_HOOK_TAGS=(
  "$KCS_HOOK_TAG_CALLBACK"
  "$KCS_HOOK_TAG_OPTIONAL"
  "$KCS_HOOK_TAG_RAW"
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
    for raw_tag in $(__kcs_parse_tags "${raw#*:}"); do
      tag_key="${raw_tag%%=*}"

      test -n "$tags" && tags="$tags,"
      tags="$tags$tag_key"
    done

    local tag_msg=""
    test -n "$tags" && tag_msg="with '$tags' "

    kcs_debug "$ns" "adding '%s' %sto hook name '%s'" \
      "$command" "$tag_msg" "$name"

    eval "${_KCS_HOOK_VARIABLE_PREFIX}_${name}+=(\"$raw\")"
  else
    kcs_warn "$ns" "adding invalid hook name '%s'" \
      "$name"
  fi
}

kcs_disable_hook() {
  local ns="hook-remover"
  local raw="$1" name cb
  name="${raw%%:*}"
  cb="__kcs_${raw#*:}"

  if [[ "${_KCS_HOOK_NAMES[*]}" =~ $name ]]; then
    kcs_debug "$ns" "disabling '%s' to hook name '%s'" \
      "$cb" "$name"

    eval "${_KCS_HOOK_DISABLE_VARIABLE_PREFIX}_${name}+=(\"$cb\")"
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
  eval "commands=(\"\${${_KCS_HOOK_VARIABLE_PREFIX}_${name}[@]}\")"
  eval "disables=(\"\${${_KCS_HOOK_DISABLE_VARIABLE_PREFIX}_${name}[@]}\")"

  kcs_debug "$ns" "running %d %11s hook (disabled=%d)" \
    "${#commands[@]}" \
    "$name" \
    "${#disables[@]}"

  export KCS_HOOK_NAME="$name"
  disabled="${disables[*]}"

  for raw in "${commands[@]}"; do
    local args=()
    local command="${raw%%:*}"
    if [[ "$disabled" =~ $command ]]; then
      kcs_debug "$ns" "disabled command '%s' on %s hook" \
        "$command" "$name"
      continue
    fi

    local callback="kcs_must_exec"
    for raw_tag in $(__kcs_parse_tags "${raw#*:}"); do
      tag_key="${raw_tag%%=*}"
      tag_value="${raw_tag#*=}"

      case "$tag_key" in
      "$KCS_HOOK_TAG_CALLBACK")
        args+=("$tag_value")
        ;;
      "$KCS_HOOK_TAG_OPTIONAL")
        callback="kcs_ignore_exec"
        ;;
      "$KCS_HOOK_TAG_RAW")
        args+=("${raw_args[@]}")
        ;;
      esac
    done

    "$callback" "$command" "${args[@]}"
  done

  unset KCS_HOOK_NAME
}

_kcs_run_hooks() {
  local args=("$@")

  for name in "${_KCS_HOOK_NAMES[@]}"; do
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
  unset _KCS_HOOK_VARIABLE_PREFIX \
    _KCS_HOOK_DISABLE_VARIABLE_PREFIX \
    _KCS_HOOK_NAMES

  unset KCS_HOOK_TAG_OPTIONAL \
    KCS_HOOK_TAG_CALLBACK \
    KCS_HOOK_TAG_RAW \
    _KCS_HOOK_TAGS
}
