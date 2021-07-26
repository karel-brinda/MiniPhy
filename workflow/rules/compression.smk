rule compress_asm:
    output:
        #nw="results/tree/{batch}.nw",
        xz="results/compressed_asm/{batch}.tar.xz",
    input:
        get_asms_batch
    shell:
        """
            tar cvf - {input} \\
                | xz -T1 -9 \\
                > {output.xz}
        """
