#!/usr/bin/env bash

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

## Show --version
kcs_info_version() {
  return 0
}

__kcs_information_lc_init() {
  local ns="init.information"

  if test -z "$_KCS_CMD_NAME"; then
    # shellcheck disable=SC2016
    kcs_log_warn "$ns" "missing %s variable, information might not completed" \
      '$_KCS_CMD_NAME'
  fi

  echo "$KCS_CMD_VERSION"
}
