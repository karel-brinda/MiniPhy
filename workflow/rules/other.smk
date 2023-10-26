##
## Compression using standard compressors
##


rule tar_xz:
    """
    Compress files using xz in a given order
    """
    output:
        xz=fn_compr("{batch}", "{protocol}"),
    input:
        #list=f"{dir_intermediate()}/{pre}/{_batch}.pre.list",
        list=fn_list("{batch}", "{protocol}"),
    threads: config["xz_threads"]
    params:
        xz_params=config["xz_params"],
    shell:
        """
        tar cvf - -C $(dirname "{input.list}") -T "{input.list}" --dereference \\
            | xz -T {threads} {params.xz_params} \\
            > {output.xz}
        """


rule tar_xz_summary:
    """
    Compress files using xz in a given order
    """
    output:
        summary=fn_compr_summary("{batch}", "{protocol}"),
    input:
        xz=fn_compr("{batch}", "{protocol}"),
    shell:
        """
        printf '%s\\t%s\\n' \\
            {wildcards.protocol}_xz_size $(wc -c < "{input.xz}") \\
            > {output.summary}
        """


rule kmer_histogram:
    """
    Compute a k-mer histogram from a list of txt/fasta files.
    """
    output:
        hist=fn_hist("{batch}", "{protocol}"),
    input:
        list=fn_list("{batch}", "{protocol}"),
    params:
        hjf=snakemake.workflow.srcdir("../scripts/histogram_using_jf.sh"),
        lfa=snakemake.workflow.srcdir("../scripts/file_list_to_fa.py"),
    threads: config["jellyfish_threads"]
    params:
        kmer_length=config["kmer_length"],
    conda:
        "../envs/jellyfish.yaml"
    shell:
        """
        {params.hjf} \\
            -t {threads} \\
            -k {params.kmer_length} \\
            <({params.lfa} {input.list}) \\
            > {output.hist}
        """


rule histogram_summary:
    output:
        summary=fn_hist_summary("{batch}", "{protocol}"),
    input:
        hist=fn_hist("{batch}", "{protocol}"),
    params:
        s=snakemake.workflow.srcdir("../scripts/summarize_histogram.py"),
    conda:
        "../envs/env.yaml"
    shell:
        """
        {params.s} {input.hist} \\
            --add-prefix {wildcards.protocol}_ \\
            > {output.summary}
        """


rule nscl:
    output:
        nscl=fn_nscl("{batch}", "{protocol}"),
    input:
        list=fn_list("{batch}", "{protocol}"),
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
    output:
        summary=fn_nscl_summary("{batch}", "{protocol}"),
    input:
        nscl=fn_nscl("{batch}", "{protocol}"),
    params:
        s=snakemake.workflow.srcdir("../scripts/summarize_nscl.py"),
    conda:
        "../envs/env.yaml"
    shell:
        """
        {params.s} {input.nscl} \\
            --add-prefix {wildcards.protocol}_ \\
            > {output.summary}
        """
