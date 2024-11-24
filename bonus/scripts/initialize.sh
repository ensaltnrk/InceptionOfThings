#!/bin/bash

# --- Install Docker ---
# Add Docker's official GPG key:
sudo apt-get update -y
sudo apt-get install ca-certificates curl -y
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y

# Install Docker itself
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# --- Install kubectl ---
curl -L "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" --output /tmp/kubectl
sudo install -o root -g root -m 0755 /tmp/kubectl /usr/local/bin/kubectl

# --- Install K3d ---
wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# --- Create Cluster ---
sudo k3d cluster create cluster

# --- Retrieve kubeconfig of the cluster ---
mkdir ~/.kube
sudo k3d kubeconfig get cluster > ~/.kube/config
chmod 600 ~/.kube/config

# --- Create resources within the cluster ---
kubectl create namespace argocd
kubectl create namespace dev

# --- Install ArgoCD ---
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
sleep 10

# --- Wait until ArgoCD is online ---
kubectl wait --for=condition=ready pod --all -n argocd --timeout=300s

# NOTE: Do we need to install CLI?
# --- Install ArgoCD CLI ---
# curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
# sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
# rm argocd-linux-amd64

# --- Apply ArgoCD Application ---
kubectl apply -f ../confs/application.yaml

# --- Print ArgoCD admin password ---
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 --decode
echo

# --- Forward the port for to reach ArgoCD web UI ---
kubectl port-forward svc/argocd-server -n argocd 8080:443 --address 0.0.0.0 &