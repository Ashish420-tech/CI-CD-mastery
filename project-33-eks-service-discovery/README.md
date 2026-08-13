# Project 33 — EKS Service Discovery Platform

Production-style Kubernetes service discovery platform deployed on Amazon EKS.

This project demonstrates how Kubernetes-native service discovery works using
ClusterIP Services, CoreDNS, Kubernetes DNS names, an internal service layer,
and an externally exposed gateway through an AWS Load Balancer.

---

## 🎯 Project Objective

Build and deploy a small microservice platform where:

- An external client reaches a gateway through an AWS Load Balancer.
- The gateway discovers backend services using Kubernetes DNS.
- Backend services remain internal using ClusterIP.
- Kubernetes/CoreDNS provides service discovery.
- Applications run as non-root containers.
- Readiness and liveness probes protect availability.
- Docker images are stored in Amazon ECR.
- The complete platform runs on Amazon EKS.

---

## 🏗️ Architecture

```text
                         Internet
                            │
                            ▼
                 ┌─────────────────────┐
                 │ AWS Load Balancer   │
                 │     gateway :80     │
                 └──────────┬──────────┘
                            │
                            ▼
                 ┌─────────────────────┐
                 │ Gateway Deployment  │
                 │      2 replicas     │
                 └──────────┬──────────┘
                            │
                  Kubernetes DNS
                            │
             ┌──────────────┴──────────────┐
             │                             │
             ▼                             ▼
┌─────────────────────────┐   ┌─────────────────────────┐
│ service-a               │   │ service-b               │
│ ClusterIP :5000         │   │ ClusterIP :5000         │
│ 2 replicas              │   │ 2 replicas              │
└─────────────────────────┘   └─────────────────────────┘
             │                             │
             └──────────── EKS ────────────┘
Kubernetes DNS

Gateway discovers:

service-a.project-33.svc.cluster.local:5000
service-b.project-33.svc.cluster.local:5000

CoreDNS resolves these names to Kubernetes ClusterIP addresses.

🧩 Components
Component	Purpose
Gateway	External API entry point and service discovery client
Service A	Internal backend microservice
Service B	Internal backend microservice
ClusterIP	Internal Kubernetes networking
CoreDNS	Kubernetes DNS/service discovery
AWS Load Balancer	External gateway access
Amazon ECR	Container image registry
Amazon EKS	Kubernetes runtime
📁 Project Structure
project-33-eks-service-discovery/
│
├── app/
│   ├── app.py
│   ├── Dockerfile
│   ├── requirements.txt
│   │
│   ├── service-a/
│   │   ├── app.py
│   │   ├── Dockerfile
│   │   └── requirements.txt
│   │
│   └── service-b/
│       ├── app.py
│       ├── Dockerfile
│       └── requirements.txt
│
├── k8s/
│   ├── namespace.yml
│   ├── services.yml
│   └── gateway.yml
│
├── tests/
│   └── test_service_discovery.py
│
├── .dockerignore
├── .gitignore
└── README.md
🐳 Container Images

Images are stored in Amazon ECR:

742820980479.dkr.ecr.ap-south-1.amazonaws.com/ci-cd-mastery/applications

Project 33 images:

project-33-gateway
project-33-service-a
project-33-service-b
☸️ Kubernetes Resources

Namespace:

project-33

Deployments:

gateway
service-a
service-b

Services:

gateway    LoadBalancer
service-a  ClusterIP
service-b  ClusterIP

Each workload uses two replicas.

🔐 Container Security

Containers run as a dedicated non-root user:

UID: 10001

Kubernetes security controls include:

runAsNonRoot: true
runAsUser: 10001
allowPrivilegeEscalation: false
capabilities:
  drop:
    - ALL

The containers also define CPU and memory requests/limits.

❤️ Health Checks

All workloads include Kubernetes readiness and liveness probes.

Example:

readinessProbe:
  httpGet:
    path: /health
    port: 5000

livenessProbe:
  httpGet:
    path: /health
    port: 5000

The application containers also include Docker health checks.

🧪 Automated Tests

The project includes YAML validation tests covering:

Namespace configuration
ClusterIP services
Kubernetes DNS configuration
Non-root security configuration

Run:

python3 -m pytest -q

Verified result:

4 passed
🔍 Kubernetes Manifest Validation

Before deployment:

kubectl apply --dry-run=client -f k8s/namespace.yml
kubectl apply --dry-run=client -f k8s/services.yml
kubectl apply --dry-run=client -f k8s/gateway.yml

All manifests successfully passed client-side validation.

🚀 Deployment

Create the namespace:

kubectl apply -f k8s/namespace.yml

Deploy backend services:

kubectl apply -f k8s/services.yml

Deploy the gateway:

kubectl apply -f k8s/gateway.yml

Verify:

kubectl get deployments -n project-33
kubectl get pods -n project-33
kubectl get svc -n project-33
🌐 Gateway API

The gateway exposes:

Root
GET /

Returns gateway status and hostname.

Health
GET /health

Returns:

{
  "status": "healthy"
}
Service Discovery
GET /discover

The gateway calls both backend services using Kubernetes DNS.

Expected response:

{
  "gateway": "service-discovery-gateway",
  "services": {
    "service-a": {
      "healthy": true,
      "status": 200,
      "url": "http://service-a.project-33.svc.cluster.local:5000"
    },
    "service-b": {
      "healthy": true,
      "status": 200,
      "url": "http://service-b.project-33.svc.cluster.local:5000"
    }
  }
}
✅ Production Runtime Verification

Project 33 was deployed to Amazon EKS and verified end-to-end.

Deployment Status
gateway     2/2
service-a   2/2
service-b   2/2
Pod Status

All six application pods were verified:

Running
0 restarts
Service Discovery

The gateway successfully discovered both services:

service-a → HTTP 200 → healthy
service-b → HTTP 200 → healthy
Kubernetes DNS

Direct DNS verification was also performed.

Service A:

service-a.project-33.svc.cluster.local
→ 172.20.35.63

Service B:

service-b.project-33.svc.cluster.local
→ 172.20.222.242

CoreDNS:

172.20.0.10:53

This proves that Kubernetes-native DNS service discovery is functioning inside the EKS cluster.

🔄 End-to-End Request Flow
Client
  │
  │ HTTP
  ▼
AWS Load Balancer
  │
  ▼
Gateway
  │
  │ HTTP request
  ▼
CoreDNS
  │
  ├── service-a.project-33.svc.cluster.local
  │
  └── service-b.project-33.svc.cluster.local
  │
  ▼
ClusterIP Services
  │
  ▼
Backend Pods
🛠️ Technologies
AWS EKS
Kubernetes
Amazon ECR
Kubernetes Services
CoreDNS
Docker
Python
Flask
Gunicorn
pytest
AWS Load Balancer
Terraform-managed EKS infrastructure
🎓 DevOps Concepts Demonstrated

This project demonstrates practical knowledge of:

Kubernetes service discovery
ClusterIP networking
Kubernetes DNS
CoreDNS
EKS networking
AWS Load Balancers
Container image lifecycle
Amazon ECR
Kubernetes Deployments
Rolling updates
Health probes
Resource management
Container security
Non-root execution
Microservice communication
Runtime troubleshooting
Production-style validation
🧠 Key Learning

Kubernetes Services provide stable networking endpoints while CoreDNS provides
DNS-based discovery.

Applications do not need to know the individual Pod IP addresses.

Instead, the gateway uses:

service-a.project-33.svc.cluster.local
service-b.project-33.svc.cluster.local

Kubernetes handles service-to-pod routing behind those stable DNS names.

This enables pods to be replaced, rescheduled, or scaled without requiring
application configuration changes.

🏁 Project Status
Project 33 — EKS Service Discovery Platform

Application              ✅
Docker                    ✅
Amazon ECR                ✅
EKS deployment            ✅
ClusterIP services        ✅
Kubernetes DNS            ✅
CoreDNS discovery         ✅
Gateway LoadBalancer      ✅
Health probes             ✅
Container security        ✅
Automated tests           ✅
Runtime verification      ✅
End-to-end discovery      ✅

Project 33 is functionally complete and verified on Amazon EKS.
