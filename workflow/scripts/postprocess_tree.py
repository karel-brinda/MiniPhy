#! /usr/bin/env python3

import argparse
import collections
import ete3
import os
import re
import sys

sys.setrecursionlimit(500000)


def info(*msg):
    print(*msg, file=sys.stderr)


def name_internal_nodes(tree):
    re_inferred = re.compile(r'^(.*)-up(\d+)$')

    for n in tree.traverse("postorder"):
        if len(n.children) == 0:
            assert hasattr(n, "name")
        else:
            for x in n.children:
                assert hasattr(x, "name")

            if not hasattr(n, "name") or n.name == "" or n.name is None:
                names = [x.name for x in n.children]
                lmin_name = sorted(names)[0]

                m = re_inferred.match(lmin_name)
                if m is not None:
                    left, right = m.groups()
                    right = int(right) + 1
                    n.name = "{}-up{}".format(left, right)
                else:
                    n.name = lmin_name + "-up1"

    return tree


def load_and_process_tree(
    in_tree_fn,
    standardize,
    midpoint_outgroup,
    ladderize,
    name_internals,
):
    t = ete3.Tree(in_tree_fn, format=1)

    if standardize:
        info("Standardizing the tree")
        t.standardize()
    if midpoint_outgroup:
        info("Setting a midpoint outgroup")
        R = t.get_midpoint_outgroup()
        t.set_outgroup(R)
    if ladderize:
        info("Ladderizing")
        t.ladderize()
    if name_internals:
        info("Automatic naming of internal nodes")
        t = name_internal_nodes(t)

    return t


def print_nodes(tree, fn, only_leaves=False):
    with open(fn, "w") as f:
        if only_leaves:
            it = tree
        else:
            it = tree.traverse('preorder')
        for n in it:
            assert n.name != "", "Error: empty node name"
            assert (n.name != "merge_root")
            f.write(f"{n.name}\n")


def run(in_tree_fn, out_tree_fn, standardize, midpoint_outgroup,
        name_internals, ladderize, leaves_fn, nodes_fn):
    t = load_and_process_tree(
        in_tree_fn=in_tree_fn,
        standardize=standardize,
        midpoint_outgroup=midpoint_outgroup,
        ladderize=ladderize,
        name_internals=name_internals,
    )
    t.write(outfile=out_tree_fn, format=3)
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
        '--standardize',
        dest='standardize',
        help='Resolve polytomy nad ',
        action='store_true',
    )

    parser.add_argument(
        '--midpoint-outgroup',
        dest='midpoint_outgroup',
        help='Mid point outgroup',
        action='store_true',
    )

    parser.add_argument(
        '--ladderize',
        dest='ladderize',
        help='Laderize tree',
        action='store_true',
    )

    parser.add_argument(
        '--name-internals',
        dest='name_internals',
        help='Name internal nodes',
        action='store_true',
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

    run(in_tree_fn=args.in_tree_fn,
        out_tree_fn=args.out_tree_fn,
        standardize=args.standardize,
        midpoint_outgroup=args.midpoint_outgroup,
        name_internals=args.name_internals,
        ladderize=args.ladderize,
        leaves_fn=args.leaves_fn,
        nodes_fn=args.nodes_fn)


if __name__ == "__main__":
    main()
