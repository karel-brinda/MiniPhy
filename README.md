# MOF-Compress

<!-- vim-markdown-toc GFM -->

* [Introduction](#introduction)
  * [Citation](#citation)
* [Installation](#installation)
  * [Step 1: Install dependencies](#step-1-install-dependencies)
  * [Step 2: Clone the repository](#step-2-clone-the-repository)
  * [Step 3: Run a simple test](#step-3-run-a-simple-test)
  * [Step 4: Download the database](#step-4-download-the-database)
* [Usage](#usage)
  * [Step 1: Copy or symlink your queries](#step-1-copy-or-symlink-your-queries)
  * [Step 2: Adjust configuration](#step-2-adjust-configuration)
  * [Step 3: Clean up intermediate files](#step-3-clean-up-intermediate-files)
  * [Step 4: Run the pipeline](#step-4-run-the-pipeline)
  * [Step 5: Analyze your results](#step-5-analyze-your-results)
* [Additional information](#additional-information)
  * [List of workflow commands](#list-of-workflow-commands)
  * [Directories](#directories)
  * [Running on a cluster](#running-on-a-cluster)
  * [Known limitations](#known-limitations)
* [License](#license)
* [Contacts](#contacts)

<!-- vim-markdown-toc -->


## Introduction

MOF-Compress is a central package of MOF that performs phylogenetic compression, a technique based
on using estimated evolutionary history to guide compression and efficiently
search large collections of microbial genomes using existing algorithms and
data structures. In short, input data are reorganized according to the topology
of the estimated phylogenies, which makes data highly locally compressible even
using basic techniques. The resulting performance gains come from a wide range of benefits of
phylogenetic compression, including easy parallelization, small memory
requirements, small database size, better memory locality, and better branch
prediction.

This pipeline performs phylogenetic compression of several batches and calculates the
associated statistics. It implements the following three protocols: 1) phylogenetic compression of assemblies based on
a left-to-right reordering, 2) phylogenetic compression of de Bruijn graphs represented by simplitigs based on the
left-to-right reordering, and 3) phylogenetic compression of de Bruijn graphs using bottom-up k-mer propagation using
ProPhyle. 

For more information about phylogenetic compression and implementation details, see the [corresponding
paper](https://www.biorxiv.org/content/10.1101/2023.04.15.536996v2) (and its
[supplementary](https://www.biorxiv.org/content/biorxiv/early/2023/04/18/2023.04.15.536996/DC1/embed/media-1.pdf)
and the associated website for the whole [MOF
framework](http://karel-brinda.github.io/mof)).


### Citation

> K. Břinda, L. Lima, S. Pignotti, N. Quinones-Olvera, K. Salikhov, R. Chikhi, G. Kucherov, Z. Iqbal, and M. Baym. **Efficient and Robust Search of Microbial Genomes via Phylogenetic Compression.** bioRxiv 2023.04.15.536996, 2023. https://doi.org/10.1101/2023.04.15.536996


## Installation

### Step 1: Install dependencies

MOF-Compress is implemented as a [Snakemake](https://snakemake.github.io)
pipeline, using the Conda system to manage all non-standard dependencies. It requires the following packages pre-installed:

* [Conda](https://docs.conda.io/en/latest/miniconda.html)
* [GNU Make](https://www.gnu.org/software/make/)
* [Python](https://www.python.org/) (>=3.7)
* [Snakemake](https://snakemake.github.io) (>=6.2.0)
* [Mamba](https://mamba.readthedocs.io/) (>= 0.20.0) - optional, recommended

The last three packages can be installed using Conda by running
```bash
    conda install -c conda-forge -c bioconda -c defaults -y "make python>=3.7" "snakemake>=6.2.0" "mamba>=0.20.0"
```


### Step 2: Clone the repository

```bash
   git clone https://github.com/karel-brinda/mof-compress
   cd mof-compress
```

### Step 3: Run a simple test

Run `make test` to ensure the pipeline works for the sample data present in the [`.test` directory](.test).

**Notes:**
* `make test` should display the following message on a successful exection:
```
94 of 94 steps (100%) done
```

## Usage

### Step 1: Adjust configuration

Edit the [`config.yaml`](config.yaml) file for your desired search. All available options are
documented directly there.

See the [test config](.test/config.yaml) and the [test input dir](.test/resources) for an example.

### Step 2: Run the pipeline

Simply run `make`, which will execute Snakemake with the corresponding parameters.

### Step 3: Analyze your results

Check the output files in `output_dir` (defined in `config.yaml`).

If the results don't correspond to what you expected and you need to re-adjust your parameters, go to Step 1.

## Additional information

### List of workflow commands

MOF-Compress is executed via [GNU Make](https://www.gnu.org/software/make/), which handles all parameters and passes them to Snakemake.

Here's a list of all implemented commands (to be executed as `make {command}`):


```
######################
## General commands ##
######################
all         Run everything (the default rule)
report      Create html report
test        Run the workflow on test data
testreport  Create html report for the test dir
cleanall    Clean all
clean       Clean
format      Reformat source codes
help        Print help message
rmstats     Remove stats
```

### Directories in the output dir

* `asm/`: TODO
* `post/`: TODO
* `pre/`: TODO
* `stats/`: TODO
* `tree/`: TODO
* `global_stats.tsv`: TODO


## License

[MIT](https://github.com/karel-brinda/mof-search/blob/master/LICENSE)

## Contacts

* [Karel Brinda](http://karel-brinda.github.io) \<karel.brinda@inria.fr\>
* [Leandro Lima](https://github.com/leoisl) \<leandro@ebi.ac.uk\>

