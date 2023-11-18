#!/usr/bin/env bash

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

## Load templates file
## usage: `content="$(kcs_tmpl_load <filename> [<variables>]...)"`
## syntax:
##   - variables: <key>=<value> (e.g. name=hello)
kcs_tmpl_load() {
  _kcs_ld_do \
    --key templates \
    --module templates \
    --on-missing warn \
    --on-error error \
    --regex \
    --suffix .tmpl \
    --action parser_default \
    --action-sh parser_eval \
    -- "$@"
}

## use default kcs_template function provided from _base.sh
__kcs_templates_ld_acb_parser_default() {
  local engine=default
  local ns="libs.templates.parser.$engine" filepath="$3"
  shift 3

  kcs_log_debug "$ns" "using '%s' for '%s'" "$engine" "$filepath"
  kcs_template "$(cat "$filepath")" "$@"
}

## eval parser
## disclaim: This can be dangerous on unknown template
__kcs_templates_ld_acb_parser_eval() {
  local engine=eval
  local ns="libs.templates.parser.$engine" filepath="$3"
  shift 3

  kcs_log_debug "$ns" "using '%s' for '%s'" "$engine" "$filepath"
  __kcs_templates_prompt_warning $engine "$filepath"

  local input
  for input in "$@"; do
    local "$input"
  done

  local content
  content="$(cat "$filepath")"
  eval "printf '%s' \"$content\""
}

__kcs_templates_prompt_warning() {
  local engine="$1" filepath="$2"
  local ns="libs.templates.prompt.$engine"
  ## Prompt if user not trust and not on testing
  if test -z "$KCS_TRUST" && test -z "$KCS_TEST"; then
    kcs_log_info "$ns" \
      "Dangerously parse '%s' using '%s' [Enter] or add 'KCS_TRUST=true'" \
      "$filepath" "$engine"
    read -r
    ## If user trust, we will just print info message
  elif test -n "$KCS_TRUST"; then
    kcs_log_info "$ns" "Dangerously parse '%s' using '%s'" \
      "$filepath" "$engine"
  fi
}
