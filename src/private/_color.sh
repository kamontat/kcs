#!/usr/bin/env bash

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

kcs_color_enabled() {
  export _KCS_COLOR_RESET='\033[0m'

  export _KCS_COLOR_DEFAULT='\033[0;29m'
  export _KCS_COLOR_BLACK='\033[0;30m'
  export _KCS_COLOR_RED='\033[0;31m'
  export _KCS_COLOR_GREEN='\033[0;32m'
  export _KCS_COLOR_YELLOW='\033[0;33m'
  export _KCS_COLOR_BLUE='\033[0;34m'
  export _KCS_COLOR_PINK='\033[0;35m'
  export _KCS_COLOR_CYAN='\033[0;36m'
  export _KCS_COLOR_WHITE='\033[0;37m'

  export _KCS_COLOR_BG_BLACK='\033[40m'
  export _KCS_COLOR_BG_RED='\033[41m'
  export _KCS_COLOR_BG_GREEN='\033[42m'
  export _KCS_COLOR_BG_YELLOW='\033[43m'
  export _KCS_COLOR_BG_BLUE='\033[44m'
  export _KCS_COLOR_BG_PINK='\033[45m'
  export _KCS_COLOR_BG_CYAN='\033[46m'
  export _KCS_COLOR_BG_WHITE='\033[47m'
}
kcs_color_disable() {
  unset _KCS_COLOR_RESET

  unset _KCS_COLOR_BLACK _KCS_COLOR_RED _KCS_COLOR_GREEN _KCS_COLOR_YELLOW
  unset _KCS_COLOR_BLUE _KCS_COLOR_PINK _KCS_COLOR_CYAN _KCS_COLOR_WHITE

  unset _KCS_COLOR_BG_BLACK _KCS_COLOR_BG_RED _KCS_COLOR_BG_GREEN
  unset _KCS_COLOR_BG_YELLOW _KCS_COLOR_BG_BLUE _KCS_COLOR_BG_PINK
  unset _KCS_COLOR_BG_CYAN _KCS_COLOR_BG_WHITE
}

## Print input message with addon
## usage: `kcs_color <message> <addon...>`
## example: `kcs_color 'hello world' RED BG_YELLOW`
kcs_color() {
  local message="$1"
  shift

  local output='' raw addon
  for raw in "$@"; do
    addon="_KCS_COLOR_${raw//[\" ;]/}"
    output="$output\$$addon"
  done
  output="$output%s\$_KCS_COLOR_RESET"
  eval printf "$output" "$message"
}

_kcs_color_init() {
  if test -n "$KCS_CLRDIS"; then
    kcs_color_disable
  elif test -n "$KCS_LOGOUT"; then
    kcs_color_disable
  # elif test -n "$KCS_CLR"; then
  #   kcs_color_enabled
  fi

  ## Enabled color by default
  kcs_color_enabled
}

__kcs_color_hook_clean() {
  kcs_color_disable
}
