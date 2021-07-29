#! /usr/bin/env python3

import argparse
import collections
import os
import re
import sys

from pathlib import Path
from xopen import xopen


def print_fn_as_fa(fn):
    fasta = False
    with xopen(fn) as f:
        for i, x in enumerate(f):
            x = x.strip()
            if i == 0 and len(x) > 0 and x[0] == ">":
                fasta = True
            if not fasta:
                print(">")
            print(x)


def list_to_fa(fn):
    with fn.open() as f:
        os.chdir(fn.parent)
        for x in f:
            y = x.strip()
            if y:
                print_fn_as_fa(y)


def main():
    parser = argparse.ArgumentParser(description="")

    parser.add_argument(
        'fn',
        metavar='list_of_files.txt',
        help='List of files (FASTA / TXT)',
    )

    args = parser.parse_args()

    list_to_fa(Path(args.fn))


if __name__ == "__main__":
    main()
