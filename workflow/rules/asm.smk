##
## Compression of assemblies
##


rule asm_list:
    """
    Make a list of assemblies as they will appear in the .tar.xz archive
    """
    output:
        list=fn_list(_batch="{batch}", _protocol="asm"),
    input:
        list=fn_leaves_sorted(_batch="{batch}"),
        fa=w_batch_asms,
    run:
        generate_file_list(
            input.list,
            output.list,
            filename_function=lambda x: fn_asm_seq(_sample=x, _batch=wildcards.batch),
        )


rule asm_seq_formatting:
    """
    Turn an assembly file from the input into a well-behaved fasta file
    """
    output:
        fa=fn_asm_seq(_batch="{batch}", _sample="{sample}"),
    input:
        fa=w_sample_source,
    params:
        seqtk_params="-U" if config["asms_to_uppercase"] else "",
    conda:
        "../envs/env.yaml"
    shell:
        """
        seqtk seq {params.seqtk_params} "{input.fa}" \\
            > "{output.fa}"
        """
