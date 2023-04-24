#!/usr/bin/env bash
##command-example:v1.0.0-beta.1

## <title>:
##   <description>
##
## > learn more at README.md

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

####################################################
## User defined function
####################################################

export KCS_NAME="ssh/command"
export KCS_VERSION="v0.0.0"

export KCS_INIT_UTILS=(
  "builtin/ssh"
)

__kcs_main_config() {
  local server="${__SERVER:-pi01}"

  kcs_conf_ssh_proxy "$server" \
    "$(command -v cloudflared) access ssh --hostname pi01.kc.in.th" \
    "admin" "$HOME/.ssh/pi01_ed25519"
  kcs_conf_ssh_local "$server" \
    "192.168.1.11" "22" \
    "admin" "$HOME/.ssh/pi01_ed25519"
}

export KCS_OPTIONS="s"
__kcs_main_option() {
  # shellcheck disable=SC2034
  local flag="$1" value="$2"
  case "$flag" in
  s | server)
    kcs_no_argument "$flag"
    __SERVER="pi01"
    ;;
  *)
    return 1
    ;;
  esac
}

__kcs_main() {
  if test -n "$__SERVER"; then
    kcs_ssh_cmd "$__SERVER" ssh command
    return $?
  fi

  local ns="$KCS_NAME"
  kcs_logf "$ns" \
    "exec command from server $HOSTNAME"
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
