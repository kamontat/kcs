#!/usr/bin/env bash

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

_KCS_PATH_PRIV="${_KCS_PATH_SRC:?}/private"
export _KCS_PATH_PRIV
_KCS_PATH_LIB="${_KCS_PATH_SRC:?}/libs"
export _KCS_PATH_LIB

# shellcheck source=/dev/null
source "$_KCS_PATH_PRIV/_base.sh" || exit 1
# shellcheck source=/dev/null
source "$_KCS_PATH_PRIV/_loader.sh" || exit 1
# shellcheck source=/dev/null
source "$_KCS_PATH_PRIV/_color.sh" || exit 1
# shellcheck source=/dev/null
source "$_KCS_PATH_PRIV/_logger.sh" || exit 1
# shellcheck source=/dev/null
source "$_KCS_PATH_PRIV/_tmp.sh" || exit 1

_kcs_color_init
_kcs_log_init

if test -n "$KCS_DEV" && test -z "$__KCS_DEV_INIT"; then
  kcs_log_info "private.base.settings" "development mode has been enabled"
  export __KCS_DEV_INIT=true
fi

if test -n "$KCS_TEST" && test -z "$__KCS_TEST_INIT"; then
  kcs_log_info "private.base.settings" "testing mode has been enabled"
  export __KCS_TEST_INIT=true
fi
