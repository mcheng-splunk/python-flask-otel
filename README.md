# Python Flask App with Splunk OpenTelemetry Auto-Instrumentation

This repository contains a minimal **Python 3.x Flask application** that is configured for **Splunk OpenTelemetry auto-instrumentation**. It is intended to be deployed on Kubernetes and fully instrumented for observability.

---

## Requirements

- Python **3.11 or higher** (3.11 tested working)
- Flask >= 2.3.0
- Docker
- Kubernetes cluster (any platform)
- Splunk OpenTelemetry Collector deployed in the cluster (optional)

---

## Project Structure

```text
python-app/
├─ app/
│ └─ main.py # Flask application
├─ requirements.txt # Python dependencies
└─ Dockerfile # Dockerfile with OTel instrumentation
```

---

## Python Auto-Instrumentation Using Dockerfile 

The application uses **Splunk OpenTelemetry Python Agent** for auto-instrumentation if we are not going to use the **zero-code instrumentation**

Key points:

1. The Python runtime **must be 3.11+** to avoid compatibility issues with the OpenTelemetry agent (Python 3.7 will fail due to `functools.cached_property` import errors).  
2. Auto-instrumentation is enabled by running the app via:

```bash
opentelemetry-instrument python app/main.py
```

This is reflected in the Dockerfile CMD:

```CMD ["opentelemetry-instrument", "python", "app/main.py"]```

## Dockerfile Notes

Use Python 3.9+ base image (python:3.11-slim recommended)

Install Flask and Splunk OpenTelemetry agent:

```bash
RUN pip install --upgrade pip \
    && pip install -r requirements.txt \
    && pip install splunk-opentelemetry
```
and also

```bash
# Command to run
CMD ["opentelemetry-instrument", "python", "app/main.py"]
```

## Expose Flask port 5000

Run the app using opentelemetry-instrument to enable telemetry

## Kubernetes Deployment (Instrumenting via zero-code instrumentation)

The application can be deployed using a Deployment + Service.

Enable auto-instrumentation in Kubernetes by ensuring:

1. Environment variables for OTel agent are configured:
env:
    - name: OTEL_SERVICE_NAME
    value: "python-flask-app"
    - name: OTEL_EXPORTER_OTLP_ENDPOINT
    value: "http://splunk-otel-collector-agent.otel.svc.cluster.local:4318"
    - name: OTEL_RESOURCE_ATTRIBUTES
    value: "deployment.environment=dev"

2. If using annotations for instrumentation (e.g., via OTel operator):
```yaml
    metadata:
      annotations:
        instrumentation.splunk.com/enabled: "otel/splunk-otel-collector"
```

3. Ensure imagePullPolicy: Always for fresh image pulls

## Build & Run for Multi Platform

Build Multi-Platform Docker Image
```bash
docker buildx create --use
docker buildx build --platform linux/amd64,linux/arm64 -t melcheng/python-flask-app:latest --push .
```

Run Locally

```docker run -p 5000:5000 melcheng/python-flask-app:latest
curl http://localhost:5000
# "Hello from Python!"
```

## Deploy to Kubernetes

```bash
kubectl apply -f Deployment.yaml
kubectl get pods
kubectl port-forward svc/python-flask-app 5000:5000
```

## Notes

Python version 3.9+ is critical for Splunk OpenTelemetry compatibility

Auto-instrumentation must be enabled via Dockerfile CMD or Kubernetes command override

Environment variables and annotations in Kubernetes are required to export telemetry to your collector