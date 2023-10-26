rule global_stats:
    input:
        [fn_stats_batch_global(batch) for batch in get_batches()],
    output:
        fn_stats_global(),
    params:
        s=snakemake.workflow.srcdir("../scripts/merge_global_stats.py"),
    conda:
        "../envs/env.yaml"
    shell:
        """
        {params.s} {input} > {output}
        """


def get_stats_files():
    stats_files = []

    for protocol in "asm", "pre", "post":
        if config[f"compress_{protocol}"]:
            if config["kmer_histograms"]:
                stats_files.append(fn_hist_summary(_batch="{batch}", protocol=protocol))

            stats_files.extend(
                (
                    fn_nscl_summary(_batch="{batch}", protocol=protocol),
                    fn_compr_summary(_batch="{batch}", protocol=protocol),
                )
            )

    return stats_files


rule stats_global_sample:
    input:
        get_stats_files(),
    output:
        fn_stats_batch_global(_batch="{batch}"),
    shell:
        """
        (
            printf 'batch\t%s\n' {wildcards.batch}
            cat {input}
        )> {output}
        """
