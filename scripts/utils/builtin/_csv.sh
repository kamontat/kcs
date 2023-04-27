#!/usr/bin/env bash
##utils-example:v1.0.0-beta.2

## builtin/csv:
##   read csv data
## Hook: utils
## Public functions:
##   `kcs_csv_read <fp> <cb> <h>` - read filepath can call callback function

## NOTE: All utility files must formatted as `_<name>.sh`.

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

## Register loaded utilities
kcs_utils_register "builtin/csv"

## read filepath can call callback function
## @param $1 - [required] csv filepath
##        $2 - [required] callback
##           - ($cb ${args[@]} where <args> is <key>=<value>)
##        $3 - [optional] pass `false` to not parse csv header
##           - then callback key will be index number instead
## @return   - return zero
## @exit 1   - if something wrong
## @example  - kcs_csv_read "/tmp/test.csv" "kcs_callback"
##           - below is a code to create variable name based on header
##           - for non-header variable will be `var_<n>` where n is index number
##             ```
##             for i in "$@"; do
##               eval "local $i"
##             done
##             ```
kcs_csv_read() {
  local filepath="$1" callback="$2" header="$3"

  local count=0
  local headers=()
  while read -r line; do
    local i=0 args=()
    if [ $count -eq 0 ] && [[ "$header" != false ]]; then
      for element in ${line//,/ }; do
        eval "headers+=(\"$element\")"
      done
    else
      local key value tmp="$IFS"

      IFS=","
      for element in $line; do
        if [ "${#headers[@]}" -gt 0 ]; then
          key="${headers[$i]}"
        else
          key="var_$i"
        fi
        value="$element"
        args+=("$key=\"$value\"")
        ((i++))
      done
      IFS="$tmp"

      "$callback" "${args[@]}"
    fi

    ((count++))
  done <"$filepath"
}
