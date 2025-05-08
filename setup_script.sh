#!/bin/bash
# This script sets up the Cloud Trace demo application on GKE

# Exit on any error
set -e

# Enable required APIs
echo "Enabling required GCP APIs..."
gcloud services enable container.googleapis.com

# Set zone (if not already set)
if [ -z "$ZONE" ]; then
  # Default to us-central1-a if not specified
  export ZONE=us-central1-a
  echo "Using default zone: $ZONE"
fi

# Create GKE cluster if it doesn't exist
if ! gcloud container clusters describe cloud-trace-demo --zone $ZONE &>/dev/null; then
  echo "Creating GKE cluster cloud-trace-demo in zone $ZONE..."
  gcloud container clusters create cloud-trace-demo \
    --zone $ZONE
else
  echo "GKE cluster cloud-trace-demo already exists in zone $ZONE"
fi

# Get credentials for the cluster
echo "Getting cluster credentials..."
gcloud container clusters get-credentials cloud-trace-demo --zone $ZONE

# Verify access to the cluster
echo "Verifying cluster access..."
kubectl get nodes

# Deploy the three services
echo "Deploying service A..."
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cloud-trace-demo-a
spec:
  replicas: 1
  selector:
    matchLabels:
      app: cloud-trace-demo-a
  template:
    metadata:
      labels:
        app: cloud-trace-demo-a
    spec:
      containers:
      - name: cloud-trace-demo-a
        image: gcr.io/cloud-trace-demo/trace-demo-app:latest
        env:
        - name: SERVICE_NAME
          value: "cloud-trace-demo-a"
        - name: SERVICE_B_URL
          value: "http://cloud-trace-demo-b:8080"
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: cloud-trace-demo-a
spec:
  type: LoadBalancer
  selector:
    app: cloud-trace-demo-a
  ports:
  - port: 80
    targetPort: 8080
EOF

echo "Deploying service B..."
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cloud-trace-demo-b
spec:
  replicas: 1
  selector:
    matchLabels:
      app: cloud-trace-demo-b
  template:
    metadata:
      labels:
        app: cloud-trace-demo-b
    spec:
      containers:
      - name: cloud-trace-demo-b
        image: gcr.io/cloud-trace-demo/trace-demo-app:latest
        env:
        - name: SERVICE_NAME
          value: "cloud-trace-demo-b"
        - name: SERVICE_C_URL
          value: "http://cloud-trace-demo-c:8080"
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: cloud-trace-demo-b
spec:
  selector:
    app: cloud-trace-demo-b
  ports:
  - port: 8080
    targetPort: 8080
EOF

echo "Deploying service C..."
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cloud-trace-demo-c
spec:
  replicas: 1
  selector:
    matchLabels:
      app: cloud-trace-demo-c
  template:
    metadata:
      labels:
        app: cloud-trace-demo-c
    spec:
      containers:
      - name: cloud-trace-demo-c
        image: gcr.io/cloud-trace-demo/trace-demo-app:latest
        env:
        - name: SERVICE_NAME
          value: "cloud-trace-demo-c"
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: cloud-trace-demo-c
spec:
  selector:
    app: cloud-trace-demo-c
  ports:
  - port: 8080
    targetPort: 8080
EOF

echo "Waiting for services to be ready..."
kubectl rollout status deployment/cloud-trace-demo-a
kubectl rollout status deployment/cloud-trace-demo-b
kubectl rollout status deployment/cloud-trace-demo-c

echo "Waiting for external IP address..."
while [ -z "$(kubectl get svc cloud-trace-demo-a -o=jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)" ]; do
  echo "Waiting for external IP..."
  sleep 5
done

EXTERNAL_IP=$(kubectl get svc cloud-trace-demo-a -o=jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "Service is available at: http://$EXTERNAL_IP"
echo "You can generate traces by running: curl $EXTERNAL_IP"
echo "Setup complete!"
