#!/bin/bash

################
### Settings ###
################

set -x
DEBIAN_FRONTEND=noninteractive
KEYRING_PATH="/usr/share/keyrings/kubernetes-archive-keyring.gpg"
KEYRING_URL="https://packages.cloud.google.com/apt/doc/apt-key.gpg"

#########################################################
### Install containerd, kubeadm, kubelet, and kubectl ###
#########################################################

# Install prerequsite packages
apt-get install -y apt-transport-https ca-certificates curl

# Install Google Cloud public signing key
curl -fsSLo "$KEYRING_PATH" "$KEYRING_URL"
if [ ! -f /etc/sysctl.d/keepalived.conf ]; then
cat <<- EOF | tee /etc/apt/sources.list.d/kubernetes.list
	deb [signed-by=${KEYRING_PATH}] https://apt.kubernetes.io/ kubernetes-xenial main
	EOF
fi

# Update package index and install
apt-get update
apt-get install -y containerd kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

# Forwarding IPv4 and letting iptables see bridged traffic
if [ ! -f /etc/modules-load.d/k8s.conf ]; then
	cat <<- EOF | tee /etc/modules-load.d/k8s.conf
	overlay
	br_netfilter
	EOF

	modprobe overlay
	modprobe br_netfilter
fi

# sysctl params required by setup, params persist across reboots
if [ ! -f /etc/sysctl.d/k8s.conf ]; then
	cat <<- EOF | tee /etc/sysctl.d/k8s.conf
	net.bridge.bridge-nf-call-iptables  = 1
	net.bridge.bridge-nf-call-ip6tables = 1
	net.ipv4.ip_forward                 = 1
	EOF

	sudo sysctl --system
fi

# Prevent further execution until floating IP is found (not a failure)
if [ ! -f /vagrant/.k8s-ips ]; then
	echo "NOTICE: /vagrant/.k8s-ips not found"
	echo "NOTICE: Rerun 'vagrant provision' after running vagrant-ips.sh"
	exit 0
fi

##########################################
### Install keepalived for floating IP ###
##########################################

apt-get update
apt-get install -y keepalived

if [ ! -f /etc/sysctl.d/keepalived.conf ]; then
	cat <<- EOF | tee /etc/sysctl.d/keepalived.conf
	net.ipv4.ip_nonlocal_bind = 1
	EOF
	sysctl -p
fi
