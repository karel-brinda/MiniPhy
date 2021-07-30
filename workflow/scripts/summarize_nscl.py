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


def summarize_nscl(fn, pref):
    df = pd.read_csv(fn, sep='\t')
    pt("sum_ns", sum(df["ns"]), pref=pref)
    pt("min_ns", min(df["ns"]), pref=pref)
    pt("max_ns", max(df["ns"]), pref=pref)
    pt("avg_ns", sum(df["ns"]) / len(df), pref=pref)
    pt("sum_cl", sum(df["cl"]), pref=pref)
    pt("min_cl", min(df["cl"]), pref=pref)
    pt("max_cl", max(df["cl"]), pref=pref)
    pt("avg_cl", sum(df["cl"]) / len(df), pref=pref)


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
        metavar='seq_summary.nscl',
        help='',
    )
    args = parser.parse_args()

    summarize_nscl(args.file, args.prefix)


if __name__ == "__main__":
    main()
