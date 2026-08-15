# Project 40 — Enterprise EKS CI/CD Platform

## 🚀 Overview

Project 40 transforms the CI/CD patterns developed across Projects 36–39 into a reusable enterprise-style CI/CD platform for Amazon EKS.

The platform provides reusable GitHub Actions workflows for:

- Security scanning
- Application testing
- Terraform validation and planning
- Docker image builds
- Trivy security scanning
- Amazon ECR publishing
- Helm deployment
- EKS rollout verification
- Kubernetes smoke testing
- Git SHA traceability

The implementation reuses the existing EKS platform, ECR repository, Terraform configuration and GitHub OIDC authentication.

---

## 🏗️ Architecture

Git Push
    │
    ▼
Gitleaks
    │
    ▼
Application Tests
    │
    ▼
Terraform Validate + Plan
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
Helm
    │
    ▼
Amazon EKS
    │
    ▼
Rollout Verification
    │
    ▼
Smoke Tests
    │
    ▼
Git SHA Traceability

---

## 🧩 Reusable CI/CD Components

The platform provides reusable GitHub Actions workflows:

```text
.github/workflows/
├── reusable-security.yml
├── reusable-terraform.yml
├── reusable-build-push.yml
└── reusable-eks-deploy.yml

The Project 40 orchestrator consumes these reusable workflows.

🔐 Security

The pipeline implements:

GitHub OIDC authentication
No long-lived AWS access keys
Gitleaks secret scanning
Trivy container scanning
ECR immutable image tags
Git SHA image traceability
Security gates before deployment
Terraform validation before deployment

AWS access is performed using:

GitHub Actions
      ↓
OIDC
      ↓
AWS IAM Role
      ↓
AWS Services
☁️ AWS Platform

Existing platform components are reused:

Amazon EKS
Amazon ECR
VPC
EBS CSI
VPC CNI
CoreDNS
kube-proxy
EKS Pod Identity
GitHub OIDC

No duplicate EKS or ECR infrastructure is created.

🚢 Deployment

The deployment pipeline performs:

Helm lint
Helm template validation
Helm deployment
Kubernetes rollout verification
Pod verification
Application smoke testing
Image traceability verification
🔎 Traceability

Every container image is tagged using the Git commit SHA.

This provides:

Git Commit
    ↓
Docker Image
    ↓
ECR
    ↓
Helm
    ↓
EKS Deployment

The pipeline verifies that the deployed image corresponds to the expected Git SHA.

🧪 Validation

Successful GitHub Actions run:

31890769705

All pipeline stages passed:

Gitleaks
Application Tests
Terraform
Docker Build
Trivy
ECR
Helm
EKS
Rollout Verification
Smoke Tests
Traceability
🛠️ Technology Stack
AWS
Amazon EKS
Amazon ECR
Terraform
Kubernetes
Helm
Docker
GitHub Actions
GitHub OIDC
Trivy
Gitleaks
Python
Bash
🎯 Engineering Outcomes

Project 40 establishes the reusable CI/CD foundation for the remaining EKS DevSecOps platform roadmap.

Future projects will build on this foundation with:

Secret scanning enhancements
SBOM
Image signing
Image verification
Kubernetes security policies
Network security
GitOps
Progressive delivery
Observability
Autoscaling
Disaster recovery
Production platform engineering
💼 Recruiter Value

This project demonstrates practical experience building an enterprise-style Kubernetes delivery platform rather than a single application pipeline.

Key capabilities demonstrated:

Reusable CI/CD architecture
AWS OIDC federation
Infrastructure-as-Code validation
Container security
Immutable image delivery
Kubernetes deployment automation
Helm-based releases
Deployment verification
Supply-chain traceability
DevSecOps security gates
Production-oriented EKS workflows
