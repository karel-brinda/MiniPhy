#! /usr/bin/env bash

set -e
set -o pipefail
set -u
#set -f

readonly PROGNAME=$(basename $0)
readonly PROGDIR=$(dirname $0)
readonly -a ARGS=("$@")
readonly NARGS="$#"

if [[ $NARGS -ne 1 ]]; then
	>&2 echo "usage: $PROGNAME -t {threads} -k {kmer_length} input.fa"
	exit 1
fi

x="$1"
y="$(mktemp -d)/count.jf"

>&2 echo "Input file: $x"
>&2 echo "Counting file: $y"

threads=7
k=31

while getopts ":a:b:" opt; do
  case $opt in
    k) k="$OPTARG" ;;
    t) t="$OPTARG" ;;
  esac
done

(
set +u
if [[ -z "$k" ]]; then
	echo "Error: k-mer length not provided (-k)" 1>&2
    exit 1
fi

if [[ -z "$t" ]]; then
	echo "Error: The number of threads not provided (-t)" 1>&2
    exit 1
fi
)

jellyfish count \
	--threads "$t" \
	--canonical \
	--mer-len "$k" \
	--size 20M \
	--output "$y" \
	"$x"

printf 'freq\tkmers\n'
jellyfish histo \
	--threads "$threads" \
	--high 1000000 \
	"$y" \
	| perl -pe 's/ /\t/g'

rm -f "$y"
