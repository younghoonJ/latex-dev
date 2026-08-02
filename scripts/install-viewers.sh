#!/usr/bin/env bash
set -Eeuo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib-install.sh"
require_apt_linux

INSTALL_VIEWERS="${INSTALL_VIEWERS:-${INSTALL_GUI_TOOLS:-1}}"
INSTALL_GRAPHICS_TOOLS="${INSTALL_GRAPHICS_TOOLS:-${INSTALL_GUI_TOOLS:-1}}"
PDF_VIEWER="${PDF_VIEWER:-evince}"

case "$PDF_VIEWER" in
  evince|okular|zathura|none) ;;
  *) die "지원하지 않는 PDF_VIEWER입니다: $PDF_VIEWER (evince, okular, zathura, none 중 하나)" ;;
esac

packages=()

if [[ "$INSTALL_VIEWERS" == "1" && "$PDF_VIEWER" != "none" ]]; then
  packages+=("$PDF_VIEWER")
  if [[ "$PDF_VIEWER" == "zathura" ]]; then
    packages+=(xdotool)
  fi
fi

if [[ "$INSTALL_GRAPHICS_TOOLS" == "1" ]]; then
  packages+=(inkscape)
fi

if [[ ${#packages[@]} -eq 0 ]]; then
  warn "설치할 viewer/GUI 도구가 없습니다."
  exit 0
fi

log "PDF viewer/GUI 도구 설치"
apt_update
apt_install "${packages[@]}"

if [[ "$INSTALL_VIEWERS" == "1" && "$PDF_VIEWER" == "zathura" ]] &&
   apt-cache show zathura-pdf-poppler >/dev/null 2>&1; then
  apt_install zathura-pdf-poppler
fi

ok "PDF viewer/GUI 도구 설치 완료"
