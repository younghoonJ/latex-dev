#!/usr/bin/env bash
set -Eeuo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/init-paper.sh PATH [--git] [--open]

Create a new LaTeX paper project from this repository's template.

Options:
  --git    Run git init in the new paper directory.
  --open   Open the new paper directory with VS Code when code is available.
EOF
}

die() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
template_dir="$repo_dir/template"
settings_dir="$repo_dir/.vscode"

target=""
init_git=0
open_code=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    --git)
      init_git=1
      shift
      ;;
    --open)
      open_code=1
      shift
      ;;
    --)
      shift
      break
      ;;
    -*)
      die "unknown option: $1"
      ;;
    *)
      [[ -z "$target" ]] || die "only one PATH argument is allowed"
      target="$1"
      shift
      ;;
  esac
done

[[ -n "$target" ]] || { usage >&2; exit 2; }
[[ -d "$template_dir" ]] || die "template directory not found: $template_dir"
[[ -d "$settings_dir" ]] || die "VS Code settings directory not found: $settings_dir"

case "$target" in
  \~/*) target="${HOME}/${target#\~/}" ;;
esac

parent_dir="$(dirname "$target")"
paper_name="$(basename "$target")"

[[ "$paper_name" != "." && "$paper_name" != "/" ]] || die "invalid target path: $target"
mkdir -p "$parent_dir"
[[ ! -e "$target" ]] || die "target already exists: $target"

cp -a "$template_dir" "$target"
cp -a "$settings_dir" "$target/.vscode"

if [[ "$init_git" -eq 1 ]]; then
  git -C "$target" init
fi

printf 'Created LaTeX paper project: %s\n' "$target"
printf 'Next steps:\n'
printf '  cd %q\n' "$target"
printf '  make pdf\n'

if [[ "$open_code" -eq 1 ]]; then
  if command -v code >/dev/null 2>&1; then
    code "$target"
  else
    printf 'WARNING: code command not found; skipping VS Code open.\n' >&2
  fi
fi
