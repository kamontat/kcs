#!/usr/bin/env bash
##command-example:v1.0.0-beta.2
## > learn more at README.md

## Special command run if finder cannot map input arguments with any commands

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

####################################################
## User defined function
####################################################

export KCS_NAME="default"
export KCS_VERSION="v0.1.1"
export KCS_HELP="
Commands:
  [release|r] <opts...>
    - release new kcs variable
  [upgrade] <opts...> <args>
    - upgrade kcs version on target directory
  [test] <opts...>
    - test command
"

__kcs_main() {
  local ns="default"
  kcs_warn "$ns" \
    "invalid commands: %s" \
    "$*"
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
