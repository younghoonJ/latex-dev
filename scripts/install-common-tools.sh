#!/usr/bin/env bash
set -Eeuo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib-install.sh"
require_apt_linux

log "APT 기본 도구 설치"
apt_update
apt_install \
  ca-certificates curl wget gpg apt-transport-https software-properties-common \
  git make python3 python3-venv python3-pip ripgrep jq unzip fontconfig \
  tar gzip build-essential fd-find xclip wl-clipboard

if ! command -v fd >/dev/null 2>&1 && command -v fdfind >/dev/null 2>&1; then
  "${SUDO[@]}" ln -sf "$(command -v fdfind)" /usr/local/bin/fd
fi

ok "기본 도구 설치 완료"
