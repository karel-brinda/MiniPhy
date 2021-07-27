##
## Tree inference
##


# get a cleaned tree and all auxiliary files
rule tree_sorted:
    output:
        nw=fn_tree_sorted(_batch="{batch}"),
        leaves=fn_leaves_sorted(_batch="{batch}"),
    input:
        nw=fn_tree_mashtree(_batch="{batch}"),
    threads:
        8
    shell:
        """
            ./scripts/postprocess_tree.py -l {output.leaves} {input.nw} {output.nw}
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
