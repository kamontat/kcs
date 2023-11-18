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
    --action-sh parser_default \
    --action-example-sh parser_default \
    -- "$@"
}

## Default parser (using `eval`)
## disclaim: This can be dangerous on unknown template
__kcs_templates_ld_acb_parser_default() {
  local ns="libs.templates.loader.parser.default"
  local filepath="$3"
  shift 3

  local engine="eval"

  ## Bypass prompt on test mode
  if test -z "$KCS_TRUST" && test -z "$KCS_TEST"; then
    kcs_log_info "$ns" \
      "Dangerously parse '%s' using '%s' [Enter] or add 'KCS_TRUST=true'" \
      "$filepath" "$engine"
    read -r
  fi

  local input
  for input in "$@"; do
    local "$input"
  done

  local content
  content="$(cat "$filepath")"
  eval "printf '%s' \"$content\""
}
