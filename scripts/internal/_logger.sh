#!/usr/bin/env bash

## Logger:
##   a logging function for getting script information or debugging

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

export KCS_LOG_LVL="LOG"
export KCS_DEBUG_LVL="DBG"
export KCS_INFO_LVL="INF"
export KCS_WARN_LVL="WRN"
export KCS_ERROR_LVL="ERR"

## default logger levels
export _KCS_LOG_LEVELS="$KCS_LOG_LVL $KCS_ERROR_LVL $KCS_WARN_LVL"

kcs_printf() {
  __kcs_log "" "$@"
}
kcs_logf() {
  __kcs_log "$KCS_LOG_LVL" "$@"
}
kcs_error() {
  __kcs_log "$KCS_ERROR_LVL" "$@"
}
kcs_warn() {
  __kcs_log "$KCS_WARN_LVL" "$@"
}
kcs_info() {
  __kcs_log "$KCS_INFO_LVL" "$@"
}
kcs_debug() {
  __kcs_log "$KCS_DEBUG_LVL" "$@"
}

## echo "test" | kcs_to_file "<file_name>" "<prefix>"
kcs_to_file() {
  local fname="$1" prefix="$2"
  local stdin timestamp
  read -r stdin

  test -n "$prefix" && prefix="[$prefix] "

  ## Use ISO 8601 output format
  timestamp="$(date -Iseconds)"
  echo "$timestamp: $prefix$stdin" >>"$_KCS_DIR_LOG/$fname"
}

## @param $1 - log level
##        $2 - namespace
##        $3 - format
##        $4 - arguments
__kcs_log() {
  local levels="$_KCS_LOG_LEVELS"
  ## slient mode
  if [[ "$levels" == "" ]]; then
    return 0
  fi

  local level="$1"
  ## if no-level, using normal printf
  if test -z "$level"; then
    shift 2

    # shellcheck disable=SC2059
    printf '%s\n' "$*"
    return 0
  fi

  local namespace="$2" format="$3" args=()
  shift 3
  args=("$@")

  ## only print if user enabled an input level
  if [[ "$_KCS_LOG_LEVELS" =~ $level ]]; then
    local __format="%s [%s] | %18s | $format\n"
    local __datetime __args=()

    __datetime="$(date +"%Y/%m/%d %H:%M:%S")"
    __args+=("$__datetime" "$level" "$namespace")
    if [ "${#args[@]}" -gt 0 ] &&
      echo "$format" | grep -q "%"; then
      __args+=("${args[@]}")
    fi

    if [[ "$level" == "$KCS_LOG_LVL" ]]; then
      # shellcheck disable=SC2059,SC2154
      printf "$__format" \
        "${__args[@]}"
    else
      # shellcheck disable=SC2059,SC2154
      printf "$__format" \
        "${__args[@]}" >&2
    fi
  fi
}

__kcs_set_debug_mode() {
  __kcs_set_info_mode
  _KCS_LOG_LEVELS="$_KCS_LOG_LEVELS $KCS_DEBUG_LVL"
}

__kcs_set_info_mode() {
  __kcs_set_warn_mode
  _KCS_LOG_LEVELS="$_KCS_LOG_LEVELS $KCS_INFO_LVL"
}

__kcs_set_warn_mode() {
  __kcs_set_error_mode
  _KCS_LOG_LEVELS="$_KCS_LOG_LEVELS $KCS_WARN_LVL"
}

__kcs_set_error_mode() {
  __kcs_set_log_mode
  _KCS_LOG_LEVELS="$_KCS_LOG_LEVELS $KCS_ERROR_LVL"
}

__kcs_set_log_mode() {
  __kcs_set_silent_mode
  _KCS_LOG_LEVELS="$_KCS_LOG_LEVELS $KCS_LOG_LVL"
}

__kcs_set_silent_mode() {
  _KCS_LOG_LEVELS=""
}

## set log level from number 0-5
## 0 - silent
## 1 - only log
## 2 - log and error
## 3 - log, error, and warn
## 4 - log, error, warn, and info
## 5 - debug mode
__kcs_set_log_level() {
  case "$1" in
  0 | slt | silent | SLT | SILENT)
    __kcs_set_silent_mode
    ;;
  1 | log | LOG | "")
    __kcs_set_log_mode
    ;;
  2 | err | error | ERR | ERROR)
    __kcs_set_error_mode
    ;;
  3 | wrn | warn | WRN | WARN)
    __kcs_set_warn_mode
    ;;
  4 | inf | info | INF | INFO)
    __kcs_set_info_mode
    ;;
  5 | dbg | debug | DBG | DEBUG)
    __kcs_set_debug_mode
    ;;
  esac
}

if test -n "$DEBUG" &&
  ! [[ "$_KCS_LOG_LEVELS" =~ $KCS_DEBUG_LVL ]]; then
  _KCS_LOG_LEVELS="$_KCS_LOG_LEVELS $KCS_DEBUG_LVL"
fi

__kcs_logger_pre_init() {
  if ! test -d "$_KCS_DIR_LOG"; then
    mkdir -p "$_KCS_DIR_LOG"
  fi

  if test -n "$LOG_LEVEL"; then
    __kcs_set_log_level "$LOG_LEVEL"
  fi
}
__kcs_logger_clean() {
  unset KCS_LOG_LVL \
    KCS_ERROR_LVL \
    KCS_WARN_LVL \
    KCS_INFO_LVL \
    KCS_DEBUG_LVL

  unset _KCS_LOG_LEVELS
}
