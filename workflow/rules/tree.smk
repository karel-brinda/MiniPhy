rule tree_newick:
    output:
        nw="results/tree/{batch}.nw",
    input:
        w_batch_asms
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
