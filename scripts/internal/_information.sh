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
    KCS_OPTIONS="$raw"
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

kcs_get_help() {
  local name="${KCS_NAME:-unknown}"
  local version="${KCS_VERSION:-dev}"
  local desc="$KCS_DESCRIPTION"
  local help="$KCS_HELP"

  test -n "$desc" && desc="$desc"$'\n'
  test -n "$help" && help=$'\n'"$help"

  printf "# %s (%s)
%s%s%s" "$name" "$version" "$desc" \
    "$__KCS_GLOBAL_HELP" \
    "$help"
  exit 0
}

__kcs_set_dry_run() {
  test -z "$DRY_RUN" && DRY_RUN=true
}
