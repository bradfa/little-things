#!/bin/sh

PATH=/usr/sbin:/sbin:/bin:/usr/bin

if [ -z "$1" ]
then
	echo Error: No outside network device
	echo "Usage: $0 <outside_net> <inside_net>"
	exit $E_INVAL
fi
if [ -z "$2" ]
then
	echo Error: No inside network device
	echo "Usage: $0 <outside_net> <inside_net>"
	exit $E_INVAL
fi

# delete all existing rules.
iptables -F
iptables -t nat -F
iptables -t mangle -F
iptables -X

# Always accept loopback traffic
iptables -A INPUT -i lo -j ACCEPT

# Allow established connections, and those not coming from the outside
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -m state --state NEW ! -i $1 -j ACCEPT
iptables -A FORWARD -i $1 -o $2 -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow outgoing connections from the LAN side.
iptables -A FORWARD -i $2 -o $1 -j ACCEPT

# Masquerade.
iptables -t nat -A POSTROUTING -o $1 -j MASQUERADE

# Don't forward from the outside to the inside.
iptables -A FORWARD -i $1 -o $2 -j REJECT

# Enable routing.
echo 1 > /proc/sys/net/ipv4/ip_forward
