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
    if config["generate_assembly_stats"]:
        stats_files.extend(
            (
                fn_asm_hist_summary(_batch="{batch}"),
                fn_asm_nscl_summary(_batch="{batch}"),
                fn_asm_compr_summary(_batch="{batch}"),
                fn_asm_seq_gz_sizegram_summary(_batch="{batch}"),
            )
        )
    if config["generate_prepropagation_stats"]:
        stats_files.extend(
            (
                fn_pre_hist_summary(_batch="{batch}"),
                fn_pre_nscl_summary(_batch="{batch}"),
                fn_pre_compr_summary(_batch="{batch}"),
            )
        )
    if config["generate_postpropagation_stats"]:
        stats_files.extend(
            (
                fn_post_hist_summary(_batch="{batch}"),
                fn_post_nscl_summary(_batch="{batch}"),
                fn_post_compr_summary(_batch="{batch}"),
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
