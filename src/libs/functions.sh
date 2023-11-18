#!/usr/bin/env bash

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

## Must call function or grateful exit (or force if cannot grateful)
## On grateful exit, this function will return input code as well
## usage: `kcs_func_must <name> <func> <args...>`
kcs_func_must() {
  _kcs_ld_do \
    --module functions \
    --key func \
    --suffix .sh \
    --action run \
    --on-missing throw \
    --on-error throw \
    --function \
    -- "$@"
}

## call function only if exist
## usage: `kcs_func_optional <name> <func> <args...>`
kcs_func_optional() {
  _kcs_ld_do \
    --function \
    --key func \
    --module functions \
    --action run \
    --on-missing silent \
    --on-error throw \
    -- "$@"
}

## Silently call function (and silently ignore error if occurred)
## usage: `kcs_func_silent <name> <func> <args...>`
kcs_func_silent() {
  _kcs_ld_do \
    --function \
    --key func \
    --module functions \
    --action run \
    --on-missing mute \
    --on-error silent \
    -- "$@"
}

__kcs_functions_ld_acb_run() {
  local ns="libs.functions.loader.run"
  local key="$1" name="$2" fn="$3"
  shift 3

  kcs_log_debug "$ns" \
    "run '%s' function with %d args [%s]" "$fn" "$#" "$*"
  "$fn" "$@"
}
