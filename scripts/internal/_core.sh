#!/usr/bin/env bash

## Core functions:
##   a set of functions required to run most utilities and internal

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

## execute input command with ignore if not exist
## and warning if command failed
kcs_ignore_exec() {
  __kcs_exec_cmd \
    "__kcs_ignore_cmd" "__kcs_warn_cmd" \
    "$@"
}

## execute input command with ignore if not exist
## or throw error if command failed
kcs_optional_exec() {
  __kcs_exec_cmd \
    "__kcs_ignore_cmd" "kcs_throw" \
    "$@"
}

## execute input command;
## if command not found, warn and return success
kcs_should_exec() {
  __kcs_exec_cmd \
    "__kcs_warn_cmd" "__kcs_error_cmd" \
    "$@"
}

## execute input command;
## if something went wrong, throw error and exit
kcs_must_exec() {
  __kcs_exec_cmd "kcs_throw" "kcs_throw" "$@"
}

## execute input command;
## This is only *_exec function that respect DRY_RUN mode.
kcs_exec() {
  local cmd="$1" args
  shift
  args=("$@")

  ## If on dry run mode
  if test -n "$DRY_RUN"; then
    kcs_logf "dry-exec" "%s '%s'" \
      "$cmd" "${args[*]}"
    return 0
  fi

  __kcs_exec_cmd \
    "__kcs_error_cmd" \
    "__kcs_error_cmd" \
    "$cmd" "${args[@]}"
}

## execute command with error handler
## @param $1 - callback if command not found
##        $2 - callback if command failed
##        $3 - command name
##        $@ - command arguments
__kcs_exec_cmd() {
  local ns="executor"

  local not_found_cmd="$1"
  local error_cmd="$2"
  local cmd="$3" args=()
  shift 3
  args=("$@")

  local arg_msg="without argument"
  if [ "${#args[@]}" -gt 0 ]; then
    arg_msg="with ${#args[@]} argument (${args[*]})"
  fi
  __kcs_print_debug "$cmd" \
    "starting '%s' %s" "$cmd" "$arg_msg"

  ## If command not found
  if ! command -v "$cmd" >/dev/null &&
    [[ "$not_found_cmd" != "" ]]; then
    local resp=("command '%s' not found" "$cmd")
    __kcs_print_debug "$cmd" "${resp[@]}"
    ## Same syntax as kcs_throw
    "$not_found_cmd" "$KCS_EC_CMD_NOT_FOUND" "$ns" \
      "${resp[@]}"
    return $?
  fi

  "$cmd" "${args[@]}"

  ## If command failed
  local exit_code=$?
  if [ $exit_code -gt 0 ] && [[ "$error_cmd" != "" ]]; then
    local resp=("command '%s' return %d exit code" "$cmd" "$exit_code")
    __kcs_print_debug "$cmd" "${resp[@]}"
    ## Same syntax as kcs_throw
    "$error_cmd" "$exit_code" "$ns" \
      "${resp[@]}"
    return $?
  fi

  return $exit_code
}

## Load internal file
kcs_load_internal() {
  __kcs_load_file \
    "kcs_throw" "kcs_throw" \
    "$_KCS_DIR_INTERNAL" "$@"
}

## load input file with throw if something wrong
kcs_must_load() {
  __kcs_load_file \
    "kcs_throw" "kcs_throw" \
    "$@"
}

## load file using source with error handler
## @param $1 - callback if command not found
##        $2 - callback if command failed
##        $3 - execute base directory
##        $4 - execute file name
##        $@ - command arguments
__kcs_load_file() {
  local ns="file-loader"
  local not_found_cmd="$1"
  local error_cmd="$2"
  local base_path="$3" file_name="$4"
  shift 4
  local file_path="$base_path/$file_name" args=("$@")

  kcs_ignore_exec kcs_debug \
    "$ns" "loading '%s'" "$file_path"

  ## If file not found
  if ! test -f "$file_path" &&
    [[ "$not_found_cmd" != "" ]]; then
    ## Same syntax as kcs_throw
    "$not_found_cmd" "$KCS_EC_FILE_NOT_FOUND" \
      "$ns" "file '%s' is missing from '%s'" \
      "$file_name" "$base_path"
    return $?
  fi

  ## If sourcing failed
  # shellcheck disable=SC1090
  source "$file_path"
  local exit_code=$?
  if [ $exit_code -gt 0 ] && [[ "$error_cmd" != "" ]]; then
    ## Same syntax as kcs_throw
    "$error_cmd" $exit_code "$ns" \
      "sourced file '%s' return %d exit code" "$cmd" "$exit_code"
    return $?
  fi

  return $exit_code
}

## This are use for not_found_cmd or error_cmd
## as a ignore handler without do anything and return success
__kcs_ignore_cmd() {
  return 0
}

## This are use for not_found_cmd or error_cmd
## as a loose handle with only print warning message
__kcs_warn_cmd() {
  shift 1
  kcs_warn "$@"
}

## This are use for not_found_cmd or error_cmd
## as a loose handle with only print error message
## and return same non-zero exit code to caller
__kcs_error_cmd() {
  local code="$1"
  shift 1
  kcs_error "$@"
  return "$code"
}

## kcs_debug wrapper for core function
__kcs_print_debug() {
  local ns="core-wrapper"
  local whitelist=(
    "kcs_debug" "kcs_info"
    "kcs_warn" "kcs_error"
    "kcs_logf" "kcs_printf"
  )

  local cmd="$1" args=()
  shift 1
  args=("$@")

  ## Needs manual check command because it function
  ## are defined on very beginning
  ## And do not print debug for logging command
  if command -v kcs_debug >/dev/null; then
    if ! [[ "${whitelist[*]}" =~ $cmd ]]; then
      kcs_debug "$ns" "${args[@]}"
    fi
  fi
}
