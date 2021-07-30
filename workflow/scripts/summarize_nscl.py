#! /usr/bin/env python3

import argparse
import collections
import os
import re
import sys

import pandas as pd


def pt(*things):
    print(*things, sep='\t')


def summarize_nscl(fn):
    df = pd.read_csv(fn, sep='\t')
    pt("ns", sum(df["ns"]))
    pt("min_ns", min(df["ns"]))
    pt("max_ns", max(df["ns"]))
    pt("avg_ns", sum(df["ns"]) / len(df))
    pt("cl", sum(df["cl"]))
    pt("min_cl", min(df["cl"]))
    pt("max_cl", max(df["cl"]))
    pt("avg_cl", sum(df["cl"]) / len(df))


def main():
    parser = argparse.ArgumentParser(description="")
    #
    parser.add_argument(
        'file',
        metavar='seq_summary.nscl',
        help='',
    )
    args = parser.parse_args()

    summarize_nscl(args.file)


if __name__ == "__main__":
    main()
