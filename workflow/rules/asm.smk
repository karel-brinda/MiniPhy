##
## Compression of assemblies
##


rule asm_list:
    """
    Make a list of assemblies as they will appear in the .tar.xz archive
    """
    output:
        list=fn_asm_list(_batch="{batch}"),
    input:
        list=fn_leaves_sorted(_batch="{batch}"),
        fa=w_batch_asms,
    run:
        generate_file_list(
            input.list,
            output.list,
            filename_function=lambda x: fn_asm_seq(_sample=x, _batch=wildcards.batch),
        )


# rule asm_list_alphabetical:
#    output:
#        list=fn_asm_list(_batch="{batch}"),
#    input:
#        fas=w_batch_asms
#    shell:
#        """
#            echo "{input.fas}" \\
#                | xargs -n1 -I{{}} realpath --relative-to $(dirname "{output.list}") {{}} \\
#                > "{output.list}"
#        """


rule asm_seq_formatting:
    """
    Turn an assembly file from the input into a well-behaved fasta file
    """
    input:
        fa=w_sample_source,
    output:
        fa=fn_asm_seq(_batch="{batch}", _sample="{sample}"),
    shell:
        """
        seqtk seq -U "{input.fa}" \\
            > "{output.fa}"
        """
