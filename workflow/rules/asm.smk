# list of assemblies as they will appear in the .tar.xz archive
#    todo: should be inferred from the tree (through an intermediate list file)
rule asm_list:
    output:
        list=fn_asm_list(_batch="{batch}"),
    input:
        fas=w_batch_asms
    params:
        d="results/asm/",
    shell:
        """
            echo "{input.fas}" \\
                | xargs -n1 -I{{}} realpath --relative-to $(dirname "{output.txt}") {{}} \\
                > "{output.list}"
        """


# format individual fasta files (from the inferred source file)
rule asm_formatting:
    output:
        fa=fn_asm_seq(_batch="{batch}", _sample="{sample}"),
    input:
        fa=w_sample_source
    shell:
        """
            seqtk seq -U "{input.fa}" \\
                > "{output.fa}"
        """
