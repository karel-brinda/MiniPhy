##
## Compression of simplitigs of assemblies
##


rule pre_seq_prophasm:
    """
    Compute simplitigs from an assembly and put them into a text file (1 simplitig per line)
    """
    input:
        fa=fn_asm_seq(_batch="{batch}", _sample="{sample}"),
    output:
        txt=fn_pre_seq(_batch="{batch}", _sample="{sample}"),
    params:
        k=31,
    conda:
        "../envs/prophasm.yaml"
    shell:
        """
        prophasm -S -i {input.fa} -k {params.k} -o - \\
            | seqtk seq \\
            | grep -v '>' \\
            > {output.txt}
        """


rule pre_list:
    """
    Make a list of pre-propagation simplitig files
    """
    input:
        list=fn_leaves_sorted(_batch="{batch}"),
        fa=w_batch_pres,
    output:
        list=fn_list(_batch="{batch}", protocol="pre"),
    run:
        generate_file_list(
            input.list,
            output.list,
            filename_function=lambda x: fn_pre_seq(_sample=x, _batch=wildcards.batch),
        )
