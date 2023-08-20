#!/usr/bin/env bash

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

main() {
  kct_autodiscovery 'enabled' "$KCT_PATH_TESTDIR"

  kct_case echo_without_debug \
    echo
  DEBUG=kcs \
    kct_case echo_with_debug \
    echo
  DEBUG=kcs:do.loader \
    kct_case echo_with_namespace_debug \
    echo
  DEBUG=kcs:add.hooks,runner.hooks \
    kct_case echo_with_namespaces_debug \
    echo

  DEBUG=kcs \
    kct_case empty_ignore_option \
    empty hello --help --example -t

  KCS_LOGLVL=error \
    kct_case loggings_only_error \
    loggings
  KCS_LOGLVL=warn,i \
    kct_case loggings_multiple_levels \
    loggings
  KCS_LOGLVL=silent \
    kct_case loggings_silent \
    loggings

  kct_case arguments_default \
    arguments a b c
  kct_case arguments_with_extra \
    arguments a b c -- hello world
  kct_case arguments_with_raw \
    arguments a b c '<>' hello world
  kct_case arguments_with_raw_and_extra \
    arguments a b c '<>' hello -- extra argument
  kct_case arguments_with_extra_and_raw \
    arguments a b c -- hello '<>' raw argument

  KCS_CMDSEP='-' \
    kct_case new_cmd_sep \
    _newsep test
  KCS_CMDDEF='_empty' \
    kct_case new_cmd_default \
    invalid

  DEBUG=kcs kct_case nested_cmd_name \
    _nested

  DEBUG=kcs:options kct_case option_single_long \
    _options --flower
  DEBUG=kcs:options kct_case option_single_short \
    _options -l
  DEBUG=kcs:options kct_case option_with_cmd \
    _options hello -l world
  DEBUG=kcs:options kct_case option_merge_short_options \
    _options -lf
  DEBUG=kcs:options kct_case option_long_with_arg \
    _options --sky 'blue'
  DEBUG=kcs:options kct_case option_long_with_equal_arg \
    _options --rock=water
  DEBUG=kcs:options kct_case option_long_with_default_arg \
    _options -r
  DEBUG=kcs:options kct_case option_short_require_arg \
    _options -s
}

kct_case() {
  local name="$1"
  shift

  if test -n "$_KCT_CASES" && ! [[ "$_KCT_CASES" =~ $name ]]; then
    _kct_run_ignore "$name" "$@"
    return
  fi

  if _kct_mode_snap; then
    _kct_run_snapshot "$name" "" "$@"
  elif _kct_mode_verify; then
    _kct_run_verify "$name" "$@"
  else
    _kct_run_invalid "$name" "$@"
  fi
}

kct_autodiscovery() {
  local status="$1" dirpath="$2"

  if [[ "$status" != "enabled" ]]; then
    return 0
  fi

  local path name args=()
  for path in "$dirpath/commands"/*.sh; do
    name="$(basename "$path")"
    [[ "$name" =~ ^_ ]] && continue
    name="${name//\.sh/}"
    # shellcheck disable=SC2206
    args=(${name//__/})

    DEBUG=kcs kct_case "$name" "${args[@]}"
  done
}

_kct_run_snapshot() {
  local name="$1"
  local dirpath="${2:-${KCT_PATH_SNAPDIR:?}/$name}"
  shift 2

  test -d "$dirpath" && rm -r "$dirpath"
  mkdir -p "$dirpath"

  local stdout="$dirpath/$KCT_SNAPSHOT_STDOUT"
  test -f "$stdout" || touch "$stdout"

  local stderr="$dirpath/$KCT_SNAPSHOT_STDERR"
  test -f "$stderr" || touch "$stderr"

  local stdlog="$dirpath/$KCT_SNAPSHOT_STDLOG"
  test -f "$stdlog" || touch "$stdlog"

  KCS_LOGOUT="$stdlog" _kct_exec_kcs "$@" >"$stdout" 2>"$stderr"
  if [[ "$dirpath" =~ ^$KCT_PATH_SNAPDIR ]]; then
    _kct_result_save "$name" "$KCT_STATUS_COMPLETED" "updated snapshot"
  fi
}
_kct_run_verify() {
  local name="$1"
  shift

  local dirpath="$KCT_PATH_SNAPDIR/$name"
  ! test -d "$dirpath" &&
    _kct_result_save "$name" "$KCT_STATUS_FAILED" "missing snapshot" &&
    return 0

  local tmpdir
  tmpdir="$(_kct_tmp_new_dir "$name")"

  _kct_run_snapshot "$name" "$tmpdir" "$@"

  local is_match_err=false is_match_out=false is_match_log=false
  _kct_diff_check \
    "$dirpath/$KCT_SNAPSHOT_STDERR" "$tmpdir/$KCT_SNAPSHOT_STDERR" &&
    is_match_err=true
  _kct_diff_check \
    "$dirpath/$KCT_SNAPSHOT_STDOUT" "$tmpdir/$KCT_SNAPSHOT_STDOUT" &&
    is_match_out=true
  _kct_diff_check \
    "$dirpath/$KCT_SNAPSHOT_STDLOG" "$tmpdir/$KCT_SNAPSHOT_STDLOG" &&
    is_match_log=true

  if "$is_match_err" && "$is_match_out" && "$is_match_log"; then
    _kct_result_save "$name" "$KCT_STATUS_PASSED"
    return 0
  fi

  local diff_dir
  diff_dir="$KCT_PATH_REPORTDIR/$name"
  test -d "$diff_dir" || mkdir -p "$diff_dir"

  local message_args=()
  ! "$is_match_err" &&
    _kct_diff_create \
      "$dirpath/$KCT_SNAPSHOT_STDERR" \
      "$tmpdir/$KCT_SNAPSHOT_STDERR" \
      "$diff_dir/$KCT_SNAPSHOT_STDERR.diff" &&
    message_args+=(STDERR)
  ! "$is_match_out" &&
    _kct_diff_create \
      "$dirpath/$KCT_SNAPSHOT_STDOUT" \
      "$tmpdir/$KCT_SNAPSHOT_STDOUT" \
      "$diff_dir/$KCT_SNAPSHOT_STDOUT.diff" &&
    message_args+=(STDOUT)
  ! "$is_match_log" &&
    _kct_diff_create \
      "$dirpath/$KCT_SNAPSHOT_STDLOG" \
      "$tmpdir/$KCT_SNAPSHOT_STDLOG" \
      "$diff_dir/$KCT_SNAPSHOT_STDLOG.diff" &&
    message_args+=(STDLOG)
  local message="[${message_args[*]}] is not matched"

  _kct_result_save "$name" "$KCT_STATUS_FAILED" "$message"
  return 0
}
_kct_run_invalid() {
  local err='invalid mode'
  _kct_result_save "$1" "$KCT_STATUS_INVALID" "$err"

  printf '%s\n' "$err" >&2
  exit 1
}
_kct_run_ignore() {
  local err='filtered out cases'
  _kct_result_save "$1" "$KCT_STATUS_IGNORED" "$err"
}

_kct_mode_snap() {
  [[ "$KCT_MODE" == "snapshot" ]] ||
    [[ "$KCT_MODE" == "snap" ]] ||
    [[ "$KCT_MODE" == "shot" ]] ||
    [[ "$KCT_MODE" == "ss" ]] ||
    [[ "$KCT_MODE" == "s" ]]
}
_kct_mode_verify() {
  test -z "$KCT_MODE" ||
    [[ "$KCT_MODE" == "validation" ]] ||
    [[ "$KCT_MODE" == "validate" ]] ||
    [[ "$KCT_MODE" == "verify" ]] ||
    [[ "$KCT_MODE" == "v" ]]
}

_kct_diff_check() {
  local expected="$1" actual="$2"
  diff -q "$expected" "$actual" >/dev/null
}
_kct_diff_create() {
  local expected="$1" actual="$2" output="$3"
  diff --new-file --suppress-common-lines \
    --ignore-space-change --ignore-case \
    --unified "$expected" "$actual" >"$output"
  return 0
}

_kct_result_save() {
  local filepath="$KCT_PATH_REPORTDIR/status.csv"
  local name="$1" status="$2" message="$3"

  [[ "$status" == "$KCT_STATUS_FAILED" ]] ||
    [[ "$status" == "$KCT_STATUS_INVALID" ]] &&
    ((KCT_ERROR_COUNT++))

  printf "C%03d: %s\n" \
    "$KCT_INDEX" "$name"
  printf "    > %s" "$status"
  test -n "$message" && printf ' (%s)' "$message"
  echo

  ! test -f "$filepath" &&
    printf '%s,%s,%s,%s,%s\n' \
      "index" "date" "name" "status" "message" >"$filepath"
  printf '%s,%s,%s,%s,%s\n' "$KCT_INDEX" \
    "$(date +"%d-%m-%yT%H:%M:%S")" \
    "$name" "$status" "$message" >>"$filepath"

  ((KCT_INDEX++))
  return 0
}

_kct_tmp_new_file() {
  local name="${1:-tmp}.XXXXXX"
  mktemp -q "$KCT_PATH_TMPDIR/$name"
}
_kct_tmp_new_dir() {
  local name="${1:-tmp}.XXXXXX"
  mktemp -qd "$KCT_PATH_TMPDIR/$name"
}

_kct_exec_kcs() {
  KCS_PATH="$KCT_PATH_TESTDIR" \
    KCS_LOGFMT='[{lvl}] {ns} {msg}' \
    "$KCT_CMD_KCS" "$@"
}

__internal() {
  KCT_ID="$(date +"%s")"
  KCT_RUN_ID="R$KCT_ID"
  KCT_INDEX=0
  KCT_ERROR_COUNT=0

  export KCT_ID KCT_RUN_ID KCT_INDEX KCT_ERROR_COUNT

  local old="$PWD"
  cd "$(dirname "$0")" || exit 1
  KCT_PATH_TESTDIR="$PWD"
  KCT_PATH_TMPDIR="$KCT_PATH_TESTDIR/.tmp"
  KCT_PATH_SNAPDIR="$KCT_PATH_TESTDIR/snap"
  KCT_PATH_REPORTDIR="$KCT_PATH_TESTDIR/reports/$KCT_ID"

  __prepare

  cd ".." || exit 1
  KCT_PATH_ROOTDIR="$PWD"
  KCT_CMD_KCS="$KCT_PATH_ROOTDIR/kcs"

  export KCT_PATH_TESTDIR KCT_PATH_TMPDIR KCT_PATH_SNAPDIR KCT_PATH_REPORTDIR
  export KCT_PATH_ROOTDIR KCT_CMD_KCS

  export KCT_STATUS_COMPLETED='COMPLETED'
  export KCT_STATUS_PASSED='PASSED'
  export KCT_STATUS_IGNORED='IGNORED'
  export KCT_STATUS_FAILED='FAILED'
  export KCT_STATUS_INVALID='INVALID'

  export KCT_SNAPSHOT_STDOUT='snapshot.stdout'
  export KCT_SNAPSHOT_STDERR='snapshot.stderr'
  export KCT_SNAPSHOT_STDLOG='snapshot.stdlog'

  export KCS_TEST=1

  local cmd="$1"
  shift
  _KCT_CASES="${KCT_CASES:-$*}" "$cmd"

  local code="$KCT_ERROR_COUNT"

  unset KCS_TEST
  unset KCT_ID KCT_RUN_ID KCT_INDEX KCT_ERROR_COUNT
  unset KCT_PATH_TESTDIR KCT_PATH_TMPDIR KCT_PATH_SNAPDIR KCT_PATH_REPORTDIR
  unset KCT_PATH_ROOTDIR KCT_CMD_KCS
  unset KCT_STATUS_COMPLETED KCT_STATUS_PASSED KCT_STATUS_IGNORED
  unset KCT_STATUS_FAILED KCT_STATUS_INVALID
  unset KCT_SNAPSHOT_STDOUT KCT_SNAPSHOT_STDERR KCT_SNAPSHOT_STDLOG

  cd "$old" || exit 1
  return "$code"
}

__prepare() {
  test -d "$KCT_PATH_TMPDIR" && rm -r "$KCT_PATH_TMPDIR"
  mkdir -p "$KCT_PATH_TMPDIR"

  test -d "$KCT_PATH_REPORTDIR" || mkdir -p "$KCT_PATH_REPORTDIR"

  test -d "$KCT_PATH_SNAPDIR" || mkdir -p "$KCT_PATH_SNAPDIR"
}

__internal main "$@"
