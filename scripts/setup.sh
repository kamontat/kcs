#!/usr/bin/env bash

__INSTALL_DIR="${1:-$PWD}"

echo "On $__INSTALL_DIR, installing..."
cd "$__INSTALL_DIR" || exit 1

! command -v git >/dev/null &&
  echo "git command is missing" >&2 &&
  exit 1

__REPO="https://github.com/kc-workspace/kcs.git"
__TEMP="$(mktemp -d)"

git clone "$__REPO" "$__TEMP"
mv "$__TEMP/src" "$__INSTALL_DIR/.kcs"

unset __INSTALL_DIR
unset __REPO __TEMP
