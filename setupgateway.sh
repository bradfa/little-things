#!/bin/bash

# setupgateway.sh - manage workbench NAT routing via a self-contained
# nftables table. Safe to use alongside Docker; flush operations do not
# touch Docker's tables or global ip_forward / ipv6 forwarding sysctls.
#
# Usage:
#   setupgateway.sh flush
#   setupgateway.sh <outside_iface> <inside_iface>
#
# Persistent sysctl prerequisites (set in /etc/sysctl.d/10-routing.conf):
#   net.ipv4.ip_forward = 1
#   net.ipv6.conf.all.forwarding = 1
#   net.ipv6.conf.<outside_iface>.accept_ra = 2   # keep SLAAC on uplink
#
# Masquerade behaviour:
#   IPv4 traffic from the inside interface is always masqueraded.
#   IPv6 traffic is masqueraded only if MASQUERADE_IPV6=1 below.
#   With link-local-only IPv6 on the workbench segment, MASQUERADE_IPV6=0
#   is correct: the kernel never forwards link-local sourced packets off
#   their originating link, so the IPv6 masquerade rule is unreachable
#   regardless. Set MASQUERADE_IPV6=1 only if workbench devices are later
#   assigned ULA addresses and need IPv6 internet access via masquerade.

MASQUERADE_IPV6=0

PATH=/usr/sbin:/sbin:/bin:/usr/bin

usage() {
	echo "usage:  $0 flush"
	echo "        $0 <outside_iface> <inside_iface>"
	exit 1
}

if [ $# -eq 1 ]; then
	if [ "$1" == "flush" ]; then
		nft delete table inet workbench 2>/dev/null || true
		# Do not touch ip_forward or ipv6 forwarding here. If Docker is
		# running it needs ip_forward enabled globally. Workbench routing
		# is gated by the presence of the workbench nftables table, not
		# these sysctls.
		exit 0
	fi
	usage
fi

if [ -z "$2" ]; then
	echo "Error: No inside network device"
	usage
fi

OUTSIDE="$1"
INSIDE="$2"

# Remove any existing workbench table before re-applying, to avoid
# duplicate rules if the script is run twice without flushing first.
nft delete table inet workbench 2>/dev/null || true

# Build the masquerade rule conditionally.
if [ "$MASQUERADE_IPV6" -eq 1 ]; then
	MASQ_RULE='oifname "'"${OUTSIDE}"'" masquerade'
else
	MASQ_RULE='meta nfproto ipv4 oifname "'"${OUTSIDE}"'" masquerade'
fi

nft -f - <<EOF
table inet workbench {

chain forward {
	type filter hook forward priority 0;

	# Accept established/related from outside to inside
	iifname "${OUTSIDE}" oifname "${INSIDE}" ct state established,related accept

	# Accept new outbound from inside to outside
	iifname "${INSIDE}" oifname "${OUTSIDE}" accept

	# Reject new inbound from outside to inside
	iifname "${OUTSIDE}" oifname "${INSIDE}" reject
}

chain postrouting {
	type nat hook postrouting priority 100;

	# Masquerade outbound traffic. IPv6 masquerade is conditional on
	# MASQUERADE_IPV6; see header comment.
	${MASQ_RULE}
}
}
EOF

# Ensure forwarding is enabled. On a machine with the persistent sysctl
# settings applied this is redundant, but acts as a safety net if those
# settings have not yet been applied.
sysctl -q net.ipv4.ip_forward=1
sysctl -q net.ipv6.conf.all.forwarding=1
