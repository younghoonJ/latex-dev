# Ubuntu VS Code + LaTeX Bootstrap

Ubuntu에서 수학 논문 작성 환경을 반복 설치하기 위한 저장소입니다.

## 포함 내용

- VS Code 공식 APT 저장소 및 `code`(선택)
- TeX Live 경량 패키지 세트 또는 TeX Live Full(선택)
- `latexmk`, `biber`, `chktex`, `latexindent`
- Ghostscript, Poppler, Git, Python, ripgrep
- Inkscape와 Evince(선택)
- VS Code 확장 자동 설치(이미 설치된 `code`가 있을 때)
- LaTeX Workshop 설정
- `biblatex`/Biber 기반 수학 논문 템플릿
- 설치 검증 스크립트

## 빠른 시작

```bash
git clone https://github.com/YOUR_ID/ubuntu-latex-dev.git
cd ubuntu-latex-dev
chmod +x install.sh scripts/*.sh
./install.sh
```

스크립트는 같은 머신에서 다시 실행해도 되도록 작성했습니다. APT와 VS Code 확장 설치는 이미 설치된 항목을 재사용·갱신합니다. 기본 설치는 기존 개발 머신을 가정해 TeX Live Full과 VS Code 신규 설치를 제외합니다.

## 설치 옵션

환경변수로 선택 기능을 켜거나 끌 수 있습니다.

```bash
# TeX Live Full 설치
INSTALL_TEXLIVE_FULL=1 ./install.sh

# GUI 도구 제외
INSTALL_GUI_TOOLS=0 ./install.sh

# VS Code 설치 포함
INSTALL_VSCODE=1 ./install.sh
```

기본값은 `INSTALL_TEXLIVE_FULL=0`, `INSTALL_GUI_TOOLS=1`, `INSTALL_VSCODE=0`입니다.

## VS Code 설정 적용

저장소의 `.vscode/settings.json`은 이 저장소와 복사한 프로젝트 안에서 적용됩니다. 전역 사용자 설정으로 복사하려면:

```bash
make copy-settings
```

기존 사용자 설정을 덮어쓰므로 먼저 백업하는 편이 안전합니다.

## 템플릿 사용

```bash
cp -a template ~/papers/my-paper
cd ~/papers/my-paper
make pdf
code .
```

생성 PDF는 `build/main.pdf`에 있습니다.

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
