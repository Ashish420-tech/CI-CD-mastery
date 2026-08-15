# 🚀 Project 36 — Production-Grade Helm Application Packaging & CI/CD

> **From source code to a secure, immutable Kubernetes deployment on Amazon EKS — using Helm, GitHub Actions, ECR, Trivy and Gitleaks.**

![AWS](https://img.shields.io/badge/AWS-EKS-orange?logo=amazonaws)
![Kubernetes](https://img.shields.io/badge/Kubernetes-1.34-blue?logo=kubernetes)
![Helm](https://img.shields.io/badge/Helm-3.19-blue?logo=helm)
![Docker](https://img.shields.io/badge/Docker-29-blue?logo=docker)
![Python](https://img.shields.io/badge/Python-3.12-blue?logo=python)
![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-CI%2FCD-black?logo=githubactions)
![Trivy](https://img.shields.io/badge/Trivy-Security-blue)
![Gitleaks](https://img.shields.io/badge/Gitleaks-Secrets-red)

---

## 🎯 Project Objective

Build a reusable, production-oriented Helm application package and connect it to a complete CI/CD pipeline.

The project demonstrates how a developer change travels through:

```text
Developer
   │
   ▼
Git Push
   │
   ▼
Gitleaks
   │
   ▼
Automated Tests
   │
   ▼
Helm Validation
   │
   ▼
Docker Build
   │
   ▼
Trivy Security Scan
   │
   ▼
Amazon ECR
   │
   ▼
GitHub OIDC
   │
   ▼
Amazon EKS
   │
   ▼
Helm Deployment
   │
   ▼
Kubernetes Rollout
   │
   ▼
Application Smoke Test


🏗️ Architecture
                         ┌─────────────────────┐
                         │      Developer      │
                         │      Git Push       │
                         └──────────┬──────────┘
                                    │
                                    ▼
                         ┌─────────────────────┐
                         │   GitHub Actions    │
                         └──────────┬──────────┘
                                    │
                     ┌──────────────┼──────────────┐
                     ▼              ▼              ▼
                 Gitleaks         Pytest       Helm Lint
                     │              │              │
                     └──────────────┼──────────────┘
                                    ▼
                            Docker Build
                                    │
                                    ▼
                              Trivy Scan
                                    │
                                    ▼
                           Amazon ECR Image
                                    │
                                    ▼
                           GitHub OIDC → AWS
                                    │
                                    ▼
                              Amazon EKS
                                    │
                                    ▼
                              Helm Release
                                    │
                                    ▼
                           Kubernetes Pods
                                    │
                                    ▼
                           Smoke Test /health
                                    │
                                    ▼
                            /version endpoint
🧰 Technology Stack
Layer	Technology
Application	Python / Flask
Containerization	Docker
Packaging	Helm
Orchestration	Kubernetes
Cloud	AWS EKS
Container Registry	Amazon ECR
CI/CD	GitHub Actions
Authentication	GitHub OIDC
Secret Detection	Gitleaks
Image Security	Trivy
Testing	Pytest
Infrastructure	Terraform
Region	AWS ap-south-1
📁 Project Structure
project-36-helm-application-packaging/
│
├── app/
│   ├── app.py
│   ├── Dockerfile
│   ├── requirements.txt
│   └── .dockerignore
│
├── chart/
│   └── project-36-app/
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/
│           ├── _helpers.tpl
│           ├── configmap.yaml
│           ├── deployment.yaml
│           └── service.yaml
│
├── tests/
│   └── test_helm.py
│
└── README.md
🔐 Security by Design

This project implements security controls throughout the delivery lifecycle.

Source security

Gitleaks scans the repository before downstream CI/CD stages proceed.

Container security

Trivy scans the built Docker image for:

HIGH vulnerabilities
CRITICAL vulnerabilities
Kubernetes security

The Deployment uses:

runAsNonRoot
runAsUser: 10001
allowPrivilegeEscalation: false
dropped Linux capabilities
seccompProfile: RuntimeDefault
disabled automatic ServiceAccount token mounting
CPU/memory requests and limits
AWS authentication

GitHub Actions authenticates to AWS using:

GitHub OIDC
     ↓
IAM Role
     ↓
AWS APIs

No long-lived AWS access keys are required in GitHub Actions.

⎈ Helm Packaging

The application is packaged as a reusable Helm chart.

Chart.yaml
values.yaml
templates/

The chart creates:

ConfigMap
Deployment
Service

Configuration is separated from the application image through Helm values and Kubernetes ConfigMaps.

🐳 Immutable Container Deployment

The CI/CD pipeline uses the Git commit SHA as the image tag:

<git-sha>

Example:

742820980479.dkr.ecr.ap-south-1.amazonaws.com/
ci-cd-mastery/applications:<GIT_SHA>

This provides:

immutable deployment references
traceability
reproducibility
easier rollback
clear source-to-production mapping
🔄 CI/CD Pipeline

The Project 36 workflow performs:

1. Security Gate
Gitleaks

Secrets detected → pipeline stops.

2. Application Tests
pytest
3. Helm Validation
helm lint
helm template
helm package
4. Container Build
docker build
5. Container Security
Trivy

HIGH/CRITICAL vulnerabilities → deployment blocked.

6. ECR Push

The image is pushed using the immutable Git SHA.

7. AWS Authentication

GitHub Actions uses:

OIDC → IAM Role
8. EKS Deployment
helm upgrade --install
9. Rollout Verification
kubectl rollout status
10. Kubernetes Smoke Test

The deployed application is tested from inside the cluster.

🧪 Application Endpoints
Application
GET /

Returns application metadata.

Health
GET /health

Example:

{
  "status": "healthy"
}
Readiness
GET /ready

Example:

{
  "status": "ready"
}
Version
GET /version

Example:

{
  "application": "project-36-helm-app",
  "version": "1.0.0",
  "environment": "production",
  "deployment": "helm",
  "ci_cd": "github-actions"
}

The /version endpoint provides a simple way to demonstrate that an application code change travelled through the CI/CD pipeline and reached Kubernetes.

☸️ Kubernetes Deployment

Expected resources:

Namespace
   └── project-36
       ├── Deployment/project-36
       ├── Service/project-36
       └── ConfigMap/project-36-config

The Deployment runs:

2 replicas

with readiness and liveness probes.

🛡️ Production-Oriented Characteristics

This project demonstrates several patterns used in real DevOps environments:

Infrastructure-backed EKS deployment
Helm-based application packaging
Immutable container tagging
CI/CD automation
OIDC-based AWS authentication
Secret scanning
Container vulnerability scanning
Kubernetes security context
Health and readiness probes
Resource requests/limits
Automated rollout validation
Automated smoke testing
Source-to-production traceability
📊 Validation

Local validation:

python -m pytest -q

Expected:

5 passed

Helm validation:

helm lint chart/project-36-app


helm template project-36 \
  chart/project-36-app \
  --namespace project-36

Expected:

1 chart(s) linted, 0 chart(s) failed

EKS validation:

kubectl get nodes
kubectl get pods -n kube-system
🚀 Deployment

The deployment is intentionally performed through GitHub Actions.

git add .
git commit -m "feat(project-36): application change"
git push origin project-36-helm-application-packaging

GitHub Actions then performs the complete delivery pipeline.

Monitor:

gh run list \
  --workflow=project-36-helm-cicd.yml \
  --branch=project-36-helm-application-packaging
🔍 What This Project Demonstrates

This project goes beyond simply deploying a container.

It demonstrates:

CODE
 ↓
SECURITY
 ↓
TEST
 ↓
PACKAGE
 ↓
BUILD
 ↓
SCAN
 ↓
REGISTRY
 ↓
AUTHENTICATE
 ↓
DEPLOY
 ↓
VERIFY

The objective is to make the deployment repeatable, traceable and automated.

🧠 Key DevOps Learnings
Helm

Helm provides a reusable application packaging and deployment abstraction over Kubernetes.

CI/CD

Every code change can automatically progress from source validation to production-style Kubernetes deployment.

Immutable Artifacts

Git SHA image tags create a direct relationship between:

Git Commit
    ↓
Docker Image
    ↓
ECR Artifact
    ↓
Helm Release
    ↓
Kubernetes Pod
DevSecOps

Security is introduced before deployment rather than after deployment.

Gitleaks
   +
Trivy
   +
Kubernetes SecurityContext
   +
OIDC
🏆 Project Outcome

Project 36 establishes a reusable foundation for deploying containerized applications to EKS using Helm and automated CI/CD.

The resulting workflow provides:

Secure source → tested application → validated Helm chart → scanned container → immutable ECR artifact → automated EKS deployment → verified workload

🔗 Project Repository

CI/CD Mastery

https://github.com/Ashish420-tech/CI-CD-mastery

👨‍💻 Author

Ashish Mondal

DevOps & Cloud Engineer

AWS • Kubernetes • Terraform • Docker • Helm • CI/CD • Linux • Cloud Security
