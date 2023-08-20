#!/usr/bin/env bash

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

export _KCS_LOG_NAME=kcs

export _KCS_LOG_PRT="PRT"
export _KCS_LOG_DBG="DBG"
export _KCS_LOG_INF="INF"
export _KCS_LOG_WRN="WRN"
export _KCS_LOG_ERR="ERR"

export _KCS_LOG_INITIATE=false
export _KCS_LOG_SLT_ENABLED=false
export _KCS_LOG_DBG_ENABLED=false
export _KCS_LOG_INF_ENABLED=false
export _KCS_LOG_WRN_ENABLED=false
export _KCS_LOG_ERR_ENABLED=false

## Printf debug message with log format
## see more on __kcs_log()
kcs_log_debug() {
  __kcs_log "$_KCS_LOG_DBG" "$@"
}
## Printf info message with log format
## see more on __kcs_log()
kcs_log_info() {
  __kcs_log "$_KCS_LOG_INF" "$@"
}
## Printf warning message with log format
## see more on __kcs_log()
kcs_log_warn() {
  __kcs_log "$_KCS_LOG_WRN" "$@"
}
## Printf error message with log format
## see more on __kcs_log()
kcs_log_error() {
  __kcs_log "$_KCS_LOG_ERR" "$@"
}
## Printf normal message with log format
## see more on __kcs_log()
kcs_log_printf() {
  __kcs_log "$_KCS_LOG_PRT" "$@"
}

_kcs_log_init() {
  local ns="init.logger"
  $_KCS_LOG_INITIATE &&
    kcs_log_debug "$ns" "logger already initiated, skipped" &&
    return 0

  ## Default log levels
  test -z "$KCS_LOGLVL" && KCS_LOGLVL="error,warn,info"

  local lvl
  for lvl in ${KCS_LOGLVL//,/ }; do
    __kcs_log_is_silent "$lvl" && _KCS_LOG_SLT_ENABLED=true
    __kcs_log_is_error "$lvl" && _KCS_LOG_ERR_ENABLED=true
    __kcs_log_is_warn "$lvl" && _KCS_LOG_WRN_ENABLED=true
    __kcs_log_is_info "$lvl" && _KCS_LOG_INF_ENABLED=true
    __kcs_log_is_debug "$lvl" && _KCS_LOG_DBG_ENABLED=true
  done

  test -n "$DEBUG" && [[ "$DEBUG" =~ ^$_KCS_LOG_NAME ]] &&
    _KCS_LOG_DBG_ENABLED=true
  test -n "$SILENT" && [[ "$SILENT" =~ ^$_KCS_LOG_NAME ]] &&
    _KCS_LOG_SLT_ENABLED=true

  kcs_log_debug "$ns" "initiated logger settings"
  _KCS_LOG_INITIATE=true
}

## logging message to console
## usage: `__kcs_log "lvl" "ns" "format" args...`
## variables:
##   $DEBUG='kcs[:<ns>,<ns>]'
##         - to enabled debug (omit ns to enabled all)
##   $KCS_LOGLVL='level,level,...'
##         - to enabled only specific level
##         - supported list: debug,info,warn,error,silent
##   $KCS_LOGFMT='{dt} {ns} {lvl} {msg}'
##         - to custom log output style
##         - supported list: dt, d, t, ns, lvl, msg, fmt, args
##   $KCS_LOGOUT=/tmp/abc
##         - writing log message to input filepath
__kcs_log() {
  local lvl="$1" ns="${2// /-}"
  local format="$3"
  shift 3

  if $_KCS_LOG_SLT_ENABLED; then
    return 0
  elif [[ "$lvl" == "$_KCS_LOG_DBG" ]]; then
    $_KCS_LOG_DBG_ENABLED || return 0
    if test -n "$DEBUG"; then
      local dbg_key="${DEBUG%%:*}"
      local dbg_value="${DEBUG#*:}" value
      if [[ "$dbg_key" != "$dbg_value" ]]; then
        local dbg_disable=true
        for value in ${dbg_value//,/ }; do
          # if [[ "$ns" == "$value" ]]; then
          if [[ "$ns" =~ $value$ ]]; then
            dbg_disable=false
            break
          fi
        done
        "$dbg_disable" && return 0
      fi
    fi
  elif [[ "$lvl" == "$_KCS_LOG_INF" ]] && ! $_KCS_LOG_INF_ENABLED; then
    return 0
  elif [[ "$lvl" == "$_KCS_LOG_WRN" ]] && ! $_KCS_LOG_WRN_ENABLED; then
    return 0
  elif [[ "$lvl" == "$_KCS_LOG_ERR" ]] && ! $_KCS_LOG_ERR_ENABLED; then
    return 0
  fi

  local template="{t} [{lvl}] {ns} {msg}"
  local args=("$@")
  local msg
  # shellcheck disable=SC2059
  msg="$(printf "$format" "${args[@]}")"

  local clvl
  case "$lvl" in
  "$_KCS_LOG_DBG") clvl="$(kcs_color "$lvl" BLACK)" ;;
  "$_KCS_LOG_INF") clvl="$(kcs_color "$lvl" CYAN)" ;;
  "$_KCS_LOG_WRN") clvl="$(kcs_color "$lvl" YELLOW)" ;;
  "$_KCS_LOG_ERR") clvl="$(kcs_color "$lvl" RED)" ;;
  "$_KCS_LOG_PRT") clvl="$(kcs_color "$lvl" DEFAULT)" ;;
  esac

  local variables=()
  variables+=(
    "dt=$(date +"%Y/%m/%d %H:%M:%S")"
    "d=$(date +"%Y/%m/%d")"
    "t=$(date +"%H:%M:%S")"
  )
  variables+=(
    "lvl=$clvl"
    "ns=$(printf '%-20s' "$ns")"
    "msg=$msg"
    "fmt=$format"
    "args=${args[*]}"
  )

  local output
  output="$(kcs_template "${KCS_LOGFMT:-$template}" "${variables[@]}")"
  output="$(__kcs_log_normalize "$output")"

  if test -n "$KCS_LOGOUT"; then
    local dir
    dir="$(dirname "$KCS_LOGOUT")"
    if ! test -d "$dir"; then
      echo "logs directory is missing ($dir)" >&2
      exit 1
    fi

    echo "$output" >>"$KCS_LOGOUT"
  else
    echo "$output" >&2
  fi
}

__kcs_log_normalize() {
  local input="$1"
  input="${input//$KCT_PATH_TESTDIR/\$KCT_PATH_TESTDIR}"
  input="${input//$_KCS_PATH_SRC/\$KCS_PATH_SRC}"
  input="${input//$_KCS_PATH_ROOT/\$KCS_PATH_ROOT}"
  input="${input//$HOME/\$HOME}"

  printf '%s' "$input"
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

__kcs_log_hook_clean() {
  unset _KCS_LOG_NAME
  unset _KCS_LOG_DBG _KCS_LOG_DBG_ENABLED
  unset _KCS_LOG_INFO _KCS_LOG_INF_ENABLED
  unset _KCS_LOG_WRN _KCS_LOG_WRN_ENABLED
  unset _KCS_LOG_ERR _KCS_LOG_ERR_ENABLED
  unset _KCS_LOG_PRT _KCS_LOG_SLT_ENABLED
}
