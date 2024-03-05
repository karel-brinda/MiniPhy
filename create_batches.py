#! /usr/bin/env python3

# example usage: ./create_batches.py ~/github/my/mof-experiments/experiments/60_661k_main_table/661k_main_table.tsv.xz -s hit1_species -f asm_path

import argparse
import collections
import csv
import glob
import os
import re
import sys

from xopen import xopen

DEFAULT_BATCH_MAX_SIZE = 4000
DEFAULT_BATCH_MIN_SIZE = 100
DEFAULT_DUSTBIN_MAX_SIZE = 1000
DEFAULT_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'input')
DEFAULT_COLUMN_SPECIES = "species"
DEFAULT_COLUMN_FN = "filename"


def clean_species_name(name):
    return re.sub('[^a-zA-Z0-9 ]+', '', name).replace(" ", "_").lower()


class Batching:

    def __init__(self, input_fn, cluster_min_size, cluster_max_size,
                 dustbin_max_size, output_d, col_species, col_fn, comments):
        self.input_fn = input_fn
        self.cluster_min_size = cluster_min_size
        self.cluster_max_size = cluster_max_size
        self.dustbin_max_size = dustbin_max_size
        self.output_d = output_d
        self.col_species = col_species
        self.col_fn = col_fn
        self.comments = comments

        self.clusters = collections.defaultdict(list)
        self.pseudoclusters = collections.defaultdict(list)
        self.batches = collections.defaultdict(list)
        self.dbg_info = {}  # fn -> dbg comments

    def _load_clusters(self):
        with xopen(self.input_fn) as fo:
            for genome_count, x in enumerate(csv.DictReader(fo,
                                                            delimiter="\t")):
                #species = x["hit1_species"]
                #fn = x["path"]
                species = clean_species_name(x[self.col_species])
                fn = x[self.col_fn]
                self.clusters[species].append(fn)
                self.dbg_info[fn] = species
        print(
            f"Loaded {genome_count} genomes across {len(self.clusters)} species clusters",
            file=sys.stderr)

    def _create_dustbin(self):
        genome_count = 0
        species_count = 0
        for cluster_name in sorted(self.clusters):
            fns = self.clusters[cluster_name]
            if len(fns) >= self.cluster_min_size:
                pseudocluster_name = cluster_name
            else:
                pseudocluster_name = "dustbin"
                species_count += 1
                genome_count += len(fns)
            self.pseudoclusters[pseudocluster_name].extend(fns)
        print(
            f"Put {genome_count} genomes of {species_count} species into the dustbin",
            file=sys.stderr)

    def _create_batches(self):
        batches = set()
        pseudoclusters_count = 0
        for pseudocluster_name, fns in self.pseudoclusters.items():
            pseudoclusters_count += 1
            if pseudocluster_name == "dustbin":
                current_max_size = self.dustbin_max_size
            else:
                current_max_size = self.cluster_max_size

            for i, v in enumerate(fns):
                batch_number = 1 + i // current_max_size
                batch_name = "{}__{:02}".format(pseudocluster_name,
                                                batch_number)
                batches.add(batch_name)
                self.batches[batch_name].append(v)
        print(
            f"Created {len(batches)} batches of {pseudoclusters_count} pseudoclusters",
            file=sys.stderr)

    def _write_batches(self):
        for batch_name, l in self.batches.items():
            fn = os.path.join(self.output_d, f"{batch_name}.txt")
            with open(fn, "w+") as f:
                for x in l:
                    if self.comments:
                        f.write(f"{x}\t#{self.dbg_info[x]}\n")
                    else:
                        f.write(f"{x}\n")
        print(f"Finished", file=sys.stderr)

    def run(self):
        self._load_clusters()
        self._create_dustbin()
        self._create_batches()
        self._write_batches()


def main():

    parser = argparse.ArgumentParser(description="")

    parser.add_argument(
        'input_fn',
        metavar='clustered_fastas.tsv[.gz/.xz/...]',
        help='',
    )

    parser.add_argument(
        '-m',
        metavar='int',
        dest='cluster_min_size',
        default=DEFAULT_BATCH_MIN_SIZE,
        type=int,
        help=f'batch min size [{DEFAULT_BATCH_MIN_SIZE}]',
    )
    parser.add_argument(
        '-M',
        metavar='int',
        dest='cluster_max_size',
        default=DEFAULT_BATCH_MAX_SIZE,
        type=int,
        help=f'batch max size [{DEFAULT_BATCH_MAX_SIZE}]',
    )

    parser.add_argument(
        '-D',
        metavar='int',
        dest='dustbin_max_size',
        default=DEFAULT_DUSTBIN_MAX_SIZE,
        type=int,
        help=f'dustbin batch max size [{DEFAULT_DUSTBIN_MAX_SIZE}]',
    )

    parser.add_argument(
        '-d',
        metavar='str',
        dest='output_d',
        default=DEFAULT_DIR,
        help=f'output directory [{DEFAULT_DIR}]',
    )

    parser.add_argument(
        '-s',
        metavar='str',
        dest='col_species',
        default=DEFAULT_COLUMN_SPECIES,
        help=f'column name with species name [{DEFAULT_COLUMN_SPECIES}]',
    )

    parser.add_argument(
        '-f',
        metavar='str',
        dest='col_fn',
        default=DEFAULT_COLUMN_FN,
        help=f'column name with filename [{DEFAULT_COLUMN_FN}]',
    )

    parser.add_argument(
        '-c',
        dest='comments',
        action='store_true',
        help=f'add comments with info to the output text files (for debugging)',
    )

    args = parser.parse_args()

    batching = Batching(input_fn=args.input_fn,
                        cluster_min_size=args.cluster_min_size,
                        cluster_max_size=args.cluster_max_size,
                        dustbin_max_size=args.dustbin_max_size,
                        output_d=args.output_d,
                        col_species=args.col_species,
                        col_fn=args.col_fn,
                        comments=args.comments)
    batching.run()


if __name__ == "__main__":
    main()
