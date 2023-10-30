# MOF-Compress

<p>
<img src="docs/logo.png" align="left" style="width:100px;" />
Workflow for <a href="http://brinda.eu/mof">phylogenetic compression</a>
of microbial genomes (produces a highly compressed <code>.tar.xz</code> files).
MOF-Compress first estimates the evolutionary history
of user-provided genomes
(unless a phylogeny is provided by the user),
and uses it compress compress the genomes.
More information about the technique can be found
on the <a href="http://brinda.eu/mof">website of phylogenetic compression</a>
or in the <a href="http://doi.org/10.1101/2023.04.15.536996">associated paper</a>.
</p>
<br />

![MOF-Compress test]([https://github.com/karel-brinda/mof-compress/actions/workflows/main.yml/badge.svg](https://github.com/karel-brinda/mof-compress/actions/workflows/main.yaml/badge.svg))

<h2>Contents</h2>

<!-- vim-markdown-toc GFM -->

* [Introduction](#introduction)
* [Installation](#installation)
  * [Dependencies](#dependencies)
  * [Installation](#installation-1)
  * [Automatic installation of dependencies](#automatic-installation-of-dependencies)
* [Usage (basic)](#usage-basic)
* [Usage (advanced)](#usage-advanced)
* [Troubleshooting](#troubleshooting)
* [Citation](#citation)
* [License](#license)
* [Contacts](#contacts)

<!-- vim-markdown-toc -->


## Introduction

It is assumed that the input genomes are provided as batches of
phylogenetically related genomes, of up to ≈10k genomes per batch
(for more information on batching strategies,
see the [paper](http://doi.org/10.1101/2023.04.15.536996)).

The user then provides files of files for individual batches
into the `input/` directory
and specifies the requested compression protocol in the
[configuration file](config.yaml).

MOF-Compress then performs phylogenetic compression of all batches,
and calculates the associated statistics, using one or more of the following protocols.




## Installation

### Dependencies

**The essential dependencies** include

* [Conda](https://docs.conda.io/en/latest/miniconda.html) (unless the use of Conda is switched off in the configuration), ideally also [Mamba](https://mamba.readthedocs.io/) (>= 0.20.0)
* [GNU Make](https://www.gnu.org/software/make/)
* [Python](https://www.python.org/) (>=3.7)
* [Snakemake](https://snakemake.github.io) (>=6.2.0)

and can be installed by Conda by
```bash
    conda install -c conda-forge -c bioconda -c defaults \
      "make python>=3.7" "snakemake>=6.2.0" "mamba>=0.20.0"
```

**Protocol-specific dependencies** are installed automatically by
Snakemake and they are required;
their lists can be found in [`workflow/envs/`](workflow/envs/)
and involve ETE 3, Seqtk, Xopen, Pandas, Jellyfish (v2),
Mashtree, ProphAsm, and ProPhyle. For instance, ProPhyle is
not installed unless Protocol 3 is used for compression.


### Installation

Just clone and enter the repository:

```bash
   git clone https://github.com/karel-brinda/mof-compress
   cd mof-compress
```

### Automatic installation of dependencies

All non-essential dependencies will be installated autoamtically
by Snakemake. To invoke installation all non-essential dependencies across
all protocols manually, run:

```bash
   make conda
```


## Usage (basic)

**Step 1: Provide your input files.**
Individual batches of genomes in the `.fa[.gz]` formats are to be specified
in the form of files of files in the `input/` directory,
as a file `{batch_name}.txt`. Use either absolute paths (recommended),
or paths relative to the root of the Github repository.


**Step 2: Adjust configuration.**
Edit the [`config.yaml`](config.yaml) to specify the compression protocols to be used, as well as all options for individual programs.
All available options are documented directly there.

**Step 3: Run the pipeline.**
Simply run `make`, which will execute Snakemake with the corresponding parameters. The computed files will then be located in `output/`.



## Usage (advanced)


<table>

<thead>
  <td>Protocol
  <td>Compressed representation
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
    original assemblies in FASTA


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
    simplitig text files per individual nodes of the tree.

</table>


(1) In 1 line format and sequences in uppercase.

(2) For obtaining the represented de Bruijn graphs,
  one needs to merge <i>k</i>-mer sets along
  the respetive root-to-leaf paths.



**Final product:**



**List of workflow commands.**
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
```

## Troubleshooting

```bash
   make test
```


## Citation

> K. Břinda, L. Lima, S. Pignotti, N. Quinones-Olvera, K. Salikhov, R. Chikhi, G. Kucherov, Z. Iqbal, and M. Baym. **[Efficient and Robust Search of Microbial Genomes via Phylogenetic Compression](https://doi.org/10.1101/2023.04.15.536996).** *bioRxiv* 2023.04.15.536996, 2023. https://doi.org/10.1101/2023.04.15.536996

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


## License

[MIT](https://github.com/karel-brinda/mof-search/blob/master/LICENSE)

## Contacts

* [Karel Brinda](http://karel-brinda.github.io) \<karel.brinda@inria.fr\>
* [Leandro Lima](https://github.com/leoisl) \<leandro@ebi.ac.uk\>

