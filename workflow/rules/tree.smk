# get a cleaned tree and all auxiliary files
#   todo: - sort tree; print names & nodes
rule tree_final:
    output:
        nw=fn_tree(_batch="{batch}"),
        leaves=fn_sorted_leaves(_batch="{batch}"),
        nodes=fn_sorted_nodes(_batch="{batch}"),
    input:
        nw=fn_tree_mashtree(_batch="{batch}"),
    threads:
        8
    shell:
        """
            cp {input.nw} {output.nw}
            touch {output.leaves}
            touch {output.nodes}
        """



# infer a phylogenetic tree from the assemblies of a given batch
rule tree_newick_mashtree:
    output:
        nw=fn_tree_mashtree(_batch="{batch}"),
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
