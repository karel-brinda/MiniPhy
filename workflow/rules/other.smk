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
