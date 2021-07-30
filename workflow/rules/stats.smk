
rule stats_global_sample:
    input:
        fn_asm_hist_summary(_batch="{batch}"),
        fn_asm_nscl_summary(_batch="{batch}"),
        fn_pre_hist_summary(_batch="{batch}"),
        fn_pre_nscl_summary(_batch="{batch}"),
        fn_post_hist_summary(_batch="{batch}"),
        fn_post_nscl_summary(_batch="{batch}"),
    output:
        fn_stats_global(_batch="{batch}"),
    shell:
        """
        (
            printf 'batch\t%s\n' {wildcards.batch}
            cat {input}
        )> {output}
        """
