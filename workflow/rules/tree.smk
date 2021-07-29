##
## Tree inference
##


rule tree_postprocessing:
    """
    Get a cleaned tree and all auxiliary files
    """
    input:
        nw=fn_tree_mashtree(_batch="{batch}"),
    output:
        nw=fn_tree_sorted(_batch="{batch}"),
        leaves=fn_leaves_sorted(_batch="{batch}"),
        nodes=fn_nodes_sorted(_batch="{batch}"),
    params:
        script=snakemake.workflow.srcdir("../scripts/postprocess_tree.py"),
    shell:
        """
        {params.script} \\
            --standardize \\
            --midpoint-outgroup \\
            --name-internals \\
            --ladderize \\
            -l {output.leaves} \\
            -n {output.nodes} \\
            {input.nw} {output.nw}
        """


rule tree_newick_mashtree:
    """
    Infer a phylogenetic tree from the assemblies belonging to a given batch
    """
    input:
        w_batch_asms,
    output:
        nw=fn_tree_mashtree(_batch="{batch}"),
    threads: 8
    shell:
        """
        mashtree \\
            --numcpus {threads} \\
            --seed 42  \\
            --sort-order ABC \\
            {input} \\
            | tee {output.nw}
        """
