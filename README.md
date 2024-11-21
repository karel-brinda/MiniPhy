# MiniPhy – Minimization via Phylogenetic compression (former MOF-Compress)


<p>
<a href="https://brinda.eu/mof">
    <img src="docs/logo_wbg.svg" align="left" style="width:100px;" />
</a>
Workflow for <a href="http://brinda.eu/mof">phylogenetic compression</a>
of microbial genomes, producing highly compressed <code>.tar.xz</code> genome archives.
MiniPhy first estimates the evolutionary history
of user-provided genomes
and then uses it for guiding their compression using XZ.
The resulting archives can be distributed to users or
re-compressed/indexed by other methods.
For more information,
see the <a href="https://brinda.eu/mof">website of phylogenetic compression</a>
and the <a href="https://doi.org/10.1101/2023.04.15.536996">associated paper</a>.
</p><br/>

[![Info](https://img.shields.io/badge/Project-Info-blue)](https://brinda.eu/mof)
[![Paper DOI](https://img.shields.io/badge/paper-10.1101/2023.04.15.536996-14dc3d.svg)](https://doi.org/10.1101/2023.04.15.536996)
[![GitHub release](https://img.shields.io/github/release/karel-brinda/miniphy.svg)](https://github.com/karel-brinda/miniphy/releases/)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.10636846.svg)](https://doi.org/10.5281/zenodo.10636846)
[![MiniPhy test](https://github.com/karel-brinda/miniphy/actions/workflows/main.yaml/badge.svg)](https://github.com/karel-brinda/miniphy/actions/)


<h2>Contents</h2>

<!-- vim-markdown-toc GFM -->

* [1. Introduction](#1-introduction)
* [2. Dependencies](#2-dependencies)
    * [2a. Essential dependencies](#2a-essential-dependencies)
    * [2b. Protocol-specific dependencies](#2b-protocol-specific-dependencies)
* [3. Installation](#3-installation)
* [4. Usage](#4-usage)
    * [4a. Basic example](#4a-basic-example)
    * [4b. Adjusting configuration](#4b-adjusting-configuration)
    * [4c. List of implemented protocols](#4c-list-of-implemented-protocols)
    * [4d. List of workflow commands](#4d-list-of-workflow-commands)
    * [4e. Running on a cluster](#4e-running-on-a-cluster)
    * [4f. Troubleshooting](#4f-troubleshooting)
* [5. Citation](#5-citation)
* [6. Issues](#6-issues)
* [7. Changelog](#7-changelog)
* [8. License](#8-license)
* [9. Contacts](#9-contacts)

<!-- vim-markdown-toc -->


## 1. Introduction

The user provides files of files for individual batches
in the `input/` directory
and specifies the requested compression protocols in the
[configuration file](config.yaml).
It is assumed that the input genomes are provided as batches of
phylogenetically related genomes, of up to approx. 10k genomes per batch
(for more information on batching strategies,
see the [paper](http://doi.org/10.1101/2023.04.15.536996)).
Upon the execution by `make`,
MiniPhy performs phylogenetic compression
of the assemblies or associated de Bruijn graphs.
All the compressed outputs and the calculated statistics
are then placed in `output/`.



## 2. Dependencies

### 2a. Essential dependencies

* [Conda](https://docs.conda.io/en/latest/miniconda.html) (unless the use of Conda is switched off in the configuration) and ideally also [Mamba](https://mamba.readthedocs.io/) (>= 0.20.0)
* [GNU Make](https://www.gnu.org/software/make/)
* [Python](https://www.python.org/) (>=3.7)
* [Snakemake](https://snakemake.github.io) (>=6.2.0)
* [XZ](https://tukaani.org/xz/)

and can be installed by Conda by
```bash
conda install -c conda-forge -c bioconda -c defaults \
  make "python>=3.7" "snakemake-minimal>=6.2.0" "mamba>=0.20.0"
```

### 2b. Protocol-specific dependencies

These are installed automatically by
Snakemake when they are requested;
for instance, ProPhyle is not installed unless Protocol 3 is used.
The specifications of individual environments
can be found in [`workflow/envs/`](workflow/envs/),
and they contain:
[Attotree](https://github.com/karel-brinda/attotree),
[ETE 3](http://etetoolkit.org/),
[SeqTK](https://github.com/lh3/seqtk),
[xopen](https://pypi.org/project/xopen/),
[Pandas](https://pandas.pydata.org/),
[Jellyfish 2](https://github.com/gmarcais/Jellyfish),
[ProphAsm](https://github.com/prophyle/prophasm),
and [ProPhyle](https://prophyle.github.io).


All non-essential dependencies across all protocols can also be
installed at once by `make conda`.



## 3. Installation

Clone and enter the repository by

```bash
git clone https://github.com/karel-brinda/miniphy
cd miniphy
```

Alternatively, the repository can also be installed using cURL by
```bash
mkdir miniphy
cd miniphy
curl -L https://github.com/karel-brinda/miniphy/tarball/main \
    | tar xvf - --strip-components=1
```


## 4. Usage

### 4a. Basic example

* ***Step 1: Provide lists of input files.*** \
  For every batch, create a txt list of input files in the `input/`
  directory (i.e., as `input/{batch_name}.txt`. Use either absolute paths (recommended),
  or paths relative to the root of the Github repository (not relative to the txt files).

  Such a list can be generated, for instance, by `find` by
  ```bash
  find ~/dir_with_my_genomes -name '*.fa' > input/my_first_batch.txt
  ```
  The supported input file formats include FASTA and FASTQ (possibly compressed by GZip).

* ***Step 2 (optional): Provide corresponding phylogenies.*** \
  Instead of estimating phylogenies by [Attotree](https://github.com/karel-brinda/attotree)
  (similar functionality like [Mashtree](https://github.com/lskatz/mashtree)),
  it is possible to supply custom phylogenies in the Newick format.
  The tree files should be named `input/{batch_name}.nw`,
  and the leave names inside should correspond
  to FASTA filenames (without FASTA suffixes).

* ***Step 3 (optional): Adjust configuration.*** \
  By editing [`config.yaml`](config.yaml) it is possible to specify
  compression protocols, data analyzes,
  and low-level parameters (see below).

* ***Step 4: Run the pipeline.*** \
  Run the pipeline by `make`; this is run
  Snakemake with the corresponding parameters.

* ***Step 5: Retrieve the output files.*** \
  All output files will be located in `output/`.


### 4b. Adjusting configuration

The workflow can be configured via the [`config.yaml`](./config.yaml) file, and
all options are documented directly there. The configurable functionality includes:
* switching off Conda,
* protocols to use (asm, dGSs, dBGs with propagation),
* analyzes to include (sequence and *k*-mer statistics),
* *k* for de Bruijn graph and *k*-mer counting,
* Attotree parameters (phylogeny estimation),
* XZ parameters (low-level compression), or
* JellyFish parameters (*k*-mer counting).


### 4c. List of implemented protocols

<table>

<thead>
  <td>Protocol
  <td>Representation
  <td>Description
  <td>Product


<tr>

  <td>
    <b>Protocol&nbsp;1<br />
    (default)</b>

  <td>
    Assemblies

  <td>
    Left-to-right reordering of the assemblies according to the phylogeny

  <td>
    <code>output/asm/{batch}.tar.xz</code><br/>
    original assemblies in FASTA <sup><b>(1)</b></sup>


<tr>

  <td>
    <b>Protocol&nbsp;2</b><br />
    (optional)

  <td>
    de Bruijn graphs

  <td>
    <a href="https://doi.org/10.1186/s13059-021-02297-z">Simplitigs</a>
    from individual assemblies, left-to-right reordering of their files

  <td>
    <code>output/pre/{batch}.tar.xz</code><br/>
    with simplitig text files,
    representing individual de Bruijn graphs


<tr>

  <td>
    <b>Protocol&nbsp;3</b><br />
    (optional)

  <td>
    de Bruijn graphs

  <td>
    Bottom-up <i>k</i>-mer propagation using <a href="http://prophyle.github.io">ProPhyle</a>,
    <a href="https://doi.org/10.1186/s13059-021-02297-z">simplitigs</a>
    at individual nodes of the tree, and left-to-right re-ordering of the obtained files

  <td>
    <code>output/post/{batch}.tar.xz</code><br/>
    <code>output/post/{batch}.nw</code><br/>
    simplitig text files per individual nodes of the tree <sup><b>(2)</b></sup>

</table>


<small>
  <sup><b>(1)</b></sup> In FASTA 1-line format and all sequences converted to uppercase
  (unless switche off in the configuration).
  <br />
  <sup><b>(2)</b></sup> The original de Bruijn graphs can
  be obtained by merging <i>k</i>-mer sets along
  the respetive root-to-leaf paths.
</small>


### 4d. List of workflow commands

MiniPhy is executed via [GNU Make](https://www.gnu.org/software/make/), which handles all parameters and passes them to Snakemake.
Here's a list of all implemented commands (to be executed as `make {command}`):


```yaml
######################
## General commands ##
######################
    all                  Run everything (the default subcommand)
    help                 Print help messages
    conda                Create the conda environments
    clean                Clean all output archives and files with statistics
    cleanall             Clean everything but Conda, Snakemake, and input files
    cleanallall          Clean completely everything
###############
## Reporting ##
###############
    viewconf             View configuration without comments
    reports              Create html report
####################
## For developers ##
####################
    test                 Run the workflow on test data (P1)
    bigtest              Run the workflow on test data (P1, P2, P3)
    format               Reformat all source code
    checkformat          Check source code format
```

*Note:* `make format` and `make checkformat` require
[YAPF](https://github.com/google/yapf) and
[Snakefmt](https://github.com/snakemake/snakefmt), which can be installed by
`conda install -c conda-forge -bioconda yapf snakefmt`.



### 4e. Running on a cluster

Cluster-related parameters for Snakemake can be added via the `SMK_CLUSTER_ARGS` Make variable.

Example:
```bash
make SMK_CLUSTER_ARGS="--profile my_snakemake_cluster_profile"
```


### 4f. Troubleshooting

Tests can be run by `make test` (just Protocol 1) or `make bigtest` (all the protocols).


## 5. Citation

> K. Brinda, L. Lima, S. Pignotti, N. Quinones-Olvera, K. Salikhov, R. Chikhi, G. Kucherov, Z. Iqbal, and M. Baym. **[Efficient and Robust Search of Microbial Genomes via Phylogenetic Compression](https://doi.org/10.1101/2023.04.15.536996).** *bioRxiv* 2023.04.15.536996, 2023. https://doi.org/10.1101/2023.04.15.536996

```bibtex
@article {PhylogeneticCompression,
   author  = {Karel B{\v r}inda and Leandro Lima and Simone Pignotti
               and Natalia Quinones-Olvera and Kamil Salikhov and Rayan Chikhi
               and Gregory Kucherov and Zamin Iqbal and Michael Baym},
   title   = {Efficient and Robust Search of Microbial Genomes via Phylogenetic Compression},
   journal = {bioRxiv},
   elocation-id = {2023.04.15.536996},
   year    = {2023},
   doi     = {10.1101/2023.04.15.536996},
   url     = {https://www.biorxiv.org/content/early/2023/04/16/2023.04.15.536996}
}
```


## 6. Issues

Please use [Github issues](https://github.com/karel-brinda/miniphy/issues).



## 7. Changelog

See [Releases](https://github.com/karel-brinda/miniphy/releases).



## 8. License

[MIT](https://github.com/karel-brinda/miniphy/blob/master/LICENSE)



## 9. Contacts

* [Karel Brinda](https://brinda.eu) \<karel.brinda@inria.fr\>
* [Leandro Lima](https://github.com/leoisl) \<leandro@ebi.ac.uk\>
