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
        tar cvf - -C $(dirname "{input.list}") -T "{input.list}" \\
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
    threads: 7
    shell:
        """
        ../scripts/histogram_using_jf.sh {input.list} \\
            > {output.hist}
        """
