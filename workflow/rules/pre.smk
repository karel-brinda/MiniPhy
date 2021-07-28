##
## Compression of simplitigs of assemblies
##


# list of prepropagation simplitig files
#    todo: should be inferred from the tree (through an intermediate list file)
rule pre_list:
    output:
        list=fn_pre_list(_batch="{batch}"),
    input:
        list=fn_leaves_sorted(_batch="{batch}"),
        fa=w_batch_pres,
    run:
        generate_file_list(
            input.list,
            output.list,
            filename_function=lambda x: fn_pre_seq(_sample=x, _batch=wildcards.batch),
        )


# compute simplitigs and put them into a text file (1 unitig per line)
rule pre_simplitigs:
    output:
        txt=fn_pre_seq(_batch="{batch}", _sample="{sample}"),
    input:
        fa=fn_asm_seq(_batch="{batch}", _sample="{sample}"),
    params:
        k=31,
    shell:
        """
        prophasm -i {input.fa} -k {params.k} -o - \\
            | seqtk seq \\
            | grep -v '>' \\
            > {output.txt}
        """
