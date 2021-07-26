rule tree_newick:
    output:
        nw="results/tree/{batch}.nw",
    input:
        get_asms_batch
    threads:
        8
    shell:
        """
            mashtree \\
                --outtree {output.nw} \\
                --numcpus {threads} \\
                --seed 42  \\
                --sort-order ABC \\
                {input}
         """
