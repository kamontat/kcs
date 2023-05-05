#!/usr/bin/env bash

## Possible values: 'validate', 'snapshot'
export __TEST_MODE="${TEST_MODE:-validate}"

main() {
  run_test \
    main logs
  run_test \
    disable debug
}

## $1 - test name
## $@ - test arguments
run_test() {
  local command_dir="$PWD/tests/commands"
  local snapshot_dir="$PWD/tests/snapshots"
  local temp_dir="$PWD/tests/.tmp"
  if [[ "$__TEST_MODE" == "snapshot" ]]; then
    temp_dir="$snapshot_dir"
  fi

  local name="$*"
  name="${name// /-}"

  DEBUG=1 KCS_TEST=1 KCS_DIR_COMMANDS="$command_dir" \
    ./scripts/main.sh "$@" >"$temp_dir/$name.txt" 2>"$temp_dir/$name.log"

  if [[ "$__TEST_MODE" == "validate" ]]; then
    local expected_file="$snapshot_dir/$name.txt"
    local actual_file="$temp_dir/$name.txt"
    _test_result "$name (out)" "$expected_file" "$actual_file"

    expected_file="$snapshot_dir/$name.log"
    actual_file="$temp_dir/$name.log"
    _test_result "$name (log)" "$expected_file" "$actual_file"
  elif [[ "$__TEST_MODE" == "snapshot" ]]; then
    printf "%-25s: %s\n" \
      "snapshot $name" "completed"
  fi
}

_test_result() {
  local exp act
  local name="$1" expected="$2" actual="$3"
  local status="unknown" description=""

  read -r exp _ < <(sha256sum "$expected")
  read -r act _ < <(sha256sum "$actual")

  if [[ "$exp" != "$act" ]]; then
    status="failed"
    description="diff -biy --suppress-common-lines $expected $actual"
  else
    status="passed"
  fi

  printf "%-25s: %s\n" \
    "$name" "$status"
  if test -n "$description"; then
    printf "%-25s: %s\n" \
      "Description" "$description"
  fi
}

main
