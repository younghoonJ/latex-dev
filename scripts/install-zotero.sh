#!/usr/bin/env bash
set -Eeuo pipefail
# Zotero 공식 다운로드 페이지에서 최신 Linux tarball URL을 복사해 첫 인자로 전달합니다.
# 예: ./scripts/install-zotero.sh 'https://download.zotero.org/client/release/...tar.bz2'
URL="${1:-}"
[[ -n "$URL" ]] || { echo "사용법: $0 <공식 Zotero Linux tarball URL>"; exit 2; }
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
curl -fL "$URL" -o "$TMP/zotero.tar.bz2"
sudo rm -rf /opt/zotero
sudo mkdir -p /opt/zotero
tar -xjf "$TMP/zotero.tar.bz2" -C "$TMP"
DIR="$(find "$TMP" -maxdepth 1 -type d -name 'Zotero_linux-*' | head -n1)"
[[ -d "$DIR" ]] || { echo "압축 내부 Zotero 디렉터리를 찾지 못했습니다."; exit 1; }
sudo cp -a "$DIR"/. /opt/zotero/
sudo ln -sf /opt/zotero/zotero /usr/local/bin/zotero
if [[ -x /opt/zotero/set_launcher_icon ]]; then sudo /opt/zotero/set_launcher_icon; fi
mkdir -p "$HOME/.local/share/applications"
if [[ -f /opt/zotero/zotero.desktop ]]; then
  cp /opt/zotero/zotero.desktop "$HOME/.local/share/applications/zotero.desktop"
  sed -i "s|^Exec=.*|Exec=/opt/zotero/zotero -url %U|" "$HOME/.local/share/applications/zotero.desktop"
fi
echo "Zotero 설치 완료"
