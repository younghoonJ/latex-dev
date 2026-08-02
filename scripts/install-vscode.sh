#!/usr/bin/env bash
set -Eeuo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib-install.sh"
require_apt_linux

repo_dir="$(script_root)"
INSTALL_VSCODE="${INSTALL_VSCODE:-0}"
INSTALL_VSCODE_EXTENSIONS="${INSTALL_VSCODE_EXTENSIONS:-1}"

if [[ "$INSTALL_VSCODE" == "1" ]]; then
  log "Microsoft VS Code APT 저장소 설정"
  install -d -m 0755 "$HOME/.cache/latex-dev-bootstrap"
  curl -fsSL https://packages.microsoft.com/keys/microsoft.asc \
    | gpg --dearmor > "$HOME/.cache/latex-dev-bootstrap/packages.microsoft.gpg"
  "${SUDO[@]}" install -o root -g root -m 644 \
    "$HOME/.cache/latex-dev-bootstrap/packages.microsoft.gpg" \
    /usr/share/keyrings/packages.microsoft.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
    | "${SUDO[@]}" tee /etc/apt/sources.list.d/vscode.list >/dev/null
  apt_update
  apt_install code
fi

if [[ "$INSTALL_VSCODE_EXTENSIONS" != "1" ]]; then
  warn "VS Code 확장 설치를 건너뜁니다."
  exit 0
fi

if command -v code >/dev/null 2>&1; then
  log "VS Code 확장 설치"
  while IFS= read -r ext; do
    [[ -z "$ext" || "$ext" =~ ^# ]] && continue
    code --install-extension "$ext" --force || warn "확장 설치 실패: $ext"
  done < "$repo_dir/extensions.txt"
  ok "VS Code 확장 설치 완료"
else
  warn "code 명령을 찾지 못해 VS Code 확장 설치를 건너뜁니다."
fi
