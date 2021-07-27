##
## Compression using standard compressors
##



# a general rule to turn a list of files into a highly compressed xz archive
rule tar_xz:
    output:
        xz="{pref}.tar.xz"
    input:
        list="{pref}.list"
    shell:
        """
            tar cvf - -C $(dirname "{input.list}") -T "{input.list}" \\
                | xz -T1 -9 \\
                > {output.xz}
        """


# a general rule to turn a list of files into a highly compressed xz archive
#	- todo: fix the script; add support for lists of files and text files with simplitigs; pass the number of threads as a params
#   - todo: check tmp dir; might run out on the cluster
rule histogram:
    output:
        hist="{pref}.hist"
    input:
        list="{pref}.list"
    threads:
    	7
    shell:
        """
            scripts/histogram_using_jf.sh {input.list} \\
                > {output.hist}
        """
