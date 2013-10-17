#!/bin/bash

. ./monitor-bw.conf

rrd_create() {
	STEP=$TESTRUN_INTERVAL
	HEARTBEAT=$(($STEP*2))
	STEPS_PER_HOUR=$((60*60/$STEP))
	ROWS_MONTH=$((31*24*60*60/$STEP))
	ROWS_YEAR=$((366*24*60*60/($STEP*$STEPS_PER_HOUR)))

	# Minimum: 0 MBit/s, Maximum: 100 MBit/s (input in KBit/s)
	# 1st RRA: 31 days, $STEP resolution
	# 2.-4. RRA: 366 days, hourly resolution
	rrdtool create "$1" \
		--step $STEP \
		DS:vpn-throughput-tx:GAUGE:$HEARTBEAT:0:102400 \
		DS:vpn-throughput-rx:GAUGE:$HEARTBEAT:0:102400 \
		RRA:LAST:0:1:$ROWS_MONTH \
		RRA:AVERAGE:0.5:$STEPS_PER_HOUR:$ROWS_YEAR \
		RRA:MIN:0.5:$STEPS_PER_HOUR:$ROWS_YEAR \
		RRA:MAX:0.5:$STEPS_PER_HOUR:$ROWS_YEAR
}

rrd_update() {
	local input; local valuetx; local valuerx; local valtime

	while read input; do
		valtime="${input%% *}"
		valuetx="${input#* }"
		valuerx="${valuetx#* }"
		valuetx="${valuetx% *}"

		rrdtool update "$1" "$valtime":"$valuetx":"$valuerx"
	done 
}

trap "pkill -P $$" EXIT

[ ! -f "$1" ] && rrd_create "$1"

./monitor-bw-ns.sh | rrd_update "$1"
