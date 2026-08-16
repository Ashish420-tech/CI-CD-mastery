# Project 46 — SBOM & Supply-Chain Attestation

## Overview

Project 46 adds Software Bill of Materials (SBOM) generation and supply-chain attestation to the existing CI/CD security architecture.

The project generates an SPDX JSON SBOM for the exact immutable container image digest produced by the existing reusable build workflow.

The SBOM is then attached to that image using Cosign keyless attestation.

The workflow finally verifies the attestation using the GitHub Actions OIDC identity.

## Objective

Establish an auditable software supply-chain evidence chain:

```text
Source Code
    ↓
Existing Reusable Build
    ↓
Trivy Image Scan
    ↓
Amazon ECR
    ↓
Immutable SHA256 Digest
    ↓
Syft SBOM Generation
    ↓
SPDX JSON
    ↓
Cosign Keyless Attestation
    ↓
ECR OCI Attestation
    ↓
Cosign Verification


Industry Problem

Container image signing establishes artifact integrity and signer identity.

However, signing alone does not answer:

What software components are inside this exact image?

An SBOM provides a machine-readable inventory of software packages contained in the image.

Attaching that SBOM to the immutable digest provides:

Supply-chain transparency
Vulnerability investigation support
Auditability
Reproducible artifact evidence
Developer-friendly dependency visibility
Machine-readable security metadata
Architecture
GitHub Actions
      │
      ├── Existing Reusable Build
      │       │
      │       ├── Docker Build
      │       ├── Trivy Scan
      │       └── ECR Push
      │
      └── Project 46
              │
              ├── AWS OIDC
              │
              ├── ECR Login
              │
              ├── Pull Immutable Digest
              │
              ├── Syft
              │     ↓
              │   SPDX SBOM
              │
              ├── Cosign Attestation
              │     ↓
              │   ECR OCI Artifact
              │
              └── Cosign Verification
Security Design
Immutable Image Reference

The workflow never relies on a mutable tag.

The SBOM is generated for:

IMAGE@sha256:<digest>

This ensures the SBOM corresponds to the exact artifact.

Keyless Attestation

Cosign uses GitHub Actions OIDC.

No long-lived private attestation key is stored in:

GitHub Secrets
Repository files
Docker images
AWS Secrets Manager
SPDX Format

The SBOM is generated in SPDX JSON format.

This provides a standardized machine-readable representation suitable for downstream security and compliance tooling.

CI Security Gate

The workflow fails if:

The image cannot be pulled
SBOM generation fails
The SBOM is empty
Attestation fails
Attestation verification fails
The attestation identity does not match the expected GitHub Actions workflow
Existing Infrastructure Reuse

Project 46 reuses:

Existing Amazon ECR repository
Existing GitHub Actions OIDC
Existing AWS IAM role
Existing reusable image build workflow
Existing application Dockerfile
Existing Trivy image scanning

No new AWS infrastructure is required.

Project 45 Relationship

Project 45 established:

Immutable Image
      ↓
Cosign Signature
      ↓
Signature Verification

Project 46 extends the trust model:

Immutable Image
      │
      ├── Cosign Signature
      │
      └── SPDX SBOM Attestation

The image therefore has both:

Cryptographic signing evidence
Software composition evidence
Files
project-46-sbom-supply-chain/
├── README.md
└── verify-sbom-attestation.sh


.github/workflows/
└── project-46-sbom-supply-chain.yml
Tools
GitHub Actions
GitHub OIDC
AWS IAM
Amazon ECR
Docker
Trivy
Syft
Cosign
SPDX
Infrastructure Safety

Project 46 does not create or recreate:

EKS
VPC
ECR repositories
Terraform infrastructure
EBS CSI
VPC CNI
CoreDNS
kube-proxy
EKS Pod Identity

The existing platform remains untouched.

Validation

The final CI pipeline must demonstrate:

✓ Existing image build reused
✓ Trivy image scan preserved
✓ Immutable SHA256 digest captured
✓ SPDX SBOM generated
✓ SBOM attached to image digest
✓ Cosign attestation created
✓ OIDC identity verified
✓ Attestation verification passed
✓ GitHub Actions security gate passed
Status

Project 46 — CI validation in progress.

README will be finalized after successful SBOM attestation and verification.
