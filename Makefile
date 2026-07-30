.PHONY: install verify test copy-settings init-paper
install:
	./install.sh
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
