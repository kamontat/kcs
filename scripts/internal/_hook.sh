#!/usr/bin/env bash
## Hooks:

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

__kcs_hook_names=(
  pre_init init post_init
  pre_validate validate post_validate
  pre_main main post_main
  pre_clean clean post_clean
)

__kcs_hook_prefix="__kcs_hooks"
__kcs_hook_disable="${__kcs_hook_prefix}_disabled"

kcs_add_hook() {
  local ns="hooks"
  local name="$1" cb="$2"

  if [[ "${__kcs_hook_names[*]}" =~ $name ]]; then
    kcs_debug "$ns" "adding '%s' to hook name '%s'" \
      "$cb" "$name"

    eval "${__kcs_hook_prefix}_${name}+=(\"$cb\")"
  else
    kcs_warn "$ns" "adding invalid hook name '%s'" \
      "$name"
  fi
}

kcs_disable_hook() {
  local ns="hooks"
  local raw="$1" name cb
  name="${raw%%:*}"
  cb="__${raw#*:}"

  if [[ "${__kcs_hook_names[*]}" =~ $name ]]; then
    kcs_debug "$ns" "disabling '%s' to hook name '%s'" \
      "$cb" "$name"

    eval "${__kcs_hook_disable}_${name}+=(\"$cb\")"
  else
    kcs_warn "$ns" "disabling invalid hook name '%s'" \
      "$name"
  fi
}

_kcs_run_hook() {
  local name="$1" args=()
  shift
  args=("$@")

  local ns="$name hook"
  local commands=() command="" callback="" disables=() disabled=""

  ## Load commands from hooks variable
  eval "commands=(\"\${${__kcs_hook_prefix}_${name}[@]}\")"
  eval "disables=(\"\${${__kcs_hook_disable}_${name}[@]}\")"

  kcs_debug "$ns" "running %d commands (disabled=%d)" \
    "${#commands[@]}" \
    "${#disables[@]}"

  disabled="${disables[*]}"
  for raw in "${commands[@]}"; do
    command="${raw%%:*}"
    callback="${raw#*:}"

    if [[ "$disabled" =~ $command ]]; then
      kcs_debug "$ns" "disabled command '%s'" "$command"
      continue
    fi

    if [[ "$command" == "$callback" ]]; then
      kcs_must_exec "$command" "${args[@]}"
    else
      kcs_must_exec "$command" "$callback" "${args[@]}"
    fi
  done
}

_kcs_run_hooks() {
  local args=("$@")

  for name in "${__kcs_hook_names[@]}"; do
    _kcs_run_hook "$name" "${args[@]}"
  done
}
