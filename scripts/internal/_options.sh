#!/usr/bin/env bash
## Options

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

__kcs_parse_options() {
  while getopts "$__KCS_GLOBAL_OPTS$KCS_OPTIONS" flag; do
    case "${flag}" in
    h) kcs_get_help ;;
    v) kcs_get_version ;;
    Q) __kcs_set_silent_mode ;;
    D) __kcs_set_debug_mode ;;
    R) __kcs_set_dry_run ;;
    L) __kcs_set_log_level "$OPTARG" ;;
    K) kcs_disable_hook "$OPTARG" ;;
    -)
      NEXT="${!OPTIND}"
      __kcs_parse_long_option "$NEXT"

      case "${OPTARG}" in
      help)
        kcs_no_argument "$LONG_OPTARG"
        kcs_get_help
        ;;
      version)
        kcs_no_argument "$LONG_OPTARG"
        kcs_get_version
        ;;
      dry-run)
        kcs_no_argument "$LONG_OPTARG"
        __kcs_set_dry_run
        ;;
      silent)
        kcs_no_argument "$LONG_OPTARG"
        __kcs_set_silent_mode
        ;;
      debug)
        kcs_no_argument "$LONG_OPTARG"
        __kcs_set_debug_mode
        ;;
      log-level)
        kcs_require_argument "$LONG_OPTARG"
        __kcs_set_log_level "$LONG_OPTVAL"
        ;;
      disable-hook)
        kcs_require_argument "$LONG_OPTARG"
        kcs_disable_hook "$LONG_OPTVAL"
        ;;
      *)
        __kcs_parse_addition_options "$LONG_OPTARG" "$LONG_OPTVAL"
        ;;
      esac
      ;;
    ?)
      __kcs_parse_addition_options "$flag" "$OPTARG"
      ;;
    *)
      __kcs_parse_addition_options "$flag" "$OPTARG"
      ;;
    esac
  done

  shift $((OPTIND - 1))
  export KCS_COMMANDS=("$@")
}

__kcs_parse_addition_options() {
  local flag="$1" value="$2" cmd="__kcs_main_option"
  if command -v "$cmd" >/dev/null; then
    if "$cmd" "$flag" "$value"; then
      return 0
    fi
  fi

  # because optspec is assigned by 'getopts' command
  # shellcheck disable=SC2154
  if [ "$OPTERR" == 1 ] && [ "${optspec:0:1}" != ":" ]; then
    printf "Unexpected option '%s', run --help for more information" "$flag" >&2
    exit 10
  fi
}

__KCS_GLOBAL_OPTS="hvQDRL:K:?-:"
__KCS_GLOBAL_HELP="
Global options:
  [--mode,-M]
      - set mode (default=default)
  [--help,-h]
      - show this message for help
  [--version,-v]
      - show script version
  [--silent,-q]
      - set log level to silent
  [--debug,-d]
      - set log level to debug
  [--log-level,-l] <0-4>
      - set log level (0=silent, 5=debug)
      - this handle on init hook
  [--dry-run]
      - dry run mode will print only hook action
      - this for debugging only
  [--disable-hook,-k] <name>
      - disable hook name (support post_options or later)
        - post_options:temp - temp setup before used
        - pre_clean:temp - temp cleanup after used
  [--] <args>
      - pass additional arguments to scripts
Environments:
  \$DEBUG
      - set to non-empty string will enabled debug mode
      - debug mode will print more detail than debug log.
  \$LOG_LEVEL
      - set to 0 - 5 same as --log-level option.
      - this handle on pre_init hook
  \$DRY_RUN
      - set to non-empty string will enabled dry-run mode
"
