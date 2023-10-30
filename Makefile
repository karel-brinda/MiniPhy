.PHONY: all help clean cleanall cleanallall test reports format edit conda viewconf

SHELL=/usr/bin/env bash -eo pipefail

.SECONDARY:

.SUFFIXES:


#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#!! WARNING: !! TOPDIR changes to .. when run from .test/ !!
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TOPDIR = .


# test if this is run from the .test/ directory
ifeq ($(strip $(TOPDIR)),..)
	SNAKEMAKE_PARAM_DIR = --snakefile ../workflow/Snakefile --show-failed-logs
else
	SNAKEMAKE_PARAM_DIR =
endif

CONDA_DIR     = $(shell grep "^conda_dir:" config.yaml | awk '{print $$2}')
ifeq ($(CONDA_DIR),)
    $(error 'conda_dir' not found in the configuration)
endif

USE_CONDA     = $(shell grep "^use_conda:" config.yaml | awk '{print $$2}')
ifeq ($(USE_CONDA),)
    $(error 'use_conda' not found in the configuration)
endif

CONDA_DIR_ADJ = $(TOPDIR)/$(CONDA_DIR)

ifeq ($(strip $(USE_CONDA)),True)
	CONDA_PARAMS  =	--use-conda --conda-prefix="$(CONDA_DIR_ADJ)"
endif


######################
## General commands ##
######################

all: ## Run everything
	snakemake -j $(CONDA_PARAMS) -p --rerun-incomplete $(SNAKEMAKE_PARAM_DIR)

help: ## Print help messages
	@echo "$$(grep -hE '^\S*(:.*)?##' $(MAKEFILE_LIST) \
		| sed -e 's/:.*##\s*/:/' -e 's/^\(.\+\):\(.*\)/\\x1b[36m\1\\x1b[m:\2/' -e 's/^\([^#]\)/    \1/g'\
		| column -c2 -t -s : )"

conda: ## Create the conda environments
	snakemake -p -j -d .test $(CONDA_PARAMS) --conda-create-envs-only

clean: ## Clean all output archives and files with statistics
	rm -fvr output/*
	find intermediate -name '*.summary' | xargs rm -fv
	@if [ -d ".test" ]; then \
		$(MAKE) -C .test clean; \
	fi

cleanall: clean ## Clean everything but Conda, Snakemake, and input files
	rm -fvr intermediate/*
	@if [ -d ".test" ]; then \
		$(MAKE) -C .test cleanall; \
	fi

cleanallall: cleanall ## Clean everything but Conda, Snakemake, and input files
	rm -fvr {input,$(CONDA_DIR)}/*
	rm -fr .snakemake/
	@if [ -d ".test" ]; then \
		$(MAKE) -C .test cleanallall; \
	fi


###############
## Reporting ##
###############

viewconf: ## View configuration without comments
	@cat config.yaml \
		| perl -pe 's/ *#.*//g' \
		| grep --color='auto' -E '.*\:'
	@#| grep -Ev ^$$

reports: ## Create html report
	snakemake -j $(CONDA_PARAMS) -p --rerun-incomplete $(SNAKEMAKE_PARAM_DIR) --report report.html
	@if [ -d ".test" ]; then \
		$(MAKE) -C .test TOPDIR=.. reports; \
	fi


####################
## For developers ##
####################

test: ## Run the workflow on test data
	#snakemake -d .test -j $(CONDA_PARAMS) -p --show-failed-logs --rerun-incomplete
	@if [ -d ".test" ]; then \
		$(MAKE) -C .test TOPDIR=..; \
	fi

format: ## Reformat all source code
	snakefmt workflow
	yapf -i --recursive workflow

checkformat: ## Check source code format
	snakefmt --check workflow
	yapf --diff --recursive workflow

edit:
	nvim -p workflow/Snakefile workflow/rules/*.smk
