#! /usr/bin/env python3

import argparse
import collections
import os
import re
import sys

from pathlib import Path
from xopen import xopen

header = False


def readfq(fp):
    """Read FASTA/FASTQ file. Based on https://github.com/lh3/readfq/blob/master/readfq.py

    Args:
        fp (file): Input file object.
    """

    last = None  # this is a buffer keeping the last unprocessed line
    while True:  # mimic closure; is it a bad idea?
        if not last:  # the first record or a record following a fastq
            for l in fp:  # search for the start of the next record
                if l[0] in '>@':  # fasta/q header line
                    last = l[:-1]  # save this line
                    break
        if not last: break

        ####
        # modified to include comments
        ####
        #name, seqs, last = last[1:].partition(" ")[0], [], None
        name, _, comment = last[1:].partition(" ")
        seqs = []
        last = None
        ####
        # end of the modified part
        ####

        for l in fp:  # read the sequence
            if l[0] in '@+>':
                last = l[:-1]
                break
            seqs.append(l[:-1])
        if not last or last[0] != '+':  # this is a fasta record
            yield name, comment, ''.join(seqs), None  # yield a fasta record
            if not last: break
        else:  # this is a fastq record
            seq, leng, seqs = ''.join(seqs), 0, []
            for l in fp:  # read the quality
                seqs.append(l[:-1])
                leng += len(l) - 1
                if leng >= len(seq):  # have read enough quality
                    last = None
                    yield name, comment, seq, ''.join(seqs)
                    # yield a fastq record
                    break
            if last:  # reach EOF before reading enough quality
                yield name, comment, seq, None  # yield a fasta record instead
                break


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

    # a bit messy, but can read even txt files
    for _, _, seq, _ in readfq(_to_fa(fn)):
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
