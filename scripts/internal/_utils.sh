#!/usr/bin/env bash

## Utils functions:
##   a helper for manage external utils function

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

export __KCS_LOADED_UTILS=""

## Load utils file
## @param $1 - utils name
##        $2 - utils path
kcs_load_utils() {
  local ns="utils-loader"
  local name="$1" path="$2"
  if ! kcs_utils_is_load "$name"; then
    __kcs_load_file \
      "__kcs_warn_cmd" "__kcs_error_cmd" \
      "$_KCS_DIR_UTILS" "$path"
  else
    kcs_debug "$ns" "utils name '%s' has been loaded, skipped" \
      "$name"
  fi
}

## kcs_utils_required <name> <requires>
## <name> util required <requires> utils
kcs_utils_required() {
  local ns="utils-validator"
  local name="$1"
  shift

  for module in "$@"; do
    if ! kcs_utils_is_load "$module"; then
      kcs_throw "$KCS_EC_UTIL_NOT_FOUND" \
        "$ns" "'%s' utility requires '%s' to work correctly" \
        "$name" "$module"
    fi
  done
}

## check is input utils loaded?
kcs_utils_is_load() {
  local module="$1"
  [[ "$__KCS_LOADED_UTILS" =~ $module ]]
}

## get utils value to resolve filepath
kcs_utils_get_value() {
  local raw="$1" scope file
  scope="$(kcs_utils_get_scope "$raw")"
  file="$(kcs_utils_get_file "$raw")"

  local out
  test -n "$scope" && out="$scope/"
  out="$out$file"

  printf "%s" "$out"
}

## get utils scope
kcs_utils_get_scope() {
  local raw="$1" key
  key="${raw%/*}"
  if [[ "$key" != "$raw" ]]; then
    printf "%s" "$key"
  fi
}

kcs_utils_get_file() {
  local raw="$1" value
  value="${raw##*/}"
  printf "%s" "_$value.sh"
}

__kcs_utils_init() {
  local cb="$1"
  local raw key value
  for raw in $(kcs_ignore_exec "$cb"); do
    kcs_load_utils "$raw" "$(kcs_utils_get_value "$raw")"
    __KCS_LOADED_UTILS="$__KCS_LOADED_UTILS $raw"
  done
}

__kcs_utils_clean() {
  unset __KCS_LOADED_UTILS
}
