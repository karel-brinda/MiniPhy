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
       - todo: fix the script; add support for lists of files and text files with simplitigs; pass the number of threads as a params
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
