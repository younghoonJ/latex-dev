# Windows + MiKTeX + Neovim LaTeX setup

이 저장소의 `nvim/` 설정은 Ubuntu와 Windows에서 함께 사용합니다.

- Ubuntu: Neovim + VimTeX + latexmk + Okular(기본) 또는 Zathura
- Windows: Neovim + VimTeX + MiKTeX/latexmk + SumatraPDF
- 공통: lazy.nvim, VimTeX, TexLab/Mason, blink.cmp, Telescope, nvim-tree, Oil, TokyoNight, which-key, bufferline, lualine

## 설치

MiKTeX는 미리 설치되어 있어야 합니다. 저장소를 받은 뒤 `install-windows.cmd`를 실행하면 Git, Neovim, ripgrep, Strawberry Perl, SumatraPDF가 없을 경우 `winget`으로 설치됩니다. MiKTeX는 자동 설치하지 않습니다.

PowerShell에서 직접 실행하려면:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\scripts\install-nvim-latex.ps1 -InstallDependencies
```

필요한 프로그램이 모두 설치되어 있다면 `-InstallDependencies`를 생략할 수 있습니다. 기존 `%LOCALAPPDATA%\nvim` 설정은 `nvim.backup.YYYYMMDD-HHMMSS`로 백업됩니다.

## MiKTeX 확인

새 PowerShell에서 다음 명령을 확인하세요.

```powershell
pdflatex --version
latexmk -v
perl -v
```

`latexmk`가 없다면 MiKTeX Console의 Packages에서 `latexmk`를 설치하세요.

## 사용

- `,ll`: VimTeX continuous compile
- `,lv`: SumatraPDF 열기/forward SyncTeX
- `,li`: VimTeX 정보
- `,le`: 오류 목록
- `,lc`: 보조 파일 정리

## SumatraPDF inverse SyncTeX

설치기는 SumatraPDF inverse-search 명령을 자동 등록합니다. Windows Neovim은 `//./pipe/nvim-latex` RPC endpoint를 열고, PDF의 텍스트를 더블클릭하면 해당 `.tex` 파일과 줄로 이동합니다.

첫 번째 Neovim 인스턴스가 고정 endpoint를 소유합니다. 동작하지 않으면 모든 Neovim과 SumatraPDF 창을 닫은 뒤 다시 열고 다음을 확인하세요.

```vim
:echo serverlist()
```

목록에 `nvim-latex`가 있어야 합니다. 상세 오류는 `%TEMP%\nvim-sumatra-inverse.log`에 기록됩니다.

## 검증

```powershell
.\scripts\verify-windows.ps1
```
