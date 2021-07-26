rule:
    output:
        fa="results/pre/{batch}/{sample}.fa.gz",
    input:
        fa="results/asm/{batch}/{sample}.fa.gz",
    params:
        k=31
    shell:
        """
            prophasm -i {input.fa} -k {params.k} -o - \\
                | seqtk seq \\
                | gzip -1 \\
                > {output.fa}
        """
