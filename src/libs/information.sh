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

## Logic on listing commands highly depends on _loader.sh code
## And logic to listing options highly depends on options.sh code
kcs_info_help() {
  local ns="libs.information.help"
  local sep="${KCS_CMDSEP:-/}"
  local recusive_limit=4

  local output=()

  output+=("# $_KCS_CMD_NAME ($_KCS_CMD_VERSION)")
  test -n "$_KCS_CMD_DESCRIPTION" &&
    output+=("$_KCS_CMD_DESCRIPTION" "") ||
    output+=("")

  ## Should find commands only if cannot resolve current command file.
  local command_basepaths=()
  ## $_KCS_CMD_DIRPATH should always be one of below list
  # command_basepaths+=("$_KCS_CMD_DIRPATH")
  test -n "$KCS_PATH" && command_basepaths+=("$KCS_PATH/commands")
  command_basepaths+=("$_KCS_PATH_ROOT/commands" "$_KCS_PATH_SRC/commands")

  if [[ "$_KCS_CMD_FILENAME" =~ ^_ ]]; then
    local command_basepath has_commands=false
    for command_basepath in "${command_basepaths[@]}"; do
      local command_paths=()
      if test -d "$command_basepath"; then
        local cmd_path="$command_basepath"
        local index="${#_KCS_CMD_ARGS[@]}"
        kcs_log_debug "$ns" "use '%s' as basepath" "$cmd_path"

        if [ "$index" -gt 0 ]; then
          local dirpath="${_KCS_CMD_ARGS[*]}"
          dirpath="${dirpath// /$sep}"
          while true; do
            if [ "$index" -le 0 ]; then
              break
            fi

            kcs_log_debug "$ns" "searching from dirpath '%s'" "$dirpath"
            if test -d "$command_basepath/$dirpath"; then
              cmd_path="$command_basepath/$dirpath"
              break
            fi

            dirpath="${_KCS_CMD_ARGS[*]:0:$((index - 1))}"
            dirpath="${dirpath// /$sep}"
            ((index--))
          done
        fi

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
      fi

      if [ "${#command_paths[@]}" -gt 0 ]; then
        if ! "$has_commands"; then
          output+=('## Commands')
          has_commands=true
        fi
        local cmd="kcs" command_path cmd_name formatted
        for command_path in "${command_paths[@]}"; do
          kcs_log_debug "$ns" "raw command path: %s" "$command_path"
          cmd_name="${command_path//$command_basepath\//}"
          cmd_name="${cmd_name//\.sh/}"
          cmd_name="${cmd_name//$sep/ }"

          formatted="$(printf '%-20s - %s' "$cmd_name" "$command_path")"
          output+=("$ $cmd $formatted")
        done
      else
        kcs_log_debug "$ns" "no commands found from '%s'" "$command_basepath"
      fi
    done

    if "$has_commands"; then
      output+=("")
    fi
  else
    kcs_log_debug "$ns" "skipped listing commands because showing command help"
  fi

  if kcs_ld_lib_is_loaded 'options'; then
    local opt_cache_path
    opt_cache_path="$(_kcs_options_def_cache "${_KCS_CMD_KEY:?}")"
    if test -f "$opt_cache_path"; then
      output+=("## Options")

      local opt_definitions opt_definition
      local opt_options opt_name opt_type opt_default opt_desc
      local formatted
      opt_definitions="$(cat "$opt_cache_path")"
      for opt_definition in ${opt_definitions//;/ }; do
        IFS=: read -r opt_options opt_name opt_type opt_default opt_desc <<<"$opt_definition"
        opt_options="$(_kcs_options_unescape "$opt_options")"
        opt_name="$(_kcs_options_unescape "$opt_name")"
        opt_type="$(_kcs_options_unescape "$opt_type")"
        opt_default="$(_kcs_options_unescape "$opt_default")"
        opt_desc="$(_kcs_options_unescape "$opt_desc")"
        test -n "$opt_default" && opt_default=":$opt_default"

        formatted="$(printf '%s %-24s - [%s%s] %s' '-' "$opt_options" "$opt_type" "$opt_default" "$opt_desc")"
        output+=("$formatted")
      done
    else
      ## This should not happen because
      ## cache should always created once options initialize
      kcs_log_error "$ns" "something went wrong, options cache is missing"
    fi
  fi

  local out
  for out in "${output[@]}"; do
    # shellcheck disable=SC2059
    echo "$out"
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
  unset _KCS_CMD_NAME _KCS_CMD_VERSION _KCS_CMD_DESCRIPTION
}
