#!/bin/bash

# Add package repositories for Helm and install it
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update -y
sudo apt-get install helm -y

# Install nginx-controller for ArgoCD <-> GitLab communication
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.3.0/deploy/static/provider/cloud/deploy.yaml
sleep 5


# Install GitLab by using Helm chart
kubectl create namespace gitlab
helm repo add gitlab http://charts.gitlab.io/
helm install gitlab gitlab/gitlab -f ../confs/values.yaml -n gitlab
sleep 5
kubectl wait --for=condition=ready pod --all -n gitlab --timeout=-1s

# Show root password
echo "Gitlab password: " $(kubectl -n gitlab get secret gitlab-gitlab-initial-root-password -ojsonpath='{.data.password}' | base64 -d ; echo)

# Delete current ingress installed by Helm chart...
kubectl delete ingress gitlab-webservice-default -n gitlab

# ... and install it with new configuration
kubectl apply -f ../confs/gitlab-ingress.yaml
kubectl apply -f ../confs/application.yaml

# Forward GitLab port to access over web browser
kubectl port-forward svc/gitlab-webservice-default -n gitlab 8181:8181 --address 0.0.0.0