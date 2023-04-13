#!/usr/bin/env bash
## Example: v0.1.0
## Example file for create new command

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

## Script name: This will show in help command or in debug mode
## This purely for information.
export KCS_NAME="example"

## Script version: This will show in help and version command
## This purely for information.
export KCS_VERSION="v0.1.0"

####################################################
## User defined function
####################################################

## Main entry of command
## visit README.md for more information
__kcs_main() {
  return 0
}

####################################################
## Internal function calls
####################################################

## original current directory
export _KCS_DIR_ORIG="$PWD"

## move to script directory
## later, it will moved to root directory instead
cd "$(dirname "$0")/.." || exit 1
export _KCS_DIR_SCRIPT="$PWD"

# shellcheck disable=SC1091
source "$_KCS_DIR_SCRIPT/internal/command.sh" || exit 1

kcs_prepare
kcs_start "$@"
