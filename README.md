# Viewing Application Latency with Cloud Trace

This repository documents the process of using Google Cloud's Cloud Trace to monitor and analyze application latency in a sample application deployed on Google Kubernetes Engine (GKE).

## Overview

In this project, I deployed a sample Python application to a Google Kubernetes Engine (GKE) cluster and used Cloud Trace to monitor and analyze application latency. The sample application consists of three microservices that communicate with each other, allowing us to observe distributed tracing in action.

## Objectives 

- Deploy a sample application to a Google Kubernetes Engine (GKE) cluster
- Create traces by sending HTTP requests to the sample application
- Use the Cloud Trace interface to view and analyze latency information

## Prerequisites   

- Google Cloud Platform account
- Access to Google Cloud Shell or local environment with:
  - `gcloud` command line tool
  - `kubectl` command line tool
  - `git` command line tool
 
## Video

https://youtu.be/0vvhq8Y_zQQ


## Step 1: Download and Deploy the Application

### Clone the Sample Repository

```bash
git clone https://github.com/GoogleCloudPlatform/python-docs-samples.git
```

### Enable the Google Kubernetes Engine API

```bash
gcloud services enable container.googleapis.com
```

### Create a GKE Cluster

```bash
# Set your desired zone
ZONE=us-central1-a  # Replace with your preferred zone

# Create the cluster
gcloud container clusters create cloud-trace-demo \
   --zone $ZONE
```

This command takes a few minutes to complete. After completion, your Google Cloud project will contain a GKE cluster named `cloud-trace-demo`.

### Update GKE Cluster Credentials

```bash
gcloud container clusters get-credentials cloud-trace-demo --zone $ZONE
```

### Verify Cluster Access

```bash
kubectl get nodes
```

Sample output:
```
NAME                                              STATUS   ROLES    AGE   VERSION
gke-cloud-trace-demo-default-pool-063c0416-113s   Ready    <none>   78s   v1.22.12-gke.2300
gke-cloud-trace-demo-default-pool-063c0416-1n27   Ready    <none>   79s   v1.22.12-gke.2300
gke-cloud-trace-demo-default-pool-063c0416-frkd   Ready    <none>   78s   v1.22.12-gke.2300
```

### Deploy the Sample Application

```bash
cd python-docs-samples/trace/cloud-trace-demo-app-opentelemetry && ./setup.sh
```

The `setup.sh` script configures the three services of the application using pre-built images. The workloads are named:
- `cloud-trace-demo-a`
- `cloud-trace-demo-b`
- `cloud-trace-demo-c`

The setup script waits for all resources to be provisioned, which might take several minutes to complete.

Sample output:
```
deployment.apps/cloud-trace-demo-a is created
service/cloud-trace-demo-a is created
deployment.apps/cloud-trace-demo-b is created
service/cloud-trace-demo-b is created
deployment.apps/cloud-trace-demo-c is created
service/cloud-trace-demo-c is created
```

## Step 2: Create a Trace

### Generate Traces with HTTP Requests

Send a curl request to `cloud-trace-demo-a` service:

```bash
curl $(kubectl get svc -o=jsonpath='{.items[?(@.metadata.name=="cloud-trace-demo-a")].status.loadBalancer.ingress[0].ip}')
```

You can execute this command multiple times to generate multiple traces.

Expected output:
```
Hello, I am service A
And I am service B
Hello, I am service C
```

## Step 3: View and Analyze Trace Data

1. In the Google Cloud Console, navigate to **Observability > Trace**
2. Explore the heatmap of span durations over time
   - Each colored block represents a span
   - Color intensity indicates duration
   - This visualization helps quickly identify slow spans or latency trends
3. Click on darker span blocks to investigate potential performance issues
4. In the Spans table, click any Span ID to see a detailed breakdown of the trace
   - Each horizontal bar represents the duration of a span within the trace
   - The length of the bar corresponds to the span's duration
5. Click on individual span bars to view more details in the details pane

## Architecture

The sample application consists of three microservices:
- Service A: Entry point that receives HTTP requests
- Service B: Intermediate service called by Service A
- Service C: Backend service called by Service B

When a request is made to Service A, it calls Service B, which in turn calls Service C. This creates a distributed trace that shows the request flow across all three services.

## Understanding Cloud Trace

Cloud Trace is a distributed tracing system that helps you understand how requests propagate through your application. Key concepts:

- **Trace**: A collection of spans representing a single request as it flows through different services
- **Span**: An individual operation within a trace, with a start and end time
- **Span Attributes**: Key-value pairs that provide additional context about a span
- **Parent-Child Relationships**: Shows how spans relate to each other within a trace

By analyzing trace data, you can:
- Identify performance bottlenecks
- Debug latency issues
- Understand request flow through your system
- Monitor and improve application performance

## Additional Resources

- [Cloud Trace Documentation](https://cloud.google.com/trace/docs)
- [OpenTelemetry for Python](https://opentelemetry.io/docs/python/)
- [Google Kubernetes Engine Documentation](https://cloud.google.com/kubernetes-engine/docs)

## Cleanup

To avoid incurring charges, delete the resources when you're finished:

```bash
# Delete the GKE cluster
gcloud container clusters delete cloud-trace-demo --zone $ZONE
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.
