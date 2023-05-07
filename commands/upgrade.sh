#!/usr/bin/env bash
##example-command:v1
## > learn more at README.md

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

####################################################
## User defined function
####################################################

export KCS_NAME="upgrade"
export KCS_VERSION="v1.0.0"
export KCS_DESCRIPTION="upgrade kcs scripts to current version"
export KCS_HELP="
Usage: main.sh upgrade <path>
Arguments:
  <target>
    - target scripts to upgrade
"

export KCS_INIT_UTILS=(
  builtin/temp
  builtin/checker
  builtin/validator
  builtin/copier
)

__kcs_main() {
  local ns="$KCS_NAME"
  local arg="${KCS_COMMANDS[0]}"

  kcs_verify_present "$arg" "first argument"

  local basepath="$_KCS_DIR_SCRIPT" target="$arg/scripts"

  kcs_verify_dir "$basepath"
  kcs_verify_dir "$target"

  kcs_copy "$basepath" "$target" "internal" || return $?
  kcs_copy "$basepath" "$target" "utils/builtin" || return $?

  kcs_copy_lazy "$basepath" "$target" "README.md" || return $?
  kcs_copy_lazy "$basepath" "$target" ".gitignore" || return $?
  kcs_copy_lazy "$basepath" "$target" "main.sh" || return $?

  kcs_copy_lazy "$basepath" "$target" "commands/__example.sh" || return $?
  kcs_copy_lazy "$basepath" "$target" "commands/__exec.sh" || return $?
  kcs_copy_lazy "$basepath" "$target" "commands/README.md" || return $?

  kcs_info "$ns" \
    "upgraded successfully"
}

####################################################
## Internal function calls
####################################################

## original current directory
export _KCS_DIR_ORIG="${_KCS_DIR_ORIG:-$PWD}"

## move to script directory
## later, it will moved to root directory instead
if test -z "$_KCS_DIR_SCRIPT"; then
  cd "$(dirname "$0")/.." || exit 1
  export _KCS_DIR_SCRIPT="$PWD"
fi

# shellcheck disable=SC1091
source "$_KCS_DIR_SCRIPT/internal/command.sh" || exit 1

kcs_prepare
kcs_start "$@"
