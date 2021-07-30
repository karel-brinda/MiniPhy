#! /usr/bin/env python3

import argparse
import collections
import os
import re
import sys

import pandas as pd


def pt(*things):
    print(*things, sep='\t')


def summarize_histogram(fn):
    df = pd.read_csv(fn, sep='\t')
    pt("set", sum(df["kmers"]))
    pt("multiset", sum(df["freq"] * df["kmers"]))
    pt("min_freq", min(df["freq"]))
    pt("max_freq", max(df["freq"]))
    pt("avg_freq", sum(df["freq"] * df["kmers"]) / sum(df["kmers"]))


def main():
    pass

    parser = argparse.ArgumentParser(description="")
    #
    parser.add_argument(
        'file',
        metavar='histogram.tsv',
        help='',
    )
    args = parser.parse_args()

    summarize_histogram(args.file)


if __name__ == "__main__":
    main()
