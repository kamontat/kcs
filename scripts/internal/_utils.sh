#!/usr/bin/env bash

## Utils functions:
##   a helper for manage external utils function

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

export __KCS_LOADED_UTILS=""

## Load utils file
kcs_load_utils() {
  __kcs_load_file \
    "__kcs_warn_cmd" "__kcs_error_cmd" \
    "$_KCS_DIR_UTILS" "$@"
}

## kcs_utils_required <name> <requires>
## <name> util required <requires> utils
kcs_utils_required() {
  local ns="required utils"
  local name="$1"
  shift

  for module in "$@"; do
    if ! kcs_utils_is_load "$module"; then
      kcs_throw "$KCS_ERRCODE_MISSING_REQUIRED_UTILS" \
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

__kcs_utils_init() {
  local cb="$1"

  local raw key value
  for raw in $(kcs_ignore_exec "$cb"); do
    __KCS_LOADED_UTILS="$__KCS_LOADED_UTILS $raw"

    key="${raw%%/*}"

    value="${raw#*/}"
    kcs_load_utils "$key/_$value.sh"
  done
}

__kcs_utils_clean() {
  unset __KCS_LOADED_UTILS
}
