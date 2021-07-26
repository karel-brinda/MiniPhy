from snakemake.utils import validate
import collections
import glob

import pandas as pd

from pprint import pprint

# this container defines the underlying OS for each job when using the workflow
# with --use-conda --use-singularity
singularity: "docker://continuumio/miniconda3"

##### load config and sample sheets #####

configfile: "config/config.yaml"
validate(config, schema="../schemas/config.schema.yaml")

#samples = pd.read_csv(config["samples"], sep="\t").set_index("sample", drop=False)
#samples.index.names = ["sample_id"]
#validate(samples, schema="../schemas/samples.schema.yaml")

BATCHES_FN={}

def _get_sample_from_fn(x):
    suffixes=["fa", "fasta", "fna", "ffa"]

    b=os.path.basename(x)
    if b.endswith(".gz"):
        b=x[:-3]
    sample,_,suffix=b.rpartition(".")
    assert suffix in suffixes, f"Unknown suffix of source files ({suffix} in {x})"
    return sample

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

def get_seq_source_path(wildcards):
    return BATCHES_FN[wildcards.batch][wildcards.sample]
    #pass


###

def get_asm_fa(batch, sample):
    return f"results/asm/{batch}/{sample}.fa"

def get_asms_batch(wildcards):
    batch=wildcards["batch"]
    l = [get_asm_fa(batch, sample) for sample in BATCHES_FN[batch]]
    return l

###

def get_pre_fa(batch, sample):
    return f"results/pre/{batch}/{sample}.txt"

def get_pres_batch(wildcards):
    batch=wildcards["batch"]
    l = [get_pre_fa(batch, sample) for sample in BATCHES_FN[batch]]
    return l

###

def get_batches():
    return BATCHES_FN.keys()

def get_samples_from_batch(x):
    #return BATCHES[x]
    pass

def get_sample_source_file(wildcards):
    pass

