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
	>&2 echo "usage: $PROGNAME input.fa"
	exit 1
fi

x="$1"
y=$(mktemp -d)/count.jf

>&2 echo "Input file: $x"
>&2 echo "Counting file: $y"

threads=7

jellyfish count \
	--threads $threads \
	--canonical \
	--mer-len 31 \
	--size 20M \
	--output "$y" \
	"$x"

printf 'freq\tkmers\n'
jellyfish histo \
	--threads $threads \
	--high 1000000 \
	"$y" \
	| perl -pe 's/ /\t/g'

rm -f "$y"
