# MOF-Compress

<p>
<a href="https://github.com/karel-brinda/mof-compress">
    <img src="docs/logo.png" align="left" style="width:100px;" />
</a>
Workflow for <a href="http://brinda.eu/mof">phylogenetic compression</a>
of microbial genomes, producing highly compressed <code>.tar.xz</code> genome archives.
MOF-Compress first estimates the phylogeny
of the user-provided genomes
(unless they are provided with a phylogeny),
and uses the tree for guiding their compression.
More information about the technique can be found
on the <a href="http://brinda.eu/mof">website of phylogenetic compression</a>
and in the <a href="http://doi.org/10.1101/2023.04.15.536996">associated paper</a>.
</p><br/>

[![Info](https://img.shields.io/badge/Project-Info-blue)](https://brinda.eu/mof)
[![Paper DOI](https://zenodo.org/badge/DOI/10.1101/2023.04.15.536996.svg)](https://doi.org/10.1101/2023.04.15.536996)
[![MOF-Compress test](https://github.com/karel-brinda/mof-compress/actions/workflows/main.yaml/badge.svg)](https://github.com/karel-brinda/mof-compress/actions/)
[![GitHub release](https://img.shields.io/github/release/karel-brinda/mof-compress.svg)](https://github.com/karel-brinda/mof-compress/releases/)

<h2>Contents</h2>

<!-- vim-markdown-toc GFM -->

* [1. Introduction](#1-introduction)
* [2. Dependencies](#2-dependencies)
  * [2a. Essential dependencies](#2a-essential-dependencies)
  * [2b. Protocol-specific dependencies](#2b-protocol-specific-dependencies)
* [Installation](#installation)
* [3. Usage](#3-usage)
  * [3a. Basic example](#3a-basic-example)
  * [3b. Adjusting configuration](#3b-adjusting-configuration)
  * [3c. List of implemented protocols](#3c-list-of-implemented-protocols)
  * [3d. List of workflow commands](#3d-list-of-workflow-commands)
  * [3e. Troubleshooting](#3e-troubleshooting)
* [4. Citation](#4-citation)
* [5. Issues](#5-issues)
* [6. Changelog](#6-changelog)
* [7. License](#7-license)
* [8. Contacts](#8-contacts)

<!-- vim-markdown-toc -->


## 1. Introduction

It is assumed that the input genomes are provided as batches of
phylogenetically related genomes, of up to approx. 10k genomes per batch
(for more information on batching strategies,
see the [paper](http://doi.org/10.1101/2023.04.15.536996)).

The user provides files of files for individual batches
in the `input/` directory
and specifies the requested compression protocols in the
[configuration file](config.yaml).

Upon execution of the pipeline by `make`,
MOF-Compress performs phylogenetic compression,
and the compressed output can then be found in `output/`.



## 2. Dependencies

### 2a. Essential dependencies

* [Conda](https://docs.conda.io/en/latest/miniconda.html) (unless the use of Conda is switched off in the configuration), ideally also [Mamba](https://mamba.readthedocs.io/) (>= 0.20.0)
* [GNU Make](https://www.gnu.org/software/make/)
* [Python](https://www.python.org/) (>=3.7)
* [Snakemake](https://snakemake.github.io) (>=6.2.0)

and can be installed by Conda by
```bash
    conda install -c conda-forge -c bioconda -c defaults \
      "make python>=3.7" "snakemake>=6.2.0" "mamba>=0.20.0"
```

### 2b. Protocol-specific dependencies

These are installed automatically by
Snakemake when they are required/
Their lists can be found in [`workflow/envs/`](workflow/envs/)
and involve ETE 3, Seqtk, Xopen, Pandas, Jellyfish (v2),
Mashtree, ProphAsm, and ProPhyle. For instance, ProPhyle is
not installed unless Protocol 3 is used.

The installation of all non-essential dependencies across
all protocols can also be achieved by:

```bash
   make conda
```



## Installation

Clone the repository and enter the directory by

```bash
   git clone https://github.com/karel-brinda/mof-compress
   cd mof-compress
```



## 3. Usage

### 3a. Basic example

<h4><i>Step 1:</i> Provide lists of input files</h4>

For every batch, create a txt list of input files in the `input/`
directory (i.e., as `input/{batch_name}.txt`. Use either absolute paths (recommended),
or paths relative to the root of the Github repository (not relative to the txt files).

Such lists can generated, for instance, by `find` by something like:
```
find /home/data/genomes -name '*.fa' > input/my_first_batch.txt
```

The supported input file formats include FASTA and FASTQ, possibly gzipped.


<h4><i>Step 2 (optional):</i> Provide corresponding phylogenies</h4>

In the default setting, phylogenies are estimated using MashTree,
which already provides a sufficiently good resolution.

In case you want to use custom phylogenies (in Newick),
put them into `input/{batch_name}.nw`. Leave names should correspond
to the names of your input FASTA files without the FASTA suffixes.


<h4><i>Step 3 (optional):</i> Adjust configuration</h4>

Edit the [`config.yaml`](config.yaml) to specify compression protocols and data analyzes
to be included, as well as specific parameters.


<h4><i>Step 4:</i> Run the pipeline</h4>

Run the pipeline by `make`. This will execute Snakemake with the corresponding parameters.


<h4><i>Step 5:</i> Retrieve the output files</h4>

All output files will be located in `output/`.


### 3b. Adjusting configuration

The workflow can be configured via the [`config.yaml`](./config.yaml) file.
All options are documented directly there.

The configurable functionality includes:
* switching off Conda
* protocols to use (asm, dGSs, dBGs with propagation)
* analyzes to include (sequence and k-mer statistics)
* k for de Bruijn graph and k-mer counting
* Mashtree parameters (phylogeny estimation)
* XZ parameters (low-level compression)
* JellyFish parameters (k-mer counting)


### 3c. List of implemented protocols

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
    original assemblies in FASTA  (<b>(1)</b>)


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
    <a href="https://doi.org/10.1186/s13059-021-02297-z">simplitigs</a>at individual nodes of the tree,
    and left-to-right re-ordering of the obtained files

  <td>
    <code>output/post/{batch}.tar.xz</code><br/>
    <code>output/post/{batch}.nw</code><br/>
    simplitig text files per individual nodes of the tree (<b>(2)</b>)

</table>


<small>
  <b>(1):</b> In 1 line format and sequences in uppercase.
  <br />
  <b>(2):</b> For obtaining the represented de Bruijn graphs,
  one needs to merge <i>k</i>-mer sets along
  the respetive root-to-leaf paths.
</small>


### 3d. List of workflow commands

MOF-Compress is executed via [GNU Make](https://www.gnu.org/software/make/), which handles all parameters and passes them to Snakemake.
Here's a list of all implemented commands (to be executed as `make {command}`):


```
all           Run everything
checkformat   Check source code format (developers)
clean         Clean
cleanall      Clean all
conda         Create the conda environments
format        Reformat all source code (developers)
help          Print help message
report        Create html report
rmstats       Remove stats
test          Run the workflow on test data
testreport    Create html report for the test
```


### 3e. Troubleshooting

Tests can be run by

```bash
   make test
```


## 4. Citation

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


## 5. Issues

Please use [Github issues](https://github.com/karel-brinda/mof-compress/issues).



## 6. Changelog

See [Releases](https://github.com/karel-brinda/mof-compress/releases).



## 7. License

[MIT](https://github.com/karel-brinda/mof-search/blob/master/LICENSE)



## 8. Contacts

* [Karel Brinda](http://karel-brinda.github.io) \<karel.brinda@inria.fr\>
* [Leandro Lima](https://github.com/leoisl) \<leandro@ebi.ac.uk\>
