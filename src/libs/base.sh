#!/usr/bin/env bash

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

KCS_PATH_DIR_LIB="${KCS_PATH_DIR_SRC:?}/libs"
export KCS_PATH_DIR_LIB

# shellcheck source=/dev/null
source "$KCS_PATH_DIR_LIB/__base.sh" || exit 1
# shellcheck source=/dev/null
source "$KCS_PATH_DIR_LIB/__loader.sh" || exit 1
# shellcheck source=/dev/null
source "$KCS_PATH_DIR_LIB/__logger.sh" || exit 1

_kcs_log_init
