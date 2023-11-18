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
  local args=(
    --key templates
    --module templates
    --on-missing warn
    --on-error error
    --regex
  )

  _kcs_ld_do "${args[@]}" \
    --suffix .tmpl \
    --action parser_default \
    --action-sh parser_eval \
    -- "$@"
}

## use default kcs_template function provided from _base.sh
__kcs_templates_ld_acb_parser_default() {
  local ns="libs.templates.default.parser" filepath="$3"
  shift 3

  kcs_template "$(cat "$filepath")" "$@"
}

## eval parser
## disclaim: This can be dangerous on unknown template
__kcs_templates_ld_acb_parser_eval() {
  local ns="libs.templates.eval.parser" filepath="$3"
  shift 3

  __kcs_templates_prompt_warning eval "$filepath"

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
  local ns="libs.templates.$engine.prompt"
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
