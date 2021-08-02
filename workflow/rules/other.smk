##
## Compression using standard compressors
##


rule tar_xz:
    """
    Compress files using xz in a given order
    """
    input:
        list="{pref}.{stage}.list",
    output:
        xz="{pref}.{stage}.tar.xz",
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
        xz="{pref}.{stage}.tar.xz",
    output:
        xz="{pref}.{stage}.tar.xz.summary",
    shell:
        """
        printf '%s\\t%s\\n' \\
            {wildcards.stage}_xz_size $(wc -c < "{input.xz}") \\
            > {output}
        """


rule histogram:
    """
    Compute histogram from a list of files
       - todo: pass the number of threads as a params
       - todo: check tmp dir; might run out on the cluster

    """
    input:
        list="{pref}.{stage}.list",
    output:
        hist="{pref}.{stage}.hist",
    params:
        hjf=snakemake.workflow.srcdir("../scripts/histogram_using_jf.sh"),
        lfa=snakemake.workflow.srcdir("../scripts/file_list_to_fa.py"),
    threads: 7
    shell:
        """
        {params.hjf} <({params.lfa} {input.list}) \\
            > {output.hist}
        """


rule histogram_summary:
    input:
        hist="{pref}.{stage}.hist",
    output:
        summ="{pref}.{stage}.hist.summary",
    params:
        s=snakemake.workflow.srcdir("../scripts/summarize_histogram.py"),
    shell:
        """
        {params.s} {input.hist} \\
            --add-prefix {wildcards.stage}_ \\
            > {output.summ}
        """


rule nscl:
    input:
        list="{pref}.{stage}.list",
    output:
        nscl="{pref}.{stage}.nscl",
    params:
        ss=snakemake.workflow.srcdir("../scripts/file_list_to_seq_summaries.py"),
    shell:
        """
        {params.ss} {input.list} \\
            > {output.nscl}
        """


rule nscl_summary:
    input:
        nscl="{pref}.{stage}.nscl",
    output:
        summ="{pref}.{stage}.nscl.summary",
    params:
        s=snakemake.workflow.srcdir("../scripts/summarize_nscl.py"),
    shell:
        """
        {params.s} {input.nscl} \\
            --add-prefix {wildcards.stage}_ \\
            > {output.summ}
        """
