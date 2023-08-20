#!/usr/bin/env bash

set -e

main() {
  local source="$1" entrypoint="$2" target="$3"

  test -d "${source:?}" ||
    _error "source directory '%s' is missing" "$source"
  test -d "${target:?}" ||
    _error "target directory '%s' is missing" "$target"
  command -v git >/dev/null ||
    _error "command '%s' is missing" "git"

  _info "%-15s %-18s | %s" "Installing..." "kcs" "$target"

  local scripts="$target/scripts"

  _delete "scripts" "$scripts"
  _create_dir "scripts" "$scripts"

  _move "source code" "$source/src" "$scripts/.kcs"
  _move "kcs version" "$source/version.txt" "$scripts/.kcs/version.txt"
  _create_script "index.sh" "$scripts/index.sh" "$entrypoint"

  _create_dir "commands" "$scripts/commands"
  _move "default command" \
    "$scripts/.kcs/commands/_default.sh" "$scripts/commands/_default.sh"

  return 0
}

_create_script() {
  local name="$1" target="$2" content="$3"
  _info "%-15s %-18s" "Creating..." "$name"
  echo "$content" >"$target" ||
    _error "cannot create '%s' file" "$target"
  chmod +x "$target" ||
    _error "cannot grant permission to '%s'" "$target"
}
_create_dir() {
  local name="$1" target="$2"
  _info "%-15s %-18s" "Creating..." "$name"
  mkdir -p "$target" ||
    _error "cannot create '%s' directory" "$target"
}
_copy() {
  local name="$1" source="$2" target="$3"
  _info "%-15s %-18s" "Copying..." "$name"
  cp -r "$source" "$target" ||
    _error "cannot move '%s' to '%s'" "$source" "$target"
}
_move() {
  local name="$1" source="$2" target="$3"
  _info "%-15s %-18s" "Moving..." "$name"
  mv "$source" "$target" ||
    _error "cannot move '%s' to '%s'" "$source" "$target"
}
_delete() {
  local name="$1" target="$2"
  if test -d "$target" || test -f "$target"; then
    _info "%-15s %-18s" "Deleting..." "$name"
    rm -rf "$target" ||
      _error "cannot delete '%s'" "$target"
  fi
}

_debug() {
  local format="$1"
  shift
  printf "[%s] $format\n" "DBG" "$@"
}
_info() {
  local format="$1"
  shift
  printf "[%s] $format\n" "INF" "$@"
}
_error() {
  local format="$1"
  shift
  printf "[%s] $format\n" "ERR" "$@" >&2
  exit 1
}

__internal() {
  local cmd="$1"
  shift

  local current="$PWD"
  local https="https://github.com/kc-workspace/kcs.git"
  local ssh="git@github.com:kc-workspace/kcs.git"

  local source
  source="$(mktemp -d)"
  ## delete source because initiate will create source instead
  test -d "$source" && rm -r "$source"

  local remote
  remote="$(git -C "$current" remote get-url origin)"
  if [[ "$remote" == "$ssh" ]] || [[ "$remote" == "$https" ]]; then
    cp -r "$current" "$source"
  else
    git clone "$https" --branch "main" --single-branch "$source"
  fi

  local entrypoint="#!/usr/bin/env bash
entrypoint=\"\$(dirname \"\$0\")/.kcs/main.sh\"
[ -f \"\$entrypoint\" ] && \"\$entrypoint\" \"\$@\"
"

  "$cmd" "$source" "$entrypoint" "$@" &&
    rm -fr "$source"
}

__internal main "$@"
