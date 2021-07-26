rule:
    output:
        fa="results/asm/{batch}/{sample}.fa.gz",
    input:
        fa=get_sample_id(wildcards)
    shell:
        """
            seqtk seq -U "{input.fa}" \\
                | gzip --fast \\
                > "{output.fa}"
        """
