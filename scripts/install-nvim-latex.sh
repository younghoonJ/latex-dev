#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SOURCE_CONFIG="$REPO_ROOT/nvim"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"

source "$SCRIPT_DIR/lib-install.sh"

SKIP_NEOVIM="${SKIP_NEOVIM:-0}"
SKIP_NVIM_PLUGINS="${SKIP_NVIM_PLUGINS:-0}"
PDF_VIEWER="${PDF_VIEWER:-okular}"

case "$PDF_VIEWER" in
  okular|zathura) ;;
  *) die "Neovim/VimTeX viewer는 PDF_VIEWER=okular 또는 PDF_VIEWER=zathura만 지원합니다." ;;
esac

require_apt_linux
[[ -f "$SOURCE_CONFIG/init.lua" ]] || die "공통 Neovim 설정을 찾을 수 없습니다: $SOURCE_CONFIG"

install_neovim() {
  local machine nvim_arch archive_url tmpdir archive extracted install_dir
  machine="$(uname -m)"

  case "$machine" in
    x86_64|amd64) nvim_arch="x86_64" ;;
    aarch64|arm64) nvim_arch="arm64" ;;
    *) die "지원하지 않는 CPU 아키텍처입니다: $machine" ;;
  esac

  archive_url="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-${nvim_arch}.tar.gz"
  tmpdir="$(mktemp -d)"
  archive="$tmpdir/nvim.tar.gz"
  extracted="$tmpdir/nvim-linux-${nvim_arch}"
  install_dir="/opt/nvim-linux-${nvim_arch}"

  log "최신 안정 Neovim 다운로드"
  curl --fail --location --retry 3 --output "$archive" "$archive_url"
  tar -xzf "$archive" -C "$tmpdir"
  [[ -x "$extracted/bin/nvim" ]] || die "Neovim 아카이브가 올바르지 않습니다."

  log "Neovim 설치: $install_dir"
  "${SUDO[@]}" rm -rf "$install_dir"
  "${SUDO[@]}" mv "$extracted" "$install_dir"
  "${SUDO[@]}" ln -sf "$install_dir/bin/nvim" /usr/local/bin/nvim
  hash -r
  rm -rf "$tmpdir"
}

configure_shell_path() {
  local rc marker_start marker_end
  marker_start="# >>> nvim-latex environment >>>"
  marker_end="# <<< nvim-latex environment <<<"

  mkdir -p "$HOME/.local/bin"

  for rc in "$HOME/.zshrc" "$HOME/.bashrc"; do
    touch "$rc"
    sed -i "\|${marker_start}|,\|${marker_end}|d" "$rc"
    cat >> "$rc" <<'EOF_SHELL'

# >>> nvim-latex environment >>>
export PATH="$HOME/.local/bin:$HOME/.local/share/nvim/mason/bin:$PATH"
export EDITOR="nvim"
export VISUAL="nvim"
# <<< nvim-latex environment <<<
EOF_SHELL
  done

  export PATH="$HOME/.local/bin:$HOME/.local/share/nvim/mason/bin:$PATH"
}

write_nvim_config() {
  local backup_dir timestamp
  timestamp="$(date +%Y%m%d-%H%M%S)"

  if [[ -e "$CONFIG_DIR" || -L "$CONFIG_DIR" ]]; then
    backup_dir="${CONFIG_DIR}.backup.${timestamp}"
    log "기존 Neovim 설정 백업: $backup_dir"
    mv "$CONFIG_DIR" "$backup_dir"
  fi

  log "공통 Neovim 설정 설치: $CONFIG_DIR"
  mkdir -p "$(dirname "$CONFIG_DIR")"
  cp -a "$SOURCE_CONFIG" "$CONFIG_DIR"

  cat > "$CONFIG_DIR/lua/config/viewer.lua" <<EOF_VIEWER
vim.env.NVIM_LATEX_PDF_VIEWER = "$PDF_VIEWER"
EOF_VIEWER

  if [[ "$PDF_VIEWER" == "zathura" ]]; then
    local zathura_dir="${XDG_CONFIG_HOME:-$HOME/.config}/zathura"
    local zathurarc="$zathura_dir/zathurarc"
    mkdir -p "$zathura_dir"
    touch "$zathurarc"
    sed -i "\|# >>> nvim-latex viewer >>>|,\|# <<< nvim-latex viewer <<<|d" "$zathurarc"
    cat >> "$zathurarc" <<'EOF_ZATHURA'

# >>> nvim-latex viewer >>>
set synctex true
set pages-per-row 1
set adjust-open "best-fit"
set window-title-basename true
# <<< nvim-latex viewer <<<
EOF_ZATHURA
  fi
}

install_plugins() {
  command -v nvim >/dev/null 2>&1 || die "nvim을 PATH에서 찾을 수 없습니다."
  log "Neovim plugin 및 TexLab 설치"
  nvim --headless "+Lazy! sync" +qa
  nvim --headless "+MasonToolsInstallSync" +qa
}

if [[ "$SKIP_NEOVIM" != "1" ]]; then
  install_neovim
else
  command -v nvim >/dev/null 2>&1 || die "SKIP_NEOVIM=1 이지만 nvim을 PATH에서 찾을 수 없습니다."
fi

configure_shell_path
write_nvim_config

if [[ "$SKIP_NVIM_PLUGINS" != "1" ]]; then
  install_plugins
else
  warn "Neovim plugin 설치를 건너뜁니다. 첫 실행 때 lazy.nvim이 설치합니다."
fi

ok "Neovim LaTeX 설정 완료"
