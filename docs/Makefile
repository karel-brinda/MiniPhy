.PHONY: all help clean cleanall

SHELL=/usr/bin/env bash -eo pipefail

.SECONDARY:

.SUFFIXES:

all: logo_wbg.svg logo_small.png

%_wbg.svg: %.svg
	cat $< \
        | perl -pe 's/\.st0/svg{background-color: white;}\n.st0/g' \
        > $@

logo_small.png: logo.pdf
	convert $< $@

help: ## Print help message
	@echo "$$(grep -hE '^\S+:.*##' $(MAKEFILE_LIST) | sed -e 's/:.*##\s*/:/' -e 's/^\(.\+\):\(.*\)/\\x1b[36m\1\\x1b[m:\2/' | column -c2 -t -s : | sort)"

clean: ## Clean

cleanall: clean ## Clean all


