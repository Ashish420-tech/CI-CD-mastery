# Project 45 — Cosign Container Image Signing

## Overview

Project 45 adds cryptographic container image signing and verification to the existing CI/CD platform using Sigstore Cosign.

The project signs the immutable SHA256 digest of the application image pushed to the existing Amazon ECR repository.

GitHub Actions OIDC is used for keyless Cosign signing, eliminating the need to store long-lived signing keys in GitHub Secrets.

---

## Objective

Establish a verifiable container supply-chain trust chain:

```text
Source Code
    ↓
Build
    ↓
Trivy Image Scan
    ↓
Amazon ECR
    ↓
Immutable SHA256 Digest
    ↓
Cosign Keyless Signing
    ↓
Signature
    ↓
Cosign Verification


Architecture
GitHub Actions
      │
      ├── GitHub OIDC
      │       ↓
      │   AWS IAM Role
      │       ↓
      │     ECR
      │
      └── Reusable Build Workflow
              │
              ├── Docker Build
              ├── Trivy HIGH/CRITICAL Scan
              └── Push Image
                      │
                      ↓
                Image Digest
                      │
                      ↓
              Cosign Sign
                      │
                      ↓
              ECR Signature
                      │
                      ↓
             Cosign Verification
Key Security Design
Immutable digest signing

The project does not sign a mutable tag such as:

latest

Instead, it signs the immutable image reference:

IMAGE@sha256:<digest>

This prevents a tag from being moved to another image after signing.

Keyless Signing

Cosign uses GitHub Actions OIDC for keyless signing.

No private signing key is stored in:

GitHub Secrets
Repository files
Docker images
AWS Secrets Manager

The signing workflow receives an ephemeral signing identity and certificate from Sigstore.

Existing ECR Integration

The project reuses the existing ECR repository:

ci-cd-mastery/applications

No new ECR repository is created.

The existing reusable build workflow is also reused:

.github/workflows/reusable-build-push.yml

It already provides:

Docker image build
Trivy image scanning
ECR authentication
Image push
Immutable image digest output

Project 45 consumes that digest for signing.

Workflow
Build and Push Image
        │
        ▼
Cosign Keyless Image Signing
        │
        ▼
Verify Signed Image
Build

The existing application image is built using the Project 38 application Dockerfile and context.

Sign

Cosign signs the exact SHA256 image digest.

Verify

Cosign verifies the signature against the same immutable digest.

The verification step also validates the GitHub Actions OIDC identity and issuer.

Security Controls

The project provides:

Immutable digest signing
Keyless signing
GitHub OIDC identity
ECR authentication
Signature verification
CI failure on verification failure
No long-lived signing keys
No mutable-tag trust model
Files
project-45-cosign-image-signing/
├── README.md
└── scripts/
    └── verify-cosign.sh


.github/workflows/
└── project-45-cosign-image-signing.yml
Verification

The verification script accepts an immutable image reference:

./project-45-cosign-image-signing/scripts/verify-cosign.sh \
  <image>@sha256:<digest>

Cosign verifies the signature using the expected GitHub Actions identity and Sigstore OIDC issuer.

Infrastructure Safety

Project 45 does not create or recreate:

EKS
VPC
ECR repositories
Terraform infrastructure
EBS CSI
VPC CNI
CoreDNS
kube-proxy
EKS Pod Identity

The existing ECR repository and GitHub OIDC architecture are reused.

Project 45 Result
✓ Existing reusable build workflow reused
✓ Existing ECR reused
✓ Trivy image scanning preserved
✓ Immutable SHA256 digest captured
✓ Cosign keyless signing implemented
✓ GitHub OIDC signing identity
✓ ECR authentication
✓ Signature verification implemented
✓ GitHub Actions security gate
✓ GitHub Actions GREEN
✓ No new AWS infrastructure
Project Status

Project 45 — COMPLETE
