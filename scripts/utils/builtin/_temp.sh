#!/usr/bin/env bash
##utils-example:v1.0.0-beta.1

## builtin/temp:
##   manage temp directory
## Requirement:
##   <none>
## Public functions:
##   `kcs_temp_create_dir [n]` - create new temp directory by name
##   `kcs_temp_create_file [n]` - create new temp file by name
##   `kcs_temp_clean <n>` - clean <n> temp directory
##   `kcs_temp_clean_all` - clean temp directory to initiate state

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

__KCS_TEMP_CREATED_DIR=()
__KCS_TEMP_CREATED_FILE=()

## create temp directory and return fullpath
## The directory created by this function
## @param $1 - [optional] name (default=random)
## @return   - single line fullpath string
kcs_temp_create_dir() {
  local name="$1"
  test -z "$name" && name=".d$RANDOM"

  local fullpath="$_KCS_DIR_TEMP/$name"
  __KCS_TEMP_CREATED_DIR+=("$fullpath")

  ## create temporary directory
  mkdir -p "$fullpath"
  printf "%s" "$fullpath"
}

## create temp file and return fullpath
## @param $1 - [optional] name (default=random)
## @return   - single line fullpath string
kcs_temp_create_file() {
  local name="$1"
  test -z "$name" && name=".f$RANDOM.temp"

  local fullpath="$_KCS_DIR_TEMP/$name"
  __KCS_TEMP_CREATED_FILE+=("$fullpath")

  ## create temporary directory
  touch "$fullpath"
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

## All directory and file created by
## kcs_temp_create_* function. It will be cleanup automatically
kcs_add_hook clean \
  "__kcs_temp_clean"
__kcs_temp_clean() {
  local ns="clean temp"
  for temp in "${__KCS_TEMP_CREATED_DIR[@]}"; do
    kcs_debug "$ns" \
      "removing '%s' temp directory"
    rm -r "$temp"
  done

  for temp in "${__KCS_TEMP_CREATED_FILE[@]}"; do
    kcs_debug "$ns" \
      "removing '%s' temp file"
    rm "$temp"
  done

  unset __KCS_TEMP_CREATED_DIR \
    __KCS_TEMP_CREATED_FILE
}
