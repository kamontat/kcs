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
## see more on _kcs_log_internal()
kcs_log_debug() {
  _kcs_log_internal "$_KCS_LOG_DBG" "$@"
}
## Printf info message with log format
## see more on _kcs_log_internal()
kcs_log_info() {
  _kcs_log_internal "$_KCS_LOG_INF" "$@"
}
## Printf warning message with log format
## see more on _kcs_log_internal()
kcs_log_warn() {
  _kcs_log_internal "$_KCS_LOG_WRN" "$@"
}
## Printf error message with log format
## see more on _kcs_log_internal()
kcs_log_error() {
  _kcs_log_internal "$_KCS_LOG_ERR" "$@"
}
## Printf normal message with log format
## see more on _kcs_log_internal()
kcs_log_printf() {
  _kcs_log_internal "$_KCS_LOG_PRT" "$@"
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
    _kcs_log_is_silent "$lvl" && _KCS_LOG_SLT_ENABLED=true
    _kcs_log_is_error "$lvl" && _KCS_LOG_ERR_ENABLED=true
    _kcs_log_is_warn "$lvl" && _KCS_LOG_WRN_ENABLED=true
    _kcs_log_is_info "$lvl" && _KCS_LOG_INF_ENABLED=true
    _kcs_log_is_debug "$lvl" && _KCS_LOG_DBG_ENABLED=true
  done

  test -n "$DEBUG" && [[ "$DEBUG" =~ ^$_KCS_LOG_NAME ]] &&
    _KCS_LOG_DBG_ENABLED=true
  test -n "$SILENT" && [[ "$SILENT" =~ ^$_KCS_LOG_NAME ]] &&
    _KCS_LOG_SLT_ENABLED=true

  kcs_log_debug "$ns" "initiated logger settings"
  _KCS_LOG_INITIATE=true
}

## logging message to console
## usage: `_kcs_log_internal "lvl" "ns" "format" args...`
## variables:
##   $DEBUG='kcs[:<ns>,<ns>]'
##         - to enabled debug (omit ns to enabled all)
##   $KCS_LOGLVL='level,level,...'
##         - to enabled only specific level
##         - supported list: debug,info,warn,error,silent
##   $KCS_LOGFMT='{t} [{lvl}] {ns} : {msg}'
##         - to custom log output style
##         - supported list: dt, d, t, ns, lvl, msg, fmt, args
##   $KCS_LOGOUT=/tmp/abc
##         - writing log message to input filepath
_kcs_log_internal() {
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
          if [[ "$ns" =~ ^$value ]]; then
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

  local template="{t} [{lvl}] {ns} : {msg}"
  local args=("$@")
  local msg
  # shellcheck disable=SC2059
  msg="$(printf "$format" "${args[@]}")"

  local clvl is_err is_print
  case "$lvl" in
  "$_KCS_LOG_DBG") clvl="$(kcs_color "$lvl" BLACK)" ;;
  "$_KCS_LOG_INF") clvl="$(kcs_color "$lvl" CYAN)" ;;
  "$_KCS_LOG_WRN") clvl="$(kcs_color "$lvl" YELLOW)" && is_err=true ;;
  "$_KCS_LOG_ERR") clvl="$(kcs_color "$lvl" RED)" && is_err=true ;;
  "$_KCS_LOG_PRT") clvl="$(kcs_color "$lvl" DEFAULT)" && is_print=true ;;
  esac

  local cns
  cns="$(kcs_color "$ns" PINK)"

  local variables=()
  if test -z "$KCS_TEST"; then
    variables+=(
      "dt=$(date +"%Y/%m/%d %H:%M:%S")"
      "d=$(date +"%Y/%m/%d")"
      "t=$(date +"%H:%M:%S")"
    )
  else
    variables+=(
      "dt=2000/12/31 00:10:45"
      "d=2000/12/31"
      "t=00:10:45"
    )
  fi
  variables+=(
    "lvl=$clvl"
    "ns=$cns"
    "msg=$msg"
    "fmt=$format"
    "args=${args[*]}"
  )

  local output
  output="$(kcs_template "${KCS_LOGFMT:-$template}" "${variables[@]}")"
  output="$(_kcs_log_normalize "$output")"

  ## All error logs (warn, and error) always log to console
  if test -n "$is_err"; then
    echo "$output" >&2
  elif test -n "$is_print"; then
    echo "$output"
  elif test -n "$KCS_LOGOUT"; then
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

## variables:
##   $KCS_LOGDTL=true
##         - show detailed logs without normalize information first
_kcs_log_normalize() {
  test -n "${KCS_LOGDTL:-}" && printf '%s' "$1" && return 0

  local input="$1"
  input="${input//$KCT_PATH_TESTDIR/\$KCT_PATH_TESTDIR}"
  input="${input//$_KCS_PATH_SRC/\$KCS_PATH_SRC}"
  input="${input//$_KCS_PATH_ROOT/\$KCS_PATH_ROOT}"
  input="${input//$TMPDIR/\$TMPDIR}"
  input="${input//$_KCS_PATH_TMP/\$KCS_PATH_TMP}"
  input="${input//$HOME/\$HOME}"

  printf '%s' "$input"
}

_kcs_log_is_debug() {
  [[ "$1" == "debug" ]] ||
    [[ "$1" == "DEBUG" ]] ||
    [[ "$1" == "dbg" ]] ||
    [[ "$1" == "DBG" ]] ||
    [[ "$1" == "d" ]] ||
    [[ "$1" == "D" ]]
}
_kcs_log_is_info() {
  [[ "$1" == "info" ]] ||
    [[ "$1" == "INFO" ]] ||
    [[ "$1" == "inf" ]] ||
    [[ "$1" == "INF" ]] ||
    [[ "$1" == "i" ]] ||
    [[ "$1" == "I" ]]
}
_kcs_log_is_warn() {
  [[ "$1" == "warn" ]] ||
    [[ "$1" == "WARN" ]] ||
    [[ "$1" == "wrn" ]] ||
    [[ "$1" == "WRN" ]] ||
    [[ "$1" == "w" ]] ||
    [[ "$1" == "W" ]]
}
_kcs_log_is_error() {
  [[ "$1" == "error" ]] ||
    [[ "$1" == "ERROR" ]] ||
    [[ "$1" == "err" ]] ||
    [[ "$1" == "ERR" ]] ||
    [[ "$1" == "e" ]] ||
    [[ "$1" == "E" ]]
}
_kcs_log_is_silent() {
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
