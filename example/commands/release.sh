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

export KCS_NAME="release"
export KCS_VERSION="v1.0.0"
export KCS_DESCRIPTION="release new kcs version"
export KCS_HELP="
Usage: main.sh release
"

export KCS_INIT_UTILS=(
  builtin/validator
)
export KCS_UTILS=(
  builtin/prompt
)

__kcs_create_version() {
  git tag "$1" --message ""
  git-chglog --output "CHANGELOG.md"
}

__kcs_main_check() {
  kcs_verify_cmd "git-chglog"
  kcs_verify_git_clean
}

__kcs_main() {
  git tag --column
  kcs_prompt "Enter your next version:" __kcs_create_version
}

__kcs_main_clean() {
  unset __kcs_main __kcs_create_version
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
