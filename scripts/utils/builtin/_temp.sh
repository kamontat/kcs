#!/usr/bin/env bash
##utils-example:v1.0.0-beta.1

## builtin/temp:
##   manage temp directory
## Hook: <any>
## Public functions:
##   `kcs_conf_temp_auto_clean` - auto clean temp file or directory
##   `kcs_conf_temp_auto_clean_all` - auto clean all temp directory
##   `kcs_conf_temp_no_clean` - never clean temp file or directory
##   `kcs_temp_create_dir [n]` - create new temp directory by name
##   `kcs_temp_create_file [n]` - create new temp file by name
##   `kcs_temp_clean <n>` - clean <n> temp directory
##   `kcs_temp_clean_all` - clean temp directory to initiate state

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

kcs_utils_register "builtin/temp"

__KCS_TEMP_AUTO_CLEANUP=true
__KCS_EXEC_TEMP_CLEANUP=".temp.ekcs"

## cleanup all files/folders created by
## kcs_temp_create_* function when on clean hook
kcs_conf_temp_auto_clean() {
  local ns="config temp"
  __KCS_TEMP_AUTO_CLEANUP=true
  kcs_debug "$ns" \
    "enabled auto cleanup"
}

## cleanup all files/folders created by
## kcs_temp_create_* function when on clean hook
kcs_conf_temp_auto_clean_all() {
  local ns="config temp"
  __KCS_TEMP_AUTO_CLEANUP=all
  kcs_debug "$ns" \
    "enabled auto cleanup all"
}

## not cleanup any file/folder created by
## kcs_temp_create_* function
kcs_conf_temp_no_clean() {
  local ns="config temp"
  unset __KCS_TEMP_AUTO_CLEANUP
  kcs_debug "$ns" \
    "disabled auto cleanup"
}

## create temp directory and return fullpath
## The directory created by this function
## @param $1 - [optional] name (default=random)
## @return   - single line fullpath string
kcs_temp_create_dir() {
  ## name cannot have space
  local name="${1// /-}"
  test -z "$name" && name=".d$RANDOM"

  local fullpath="$_KCS_DIR_TEMP/$name"
  echo "$fullpath" \
    >>"$_KCS_DIR_TEMP/$__KCS_EXEC_TEMP_CLEANUP"

  ## create temporary directory
  mkdir -p "$fullpath"
  printf "%s" "$fullpath"
}

## create temp file and return fullpath
## @param $1 - [optional] name (default=random)
## @return   - single line fullpath string
kcs_temp_create_file() {
  ## name cannot have space
  local name="${1// /-}"
  test -z "$name" && name=".f$RANDOM.temp"

  local fullpath="$_KCS_DIR_TEMP/$name"
  echo "$fullpath" \
    >>"$_KCS_DIR_TEMP/$__KCS_EXEC_TEMP_CLEANUP"

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
  __kcs_temp_clean
__kcs_temp_clean() {
  local fpath
  local exec_tfile="$_KCS_DIR_TEMP/$__KCS_EXEC_TEMP_CLEANUP"
  if test -f "$exec_tfile"; then
    if test -n "$__KCS_TEMP_AUTO_CLEANUP"; then
      if [[ "$__KCS_TEMP_AUTO_CLEANUP" == "all" ]]; then
        kcs_temp_clean_all
      else
        while IFS= read -r fpath; do
          test -f "$fpath" &&
            kcs_exec rm "$fpath"
          test -d "$fpath" &&
            kcs_exec rm -r "$fpath"
        done <"$exec_tfile"
      fi
    fi

    rm "$exec_tfile"
  fi

  unset __KCS_EXEC_TEMP_CLEANUP \
    __KCS_TEMP_AUTO_CLEANUP
}
