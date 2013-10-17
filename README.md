# ff-monitor-bw

## About

This collection of scripts measures and monitors the available throughput on a given interface via a certain router.

## Usage

### Monitoring:

./monitor-bw.sh [output.rrd]

Starts periodic measurements and saves results to 'output.rrd'.
If the specified 'output.rrd' does not exist yet, then it will
be created automatically.

### Graphing:

./monitor-bw-rrd2graph.sh [input.rrd] > output.png

Generates a pretty graph from a given rrd file.


## Requirements

* rrdtool
* iperf
* brctl
* ip netns
* realpath
* xz


## Installation

### Arch:

	mkdir -p /var/log/rrd/
	cp $INSTALLDIR/monitor-bw.service /etc/systemd/system/
	ln -s $INSTALLDIR/monitor-bw.sh /usr/local/bin/
	systemctl enable monitor-bw.service
	systemctl start monitor-bw.service

	ln -s $INSTALLDIR/monitor-bw-rrd2graph.sh /usr/local/bin/
	mkdir $HTTPDIR/rrd/
	crontab -e
	## Add:
	# */15 * * * * nice rrdtool dump /var/log/rrd/monitor-bw.rrd | nice xz -c > $HTTPDIR/rrd/monitor-bw.xml.xz
	# */5 * * * * monitor-bw-rrd2graph.sh /var/log/rrd/monitor-bw.rrd > $HTTPDIR/rrd/monitor-bw.png

### Debian:

	mkdir -p /var/log/rrd
	cp $INSTALLDIR/monitor-bw.init /etc/init.d/monitor-bw
	ln -s $INSTALLDIR/monitor-bw.sh /usr/local/bin/
	insserv monitor-bw
	/etc/init.d/monitor-bw start

	ln -s $INSTALLDIR/monitor-bw-rrd2graph.sh /usr/local/bin/
	mkdir $HTTPDIR/rrd/
	crontab -e
	## Add:
	# */15 * * * * nice rrdtool dump /var/log/rrd/monitor-bw.rrd | nice xz -c > $HTTPDIR/rrd/monitor-bw.xml.xz
	# */5 * * * * PATH=/usr/local/bin/:$PATH monitor-bw-rrd2graph.sh /var/log/rrd/monitor-bw.rrd > $HTTPDIR/rrd/monitor-bw.png
