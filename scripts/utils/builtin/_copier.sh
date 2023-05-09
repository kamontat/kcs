#!/usr/bin/env bash
##example-utils:v1

## builtin/copier:
##   copy current to target
## Hook: <any>
## Public functions:
##   `kcs_conf_copy_auto_create` - force copy to create missing directory
##   `kcs_conf_copy_never_create` - force copy to never missing directory
##   `kcs_conf_copy_use_cp` - force using 'cp' to copy
##   `kcs_conf_copy_use_rsync` - force using 'rsync' to copy
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
__KCS_COPIER_COMMAND=""

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

## force using 'cp' to copy
kcs_conf_copy_use_cp() {
  local ns="copy-configure"
  __KCS_COPIER_COMMAND="cp"
  kcs_debug "$ns" \
    "force use '%s' command" \
    "cp"
}

## force using 'rsync' to copy
kcs_conf_copy_use_rsync() {
  local ns="copy-configure"
  __KCS_COPIER_COMMAND="rsync"
  kcs_debug "$ns" \
    "force use '%s' command" \
    "rsync"
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

  local test_args=()
  if test -f "$ipath"; then
    ftype="file"
    test_args+=("-f")
    "$__KCS_COPIER_AUTO_CREATE" &&
      kcs_create_file "$opath"
  elif test -d "$ipath"; then
    ftype="directory"
    test_args+=("-d")
    "$__KCS_COPIER_AUTO_CREATE" &&
      kcs_create_dir "$opath"
  fi

  kcs_debug "$ns" "starting copy '%s'" "$ftype"
  kcs_debug "$ns" \
    "input: %s, output: %s" \
    "$ipath" "$opath"

  test_args+=("$opath")
  if [[ "$mode" == "missing" ]] &&
    test "${test_args[@]}"; then
    kcs_debug "$ns" \
      "skipping %s: '%s' because it's existed" \
      "$ftype" "$opath"
    return 0
  fi

  if [[ "$__KCS_COPIER_COMMAND" == "rsync" ]]; then
    __kcs_rsync "$mode" "$ftype" "$ipath" "$opath"
  elif [[ "$__KCS_COPIER_COMMAND" == "cp" ]]; then
    __kcs_cp "$mode" "$ftype" "$ipath" "$opath"
  elif command -v "rsync" >/dev/null; then
    __kcs_rsync "$mode" "$ftype" "$ipath" "$opath"
  else
    __kcs_cp "$mode" "$ftype" "$ipath" "$opath"
  fi
}

## Internal cp command with mode supported
__kcs_cp() {
  local ns="cp"
  local mode="$1" ftype="$2"
  local ipath="$3" opath="$4"
  test -n "$mode" && ns="$mode-$ns"

  kcs_debug "$ns" \
    "starting 'cp' command on '%s' mode" \
    "$mode"

  local cmd="cp" args=()

  local shasum no_change=false
  if [[ "$ftype" == "directory" ]]; then
    args+=("-r")
    ipath="$ipath/./"
    ## remove double slash if exist
    ipath="${ipath//\/\///}"

    local checksum1 checksum2
    checksum1="$(kcs_temp_create_file)"
    checksum2="$(kcs_temp_create_file)"

    find "$ipath" \
      -type f \
      -exec sha256sum "{}" \; |
      cut -d\  -f1 |
      sort >"$checksum1"
    find "$opath" \
      -type f \
      -exec sha256sum "{}" \; |
      cut -d\  -f1 |
      sort >"$checksum2"

    if diff -q "$checksum1" "$checksum2" >/dev/null; then
      no_change=true
    fi
  elif [[ "$ftype" == "file" ]] &&
    [[ "$mode" == "lazy" ]]; then
    local checksum
    checksum="$(kcs_temp_create_file)"

    read -r shasum _ < <(sha256sum "$opath")
    echo "$shasum $ipath" >"$checksum"
    if sha256sum --check --status "$checksum"; then
      no_change=true
    fi
  fi

  if "$no_change"; then
    kcs_debug "$ns" \
      "skipping %s: '%s' because same content" \
      "$ftype" "$opath"
    return 0
  fi

  args+=("$ipath" "$opath")
  kcs_exec "$cmd" "${args[@]}"
}

## Internal rsync command with mode supported
__kcs_rsync() {
  local ns="rsync"
  local mode="$1" ftype="$2"
  local ipath="$3" opath="$4"
  test -n "$mode" && ns="$mode-$ns"

  kcs_debug "$ns" \
    "starting 'rsync' command on '%s' mode" \
    "$mode"

  local cmd="rsync" args=()

  args+=(
    --sparse --times
    --executability --perms
    --quiet
  )

  if [[ "$mode" == "lazy" ]]; then
    args+=(--checksum)
  fi

  args+=("$ipath" "$opath")
  kcs_exec "$cmd" "${args[@]}"
}

kcs_add_hook clean \
  __kcs_copier_clean
__kcs_copier_clean() {
  unset __KCS_COPIER_COMMAND \
    __KCS_COPIER_AUTO_CREATE
}
