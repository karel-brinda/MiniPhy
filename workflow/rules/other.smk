##
## Compression using standard compressors
##


rule tar_xz:
    """
    Compress files using xz in a given order
    """
    input:
        #list=f"{dir_intermediate()}/{pre}/{_batch}.pre.list",
        list=fn_list("{batch}", "{protocol}"),
    output:
        xz=fn_compr("{batch}", "{protocol}"),
    shell:
        """
        tar cvf - -C $(dirname "{input.list}") -T "{input.list}" --dereference \\
            | xz -T1 -9 \\
            > {output.xz}
        """


rule tar_xz_summary:
    """
    Compress files using xz in a given order
    """
    input:
        xz=fn_compr("{batch}", "{protocol}"),
    output:
        xz_summary=fn_compr_summary("{batch}", "{protocol}"),
    shell:
        """
        printf '%s\\t%s\\n' \\
            {wildcards.protocol}_xz_size $(wc -c < "{input.xz}") \\
            > {output}
        """


rule histogram:
    """
    Compute histogram from a list of files
       - todo: pass the number of threads as a params
       - todo: check tmp dir; might run out on the cluster

    """
    input:
        list=fn_list("{batch}", "{protocol}"),
    output:
        hist=fn_hist("{batch}", "{protocol}"),
    params:
        hjf=snakemake.workflow.srcdir("../scripts/histogram_using_jf.sh"),
        lfa=snakemake.workflow.srcdir("../scripts/file_list_to_fa.py"),
    threads: 7
    conda:
        "../envs/jellyfish.yaml"
    shell:
        """
        {params.hjf} <({params.lfa} {input.list}) \\
            > {output.hist}
        """


rule histogram_summary:
    input:
        hist=fn_hist("{batch}", "{protocol}"),
    output:
        hist_summary=fn_hist_summary("{batch}", "{protocol}"),
    params:
        s=snakemake.workflow.srcdir("../scripts/summarize_histogram.py"),
    conda:
        "../envs/env.yaml"
    shell:
        """
        {params.s} {input.hist} \\
            --add-prefix {wildcards.protocol}_ \\
            > {output.hist_summary}
        """


rule nscl:
    input:
        list=fn_list("{batch}", "{protocol}"),
    output:
        nscl=fn_nscl("{batch}", "{protocol}"),
    params:
        ss=snakemake.workflow.srcdir("../scripts/file_list_to_seq_summaries.py"),
    conda:
        "../envs/env.yaml"
    shell:
        """
        {params.ss} {input.list} \\
            > {output.nscl}
        """


rule nscl_summary:
    input:
        nscl=fn_nscl("{batch}", "{protocol}"),
    output:
        nscl_summary=fn_nscl("{batch}", "{protocol}"),
    params:
        s=snakemake.workflow.srcdir("../scripts/summarize_nscl.py"),
    conda:
        "../envs/env.yaml"
    shell:
        """
        {params.s} {input.nscl} \\
            --add-prefix {wildcards.protocol}_ \\
            > {output.nscl_summary}
        """
