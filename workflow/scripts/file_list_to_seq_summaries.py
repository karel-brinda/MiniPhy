#! /usr/bin/env python3

import argparse
import collections
import os
import re
import sys

from pathlib import Path
from xopen import xopen
from Bio.SeqIO.FastaIO import SimpleFastaParser

header=False

def _to_fa(fn):
    fasta = False
    with xopen(fn) as f:
        for i, x in enumerate(f):
            x = x.strip()
            if i == 0 and len(x) > 0 and x[0] == ">":
                fasta = True
            if not fasta:
                yield f">{i}"
            yield x


def process_seq_file(fn):
    sample = os.path.basename(fn).split(".")[0]

    cl = 0
    ns = 0
    for _, seq in SimpleFastaParser(_to_fa(fn)):
        #print(seq)
        cl += len(seq)
        ns += 1
    global header
    if not header:
        print("sample", "filename", "ns", "cl", sep="\t")
        header = True
    print(sample, fn, ns, cl, sep="\t")


def characterize_files(fn):
    with fn.open() as f:
        os.chdir(fn.parent)
        for x in f:
            y = x.strip()
            if y:
                process_seq_file(y)


def main():
    parser = argparse.ArgumentParser(description="")

    parser.add_argument(
        'fn',
        metavar='list_of_files.txt',
        help='List of files (FASTA / TXT)',
    )

    args = parser.parse_args()

    characterize_files(Path(args.fn))


if __name__ == "__main__":
    main()
