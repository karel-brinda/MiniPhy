rule formatting:
    output:
        fa="results/asm/{batch}/{sample}.fa",
    input:
        fa=get_seq_source_path
    shell:
        """
            seqtk seq -U "{input.fa}" \\
                > "{output.fa}"
        """

