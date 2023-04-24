#!/usr/bin/env bash

## Location constants:
##   export location constants used for most of internal utilities

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

## current working directory for $KCS_ROOT variable
export _KCS_ROOT_CWD="cwd"

## original current directory
## usually, created from execute files
export _KCS_DIR_ORIG="${_KCS_DIR_ORIG:-$PWD}"

## script directory
## usually, created from execute files
export _KCS_DIR_SCRIPT="${_KCS_DIR_SCRIPT:-$PWD}"

## root directory
## if KCS_MODE=internal, move root up <n> level
export _KCS_DIR_ROOT="${_KCS_DIR_SCRIPT:-$PWD}"
if [[ $KCS_ROOT != "$_KCS_ROOT_CWD" ]]; then
  ## move to script directory
  cd "$_KCS_DIR_SCRIPT" || exit 1

  ## Go up <n> times
  for ((i = 0; i < KCS_ROOT; i++)); do
    cd ".."
  done

  ## Change root to directory up <n> times
  _KCS_DIR_ROOT="$PWD"
fi

## script internal utilities
export _KCS_DIR_INTERNAL="$_KCS_DIR_SCRIPT/internal"

## script custom utilities; override by $KCS_DIR_UTILS
export _KCS_DIR_UTILS="${KCS_DIR_UTILS:-$_KCS_DIR_SCRIPT/utils}"

## script commands; override by $KCS_DIR_COMMANDS
export _KCS_DIR_COMMANDS="${KCS_DIR_COMMANDS:-$_KCS_DIR_SCRIPT/commands}"

## temporary directory; override by $KCS_DIR_TEMP
export _KCS_DIR_TEMP="${KCS_DIR_TEMP:-$_KCS_DIR_SCRIPT/.tmp}"

## log directory; override by $KCS_DIR_LOG
export _KCS_DIR_LOG="${KCS_DIR_LOG:-$_KCS_DIR_TEMP/logs}"

## Scripts should always resolve relative path from root directory
cd "$_KCS_DIR_ROOT" || exit 1

__kcs_location_post_clean() {
  cd "$_KCS_DIR_ORIG" || exit 1

  unset _KCS_ROOT_CWD

  unset _KCS_DIR_ORIG \
    _KCS_DIR_INTERNAL \
    _KCS_DIR_UTILS \
    _KCS_DIR_COMMANDS \
    _KCS_DIR_TEMP \
    _KCS_DIR_LOG \
    _KCS_DIR_ROOT \
    _KCS_DIR_SCRIPT
}
