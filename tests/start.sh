#!/usr/bin/env bash

## Possible values: 'validate', 'snapshot'
# TEST_MODE=validate

## Possible values: 'snap', 'code', 'out', 'log'
# TEST_TYPE=snap

## Possible values: 'snapshot', 'exit-code', 'output', 'logging'
# TEST_KEY=snapshot

tests() {
  new_case \
    main simple
  new_case \
    debug disable
  new_case \
    debug single-only
  new_case \
    debug multiple-only
  new_case \
    dry hook
  new_case \
    utils init-phase
}

###################################################
## Public functions
###################################################

new_case() {
  local name
  name="$(_test_name "$@")"

  if _tests_is_snapshot_mode; then
    _tests_run_snapshot "$name" "$@"
  elif _tests_is_validate_mode; then
    _test_run_validate "$name" "$@"
  fi
}

###################################################
## Protected functions
###################################################

_tests_init() {
  export __TEST_MODE_VALIDATE="validate"
  export __TEST_MODE_SNAPSHOT="snapshot"
  export __TEST_MODE="${TEST_MODE:-$__TEST_MODE_VALIDATE}"

  export __TEST_STATUS_PASSED="passed"
  export __TEST_STATUS_PASSED_SHORT="P"
  export __TEST_STATUS_FAILED="failed"
  export __TEST_STATUS_FAILED_SHORT="F"
  export __TEST_STATUS_COMPLETED="completed"
  export __TEST_STATUS_COMPLETED_SHORT="C"

  export __TEST_REASON_NO_SNAPSHOT="no-snapshot"
  export __TEST_REASON_NO_SNAPSHOT_SHORT="[NS]"
  export __TEST_REASON_MISMATCH="mismatch"
  export __TEST_REASON_MISMATCH_SHORT="[MM]"

  export __TEST_TYPE_SNAP="snap"
  export __TEST_TYPE_CODE="code"
  export __TEST_TYPE_OUT="out"
  export __TEST_TYPE_LOG="log"
  export __TEST_TYPE_DIFF="diff"

  export __TEST_KEY_SNAP="snapshot"
  export __TEST_KEY_CODE="exit-code"
  export __TEST_KEY_OUT="output"
  export __TEST_KEY_LOG="logging"

  export __TEST_DIR_COMMAND="${TEST_DIR_COMMAND:-$PWD/tests/commands}"
  export __TEST_DIR_SNAPSHOT="${TEST_DIR_SNAPSHOT:-$PWD/tests/snapshots}"
  export __TEST_DIR_RESULT="${TEST_DIR_RESULT:-$PWD/tests/.results}"
  export __TEST_DIR_TEMPORARY="${TEST_DIR_TEMPORARY:-$PWD/tests/.tmp}"

  export __TEST_INDEX=0
  export __TEST_TOTAL=0
  export __TEST_TOTAL_COMPLETED=0
  export __TEST_TOTAL_PASSED=0
  export __TEST_TOTAL_FAILED=0
}

_tests_setup() {
  __remove_dirs "$__TEST_DIR_RESULT" "$__TEST_DIR_TEMPORARY"
  __create_dirs "$__TEST_DIR_SNAPSHOT" \
    "$__TEST_DIR_RESULT" \
    "$__TEST_DIR_TEMPORARY"
}

_tests_clean() {
  local code="$__TEST_TOTAL_FAILED"

  _test_summary

  unset __TEST_MODE \
    __TEST_MODE_VALIDATE __TEST_MODE_SNAPSHOT

  unset __TEST_STATUS_PASSED __TEST_STATUS_PASSED_SHORT \
    __TEST_STATUS_FAILED __TEST_STATUS_FAILED_SHORT \
    __TEST_STATUS_COMPLETED __TEST_STATUS_COMPLETED_SHORT

  unset __TEST_REASON_NO_SNAPSHOT __TEST_REASON_NO_SNAPSHOT_SHORT \
    __TEST_REASON_MISMATCH __TEST_REASON_MISMATCH_SHORT

  unset __TEST_TYPE_SNAP __TEST_TYPE_CODE \
    __TEST_TYPE_OUT __TEST_TYPE_LOG __TEST_TYPE_DIFF

  unset __TEST_KEY_SNAP __TEST_KEY_CODE \
    __TEST_KEY_OUT __TEST_KEY_LOG

  unset __TEST_DIR_COMMAND \
    __TEST_DIR_RESULT __TEST_DIR_SNAPSHOT \
    __TEST_DIR_TEMPORARY

  unset __TEST_INDEX \
    __TEST_TOTAL __TEST_TOTAL_COMPLETED \
    __TEST_TOTAL_PASSED __TEST_TOTAL_FAILED

  return "$code"
}

_tests_run_snapshot() {
  local name="$1"
  shift

  __debug "starting '%s' (%s)" "$name" "snapshot"
  _test_run_command "$name" "$__TEST_DIR_SNAPSHOT" "$@"
  _tests_snapshot_result "$name"
}

_tests_snapshot_result() {
  local name="$1"

  _test_print_result "$name" \
    "$__TEST_KEY_SNAP:$__TEST_STATUS_COMPLETED"
}

_test_run_validate() {
  local name="$1"
  shift

  __debug "starting '%s' (%s)" "$name" "validate"
  _test_run_command "$name" "$__TEST_DIR_TEMPORARY" "$@"
  _test_validate_result "$name"
}

_test_validate_result() {
  local results=()

  ## Verify code
  results+=("$__TEST_KEY_CODE:$(_test_compare \
    "$name" "$__TEST_KEY_CODE" "$__TEST_TYPE_CODE")")

  ## Verify output
  results+=("$__TEST_KEY_OUT:$(_test_compare \
    "$name" "$__TEST_KEY_OUT" "$__TEST_TYPE_OUT")")

  ## Verify logging
  results+=("$__TEST_KEY_LOG:$(_test_compare \
    "$name" "$__TEST_KEY_LOG" "$__TEST_TYPE_LOG")")

  _test_print_result "$name" \
    "${results[@]}"
}

_test_compare() {
  local name="$1" key="$2" type="$3"
  local expected actual result

  expected="$(_test_filename "$__TEST_DIR_SNAPSHOT" "$name" "$key" "$type")"
  actual="$(_test_filename "$__TEST_DIR_TEMPORARY" "$name" "$key" "$type")"

  if ! test -f "$expected"; then
    printf "%s:%s" "$__TEST_STATUS_FAILED" "$__TEST_REASON_NO_SNAPSHOT"
    return 0
  fi

  if ! diff -q "$expected" "$actual" >/dev/null; then
    result="$(_test_filename "$__TEST_DIR_RESULT" "$name" "$type" "$__TEST_TYPE_DIFF")"
    diff --new-file --suppress-common-lines \
      --ignore-space-change --ignore-case \
      --unified "$expected" "$actual" >"$result"

    ((__TEST_EXIT_CODE++))
    export __TEST_EXIT_CODE
    printf "%s:%s" "$__TEST_STATUS_FAILED" "$__TEST_REASON_MISMATCH"
    return 0
  fi

  printf "passed"
  return 0
}

_test_run_command() {
  local name="$1" basepath="$2"
  shift 2

  local stdout stderr stdcode

  stdout="$(_test_filename \
    "$basepath" "$name" "$__TEST_KEY_OUT" "$__TEST_TYPE_OUT")"
  stderr="$(_test_filename \
    "$basepath" "$name" "$__TEST_KEY_LOG" "$__TEST_TYPE_LOG")"
  stdcode="$(_test_filename \
    "$basepath" "$name" "$__TEST_KEY_CODE" "$__TEST_TYPE_CODE")"

  DEBUG=1 KCS_TEST=1 \
    KCS_DIR_COMMANDS="$__TEST_DIR_COMMAND" \
    ./scripts/main.sh "$@" >"$stdout" 2>"$stderr"
  local exit_code="$?"
  printf "%d" "$exit_code" >"$stdcode"

  return 0
}

_test_print_result() {
  if test -n "$CI"; then
    _test_print_result_minimal "$@"
  else
    _test_print_result_verbose "$@"
  fi

  ((__TEST_INDEX++))
}

_test_print_result_minimal() {
  local name="$1" suffix
  shift

  local raw key _status status _reason
  local suffix
  for raw in "$@"; do
    key="${raw%%:*}"
    _status="${raw#*:}"
    _reason="${_status#*:}"
    if [[ "$_status" != "$_reason" ]]; then
      _status="${_status%%:*}"
    fi

    unset status

    case "$_status" in
    "$__TEST_STATUS_COMPLETED") status="$__TEST_STATUS_COMPLETED_SHORT" ;;
    "$__TEST_STATUS_PASSED") status="$__TEST_STATUS_PASSED_SHORT" ;;
    "$__TEST_STATUS_FAILED") status="$__TEST_STATUS_FAILED_SHORT" ;;
    esac

    suffix="$suffix$status"
    _test_update_total "$_status"
  done

  test -n "$suffix" && suffix=" $suffix"

  printf "Case #%03d %-27s:%s\n" \
    "$((__TEST_INDEX + 1))" "$name" "$suffix"

  #   if [[ "$status" != "$reason" ]]; then
  #     status="${status%%:*}"
  #     suffix=" ($reason)"
  #   fi

  #   printf "%4s%s %-15s: %s%s\n" \
  #     "" "-" "$key" "$status" "$suffix"

  #   _test_update_total "$status"
  # done
  # echo
}

_test_print_result_verbose() {
  local name="$1"
  printf "Case #%03d: '%s'\n" \
    "$((__TEST_INDEX + 1))" "$name"
  shift

  local raw key status reason
  local suffix
  for raw in "$@"; do
    key="${raw%%:*}"
    status="${raw#*:}"
    reason="${status#*:}"
    suffix=""

    if [[ "$status" != "$reason" ]]; then
      status="${status%%:*}"
      suffix=" ($reason)"
    fi

    printf "%4s%s %-15s: %s%s\n" \
      "" "-" "$key" "$status" "$suffix"

    _test_update_total "$status"
  done
  echo
}

_test_summary() {
  local line="-----------"

  printf "\n"
  printf "| %-9s | %-9s | %-9s |\n" \
    "$__TEST_STATUS_COMPLETED" \
    "$__TEST_STATUS_PASSED" "$__TEST_STATUS_FAILED"
  printf "| %-9d | %-9d | %-9d |\n" \
    "$__TEST_TOTAL_COMPLETED" \
    "$__TEST_TOTAL_PASSED" "$__TEST_TOTAL_FAILED"
  printf "|%-11s|%-11s|%-11s|\n" \
    "$line" "$line" "$line"
  printf "| %-9s | %-21s |\n" \
    "Total" "$__TEST_TOTAL/$__TEST_INDEX (checks/cases)"
}

_test_update_total() {
  local status="$1"
  [[ "$status" == "$__TEST_STATUS_COMPLETED" ]] &&
    ((__TEST_TOTAL_COMPLETED++))
  [[ "$status" == "$__TEST_STATUS_PASSED" ]] &&
    ((__TEST_TOTAL_PASSED++))
  [[ "$status" == "$__TEST_STATUS_FAILED" ]] &&
    ((__TEST_TOTAL_FAILED++))

  ((__TEST_TOTAL++))
}

_test_name() {
  local name="$*" separator="-"
  name="${name// /$separator}"
  printf "%s" "$name"
}

_test_filename() {
  local base="$1" name="$2" key="$3" type="$4"

  test -d "$base/$name" ||
    mkdir -p "$base/$name"

  printf "%s/%s/%s.%s" "$base" "$name" "$key" "$type"
}

_tests_is_validate_mode() {
  [[ "$__TEST_MODE" == "$__TEST_MODE_VALIDATE" ]] ||
    [[ "$__TEST_MODE" == "validation" ]] ||
    [[ "$__TEST_MODE" == "verify" ]] ||
    [[ "$__TEST_MODE" == "v" ]]
}

_tests_is_snapshot_mode() {
  [[ "$__TEST_MODE" == "$__TEST_MODE_SNAPSHOT" ]] ||
    [[ "$__TEST_MODE" == "snap" ]] ||
    [[ "$__TEST_MODE" == "ss" ]] ||
    [[ "$__TEST_MODE" == "s" ]]
}

###################################################
## Private functions
###################################################

__debug() {
  if test -n "$DEBUG"; then
    local format="$1"
    shift

    # shellcheck disable=SC2059
    printf "$format\n" "$@" >&2
  fi
}

__create_dirs() {
  local dir
  for dir in "$@"; do
    if ! test -d "$dir"; then
      mkdir -p "$dir"
    fi
  done
}

__remove_dirs() {
  local dir
  for dir in "$@"; do
    if test -d "$dir"; then
      rm -r "$dir"
      mkdir -p "$dir"
      touch "$dir/.gitkeep"
    fi
  done
}

###################################################
## Main function
###################################################

_tests_init
_tests_setup
tests
_tests_clean
