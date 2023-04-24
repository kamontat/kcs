#!/usr/bin/env bash
##utils-example:v1.0.0-beta.2

## <module_name>:
##   <description>
## Hook: [init_utils|utils|<any>]
## Public functions:
##   <none>

## NOTE: All utility files must formatted as `_<name>.sh`.

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

## Register loaded utilities
kcs_utils_register "<module_name>" \
  "[dependencies...]"

## print input string
## @param $1 - [required] input string
## @return   - return zero
## @exit 1   - if something wrong
## @example  - __kcs_example "test"
__kcs_example() {
  printf "%s\n" "$1"
  return 0
}
