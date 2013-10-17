#!/bin/bash

. ./monitor-bw.conf

format_tx() {
	tail -n1 | sed "s/.* \([0-9]*\) Kbits\/sec$/\1/" | tr '\n' ' '
}

do_tx() {
	iperf -c "$IPERF_SERVER" -t $TESTRUN_DURATION -f k
}

format_rx() {
	awk -v dur=$TESTRUN_DURATION '{ print int($1*8/1024/dur) }'
}

__do_rx() {
	timeout $TESTRUN_DURATION wget -q "$dl" -O -
	echo -n ""
}

do_rx() {
	local domain="${HTTP_DOWNLOAD#http://}"; domain="${domain%/*}"
	local dl="$(echo "$HTTP_DOWNLOAD" | sed "s/`host -t A "$domain" | sed "s/ has address /\//"`/")"

	__do_rx | wc -c
}

run() {
	local min=$((($TESTRUN_INTERVAL-6*$TESTRUN_DURATION)/3))
	local ave=$(($TESTRUN_INTERVAL-$min-2*$TESTRUN_DURATION))
	local res=$(($min+$ave*2*$RANDOM/32767))

	echo -n "`date +%s` "
	do_tx | format_tx
	do_rx | format_rx
	sleep $res
}

trap "pkill -P $$" EXIT

while true; do
	run
done
