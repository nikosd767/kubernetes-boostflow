#!/bin/bash

# Script to create Kubernetes secrets and configmaps from .env.local file
# Run this script to generate secrets before deploying

set -e

ENV_FILE=".env.local"

if [ ! -f "$ENV_FILE" ]; then
    echo "Error: .env.local file not found!"
    exit 1
fi

echo "Creating Kubernetes secrets and configmaps from $ENV_FILE..."

# Source the .env.local file
source $ENV_FILE

# Create Firebase secret
echo "Creating Firebase secret..."
kubectl create secret generic firebase-config \
    --from-literal=api-key="$NEXT_PUBLIC_FIREBASE_API_KEY" \
    --from-literal=auth-domain="$NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN" \
    --from-literal=project-id="$NEXT_PUBLIC_FIREBASE_PROJECT_ID" \
    --from-literal=storage-bucket="$NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET" \
    --from-literal=messaging-sender-id="$NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID" \
    --from-literal=app-id="$NEXT_PUBLIC_FIREBASE_APP_ID" \
    --from-literal=measurement-id="$NEXT_PUBLIC_FIREBASE_MEASUREMENT_ID" \
    --from-literal=service-account-key="$FIREBASE_SERVICE_ACCOUNT_KEY" \
    --dry-run=client -o yaml > Firebase/Firebase-secret-generated.yaml

# Create MinIO secret
echo "Creating MinIO secret..."
kubectl create secret generic minio-config \
    --from-literal=root-user="$MINIO_ROOT_USER" \
    --from-literal=root-password="$MINIO_ROOT_PASSWORD" \
    --from-literal=endpoint="$MINIO_ENDPOINT" \
    --from-literal=external-endpoint="$MINIO_EXTERNAL_ENDPOINT" \
    --from-literal=port="$MINIO_PORT" \
    --from-literal=use-ssl="$MINIO_USE_SSL" \
    --from-literal=profile-pictures-bucket="$MINIO_PROFILE_PICTURES_BUCKET" \
    --from-literal=project-documents-bucket="$MINIO_PROJECT_DOCUMENTS_BUCKET" \
    --dry-run=client -o yaml > MinIO/minio-secret-generated.yaml

# Create OAuth secret
echo "Creating OAuth secret..."
kubectl create secret generic oauth-config \
    --from-literal=google-client-id="$GOOGLE_CLIENT_ID" \
    --from-literal=google-client-secret="$GOOGLE_CLIENT_SECRET" \
    --from-literal=github-client-id="$GITHUB_CLIENT_ID" \
    --from-literal=github-client-secret="$GITHUB_CLIENT_SECRET" \
    --from-literal=oauth-client-id="$NEXT_PUBLIC_OAUTH_CLIENT_ID" \
    --dry-run=client -o yaml > oauth-secret-generated.yaml

# Create Email secret
echo "Creating Email secret..."
kubectl create secret generic email-config \
    --from-literal=sendgrid-api-key="$SENDGRID_API_KEY" \
    --from-literal=default-from-email="$DEFAULT_FROM_EMAIL" \
    --from-literal=mailhog-host="$MAILHOG_HOST" \
    --from-literal=mailhog-port="$MAILHOG_PORT" \
    --dry-run=client -o yaml > email-secret-generated.yaml

# Create App ConfigMap
echo "Creating App ConfigMap..."
kubectl create configmap app-config \
    --from-literal=node-env="$NODE_ENV" \
    --from-literal=app-url="$NEXT_PUBLIC_APP_URL" \
    --from-literal=google-maps-api-key="$NEXT_PUBLIC_GOOGLE_MAPS_API_KEY" \
    --from-literal=gemini-api-key="$GEMINI_API_KEY" \
    --dry-run=client -o yaml > app-configmap-generated.yaml

echo "Generated files:"
echo "  - Firebase/Firebase-secret-generated.yaml"
echo "  - MinIO/minio-secret-generated.yaml"
echo "  - oauth-secret-generated.yaml"
echo "  - email-secret-generated.yaml"
echo "  - app-configmap-generated.yaml"
echo ""
echo "To apply these secrets and configmaps:"
echo "  kubectl apply -f Firebase/Firebase-secret-generated.yaml"
echo "  kubectl apply -f MinIO/minio-secret-generated.yaml"
echo "  kubectl apply -f oauth-secret-generated.yaml"
echo "  kubectl apply -f email-secret-generated.yaml"
echo "  kubectl apply -f app-configmap-generated.yaml"
echo ""
echo "Or apply all at once:"
echo "  kubectl apply -f Firebase/Firebase-secret-generated.yaml -f MinIO/minio-secret-generated.yaml -f oauth-secret-generated.yaml -f email-secret-generated.yaml -f app-configmap-generated.yaml"