rule global_stats:
    input:
        [fn_stats_batch_global(batch) for batch in get_batches()],
    output:
        fn_stats_global(),
    params:
        s=snakemake.workflow.srcdir("../scripts/merge_global_stats.py"),
    shell:
        """
        {params.s} {input} > {output}
        """


rule stats_global_sample:
    input:
        fn_asm_hist_summary(_batch="{batch}"),
        fn_asm_nscl_summary(_batch="{batch}"),
        fn_asm_compr_summary(_batch="{batch}"),
        fn_pre_hist_summary(_batch="{batch}"),
        fn_pre_nscl_summary(_batch="{batch}"),
        fn_pre_compr_summary(_batch="{batch}"),
        fn_post_hist_summary(_batch="{batch}"),
        fn_post_nscl_summary(_batch="{batch}"),
        fn_post_compr_summary(_batch="{batch}"),
    output:
        fn_stats_batch_global(_batch="{batch}"),
    shell:
        """
        (
            printf 'batch\t%s\n' {wildcards.batch}
            cat {input}
        )> {output}
        """
