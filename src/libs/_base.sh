#!/usr/bin/env bash

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

## Parse template with input values
## usage: `_kcs_template 'hello {name}' 'name=world'`
_kcs_template() {
  local kv key value
  local template="$1"
  shift
  for kv in "$@"; do
    key="${kv%%=*}"
    value="${kv##*=}"
    template="${template//\{$key\}/$value}"
  done
  printf "%s" "$template"
}

# shellcheck source=/dev/null
source "${KCS_DIR_SRC:?}/libs/__loader.sh" || exit 1
# shellcheck source=/dev/null
source "${KCS_DIR_SRC:?}/libs/__logger.sh" || exit 1

kcs_ld_load source with_throw lib _hook
kcs_ld_load source with_throw lib _lifecycle
