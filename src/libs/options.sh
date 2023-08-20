#!/usr/bin/env bash

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

## The definition consist of '|<OPTIONS>|:<VARNAME>:<TYPE>:[DEFAULT]:[DESC]'
## <OPTIONS> - (required) All possible options separated by '|'
## <VARNAME> - (required) UPPER option name
## <TYPE>    - (required) The value type `_KCS_OPTIONS_VTYPE_*`
## [DEFAULT] - (optional) Default value if user didn't enter the options
## [DESC]    - (optional) Option description when user would like some help

## No argument
export _KCS_OPTIONS_ATYPE_NO_VALUE='NV'
## Require string argument
export _KCS_OPTIONS_ATYPE_STR_REQ='RS'
## Optional string argument
export _KCS_OPTIONS_ATYPE_STR_OPT='OS'

_kcs_options_is_arg() {
  ! [[ "$1" =~ ^- ]]
}

_kcs_options_is_short_opt() {
  [[ "$1" =~ ^-[^-] ]]
}

_kcs_options_is_long_opt() {
  [[ "$1" =~ ^-- ]]
}

__kcs_options_lc_init() {
  local ns="init.options"

  if ! kcs_ld_lib_is_loaded 'hooks'; then
    kcs_log_error "$ns" "options is requires 'hooks' to be loaded"
    return 1
  fi
  if [ "$#" -lt 1 ]; then
    kcs_log_error "$ns" "options lib is required at least 1 argument"
    return 1
  fi

  local cache
  cache="$(__kcs_options_def_cache "${_KCS_CMD_NAME:?}")"
  if test -f "$cache"; then
    kcs_log_debug "$ns" "reuse definitions from cache file '%s'" "$cache"
    output="$(cat "$cache")"
  else
    ## "<options> [atype]; <VAR> [desc]" where
    ## - options = array separated by '|'
    ## - atype   = argument type; there are 3 options omit, [type], or <type>
    ##           = where type is argument data type and [] is optional and <> is required
    ## - VAR     = is upper variable string
    ## - desc    = option description
    local input first second definition output
    local options atype default variable desc
    # local arg key raw options atype output
    for input in "$@"; do
      first="${input%%;*}"
      second="${input#*; }"

      options="${first%% *}"
      atype="${first#* }"
      if [[ "$options" == "$atype" ]]; then
        atype="$_KCS_OPTIONS_ATYPE_NO_VALUE"
      else
        local optional_atype required_atype
        optional_atype="$(echo "$atype" | sed -En 's/.*\[(.*)\].*$/\1/p')"
        required_atype="$(echo "$atype" | sed -En 's/.*\<(.*)\>.*$/\1/p')"
        if test -z "$optional_atype" && test -z "$required_atype"; then
          kcs_log_error "$ns" "invalid option argument type ('%s')" "$atype"
          return 1
        fi

        local prefix key name
        atype="${required_atype:-$optional_atype}"
        key="${atype%%:*}"
        default="${atype#*:}"
        [[ "$key" == "$default" ]] && default=""

        test -n "$optional_atype" && prefix="O"
        test -n "$required_atype" && prefix="R"
        name="$(echo "${key:0:1}" | tr '[:lower:]' '[:upper:]')"
        atype="$prefix$name"
      fi

      variable="${second%% *}"
      desc="${second#* }"
      [[ "$variable" == "$desc" ]] && desc=""

      kcs_log_debug "$ns" "parsing input option string '%s'" "$input"
      kcs_log_debug "$ns" "possible option list: %s" "$options"
      kcs_log_debug "$ns" "variable name: %s" "$variable"
      kcs_log_debug "$ns" "option description: %s" "$desc"
      kcs_log_debug "$ns" "argument type: %s" "$atype"
      kcs_log_debug "$ns" "argument default value: %s" "$default"

      local default_esc desc_esc
      default_esc="$(__kcs_options_escape "$default")"
      desc_esc="$(__kcs_options_escape "$desc")"
      definition="|$options|:$variable:$atype:$default_esc:$desc_esc;"
      kcs_log_debug "$ns" "create option definition: %s" "$definition"

      output="$output$definition"
    done

    kcs_log_debug "$ns" "caching definitions output at '%s'" "$cache"
    echo "$output" >"$cache"
  fi

  kcs_ld_lib information
  kcs_hooks_add post_init options @raw "@rawargs=$output"
  kcs_hooks_add post_clean options
}

__kcs_options_hook_init() {
  kcs_argument __kcs_options_hook_init_internal "$@"
}
__kcs_options_hook_init_internal() {
  local ns="hook-init.options"
  # shellcheck disable=SC2206
  local definitions="$1" code=0
  shift 2

  kcs_log_debug "$ns" "options definition: %s" "$definitions"

  local raw next inputs=("$@") output=()
  local def opt option arg
  for ((i = 0; i < ${#inputs[@]}; i++)); do
    raw="${inputs[$i]}"
    if _kcs_options_is_arg "$raw"; then
      kcs_log_debug "$ns" "move '%s' to final list as args" "$raw"
      output+=("$raw")
      continue
    fi

    ## inline mode is when argument inline in long option using equal sign (=)
    local inline=false
    next="${inputs[$((i + 1))]}"
    if _kcs_options_is_short_opt "$raw"; then
      opt="${raw:1}"
      local short_option_size="${#opt}"
      for ((j = 0; j < short_option_size; j++)); do
        option="-${opt:$j:1}"
        ## Only parse next argument on last option in short options list
        [ "$((j + 1))" -eq "$short_option_size" ] &&
          _kcs_options_is_arg "$next" && arg="$next"

        kcs_log_debug "$ns" "parsing short options '%s'" "$option"

        def="$(__kcs_options_def_find "$definitions" "$option")"
        ! __kcs_options_check_warn "$def" "$option" "$arg" && continue
        ! __kcs_options_check_error "$def" "$option" "$arg" &&
          ((code++)) &&
          continue
        __kcs_options_check_arg "$def" "$option" "$arg" "$inline" && ((i++))
        ! __kcs_options_export "$def" "$option" "$arg" &&
          ((code++)) &&
          continue
      done
      continue
    fi

    if _kcs_options_is_long_opt "$raw"; then
      option="${raw%%=*}"
      ## Parse inline argument
      local raw_arg="${raw#*=}"
      [[ "$raw_arg" != "$option" ]] && arg="$raw_arg" && inline=true
      ## Parse next argument
      _kcs_options_is_arg "$next" && test -z "$arg" && arg="$next"

      kcs_log_debug "$ns" "parsing long options '%s'" "$option"

      def="$(__kcs_options_def_find "$definitions" "$option")"
      ! __kcs_options_check_warn "$def" "$option" "$arg" && continue
      ! __kcs_options_check_error "$def" "$option" "$arg" &&
        ((code++)) &&
        continue
      __kcs_options_check_arg "$def" "$option" "$arg" "$inline" && ((i++))
      ! __kcs_options_export "$def" "$option" "$arg" &&
        ((code++)) &&
        continue
      continue
    fi

    kcs_log_warn "$ns" "unknown argument syntax (%s)" "$raw"
  done

  export _KCS_CMD_ARGS
  _KCS_CMD_ARGS=("${output[@]}")
  return "$code"
}

__kcs_options_hook_clean() {
  unset _KCS_OPTIONS_VTYPE_NO_VALUE
  unset _KCS_OPTIONS_VTYPE_REQ_STR _KCS_OPTIONS_VTYPE_OPT_STR
}

## find definition from input key
## usage: `__kcs_options_def_find '|h|help|:HELP:NV' h`
__kcs_options_def_find() {
  local definitions="$1" key="$2"
  echo "$definitions" | grep -Eo "\|$key\|[^;]+"
}

## verify definitions with option and next value (warn mode)
## usage: `__kcs_options_def_check_warn '|h|help|:HELP:NV' [option] [arg]`
__kcs_options_check_warn() {
  local ns="checker.options"
  local def="$1" option="$2" arg="$3"

  test -z "$def" &&
    kcs_log_warn "$ns" "unknown option '%s'" "$option" &&
    return 1

  return 0
}
## verify definitions with current and next value (error mode)
## usage: `__kcs_options_def_check_error '|h|help|:HELP:NV' [option] [arg]`
__kcs_options_check_error() {
  local ns="checker.options"
  local def="$1" option="$2" arg="$3" atype
  atype="$(__kcs_options_def_atype "$def")"

  ## Option must contains argument
  [[ "${atype:0:1}" == "R" ]] && test -z "$arg" &&
    kcs_log_error "$ns" "option '%s' requires argument" \
      "$(__kcs_options_def_options "$def")" &&
    return 1
  ## Option must NOT contains argument
  # [[ "${atype:0:1}" == "N" ]] && test -n "$arg" &&
  #   kcs_log_error "$ns" "option '%s' requires NO argument" \
  #     "$(__kcs_options_def_options "$def")" &&
  #   return 1

  return 0
}

## check is option consume argument or not
__kcs_options_check_arg() {
  local ns="checker.options"
  local def="$1" option="$2" arg="$3" inline="$4" atype
  atype="$(__kcs_options_def_atype "$def")"

  if "$inline"; then
    kcs_log_debug "$ns" "inline mode; never parse argument for '%s'" "$option"
    return 1
  fi
  if [[ "${atype:0:1}" == "N" ]]; then
    kcs_log_debug "$ns" "option '%s' is no argument type" "$option"
    return 1
  fi
  if test -z "$arg"; then
    kcs_log_debug "$ns" "option '%s' not provide any argument" "$option"
    return 1
  fi

  kcs_log_debug "$ns" "convert next input to option argument (%s)" "$arg"
  return 0
}

## export option value
__kcs_options_export() {
  local ns="export.options"
  local def="$1" option="$2" arg="$3"

  local name atype
  name="$(__kcs_options_def_name "$def")"
  atype="$(__kcs_options_def_atype "$def")"

  test -z "$name" &&
    kcs_log_error "$ns" "option '%s' is missing variable name (%s)" \
      "$option" "$def" &&
    return 1

  local var="_KCS_OPT_${name}_VALUE"

  if [[ "${atype:0:1}" == "N" ]]; then
    kcs_log_debug "$ns" "assign argument of NV to 'true'"
    arg="true"
  fi

  if [[ "${atype:0:1}" == "O" ]] && test -z "$arg"; then
    local default
    default="$(__kcs_options_def_default "$def")"
    kcs_log_debug "$ns" "assign '%s' as default argument to option '%s'" \
      "$default" "$option"
    arg="$default"
  fi

  kcs_log_debug "$ns" "export '%s'='%s'" "$var" "$arg"
  export "$var"="$arg"
}

## get definition possible options
## usage: `__kcs_options_def_options '|h|help|:HELP:NV'`
__kcs_options_def_options() {
  __kcs_options_def_get "$1" 0
}
## get definition variable name
## usage: `__kcs_options_def_name '|h|help|:HELP:NV'`
__kcs_options_def_name() {
  __kcs_options_def_get "$1" 1
}
## get definition value type
## usage: `__kcs_options_def_atype '|h|help|:HELP:NV'`
__kcs_options_def_atype() {
  __kcs_options_def_get "$1" 2
}
## get definition default value
## usage: `__kcs_options_def_default '|h|help|:HELP:NV:null'`
__kcs_options_def_default() {
  __kcs_options_def_get "$1" 3
}
## get definition description
## usage: `__kcs_options_def_desc '|h|help|:HELP:NV:null:show message'`
__kcs_options_def_desc() {
  __kcs_options_def_get "$1" 4
}
__kcs_options_def_get() {
  local ns="parser.def.options"
  # shellcheck disable=SC2207
  local array=($(echo "$1" | tr ':' '\n')) index="$2"
  if [ ${#array[@]} -lt 3 ] || [ ${#array[@]} -gt 5 ]; then
    kcs_log_warn "$ns" "cannot parse definition '%s' (expected 3 <= %d <= 5)" \
      "$1" "${#array[@]}"
    return 1
  fi

  if [ ${#array[@]} -eq 3 ] ||
    [ ${#array[@]} -eq 4 ] ||
    [ ${#array[@]} -eq 5 ]; then
    local value="${array[$index]}"
    printf "%s" "$(__kcs_options_unescape "$value")"
    return 0
  fi

  return 1
}

## create and get definition cache filepath
## usage: `__kcs_options_def_cache`
__kcs_options_def_cache() {
  local dir
  dir="$(kcs_tmp_create_dir 'libs-options')"
  printf "%s" "$dir/$1-definitions.txt"
}

## Input string and return escape string
## usage: `__kcs_options_escape 'hello world'`
__kcs_options_escape() {
  local input="$1"
  input="${input// /(=space=)}"
  input="${input//:/(=colon=)}"
  input="${input//;/(=semi=)}"
  printf "%s" "$input"
}

## Input escape string and return normal string
## usage: `__kcs_options_unescape 'hello[space]world'`
__kcs_options_unescape() {
  local input="$1"
  input="${input//\(=space=\)/ }"
  input="${input//\(=colon=\)/:}"
  input="${input//\(=semi=\)/;}"
  printf "%s" "$input"
}

################################################################################

# TODO: Add --version and --help as default options
# TODO: find way to customize extra arguments

## @param $1 - boolean for requires argument or
##           - requires no argument
##        $2 - options flag value
## @example  - kcs_opt_arg true "$flag"
##           - kcs_opt_arg false "$flag"
kcs_opt_arg() {
  local has_args="$1"
  ## If short options, ignored
  [ ${#2} -le 1 ] && return 0
  ## Check require argument
  "$has_args" && test -z "$LONG_OPTVAL" &&
    kcs_exit 1 "option '%s' requires argument" "$LONG_OPTARG" &&
    return 1
  ## Check no argument
  ! "$has_args" && test -n "$LONG_OPTVAL" && ! [[ "$LONG_OPTVAL" =~ "-" ]] &&
    kcs_exit 1 "option '%s' should not provides argument" "$LONG_OPTARG" &&
    return 1
  ## If not require argument, move opt index back
  ! "$has_args" && ((OPTIND--))
}