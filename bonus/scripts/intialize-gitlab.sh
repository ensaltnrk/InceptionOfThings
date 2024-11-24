#!/bin/bash

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.3.0/deploy/static/provider/cloud/deploy.yaml
sleep 5
kubectl wait --for=condition=ready pod --all -n ingress-nginx --timeout=300s

kubectl create namespace gitlab
helm repo add gitlab http://charts.gitlab.io/
helm install gitlab gitlab/gitlab -f values.yaml -n gitlab
sleep 5

kubectl wait --for=condition=ready pod --all -n gitlab --timeout=300s


echo "Argocd password: " $(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo "Gitlab password: " $(kubectl -n gitlab get secret gitlab-gitlab-initial-root-password -ojsonpath='{.data.password}' | base64 -d ; echo)

kubectl delete ingress gitlab-webservice-default -n gitlab

kubectl apply -f ../confs/gitlab-ingress.yaml
kubectl apply -f ../confs/application.yaml

kubectl port-forward svc/gitlab-webservice-default -n gitlab 8181:8181 --adress 0.0.0.0 &
wait