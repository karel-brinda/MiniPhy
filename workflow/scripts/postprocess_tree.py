#! /usr/bin/env python3

import argparse
import collections
import ete3
import os
import re
import sys


def preprocess_tree(fn, out_tree):
    t = ete3.Tree(fn)

    # to standardize the order (and possibly also enhance compression)
    t.ladderize()
    return t


def print_nodes(tree, fn, only_leaves=False):
    for i, n in enumerate(t, 1):
        print(n.name, i, sep="\t")


def process_tree(in_tree_fn, out_tree_fn, leaves, nodes):
    t1 = preprocess_tree(in_tree_fn)
    t2 = name_internal_nodes(t1)
    t2.write(outfile=out_tree_fn, format=1)


def main():
    parser = argparse.ArgumentParser(description="")

    parser.add_argument(
        'in_tree_fn',
        metavar='input.tree.nw',
        help='Input tree',
    )

    parser.add_argument(
        'out_tree_fn',
        metavar='output.tree.nw',
        help='Output tree',
    )

    parser.add_argument(
        '-l',
        '--leaves',
        metavar='leaves_order.txt',
        dest='leaves',
        help='Print leaves',
    )

    parser.add_argument(
        '-n',
        '--nodes',
        metavar='nodes_order.txt',
        dest='nodes',
        help='Print nodes',
    )

    args = parser.parse_args()

    process_tree(args.in_tree_fn, args.out_tree_fn, args.leaves, args.nodes)


if __name__ == "__main__":
    main()
