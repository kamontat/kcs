#!/usr/bin/env bash

## setup.sh <output-directory> [version]

set -e

main() {
  local source="$1" output="$2"
  local entrypoint="#!/usr/bin/env bash
entrypoint=\"\$(dirname \"\$0\")/.kcs/main.sh\"
[ -f \"\$entrypoint\" ] && \"\$entrypoint\" \"\$@\""

  test -d "${source:?}" || _error "source directory '%s' is missing" "$source"
  test -d "${output:?}" || _error "output directory '%s' is missing" "$output"

  local src="$source/src"
  local scripts="$output/scripts"
  local kcs="$scripts/.kcs"

  _create_dir "kcs" "$kcs"
  _create_dir "custom commands" "$scripts/commands"
  _create_dir "default commands" "$kcs/commands"

  _create_script "index.sh" "$scripts/index.sh" "$entrypoint"
  _replace "version file" "$source/version.txt" "$kcs/version.txt"
  _replace "main script" "$src/main.sh" "$kcs/main.sh"
  _replace "default command" "$src/commands/_default.sh" "$kcs/commands/_default.sh"
  _replace "example command" "$src/commands/_example.sh" "$kcs/commands/_example.sh"
  _replace "envs directory" "$src/envs" "$kcs/envs"
  _replace "private directory" "$src/private" "$kcs/private"
  _replace "lib directory" "$src/libs" "$kcs/libs"

  return 0
}

_create_script() {
  local name="$1" target="$2" content="$3"
  _step "Creating file" "$name" "$target"
  echo "$content" >"$target" ||
    _error "cannot create '%s' file" "$target"
  chmod +x "$target" ||
    _error "cannot grant permission to '%s'" "$target"
}
_create_dir() {
  local name="$1" target="$2"
  if ! test -d "$target"; then
    _step "Creating folder" "$name" "$target"
    mkdir -p "$target" || _error "cannot create '%s' directory" "$target"
  fi
}
_copy() {
  local name="$1" source="$2" target="$3"
  _step "Copying" "$name" "$target"
  cp -r "$source" "$target" ||
    _error "cannot move '%s' to '%s'" "$source" "$target"
}
_move() {
  local name="$1" source="$2" target="$3"
  _step "Moving" "$name" "$target"
  mv "$source" "$target" ||
    _error "cannot move '%s' to '%s'" "$source" "$target"
}
_replace() {
  local name="$1" source="$2" target="$3"
  if test -d "$target" || test -f "$target"; then
    _step "Replacing" "$name" "$target"
    rm -rf "$target" ||
      _error "cannot delete '%s'" "$target"
    mv "$source" "$target" ||
      _error "cannot move '%s' to '%s'" "$source" "$target"
  else
    _move "$name" "$source" "$target"
  fi
}
_delete() {
  local name="$1" target="$2"
  if test -d "$target" || test -f "$target"; then
    _step "Deleting" "$name" "$target"
    rm -rf "$target" ||
      _error "cannot delete '%s'" "$target"
  fi
}

_step() {
  local action="$1" name="$2" data="$3"
  printf "[STEP] %-18s %-20s | %s\n" "$action..." "$name" "$data"
}
_error() {
  local format="$1"
  shift
  printf "[%s] $format\n" "ERR" "$@" >&2
  exit 1
}

__internal() {
  local defaults_version
  defaults_version="$(
    curl -sSI https://github.com/kc-workspace/kcs/releases/latest |
      grep -i location |
      sed 's/.*tag\///'
  )"
  local cmd="$1" output="$2" version="${3:-$defaults_version}"

  local current="$PWD"
  local https="https://github.com/kc-workspace/kcs.git"
  local ssh="git@github.com:kc-workspace/kcs.git"

  local source
  source="$(mktemp -d)"
  ## delete source because initiate will create source instead
  test -d "$source" && rm -r "$source"

  if test -d "$current/.git"; then
    local remote
    remote="$(git -C "$current" remote get-url origin)"
    if [[ "$remote" == "$ssh" ]] || [[ "$remote" == "$https" ]]; then
      _copy "kcs" "$current" "$source"
    fi
  fi

  if ! test -d "$source"; then
    _step "Cloning" "kcs ($version)" "$https"
    git --no-pager clone --quiet --depth 1 \
      --branch "$version" --single-branch "$https" "$source"
  fi

  "$cmd" "$source" "$output" && rm -rf "$source"
}

__internal main "$1" "$2"
