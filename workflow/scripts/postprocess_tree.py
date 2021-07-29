#! /usr/bin/env python3

import argparse
import collections
import ete3
import os
import re
import sys


def preprocess_tree(tree_fn):
    t = ete3.Tree(tree_fn, format=1)

    # to standardize the order (and possibly also enhance compression)
    t.ladderize()
    return t


def print_nodes(tree, fn, only_leaves=False):
    with open(fn, "w") as f:
        if only_leaves:
            it = tree
        else:
            it = tree.traverse('preorder')
        for n in it:
            assert n.name != "", "Error: empty node name"
            if n.name != "merge_root":
                f.write(f"{n.name}\n")


def process_tree(in_tree_fn, out_tree_fn, leaves_fn, nodes_fn):
    t = preprocess_tree(in_tree_fn)
    t.write(outfile=out_tree_fn, format=1)
    if leaves_fn:
        print_nodes(t, leaves_fn, only_leaves=True)
    if nodes_fn:
        print_nodes(t, nodes_fn, only_leaves=False)


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
        dest='leaves_fn',
        help='Print leaves',
    )

    parser.add_argument(
        '-n',
        '--nodes',
        metavar='nodes_order.txt',
        dest='nodes_fn',
        help='Print nodes',
    )

    args = parser.parse_args()

    process_tree(args.in_tree_fn, args.out_tree_fn, args.leaves_fn,
                 args.nodes_fn)


if __name__ == "__main__":
    main()
