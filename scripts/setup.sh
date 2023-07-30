#!/usr/bin/env bash

set -e

__INSTALL_DIR="${1:-$PWD}"

! command -v git >/dev/null &&
  echo "git command is missing" >&2 &&
  exit 1

__REPO="https://github.com/kc-workspace/kcs.git"
__TEMP="$(mktemp -d)"
__ENTRYPOINT="#!/usr/bin/env bash

if [ -f \"\$(dirname \"\$0\")/.kcs/main.sh\" ]; then
  \"\$(dirname \"\$0\")/.kcs/main.sh\" \"\$@\"
else
  echo \"cannot found main.sh file\" >&2
  exit 1
fi"

echo "On $__INSTALL_DIR, installing..."

test -d "$__INSTALL_DIR/scripts/.kcs" &&
  rm -r "$__INSTALL_DIR/scripts/.kcs"
mkdir -p "$__INSTALL_DIR/scripts" &&
  git clone "$__REPO" \
    --branch "main" --single-branch \
    "$__TEMP" &&
  mv "$__TEMP/src" "$__INSTALL_DIR/scripts/.kcs" &&
  echo "$__ENTRYPOINT" >"$__INSTALL_DIR/scripts/kcs" &&
  chmod +x "$__INSTALL_DIR/scripts/kcs" &&
  rm -rf "$__TEMP"

unset __INSTALL_DIR
unset __REPO __TEMP
unset __ENTRYPOINT
