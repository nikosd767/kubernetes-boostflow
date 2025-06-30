#!/bin/bash

# BoostFlow Kubernetes Deployment Script
echo "Deploying BoostFlow to Kubernetes..."

# Check if .env.local exists
if [ ! -f ".env.local" ]; then
    echo "Error: .env.local file not found!"
    echo "Please create .env.local file with your configuration."
    exit 1
fi

# Create namespace if it doesn't exist
#kubectl create namespace default --dry-run=client -o yaml | kubectl apply -f -

# Generate secrets and configmaps from .env.local
echo "Creating secrets and configmaps from .env.local..."
if [ -f "create-secrets-from-env.sh" ]; then
    chmod +x create-secrets-from-env.sh
    ./create-secrets-from-env.sh
else
    echo "Warning: create-secrets-from-env.sh not found, using manual secret creation..."
fi

# Apply generated secrets and configmaps
echo "Applying secrets and configmaps..."
if [ -f "Firebase/Firebase-secret-generated.yaml" ]; then
    kubectl apply -f Firebase/Firebase-secret-generated.yaml
else
    echo "Warning: Using existing Firebase secret..."
    kubectl apply -f Firebase/Firebase-secret.yaml
fi

if [ -f "MinIO/minio-secret-generated.yaml" ]; then
    kubectl apply -f MinIO/minio-secret-generated.yaml
fi

if [ -f "oauth-secret-generated.yaml" ]; then
    kubectl apply -f oauth-secret-generated.yaml
fi

if [ -f "email-secret-generated.yaml" ]; then
    kubectl apply -f email-secret-generated.yaml
fi

if [ -f "app-configmap-generated.yaml" ]; then
    kubectl apply -f app-configmap-generated.yaml
fi

# Create Docker registry credentials secret
echo "Creating Docker registry credentials..."
# Make sure you have created the .dockerconfig.json file with your GitHub token
kubectl create secret docker-registry registry-credentials \
  --from-file=.dockerconfigjson=.dockerconfig.json \
  --dry-run=client -o yaml | kubectl apply -f -

# Deploy MinIO first
echo "Deploying MinIO storage..."
kubectl apply -f MinIO/minio-deployment.yaml

# Wait for MinIO to be ready
echo "Waiting for MinIO to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/minio-deployment

# Deploy BoostFlow application
echo "Deploying BoostFlow application..."
kubectl apply -f Boostflow/Boostflow-deployment.yaml
kubectl apply -f Boostflow/Boostflow-svc.yaml

# Wait for deployment to be ready
echo "Waiting for deployment to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/boostflow-deployment

# Apply ingress
echo "Setting up ingress..."
kubectl apply -f Boostflow/Boostflow-ingress.yaml

# Show status
echo "Deployment completed!"
echo ""
echo "Current status:"
kubectl get deployments,services,ingress -l app=boostflow
kubectl get deployments,services,ingress -l app=minio

echo ""
echo "Your applications will be available at:"
echo "BoostFlow App: https://react.boostflow.dns-cloud.new.net"
echo "MinIO Console: https://minio.boostflow.dns-cloud.new.net"
echo "MinIO API: https://minio-api.boostflow.dns-cloud.new.net"
echo ""
echo "Useful commands:"
echo "kubectl logs -f deployment/boostflow-deployment"
echo "kubectl logs -f deployment/minio-deployment"
echo "kubectl get pods -l app=boostflow"
echo "kubectl get pods -l app=minio"
echo "kubectl describe ingress boostflow-ingress"
