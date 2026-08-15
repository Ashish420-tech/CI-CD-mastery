# Project 38 — EKS Application Platform

Enterprise CI/CD deployment platform for running containerized applications
on the existing Amazon EKS platform.

## Objective

Project 38 extends Projects 36 and 37:

```text
Project 36
Helm Application Packaging
        ↓
Project 37
Immutable ECR Platform
        ↓
Project 38
EKS Application Platform
# 🚀 Project 38 — EKS Application Platform

> Production-oriented Kubernetes application delivery using GitHub Actions,
> Amazon ECR, Helm, GitHub OIDC and Amazon EKS.

![AWS](https://img.shields.io/badge/AWS-EKS-orange?logo=amazonaws)
![Kubernetes](https://img.shields.io/badge/Kubernetes-1.34-blue?logo=kubernetes)
![Helm](https://img.shields.io/badge/Helm-3.x-0F1689?logo=helm)
![Docker](https://img.shields.io/badge/Docker-Container-blue?logo=docker)
![GitHub Actions](https://img.shields.io/badge/CI%2FCD-GitHub%20Actions-black?logo=githubactions)
![Terraform](https://img.shields.io/badge/IaC-Terraform-purple?logo=terraform)
![DevSecOps](https://img.shields.io/badge/DevSecOps-Security-red)

---

## 📌 Overview

Project 38 establishes the **EKS Application Platform** layer of the
CI/CD Mastery Platform Engineering + DevSecOps architecture.

The project connects the previously established application packaging and
immutable container artifact platforms with a real Kubernetes deployment
pipeline.

The complete delivery chain is:

```text
Git Push
   ↓
GitHub Actions
   ↓
Gitleaks
   ↓
Application Tests
   ↓
Helm Validation
   ↓
Docker Build
   ↓
Trivy Security Scan
   ↓
GitHub OIDC
   ↓
Amazon ECR
   ↓
Immutable Git SHA Image
   ↓
Amazon EKS
   ↓
Helm Deployment
   ↓
Kubernetes Rollout
   ↓
Application Smoke Tests


🎯 Project Objectives

The objective is to create a reusable CI/CD application deployment platform
for the existing EKS environment.

Key objectives
Deploy applications to Amazon EKS through CI/CD
Reuse the existing EKS cluster
Reuse the existing ECR platform
Reuse GitHub OIDC authentication
Deploy using Helm
Use immutable Git SHA image tags
Add security gates before deployment
Verify Kubernetes rollout automatically
Verify application health automatically
Verify application version automatically
Avoid manual Kubernetes deployment steps
🏗️ Architecture
                         Developer
                             │
                             ▼
                       Git Repository
                             │
                             ▼
                    ┌─────────────────┐
                    │ GitHub Actions  │
                    └────────┬────────┘
                             │
              ┌──────────────┼──────────────┐
              │              │              │
              ▼              ▼              ▼
          Gitleaks         Pytest         Helm
              │              │          lint/template
              └──────────────┼──────────────┘
                             │
                             ▼
                       Docker Build
                             │
                             ▼
                          Trivy
                             │
                             ▼
                     GitHub OIDC → AWS
                             │
                             ▼
                           ECR
                             │
                             ▼
                    Git SHA Image Tag
                             │
                             ▼
                       SHA256 Digest
                             │
                             ▼
                         Helm CLI
                             │
                             ▼
                    Amazon EKS Cluster
                             │
                   ┌─────────┴─────────┐
                   ▼                   ▼
              Deployment             Service
              2 Replicas            ClusterIP
                   │
                   ▼
             Health Probes
                   │
                   ▼
             Smoke Verification
☁️ Existing AWS Platform

Project 38 intentionally does not create a new EKS cluster.

The existing platform is reused.

Component	Value
AWS Region	ap-south-1
EKS Cluster	ci-cd-mastery-eks
Kubernetes	v1.34.9-eks-254016e
EKS Status	ACTIVE
EKS Nodes	3
ECR Repository	ci-cd-mastery/applications
ECR Mutability	IMMUTABLE
ECR Scan on Push	Enabled
ECR Encryption	AES256
Namespace	project-38
Helm Release	project-38
Helm Chart	project-38-app
🔐 Security Architecture

Project 38 inherits the security foundation established in Projects 36
and 37.

GitHub OIDC

GitHub Actions authenticates with AWS using OpenID Connect.

GitHub Actions
      │
      ▼
OIDC Token
      │
      ▼
AWS STS
      │
      ▼
GitHubActionsEnterpriseCapstoneRole
      │
      ▼
AWS / EKS / ECR

No long-lived AWS access keys are required.

The workflow uses:

permissions:
  contents: read
  id-token: write

AWS authentication is performed using:

aws-actions/configure-aws-credentials
🛡️ DevSecOps Pipeline

Project 38 introduces multiple security gates before deployment.

1. Gitleaks

The repository is scanned for accidentally committed secrets.

Git Repository
      ↓
Gitleaks
      ↓
PASS / FAIL
2. Application Testing

The application test suite is executed before container deployment.

Result:

5 passed
3. Helm Validation

The Helm chart is validated using:

helm lint
helm template

This prevents invalid Kubernetes manifests from reaching the cluster.

4. Trivy

The container image is scanned for:

HIGH
CRITICAL

vulnerabilities.

The deployment cannot proceed when the configured security gate fails.

📦 Immutable Artifact Flow

Project 38 consumes the immutable ECR foundation established in Project 37.

The image is tagged using the Git commit SHA:

<registry>/ci-cd-mastery/applications:<GITHUB_SHA>

This creates deterministic traceability:

Git Commit
    ↓
GITHUB_SHA
    ↓
Docker Image
    ↓
ECR
    ↓
SHA256 Digest
    ↓
Helm
    ↓
EKS

The deployed artifact can therefore be traced back to the exact source
commit that produced it.

☸️ Kubernetes Platform
Namespace
project-38

The namespace isolates the application from other projects running on the
shared EKS platform.

Helm Release
Release:
project-38


Chart:
project-38-app


Version:
0.1.0

Deployment is performed through:

helm upgrade --install

The CI/CD pipeline waits for the Kubernetes rollout to complete.

🚀 Application Deployment

The application runs as a Kubernetes Deployment with:

Replicas: 2

Current verified deployment:

deployment.apps/project-38


READY:
2/2


UP-TO-DATE:
2


AVAILABLE:
2

Running pods:

project-38-6dbb4df8cc-lfd59
project-38-6dbb4df8cc-rk22j

Both pods were verified:

READY     1/1
STATUS    Running
RESTARTS  0
🔄 Kubernetes Service

The application is exposed internally through a Kubernetes ClusterIP
service.

Service:
project-38


Type:
ClusterIP


Port:
80


Target:
5000

This provides internal service discovery without exposing the application
directly to the public internet.

❤️ Health and Reliability

The deployment includes Kubernetes health probes.

Readiness Probe
/ready

Used by Kubernetes to determine whether the pod is ready to receive
traffic.

Liveness Probe
/health

Used by Kubernetes to determine whether the application is healthy.

The CI/CD pipeline additionally performs application smoke testing against
the Kubernetes service.

⚙️ Container Security

The Kubernetes Deployment uses hardened container settings.

Service Account Token
automountServiceAccountToken: false
Non-root execution
runAsNonRoot: true
runAsUser: 10001
Privilege escalation
allowPrivilegeEscalation: false
Linux capabilities
capabilities:
  drop:
    - ALL
Seccomp
seccompProfile:
  type: RuntimeDefault

These controls reduce the container's runtime privilege.

📊 Resource Management

The application defines Kubernetes resource requests and limits.

requests:
  cpu: 100m
  memory: 128Mi


limits:
  cpu: 500m
  memory: 256Mi

This provides predictable scheduling and prevents uncontrolled resource
consumption.

🔄 Complete CI/CD Pipeline

The Project 38 GitHub Actions workflow is:

                         Git Push
                            │
                            ▼
                    GitHub Actions
                            │
                            ▼
                    Gitleaks Scan
                            │
                            ▼
                    Application Tests
                            │
                            ▼
                     Helm Lint
                            │
                            ▼
                   Helm Template
                            │
                            ▼
                     Docker Build
                            │
                            ▼
                    Trivy Scan
                            │
                            ▼
                 GitHub OIDC → AWS
                            │
                            ▼
                       ECR Login
                            │
                            ▼
                  Push Git SHA Image
                            │
                            ▼
                  Resolve SHA256 Digest
                            │
                            ▼
                Configure EKS Kubeconfig
                            │
                            ▼
                     Helm Deploy
                            │
                            ▼
                  Rollout Verification
                            │
                            ▼
                  Kubernetes Verification
                            │
                            ▼
                    /health Test
                            │
                            ▼
                   /version Test
                            │
                            ▼
                          PASS
🧪 CI/CD Verification

The successful GitHub Actions run:

Run ID:
31884763159


Workflow:
Project 38 - EKS Application Platform CI/CD


Status:
SUCCESS

The workflow successfully validated:

Gitleaks                 ✅
Application Tests        ✅
Helm Validation          ✅
Docker Build             ✅
Trivy Scan               ✅
GitHub OIDC              ✅
ECR Authentication       ✅
ECR Image Push           ✅
EKS Authentication       ✅
Helm Deployment          ✅
Kubernetes Rollout       ✅
Application Verification ✅
🔍 Local Verification
Kubernetes
kubectl get all -n project-38

Verified state:

Deployment:
2/2 Ready


Pods:
2/2 Running


Service:
project-38
ClusterIP
Port 80
Helm
helm list -n project-38

Verified:

NAME        NAMESPACE   REVISION   STATUS
project-38  project-38  1          deployed
Pod Verification
kubectl get pods -n project-38 -o wide

Verified:

2 Pods
2/2 Ready
0 Restarts
Running
🔗 Project 36 → Project 37 → Project 38

The three projects now form one continuous platform.

Project 36
Helm Application Packaging

Application packaging and Helm foundation.

↓

Project 37
ECR + Immutable Image Platform

Secure and immutable container artifact platform.

↓

Project 38
EKS Application Platform

Automated deployment of the immutable artifact into Kubernetes.

Complete flow:

Application Source
       │
       ▼
      Helm
       │
       ▼
   Docker Image
       │
       ▼
Immutable ECR
       │
       ▼
GitHub Actions
       │
       ▼
      Helm
       │
       ▼
      EKS
       │
       ▼
 Running Application
🏢 Platform Engineering Principles

Project 38 follows several enterprise platform engineering principles.

Reuse

Existing EKS, ECR, OIDC and CI/CD infrastructure is reused.

Automation

Application deployment is performed through GitHub Actions.

Security by Default

Security scanning and hardened container settings are included in the
platform.

Immutable Artifacts

Deployment uses Git SHA image tags.

Declarative Deployment

Kubernetes resources are packaged and deployed through Helm.

Verification

The pipeline verifies the deployment instead of assuming success.

Cost Control

No additional EKS cluster, VPC, NAT Gateway or node group is created.

💰 Cost Optimization

The project intentionally reuses the existing AWS platform.

No new:

EKS cluster
VPC
NAT Gateway
ECR repository
Node group

is created for Project 38.

This allows the project to demonstrate enterprise deployment architecture
while keeping AWS resource consumption controlled.

📁 Project Structure
project-38-eks-application-platform/
│
├── app/
│   ├── app.py
│   ├── Dockerfile
│   ├── requirements.txt
│   └── .dockerignore
│
├── tests/
│   └── ...
│
└── chart/
    └── project-38-app/
        ├── Chart.yaml
        ├── values.yaml
        └── templates/
            ├── _helpers.tpl
            ├── configmap.yaml
            ├── deployment.yaml
            └── service.yaml

CI/CD:

.github/workflows/
└── project-38-eks-platform-cicd.yml
📈 Platform Roadmap
Project 36
Helm Application Packaging
        │
        ▼
Project 37
Immutable ECR Platform
        │
        ▼
Project 38
EKS Application Platform
        │
        ▼
Project 39
IRSA / EKS Pod Identity
        │
        ▼
Project 40
Enterprise EKS CI/CD
        │
        ▼
Projects 41–50
DevSecOps Security Platform
        │
        ▼
Projects 51–60
Advanced Delivery + GitOps
        │
        ▼
Projects 61–70
Observability + Reliability
        │
        ▼
Projects 71–77
Production Platform Engineering
🏆 Key Engineering Outcomes

Project 38 demonstrates:

Enterprise Kubernetes application deployment
GitHub Actions CI/CD
GitHub OIDC authentication
Amazon ECR integration
Immutable container artifacts
Helm-based Kubernetes deployment
Kubernetes health probes
Container security hardening
Resource management
Automated rollout verification
Automated application smoke testing
Shared EKS platform architecture
Cost-aware AWS infrastructure reuse
✅ Final Status
PROJECT 38 — EKS APPLICATION PLATFORM

COMPLETE ✅

Verified:

GitHub Actions             ✅
DevSecOps Security Gates   ✅
Immutable ECR Artifact     ✅
GitHub OIDC                ✅
Helm Deployment            ✅
Amazon EKS                 ✅
2/2 Pods Ready             ✅
ClusterIP Service          ✅
Health Checks              ✅
Rollout Verification       ✅
Application Verification   ✅
Production Delivery Chain
SOURCE
  ↓
SECURITY
  ↓
TEST
  ↓
BUILD
  ↓
TRIVY
  ↓
ECR
  ↓
OIDC
  ↓
HELM
  ↓
EKS
  ↓
ROLLOUT
  ↓
HEALTH
  ↓
VERSION
  ↓
PRODUCTION-READY PLATFORM PATTERN
👨‍💻 Author

Ashish Mondal

DevOps & Cloud Engineer

Core Technologies

AWS · EKS · ECR · Kubernetes · Helm · Docker ·
Terraform · GitHub Actions · GitHub OIDC · Trivy · Gitleaks
