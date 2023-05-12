##
## Tree inference
##


rule tree_postprocessing:
    """
    Get a cleaned tree and all auxiliary files
    """
    input:
        nw=fn_tree_dirty(_batch="{batch}"),
    output:
        nw=fn_tree_sorted(_batch="{batch}"),
        leaves=fn_leaves_sorted(_batch="{batch}"),
        nodes=fn_nodes_sorted(_batch="{batch}"),
    params:
        script=snakemake.workflow.srcdir("../scripts/postprocess_tree.py"),
    conda:
        "../envs/env.yaml"
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


ruleorder: symlink_nw_tree > tree_newick_mashtree


rule symlink_nw_tree:
    """
    Symlink a phylogenetic tree if possible (nw)
    """
    input:
        nw=dir_input() / "{batch}.nw",
    output:
        nw=fn_tree_dirty(_batch="{batch}"),
    shell:
        """
        odir=$(dirname "{output.nw}")
        r=$(realpath --relative-to="$odir" "{input.nw}")
        ln -sf "$r" {output.nw}
        """


rule tree_newick_mashtree:
    """
    Infer a phylogenetic tree from the assemblies belonging to a given batch
    """
    input:
        w_batch_asms,
    output:
        nw=fn_tree_dirty(_batch="{batch}"),
    threads: 8
    conda:
        "../envs/env.yaml"
    shell:
        """
        mashtree \\
            --numcpus {threads} \\
            --seed 42  \\
            --sort-order ABC \\
            {input} \\
            | tee {output.nw}
        """
