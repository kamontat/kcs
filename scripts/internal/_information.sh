#!/usr/bin/env bash
## Load information from function

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

export __KCS_GLOBAL_HELP="
"

__kcs_set_name() {
  local cb="$1"
  export KCS_NAME
  KCS_NAME="$($cb)"
}

__kcs_set_version() {
  local cb="$1"
  export KCS_VERSION
  KCS_VERSION="$($cb)"
}

__kcs_set_options() {
  local cb="$1"
  export KCS_OPTIONS
  KCS_OPTIONS="$($cb)"
}

kcs_get_info() {
  local name="${KCS_NAME:-unknown}"
  local version="${KCS_VERSION:-dev}"
  printf '%s: %s\n' "$name" "$version"
  exit 0
}

__kcs_set_description() {
  local cb="$1"
  export KCS_DESCRIPTION
  KCS_DESCRIPTION="$($cb)"
}

__kcs_set_help() {
  local cb="$1"
  export KCS_HELP
  KCS_HELP="$($cb)"
}

kcs_get_help() {
  local name="${KCS_NAME:-unknown}"
  local version="${KCS_VERSION:-dev}"
  local desc=${KCS_DESCRIPTION:-<no-description>}
  local help="${KCS_HELP:-<no-help>}"

  printf "# %s (%s)
%s%s%s" "$name" "$version" "$desc" \
    "$__KCS_GLOBAL_HELP" \
    "$help"
  exit 0
}

__kcs_set_dry_run() {
  test -z "$DRY_RUN" && DRY_RUN=true
}
