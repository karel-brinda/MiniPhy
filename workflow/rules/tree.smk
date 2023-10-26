##
## Tree inference
##
import os.path


rule tree_postprocessing:
    """
    Get a cleaned tree and all auxiliary files
    """
    output:
        nw=fn_tree_sorted(_batch="{batch}"),
        leaves=fn_leaves_sorted(_batch="{batch}"),
        nodes=fn_nodes_sorted(_batch="{batch}"),
    input:
        nw=fn_tree_dirty(_batch="{batch}"),
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
    output:
        nw=fn_tree_dirty(_batch="{batch}"),
    input:
        nw=dir_input() / "{batch}.nw",
    params:
        relative_path=lambda wildcards, input, output: os.path.relpath(
            input.nw, start=os.path.dirname(output.nw)
        ),
    shell:
        """
        ln -sf {params.relative_path} {output.nw}
        """


rule tree_newick_mashtree:
    """
    Infer a phylogenetic tree from the assemblies belonging to a given batch
    """
    output:
        nw=fn_tree_dirty(_batch="{batch}"),
    input:
        w_batch_asms,
    threads: 8
    conda:
        "../envs/mashtree.yaml"
    shell:
        """
        mashtree \\
            --numcpus {threads} \\
            --seed 42  \\
            --sort-order ABC \\
            {input} \\
            | tee {output.nw}
        """
