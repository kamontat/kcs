#!/usr/bin/env bash

## Hook Registry:
##   all hooks should be registered on this file

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

_kcs_register_hooks() {
  kcs_add_hook pre_init \
    __kcs_logger_pre_init
  kcs_add_hook pre_init \
    __kcs_set_alias:@optional,@cb=__kcs_main_alias,@raw
  kcs_add_hook pre_init \
    __kcs_main_hook:@optional

  kcs_add_hook init \
    __kcs_utils_init:@optional,@cb=__kcs_main_init_utils,@args=KCS_INIT_UTILS
  kcs_add_hook init \
    __kcs_set_name:@optional,@cb=__kcs_main_name
  kcs_add_hook init \
    __kcs_set_version:@optional,@cb=__kcs_main_version
  kcs_add_hook init \
    __kcs_set_options:@optional,@cb=__kcs_main_option_keys
  kcs_add_hook init \
    __kcs_set_description:@optional,@cb=__kcs_main_description
  kcs_add_hook init \
    __kcs_set_help:@optional,@cb=__kcs_main_help

  kcs_add_hook post_init \
    __kcs_utils_check:@optional
  kcs_add_hook post_init \
    __kcs_init_check:@optional
  kcs_add_hook post_init \
    __kcs_main_init:@optional,@raw

  kcs_add_hook pre_load \
    __kcs_mode_load
  kcs_add_hook pre_load \
    __kcs_parse_options:@optional,@raw

  kcs_add_hook load \
    __kcs_utils_init:@optional,@cb=__kcs_main_utils,@args=KCS_UTILS

  kcs_add_hook post_load \
    __kcs_utils_check:@optional
  kcs_add_hook post_load \
    __kcs_load_check:@optional

  kcs_add_hook pre_main \
    __kcs_default_config:@optional
  kcs_add_hook pre_main \
    __kcs_main_config:@optional
  kcs_add_hook pre_main \
    __kcs_main_check:@optional

  kcs_add_hook main \
    __kcs_main:@raw

  kcs_add_hook clean \
    __kcs_error_clean
  kcs_add_hook clean \
    __kcs_options_clean
  kcs_add_hook clean \
    __kcs_mode_clean
  kcs_add_hook clean \
    __kcs_main_clean:@optional

  kcs_add_hook post_clean \
    __kcs_logger_clean
  kcs_add_hook post_clean \
    __kcs_utils_clean
}

__kcs_required_hook() {
  kcs_throw "$@"
}

__kcs_optional_hook() {
  shift 1
  kcs_debug "$@"

  return 0
}
