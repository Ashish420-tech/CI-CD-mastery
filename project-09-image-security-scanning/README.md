# Project 09 — Docker Image Security Scanning

## Overview

Project 09 introduces **container image vulnerability scanning** into the CI/CD pipeline using **Trivy**.

The objective is to ensure that a Docker image is not only buildable and testable, but also passes a defined security gate before it can progress through the delivery lifecycle.

---

## Enterprise Problem

A Docker build can succeed even when the resulting image contains:

* Vulnerable operating-system packages
* Vulnerable Python/application dependencies
* Known CVEs
* Security issues that could be inherited by production workloads

Therefore:

> **Build success does not mean security validation success.**

Project 09 adds security scanning between Docker image creation and further image promotion/deployment.

---

## Project Architecture

```text
                    PROJECT 09 CI/CD
                         |
                         v
                 ┌───────────────┐
                 │ GitHub Commit │
                 └───────┬───────┘
                         |
                         v
                 ┌───────────────┐
                 │    Checkout   │
                 └───────┬───────┘
                         |
                         v
                 ┌───────────────┐
                 │  Setup Python │
                 └───────┬───────┘
                         |
                         v
                 ┌───────────────┐
                 │  Install pytest│
                 └───────┬───────┘
                         |
                         v
                 ┌───────────────┐
                 │   Run Tests   │
                 │   3 passed    │
                 └───────┬───────┘
                         |
                         v
                 ┌───────────────┐
                 │ Docker Build  │
                 └───────┬───────┘
                         |
                         v
                 ┌───────────────┐
                 │ Trivy Scan    │
                 │ HIGH/CRITICAL │
                 └───────┬───────┘
                         |
              ┌──────────┴──────────┐
              │                     │
              v                     v
        Vulnerability          No Blocking
        Detected               Vulnerability
              |                     |
              v                     v
           CI FAIL               CI PASS
```

---

## Technologies

| Technology     | Purpose                          |
| -------------- | -------------------------------- |
| Docker         | Container image creation         |
| Trivy          | Container vulnerability scanning |
| GitHub Actions | CI/CD automation                 |
| Python         | Application runtime              |
| pytest         | Automated testing                |
| Git            | Version control                  |

---

# Directory Structure

```text
CI-CD-mastery/
│
├── .github/
│   └── workflows/
│       └── project-09-image-security.yml
│
└── project-09-image-security-scanning/
    ├── .dockerignore
    ├── Dockerfile
    ├── README.md
    ├── app.py
    └── test_app.py
```

---

# CI Workflow

The Project 09 workflow performs the following operations:

```text
Checkout
   ↓
Setup Python
   ↓
Install pytest
   ↓
Run pytest
   ↓
Build Docker image
   ↓
Trivy vulnerability scan
   ↓
Security gate
```

The workflow is triggered for:

* Pushes to `project-09-image-security-scanning`
* Pull requests affecting Project 09
* Changes to the Project 09 workflow

---

# Security Gate

The Trivy configuration checks:

```yaml
severity: HIGH,CRITICAL
exit-code: '1'
ignore-unfixed: true
```

### Meaning

### HIGH / CRITICAL

Only high-severity and critical-severity vulnerabilities are treated as release-blocking findings.

### exit-code: 1

If matching vulnerabilities are detected, Trivy exits with status `1`.

GitHub Actions therefore marks the job as failed.

### ignore-unfixed: true

Vulnerabilities for which no upstream fix is currently available are excluded from the blocking result.

This is a deliberate CI policy decision.

---

# Local Validation

## 1. Run tests

```bash
python -m pytest -q project-09-image-security-scanning
```

Actual validation:

```text
3 passed in 0.01s
```

---

## 2. Build Docker image

```bash
docker build \
  -t ci-cd-mastery-project-09:local \
  ./project-09-image-security-scanning
```

Validate:

```bash
docker image inspect ci-cd-mastery-project-09:local >/dev/null \
  && echo "Docker build validation: PASS"
```

Result:

```text
Docker build validation: PASS
```

---

## 3. Check Trivy

```bash
trivy --version
```

Validated version:

```text
Trivy 0.70.0
```

---

## 4. Scan the image

```bash
trivy image \
  --severity HIGH,CRITICAL \
  --ignore-unfixed \
  --exit-code 1 \
  ci-cd-mastery-project-09:local
```

Actual security result:

```text
Debian vulnerabilities: 0
Python package vulnerabilities: 0
```

Therefore:

```text
HIGH/CRITICAL security findings: 0
Security validation: PASS
```

---

# GitHub Actions Validation

The final GitHub Actions run successfully completed:

```text
Run:
31519714392

Job:
Docker Image Security Scan

Result:
SUCCESS
```

Validated steps:

```text
✓ Set up job
✓ Checkout
✓ Setup Python
✓ Install pytest
✓ Run tests
✓ Build Docker image
✓ Scan Docker image
✓ Complete job
```

---

# Real Failure Encountered

Project 09 intentionally demonstrates real CI troubleshooting.

The first GitHub Actions execution failed before the workflow steps started.

Error:

```text
Unable to resolve action
aquasecurity/trivy-action@0.28.0

unable to find version 0.28.0
```

### Root Cause

The referenced Trivy GitHub Action version did not exist.

This was **not** a vulnerability failure.

The job failed during:

```text
Set up job
```

before:

```text
Checkout
Run tests
Docker build
Trivy scan
```

### Diagnosis

GitHub Actions job logs were inspected to identify the exact failure.

### Resolution

The invalid action reference was replaced with a valid Trivy Action reference.

The workflow was pushed again and successfully executed.

Final result:

```text
Project 09 CI: PASS
```

---

# Why This Project Matters

Project 08 established:

```text
Application
   ↓
Docker
   ↓
GHCR
```

Project 09 adds:

```text
Application
   ↓
Tests
   ↓
Docker Build
   ↓
Security Scan
   ↓
Registry / Promotion
```

This introduces the foundation for **DevSecOps container security**.

---

# Security Principle

A container image should not be considered production-ready simply because:

```text
docker build
```

succeeds.

A production-oriented pipeline should validate:

```text
Code
 ↓
Tests
 ↓
Build
 ↓
Security
 ↓
Artifact
 ↓
Deployment
```

---

# Interview Questions

## 1. What is Trivy?

Trivy is an open-source security scanner commonly used to identify vulnerabilities in container images, filesystems, repositories, and other artifacts.

---

## 2. What is a CVE?

CVE stands for **Common Vulnerabilities and Exposures**.

It provides a standardized identifier for publicly known security vulnerabilities.

Example:

```text
CVE-2026-XXXX
```

---

## 3. Why scan Docker images?

Because container images inherit software from their base images and installed packages.

For example:

```text
python:3.12-slim
       ↓
Debian packages
       ↓
Python packages
       ↓
Application
```

A vulnerability in any layer can affect the final image.

---

## 4. Image scanning vs dependency scanning?

### Dependency scanning

Focuses primarily on application dependencies.

Example:

```text
Flask
requests
pytest
```

### Image scanning

Examines the final container artifact, including:

```text
OS packages
Python packages
Application dependencies
Container filesystem
```

They complement each other.

---

## 5. Why use HIGH and CRITICAL as the CI gate?

Because these vulnerabilities generally represent higher risk.

However, severity thresholds should be defined according to organizational security policy.

A mature organization may also consider:

* Exploitability
* Internet exposure
* Runtime context
* Compensating controls
* Whether a fix exists

---

## 6. Why use `exit-code: 1`?

The exit code converts the security finding into a CI failure.

Without this gate, Trivy could report vulnerabilities while the pipeline continues successfully.

---

## 7. Why use `ignore-unfixed`?

Some vulnerabilities have no available upstream fix.

Blocking every such finding may prevent legitimate releases without providing a remediation path.

Therefore organizations may choose to exclude unfixed findings from the blocking gate while still tracking them separately.

---

## 8. Why scan before pushing to a registry?

Because the registry should ideally contain artifacts that have already passed the organization's quality and security gates.

Preferred lifecycle:

```text
Build
 ↓
Test
 ↓
Scan
 ↓
Approve
 ↓
Push
 ↓
Deploy
```

---

## 9. What was the actual Project 09 CI failure?

The first pipeline failed because the workflow referenced:

```text
aquasecurity/trivy-action@0.28.0
```

which GitHub could not resolve.

The important troubleshooting lesson is:

> Always inspect the failed job logs before assuming the failure is caused by the application or security scan.

---

## 10. Is `latest` a secure production image reference?

Not necessarily.

`latest` is a mutable tag.

A production deployment should preferably use:

* Immutable version tags
* Commit SHA tags
* Image digests

Project 10 will build on this concept.

---

# Project 09 Outcome

```text
┌──────────────────────────────────────┐
│ PROJECT 09 — COMPLETE                │
├──────────────────────────────────────┤
│ Docker Build             ✅          │
│ pytest                   ✅          │
│ Trivy Installation       ✅          │
│ Vulnerability Scan       ✅          │
│ HIGH/CRITICAL Findings   0           │
│ GitHub Actions           ✅          │
│ Failure Diagnosis        ✅          │
│ Fix Validation           ✅          │
│ Commit                   ✅          │
│ Push                     ✅          │
└──────────────────────────────────────┘
```

## Mastery Progress

```text
Project 01  Basic CI                         ✅
Project 02  Pull Request CI                  ✅
Project 03  Branch/Path CI                   ✅
Project 04  Matrix CI                        ✅
Project 05  CI Artifacts                     ✅
Project 06  Environments/Gates               ✅
Project 07  Docker Image CI                  ✅
Project 08  GHCR Registry                    ✅
Project 09  Image Security Scanning          ✅
Project 10  Image Tagging/Lifecycle          ▶ NEXT
```

**Key takeaway:** Project 09 transforms the pipeline from merely **building containers** into **building security-validated containers**.
