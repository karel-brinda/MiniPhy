.PHONY: all help clean cleanall test report testreport format rmstats edit

SHELL=/usr/bin/env bash -eo pipefail

.SECONDARY:

.SUFFIXES:

all:
	snakemake -j --use-conda -p --rerun-incomplete

test: ## Run the workflow on test data
	snakemake -d .test -j 1 --use-conda -p --show-failed-logs --conda-cleanup-pkgs

testreport: ## Create html report for the test dir
	snakemake -d .test -j 1 --use-conda -p --show-failed-logs --conda-cleanup-pkgs --report test_report.html

help: ## Print help message
	@echo "$$(grep -hE '^\S+:.*##' $(MAKEFILE_LIST) | sed -e 's/:.*##\s*/:/' -e 's/^\(.\+\):\(.*\)/\1:\2/' | column -c2 -t -s : | sort)"

report: ## Create html report
	snakemake --use-conda --report report.html

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
