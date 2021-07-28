##
## K-mer propagation
##


# compute prophyle index
# todo: output *
rule prophyle_index:
    input:
        w_batch_asms,
        nw=fn_tree_sorted(_batch="{batch}"),
    output:
        nw=fn_prophyle_tree(_batch="{batch}"),
        d=directory(dir_prophyle_index(_batch="{batch}")),
    shell:
        """
        prophyle index $(dirname "nnn.txt")
        """


# get the ProPhyle tree, clean it, and print all node names
checkpoint tree_post_sorted:
    input:
        nw=fn_prophyle_tree(_batch="{batch}"),
    output:
        nw=fn_tree_sorted2(_batch="{batch}"),
        nodes=fn_nodes_sorted(_batch="{batch}"),
    params:
        script=snakemake.workflow.srcdir("../scripts/postprocess_tree.py"),
    shell:
        """
        {params.script} -n {output.nodes} {input.nw} {output.nw}

        """


rule post_seq:
    """
    Compute simplitigs from an assembly and put them into a text file (1 simplitig per line)
    """
    input:
        fa=fn_post_seq0(_batch="{batch}", _node="{node}"),
    output:
        txt=fn_post_seq(_batch="{batch}", _node="{node}"),
    shell:
        """
        seqtk seq {input.fa} \\
            | grep -v '>' \\
            > {output.txt}
        """


# make a list of node simplitig files
rule post_list:
    input:
        list=fn_nodes_sorted(_batch="{batch}"),
        fa=w_batch_posts,
    output:
        list=fn_post_list(_batch="{batch}"),
    run:
        generate_file_list(
            input.list,
            output.list,
            filename_function=lambda x: fn_post_seq(_sample=x, _batch=wildcards.batch),
        )
