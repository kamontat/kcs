#!/usr/bin/env bash

## Information helper:
##   getter and setter script information

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

__kcs_set_name() {
  local cb="$1" raw
  raw="$(kcs_ignore_exec "$cb")"
  test -n "$raw" &&
    KCS_NAME="$raw"
  export KCS_NAME
}

__kcs_set_version() {
  local cb="$1" raw
  raw="$(kcs_ignore_exec "$cb")"
  test -n "$raw" &&
    KCS_VERSION="$raw"
  export KCS_VERSION
}

__kcs_set_options() {
  local cb="$1" raw
  raw="$(kcs_ignore_exec "$cb")"
  test -n "$raw" &&
    KCS_OPTIONS="$KCS_OPTIONS$raw"
  export KCS_OPTIONS
}

kcs_get_info() {
  local name="${KCS_NAME:-unknown}"
  local version="${KCS_VERSION:-dev}"
  printf '%s: %s\n' "$name" "$version"
  exit 0
}

__kcs_set_description() {
  local cb="$1" raw
  raw="$(kcs_ignore_exec "$cb")"
  test -n "$raw" &&
    KCS_DESCRIPTION="$raw"
  export KCS_DESCRIPTION
}

__kcs_set_help() {
  local cb="$1" raw
  raw="$(kcs_ignore_exec "$cb")"
  test -n "$raw" &&
    KCS_HELP="$raw"
  export KCS_HELP
}

## get only command help message
kcs_get_help() {
  local name="${KCS_NAME:-unknown}"
  local version="${KCS_VERSION:-dev}"
  local desc="$KCS_DESCRIPTION"
  local help="$KCS_HELP"

  test -n "$desc" && desc="$desc"$'\n'

  printf "# %s (%s)
%s%s%s" "$name" "$version" "$desc" \
    "$help" "$__KCS_GLOBAL_HELP_SHORT"
  exit 0
}

## get fully help message
kcs_get_help_all() {
  local name="${KCS_NAME:-unknown}"
  local version="${KCS_VERSION:-dev}"
  local desc="$KCS_DESCRIPTION"
  local help="$KCS_HELP"

  test -n "$desc" && desc="$desc"$'\n'

  printf "# %s (%s)
%s%s%s%s" "$name" "$version" "$desc" \
    "$help" "$__KCS_GLOBAL_HELP" \
    "$__KCS_GLOBAL_HELP_ENV"
  exit 0
}

__kcs_set_alias() {
  local ns="alias-setter"
  local cb="$1" args=() cmd
  shift
  args=("$@")

  # shellcheck disable=SC2207
  if command -v "$cb" >/dev/null; then
    kcs_debug "$ns" \
      "set alias command from function"
    cmd=($(kcs_ignore_exec "$cb"))
  else
    kcs_debug "$ns" \
      "set alias command from variable"
    cmd=("${KCS_ALIAS_COMMAND[@]}")
  fi

  [ "${#cmd[@]}" -le 0 ] &&
    return 0

  ## Because we call command on current shell
  ## we have to cleanup current command before
  ## call alias command
  unset __kcs_main_alias
  unset KCS_ALIAS_COMMAND

  kcs_call_command "${cmd[@]}" "${args[@]}"
  exit $?
}

__kcs_set_dry_run() {
  test -z "$DRY_RUN" && DRY_RUN=true
}
