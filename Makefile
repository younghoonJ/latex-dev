.PHONY: install verify test copy-settings
install:
	./install.sh
verify:
	./scripts/verify.sh
test:
	$(MAKE) -C template pdf
copy-settings:
	mkdir -p "$${HOME}/.config/Code/User"
	cp .vscode/settings.json "$${HOME}/.config/Code/User/settings.json"
