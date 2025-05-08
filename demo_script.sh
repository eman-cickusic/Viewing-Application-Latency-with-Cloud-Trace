#!/bin/bash
# This script generates multiple traces for the Cloud Trace demo

# Exit on any error
set -e

# Get the external IP of the cloud-trace-demo-a service
EXTERNAL_IP=$(kubectl get svc -o=jsonpath='{.items[?(@.metadata.name=="cloud-trace-demo-a")].status.loadBalancer.ingress[0].ip}')

if [ -z "$EXTERNAL_IP" ]; then
  echo "Error: Could not find external IP for cloud-trace-demo-a service"
  echo "Make sure the service is deployed and has an external IP assigned"
  exit 1
fi

echo "Found service at IP: $EXTERNAL_IP"

# Number of traces to generate
NUM_TRACES=${1:-10}
echo "Generating $NUM_TRACES traces..."

# Generate traces with variable sleep intervals
for (( i=1; i<=$NUM_TRACES; i++ ))
do
  echo "Generating trace $i of $NUM_TRACES..."
  curl -s $EXTERNAL_IP
  
  # Add a random delay between requests (1-3 seconds)
  DELAY=$(( $RANDOM % 3 + 1 ))
  echo "Waiting $DELAY seconds before next request..."
  sleep $DELAY
done

echo "Done generating traces. You can now view them in Cloud Trace in the Google Cloud Console."
echo "Navigate to: https://console.cloud.google.com/traces/list"
