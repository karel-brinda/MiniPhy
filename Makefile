.PHONY: all help clean cleanall test report format rmstats

SHELL=/usr/bin/env bash -eo pipefail

.SECONDARY:

.SUFFIXES:

all:
	snakemake -j10000 -p -k --rerun-incomplete

test:
	snakemake -j -p --dir .test --debug-dag

help: ## Print help message
	@echo "$$(grep -hE '^\S+:.*##' $(MAKEFILE_LIST) | sed -e 's/:.*##\s*/:/' -e 's/^\(.\+\):\(.*\)/\\x1b[36m\1\\x1b[m:\2/' | column -c2 -t -s : | sort)"

report:
	snakemake --report report.html

format:
	snakefmt workflow
	yapf -i --recursive workflow

clean: ## Clean

cleanall: clean ## Clean all

rmstats: ## Remove stats
	find results .test/results -name '*.global.tsv' | xargs rm -fv
	find results .test/results -name '*.summary' | xargs rm -fv

