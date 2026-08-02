# Ubuntu LaTeX Development Bootstrap

Ubuntu에서 수학 논문 작성 환경을 반복 설치하기 위한 저장소입니다. 설치 단위는 공통 도구, TeX 도구, PDF viewer/GUI 도구, 편집기 설정으로 나뉩니다.

## 포함 내용

- TeX Live 경량 패키지 세트 또는 TeX Live Full
- `latexmk`, `biber`, `chktex`, `latexindent`
- Ghostscript, Poppler, Git, Python, ripgrep
- PDF viewer/GUI 도구: Evince, Okular, Zathura, Inkscape 중 선택
- VS Code 공식 APT 저장소 및 `code` 설치(선택)
- VS Code LaTeX Workshop 확장 및 추천 확장 설치
- Neovim, VimTeX, TexLab, lazy.nvim 기반 설정(선택)
- `biblatex`/Biber 기반 수학 논문 템플릿
- 설치 검증 스크립트

## 빠른 시작

기본 설치는 기존처럼 VS Code 중심 환경입니다. VS Code 앱 자체는 기본 설치하지 않고, 이미 `code`가 있으면 확장만 설치합니다.

```bash
git clone https://github.com/YOUR_ID/ubuntu-latex-dev.git
cd ubuntu-latex-dev
chmod +x install.sh scripts/*.sh
make install
```

스크립트는 같은 머신에서 다시 실행해도 되도록 작성했습니다. APT와 VS Code 확장 설치는 이미 설치된 항목을 재사용·갱신합니다.

## Makefile 설치 타깃

```bash
# 공통 도구만 설치
make install-common

# TeX Live / latexmk / biber / chktex / latexindent 설치
make install-tex

# PDF viewer와 GUI 도구 설치. 기본 viewer는 evince입니다.
make install-viewers
PDF_VIEWER=okular make install-viewers
PDF_VIEWER=zathura make install-viewers

# VS Code 앱 설치 없이, code가 있으면 확장만 설치
make install-vscode

# VS Code 앱까지 설치
INSTALL_VSCODE=1 make install-vscode

# Neovim + VimTeX + TexLab 설정. 기본 viewer는 okular입니다.
make install-nvim
PDF_VIEWER=zathura make install-nvim
```

`make install`은 다음 순서로 실행됩니다.

```bash
make install-common
make install-tex
make install-viewers
make install-vscode
make verify
```

## 설치 옵션

환경변수로 선택 기능을 켜거나 끌 수 있습니다.

```bash
# TeX Live Full 설치
INSTALL_TEXLIVE_FULL=1 make install-tex

# viewer/GUI 도구 제외
INSTALL_VIEWERS=0 ./install.sh

# Inkscape 제외, PDF viewer만 설치
INSTALL_GRAPHICS_TOOLS=0 make install-viewers

# VS Code 확장 설치 제외
INSTALL_VSCODE_EXTENSIONS=0 make install-vscode

# 기존 install.sh 경로에서 Neovim까지 함께 설치
INSTALL_NVIM=1 ./install.sh
```

기존 호환을 위해 `INSTALL_GUI_TOOLS=0`도 `INSTALL_VIEWERS=0`처럼 동작합니다.

## VS Code 설정 적용

저장소의 `.vscode/settings.json`은 이 저장소와 복사한 프로젝트 안에서 적용됩니다. 전역 사용자 설정으로 복사하려면:

```bash
make copy-settings
```

기존 사용자 설정을 덮어쓰므로 먼저 백업하는 편이 안전합니다.

## 템플릿 사용

```bash
./scripts/init-paper.sh ~/papers/my-paper --git --open
cd ~/papers/my-paper
make pdf
```

생성 PDF는 VS Code 빌드에서는 `build/main.pdf`에 있습니다. Makefile 빌드는 템플릿의 `Makefile` 설정을 따릅니다.

Makefile을 통해서도 새 논문 프로젝트를 만들 수 있습니다.

```bash
make init-paper TARGET=~/papers/my-paper GIT=1 OPEN=1
```

대상 경로가 이미 있으면 덮어쓰지 않고 실패합니다. VS Code 워크스페이스 설정도 새 프로젝트의 `.vscode/settings.json`으로 함께 복사됩니다.

## 검증

```bash
make verify
make test
```

## Zotero

Zotero 공식 문서는 Linux에서 공식 tarball을 내려받아 압축을 풀어 실행하는 방식을 안내합니다. 최신 URL이 바뀔 수 있어 기본 설치에서는 제외했습니다. 공식 다운로드 페이지에서 Linux tarball URL을 복사한 뒤:

```bash
./scripts/install-zotero.sh '공식-tarball-URL'
```

Better BibTeX 플러그인은 Zotero 내부에서 별도 설치하세요.

## GitHub에 올리기

```bash
git init
git add .
git commit -m "Add Ubuntu LaTeX development bootstrap"
git branch -M main
git remote add origin git@github.com:YOUR_ID/ubuntu-latex-dev.git
git push -u origin main
```

개인 이름·이메일·토큰·SSH 키는 이 저장소에 넣지 마세요.
