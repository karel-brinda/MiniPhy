#! /usr/bin/env python3

import argparse
import collections
import glob
import os
import re
import sys

cluster_max_size = 4000
cluster_min_size = 100
dustbin_max_size = 1000


def accession_from_fn(fn):
    b = os.path.basename(fn)
    return b.split(".")[0]


re_acc = re.compile(r'([A-Z]+)([0-9]+)')

#def sorting_function(x):
#    acc = accession_from_fn(x)
#    #print(x, acc)
#    m = re_acc.match(acc)
#    assert m is not None, x
#    letters, number = m.groups()
#    assert len(letters) == 4, [acc, letters]
#    assert 7 <= len(number) <= 7, [acc, number, len(number)]
#    norm_acc = "{}{:013}".format(letters, int(number))
#    #print(norm_acc)
#    #print(acc, norm_acc)
#    return norm_acc


def main():
    l = glob.glob("../61_661k_clusters/*.txt")
    d = collections.defaultdict(lambda: [])

    for x in l:
        b = accession_from_fn(x)
        ll = [x.strip() for x in open(x)]
        if len(ll) >= cluster_min_size:
            cluster_name = b
        else:
            cluster_name = "dustbin"
        d[cluster_name].extend(ll)

    dd = collections.defaultdict(lambda: [])

    for k in d:
        if k == "dustbin":
            current_max_size = dustbin_max_size
        else:
            current_max_size = cluster_max_size

        #d[k].sort(key=sorting_function)

        for i, v in enumerate(d[k]):
            j = "{:02}".format(1 + i // current_max_size)
            #print(i, v, sorting_function(v), k, j, sep="\t")
            dd[f"{k}__{j}"].append(v)

    for k in dd:
        with open(f"{k}.txt", "w") as f:
            f.write("\n".join(dd[k]) + "\n")


if __name__ == "__main__":
    main()
