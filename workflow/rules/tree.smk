# infer a phylogenetic tree from the assemblies of a given batch
rule tree_newick:
    output:
        nw=fn_tree(_batch="{batch}"),
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
