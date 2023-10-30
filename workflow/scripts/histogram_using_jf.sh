#! /usr/bin/env bash

set -e
set -o pipefail
set -u
#set -f


default_s="20M"
default_k=31
default_t=$(nproc --all)

s="$default_s"
t="$default_t"
k="$default_k"

function help_msg {
	>&2 echo
	>&2 echo "Program:  $PROGNAME - get k-mer histogram using JellyFish"
	>&2 echo
	>&2 echo "Usage:    $PROGNAME [-s str] [-t int] [-k int] input.fa"
	>&2 echo
	>&2 echo "Options:  -s STR   initial hash size [$default_s]"
	>&2 echo "          -t INT   number of threads [$default_t]"
	>&2 echo "          -k INT   k-mer length [$default_k]"
	>&2 echo
	exit 1
}

while getopts ":s:k:t:" opt; do
  case $opt in
    s) s="$OPTARG" ;;
    k) k="$OPTARG" ;;
    t) t="$OPTARG" ;;
  esac
done
shift $((OPTIND-1))


readonly PROGNAME=$(basename $0)
readonly PROGDIR=$(dirname $0)
readonly -a ARGS=("$@")
readonly NARGS="$#"


if [[ $NARGS -ne 1 ]]; then
    help_msg
fi

x="$1"
y="$(mktemp -d)/count.jf"

>&2 echo "Input file: $x"
>&2 echo "Counting file: $y"


(
set +u
if [[ -z "$s" ]]; then
	echo "Error: initial hash table size not provided (-s)" 1>&2
    exit 1
fi

if [[ -z "$k" ]]; then
	echo "Error: k-mer length not provided (-k)" 1>&2
    exit 1
fi

if [[ -z "$t" ]]; then
	echo "Error: The number of threads not provided (-t)" 1>&2
    exit 1
fi
)

echo "Parameters: s=$s k=$k t=$t" 1>&2

jellyfish count \
	--canonical \
	--threads "$t" \
	--mer-len "$k" \
	--counter-len 16 \
	--out-counter-len 7 \
	--size "$s" \
	--output "$y" \
	"$x"

printf 'freq\tkmers\n'
jellyfish histo \
	--threads "$t" \
	--high 10000000 \
	"$y" \
	| perl -pe 's/ /\t/g'

rm -f "$y"

