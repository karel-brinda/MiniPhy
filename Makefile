.PHONY: all help clean cleanall test report testreport format rmstats edit conda

SHELL=/usr/bin/env bash -eo pipefail

.SECONDARY:

.SUFFIXES:

#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# WARNING:!! whenever '-d .test/' is used, important to re-mark TOPLEVEL_DIR
#         !! so that conda environments aren't recreated again
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TOPLEVEL_DIR := .
CONDA_DIR     = $(shell grep "^conda_dir:" config.yaml | awk '{print $$2}')
USE_CONDA     = $(shell grep "^use_conda:" config.yaml | awk '{print $$2}')

CONDA_DIR_ADJ = "$(TOPLEVEL_DIR)/$(CONDA_DIR)"

ifeq ($(strip $(USE_CONDA)),True)
	CONDA_PARAMS  =	--use-conda --conda-prefix="$(CONDA_DIR_ADJ)"
endif

#############
# FOR USERS #
#############

all: ## Run everything
	snakemake -j $(CONDA_PARAMS) -p --rerun-incomplete

help: ## Print help message
	@echo "$$(grep -hE '^\S+:.*##' $(MAKEFILE_LIST) | sed -e 's/:.*##\s*/:/' -e 's/^\(.\+\):\(.*\)/\1:\2/' | column -c2 -t -s : | sort)"

conda: ## Create the conda environments
	$(eval TOPLEVEL_DIR=..)
	snakemake -p -j -d .test $(CONDA_PARAMS) --conda-create-envs-only

clean: ## Clean
	rm -fvr {.,.test}/{intermediate,output}/*

cleanall: clean ## Clean all

rmstats: ## Remove stats
	find output .test/output -name 'stats*.tsv' | xargs rm -fv
	find output .test/output -name '*.summary' | xargs rm -fv


##################
# FOR DEVELOPERS #
##################


test: ## Run the workflow on test data
	$(eval TOPLEVEL_DIR=..)
	snakemake -d .test -j $(CONDA_PARAMS) -p --show-failed-logs --rerun-incomplete

testreport:
	$(eval TOPLEVEL_DIR=..)
	snakemake -d .test -j 1 $(CONDA_PARAMS) -p --show-failed-logs --report test_report.html

report: ## Create html report
	snakemake $(CONDA_PARAMS) --report report.html

format: ## Reformat all source code (developers)
	snakefmt workflow
	yapf -i --recursive workflow

checkformat: ## Check source code format (developers)
	snakefmt --check workflow
	yapf --diff --recursive workflow

edit:
	nvim -p workflow/Snakefile workflow/rules/*.smk
