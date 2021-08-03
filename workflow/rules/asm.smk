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
        fa_gz=fn_asm_seq_gz(_batch="{batch}", _sample="{sample}"),
        fa_gz_size=fn_asm_seq_gz_size(_batch="{batch}", _sample="{sample}"),
    params:
        gzip_level=5,
    shell:
        """
        seqtk seq -U "{input.fa}" \\
            | tee "{output.fa}" \\
            | gzip -"{params.gzip_level}" \
            > "{output.fa_gz}"

        printf '%s\t%s\n' \\
            {wildcards.sample} \\
            $(wc -c < "{output.fa_gz}") \\
            > "{output.fa_gz_size}"
        """


rule asm_gz_sizegram:
    output:
        tsv=fn_asm_seq_gz_sizegram(_batch="{batch}"),
    input:
        w_batch_asms_gz_sizes,
    shell:
        """
        cat {input} > {output}
        """


rule asm_gz_sizegram_summary:
    output:
        tsv=fn_asm_seq_gz_sizegram_summary(_batch="{batch}"),
    input:
        tsv=fn_asm_seq_gz_sizegram(_batch="{batch}"),
    shell:
        """
        printf '%s\t%s\n' \\
            "asm_sum_gz_size" \\
            $(cut -f2 {input} | paste -sd+ - | bc) \\
            > {output.tsv} 
        """
