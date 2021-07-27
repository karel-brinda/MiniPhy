from snakemake.utils import validate
import collections
import glob

import pandas as pd

from pprint import pprint

# this container defines the underlying OS for each job when using the workflow
# with --use-conda --use-singularity
#singularity: "docker://continuumio/miniconda3"

##### load config and sample sheets #####

#configfile: "config/config.yaml"
#validate(config, schema="../schemas/config.schema.yaml")

#samples = pd.read_csv(config["samples"], sep="\t").set_index("sample", drop=False)
#samples.index.names = ["sample_id"]
#validate(samples, schema="../schemas/samples.schema.yaml")




# extract sample name from a path
def _get_sample_from_fn(x):
    suffixes=["fa", "fasta", "fna", "ffa"]

    b=os.path.basename(x)
    if b.endswith(".gz"):
        b=x[:-3]
    sample,_,suffix=b.rpartition(".")
    assert suffix in suffixes, f"Unknown suffix of source files ({suffix} in {x})"
    return sample

# compute main dict for batches
BATCHES_FN={}
res=glob.glob("resources/*.txt")
for x in res:
    b=os.path.basename(x)
    if not b.endswith(".txt"):
        continue
    batch=b[:-4]
    BATCHES_FN[batch]={}
    with open(x) as f:
        for y in  f:
            sample_fn=y.strip()
            if sample_fn:
                sample=_get_sample_from_fn(sample_fn)
                BATCHES_FN[batch][sample]=sample_fn

pprint(BATCHES_FN)


## BATCHES

def get_batches():
   return BATCHES_FN.keys()


## FILE PATHS

# *_list - list of files for compression in that order
# *_seq - files with sequences (fa / simpl
# *_compr - compressed dataset


def fn_tree(_batch):
    return f"results/tree/{_batch}.nw"

#

def fn_asm_list(_batch):
    return f"results/asm/{_batch}.list"

def fn_asm_seq(_batch, _sample):
    return f"results/asm/{batch}/{sample}.fa"

def fn_asm_compr(_batch, _sample):
    return f"results/asm/{batch}.tar.xz"

#

def fn_pre_list(_batch):
    return f"results/pre/{_batch}.list"

def fn_pre_seq(_batch, _sample):
    return f"results/pre/{_batch}/{_sample}.simpl"

def fn_pre_compr(_batch):
    return f"results/pre/{_batch}.tar.xz"


#

def fn_post_list(_batch):
    return f"results/pre/{_batch}.list"

def fn_post_seq(_batch, _sample):
    return f"results/post/{_batch}/{_sample}.simpl"

def fn_post_compr(_batch):
    return f"results/post/{_batch}.tar.xz"



## WILDCARD FUNCTIONS

# get source file path from batch & sample
def w_sample_source(wildcards):
    return BATCHES_FN[wildcards.batch][wildcards.sample]

# get source file paths from batch
def w_batch_asms(wildcards):
    batch=wildcards["batch"]
    l = [fn_asm_seq(batch, sample) for sample in BATCHES_FN[batch]]
    return l

## get pre propagation simplitig files from batch & sample
def w_batch_pres(wildcards):
    batch=wildcards["batch"]
    l = [fn_pre_seq(batch, sample) for sample in BATCHES_FN[batch]]
    return l