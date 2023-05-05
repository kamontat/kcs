#!/usr/bin/env bash
##example-utils:v1

## builtin/copier:
##   copy current to target
## Hook: <any>
## Public functions:
##   `kcs_copy <base> <target> <name> <new>` - copy file or directory from base
##   `kcs_lazy_copy <b> <t> <n> <w>` - copy file or directory if required

## NOTE: All utility files must formatted as `_<name>.sh`.

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

## Register loaded utilities
kcs_utils_register "builtin/copier" \
  "builtin/temp"

## copy file or directory from base
## @param $1 - [required] current base directory
##        $2 - [required] target base directory
##        $3 - [optional] append current base '$1' if exist
##        $4 - [optional] append target base '$2' if exist
## @example  - kcs_copy "/home/admin/test.txt" "/tmp/test.txt"
##           - kcs_copy "/home/admin" "/tmp" "test.txt"
##           - kcs_copy "/home/admin" "/tmp" "test.txt" "test.txt"
kcs_copy() {
  __kcs_copy "$1" "$2" "$3" "$4" ""
}

## copying if and only if target not exist or change only
## note: lazy only works on file copying, not directory
## @param $1 - [required] current base directory
##        $2 - [required] target base directory
##        $3 - [required] current file/directory name
##        $4 - [optional] copied file/directory name
kcs_lazy_copy() {
  __kcs_copy "$1" "$2" "$3" "$4" "lazy"
}

## internal copy wrapper using cp command with kcs configuration
## this is not support regex/globcard path
## @param $1 - [required] current base directory
##        $2 - [required] target base directory
##        $3 - [optional] append current base '$1' if exist
##        $4 - [optional] append target base '$2' if exist
##        $5 - [optional] pass 'lazy' to copy lazy mode
__kcs_copy() {
  local ns="copier" ftype="unknown"
  local ibase="${1:?}" obase="${2:?}"
  local iname="${3#/*}" oname="${4:-$3}"
  local is_lazy="$5"

  test -n "$is_lazy" && ns="lazy-copier"
  oname="${oname#/*}"

  local ipath opath
  local checksum
  checksum="$(kcs_temp_create_file)"

  if test -n "$iname"; then
    ipath="$ibase/$iname"
  fi
  if test -n "$oname"; then
    opath="$obase/$oname"
  fi

  if test -f "$ipath"; then
    ftype="file"
  elif test -d "$ipath"; then
    ftype="directory"
  fi

  kcs_debug "$ns" "starting copy '%s'" "$ftype"

  local cmd="cp" cp_args=()
  local shasum no_change
  if [[ "$ftype" == "directory" ]]; then
    cp_args+=("-r")

    ipath="$ipath/./"
    ## remove double slash if exist
    ipath="${ipath//\/\///}"
  elif [[ "$ftype" == "file" ]]; then
    ## If lazy enabled and same content, return
    if test -n "$is_lazy"; then
      read -r shasum _ < <(sha256sum "$opath")
      echo "$shasum $ipath" >"$checksum"
      if sha256sum --check --status "$checksum"; then
        no_change=true
      fi
    fi
  fi

  if test -n "$no_change"; then
    kcs_debug "$ns" \
      "no changes on file (%s), exit" "$opath"
    return 0
  fi

  cp_args+=(
    "$ipath"
    "$opath"
  )

  kcs_info "$ns" \
    "copying '%s' to '%s'" \
    "$ipath" "$opath"
  kcs_exec "$cmd" "${cp_args[@]}"
}
