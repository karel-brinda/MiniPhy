from snakemake.utils import validate
import pandas as pd
import glob

# this container defines the underlying OS for each job when using the workflow
# with --use-conda --use-singularity
singularity: "docker://continuumio/miniconda3"

##### load config and sample sheets #####

configfile: "config/config.yaml"
validate(config, schema="../schemas/config.schema.yaml")

#samples = pd.read_csv(config["samples"], sep="\t").set_index("sample", drop=False)
#samples.index.names = ["sample_id"]
#validate(samples, schema="../schemas/samples.schema.yaml")

res=glob.glob("resources/*.txt")
for x in res:
    print(x)

BATCHES_FN=[]

def get_seq_source_path(wildcards):
    return BATCHES_FN[wildcards.batch][wildcards.sample]
    #pass

def get_asm(batch, sample):
    return "results/asm/{batch}/{sample}.fa.gz"

def get_asms_batch(wildcards):
    batch=wildcards["batch"]
    l = [get_asm(batch, sample) for sample in BATCHES_FN[batch]]
    return l


def get_batches():
    #return BATCHES.keys()
    pass

def get_samples_from_batch(x):
    #return BATCHES[x]
    pass

def get_sample_source_file(wildcards):
    pass

