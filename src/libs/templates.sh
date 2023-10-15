#!/usr/bin/env bash

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

kcs_tmpl_load() {
  _kcs_ld_do \
    --module templates \
    --key templates \
    --suffix .tmpl \
    --action parse \
    --on-missing warn \
    --on-error error \
    -- "$@"
}

__kcs_templates_ld_acb_parse() {
  local ns="libs.templates.loader.parse"
  local filepath="$3"
  shift 3

  local engine="eval"

  if test -z "$KCS_TRUST"; then
    kcs_log_info "$ns" "Add KCS_TRUST=true to disable below prompt"
    kcs_log_info "$ns" "Parse '%s' using '%s', it might be dangerous [Enter]" \
      "$filepath" "$engine"
    ## Disable prompt on test mode
    test -z "$KCS_TEST" && read -r
  fi

  local input
  for input in "$@"; do
    local "$input"
  done

  local content
  content="$(cat "$filepath")"
  eval "printf '%s' \"$content\""
}
