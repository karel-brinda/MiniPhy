.PHONY: all help clean cleanall cleanallall test reports format edit conda viewconf

SHELL=/usr/bin/env bash -eo pipefail

.SECONDARY:

.SUFFIXES:


THREADS = $(shell grep "^threads:" config.yaml | awk '{print $$2}')

CONDA_DIR     = $(shell grep "^conda_dir:" config.yaml | awk '{print $$2}')
ifeq ($(CONDA_DIR),)
    $(error 'conda_dir' not found in the configuration)
endif

USE_CONDA     = $(shell grep "^use_conda:" config.yaml | awk '{print $$2}')
ifeq ($(USE_CONDA),)
    $(error 'use_conda' not found in the configuration)
endif

ifeq ($(strip $(USE_CONDA)),True)
	CONDA_PARAMS  =	--use-conda --conda-prefix="$(CONDA_DIR)"
endif

ifeq ($(SMK_CLUSTER_ARGS),)
    # configure local run
	SNAKEMAKE_PARAMS = --cores $(THREADS) $(CONDA_PARAMS) --rerun-incomplete --printshellcmds #--show-failed-logs
else
    # configure cluster run
	SNAKEMAKE_PARAMS = --cores all $(CONDA_PARAMS) $(SMK_CLUSTER_ARGS) --rerun-incomplete --printshellcmds #--show-failed-logs
endif
BIG_TEST_PARAMS = --config protocol_pre=True protocol_post=True



######################
## General commands ##
######################

all: ## Run everything (the default subcommand)
	snakemake $(SNAKEMAKE_PARAMS)

help: ## Print help messages
	@echo -e "$$(grep -hE '^\S*(:.*)?##' $(MAKEFILE_LIST) \
		| sed \
			-e 's/:.*##\s*/:/' \
			-e 's/^\(.*\):\(.*\)/   \\x1b[36m\1\\x1b[m:\2/' \
			-e 's/^\([^#]\)/\1/g' \
			-e 's/: /:/g' \
			-e 's/^#\(.*\)#/\\x1b[90m\1\\x1b[m/' \
		| column -c2 -t -s : )"

conda: ## Create the conda environments
	snakemake $(SNAKEMAKE_PARAMS) -d .test --conda-create-envs-only

clean: ## Clean all output archives and files with statistics
	rm -fvr output/* intermediate/stats/*
	find intermediate -name '*.summary' -or -name '*.nscl' -or -name '*.hist'  | xargs rm -fv
	if [ -d ".test" ]; then \
		$(MAKE) -C .test clean; \
	fi

cleanall: clean ## Clean everything but Conda, Snakemake, and input files
	rm -fvr intermediate/*
	@if [ -d ".test" ]; then \
		$(MAKE) -C .test cleanall; \
	fi

cleanallall: cleanall ## Clean completely everything
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
	snakemake $(SNAKEMAKE_PARAMS)--report report.html
	if [ -d ".test" ]; then \
		$(MAKE) -C .test reports; \
	fi


####################
## For developers ##
####################

#snakemake -d .test $(SNAKEMAKE_PARAMS)
test: ## Run the workflow on test data (P1)
	if [ -d ".test" ]; then \
		$(MAKE) -C .test test; \
	else\
		snakemake $(SNAKEMAKE_PARAMS); \
	fi

bigtest: ## Run the workflow on test data (P1, P2, P3)
	if [ -d ".test" ]; then \
		$(MAKE) -C .test bigtest; \
	else\
		snakemake $(SNAKEMAKE_PARAMS) $(BIG_TEST_PARAMS); \
	fi

format: ## Reformat all source code
	snakefmt workflow
	yapf -i --recursive workflow
	yapf -i *.py

checkformat: ## Check source code format
	snakefmt --check workflow
	yapf --diff --recursive workflow

edit:
	nvim -p workflow/Snakefile workflow/rules/*.smk
