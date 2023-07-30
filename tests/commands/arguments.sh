#!/usr/bin/env bash

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

__kcs_arguments_main() {
  local ns="$1"
  shift

  echo "name  : $KCS_CMD_NAME"
  echo "ns    : $ns"
  echo "args  : $# [$*]"
  echo "raw   : ${KCS_CMD_ARGS_RAW:-<missing>}"
  echo "extra : ${KCS_CMD_ARGS_EXTRA:-<missing>}"
}

if test -z "$_KCS_MAIN_MODE"; then
  export KCS_PATH_DIR_ORIG="$PWD"
  cd "$(dirname "$0")/.." || exit 1
  export KCS_PATH_DIR_SRC="$PWD"
  cd ".." || exit 1
  export KCS_PATH_DIR_ROOT="$PWD"
fi

# shellcheck source=/dev/null
source "$KCS_PATH_DIR_SRC/libs/base.sh" || exit 1
# shellcheck source=/dev/null
source "$KCS_PATH_DIR_SRC/libs/command.sh" || exit 1

kcs_command_start arguments "$@"
