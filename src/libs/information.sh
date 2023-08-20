#!/usr/bin/env bash

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

## Show --version
kcs_info_version() {
  if test -n "$_KCS_CMD_VERSION"; then
    printf '%s\n' "$_KCS_CMD_VERSION"
    return 0
  fi

  kcs_log_debug "$ns" \
    "missing version, create '%s' file with '%s'" \
    "configs/.env" \
    "KCS_CMD_VERSION=0.0.0"
  return 1
}

kcs_info_full_version() {
  local kcs_version=dev

  if test -n "$_KCS_PATH_SRC" && test -f "$_KCS_PATH_SRC/version.txt"; then
    kcs_log_debug "$ns" "found kcs version from '%s'" "\$_KCS_PATH_SRC"
    kcs_version="$(cat "$_KCS_PATH_SRC/version.txt")"
  elif test -n "$_KCS_PATH_ROOT" && test -f "$_KCS_PATH_ROOT/version.txt"; then
    kcs_log_debug "$ns" "found kcs version from '%s'" "\$_KCS_PATH_ROOT"
    kcs_version="$(cat "$_KCS_PATH_ROOT/version.txt")"
  fi

  if test -n "$_KCS_CMD_NAME" && test -n "$_KCS_CMD_VERSION"; then
    printf '%s: %s\n' "$_KCS_CMD_NAME" "$_KCS_CMD_VERSION"
    printf '%s: %s\n' "kcs" "$kcs_version"
    return 0
  fi

  kcs_log_debug "$ns" \
    "information is missing either '%s' or '%s'" \
    "KCS_CMD_NAME $_KCS_CMD_NAME" \
    "KCS_CMD_VERSION $_KCS_CMD_VERSION"
  return 1
}

# TODO: Add help command

__kcs_information_lc_init() {
  local ns="init.information"

  if test -z "$_KCS_CMD_NAME"; then
    # shellcheck disable=SC2016
    kcs_log_warn "$ns" "missing %s variable, information might not completed" \
      '$_KCS_CMD_NAME'
  fi

  export _KCS_CMD_VERSION="${KCS_CMD_VERSION:-dev}"
}

__kcs_information_lc_start() {
  kcs_hooks_add pre_clean information
}

__kcs_information_hook_clean() {
  unset _KCS_CMD_VERSION
}
