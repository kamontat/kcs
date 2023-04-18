#!/usr/bin/env bash

## Base functions:
##   base required commands for all entry

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

# shellcheck disable=SC1091
source "$_KCS_DIR_SCRIPT/internal/_location.sh" || return $?
# shellcheck disable=SC1091
source "$_KCS_DIR_INTERNAL/_core.sh" || return $?

## Load global internal and utilities
kcs_load_internal "_utils.sh"
kcs_load_internal "_error.sh"
kcs_load_internal "_logger.sh"
kcs_load_internal "_mode.sh"
kcs_load_internal "_commands.sh"

## shared namespace with load_internal
kcs_ignore_exec kcs_debug "file-loader" \
  "loaded _base.sh in internal file"
