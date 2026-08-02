#!/usr/bin/env bash
set -Eeuo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$repo_dir/scripts/lib-install.sh"

INSTALL_COMMON_TOOLS="${INSTALL_COMMON_TOOLS:-1}"
INSTALL_TEX="${INSTALL_TEX:-1}"
INSTALL_VIEWERS="${INSTALL_VIEWERS:-${INSTALL_GUI_TOOLS:-1}}"
INSTALL_VSCODE_EXTENSIONS="${INSTALL_VSCODE_EXTENSIONS:-1}"
INSTALL_NVIM="${INSTALL_NVIM:-0}"
INSTALL_ZOTERO="${INSTALL_ZOTERO:-0}"

if [[ "$INSTALL_NVIM" == "1" && -z "${PDF_VIEWER:-}" ]]; then
  export PDF_VIEWER="okular"
fi

if [[ "$INSTALL_COMMON_TOOLS" == "1" ]]; then
  "$repo_dir/scripts/install-common-tools.sh"
fi

if [[ "$INSTALL_TEX" == "1" ]]; then
  "$repo_dir/scripts/install-tex.sh"
fi

if [[ "$INSTALL_VIEWERS" == "1" ]]; then
  "$repo_dir/scripts/install-viewers.sh"
fi

"$repo_dir/scripts/install-vscode.sh"

if [[ "$INSTALL_NVIM" == "1" ]]; then
  "$repo_dir/scripts/install-nvim-latex.sh"
fi

if [[ "$INSTALL_ZOTERO" == "1" ]]; then
  warn "Zotero는 공식 Linux tarball 배포 방식이므로 scripts/install-zotero.sh를 별도로 실행하세요."
fi

log "설치 완료"
"$repo_dir/scripts/verify.sh"
