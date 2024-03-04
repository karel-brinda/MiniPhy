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
        "../envs/basic_env.yaml"
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


rule cp_final_tree_for_post_output:
    output:
        nw=fn_post_output_tree(_batch="{batch}"),
    input:
        nw=fn_tree_sorted(_batch="{batch}"),
    shell:
        """
        cp "{input.nw}" "{output.nw}"
        """


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


if not config["trees_required"]:

    ruleorder: symlink_nw_tree > tree_newick_attotree

    rule tree_newick_attotree:
        """
        Infer a phylogenetic tree from the assemblies belonging to a given batch
        """
        output:
            nw=fn_tree_dirty(_batch="{batch}"),
        input:
            w_batch_asms,
        threads: config["attotree_threads"]
        params:
            k=config["attotree_kmer_length"],
            s=config["attotree_sketch_size"],
            t=min(int(config["attotree_threads"]), workflow.cores),  # ensure that the number of cores for Attotree doesn't go too low
        conda:
            "../envs/attotree.yaml"
        shell:
            """
            attotree \\
                -t {params.t} \\
                -k {params.k} \\
                -s {params.s} \\
                {input} \\
                | tee {output.nw}
            """
