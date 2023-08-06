#!/usr/bin/env bash

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

## Must call function
## usage: `kcs_func_must <name> <func> <args...>`
kcs_func_must() {
  _kcs_ld_do function nothing throw throw func "$@"
}

## Should call function (or ignore if not exist)
## usage: `kcs_func_optional <name> <func> <args...>`
kcs_func_optional() {
  _kcs_ld_do function nothing mute throw func "$@"
}

## Silently call function (and silently ignore error if occurred)
## usage: `kcs_func_silent <name> <func> <args...>`
kcs_func_silent() {
  _kcs_ld_do function nothing mute silent func "$@"
}
