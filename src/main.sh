#!/usr/bin/env bash

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

export _KCS_PATH_ORIG="$PWD"
cd "$(dirname "$0")" || exit 1
export _KCS_PATH_SRC="$PWD"
cd ".." || exit 1
export _KCS_PATH_ROOT="$PWD"

# shellcheck source=/dev/null
source "$_KCS_PATH_SRC/libs/base.sh" || exit 1
# shellcheck source=/dev/null
source "$_KCS_PATH_SRC/libs/main.sh" || exit 1

kcs_main_start "$@"
