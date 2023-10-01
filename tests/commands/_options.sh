#!/usr/bin/env bash

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

__kcs_opt_hook_load() {
  kcs_ld_lib options \
    '-l; LAND' \
    '-f|--flower; FLOWER' \
    '-s|--sky <str>; SKY' \
    '-w|--water [str]; WATER' \
    '-r|--rock [str:paper]; ROCK' \
    '-e|--ex|--extra; EXTRA' \
    '--q; QUE' \
    '-a|--animal [str]; ANIMAL show all animal in the earth'
}

__kcs_opt_hook_main() {
  # shellcheck disable=SC2034
  local ns="$1"
  shift

  echo "Direct Arguments: $# [$*]"
  echo "Parsed Arguments: ${#_KCS_CMD_ARGS[@]} [${_KCS_CMD_ARGS[*]}]"

  test -n "$_KCS_OPT_LAND_VALUE" &&
    echo "Land: $_KCS_OPT_LAND_VALUE"
  test -n "$_KCS_OPT_FLOWER_VALUE" &&
    echo "Flower: $_KCS_OPT_FLOWER_VALUE"
  test -n "$_KCS_OPT_SKY_VALUE" &&
    echo "Sky: $_KCS_OPT_SKY_VALUE"
  test -n "$_KCS_OPT_WATER_VALUE" &&
    echo "Water: $_KCS_OPT_WATER_VALUE"
  test -n "$_KCS_OPT_ROCK_VALUE" &&
    echo "Rock: $_KCS_OPT_ROCK_VALUE"
  test -n "$_KCS_OPT_EXTRA_VALUE" &&
    echo "Extra: $_KCS_OPT_EXTRA_VALUE"
  test -n "$_KCS_OPT_QUE_VALUE" &&
    echo "Que: $_KCS_OPT_QUE_VALUE"
  test -n "$_KCS_OPT_ANIMAL_VALUE" &&
    echo "Animal: $_KCS_OPT_ANIMAL_VALUE"

  return 0
}

if test -z "$_KCS_MAIN_MODE"; then
  export _KCS_PATH_ORIG="$PWD"
  cd "$(dirname "$0")/.." || exit 1
  export _KCS_PATH_SRC="$PWD"
  cd ".." || exit 1
  export _KCS_PATH_ROOT="$PWD"
fi

# shellcheck source=/dev/null
source "$_KCS_PATH_SRC/private/base.sh" || exit 1
# shellcheck source=/dev/null
source "$_KCS_PATH_SRC/private/command.sh" || exit 1

kcs_command_start opt "$@"
