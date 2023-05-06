#!/usr/bin/env bash
##example-utils:v1

## builtin/test:
##   for testing onlys
## Hook: <any>
## Public functions:
##   <none>

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

kcs_utils_register "builtin/test"

kcs_logf "builtin/test" \
  "loading %s utilities" "builtin/test"
