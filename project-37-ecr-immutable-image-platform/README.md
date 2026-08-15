# Project 37 — ECR + Immutable Image Platform

> Production-grade container artifact management using Amazon ECR,
> immutable Git-SHA tags, image scanning, encryption and lifecycle governance.

## Objective

Establish the shared container image platform for the CI/CD Mastery
EKS Platform Engineering + DevSecOps roadmap.

Project 37 reuses the existing ECR repository created for the platform.

```text
ci-cd-mastery/applications
# 🚀 Project 37 — ECR + Immutable Image Platform

> Enterprise-grade container artifact management with Amazon ECR, immutable
> Git-SHA image tagging, security scanning, lifecycle governance and
> GitHub OIDC-based CI/CD.

![AWS](https://img.shields.io/badge/AWS-ECR-orange?logo=amazonaws)
![Terraform](https://img.shields.io/badge/IaC-Terraform-purple?logo=terraform)
![Docker](https://img.shields.io/badge/Container-Docker-blue?logo=docker)
![GitHub Actions](https://img.shields.io/badge/CI%2FCD-GitHub%20Actions-black?logo=githubactions)
![Security](https://img.shields.io/badge/Security-DevSecOps-red)
![ECR](https://img.shields.io/badge/ECR-IMMUTABLE-green)

---

## 📌 Overview

Project 37 establishes the **enterprise container image platform** for the
CI/CD Mastery EKS Platform Engineering + DevSecOps architecture.

Instead of creating a new registry for every project, the platform reuses
the existing shared Amazon ECR repository and applies production-oriented
artifact governance.

The platform provides:

- Immutable image tags
- Git commit SHA traceability
- SHA256 image digest verification
- ECR scan-on-push
- AES256 encryption
- Lifecycle retention
- GitHub OIDC authentication
- Automated security gates
- Automated Docker build and push
- Automated ECR verification

---

# 🏗️ Architecture

```text
                         Developer
                             │
                             ▼
                         Git Commit
                             │
                             ▼
                     ┌─────────────────┐
                     │    GitHub       │
                     │   Repository    │
                     └────────┬────────┘
                              │
                              ▼
                     ┌─────────────────┐
                     │ GitHub Actions  │
                     └────────┬────────┘
                              │
               ┌──────────────┼──────────────┐
               │              │              │
               ▼              ▼              ▼
           Gitleaks        Pytest          Trivy
               │              │              │
               └──────────────┼──────────────┘
                              │
                              ▼
                       Docker Build
                              │
                              ▼
                  GitHub OIDC Authentication
                              │
                              ▼
                     Amazon ECR Login
                              │
                              ▼
                ┌─────────────────────────┐
                │ Amazon ECR              │
                │                         │
                │ IMMUTABLE TAGS          │
                │ SCAN ON PUSH            │
                │ AES256 ENCRYPTION       │
                │ LIFECYCLE GOVERNANCE    │
                └────────────┬────────────┘
                             │
                             ▼
                       SHA256 DIGEST
                             │
                             ▼
                       Verified Artifact
                             │
                             ▼
                           Helm
                             │
                             ▼
                        Amazon EKS

🎯 Project Objectives

The goal of Project 37 is to establish a reusable and secure container
artifact platform that can support Projects 38–77.

Primary objectives
Reuse the existing shared ECR repository.
Prevent image tag overwrites.
Associate images with Git commits.
Automatically scan container images.
Encrypt ECR artifacts.
Control image retention and storage growth.
Authenticate GitHub Actions using OIDC.
Verify the published artifact automatically.
Establish the foundation for secure EKS deployments.
☁️ AWS Architecture
ECR Repository
Repository:
ci-cd-mastery/applications


Region:
ap-south-1


Registry:
742820980479.dkr.ecr.ap-south-1.amazonaws.com
ECR configuration
Capability	Configuration
Repository	ci-cd-mastery/applications
Region	ap-south-1
Tag Mutability	IMMUTABLE
Scan on Push	Enabled
Encryption	AES256
Lifecycle Retention	Newest 20 images
Authentication	GitHub OIDC
Artifact Identity	Git SHA + SHA256 Digest
🔐 Immutable Image Strategy

Traditional mutable tags create a deployment risk:

latest
production
stable

The same tag can potentially point to a different image later.

Project 37 uses the Git commit SHA as the image tag:

<repository>:<GIT_SHA>

Example:

742820980479.dkr.ecr.ap-south-1.amazonaws.com/ci-cd-mastery/applications:<GIT_SHA>

The image is then identified by its immutable content digest:

sha256:<IMAGE_DIGEST>

This creates deterministic artifact traceability:

Git Commit
     │
     ▼
Git SHA
     │
     ▼
Docker Image
     │
     ▼
ECR Git-SHA Tag
     │
     ▼
SHA256 Digest
     │
     ▼
Helm
     │
     ▼
EKS
🛡️ Security Controls
1. Immutable Tags

ECR is configured with:

IMMUTABLE

An existing image tag cannot simply be overwritten with another image.

2. Scan on Push

ECR image scanning is enabled when artifacts are pushed.

This provides an additional security gate at the container registry layer.

3. AES256 Encryption

ECR artifacts are encrypted using:

AES256
4. GitHub OIDC

GitHub Actions does not use long-lived AWS access keys.

The workflow authenticates using:

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

This eliminates the need to store:

AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY

as long-lived credentials.

🔄 CI/CD Pipeline

Project 37 implements the following CI/CD flow:

Git Push
   │
   ▼
Gitleaks
   │
   ▼
Application Tests
   │
   ▼
Docker Build
   │
   ▼
Trivy HIGH/CRITICAL Scan
   │
   ▼
GitHub OIDC
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
Verify Immutable Repository
   │
   ▼
Verify Scan-on-Push
   │
   ▼
Verify Lifecycle Policy
   │
   ▼
🧪 Security Gates

The pipeline contains multiple security gates before artifact publication.

Gitleaks

Detects accidentally committed secrets.

Source
  ↓
Gitleaks
  ↓
PASS / FAIL
Trivy

Scans the Docker image for HIGH and CRITICAL vulnerabilities.

Docker Build
     ↓
Trivy
     ↓
HIGH / CRITICAL
     ↓
Pipeline Gate
Application Tests

The existing Project 36 application test suite is reused rather than
duplicated.

📦 Artifact Traceability

Every published image can be traced back to its source commit.

GitHub Commit
      │
      ├── Commit SHA
      │
      ▼
GitHub Actions
      │
      ▼
Docker Build
      │
      ▼
ECR
      │
      ├── Git SHA Tag
      │
      └── SHA256 Digest

This provides an auditable chain from:

Source → Build → Artifact → Deployment
♻️ ECR Lifecycle Governance

The repository retains the newest 20 images.

Newest
  │
  ├── Image 01
  ├── Image 02
  ├── Image 03
  ├── ...
  └── Image 20
        │
        ▼
Older Images
        │
        ▼
Automatically Expired
Benefits
Controls ECR storage growth
Reduces unnecessary AWS cost
Preserves recent rollback candidates
Provides predictable artifact retention
🧱 Terraform

Project 37 reuses the existing ECR infrastructure.

The existing repository configuration provides:

image_tag_mutability = "IMMUTABLE"


image_scanning_configuration {
  scan_on_push = true
}


encryption_configuration {
  encryption_type = "AES256"
}

Lifecycle governance is managed through Terraform.

No new EKS cluster is created.

No new VPC is created.

No duplicate ECR repository is created.

🔍 Validation
Terraform Validation
cd infrastructure/eks


terraform fmt -check
terraform validate
terraform plan

Expected:

Success! The configuration is valid.
ECR Repository Verification
aws ecr describe-repositories \
  --repository-names ci-cd-mastery/applications \
  --region ap-south-1

Verify:

imageTagMutability = IMMUTABLE
scanOnPush = true
encryptionType = AES256


Lifecycle Verification
aws ecr get-lifecycle-policy \
  --repository-name ci-cd-mastery/applications \
  --region ap-south-1

Expected retention rule:

imageCountMoreThan = 20
Image Verification
aws ecr describe-images \
  --repository-name ci-cd-mastery/applications \
  --region ap-south-1

Verify:

Git SHA tag
SHA256 digest
Push timestamp
Image metadata
🚀 CI/CD Verification

GitHub Actions provides the final platform verification.

The successful Project 37 pipeline demonstrated:

Gitleaks                 ✅
Application Tests        ✅
Docker Build             ✅
Trivy Scan               ✅
GitHub OIDC              ✅
ECR Login                ✅
Git SHA Image Push       ✅
SHA256 Digest            ✅
Immutable Verification   ✅
Scan-on-Push Verification ✅
Lifecycle Verification   ✅
Artifact Verification    ✅
💰 Cost Optimization

The existing AWS platform is intentionally reused.

Project 37 does not create:

New EKS cluster
New VPC
New NAT Gateway
Duplicate ECR repository
Duplicate node groups

ECR lifecycle retention also limits unnecessary image storage.

This keeps the platform aligned with the project's AWS cost constraints.

🔗 Relationship With Project 36

Project 36 established:

Flask Application
     ↓
Docker
     ↓
Helm
     ↓
ECR
     ↓
EKS

Project 37 strengthens the artifact layer:

Application
     ↓
CI Security
     ↓
Docker
     ↓
IMMUTABLE ECR
     ↓
SHA256 Digest
     ↓
Helm
     ↓
EKS

Project 37 therefore extends Project 36 instead of replacing it.

🏢 Platform Engineering Pattern

The important design principle is reuse over duplication.

Projects 37–77 build on shared platform capabilities:

                 Shared EKS Platform
                        │
        ┌───────────────┼───────────────┐
        │               │               │
       ECR             OIDC          Terraform
        │               │               │
        └───────────────┼───────────────┘
                        │
                 GitHub Actions
                        │
                        ▼
                Secure Artifacts
                        │
                        ▼
                       EKS

Future projects will extend this platform with:

IRSA / Pod Identity
RBAC
NetworkPolicy
Pod Security
Kyverno
SBOM
Cosign
Image verification
Argo CD
Progressive delivery
Prometheus
Grafana
OpenTelemetry
Autoscaling
Reliability engineering
📈 Project Outcome

Project 37 establishes a reusable enterprise container artifact platform.

The final supply-chain model is:

              SOURCE
                 │
                 ▼
          GitHub Repository
                 │
                 ▼
        DevSecOps Pipeline
                 │
        ┌────────┼────────┐
        │        │        │
     Gitleaks  Tests    Trivy
        │        │        │
        └────────┼────────┘
                 │
                 ▼
           Docker Build
                 │
                 ▼
         GitHub OIDC → AWS
                 │
                 ▼
              ECR
                 │
        ┌────────┼────────┐
        │        │        │
    Immutable  Scan     AES256
      Tags     Push
        │
        ▼
    SHA256 Digest
        │
        ▼
       Helm
        │
        ▼
       EKS
🏆 Key Engineering Outcomes
Security
No long-lived AWS credentials
Secret scanning
Container vulnerability scanning
Immutable artifacts
Encrypted registry
Reliability
Deterministic image identity
SHA256 digest traceability
Controlled artifact retention
Operations
Automated CI/CD
Automated verification
Terraform-managed infrastructure
Reusable shared ECR platform
Cost
Existing EKS reused
Existing ECR reused
Lifecycle-based artifact cleanup
No duplicate infrastructure
📚 Roadmap Position
Project 36
Helm Application Packaging
        │
        ▼
Project 37
ECR + Immutable Image Platform
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
Enterprise EKS CI/CD Platform
        │
        ▼
Projects 41–77
DevSecOps + GitOps + Observability
+ Reliability + Platform Engineering
👨‍💻 Author

Ashish Mondal

DevOps & Cloud Engineer

Core Technologies

AWS • EKS • ECR • Terraform • Docker • Kubernetes
• Helm • GitHub Actions • DevSecOps
