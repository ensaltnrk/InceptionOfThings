#!/bin/bash

# Check k3s
while ! kubectl get nodes; do
  sleep 5;
done;
echo 'K3s is ready!';

# Deploying all apps and ingress
echo "Deploying..."
kubectl apply -f /vagrant/confs/app-one.yaml
kubectl apply -f /vagrant/confs/app-two.yaml
kubectl apply -f /vagrant/confs/app-three.yaml
kubectl apply -f /vagrant/confs/ingress.yaml
echo "Deployed all apps and ingress!"