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
    value="${kv##*=}"
    template="${template//\{$key\}/$value}"
  done
  printf "%s" "$template"
}

## Parse argument
## usage: `kcs_argument <callback> <args...>`
## signature:
##   - callback: $cb '$extra' '$raw' '<args...>'
kcs_argument() {
  local ns="argument.base"
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
    "$callback" "${extra_args[*]}" "${raw_args[*]}" "${args[@]}"
  else
    kcs_log_warn "$ns" "callback(%s) function is missing" "$callback"
    return 1
  fi
}
