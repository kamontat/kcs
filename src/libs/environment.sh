#!/usr/bin/env bash

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

kcs_env_get() {
  local namespace="$1" name="$2"
  local key="${namespace}__${name}"
  key="${key//[ .]/__}"
  key="${key//-/_}"
  key="${key//[\$\{\}]/}"

  eval "printf '%s' \"\$$(printf '%s' "$key" | tr '[:lower:]' '[:upper:]')\""
}

kcs_env_load_insert() {
  _kcs_ld_do_v2 \
    --module environment \
    --key envs \
    --prefix . \
    --action insert \
    --on-missing warn \
    --on-error throw \
    -- "$@"
}

kcs_env_load_upsert() {
  _kcs_ld_do_v2 \
    --module environment \
    --key envs \
    --prefix . \
    --action upsert \
    --on-missing error \
    --on-error throw \
    -- "$@"
}

kcs_env_unload() {
  _kcs_ld_do_v2 \
    --module environment \
    --key envs \
    --prefix . \
    --action delete \
    --on-missing mute \
    --on-error throw \
    -- "$@"
}

__kcs_environment_on_init() {
  kcs_env_load_insert default
  kcs_hooks_add clean environment
}

__kcs_environment_hook_clean() {
  kcs_env_unload default
}

__kcs_environment_ld_acb_insert() {
  local ns="libs.env.loader.insert"
  local key="$1" name="$2" filepath="$3"
  shift 3
  local line key value keys=()
  while read -r line; do
    [[ "$line" =~ ^# ]] || [[ "$line" =~ ^// ]] || test -z "$line" &&
      continue
    key="${line%%=*}"
    value="${line#*=}"
    keys+=("$key")
    if ! declare -p "$key" >/dev/null 2>&1; then
      export "$key"="$value"
    else
      kcs_log_debug "$ns" "variable '%s' was created, skipped" "$key"
    fi
  done <"$filepath"
  kcs_log_debug "$ns" "export '%d' variables [%s]" "${#keys[@]}" "${keys[*]}"
}

__kcs_environment_ld_acb_upsert() {
  local ns="libs.env.loader.upsert"
  local key="$1" name="$2" filepath="$3"
  shift 3
  local line key value keys=()
  while read -r line; do
    [[ "$line" =~ ^# ]] || [[ "$line" =~ ^// ]] || test -z "$line" &&
      continue
    key="${line%%=*}"
    value="${line#*=}"
    keys+=("$key")
    export "$key"="$value"
  done <"$filepath"
  kcs_log_debug "$ns" "export '%d' variables [%s]" "${#keys[@]}" "${keys[*]}"
}

__kcs_environment_ld_acb_delete() {
  local ns="libs.env.loader.delete"
  local key="$1" name="$2" filepath="$3"
  shift 3
  local line key value keys=()
  while read -r line; do
    [[ "$line" =~ ^# ]] || [[ "$line" =~ ^// ]] || test -z "$line" &&
      continue
    key="${line%%=*}"
    value="${line#*=}"
    keys+=("$key")
    unset "$key"
  done <"$filepath"
  kcs_log_debug "$ns" "unset '%d' variables [%s]" "${#keys[@]}" "${keys[*]}"
}
