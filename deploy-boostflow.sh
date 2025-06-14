#!/bin/bash

# BoostFlow Kubernetes Deployment Script
echo "🚀 Deploying BoostFlow to Kubernetes..."

# Create namespace if it doesn't exist
#kubectl create namespace default --dry-run=client -o yaml | kubectl apply -f -

# Apply Firebase configuration secret
echo "📝 Creating Firebase configuration secret..."
kubectl apply -f firebase-secret.yaml

# Create Docker registry credentials secret
echo "🔐 Creating Docker registry credentials..."
# Make sure you have created the .dockerconfig.json file with your GitHub token
kubectl create secret docker-registry registry-credentials \
  --from-file=.dockerconfigjson=.dockerconfig.json \
  --dry-run=client -o yaml | kubectl apply -f -

# Deploy BoostFlow application
echo "🏗️ Deploying BoostFlow application..."
kubectl apply -f boostflow-deployment.yaml
kubectl apply -f boostflow-svc.yaml

# Wait for deployment to be ready
echo "⏳ Waiting for deployment to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/boostflow-deployment

# Apply ingress
echo "🌐 Setting up ingress..."
kubectl apply -f boostflow-ingress.yaml

# Show status
echo "✅ Deployment completed!"
echo ""
echo "📊 Current status:"
kubectl get deployments,services,ingress -l app=boostflow

echo ""
echo "🔗 Your application will be available at:"
echo "   https://react.boostflow.dns-cloud.new.net"
echo ""
echo "📋 Useful commands:"
echo "   kubectl logs -f deployment/boostflow-deployment"
echo "   kubectl get pods -l app=boostflow"
echo "   kubectl describe ingress boostflow-ingress"