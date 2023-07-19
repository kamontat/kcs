#!/usr/bin/env bash

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

export KCS_LOG_NAME=kcs

export KCS_LOG_PRT="PRT"
export KCS_LOG_DBG="DBG"
export KCS_LOG_INF="INF"
export KCS_LOG_WRN="WRN"
export KCS_LOG_ERR="ERR"

export _KCS_LOG_INITIATE
export _KCS_LOG_SLT_ENABLED
export _KCS_LOG_DBG_ENABLED
export _KCS_LOG_INF_ENABLED
export _KCS_LOG_WRN_ENABLED
export _KCS_LOG_ERR_ENABLED

## Printf debug message with log format
## see more on __kcs_log()
kcs_log_debug() {
  __kcs_log "$KCS_LOG_DBG" "$@"
}
## Printf info message with log format
## see more on __kcs_log()
kcs_log_info() {
  __kcs_log "$KCS_LOG_INF" "$@"
}
## Printf warning message with log format
## see more on __kcs_log()
kcs_log_warn() {
  __kcs_log "$KCS_LOG_WRN" "$@"
}
## Printf error message with log format
## see more on __kcs_log()
kcs_log_error() {
  __kcs_log "$KCS_LOG_ERR" "$@"
}
## Printf normal message with log format
## see more on __kcs_log()
kcs_log_printf() {
  __kcs_log "$KCS_LOG_PRT" "$@"
}

_kcs_log_init() {
  local ns="init.logger"
  test -n "$_KCS_LOG_INITIATE" &&
    kcs_log_debug "$ns" "logger already initiated, skipped" &&
    return 0

  test -z "$LOG_LEVEL" && LOG_LEVEL="error,warn,info"

  local lvl
  for lvl in ${LOG_LEVEL//,/ }; do
    __kcs_log_is_silent "$lvl" && _KCS_LOG_SLT_ENABLED=true
    __kcs_log_is_error "$lvl" && _KCS_LOG_ERR_ENABLED=true
    __kcs_log_is_warn "$lvl" && _KCS_LOG_WRN_ENABLED=true
    __kcs_log_is_info "$lvl" && _KCS_LOG_INF_ENABLED=true
    __kcs_log_is_debug "$lvl" && _KCS_LOG_DBG_ENABLED=true
  done

  test -n "$DEBUG" && [[ "$DEBUG" =~ ^$KCS_LOG_NAME ]] &&
    _KCS_LOG_DBG_ENABLED=true
  test -n "$SILENT" && [[ "$SILENT" =~ ^$KCS_LOG_NAME ]] &&
    _KCS_LOG_SLT_ENABLED=true

  kcs_log_debug "$ns" "initiated logger settings"
  _KCS_LOG_INITIATE=true
}
_kcs_log_clean() {
  unset KCS_LOG_NAME
  unset KCS_LOG_DBG _KCS_LOG_DBG_ENABLED
  unset KCS_LOG_INFO _KCS_LOG_INF_ENABLED
  unset KCS_LOG_WRN _KCS_LOG_WRN_ENABLED
  unset KCS_LOG_ERR _KCS_LOG_ERR_ENABLED
  unset KCS_LOG_PRT _KCS_LOG_SLT_ENABLED
}

## logging message to console
## usage: `__kcs_log "lvl" "ns" "format" args...`
## variables:
##   $DEBUG='kcs[:<ns>,<ns>]'
##         - to enabled debug (omit ns to enabled all)
##   $LOG_LEVEL='level,level,...'
##         - to enabled only specific level
##         - supported list: debug,info,warn,error,silent
##   $LOG_FORMAT='{dt} {ns} {lvl} {msg}'
##         - to custom log output style
##         - supported list: dt, d, t, ns, lvl, msg, fmt, args
__kcs_log() {
  local lvl="$1" ns="${2// /-}"
  local format="$3"
  shift 3

  if test -n "$_KCS_LOG_SLT_ENABLED"; then
    return 0
  elif [[ "$lvl" == "$KCS_LOG_DBG" ]]; then
    test -z "$_KCS_LOG_DBG_ENABLED" && return 0
    if test -n "$DEBUG"; then
      local dbg_key="${DEBUG%%:*}"
      local dbg_value="${DEBUG#*:}" value
      if [[ "$dbg_key" != "$dbg_value" ]]; then
        local dbg_disable=true
        for value in ${dbg_value//,/ }; do
          if [[ "$value" == "$ns" ]]; then
            dbg_disable=false
            break
          fi
        done
        "$dbg_disable" && return 0
      fi
    fi
  elif [[ "$lvl" == "$KCS_LOG_INF" ]] &&
    test -z "$_KCS_LOG_INF_ENABLED"; then
    return 0
  elif [[ "$lvl" == "$KCS_LOG_WRN" ]] &&
    test -z "$_KCS_LOG_WRN_ENABLED"; then
    return 0
  elif [[ "$lvl" == "$KCS_LOG_ERR" ]] &&
    test -z "$_KCS_LOG_ERR_ENABLED"; then
    return 0
  fi

  local template="{t} [{lvl}] {ns} {msg}"
  local args=("$@")
  local msg
  # shellcheck disable=SC2059
  msg="$(printf "$format" "${args[@]}")"

  local variables=()
  variables+=(
    "dt=$(date +"%Y/%m/%d %H:%M:%S")"
    "d=$(date +"%Y/%m/%d")"
    "t=$(date +"%H:%M:%S")"
  )
  variables+=(
    "lvl=$lvl" "ns=$(printf '%-15s' "$ns")"
    "msg=$msg" "fmt=$format" "args=${args[*]}"
  )

  _kcs_template "${LOG_FORMAT:-$template}" "${variables[@]}" >&2
  echo >&2
}

__kcs_log_is_debug() {
  [[ "$1" == "debug" ]] ||
    [[ "$1" == "DEBUG" ]] ||
    [[ "$1" == "dbg" ]] ||
    [[ "$1" == "DBG" ]] ||
    [[ "$1" == "d" ]] ||
    [[ "$1" == "D" ]]
}
__kcs_log_is_info() {
  [[ "$1" == "info" ]] ||
    [[ "$1" == "INFO" ]] ||
    [[ "$1" == "inf" ]] ||
    [[ "$1" == "INF" ]] ||
    [[ "$1" == "i" ]] ||
    [[ "$1" == "I" ]]
}
__kcs_log_is_warn() {
  [[ "$1" == "warn" ]] ||
    [[ "$1" == "WARN" ]] ||
    [[ "$1" == "wrn" ]] ||
    [[ "$1" == "WRN" ]] ||
    [[ "$1" == "w" ]] ||
    [[ "$1" == "W" ]]
}
__kcs_log_is_error() {
  [[ "$1" == "error" ]] ||
    [[ "$1" == "ERROR" ]] ||
    [[ "$1" == "err" ]] ||
    [[ "$1" == "ERR" ]] ||
    [[ "$1" == "e" ]] ||
    [[ "$1" == "E" ]]
}
__kcs_log_is_silent() {
  [[ "$1" == "silent" ]] ||
    [[ "$1" == "SILENT" ]] ||
    [[ "$1" == "slt" ]] ||
    [[ "$1" == "SLT" ]] ||
    [[ "$1" == "s" ]] ||
    [[ "$1" == "S" ]]
}
