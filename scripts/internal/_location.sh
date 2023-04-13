#!/usr/bin/env bash
## Hooks

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

## original current directory
## usually, created from execute files
export _KCS_DIR_ORIG="${_KCS_DIR_ORIG:-$PWD}"

## script directory
## usually, created from execute files
export _KCS_DIR_SCRIPT="${_KCS_DIR_SCRIPT:-$PWD}"

## root directory
## if KCS_MODE=internal, move root up 1 level
export _KCS_DIR_ROOT="${_KCS_DIR_SCRIPT:-$PWD}"
if [[ $KCS_MODE == "internal" ]]; then
  _KCS_DIR_ROOT="$(cd "$_KCS_DIR_ROOT/.." && pwd)"
fi

## script internal utilities
export _KCS_DIR_INTERNAL="$_KCS_DIR_SCRIPT/internal"

## script custom utilities
export _KCS_DIR_UTILS="$_KCS_DIR_SCRIPT/utils"

## script commands
export _KCS_DIR_COMMANDS="$_KCS_DIR_SCRIPT/commands"

## temporary directory
export _KCS_DIR_TEMP="$_KCS_DIR_SCRIPT/.tmp"

## log directory
export _KCS_DIR_LOG="$_KCS_DIR_TEMP/logs"

## Scripts should always resolve relative path from root directory
cd "$_KCS_DIR_ROOT" || exit 1
