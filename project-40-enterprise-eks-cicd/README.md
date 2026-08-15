# 🚀 Project 40 — Enterprise EKS CI/CD Platform

> Reusable enterprise-style CI/CD foundation for the existing Amazon EKS platform using GitHub Actions, GitHub OIDC, Terraform, Trivy, ECR, Helm and Kubernetes.

![AWS](https://img.shields.io/badge/AWS-EKS-orange?logo=amazonaws)
![Kubernetes](https://img.shields.io/badge/Kubernetes-EKS-blue?logo=kubernetes)
![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-CI%2FCD-black?logo=githubactions)
![Terraform](https://img.shields.io/badge/Terraform-IaC-purple?logo=terraform)
![Docker](https://img.shields.io/badge/Docker-Container-blue?logo=docker)
![Trivy](https://img.shields.io/badge/Trivy-DevSecOps-red)
![Helm](https://img.shields.io/badge/Helm-Kubernetes-0F1689?logo=helm)

## Overview

Project 40 converts the delivery patterns built in Projects 36–39 into a reusable CI/CD foundation.

Instead of duplicating GitHub Actions logic in every future project, common pipeline capabilities are centralized into reusable workflows.

## Architecture

```text
Developer
   ↓
Git Push / Pull Request
   ↓
Reusable Security
   ├── Gitleaks
   └── Security Gate
   ↓
Reusable Validation
   ├── Tests
   ├── Helm Lint
   ├── Helm Template
   └── Terraform Validate / Plan
   ↓
Reusable Build
   ├── Docker Build
   ├── Trivy Scan
   ├── Git SHA Tag
   └── ECR Push
   ↓
Reusable Deployment
   ├── GitHub OIDC
   ├── EKS Kubeconfig
   ├── Helm Upgrade
   └── Rollout Verification
   ↓
Smoke Tests
   ↓
Traceability
   ├── Git SHA
   ├── ECR Digest
   └── Deployed Image

Reusable CI/CD Components
.github/workflows/reusable/


security.yml
terraform.yml
build-push.yml
eks-deploy.yml

These workflows are invoked using GitHub Actions workflow_call.

Future projects can therefore consume the same platform capabilities without rebuilding the delivery pipeline.

Existing AWS Platform

No new AWS platform infrastructure is created.

Component	Existing Value
Region	ap-south-1
EKS Cluster	ci-cd-mastery-eks
ECR	ci-cd-mastery/applications
Authentication	GitHub OIDC
Deployment	Helm
Workload	Project 38
Image Identity	Git commit SHA
Security

Project 40 uses:

Gitleaks
Trivy
GitHub OIDC
immutable ECR image tags
Terraform validation
Helm validation
rollout verification
Kubernetes smoke testing

No long-lived AWS credentials are introduced.

Git SHA Traceability
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
    ↓
Running Workload

The deployed container can therefore be traced back to the exact source commit that produced it.

Cost Control

Project 40 intentionally reuses:

existing EKS
existing ECR
existing VPC
existing OIDC
existing platform Terraform

No new EKS cluster, VPC, NAT Gateway, node group or duplicate Terraform root is created.

Validation

The platform proves:

reusable CI/CD workflows
GitHub OIDC authentication
security gates
Terraform validation
application testing
Docker image builds
Trivy security scanning
ECR publishing
Helm deployment
EKS rollout verification
Kubernetes smoke tests
Git SHA traceability
Project Chain
Project 36
Helm Application Packaging
        ↓
Project 37
Immutable ECR Platform
        ↓
Project 38
EKS Application Platform
        ↓
Project 39
EKS Pod Identity
        ↓
Project 40
Enterprise EKS CI/CD Platform
        ↓
Projects 41–50
DevSecOps Security Platform
        ↓
Projects 51–60
Progressive Delivery + GitOps
        ↓
Projects 61–70
Observability Platform
        ↓
Projects 71–77
Production Platform Engineering
Final Status

Project 40 establishes a reusable enterprise CI/CD foundation for the remaining EKS Platform Engineering + DevSecOps roadmap.

Status: IN PROGRESS
EOF



### 4. Validate before pushing


```bash
git status
git branch --show-current


echo "===== YAML FILES ====="
find .github/workflows -type f | sort


echo "===== TERRAFORM ====="
cd infrastructure/eks
terraform fmt -check -recursive
terraform init -input=false
terraform validate
cd ../..


echo "===== HELM ====="
helm lint project-38-eks-application-platform/chart/project-38-app
helm template project-38 \
  project-38-eks-application-platform/chart/project-38-app \
  --namespace project-38 >/tmp/project40-rendered.yaml


echo "===== GIT STATUS ====="
git status --short
