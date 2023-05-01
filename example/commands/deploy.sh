#!/usr/bin/env bash
##command-example:v1.0.0-beta.2
## > learn more at README.md

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

####################################################
## User defined function
####################################################

export KCS_NAME="deploy"
export KCS_VERSION="v0.0.0"

export KCS_INIT_UTILS=(
  builtin/temp
  builtin/checker
  builtin/validator
  builtin/copier
)

__kcs_main_config() {
  kcs_conf_temp_no_clean
}

__kcs_main() {
  local ns="$KCS_NAME"
  local arg="${KCS_COMMANDS[0]}"

  kcs_verify_present "$arg" "first argument"

  local basepath="$_KCS_DIR_SCRIPT" target="$arg/scripts"

  kcs_verify_dir "$basepath"
  kcs_verify_dir "$target"

  kcs_copy "$basepath" "$target" "/internal" || return $?
  kcs_copy "$basepath" "$target" "utils/builtin" || return $?

  kcs_lazy_copy "$basepath" "$target" "README.md" || return $?
  kcs_lazy_copy "$basepath" "$target" ".gitignore" || return $?
  kcs_lazy_copy "$basepath" "$target" "main.sh" || return $?

  kcs_lazy_copy "$basepath" "$target" "commands/__example.sh" || return $?
  kcs_lazy_copy "$basepath" "$target" "commands/__exec.sh" || return $?
  kcs_lazy_copy "$basepath" "$target" "commands/README.md" || return $?

  kcs_info "$ns" \
    "successfully deployed"
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
