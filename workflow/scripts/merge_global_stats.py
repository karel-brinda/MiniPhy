#! /usr/bin/env python3

import argparse
import collections
import os
import re
import sys

import pandas as pd


def get_in_wide(fn):
    df0 = pd.read_csv(fn, sep='\t', index_col=0, names=["key", "val"])
    df = df0.transpose()
    return df


def merge_global_stats(*fns):
    dfs = [get_in_wide(fn) for fn in fns]
    df = pd.concat(dfs)
    print(df.to_csv(sep='\t', index=False))


def main():
    parser = argparse.ArgumentParser(description="")
    parser.add_argument(
        'fns',
        metavar='batch.global.stats',
        nargs="+",
    )

    args = parser.parse_args()
    merge_global_stats(*args.fns)


if __name__ == "__main__":
    main()
