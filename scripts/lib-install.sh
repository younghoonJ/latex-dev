#!/usr/bin/env bash

log() {
  printf '\n\033[1;34m==> %s\033[0m\n' "$*"
}

ok() {
  printf '\033[1;32mOK: %s\033[0m\n' "$*"
}

warn() {
  printf '\033[1;33mWARNING: %s\033[0m\n' "$*" >&2
}

die() {
  printf '\033[1;31mERROR: %s\033[0m\n' "$*" >&2
  exit 1
}

require_apt_linux() {
  [[ "$(uname -s)" == "Linux" ]] || die "Linux에서만 실행할 수 있습니다."
  command -v apt-get >/dev/null 2>&1 || die "apt 기반 Ubuntu/Debian 환경이 필요합니다."

  if [[ ${EUID:-$(id -u)} -eq 0 ]]; then
    SUDO=()
  else
    command -v sudo >/dev/null 2>&1 || die "sudo가 필요합니다."
    SUDO=(sudo)
  fi
}

apt_update() {
  if [[ ${#SUDO[@]} -eq 0 ]]; then
    DEBIAN_FRONTEND=noninteractive apt-get update
  else
    "${SUDO[@]}" env DEBIAN_FRONTEND=noninteractive apt-get update
  fi
}

apt_install() {
  if [[ $# -eq 0 ]]; then
    return 0
  fi

  if [[ ${#SUDO[@]} -eq 0 ]]; then
    DEBIAN_FRONTEND=noninteractive apt-get install -y "$@"
  else
    "${SUDO[@]}" env DEBIAN_FRONTEND=noninteractive apt-get install -y "$@"
  fi
}

script_root() {
  cd "$(dirname "${BASH_SOURCE[1]}")/.." && pwd
}
