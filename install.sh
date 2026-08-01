#!/usr/bin/env bash
set -Eeuo pipefail

log(){ printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }
warn(){ printf '\033[1;33mWARNING: %s\033[0m\n' "$*" >&2; }
die(){ printf '\033[1;31mERROR: %s\033[0m\n' "$*" >&2; exit 1; }

[[ "$(uname -s)" == "Linux" ]] || die "Linux에서만 실행할 수 있습니다."
command -v apt-get >/dev/null || die "apt 기반 Ubuntu/Debian 환경이 필요합니다."

INSTALL_TEXLIVE_FULL="${INSTALL_TEXLIVE_FULL:-0}"
INSTALL_GUI_TOOLS="${INSTALL_GUI_TOOLS:-1}"
INSTALL_VSCODE="${INSTALL_VSCODE:-0}"
INSTALL_ZOTERO="${INSTALL_ZOTERO:-0}"

if [[ ${EUID} -eq 0 ]]; then SUDO=""; else SUDO="sudo"; fi

log "APT 기본 도구 설치"
$SUDO apt-get update
$SUDO DEBIAN_FRONTEND=noninteractive apt-get install -y \
  ca-certificates curl wget gpg apt-transport-https software-properties-common \
  git make python3 python3-venv python3-pip ripgrep jq unzip fontconfig

log "LaTeX 도구 설치"
if [[ "$INSTALL_TEXLIVE_FULL" == "1" ]]; then
  $SUDO DEBIAN_FRONTEND=noninteractive apt-get install -y texlive-full
else
  $SUDO DEBIAN_FRONTEND=noninteractive apt-get install -y \
    texlive-latex-base texlive-latex-recommended texlive-latex-extra \
    texlive-fonts-recommended texlive-fonts-extra texlive-science \
    texlive-pictures texlive-bibtex-extra texlive-lang-korean \
    texlive-xetex texlive-luatex \
    latexmk biber chktex latexindent
fi
$SUDO DEBIAN_FRONTEND=noninteractive apt-get install -y \
  ghostscript poppler-utils

if [[ "$INSTALL_GUI_TOOLS" == "1" ]]; then
  log "그림·PDF GUI 도구 설치"
  $SUDO DEBIAN_FRONTEND=noninteractive apt-get install -y inkscape evince
fi

if [[ "$INSTALL_VSCODE" == "1" ]]; then
  log "Microsoft VS Code APT 저장소 설정"
  install -d -m 0755 "$HOME/.cache/latex-dev-bootstrap"
  curl -fsSL https://packages.microsoft.com/keys/microsoft.asc \
    | gpg --dearmor > "$HOME/.cache/latex-dev-bootstrap/packages.microsoft.gpg"
  $SUDO install -o root -g root -m 644 \
    "$HOME/.cache/latex-dev-bootstrap/packages.microsoft.gpg" \
    /usr/share/keyrings/packages.microsoft.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
    | $SUDO tee /etc/apt/sources.list.d/vscode.list >/dev/null
  $SUDO apt-get update
  $SUDO DEBIAN_FRONTEND=noninteractive apt-get install -y code
fi

if command -v code >/dev/null; then
  log "VS Code 확장 설치"
  while IFS= read -r ext; do
    [[ -z "$ext" || "$ext" =~ ^# ]] && continue
    code --install-extension "$ext" --force || warn "확장 설치 실패: $ext"
  done < "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/extensions.txt"
else
  warn "code 명령을 찾지 못해 VS Code 확장 설치를 건너뜁니다."
fi

if [[ "$INSTALL_ZOTERO" == "1" ]]; then
  log "Zotero 설치 안내"
  warn "Zotero는 공식 Linux tarball 배포 방식이므로 자동 설치 대신 scripts/install-zotero.sh를 별도로 실행하세요."
fi

log "설치 완료"
"$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/scripts/verify.sh"
