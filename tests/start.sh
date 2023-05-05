#!/usr/bin/env bash

## Possible values: 'validate', 'snapshot'
# TEST_MODE=validate

main() {
  test_setup

  test_case \
    main logs
  test_case \
    disable debug

  test_cleanup
}

test_setup() {
  ## Possible values: 'validate', 'snapshot'
  export __TEST_MODE="${TEST_MODE:-validate}"
  export __TEST_COMMAND_DIR="${TEST_COMMAND_DIR:-$PWD/tests/commands}"
  export __TEST_SNAPSHOT_DIR="${TEST_COMMAND_DIR:-$PWD/tests/snapshots}"
  export __TEST_RESULT_DIR="${TEST_COMMAND_DIR:-$PWD/tests/.results}"
  export __TEST_TEMPORARY_DIR="${TEST_COMMAND_DIR:-$PWD/tests/.tmp}"
  export __TEST_INDEX=1

  __remove_dirs "$__TEST_RESULT_DIR"
  __create_dirs "$__TEST_SNAPSHOT_DIR" \
    "$__TEST_RESULT_DIR" \
    "$__TEST_TEMPORARY_DIR"
}

test_cleanup() {
  __remove_dirs "$__TEST_TEMPORARY_DIR"

  unset __TEST_MODE __TEST_INDEX \
    __TEST_COMMAND_DIR __TEST_SNAPSHOT_DIR \
    __TEST_RESULT_DIR __TEST_TEMPORARY_DIR
}

test_case() {
  local commands=("$@") name
  name="$(__test_name "${commands[@]}")"

  __test_runner "$name" "${commands[@]}"
  __test_result "$name"

  ((__TEST_INDEX++))
}

__test_runner() {
  local base code out log
  local name="$1"
  shift

  base="$__TEST_TEMPORARY_DIR"
  __test_is_snapshot && base="$__TEST_SNAPSHOT_DIR"

  code="$(__test_filename "$base" "$name" "code")"
  out="$(__test_filename "$base" "$name" "out")"
  log="$(__test_filename "$base" "$name" "log")"

  DEBUG=1 KCS_TEST=1 KCS_DIR_COMMANDS="$__TEST_COMMAND_DIR" \
    ./scripts/main.sh "$@" >"$out" 2>"$log"

  local exit_code="$?"
  printf "%d" "$exit_code" >"$code"

  return 0
}

__test_result() {
  local code out log
  local name="$1"

  if __test_is_snapshot; then
    __test_print_result "$name" \
      "snapshot:completed"
    return 0
  fi

  local results=()

  ## Verify code
  results+=("code:$(__test_compare "$name" "code")")

  ## Verify output
  results+=("output:$(__test_compare "$name" "out")")

  ## Verify logging
  results+=("logging:$(__test_compare "$name" "log")")

  __test_print_result "$name" \
    "${results[@]}"
}

__test_compare() {
  local name="$1" ttype="$2"
  local expected actual result

  expected="$(__test_filename "$__TEST_SNAPSHOT_DIR" "$name" "$ttype")"
  actual="$(__test_filename "$__TEST_TEMPORARY_DIR" "$name" "$ttype")"

  if ! test -f "$expected"; then
    printf "failed (no-snapshot)"
    return 0
  fi

  if ! diff -q "$expected" "$actual" >/dev/null; then
    result="$(__test_filename "$__TEST_RESULT_DIR" "$name-$ttype" "diff")"
    diff --new-file --suppress-common-lines \
      --ignore-space-change --ignore-case \
      --unified "$expected" "$actual" >"$result"

    printf "failed (diff)"
    return 0
  fi

  printf "passed"
  return 0
}

__test_print_result() {
  local name="$1"
  printf "Case #%d: '%s'\n" \
    "$__TEST_INDEX" "$name"

  shift

  local raw key status
  for raw in "$@"; do
    key="${raw%%:*}"
    status="${raw#*:}"

    printf "%4s%s %-15s: %s\n" \
      "" "-" "$key" "$status"
  done
  echo
}

__test_name() {
  local name="$*" separator="-"
  name="${name// /$separator}"
  printf "%s" "$name"
}

## ttype is test type, possible values are 'code', 'out', 'log'
__test_filename() {
  local base="$1" name="$2" ttype="$3"
  printf "%s/%s.%s" "$base" "$name" "$ttype"
}

__test_is_validate() {
  [[ "$__TEST_MODE" == "validation" ]] ||
    [[ "$__TEST_MODE" == "validate" ]] ||
    [[ "$__TEST_MODE" == "verify" ]] ||
    [[ "$__TEST_MODE" == "v" ]]
}
__test_is_snapshot() {
  [[ "$__TEST_MODE" == "snapshot" ]] ||
    [[ "$__TEST_MODE" == "snap" ]] ||
    [[ "$__TEST_MODE" == "ss" ]] ||
    [[ "$__TEST_MODE" == "s" ]]
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

main
