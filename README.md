# vagrant-k8s
A test environment to play with Kubernetes (k8s) using kubeadm and containerd on Debian Virtual Machines using Vagrant. A simple `make` command will create three Debian 11 nodes with 2 vCPUs and 2 GB of RAM each, allocating 6 threads—depending on CPU—and 6 GB of system RAM.

This project is a work in progress.

## Quick Start

1. `make clean`
2. `make`
3. `grep node1 vagrantup.log | less`
