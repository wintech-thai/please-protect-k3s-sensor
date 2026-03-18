#!/bin/bash

MODE=${1:-prod}

cd 01-bootstrap

kubectl apply -f argocd-ing.yaml
kubectl apply -f argocd-bootstrap-data-plane.yaml

if [ "$MODE" = "dev" ]; then
  echo "Deploying DEV control plane"
  kubectl apply -f argocd-bootstrap-control-plane-dev.yaml
fi

echo "Deploying PROD control plane"
kubectl apply -f argocd-bootstrap-control-plane-prod.yaml

kubectl apply -f argocd-cluster-secret.yaml

GIT_USER=$(kubectl get secret initial-secret -n default -o jsonpath='{.data.GIT_USER}' | base64 -d)
GIT_PASSWORD=$(kubectl get secret initial-secret -n default -o jsonpath='{.data.GIT_PASSWORD}' | base64 -d)

YAML_FILE="argocd-local-repo.yaml"
cp ${YAML_FILE} ${YAML_FILE}.tmp
sed -i "s|<<GITEA_USERNAME>>|${GIT_USER}|g" ${YAML_FILE}.tmp
sed -i "s|<<GITEA_PASSWORD>>|${GIT_PASSWORD}|g" ${YAML_FILE}.tmp
kubectl apply -f ${YAML_FILE}.tmp

cd ..
