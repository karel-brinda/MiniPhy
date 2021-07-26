rule:
    output:
        nw="results/tree/{batch}.nw",
    input:
        fa=get_fastas_from_batch(wildcards)
    shell:
        """
            seqtk seq -U "{input.fa}" \\
                | gzip --fast \\
                > "{output.fa}"
        """
