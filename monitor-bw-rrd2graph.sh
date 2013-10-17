#!/bin/sh

rrdtool graph - \
	-a PNG \
	-w 800 -h 400 \
	DEF:data-tx="$1":vpn-throughput-tx:LAST \
	DEF:data-rx="$1":vpn-throughput-rx:LAST \
	"CDEF:result-tx=data-tx,1000,/" \
	"CDEF:result-rx=data-rx,1000,/" \
	"LINE:result-tx#00F:Exit VPN Throughput TX" \
	GPRINT:result-tx:LAST:"Current\: %.3lf MBit/s" \
	GPRINT:result-tx:AVERAGE:"Average\: %.3lf MBit/s" \
	GPRINT:result-tx:MIN:"Minimum\: %.3lf MBit/s" \
	GPRINT:result-tx:MAX:"Maximum\: %.3lf MBit/s" \
	"LINE:result-rx#F00:Exit VPN Throughput RX" \
	GPRINT:result-rx:LAST:"Current\: %.3lf MBit/s" \
	GPRINT:result-rx:AVERAGE:"Average\: %.3lf MBit/s" \
	GPRINT:result-rx:MIN:"Minimum\: %.3lf MBit/s" \
	GPRINT:result-rx:MAX:"Maximum\: %.3lf MBit/s" \
	--vertical-label="MBit/s" \
	--title="Estimated Throughput on Exit VPN per Connection" \
	-X 0 -Y
