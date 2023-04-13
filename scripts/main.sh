#!/usr/bin/env bash
## SHellTemplate: v0.1.0
## Main.sh is a entry file for all cmd in /commands

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

## Possible values: internal, external
## Internal: Scripts should have theirs directory inside root project
## External: Scripts should mixed with other code language
export KCS_MODE="internal"

####################################################
## Internal function calls
####################################################

## mark we running from main entry
export _KCS_ENTRY="main"

## original current directory
export _KCS_DIR_ORIG="$PWD"

## move to script directory
## later, it will moved to root directory instead
cd "$(dirname "$0")" || exit 1
export _KCS_DIR_SCRIPT="$PWD"

# shellcheck disable=SC1091
source "$_KCS_DIR_SCRIPT/internal/main.sh" || exit 1

kcs_prepare
kcs_start "$@"
