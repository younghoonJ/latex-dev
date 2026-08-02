.PHONY: install install-common install-tex install-viewers install-vscode install-nvim verify test copy-settings init-paper

install: install-common install-tex install-viewers install-vscode verify

install-common:
	./scripts/install-common-tools.sh

install-tex: install-common
	./scripts/install-tex.sh

install-viewers: install-common
	./scripts/install-viewers.sh

install-vscode: install-common
	./scripts/install-vscode.sh

install-nvim: install-common install-tex
	PDF_VIEWER="$${PDF_VIEWER:-okular}" ./scripts/install-viewers.sh
	PDF_VIEWER="$${PDF_VIEWER:-okular}" ./scripts/install-nvim-latex.sh

verify:
	./scripts/verify.sh

test:
	$(MAKE) -C template pdf

copy-settings:
	mkdir -p "$${HOME}/.config/Code/User"
	cp .vscode/settings.json "$${HOME}/.config/Code/User/settings.json"

init-paper:
	@test -n "$(TARGET)" || (echo "Usage: make init-paper TARGET=~/papers/my-paper [GIT=1] [OPEN=1]" >&2; exit 2)
	./scripts/init-paper.sh "$(TARGET)" $(if $(GIT),--git) $(if $(OPEN),--open)
