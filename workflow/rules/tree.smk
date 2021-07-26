rule:
    output:
        nw="results/tree/{batch}.nw",
    input:
        fa=get_asms_batch
    shell:
        """
            seqtk seq -U "{input.fa}" \\
                | gzip --fast \\
                > "{output.fa}"
        """
