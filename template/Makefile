.PHONY: pdf lua clean watch
pdf:
	latexmk -pdf -interaction=nonstopmode -file-line-error main.tex
lua:
	latexmk -lualatex -interaction=nonstopmode -file-line-error main.tex
watch:
	latexmk -pvc -pdf -interaction=nonstopmode -file-line-error main.tex
clean:
	latexmk -C
	rm -rf build
