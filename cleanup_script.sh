#!/bin/bash
# This script cleans up the Cloud Trace demo resources to avoid incurring charges

# Exit on any error
set -e

# Set zone (if not already set)
if [ -z "$ZONE" ]; then
  # Default to us-central1-a if not specified
  export ZONE=us-central1-a
  echo "Using default zone: $ZONE"
fi

echo "Deleting Cloud Trace demo services..."
kubectl delete deployment cloud-trace-demo-a cloud-trace-demo-b cloud-trace-demo-c --ignore-not-found
kubectl delete service cloud-trace-demo-a cloud-trace-demo-b cloud-trace-demo-c --ignore-not-found

echo "Deleting GKE cluster cloud-trace-demo in zone $ZONE..."
gcloud container clusters delete cloud-trace-demo --zone $ZONE --quiet

echo "Cleanup complete!"
