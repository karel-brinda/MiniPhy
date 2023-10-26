##
## K-mer propagation
##


# compute prophyle index
# todo: output *
checkpoint prophyle_index:
    output:
        d1=directory(dir_prophyle(_batch="{batch}")),
        d2=directory(dir_prophyle_propagation(_batch="{batch}")),
    input:
        w_batch_asms,
        nw=fn_post_output_tree(_batch="{batch}"),
    params:
        k=config["kmer_length"],
        asm_dir=fn_asm_seq_dir("{batch}"),
    conda:
        "../envs/prophyle.yaml"
    shell:
        """
        prophyle index  -T -A -S \\
            -k {params.k} -g {params.asm_dir} \\
            {input.nw} {output.d1}
        """


rule post_seq:
    """
    Compute simplitigs from an assembly and put them into a text file (1 simplitig per line)
    """
    output:
        txt=fn_post_seq(_batch="{batch}", _node="{node}"),
    input:
        fa=fn_post_seq0(_batch="{batch}", _node="{node}"),
    conda:
        "../envs/basic_env.yaml"
    shell:
        """
        seqtk seq {input.fa} \\
            | {{ grep -v '>' || true; }} \\
            > {output.txt}
        """


# make a list of node simplitig files
rule post_list:
    input:
        list=fn_nodes_sorted(_batch="{batch}"),
        fa=w_batch_posts,
        dpp=dir_prophyle_propagation(_batch="{batch}"),
    output:
        list=fn_list(_batch="{batch}", _protocol="post"),
    run:
        generate_file_list(
            input.list,
            output.list,
            filename_function=lambda x: fn_post_seq(_node=x, _batch=wildcards.batch),
        )
