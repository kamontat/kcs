#!/usr/bin/env bash
##example-command:v1
## > learn more at README.md

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

####################################################
## User defined function
####################################################

export KCS_NAME="test"
export KCS_VERSION="v0.0.0"

export KCS_INIT_UTILS=(
  builtin/test
)

export KCS_UTILS=(
  builtin/test
)

__kcs_main() {
  return 0
}

####################################################
## Internal function calls
####################################################

## original current directory
export _KCS_DIR_ORIG="${_KCS_DIR_ORIG:-$PWD}"

## move to script directory
## later, it will moved to root directory instead
if test -z "$_KCS_DIR_SCRIPT"; then
  cd "$(dirname "$0")/.." || exit 1
  export _KCS_DIR_SCRIPT="$PWD"
fi

# shellcheck disable=SC1091
source "$_KCS_DIR_SCRIPT/internal/command.sh" || exit 1

kcs_prepare
kcs_start "$@"
