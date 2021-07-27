rule compress_pre:
    output:
        xz="results/compressed_pre/{batch}.tar.xz",
    input:
        txt="results/pre/{batch}.txt",
    params:
        d="results/pre/"
    shell:
        """
            tar cvf - -C "{params.d}" -T "{input.txt}" \\
                | xz -T1 -9 \\
                > {output.xz}
        """


rule pre_list:
    output:
        txt="results/pre/{batch}.txt",
    input:
        w_batch_pres
    params:
        d="results/pre/",
    shell:
        """
            echo "{input}" \\
                | xargs -n1 -I{{}} realpath --relative-to "{params.d}" {{}} \\
                > "{output}"
        """


rule pre_simplitigs:
    output:
        txt="results/pre/{batch}/{sample}.txt",
    input:
        fa="results/asm/{batch}/{sample}.fa",
    params:
        k=31
    shell:
        """
            prophasm -i {input.fa} -k {params.k} -o - \\
                | seqtk seq \\
                | grep -v '>' \\
                > {output.txt}
        """

