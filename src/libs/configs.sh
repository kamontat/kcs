#!/usr/bin/env bash

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

_KCS_CONFIGS_DB_ALL="__kcs_configs_db"

kcs_conf_use() {
  local ns="use.config"
  local key="$1" value="$2"

  local previous
  eval "previous=\"\${${_KCS_CONFIGS_DB_ALL}_${key}}\""
  if test -n "$previous"; then
    kcs_log_warn "$ns" "ignored duplicate config key (%s)" "$key"
    return 0
  fi

  kcs_log_debug "$ns" "using config '%s' (%s)" "$value" "$key"
  export "${_KCS_CONFIGS_DB_ALL}_${key}=${value}"
}

kcs_conf_load() {
  local ns="load.config"
  local key="$1"

  local value
  eval "value=\"\${${_KCS_CONFIGS_DB_ALL}_${key}}\""

  if test -n "$value"; then
    name="${key}_use_conf"
    fn="__kcs_${key}_conf_use_${value}"
    kcs_func_optional "$name" "$fn" || return 1
  fi

  kcs_log_debug "$ns" "cannot found config of '%s'" "$key"
  return 0
}

__kcs_configs_lc_init() {
  kcs_ld_lib functions

  kcs_hooks_add clean configs
}

__kcs_configs_hook_clean() {
  unset _KCS_CONFIGS_DB_ALL
}
