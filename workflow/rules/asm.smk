rule compress_asm:
    output:
        #nw="results/tree/{batch}.nw",
        xz="results/compressed_asm/{batch}.tar.xz",
    input:
        txt="results/asm/{batch}.txt",
    params:
        d="results/asm/"
    shell:
        """
            tar cvf - -C "{params.d}" -T "{input.txt}" \\
                | xz -T1 -9 \\
                > {output.xz}
        """


rule asm_list:
    output:
        txt="results/asm/{batch}.txt",
    input:
        get_asms_batch
    params:
        d="results/asm/",
    shell:
        """
            echo "{input}" \\
                | xargs -n1 -I{{}} realpath --relative-to "{params.d}" {{}} \\
                > "{output}"
        """


rule asm_formatting:
    output:
        fa="results/asm/{batch}/{sample}.fa",
    input:
        fa=get_seq_source_path,
    shell:
        """
            seqtk seq -U "{input.fa}" \\
                > "{output.fa}"
        """

