.PHONY: all help clean cleanall test report

SHELL=/usr/bin/env bash -eo pipefail

.SECONDARY:

.SUFFIXES:

all:
	snakemake -j -p

test:
	snakemake -j -p --dir .te

help: ## Print help message
	@echo "$$(grep -hE '^\S+:.*##' $(MAKEFILE_LIST) | sed -e 's/:.*##\s*/:/' -e 's/^\(.\+\):\(.*\)/\\x1b[36m\1\\x1b[m:\2/' | column -c2 -t -s : | sort)"

report:
	snakemake --report report.html

clean: ## Clean

cleanall: clean ## Clean all




