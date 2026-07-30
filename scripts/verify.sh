#!/usr/bin/env bash
set -u
TOOLS=(code pdflatex lualatex latexmk biber bibtex chktex latexindent git python3 inkscape gs pdftotext)
failed=0
printf '\n%-16s %s\n' TOOL STATUS
printf '%-16s %s\n' '----------------' '----------------'
for tool in "${TOOLS[@]}"; do
  if command -v "$tool" >/dev/null 2>&1; then
    printf '%-16s OK\n' "$tool"
  else
    printf '%-16s MISSING\n' "$tool"
    failed=1
  fi
done
printf '\n'
if [[ $failed -eq 0 ]]; then
  echo "모든 핵심 도구가 확인되었습니다."
else
  echo "일부 선택/필수 도구가 없습니다. 위 목록을 확인하세요."
fi
exit 0
