#!/usr/bin/env bash
##utils-example:v1.0.0-beta.1

## builtin/ssh:
##   work same with ssh, use mode to decide which config to resolve
## Public functions:
##   `kcs_conf_ssh_local <p> <ip> <port> <u> <pem>` - create new ssh profile
##   `kcs_conf_ssh_proxy <p> <px> <u> <pem>` - create new ssh proxy profile
##   `kcs_conf_ssh_auto_mode` - auto select ssh config
##   `kcs_conf_ssh_default_mode` - use default ssh config
##   `kcs_conf_ssh_local_mode` - use custom local ssh config
##   `kcs_conf_ssh_proxy_mode` - use custom proxy ssh config
##   `kcs_ssh <p> <opts...> -- <args...>` - works same as ssh on profile
##   `kcs_ssh_cmd <p> <cmd>` - execute command on profile
##   `kcs_ssh_copy_from <p> <args...>` - copy file/folder from profile
##   `kcs_ssh_copy_to <p> <args...>` - copy file/folder to profile
##   `kcs_scp <p> <args...>` - works same as scp on profile

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

kcs_utils_register "builtin/ssh"

export _KCS_SSH_CONFIG_DIR="$_KCS_DIR_TEMP/ssh"

## Configuration mode
export KCS_SSH_MODE_AUTO="auto"
export KCS_SSH_MODE_DEFAULT="default"
export KCS_SSH_MODE_LOCAL="local"
export KCS_SSH_MODE_PROXY="proxy"
export __KCS_SSH_MODE="$KCS_SSH_MODE_AUTO"

## Configuration type
export KCS_SSH_TYPE_DEFAULT="default"
export KCS_SSH_TYPE_LOCAL="local"
export KCS_SSH_TYPE_PROXY="proxy"
export __KCS_SSH_TYPE=""

## create new local ssh profile config
## @param $1 - [required] profile name
##        $2 - [required] hostname
##        $3 - [optional] port number
##        $4 - [optional] username
##        $5 - [optional] private key for authentication
kcs_conf_ssh_local() {
  __kcs_ssh_new_profile "$1" "$KCS_SSH_TYPE_LOCAL" \
    "HostName=$2" "Port=${3:-22}" \
    "User=${4:-admin}" "IdentityFile=${5:-$HOME/.ssh/id_rsa}"
}

## create new proxy ssh profile config
## @param $1 - [required] profile name
##        $2 - [required] command name
##        $4 - [optional] username
##        $5 - [optional] private key for authentication
kcs_conf_ssh_proxy() {
  __kcs_ssh_new_profile "$1" "$KCS_SSH_TYPE_PROXY" \
    "ProxyCommand=$2" \
    "User=${3:-admin}" "IdentityFile=${4:-$HOME/.ssh/id_rsa}"
}

## auto select ssh config (default mode)
kcs_conf_ssh_auto_mode() {
  kcs_debug "mode ssh" "using auto mode"
  __KCS_SSH_MODE="$KCS_SSH_MODE_AUTO"
  __KCS_SSH_TYPE=""
}

## use default ssh config
kcs_conf_ssh_default_mode() {
  kcs_debug "mode ssh" "using default mode"
  __KCS_SSH_MODE="$KCS_SSH_MODE_DEFAULT"
  __KCS_SSH_TYPE="$KCS_SSH_TYPE_DEFAULT"
}

## use custom local ssh config
kcs_conf_ssh_local_mode() {
  kcs_debug "mode ssh" "using local mode"
  __KCS_SSH_MODE="$KCS_SSH_MODE_LOCAL"
  __KCS_SSH_TYPE="$KCS_SSH_TYPE_LOCAL"
}

## use custom proxy ssh config
kcs_conf_ssh_proxy_mode() {
  kcs_debug "mode ssh" "using proxy mode"
  __KCS_SSH_MODE="$KCS_SSH_MODE_PROXY"
  __KCS_SSH_TYPE="$KCS_SSH_TYPE_PROXY"
}

## copy commands from /commands, and run on target profile
## @param $1 - [required] profile name
##        $2 - [required] commands to run
##        $n - [required] command arguments
kcs_ssh_cmd() {
  local name="$1"
  local cmd="$2"
  shift 2

  local args=("$@")
  _kcs_find_command \
    "__kcs_ssh_cmd" "__kcs_command_load_default" \
    "$cmd" "${args[@]}" "<>" "$name"
}
__kcs_ssh_cmd() {
  local ns="ssh-commander"
  local lbase="$1" lfile="$2" name="$3"
  local cmd="$lbase/$lfile"
  shift 3

  local args=("$@")
  kcs_debug "$ns" "running command '%s' with %d arguments" \
    "$lfile" "${#args[@]}"

  ## searching for required utils
  kcs_debug "$ns" "searching required utilities for '%s' command" \
    "$lfile"
  local ucmd="echo $__KCS_LOADED_UTILS" ucache
  ucache="$_KCS_SSH_CONFIG_DIR/.utils.txt"
  _KCS_ENTRY=command KCS_MODE=$_KCS_MODE_LIBRARY \
    bash -c "source '$cmd'; $ucmd 2>/dev/null >$ucache"

  ## packed scripts for send with single request
  ## package config
  local pbase
  pbase="$_KCS_SSH_CONFIG_DIR/pkg"
  local pu_raw pu_scope pu_value pu_path
  ## copy command
  mkdir -p "$pbase/commands"
  cp "$cmd" "$pbase/commands/$lfile"
  ## copy internal
  mkdir -p "$pbase/internal"
  cp -r "$_KCS_DIR_INTERNAL" "$pbase"
  ## copy utils
  mkdir -p "$pbase/utils"
  # shellcheck disable=SC2013
  for pu_raw in $(cat "$ucache"); do
    pu_scope="$(kcs_utils_get_scope "$pu_raw")"
    pu_value="$(kcs_utils_get_value "$pu_raw")"
    pu_path="$_KCS_DIR_UTILS/$pu_value"
    ## skip not found utils
    if ! test -f "$pu_path"; then
      kcs_warn "$ns" "utils '%s' not found on command '%s'" \
        "$pu_value" "$lfile"
      continue
    fi

    ## create scoped directory if exist
    test -n "$pu_scope" &&
      mkdir -p "$pbase/utils/$pu_scope"
    ## copy utils to packed output
    cp -r "$pu_path" "$pbase/utils/$pu_value"
  done

  ## server configuration
  local sbase="/tmp/${KCS_NAME:-kcs}"

  ## remove tmp if exist
  kcs_ssh "$name" -- rm -r "$sbase" 2>/dev/null
  kcs_ssh_copy_to "$name" \
    "$pbase:$sbase"

  ## execute command
  kcs_info "$ns" \
    "running command '%s' at %s" \
    "$lfile" "$name"
  cmd="$sbase/commands/$lfile"
  kcs_ssh "$name" -- "$cmd" "${args[@]}"
}

## works same as ssh on profile
## @param $1 - [required] profile name
##        $n - [optional] ssh options
##        -- - [optional] parameters separator between options and argument
##        $m - [optional] ssh arguments
## @return   - same as ssh command
## @exit     - same as ssh command
kcs_ssh() {
  local ns="ssh"
  local name="$1" ctype config
  ctype="$(__kcs_ssh_get_type "$name")"
  config="$(__kcs_ssh_get_config "$name" "$ctype")"
  shift

  kcs_info "$ns" "running on '%s' config type" "$ctype"

  ## -C => Requests compression of all data
  ## -T => Disable pseudo-terminal allocation
  local opts=("-CT") args=()
  ## Add config if it exist
  if test -n "$config"; then
    opts+=("-F" "$config")
  fi

  ## Parsing options and arguments
  local is_args
  for arg in "$@"; do
    kcs_debug "$ns" "checking input %s" "$arg"
    if test -z "$is_args"; then
      if [[ "$arg" == "--" ]]; then
        is_args=true
        continue
      fi
      kcs_debug "$ns" "add '%s' to option" "$arg"
      opts+=("$arg")
    else
      kcs_debug "$ns" "add '%s' to argument" "$arg"
      args+=("$arg")
    fi
  done

  ## Pass some script environment to server as well
  if [ "${#args[@]}" -gt 0 ]; then
    local d c
    test -n "$DEBUG" && d="DEBUG=$DEBUG "
    test -n "$LOG_LEVEL" && ll="LOG_LEVEL=$LOG_LEVEL "

    args[0]="$d$c$ll${args[0]}"
  fi

  kcs_debug "$ns" "options: %s" "${opts[*]}"
  kcs_debug "$ns" "arguments: %s" "${args[*]}"

  # shellcheck disable=SC2029
  kcs_exec ssh "${opts[@]}" \
    "$name" \
    "${args[@]}"
}

## copy file/folder from profile to local machine
## @param $1 - [required] profile name
##        $n - [required] file path (syntax=`<src>:<dest>`)
##             must use fullpath
## @return   - same as scp command
## @exit     - same as scp command
kcs_ssh_copy_from() {
  local ns="ssh-copier"
  local cmd="kcs_scp" name="$1"
  shift

  local raw src dest
  for raw in "$@"; do
    src="${raw%%:*}"
    dest="${raw#*:}"

    kcs_debug "$ns" "copying '%s' (%s) to '%s' (%s)" \
      "$src" "$name" "$dest" "local"
    "$cmd" "$name" "$name:$src" "$dest"
  done
}

## copy file/folder from local to profile server
## @param $1 - [required] profile name
##        $n - [required] file path (syntax=`<src>:<dest>`)
##             must use fullpath
## @return   - same as scp command
## @exit     - same as scp command
kcs_ssh_copy_to() {
  local ns="ssh-copier"
  local cmd="kcs_scp" name="$1"
  shift

  local raw src dest
  for raw in "$@"; do
    src="${raw%%:*}"
    dest="${raw#*:}"

    if test -f "$src" || test -d "$src"; then
      kcs_debug "$ns" "copying '%s' (%s) to '%s' (%s)" \
        "$src" "local" "$dest" "$name"
      "$cmd" "$name" "$src" "$name:$dest"
    else
      kcs_error "$ns" "file/folder not found at '%s'" \
        "$src"
    fi
  done
}

## works same as scp on profile
## @param $1 - [required] profile name
##        $n - [optional] scp arguments
## @return   - same as scp command
## @exit     - same as scp command
## @example  - kcs_scp "$server" "$server:/tmp/test" "$PWD/test"
##           - kcs_scp "$server" "$PWD/test" "$server:/tmp/test"
kcs_scp() {
  local ns="scp"
  local name="$1" ctype config
  ctype="$(__kcs_ssh_get_type "$name")"
  config="$(__kcs_ssh_get_config "$name" "$ctype")"
  shift

  ## -C => Requests compression of all data
  ## -T => Disable pseudo-terminal allocation
  local opts=("-CT" "-rq") args=("$@")
  if test -n "$config"; then
    opts+=("-F" "$config")
  fi

  kcs_debug "$ns" "options: %s" "${opts[*]}"
  kcs_debug "$ns" "arguments: %s" "${args[*]}"
  kcs_exec scp "${opts[@]}" "${args[@]}"
}

## get config type based on ssh mode
## @param $1 - [required] profile name
## @return   - ssh type
__kcs_ssh_get_type() {
  local name="$1"

  ## If cached exist, use cached type instead
  if test -n "$__KCS_SSH_TYPE"; then
    printf "%s" "$__KCS_SSH_TYPE"
    return 0
  fi

  case "$__KCS_SSH_MODE" in
  "$KCS_SSH_MODE_AUTO")
    if __kcs_ssh_can_connect "$name"; then
      __KCS_SSH_TYPE="$KCS_SSH_TYPE_LOCAL"
    elif __kcs_ssh_has_profile "$name" "$KCS_SSH_TYPE_PROXY"; then
      __KCS_SSH_TYPE="$KCS_SSH_TYPE_PROXY"
    else
      __KCS_SSH_TYPE="$KCS_SSH_TYPE_DEFAULT"
    fi
    __kcs_ssh_get_type "$name"
    ;;
  *)
    ## Save cached
    __KCS_SSH_TYPE="$__KCS_SSH_MODE"
    printf "%s" "$__KCS_SSH_MODE"
    ;;
  esac
}

## create new profile on config type
## @param $1 - [required] profile name
##        $2 - [required] config type
##        $n - [required] '<key>=<value>' config key-value
__kcs_ssh_new_profile() {
  local ns="ssh-profiler"
  local name="${1:?}" ctype="$2" config
  config="$(__kcs_ssh_get_config "$name" "$ctype")"
  shift 2

  ## Duplicated profile name, Reuse the configuration
  if test -f "$config"; then
    kcs_debug "$ns" \
      "profile %s has been created, reuse them" "$name"
    return 0
  fi

  local content="Host $name"
  local raw key value
  for raw in "$@"; do
    key="${raw%%=*}"
    value="${raw#*=}"
    content="$content
      $key $value"
  done

  kcs_debug "$ns" "create new profile at '%s'" \
    "$config"
  printf "%s\n" "$content" >>"$config"
}

## check if local profile is connectable
## @param $1 - [required] profile name
## @return   - zero if profile is connectable; otherwise, return 1
__kcs_ssh_can_connect() {
  local name="$1" hostname port
  hostname="$(__kcs_ssh_search_config "$name" "$KCS_SSH_TYPE_LOCAL" "HostName")"
  port="$(__kcs_ssh_search_config "$name" "$KCS_SSH_TYPE_LOCAL" "Port")"

  ## No config found, meaning cannot connect
  if test -z "$hostname" || test -z "$port"; then
    return 1
  fi

  local cmd="nc" args=()
  ## set mode
  args+=("-z")
  ## set timeout
  args+=("-w" "1" "-H" "1" "-J" "1" "-G" "1")
  ## set arguments
  args+=("$hostname" "$port")
  ## Only tested on MacOS
  "$cmd" "${args[@]}" 2>/dev/null
}

## search config value from input key
## @param $1 - [required] profile key
##        $2 - [required] config type
##        $3 - [required] search key
__kcs_ssh_search_config() {
  local name="$1" ctype="$2"
  local config search="$3"
  config="$(__kcs_ssh_get_config "$name" "$ctype")"
  if test -f "$config"; then
    result="$(grep -io "$search [^,]*" "$config")"
    printf "%s" "${result#* }"
  fi

  return 1
}

## get config path
## @param $1 - [required] profile name
##        $2 - [required] config type
## @return   - single line string as config full path
##           - or empty string if use default config
__kcs_ssh_get_config() {
  local name="$1" ctype="$2"
  case "$ctype" in
  "$KCS_SSH_TYPE_DEFAULT")
    printf ""
    ;;
  *)
    printf "%s/%s" "$_KCS_SSH_CONFIG_DIR" "$ctype-$name.conf"
    ;;
  esac
}

## check is input profile created
## @param $1 - [required] profile name
##        $2 - [required] config type
## @return   - zero if profile exist; otherwise, return 1
__kcs_ssh_has_profile() {
  local name="$1" ctype="$2" config
  config="$(__kcs_ssh_get_config "$name" "$ctype")"
  test -f "$config" && grep -q "Host $name" "$config"
}

# --------------------------------------------------------

## ssh setup hook
kcs_add_hook \
  post_init __kcs_ssh_setup
__kcs_ssh_setup() {
  if test -d "$_KCS_SSH_CONFIG_DIR"; then
    rm -r "$_KCS_SSH_CONFIG_DIR"
  fi
  ## Create new ssh config directory
  mkdir -p "$_KCS_SSH_CONFIG_DIR"
}

## ssh cleaning hook
kcs_add_hook \
  clean __kcs_ssh_clean
__kcs_ssh_clean() {
  unset _KCS_SSH_CONFIG_DIR \
    __KCS_SSH_MODE \
    KCS_SSH_MODE_AUTO \
    KCS_SSH_MODE_DEFAULT \
    KCS_SSH_MODE_LOCAL \
    KCS_SSH_MODE_PROXY \
    __KCS_SSH_TYPE \
    KCS_SSH_TYPE_DEFAULT \
    KCS_SSH_TYPE_LOCAL \
    KCS_SSH_TYPE_PROXY
}
