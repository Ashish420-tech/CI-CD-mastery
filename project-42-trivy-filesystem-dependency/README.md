# 🔐 Project 42 — Trivy Filesystem + Dependency Security

> **Find dependency vulnerabilities before they reach production.**

![DevSecOps](https://img.shields.io/badge/DevSecOps-Enabled-success)
![Trivy](https://img.shields.io/badge/Trivy-Filesystem%20Scanning-blue)
![Gitleaks](https://img.shields.io/badge/Gitleaks-Secret%20Scanning-orange)
![CI](https://img.shields.io/badge/GitHub%20Actions-GREEN-success)
![AWS](https://img.shields.io/badge/AWS-Infrastructure%20Untouched-success)

---

## 🎯 Project Objective

Project 42 extends the centralized security architecture built in
Project 40 and Project 41 by introducing:

- Trivy filesystem vulnerability scanning
- Dependency vulnerability detection
- HIGH/CRITICAL security gates
- Developer-focused remediation output
- Controlled filesystem exclusions
- Reusable GitHub Actions security architecture

The objective is to detect vulnerable dependencies **before application
delivery**.

---

## 🛡️ Security Evolution

```text
┌─────────────────────────────────────┐
│ Project 40                          │
│ Enterprise EKS CI/CD                │
└──────────────────┬──────────────────┘
                   │
                   ▼
┌─────────────────────────────────────┐
│ Project 41                          │
│ Gitleaks Secret Detection            │
│                                     │
│ Prevent credentials from leaking     │
└──────────────────┬──────────────────┘
                   │
                   ▼
┌─────────────────────────────────────┐
│ Project 42                          │
│ Trivy Filesystem + Dependency Scan  │
│                                     │
│ Prevent vulnerable dependencies      │
│ from reaching the delivery pipeline  │
└──────────────────┬──────────────────┘
                   │
                   ▼
          Secure CI/CD Pipeline

🔍 What Trivy Scans

Trivy recursively scans the repository filesystem for supported
dependency manifests.

Current repository manifests detected include:

project-18-compose-multi-container/requirements.txt
project-19-compose-enterprise-config/requirements.txt
project-20-compose-secrets/requirements.txt
project-21-compose-profiles/requirements.txt
project-38-eks-application-platform/app/requirements.txt

The architecture is not hard-coded to Python and can detect supported
dependency manifests introduced into the repository later.

🚦 Security Gate Policy
Severity	Action
CRITICAL	❌ Block CI
HIGH	❌ Block CI
MEDIUM	⚠️ Report
LOW	⚠️ Report

The Project 42 gate intentionally focuses on:

HIGH, CRITICAL

No vulnerability baseline is used.

Unfixed vulnerabilities are not silently ignored.

🔐 Existing Gitleaks Protection

Project 41 remains intact.

The centralized security workflow now provides:

                reusable-security.yml
                       │
              ┌────────┴────────┐
              │                 │
           Gitleaks            Trivy
              │                 │
        Secret Detection   Dependency Security
              │                 │
              └────────┬────────┘
                       │
                  Security Gate

This avoids creating separate security architectures for every control.

🎯 Controlled Exclusions

Trivy excludes only generated, cached, or local development content:

.git
.terraform
.venv
node_modules
__pycache__
.pytest_cache
*.pyc

These exclusions are deliberately narrow.

The project does not use broad vulnerability suppression to manufacture
a green pipeline.

👨‍💻 Developer Remediation

When HIGH or CRITICAL vulnerabilities are detected:

1. Review the Trivy finding
        ↓
2. Identify vulnerable dependency
        ↓
3. Locate dependency manifest
        ↓
4. Upgrade to secure compatible version
        ↓
5. Run tests
        ↓
6. Re-run Trivy
        ↓
7. Security gate passes

The pipeline explains what the developer needs to investigate instead of
simply returning a generic CI failure.

🧪 Local Validation

Project 42 was validated locally using Trivy filesystem scanning.

Result:

Dependency manifests scanned: 5


HIGH:     0
CRITICAL: 0


RESULT: PASS

Trivy also refreshed the local vulnerability database during validation.

🚀 GitHub Actions Validation

The Project 42 workflow successfully executed on GitHub Actions.

Project 42
    │
    ├── Gitleaks Secret Scan
    │       └── ✅ PASS
    │
    └── Trivy Filesystem Dependency Scan
            └── ✅ PASS


Workflow: SUCCESS

This confirms that the centralized reusable security workflow works in
GitHub Actions, not only on the developer workstation.

☁️ AWS Impact
ZERO AWS infrastructure changes

Project 42 runs entirely on GitHub Actions compute.

No changes were made to:

EKS
VPC
ECR
EBS CSI
VPC CNI
CoreDNS
kube-proxy
EKS Pod Identity
GitHub OIDC
Terraform infrastructure

This keeps security validation independent from the existing AWS platform.

🏗️ Architecture
Developer
    │
    ▼
Git Push / Pull Request
    │
    ▼
GitHub Actions
    │
    ▼
Reusable Security Workflow
    │
    ├───────────────┐
    ▼               ▼
 Gitleaks         Trivy FS
    │               │
    │          Dependency Scan
    │               │
    └───────┬───────┘
            ▼
       Security Gate
            │
      ┌─────┴─────┐
      │           │
   PASS          FAIL
      │           │
      ▼           ▼
 Continue       Remediate
 CI/CD          Dependency
💼 Industry Relevance

This project demonstrates practical DevSecOps engineering patterns used
in production environments:

Shift-left security
Software composition security
Dependency vulnerability management
Filesystem vulnerability scanning
Severity-based CI gates
Reusable GitHub Actions workflows
Developer remediation workflows
Controlled security exclusions
Security automation without additional cloud infrastructure
🧠 What This Project Demonstrates

Project 42 answers an important production question:

"Can we prevent known vulnerable dependencies from progressing through
our CI/CD pipeline?"

The answer is now:

YES — HIGH and CRITICAL dependency vulnerabilities block the pipeline.

🏆 Project 42 Outcome
┌─────────────────────────────────────────┐
│ PROJECT 42 SECURITY GATE                │
├─────────────────────────────────────────┤
│ Gitleaks                         PASS   │
│ Trivy Filesystem                PASS   │
│ HIGH vulnerabilities               0   │
│ CRITICAL vulnerabilities           0   │
│ AWS infrastructure changes         0   │
│ GitHub Actions                   GREEN  │
└─────────────────────────────────────────┘
📚 Projects
Project	Security Capability
40	Enterprise EKS CI/CD
41	Enterprise Gitleaks Secret Scanning
42	Trivy Filesystem + Dependency Security
🔥 DevSecOps Principle

Security should be a quality gate, not a production surprise.

Project 42 moves dependency security earlier in the software delivery
lifecycle and makes vulnerability remediation part of normal CI/CD.

👤 Author

Ashish Mondal

CI/CD • AWS • Kubernetes • Terraform • GitHub Actions • DevSecOps

⭐ Built as part of the CI/CD Mastery — 100 Project Engineering Journey.
