#!/usr/bin/env bash
## Main utilities for command entrypoint

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

kcs_prepare() {
  _KCS_ENTRY="${_KCS_ENTRY:-command}"
  if [[ "$_KCS_ENTRY" != "main" ]]; then
    # shellcheck disable=SC1091
    source "$_KCS_DIR_SCRIPT/internal/_base.sh"
  fi

  ## Load command specific internal and utilities
  kcs_load_internal "_hook.sh"
  kcs_load_internal "_hook_register.sh"

  kcs_load_internal "_information.sh"
  kcs_load_internal "_options.sh"
  kcs_load_internal "_options_internal.sh"
}

kcs_start() {
  _kcs_register_hooks
  _kcs_run_hooks "$@"
  _kcs_clean_hooks
}
