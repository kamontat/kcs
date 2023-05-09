#!/usr/bin/env bash
##example-utils:v1

## builtin/copier:
##   copy current to target
## Hook: <any>
## Public functions:
##   `kcs_conf_copy_auto_create` - force copy to create missing directory
##   `kcs_conf_copy_never_create` - force copy to never missing directory
##   `kcs_copy <base> <target> <name> <new>` - copy file or directory from base
##   `kcs_copy_missing <b> <t> <n> <w>` - copy file or directory if missing
##   `kcs_copy_lazy <b> <t> <n> <w>` - copy file or directory if needed

## NOTE: All utility files must formatted as `_<name>.sh`.

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

## Register loaded utilities
kcs_utils_register "builtin/copier" \
  "builtin/temp" builtin/fs

__KCS_COPIER_AUTO_CREATE=true

## make copy will auto create directory on target
kcs_conf_copy_auto_create() {
  local ns="copy-configure"
  __KCS_COPIER_AUTO_CREATE=true
  kcs_debug "$ns" \
    "enabled auto create directory"
}

## make copy never create directory on target
kcs_conf_copy_never_create() {
  local ns="copy-configure"
  __KCS_COPIER_AUTO_CREATE=false
  kcs_debug "$ns" \
    "disable auto create directory"
}

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
kcs_copy_lazy() {
  __kcs_copy "$1" "$2" "$3" "$4" "lazy"
}

## copying if and only if target is missing
## @param $1 - [required] current base directory
##        $2 - [required] target base directory
##        $3 - [required] current file/directory name
##        $4 - [optional] copied file/directory name
kcs_copy_missing() {
  __kcs_copy "$1" "$2" "$3" "$4" "missing"
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
  local mode="$5"

  test -n "$mode" && ns="$mode-copier"
  oname="${oname#/*}"

  local ipath opath

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
  kcs_debug "$ns" \
    "input: %s, output: %s" \
    "$ipath" "$opath"

  local cmd="cp" cp_args=() test_args=()
  local shasum no_change
  if [[ "$ftype" == "directory" ]]; then
    "$__KCS_COPIER_AUTO_CREATE" &&
      kcs_create_dir "$opath"

    cp_args+=("-r")
    test_args+=("-d")

    ipath="$ipath/./"
    ## remove double slash if exist
    ipath="${ipath//\/\///}"

    return 0
  elif [[ "$ftype" == "file" ]]; then
    test_args+=("-f")

    ## If lazy enabled and same content, return
    if [[ "$mode" == "lazy" ]]; then
      local checksum
      checksum="$(kcs_temp_create_file)"

      "$__KCS_COPIER_AUTO_CREATE" &&
        kcs_create_file "$opath"
      read -r shasum _ < <(sha256sum "$opath")
      echo "$shasum $ipath" >"$checksum"
      if sha256sum --check --status "$checksum"; then
        no_change=true
      fi
    fi
  fi

  test_args+=("$opath")
  if [[ "$mode" == "missing" ]] &&
    test "${test_args[@]}"; then
    no_change=true
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
