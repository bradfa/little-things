#!/bin/bash

PATH=/usr/sbin:/sbin:/bin:/usr/bin

usage() {
	echo "usage:	$0 flush"
	echo "	$0 <outside_net> <inside_net>"
	exit $E_INVAL
}

if [ $# -eq 1 ]; then
	if [ "$1" == "flush" ]; then
		# delete all existing rules.
		iptables -v -F
		iptables -v -t nat -F
		iptables -v -t mangle -F
		iptables -v -X
		# Disable routing.
		echo 0 > /proc/sys/net/ipv4/ip_forward
		exit
	fi
fi

if [ -z "$2" ]
then
	echo Error: No inside network device
	usage
fi

# Always accept loopback traffic
iptables -v -A INPUT -i lo -j ACCEPT

# Allow established connections, and those not coming from the outside
iptables -v -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -v -A INPUT -m state --state NEW ! -i $1 -j ACCEPT
iptables -v -A FORWARD -i $1 -o $2 -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow outgoing connections from the LAN side.
iptables -v -A FORWARD -i $2 -o $1 -j ACCEPT

# Masquerade.
iptables -v -t nat -A POSTROUTING -o $1 -j MASQUERADE

# Don't forward from the outside to the inside.
iptables -v -A FORWARD -i $1 -o $2 -j REJECT

# Enable routing.
echo 1 > /proc/sys/net/ipv4/ip_forward
