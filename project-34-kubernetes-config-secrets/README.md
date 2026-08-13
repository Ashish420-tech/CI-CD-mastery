
# Project 34 — Kubernetes Configuration & Secrets

Production-style Kubernetes configuration management deployed on Amazon EKS.

## Objective

Demonstrate how Kubernetes separates application configuration from container
images using ConfigMaps and Secrets while preserving secure workload defaults.

## Architecture

```text
                         Amazon EKS
                              |
                    +---------+---------+
                    |                   |
              ConfigMap              Secret
            non-sensitive           sensitive
                    |                   |
                    +---------+---------+
                              |
                         Pod environment
                              |
             +----------------+----------------+
             |                |                |
          Gateway          Service A        Service B
          2 replicas       2 replicas       2 replicas
             |
        LoadBalancer
Configuration

The application-config ConfigMap provides:

APP_ENVIRONMENT
LOG_LEVEL
SERVICE_A_URL
SERVICE_B_URL

These values are injected through Kubernetes envFrom.

Secrets

The application-secrets Secret contains:

API_TOKEN
DATABASE_PASSWORD

Actual values are created at deployment time and are intentionally not
committed to Git.

Create the Secret:

export API_TOKEN='...'
export DATABASE_PASSWORD='...'
./scripts/create-secret.sh
Security

Workloads use:

runAsNonRoot: true
runAsUser: 10001
allowPrivilegeEscalation: false
capabilities:
  drop:
    - ALL

The default ServiceAccount has no permission to read or list Kubernetes Secrets.

Verified:

kubectl auth can-i get secrets \
  --as=system:serviceaccount:project-34:default \
  -n project-34

no
Configuration Update Behavior

Environment variables sourced from a ConfigMap are captured when a Pod starts.

Therefore changing the ConfigMap does not change the environment of existing
Pods automatically.

Verified workflow:

ConfigMap LOG_LEVEL=INFO
        |
        v
Existing Pod -> INFO
        |
        v
ConfigMap changed to DEBUG
        |
        v
Controlled Deployment rollout
        |
        v
New Pod -> DEBUG

The Gateway remained available with 2/2 replicas during the rollout.

Validation

Client-side Kubernetes validation:

kubectl apply --dry-run=client -f k8s/namespace.yml
kubectl apply --dry-run=client -f k8s/configmap.yml
kubectl apply --dry-run=client -f k8s/services.yml
kubectl apply --dry-run=client -f k8s/gateway.yml

Automated tests:

python3 -m pytest -q
Runtime Verification

Verified on Amazon EKS:

Namespace project-34 active
Gateway: 2/2 Ready
Service A: 2/2 Ready
Service B: 2/2 Ready
All Pods Running
Zero unexpected restarts
ConfigMap successfully injected
Secret successfully injected
Secret values not exposed during validation
Gateway health returned HTTP 200
Service discovery returned HTTP 200 for Service A
Service discovery returned HTTP 200 for Service B
Kubernetes endpoints populated
Default ServiceAccount denied Secret read/list access
Non-root security controls verified
ConfigMap update and controlled rollout verified
Project Structure
project-34-kubernetes-config-secrets/
├── k8s/
│   ├── namespace.yml
│   ├── configmap.yml
│   ├── services.yml
│   └── gateway.yml
├── scripts/
│   └── create-secret.sh
├── tests/
│   └── test_config_secrets.py
├── .dockerignore
├── .gitignore
└── README.md
Project Status

COMPLETE

Project 34 successfully demonstrates production-style Kubernetes
configuration and secret management on the existing EKS platform.
