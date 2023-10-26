.PHONY: all help clean cleanall test report testreport format rmstats edit conda

SHELL=/usr/bin/env bash -eo pipefail

.SECONDARY:

.SUFFIXES:

TOPLEVEL_DIR := $(shell pwd)
CONDA_PARAMS = --use-conda --conda-prefix="$(TOPLEVEL_DIR)/.conda"

THREADS=$(shell grep "^threads:" config.yaml | awk '{print $$2}')

all: ## Run everything
	snakemake -j $(CONDA_PARAMS) -p --rerun-incomplete

test: ## Run the workflow on test data
	#snakemake -d .test -j 1 $(condaparams) -p --show-failed-logs
	snakemake -d .test -j $(CONDA_PARAMS) -p --show-failed-logs --rerun-incomplete

testreport:
	snakemake -d .test -j 1 $(CONDA_PARAMS) -p --show-failed-logs --report test_report.html

help: ## Print help message
	@echo "$$(grep -hE '^\S+:.*##' $(MAKEFILE_LIST) | sed -e 's/:.*##\s*/:/' -e 's/^\(.\+\):\(.*\)/\1:\2/' | column -c2 -t -s : | sort)"

report: ## Create html report
	snakemake $(CONDA_PARAMS) --report report.html

format: ## Reformat all source code (developers)
	snakefmt workflow
	yapf -i --recursive workflow

checkformat: ## Check source code format (developers)
	snakefmt --check workflow
	yapf --diff --recursive workflow

clean: ## Clean
	rm -fvr {.,.test}/{intermediate,output}/*

cleanall: clean ## Clean all

conda: ## Create the conda environments
	# as test tests everything, it requires all the environments, unlike the default conf
	snakemake -p -j -d .test $(CONDA_PARAMS) --conda-create-envs-only


rmstats: ## Remove stats
	find output .test/output -name 'stats*.tsv' | xargs rm -fv
	find output .test/output -name '*.summary' | xargs rm -fv

edit:
	nvim -p workflow/Snakefile workflow/rules/*.smk
