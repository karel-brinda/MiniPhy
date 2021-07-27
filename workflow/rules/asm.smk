rule compress_asm:
    output:
        xz="results/compressed_asm/{batch}.tar.xz",
    input:
        txt="results/asm/{batch}.txt",
    params:
        asm_dir="results/asm/"
    shell:
        """
            tar cvf - -C "{params.asm_dir}" -T "{input.txt}" \\
                | xz -T1 -9 \\
                > {output.xz}
        """


rule asm_list:
    output:
        txt="results/asm/{batch}.txt",
    input:
        w_batch_asms
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
        fa=w_sample_source
    shell:
        """
            seqtk seq -U "{input.fa}" \\
                > "{output.fa}"
        """

