#!/bin/bash

# Define environment variables to make that K3S installation as an agent
export K3S_TOKEN=$(cat /vagrant/agent-token.env)
export K3S_URL="https://192.168.56.110:6443"

curl -sfL https://get.k3s.io | sh -

# We don't need that token anymore so we can delete it
rm -f /vagrant/agent-token.env