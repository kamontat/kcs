#!/usr/bin/env bash
##utils-example:v1.0.0-beta.1

## builtin/temp:
##   manage temp directory
## Requirement:
##   <none>
## Public functions:
##   `kcs_temp_create [n]` - create new temp directory by name
##   `kcs_temp_clean <n>` - clean <n> temp directory
##   `kcs_temp_clean_all` - clean temp directory to initiate state

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

## create temp directory and return fullpath
## @param $1 - [optional] name (default=random)
## @return   - single line fullpath string
kcs_temp_create() {
  local name="$1"
  test -z "$name" && name=".t$RANDOM"

  local fullpath="$_KCS_DIR_TEMP/$name"
  ## create temporary directory
  mkdir -p "$fullpath"
  printf "%s" "$fullpath"
}

## clean input temp directory name
## @param $1 - [required] directory name (default=random)
## @return   - zero code if cleanup completed
kcs_temp_clean() {
  local ns="temp-cleaner"
  local name="$1"
  local fullpath="$_KCS_DIR_TEMP/$name"

  if test -d "$fullpath" ||
    test -f "$fullpath"; then
    kcs_debug "$ns" "%s now cleaned" \
      "$fullpath"

    rm -r "$fullpath"
  fi
  return 1
}

## cleanup whole temp directory
kcs_temp_clean_all() {
  local ns="temp-cleaner"

  if test -d "$_KCS_DIR_TEMP"; then
    rm -r "$_KCS_DIR_TEMP"
  fi

  mkdir -p "$_KCS_DIR_TEMP"
  touch "$_KCS_DIR_TEMP/.gitkeep"

  kcs_debug "$ns" "%s (temp dir) now cleaned" \
    "$_KCS_DIR_TEMP"
}
