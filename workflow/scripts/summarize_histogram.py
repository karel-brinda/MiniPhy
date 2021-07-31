#! /usr/bin/env python3

import argparse
import collections
import os
import re
import sys

import pandas as pd


def pt(*things, pref=""):
    print(pref, end="")
    print(*things, sep='\t')


def summarize_histogram(fn, pref):
    df = pd.read_csv(fn, sep='\t')
    kmset = sum(df["kmers"])
    pt("set", kmset, pref=pref)
    pt("multiset", sum(df["freq"] * df["kmers"]), pref=pref)
    try:
        pt("min_freq", min(df["freq"]), pref=pref)
    except ValueError:
        pt("min_freq", "NA", pref=pref)
    try:
        pt("max_freq", max(df["freq"]), pref=pref)
    except ValueError:
        pt("max_freq", "NA", pref=pref)
    try:
        if kmset != 0:
            pt("avg_freq", sum(df["freq"] * df["kmers"]) / kmset, pref=pref)
        else:
            pt("avg_freq", "NA", pref=pref)
    except ValueError:
        pt("avg_freq", "NA", pref=pref)


def main():
    parser = argparse.ArgumentParser(description="")
    #
    parser.add_argument(
        '--add-prefix',
        default='',
        dest='prefix',
        metavar='str',
        help='add prefix (str) [""]',
    )
    #
    parser.add_argument(
        'file',
        metavar='histogram.tsv',
        help='',
    )
    args = parser.parse_args()

    summarize_histogram(args.file, args.prefix)


if __name__ == "__main__":
    main()
