.PHONY: all help clean cleanall test report testreport format rmstats edit

SHELL=/usr/bin/env bash -eo pipefail

.SECONDARY:

.SUFFIXES:

all:
	snakemake -j -p --rerun-incomplete

test: ## Run the workflow on test data
	snakemake -j 4 --configfile .test/config.yaml --use-conda -p --debug-dag

help: ## Print help message
	@echo "$$(grep -hE '^\S+:.*##' $(MAKEFILE_LIST) | sed -e 's/:.*##\s*/:/' -e 's/^\(.\+\):\(.*\)/\\x1b[36m\1\\x1b[m:\2/' | column -c2 -t -s : | sort)"

testreport: ## Create html report for the test dir
	snakemake --dir .test --report report.html

report: ## Create html report
	snakemake --report report.html

format: ## Reformat source codes
	snakefmt workflow
	yapf -i --recursive workflow

clean: ## Clean

cleanall: clean ## Clean all

rmstats: ## Remove stats
	find results .test/results -name '*.global.tsv' | xargs rm -fv
	find results .test/results -name '*.summary' | xargs rm -fv

edit:
	nvim -p workflow/Snakefile workflow/rules/*.smk
