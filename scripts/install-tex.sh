#!/usr/bin/env bash
set -Eeuo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib-install.sh"
require_apt_linux

INSTALL_TEXLIVE_FULL="${INSTALL_TEXLIVE_FULL:-0}"

log "LaTeX 도구 설치"
apt_update

if [[ "$INSTALL_TEXLIVE_FULL" == "1" ]]; then
  apt_install texlive-full
else
  apt_install \
    texlive-latex-base texlive-latex-recommended texlive-latex-extra \
    texlive-fonts-recommended texlive-fonts-extra texlive-science \
    texlive-pictures texlive-bibtex-extra texlive-lang-korean \
    texlive-xetex texlive-luatex texlive-extra-utils \
    latexmk biber chktex 
fi

apt_install ghostscript poppler-utils

command -v latexindent >/dev/null \
  || die "latexindent 설치 확인 실패"

ok "LaTeX 도구 설치 완료"
