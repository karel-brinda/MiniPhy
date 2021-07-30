##
## Compression using standard compressors
##


rule tar_xz:
    """
    Compress files using xz in a given order
    """
    output:
        xz="{pref}.tar.xz",
    input:
        list="{pref}.list",
    shell:
        """
        tar cvf - -C $(dirname "{input.list}") -T "{input.list}" --dereference \\
            | xz -T1 -9 \\
            > {output.xz}
        """


rule histogram:
    """
    Compute histogram from a list of files
       - todo: pass the number of threads as a params
       - todo: check tmp dir; might run out on the cluster

    """
    input:
        list="{pref}.list",
    output:
        hist="{pref}.hist",
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
        hist="{pref}.hist",
    output:
        summ="{pref}.hist.summary",
    params:
        s=snakemake.workflow.srcdir("../scripts/summarize_histogram.py"),
    shell:
        """
        {params.s} {input.hist} \\
            > {output.summ}
        """


rule nscl:
    input:
        list="{pref}.list",
    output:
        nscl="{pref}.nscl",
    params:
        ss=snakemake.workflow.srcdir("../scripts/file_list_to_seq_summaries.py"),
    shell:
        """
        {params.ss} {input.list} \\
            > {output.nscl}
        """


rule nscl_summary:
    input:
        nscl="{pref}.nscl",
    output:
        summ="{pref}.nscl.summary",
    params:
        s=snakemake.workflow.srcdir("../scripts/summarize_nscl.py"),
    shell:
        """
        {params.s} {input.nscl} \\
            > {output.summ}
        """
