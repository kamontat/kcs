#!/usr/bin/env bash

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

## Show --version
kcs_info_version() {
  local ns="libs.info.version"
  if test -n "$_KCS_CMD_VERSION"; then
    printf '%s\n' "$_KCS_CMD_VERSION"
    return 0
  fi

  kcs_log_debug "$ns" \
    "missing version, create '%s' file with '%s'" \
    "envs/.default" \
    "KCS_CMD_VERSION=0.0.0"
  return 1
}

kcs_info_version_full() {
  local ns="libs.info.full-version"
  local kcs_version=dev

  if test -n "$_KCS_PATH_SRC" && test -f "$_KCS_PATH_SRC/version.txt"; then
    kcs_log_debug "$ns" "found kcs version from '%s'" "\$_KCS_PATH_SRC"
    kcs_version="$(cat "$_KCS_PATH_SRC/version.txt")"
  elif test -n "$_KCS_PATH_ROOT" && test -f "$_KCS_PATH_ROOT/version.txt"; then
    kcs_log_debug "$ns" "found kcs version from '%s'" "\$_KCS_PATH_ROOT"
    kcs_version="$(cat "$_KCS_PATH_ROOT/version.txt")"
  fi

  if test -n "$_KCS_CMD_NAME" && test -n "$_KCS_CMD_VERSION"; then
    printf '%s: %s\n' "$_KCS_CMD_NAME" "$_KCS_CMD_VERSION"
    printf '%s: %s\n' "kcs" "$kcs_version"
    return 0
  fi

  kcs_log_debug "$ns" \
    "information is missing either '%s' or '%s'" \
    "KCS_CMD_NAME $_KCS_CMD_NAME" \
    "KCS_CMD_VERSION $_KCS_CMD_VERSION"
  return 1
}

## TODO: Add options help from options apis as well
kcs_info_help() {
  local ns="libs.information.help"
  local sep="${KCS_CMDSEP:-/}"
  local recusive_limit=4

  local output=() newline=$'\n'

  output+=("# $_KCS_CMD_NAME ($_KCS_CMD_VERSION)" "$newline")
  test -n "$_KCS_CMD_DESCRIPTION" &&
    output+=("$_KCS_CMD_DESCRIPTION" "$newline" "$newline") ||
    output+=("$newline")

  ## Should find commands only if cannot resolve current command file.
  local command_basepath="$_KCS_CMD_DIRPATH" command_paths=()
  if [[ "$_KCS_CMD_FILENAME" =~ ^_ ]]; then
    if test -d "$command_basepath"; then
      local cmd_path="$command_basepath"
      local index="${#_KCS_CMD_ARGS[@]}"

      if [ "$index" -gt 0 ]; then
        local dirpath="${_KCS_CMD_ARGS[*]}"
        dirpath="${dirpath// /$sep}"
        while true; do
          if [ "$index" -le 0 ]; then
            break
          fi

          kcs_log_debug "$ns" "current dirpath is '%s'" "$dirpath"
          if test -d "$command_basepath/$dirpath"; then
            cmd_path="$command_basepath/$dirpath"
            break
          fi

          dirpath="${_KCS_CMD_ARGS[*]:0:$((index - 1))}"
          dirpath="${dirpath// /$sep}"
        done
      fi

      kcs_log_debug "$ns" "set command path to '%s'" "$cmd_path"

      find_script() {
        local p f dp="$1" limit="$2"
        if [ "$limit" -le 0 ]; then
          kcs_log_warn "$ns" \
            "ignore path because recusive limit reach (%s)" "$dp"
          return 0
        fi

        for p in "$dp"/*; do
          f="$(basename "$p")"
          if test -d "$p"; then
            find_script "$p" "$((limit - 1))"
          elif test -f "$p" && ! [[ "$f" =~ ^_ ]]; then
            command_paths+=("$p")
          fi
        done
      }

      find_script "$cmd_path" "$recusive_limit"
    else
      kcs_log_debug "$ns" \
        "cannot found $%s variable to resolving path" "_KCS_CMD_DIRPATH"
    fi
  fi

  if [ "${#command_paths[@]}" -gt 0 ]; then
    output+=('## Commands' "$newline")
    local cmd="kcs" command_path cmd_name formatted
    for command_path in "${command_paths[@]}"; do
      cmd_name="${command_path//$command_basepath\//}"
      cmd_name="${cmd_name//\.sh/}"
      cmd_name="${cmd_name//$sep/ }"

      formatted="$(printf '%-20s - %s' "$cmd_name" "$command_path")"
      output+=("$ $cmd $formatted" "$newline")
    done
    output+=("$newline")
  else
    kcs_log_debug "$ns" "skipped listing possible commands"
  fi

  if kcs_ld_lib_is_loaded 'options'; then
    local opt_cache_path
    opt_cache_path="$(_kcs_options_def_cache "${_KCS_CMD_KEY:?}")"
    if test -f "$opt_cache_path"; then
      output+=("## Options" "$newline")

      opt_definition="$(cat "$opt_cache_path")"
      echo "$opt_definition"
    else
      ## This should not happen because
      ## cache should always created once options initialize
      kcs_log_error "$ns" "something went wrong, options cache is missing"
    fi
  fi

  local out
  for out in "${output[@]}"; do
    # shellcheck disable=SC2059
    printf "$out"
  done
}

__kcs_information_on_init() {
  local ns="libs.information.on.init"

  kcs_hooks_add pre_clean information
  if test -z "$_KCS_CMD_NAME"; then
    # shellcheck disable=SC2016
    kcs_log_warn "$ns" "missing %s variable, information might not completed" \
      '$_KCS_CMD_NAME'
  fi

  export _KCS_CMD_VERSION="${KCS_CMD_VERSION:-dev}"
  export _KCS_CMD_DESCRIPTION="${KCS_CMD_DESCRIPTION:-}"
}

__kcs_information_hook_clean() {
  unset _KCS_CMD_VERSION
}
