"""
    2 types of statistics to compute:
    - batch statistics: 1 record per batch; 1 file
    - genome statistics: 1 record per genome, 1 file per 1 batch
"""


rule stats_batches:
    """
    Create global statistics file by merging individual stats from all batches
    """
    output:
        fn_stats_batches(),
    input:
        [fn_stats_batches_1batch(_batch=batch) for batch in get_batches()],
    params:
        s=snakemake.workflow.srcdir("../scripts/merge_global_stats.py"),
    conda:
        "../envs/basic_env.yaml"
    shell:
        """
        {params.s} {input} > {output}
        """


def get_stats_files(protocol):
    stats_files = []

    if config[f"protocol_{protocol}"]:
        if config["kmer_counting"]:
            stats_files.append(fn_hist_summary(_batch="{batch}", _protocol=protocol))

        if config["nscl_analyses"]:
            stats_files.append(fn_nscl_summary(_batch="{batch}", _protocol=protocol))

        stats_files.append(fn_compr_summary(_batch="{batch}", _protocol=protocol))

    return stats_files


rule stats_batches_1batch:
    """
    For a given batch, merge stats from individual protocols
    """
    output:
        fn_stats_batches_1batch(_batch="{batch}"),
    input:
        [get_stats_files(protocol=x) for x in ("asm", "pre", "post")],
    shell:
        """
        (
            printf 'batch\t%s\n' {wildcards.batch}
            cat {input}
        )> {output}
        """
