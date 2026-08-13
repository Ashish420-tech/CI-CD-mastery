# Project 32 — Enterprise Kubernetes Observability

> Production-oriented Kubernetes observability platform using Prometheus, Grafana, kube-state-metrics, Node Exporter and application-native Prometheus metrics.

## Executive Summary

This project builds a Kubernetes observability foundation on Minikube.

The platform combines:

- Application metrics
- Kubernetes object-state metrics
- Node-level metrics
- Prometheus collection
- Grafana visualization
- Kubernetes RBAC
- Pod health probes
- Resource governance
- Non-root execution
- Linux capability dropping
- Seccomp RuntimeDefault
- GitHub Actions validation

The project intentionally separates CI validation from Kubernetes runtime validation:

```text
GitHub Actions
   |
   +-- pytest
   +-- YAML validation
   +-- Helm lint
   +-- Helm template
   |
   v
CI validation

Minikube
   |
   +-- Kubernetes deployment
   +-- Prometheus
   +-- Grafana
   +-- kube-state-metrics
   +-- Node Exporter
   |
   v
Runtime observability
Architecture
                    Kubernetes Cluster
                           |
             +-------------+-------------+
             |                           |
             v                           v
     Observability App             Monitoring Stack
        2 replicas                      |
             |                    +-----+------+
             |                    |            |
          /metrics             Prometheus   Grafana
             |                    |
             +--------------------+
                                  |
                    +-------------+-------------+
                    |                           |
                    v                           v
             kube-state-metrics          Node Exporter
                    |                           |
                    +-------------+-------------+
                                  |
                                  v
                         Kubernetes Metrics
Technology Stack
Technology	Purpose
Kubernetes	Container orchestration
Minikube	Local Kubernetes environment
Helm	Monitoring stack deployment
Prometheus	Metrics collection/querying
Grafana	Metrics visualization
kube-state-metrics	Kubernetes object-state metrics
Node Exporter	Node-level metrics
Flask	Application API
Gunicorn	Production WSGI server
Python 3.12	Application runtime
pytest	Automated testing
GitHub Actions	CI validation
Application

The application exposes:

GET /
GET /health
GET /metrics

Example health response:

{
  "status": "healthy",
  "uid": 10001
}

The application exports:

k8s_observability_requests_total
k8s_observability_uptime_seconds
Prometheus Integration

The application uses Kubernetes pod annotations:

prometheus.io/scrape: "true"
prometheus.io/path: "/metrics"
prometheus.io/port: "5000"

Prometheus discovers the application and scrapes the metrics endpoint.

This demonstrates the relationship:

Pod
 |
 +-- /metrics
       |
       v
   Prometheus
       |
       v
 PromQL / Grafana
Kubernetes Security

The application runs as:

UID 10001
GID 10001

Pod security configuration includes:

runAsNonRoot: true
runAsUser: 10001
runAsGroup: 10001
seccompProfile:
  type: RuntimeDefault

Container security includes:

allowPrivilegeEscalation: false

capabilities:
  drop:
    - ALL

These controls implement least privilege and reduce container escape/privilege-escalation risk.

Health Management

The deployment uses both:

Readiness Probe

Determines whether the pod should receive traffic.

/health
Liveness Probe

Determines whether Kubernetes should restart an unhealthy container.

/health

Interview distinction:

Readiness controls traffic eligibility; liveness controls process recovery.

Resource Governance

The application specifies:

requests:
  cpu: 50m
  memory: 64Mi

limits:
  cpu: 250m
  memory: 256Mi

Requests influence scheduling.

Limits constrain maximum resource consumption.

This prevents an individual workload from consuming unlimited cluster resources.

RBAC

The project defines:

ServiceAccount
ClusterRole
ClusterRoleBinding

The monitoring identity receives only the Kubernetes API permissions required for observation.

This demonstrates:

Kubernetes observability should follow least-privilege RBAC rather than using unrestricted cluster access.

Helm

The monitoring platform is deployed using:

prometheus-community/kube-prometheus-stack

The stack provides:

Prometheus
Grafana
Prometheus Operator
kube-state-metrics
Node Exporter

The project validates both:

helm lint
helm template

before runtime deployment.

Runtime Validation

The Minikube environment validates:

Namespace
ConfigMap
RBAC
Application Deployment
Application Service
Pod readiness
Pod liveness
Application metrics
Prometheus
Grafana
kube-state-metrics
Node Exporter
CI/CD

Dedicated workflow:

.github/workflows/project-32-kubernetes-observability.yml

Pipeline:

Checkout
   |
Python 3.12
   |
pytest
   |
YAML validation
   |
Helm repository
   |
Pinned chart download
   |
Helm lint
   |
Helm template
   |
Kubernetes manifest validation

CI deliberately does not attempt to connect to the developer's local Minikube cluster.

GitHub-hosted runners are separate machines from the developer's WSL environment.

Troubleshooting
Prometheus target DOWN

Check:

kubectl get pods -n observability
kubectl get svc -n observability

Then inspect:

kubectl logs -n observability deploy/observability-app

Validate the metrics endpoint:

kubectl port-forward \
  -n observability \
  svc/observability-app \
  5001:5000

curl http://localhost:5001/metrics
Pod not Ready

Check:

kubectl describe pod -n observability <pod>

Then inspect:

kubectl logs -n observability <pod>
Helm failure

Validate:

helm lint \
  prometheus-community/kube-prometheus-stack \
  -f helm/values.yaml

Render:

helm template monitoring \
  prometheus-community/kube-prometheus-stack \
  -n observability \
  -f helm/values.yaml
Interview Questions
Why Prometheus?

Prometheus provides pull-based metrics collection, time-series storage and PromQL querying. It is well suited to Kubernetes environments.

Why Grafana?

Grafana provides dashboards and visualization over Prometheus metrics.

Why kube-state-metrics?

kube-state-metrics exposes the state of Kubernetes API objects such as deployments, pods, replicasets and jobs.

Why Node Exporter?

Node Exporter provides host-level metrics such as CPU, memory, filesystem and network statistics.

Readiness vs liveness?

Readiness determines whether a pod can receive traffic. Liveness determines whether Kubernetes should restart the container.

Requests vs limits?

Requests influence scheduling and represent expected resource consumption. Limits constrain maximum consumption.

Why non-root?

A compromised application running as non-root has less privilege and therefore a smaller blast radius.

Why RBAC?

RBAC implements least privilege for Kubernetes API access.

Why Helm?

Helm packages complex Kubernetes applications into repeatable, configurable releases.

Production Evolution

This Minikube implementation is the foundation for the EKS track.

The production evolution is:

Minikube
   |
   v
AWS EKS
   |
   +-- ECR
   +-- IAM / IRSA
   +-- EBS CSI
   +-- AWS Load Balancer Controller
   +-- Prometheus
   +-- Grafana
   +-- Alertmanager
   +-- HPA
   +-- NetworkPolicy
   +-- CloudWatch
Project Outcome

The project demonstrates practical Kubernetes observability rather than simply installing Prometheus.

It validates:

application telemetry
Kubernetes telemetry
node telemetry
monitoring discovery
security
RBAC
health management
resource governance
Helm
CI validation
Status

Project 32 — COMPLETE

Dedicated branch: project-32-kubernetes-observability
Dedicated GitHub Actions workflow: GREEN
Application metrics: VERIFIED
Kubernetes manifests: VERIFIED
Helm validation: VERIFIED
Prometheus stack: VERIFIED
Grafana: VERIFIED
kube-state-metrics: VERIFIED
Node Exporter: VERIFIED
Security controls: VERIFIED
RBAC: VERIFIED
EOF
