#!/usr/bin/env bash

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

export _KCS_CMD_SEP="__"
export _KCS_CMD_ARG_SEP="<>"
export __KCS_CMD_DEFAULT_NAME="_default.sh"

## find command from input arguments
## usage: `kcs_cmd_find <found-cb> <miss-cb> <raw-args...>`
## signature:
##   - found_cb: same as loader found callback
##   - miss_cb : same as loader miss callback
kcs_cmd_find() {
  local ns="finder.cmd"
  local found_cb="$1" miss_cb="__kcs_cmd_$2"
  shift 2

  local commands=() raw_args=() is_arg arg
  for arg in "$@"; do
    kcs_log_debug "$ns" \
      "checking input %s" "$arg"
    if test -z "$is_arg"; then
      if [[ "$arg" == "$__KCS_ARGS_SEPARATOR" ]]; then
        is_arg=true
        continue
      fi
      kcs_log_debug "$ns" \
        "add '%s' to commands resolver" "$arg"
      commands+=("$arg")
    else
      kcs_log_debug "$ns" \
        "add '%s' to arguments" "$arg"
      raw_args+=("$arg")
    fi
  done

  local args exit_code
  local index="${#commands[@]}"
  local filename="${commands[*]}"
  filename="${filename// /$_KCS_CMD_SEP}"
  while true; do
    if [ "$index" -le 0 ]; then
      break
    fi

    args=("${raw_args[@]}")
    args+=("${commands[@]:$index}")

    kcs_ld_load "$found_cb" "with_silent" commands "$filename"
    exit_code="$?"

    case "$exit_code" in
    0) return 0 ;;
    "$KCS_LD_CODE_ERROR") return 1 ;;
    esac

    filename="${commands[*]:0:$((index - 1))}"
    filename="${filename// /$_KCS_CMD_SEP}"

    ((index--))
  done

  "$miss_cb" "${commands[@]}" "${raw_args[@]}"
}

__kcs_cmd_with_silent() {
  return 1
}
__kcs_cmd_with_optional() {
  local ns="callback.cmd"
  kcs_log_error "$ns" "arguments [%s] is invalid" "$*"
  return 1
}
__kcs_cmd_with_throw() {
  __kcs_cmd_with_optional "$@"
  exit 1
}
