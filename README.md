# MOF-Compress

<p>
<img src="docs/logo.png" align="left" style="width:100px;" />
Workflow for <a href="http://brinda.eu/mof">phylogenetic compression</a>
of microbial genomes (produces a highly compressed `.tar.xz` files).
MOF-Compress first estimates the evolutionary history
of the provided genomes
(or takes a user-provided phylogeny)
and uses it compress compress the genomes.
More information about the technique can be found
on the <a href="http://brinda.eu/mof">website of phylogenetic compression</a>
or in the <a href="http://doi.org/10.1101/2023.04.15.536996">associated paper</a>.
</p>
<br />

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

MOF-Compress is implemented as a Snakemake pipeline,
with automatic installation of dependencies using Conda.

It is assumed that the input genomes are already split into batches of
phylogenetically related genomes, of up to ≈10k genomes per batch
(for more information about how to perform batching,
see the [paper](http://doi.org/10.1101/2023.04.15.536996)).

The user then provides files of files for individual batches
into the `input/` directory (possibly accompanied with phylogenies,
otherwise they will be estimated by MashTree),
and specifies the requested compression protocol in the
[configuration file](config.yaml).

This pipeline then performs phylogenetic compression of all batches,
and calculates the associated statistics, using the following protocols:
<ol>
<li> phylogenetic compression of assemblies based on a left-to-right reordering (<b>the default protocol</b>),
<li> phylogenetic compression of de Bruijn graphs represented by simplitigs based on the left-to-right reordering (optional),
<li> phylogenetic compression of de Bruijn graphs using bottom-up <i>k</i>-mer propagation using ProPhyle (optional).
</ol>

## Installation

### Dependencies

**The essential dependencies** include

* [Conda](https://docs.conda.io/en/latest/miniconda.html) (unless the use of Conda is switched off in the configuration), ideally also [Mamba](https://mamba.readthedocs.io/) (>= 0.20.0)
* [GNU Make](https://www.gnu.org/software/make/)
* [Python](https://www.python.org/) (>=3.7)
* [Snakemake](https://snakemake.github.io) (>=6.2.0)

and can be installed by Conda by
```bash
    conda install -c conda-forge -c bioconda -c defaults \\
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

K. Břinda, L. Lima, S. Pignotti, N. Quinones-Olvera, K. Salikhov, R. Chikhi, G. Kucherov, Z. Iqbal, and M. Baym. **Efficient and Robust Search of Microbial Genomes via Phylogenetic Compression.** bioRxiv 2023.04.15.536996, 2023. https://doi.org/10.1101/2023.04.15.536996

```
@article {B{\v r}inda2023.04.15.536996,
  author = {Karel B{\v r}inda and Leandro Lima and Simone Pignotti
    and Natalia Quinones-Olvera and Kamil Salikhov and Rayan Chikhi
    and Gregory Kucherov and Zamin Iqbal and Michael Baym},
  title = {Efficient and Robust Search of Microbial Genomes via Phylogenetic Compression},
  elocation-id = {2023.04.15.536996},
  year = {2023},
  doi = {10.1101/2023.04.15.536996},
  URL = {https://www.biorxiv.org/content/early/2023/04/16/2023.04.15.536996},
  journal = {bioRxiv}
}
```


## License

[MIT](https://github.com/karel-brinda/mof-search/blob/master/LICENSE)

## Contacts

* [Karel Brinda](http://karel-brinda.github.io) \<karel.brinda@inria.fr\>
* [Leandro Lima](https://github.com/leoisl) \<leandro@ebi.ac.uk\>

