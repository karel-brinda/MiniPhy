rule:
    output:
        txt="results/pre/{batch}/{sample}.txt",
    input:
        fa="results/asm/{batch}/{sample}.fa",
    params:
        k=31
    shell:
        """
            prophasm -i {input.fa} -k {params.k} -o - \\
                | seqtk seq \\
                | grep -v '>' \\
                > {output.txt}
        """
