#!/usr/bin/env bash

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

## Show --version
kcs_info_version() {
  if test -n "$KCS_CMD_VERSION"; then
    printf '%s\n' "$KCS_CMD_VERSION"
    return 0
  fi

  kcs_log_debug "$ns" \
    "missing version, create '%s' file with '%s'" \
    "configs/.env" \
    "KCS_CMD_VERSION=0.0.0"
  return 1
}

kcs_info_full_version() {
  if test -n "$_KCS_CMD_NAME" && test -n "$KCS_CMD_VERSION"; then
    printf '%s: %s\n' "$_KCS_CMD_NAME" "$KCS_CMD_VERSION"
    return 0
  fi

  kcs_log_debug "$ns" \
    "information is missing either '%s' or '%s'" \
    "KCS_CMD_NAME $_KCS_CMD_NAME" \
    "KCS_CMD_VERSION $KCS_CMD_VERSION"
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
}
