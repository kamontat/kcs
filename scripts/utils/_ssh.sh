#!/usr/bin/env bash
##utils-example:v1.0.0-beta.1

## SSH wrapper:
##   work same with ssh, but support custom config
## Requirement:
##   - temp: create temporary directory
## Public functions:
##   `kcs_conf_ssh_local <p> <ip> <port> <u> <pem>` - create new ssh profile
##   `kcs_conf_ssh_proxy <p> <px> <u> <pem>` - create new ssh proxy profile
##   `kcs_ssh_force_local` - force ssh to use local config
##   `kcs_ssh_force_proxy` - force ssh to use proxy config
##   `kcs_ssh <p> <opts...> -- <args...>` - works same as ssh on profile
##   `kcs_ssh_cmd <p> <cmd>` - execute command on profile
##   `kcs_ssh_copy_from <p> <args...>` - copy file/folder from profile
##   `kcs_ssh_copy_to <p> <args...>` - copy file/folder to profile

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

export __KCS_SSH_CONFIG_DIR="$_KCS_DIR_TEMP/ssh"
export __KCS_SSH_LOCAL_CONFIG="$__KCS_SSH_CONFIG_DIR/local.conf"
export __KCS_SSH_PROXY_CONFIG="$__KCS_SSH_CONFIG_DIR/proxy.conf"

## Auto resolve
export __KCS_SSH_CONFIG=""

## create ssh profile to custom config
## @param $1 - [required] profile name
##        $2 - [required] hostname
##        $3 - [optional] port number
##        $4 - [optional] username
##        $5 - [optional] private key for authentication
kcs_conf_ssh_local() {
  __kcs_ssh_new_profile "$1" "$__KCS_SSH_LOCAL_CONFIG" \
    "HostName=$2" "Port=${3:-22}" \
    "User=${4:-admin}" "IdentityFile=${5:-$HOME/.ssh/id_rsa}"
}

## create ssh profile to custom config
## @param $1 - [required] profile name
##        $2 - [required] proxy command
##        $3 - [optional] username
##        $4 - [optional] private key for authentication
kcs_conf_ssh_proxy() {
  __kcs_ssh_new_profile "$1" "$__KCS_SSH_PROXY_CONFIG" \
    "ProxyCommand=$2" \
    "User=${3:-admin}" "IdentityFile=${4:-$HOME/.ssh/id_rsa}"
}

## force ssh to use local config
kcs_ssh_force_local() {
  __KCS_SSH_CONFIG="$__KCS_SSH_LOCAL_CONFIG"
}

## force ssh to use proxy config
kcs_ssh_force_proxy() {
  __KCS_SSH_CONFIG="$__KCS_SSH_PROXY_CONFIG"
}

## works same as ssh on profile
## @param $1 - [required] profile name
##        $2 - [optional] config path
##        $n - [optional] ssh options
##        -- - [optional] parameters separator between options and argument
##        $m - [optional] ssh arguments
## @return   - same as ssh command
## @exit     - same as ssh command
kcs_ssh() {
  local name="$1"
  shift

  __kcs_ssh "$name" "$__KCS_SSH_CONFIG" \
    "$@"
}

## works same as ssh on profile
## @param $1 - [required] profile name
##        $2 - [optional] config path
##        $n - [optional] ssh options
##        -- - [optional] parameters separator between options and argument
##        $m - [optional] ssh arguments
## @return   - same as ssh command
## @exit     - same as ssh command
__kcs_ssh() {
  local ns="ssh"
  local name="$1" config="$2"
  shift 2

  ## -C => Requests compression of all data
  ## -T => Disable pseudo-terminal allocation
  local opts=("-CT") args=()
  ## Add config if it has valid profile
  if __kcs_ssh_has_profile "$name" "$config"; then
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

## check is input profile created
## @param $1 - [required] profile name
##        $2 - [required] config path
## @return   - zero if profile exist; otherwise, return 1
__kcs_ssh_has_profile() {
  local name="$1" config="$2"
  test -f "$config" && grep -q "Host $name" "$config"
}

## write profile to ssh config
## @param $1 - [required] profile name
##        $n - [required] '<name>=<value>' where name must be valid SSH Config
__kcs_ssh_new_profile() {
  local ns="profile ssh" name="$1" profile="$2"
  shift 2

  ## Duplicated profile name, Reuse what we had
  if __kcs_ssh_has_profile "$name" "$profile"; then
    kcs_warn "$ns" \
      "profile %s has been created, reuse them" "$name"
    return 0
  fi

  local output="Host $name"

  local raw key value
  for raw in "$@"; do
    key="${raw%%=*}"
    value="${raw#*=}"
    output="$output
    $key $value"
  done

  kcs_debug "$ns" "create ssh profile name '%s' at %s" \
    "$name" "$profile"
  printf "%s\n" "$output" >>"$profile"
}

## ssh check hook
kcs_add_hook \
  check __kcs_ssh_check
__kcs_ssh_check() {
  kcs_utils_required "ssh" \
    "temp"
}

## ssh setup hook
kcs_add_hook \
  post_init __kcs_ssh_setup
__kcs_ssh_setup() {
  if test -d "$__KCS_SSH_CONFIG_DIR"; then
    rm -r "$__KCS_SSH_CONFIG_DIR"
  fi

  ## Create new ssh config directory
  mkdir -p "$__KCS_SSH_CONFIG_DIR"
}

## ssh cleaning hook
kcs_add_hook \
  clean __kcs_ssh_clean
__kcs_ssh_clean() {
  unset __KCS_SSH_CONFIG_DIR \
    __KCS_SSH_LOCAL_CONFIG \
    __KCS_SSH_PROXY_CONFIG \
    __KCS_SSH_CONFIG
}
