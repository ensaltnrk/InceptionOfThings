#!/bin/bash

# Check k3s
while ! kubectl get nodes; do
  sleep 5;
done;
echo 'K3s is ready!';

# Deploying all apps and ingress
echo "Deploying..."
kubectl apply -f /vagrant/conf/app-one.yaml
kubectl apply -f /vagrant/conf/app-two.yaml
kubectl apply -f /vagrant/conf/app-three.yaml
kubectl apply -f /vagrant/conf/ingress.yaml
echo "Deployed all apps and ingress!"