##
## Compression of assemblies
##


"""
list of assemblies as they will appear in the .tar.xz archive
"""


rule asm_list:
    output:
        list=fn_asm_list(_batch="{batch}"),
    input:
        list=fn_leaves_sorted(_batch="{batch}"),
    run:
        # infer the file names from the fn_asm_seq function
        with open(input.list) as f:
            with open(output.list, "w") as g:
                for x in f:
                    x = x.strip()
                    fn0 = fn_asm_seq(wildcards.batch, x)  # top-level path
                    fn = os.path.relpath(fn0, os.path.dirname(output.list))
                    g.write(fn + "\n")
        # shell:
        #    """
        #    cat {input.list} \\
        #        | perl -pe 's/^(.*)$/{wildcards.batch}\/\\1.fa/g' \\
        #        > "{output.list}"
        #    """



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


# format individual fasta files (from the inferred source file)
rule asm_formatting:
    output:
        fa=fn_asm_seq(_batch="{batch}", _sample="{sample}"),
    input:
        fa=w_sample_source,
    shell:
        """
        seqtk seq -U "{input.fa}" \\
            > "{output.fa}"
        """
