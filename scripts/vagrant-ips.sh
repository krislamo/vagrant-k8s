#!/bin/bash
set -x

# IPs file already exist
if [ -f .k8s-ips ]; then
	echo "NOTICE: .k8s-ips already exists"
	exit 0
fi

# Create file with vagrant-k8s private DHCP IPs
echo "declare -a K8S_NODES" > .k8s-ips
for i in {1..3}; do
	IP=$(vagrant ssh "node$i" -c "hostname -I | cut -d' ' -f2" 2>/dev/null)
	echo "K8S_NODES[$i]=$IP" >> .k8s-ips
done

# Source new IP file
# shellcheck disable=SC1091
source .k8s-ips

# Grab last octet on IP addresses (assuming /24)
last_octets=()
for i in {1..3}; do
	last_octets+=("$(echo "${K8S_NODES[$i]}" | rev | cut -d. -f1 | rev)")
done

# Generate random octet and ensure it's not taken
while true
do
	available=true
	random_octet="$(shuf -i2-254 -n1)"
	for i in "${last_octets[@]}"; do
		[ "$random_octet" == "${i::-1}" ] && available=false
	done
	[ "$available" == true ] && break
done

# Add keepalived IP address in order
sed -i "/declare/a K8S_NODES[0]=${K8S_NODES[1]%.*}.$random_octet" .k8s-ips
