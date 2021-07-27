rule compress_post:
    output:
        xz="results/compressed_post/{batch}.tar.xz",
    input:
        txt="results/post/{batch}.txt",
    params:
        d="results/post/"
    shell:
        """
            tar cvf - -C "{params.d}" -T "{input.txt}" \\
                | xz -T1 -9 \\
                > {output.xz}
        """


rule post_list:
    output:
        txt="results/post/{batch}.txt",
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


rule post_index:
    output:
        txt="results/post/{batch}/{batch}/index.fa",
    input:
        txt="results/pre/{batch}.txt",
    params:
        k=31
    shell:
        """
            prophyle index $(dirname "input.txt")
        """

