#!/bin/bash

# Define server installation arguments
export INSTALL_K3S_EXEC="--write-kubeconfig-mode=644 --bind-address=192.168.56.110 --advertise-address=192.168.56.110 --node-ip=192.168.56.110"

# Install latest k3s
curl -sfL https://get.k3s.io | sh -

# Save the token to the synced folder
sudo cat /var/lib/rancher/k3s/server/node-token > /vagrant/agent-token.env