# MOF-Compress


<p>
<img src="docs/logo.png" align="left" style="width:100px;" />
MOF-Compress is a central package of MOF that performs phylogenetic compression, a technique based
on using estimated evolutionary history to guide compression and efficiently
search large collections of microbial genomes using existing algorithms and
data structures. In short, input data are reorganized according to the topology
of the estimated phylogenies, which makes data highly locally compressible even
using basic techniques.
</p>
<br />

<h2>Contents</h2>

<!-- vim-markdown-toc GFM -->

* [Introduction](#introduction)
  * [Citation](#citation)
* [Installation](#installation)
* [Usage](#usage)
* [Additional information](#additional-information)
* [License](#license)
* [Contacts](#contacts)

<!-- vim-markdown-toc -->


## Introduction

This pipeline performs phylogenetic compression of one or more genome batches,
and calculates the associated statistics, using the following protocols:
<ol>
<li> phylogenetic compression of assemblies based on a left-to-right reordering
<li> phylogenetic compression of de Bruijn graphs represented by simplitigs based on the left-to-right reordering
<li> phylogenetic compression of de Bruijn graphs using bottom-up k-mer propagation using ProPhyle.
</ol>

For more information about phylogenetic compression and implementation details, see
the [main website](http://karel-brinda.github.io/mof)) and
the [paper](https://www.biorxiv.org/content/10.1101/2023.04.15.536996v2).


### Citation

> K. Břinda, L. Lima, S. Pignotti, N. Quinones-Olvera, K. Salikhov, R. Chikhi, G. Kucherov, Z. Iqbal, and M. Baym. **Efficient and Robust Search of Microbial Genomes via Phylogenetic Compression.** bioRxiv 2023.04.15.536996, 2023. https://doi.org/10.1101/2023.04.15.536996


## Installation

**Step 1: Install dependencies.**
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

**Step 2: Clone the repository.**

```bash
   git clone https://github.com/karel-brinda/mof-compress
   cd mof-compress
```

**Step 3 (optional): Install conda environments.**

```bash
   make conda
```

**Step 4 (optional): Run a simple test.**

```bash
   make test
```


## Usage

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

## Additional information

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


## License

[MIT](https://github.com/karel-brinda/mof-search/blob/master/LICENSE)

## Contacts

* [Karel Brinda](http://karel-brinda.github.io) \<karel.brinda@inria.fr\>
* [Leandro Lima](https://github.com/leoisl) \<leandro@ebi.ac.uk\>

