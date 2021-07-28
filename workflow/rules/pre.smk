##
## Compression of simplitigs of assemblies
##


# list of prepropagation simplitig files
#    todo: should be inferred from the tree (through an intermediate list file)
rule pre_list:
    output:
        list=fn_pre_list(_batch="{batch}"),
    input:
        fa=w_batch_pres,
    shell:
        """
        echo "{input.fa}" \\
            | xargs -n1 -I{{}} realpath --relative-to $(dirname "{output.list}") {{}} \\
            > "{output.list}"
        """


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
