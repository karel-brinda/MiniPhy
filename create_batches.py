#! /usr/bin/env python3

import argparse
import collections
import glob
import os
import re
import sys

from xopen import xopen

DEFAULT_BATCH_MAX_SIZE = 4000
DEFAULT_BATCH_MIN_SIZE = 100
DEFAULT_DUSTBIN_MAX_SIZE = 1000
DEFAULT_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'input')


class Batching:
    # todo: pass names of csv columns

    def __init__(self, input_fn, cluster_min_size, cluster_max_size,
                 dustbin_max_size, output_d):
        self.input_fn = input_fn
        self.cluster_min_size = cluster_min_size
        self.cluster_max_size = cluster_max_size
        self.dustbin_max_size = dustbin_max_size
        self.output_d = output_d

        self.clusters = collections.default_dict(lambda: [])
        self.pseudoclusters = collections.default_dict(lambda: [])
        self.batches = collections.default_dict(lambda: [])

    def _load_clusters(self):
        with xopen(self.input_fn) as fo:
            for genome_count, x in enumerate(fo):
                species, fasta_fn = x.strip().split("\t")
                self.species[species].append(fasta_fn)

                species = x["hit1_species"]
                fn = x["path"]
                self.clusters[species].append(fn)

            print(
                f"Loaded {genome_count} genomes of {len(self.species)} species",
                file=sys.stderr)

    def _create_dustbin(self):
        for cluster_name, fns in self.clusters.items():
            if len(fns) >= self.cluster_min_size:
                pseudocluster_name = cluster_name
            else:
                pseudocluster_name = "dustbin"
            self.pseudoclusters[cluster_name].extend(fns)

    def _create_batches(self):
        for pseudocluster_name, fns in self.pseudoclusters.items():
            if pseudocluster_name == "dustbin":
                current_max_size = self.dustbin_max_size
            else:
                current_max_size = self.cluster_max_size

            for i, v in enumerate(d[k]):
                batch_number = f"{pseudocluster_name}_{i // current_max_size}"
                batch_name = "{}__{:02}".format(pseudocluster_name,
                                                batch_number)
                self.batches[batch_name].append(v)

    def _write_batches(self):
        for batch_name, l in self.batches.items():
            fn = os.path.join(self.output_d, "{batch_name}.txt")
            with open(f"{k}.txt", "w+") as f:
                f.write("\n".join(l) + "\n")

    def run(self):
        self._load_clusters(self)
        self._create_dustbin(self)
        self._create_batches(self)
        self._write_batches(self)


def main():

    parser = argparse.ArgumentParser(description="")

    parser.add_argument(
        'input_fn',
        metavar='clustered_fastas.tsv',
        help='',
    )

    parser.add_argument(
        '-m',
        metavar='int',
        dest='cluster_min_size',
        default=DEFAULT_BATCH_MIN_SIZE,
        help=f'batch min size [{DEFAULT_BATCH_MIN_SIZE}]',
    )
    parser.add_argument(
        '-M',
        metavar='int',
        dest='cluster_max_size',
        default=DEFAULT_BATCH_MAX_SIZE,
        help=f'batch max size [{DEFAULT_BATCH_MAX_SIZE}]',
    )

    parser.add_argument(
        '-D',
        metavar='int',
        dest='dustbin_max_size',
        default=DEFAULT_DUSTBIN_MAX_SIZE,
        help=f'dustbin batch max size [{DEFAULT_DUSTBIN_MAX_SIZE}]',
    )

    parser.add_argument(
        '-d',
        metavar='str',
        dest='output_d',
        default=DEFAULT_DIR,
        help=f'output directory [{DEFAULT_DIR}]',
    )

    args = parser.parse_args()

    batching = Batching(input_fn=args.input_fn,
                        cluster_min_size=args.cluster_min_size,
                        cluster_max_size=args.cluster_max_size,
                        dustbin_max_size=args.dustbin_max_size,
                        output_d=args.output_d)
    batching.run()


if __name__ == "__main__":
    main()
