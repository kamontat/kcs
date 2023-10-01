#!/usr/bin/env bash

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

_KCS_CONFIGS_DB_ALL="__kcs_configs_db"

kcs_conf_use() {
  local ns="libs.configs.use"
  local key="$1" value="$2"

  local previous
  eval "previous=\"\${${_KCS_CONFIGS_DB_ALL}_${key}}\""
  if test -n "$previous"; then
    kcs_log_warn "$ns" "ignored duplicate config key (%s)" "$key"
    return 0
  fi

  kcs_log_debug "$ns" "export %s" "${_KCS_CONFIGS_DB_ALL}_${key}=${value}"
  export "${_KCS_CONFIGS_DB_ALL}_${key}=${value}"
}

kcs_conf_load() {
  local ns="libs.configs.load"
  local key="$1"

  local value name fn
  eval "value=\"\${${_KCS_CONFIGS_DB_ALL}_${key}}\""

  kcs_log_debug "$ns" "reading config value: %s" \
    "\${${_KCS_CONFIGS_DB_ALL}_${key}}"
  if test -n "$value"; then
    name="${key}_use_conf"
    fn="__kcs_${key}_conf_use_${value}"
    if ! kcs_func_optional "$name" "$fn"; then
      kcs_log_warn "$ns" "loading config return error (%s)" "$fn"
    fi
  else
    kcs_log_debug "$ns" "cannot found config of '%s'" "$key"
  fi

  return 0
}

__kcs_configs_on_init() {
  kcs_ld_lib functions

  kcs_hooks_add clean configs
}

__kcs_configs_hook_clean() {
  unset _KCS_CONFIGS_DB_ALL
}
