#!/usr/bin/env bash
##template:v1.0.0-beta.1
## Main.sh is a entry file for all cmd in /commands

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

## Possible values: cwd, or <number>
## cwd      : Current directory is a root directory (default)
## <number> : Go up <number> times
export KCS_ROOT="1"

## Possible values: command or library
## command: Scripts will create all functions and run (default)
## library: Scripts will create all functions, but not execute them
export KCS_MODE="command"

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
