#!/usr/bin/env bash
## Hooks:

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

_kcs_register_hooks() {
  __kcs_register __kcs_optional_hook \
    pre_init __kcs_set_name:__kcs_main_name
  __kcs_register __kcs_optional_hook \
    pre_init __kcs_set_version:__kcs_main_version
  __kcs_register __kcs_optional_hook \
    pre_init __kcs_set_options:__kcs_main_option_keys
  __kcs_register __kcs_optional_hook \
    pre_init __kcs_set_description:__kcs_main_description
  __kcs_register __kcs_optional_hook \
    pre_init __kcs_set_help:__kcs_main_help
  __kcs_register __kcs_optional_hook \
    pre_init __kcs_logger_pre_init
  __kcs_register __kcs_optional_hook \
    pre_init __kcs_debug_pre_init
  __kcs_register __kcs_optional_hook \
    pre_init __kcs_pre_init
  __kcs_register __kcs_optional_hook \
    init __kcs_init
  __kcs_register __kcs_optional_hook \
    post_init __kcs_parse_options
  __kcs_register __kcs_optional_hook \
    post_init __kcs_main_register
  __kcs_register __kcs_optional_hook \
    post_init __kcs_post_init

  __kcs_register __kcs_optional_hook \
    pre_validate __kcs_pre_validate
  __kcs_register __kcs_optional_hook \
    validate __kcs_validate
  __kcs_register __kcs_optional_hook \
    post_validate __kcs_post_validate

  __kcs_register __kcs_optional_hook \
    pre_main __kcs_pre_main
  __kcs_register __kcs_required_hook \
    main __kcs_main
  __kcs_register __kcs_optional_hook \
    post_main __kcs_post_main

  __kcs_register __kcs_optional_hook \
    pre_clean __kcs_pre_clean
  __kcs_register __kcs_optional_hook \
    clean __kcs_logger_clean
  __kcs_register __kcs_optional_hook \
    clean __kcs_error_clean
  __kcs_register __kcs_optional_hook \
    clean __kcs_clean
  __kcs_register __kcs_optional_hook \
    post_clean __kcs_post_clean
}

__kcs_required_hook() {
  kcs_throw "$@"
}

__kcs_optional_hook() {
  shift 1
  kcs_debug "$@"

  return 0
}

__kcs_register() {
  local ns="register hook"
  local callback="$1" name="$2" raw="$3"
  local cb1="${raw%%:*}" cb2="${raw#*:}"

  if test -z "$raw"; then
    ## same syntax with kcs_throw
    "$callback" "$KCS_ERRCODE_MISSING_REQUIRED_ARGUMENT" \
      "$ns" "cannot register %s hook because missing callback" \
      "$name"
    return $?
  fi

  if ! command -v "$cb1" >/dev/null; then
    ## same syntax with kcs_throw
    "$callback" "$KCS_ERRCODE_CMD_NOT_FOUND" \
      "$ns" "%s hook failed, callback '%s' missing" \
      "$name" "$cb1"
    return $?
  fi

  if [[ "$cb1" != "$cb2" ]] &&
    ! command -v "$cb2" >/dev/null; then
    ## same syntax with kcs_throw
    "$callback" "$KCS_ERRCODE_CMD_NOT_FOUND" \
      "$ns" "%s hook failed, callback '%s' missing" \
      "$name" "$cb2"
    return $?
  fi

  kcs_add_hook "$name" "$raw"
}
