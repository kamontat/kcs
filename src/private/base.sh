#!/usr/bin/env bash

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

_KCS_PATH_DIR_PRIV="${_KCS_PATH_SRC:?}/private"
export _KCS_PATH_DIR_PRIV
_KCS_PATH_DIR_LIB="${_KCS_PATH_SRC:?}/libs"
export _KCS_PATH_DIR_LIB

# shellcheck source=/dev/null
source "$_KCS_PATH_DIR_PRIV/_base.sh" || exit 1
# shellcheck source=/dev/null
source "$_KCS_PATH_DIR_PRIV/_loader.sh" || exit 1
# shellcheck source=/dev/null
source "$_KCS_PATH_DIR_PRIV/_logger.sh" || exit 1

_kcs_log_init
