#!/usr/bin/env bash

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

## Parse template with input values
## usage: `kcs_template 'hello {name}' 'name=world'`
kcs_template() {
  local kv key value
  local template="$1"
  shift
  for kv in "$@"; do
    key="${kv%%=*}"
    value="${kv#*=}"
    template="${template//\{$key\}/$value}"
  done
  printf "%s" "$template"
}

## Parse argument
## usage: `kcs_argument <callback> <args...>`
## signature:
##   - callback: $cb '$raw' '$extra' '<args...>'
kcs_argument() {
  local ns="private.base.argument"
  local raw_sep='<>' extra_sep='--'
  local callback="$1"
  shift

  local args=() raw_args=() extra_args=()
  local is_raw=false is_extra=false input
  for input in "$@"; do
    kcs_log_debug "$ns" "checking input: '%s'" "$input"
    if "$is_raw"; then
      kcs_log_debug "$ns" "add '%s' as arguments [raw]" "$input"
      raw_args+=("$input")
      continue
    elif [[ "$input" == "$raw_sep" ]]; then
      is_raw=true
      continue
    fi

    if "$is_extra"; then
      kcs_log_debug "$ns" "add '%s' as arguments [extra]" "$input"
      extra_args+=("$input")
      continue
    elif [[ "$input" == "$extra_sep" ]]; then
      is_extra=true
      continue
    fi

    kcs_log_debug "$ns" "add '%s' as arguments" "$input"
    args+=("$input")
  done

  if command -v "$callback" >/dev/null; then
    "$callback" "${raw_args[*]}" "${extra_args[*]}" "${args[@]}"
  else
    kcs_log_warn "$ns" "callback(%s) function is missing" "$callback"
    return 1
  fi
}

## Save exit result for grateful exit (this will use input code as return)
## usage: `kcs_exit <code> [<reason...>]`
kcs_exit() {
  local ns="private.base.exit"
  local code="$1"
  shift

  if [ "$#" -gt 0 ]; then
    kcs_log_debug "$ns" "start grateful exit %d with logs" "$code"
    if [ "$code" -gt 0 ]; then
      kcs_log_error "$ns" "$@"
    else
      kcs_log_info "$ns" "$@"
    fi
  else
    kcs_log_debug "$ns" "start grateful exit %d without logs" "$code"
  fi

  if ! kcs_ld_lib_is_loaded 'hooks'; then
    kcs_log_debug "$ns" "exit instantly because missing hooks"
    exit "$code"
  fi

  kcs_hooks_disable pre_main
  kcs_hooks_disable main
  kcs_hooks_add finish exit "@varargs=$code"
  return "$code"
}
__kcs_exit_hook_finish() {
  exit "${1:-1}"
}

__kcs_base_setup() {
  ## Set up developer mode
  if test -n "$KCS_DEV"; then
    test -z "$DEBUG" && export DEBUG=kcs
    test -z "$KCS_TMPBFR" && export KCS_TMPBFR=true
    test -z "$KCS_TRUST" && export KCS_TRUST=true
    test -z "$KCS_TMPDIR" && export KCS_TMPDIR=/tmp/kcs
  fi

  return 0
}

__kcs_base_setup
