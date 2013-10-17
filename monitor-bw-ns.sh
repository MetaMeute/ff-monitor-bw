#!/bin/bash

. ./monitor-bw.conf

set_up() {
	# Network namespace DNS
	[ ! -d /etc/netns/$GWIF-monns ] && \
		mkdir -p /etc/netns/$GWIF-monns
	[ ! -f /etc/netns/$GWIF-monns/resolv.conf ] && \
		echo "nameserver $GWIP" > /etc/netns/$GWIF-monns/resolv.conf

	# Interface creation+wiring
	ip link add name $GWIF-l0 type veth peer name $GWIF-l1
	brctl addif $GWIF $GWIF-l0
	ip link set $GWIF-l0 up

	# Network namespace association
	ip netns add $GWIF-monns
	ip link set $GWIF-l1 netns $GWIF-monns

	# Network namespace configuration
	ip netns exec $GWIF-monns ip addr add $MONIP dev $GWIF-l1
	ip netns exec $GWIF-monns ip link set up dev $GWIF-l1
	ip netns exec $GWIF-monns ip route add default via $GWIP dev $GWIF-l1

	touch /tmp/monitor-bw-ns.sh-configured.stamp
}

tear_down() {
	ip netns exec $GWIF-monns ip link del $GWIF-l1
	ip netns del $GWIF-monns

	rm -r /etc/netns/$GWIF-monns

	rm /tmp/monitor-bw-ns.sh-configured.stamp
}

trap "pkill -P $$; tear_down" EXIT

[ ! -f /tmp/monitor-bw-ns.sh-configured.stamp ] && set_up

ip netns exec $GWIF-monns ./monitor-bw-test.sh
