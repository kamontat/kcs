#!/usr/bin/env bash
##utils-example:v1.0.0-beta.1

## Prompt:
##   create prompt to user
## Public functions:
##   `kcs_prompt_yn <msg> [yes]` - prompt yes-no question
##   `kcs_prompt <msg> <cb> [ans]` - prompt open-question with callback

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

## prompt yes-no question
## @param $1 - [required] message name
##        $2 - [optional] pre-set answer without prompt
## @return   - return 1 if user answered no
kcs_prompt_yn() {
  local msg="$1" ans="$2"
  local yes_list=(
    "Y" "y"
    "T" "t"
  )

  echo
  if test -z "$ans"; then
    printf "%s [Y|n]: " "$msg"
    case "$(uname -s)" in
    Linux)
      read -r ans
      ;;
    *)
      read -rn 1 ans
      echo
      ;;
    esac
  else
    printf "%s: %s\n" "$msg" "$ans"
  fi

  if [[ "${yes_list[*]}" =~ $ans ]]; then
    return 0
  fi

  return 1
}

## prompt open-question with callback
## @param $1 - [required] prompt message
##        $2 - [required] callback name with 1 parameter $ans
##        $3 - [optional] pre-set answer without prompt
kcs_prompt() {
  local msg="$1" callback="$2" ans="$3"

  echo
  printf "%s\n> " "$msg"
  read -r ans
  echo

  "$callback" "$ans"
}
