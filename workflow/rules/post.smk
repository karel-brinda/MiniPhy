##
## K-mer propagation and compression
##


rule prophyle:
    output:
        txt="results/post/{batch}.txt",
        #nw=fn_tree_prophyle(_batch="{batch}"),
    input:
        w_batch_pres,
    params:
        d="results/pre/",
    shell:
        """
        prophyle index $(dirname "input.txt")
        """


# list of nodes for archivation
rule post_list:
    output:
        txt="results/post/{batch}.txt",
    input:
        w_batch_pres,
    params:
        d="results/pre/",
    shell:
        """
        echo "{input}" \\
            | xargs -n1 -I{{}} realpath --relative-to "{params.d}" {{}} \\
            > "{output}"
        """


# todo: split prophyle file


# prophyle index
rule post_index:
    output:
        txt="results/post/{batch}/{batch}/index.fa",
    input:
        txt="results/pre/{batch}.txt",
    params:
        k=31,
    shell:
        """
        """
