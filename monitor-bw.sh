#!/bin/bash

if [[ $1 =~ / ]]; then
	OUTPUT="`realpath ${1%/*}`/${1##*/}"
else
	OUTPUT="`pwd`/$1"
fi

FILE="${BASH_SOURCE[0]}"
while [ -h "$FILE" ]; do
	DIR="`cd "$(dirname "$FILE")" && pwd`"
	FILE="`readlink "$FILE"`"
	[ "${FILE:0:1}" = "/" ] || FILE="$DIR/$FILE"
done
DIR="`cd "$(dirname "$FILE")" && pwd`"

cd "$DIR"


trap "pkill -P $$" EXIT

./monitor-bw-rrd.sh "$OUTPUT"
