rule tree_newick:
    output:
        nw="results/tree/{batch}.nw",
    input:
        get_asms_batch
    shell:
        """
            mashtree \\
                --outtree {output.nw} \\
                --numcpus 7 \\
                --seed 42  \\
                --sort-order ABC \\
                {input}
         """
