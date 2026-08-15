# Project 41 — Enterprise Gitleaks Secret Scanning

## 🚀 Overview

Project 41 strengthens the reusable Project 40 CI/CD platform with centralized enterprise-oriented secret scanning using Gitleaks.

The platform now provides:

- Centralized Gitleaks configuration
- Full Git history scanning
- Push protection
- Pull request protection
- Reusable GitHub Actions security workflow
- Controlled false-positive handling
- Developer-facing security failure messages
- No real secrets committed
- Security gating before downstream CI/CD stages

No AWS infrastructure is created or modified by Project 41.

---

## 🏗️ Architecture

```text
Git Push / Pull Request
          │
          ▼
Project 41 Security Workflow
          │
          ▼
Reusable Security Workflow
          │
          ▼
Gitleaks Secret Scanner
          │
      ┌───┴───┐
      │       │
     PASS    FAIL
      │       │
      ▼       ▼
 CI Continues  Pipeline Blocked


🔐 Centralized Configuration

The repository uses:

.gitleaks.toml

The configuration extends Gitleaks default detection rules.

Only deterministic generated/dependency directories are excluded:

.git
.terraform
.venv
__pycache__
node_modules

No blanket exclusions for passwords, tokens, API keys, AWS credentials, or secrets are configured.

🛡️ Security Gate

The reusable security workflow:

Checks out complete Git history.
Executes Gitleaks.
Uses the centralized repository configuration.
Blocks CI when a potential secret is detected.
Provides developer remediation guidance.
Requires justified handling for false positives.

Real credentials must never be allowlisted.

🔄 Reusable CI/CD Architecture

Project 41 extends the Project 40 architecture instead of creating a second CI system.

Project 40 Enterprise CI/CD
            │
            ▼
    Reusable Security
            │
            ├── Gitleaks
            │
            ▼
    Application Tests
            │
            ▼
    Terraform Validation
            │
            ▼
       Docker Build
            │
            ▼
        Trivy
            │
            ▼
          ECR
            │
            ▼
          Helm
            │
            ▼
          EKS
🧪 Local Validation

Run:

gitleaks detect \
  --source . \
  --config .gitleaks.toml \
  --redact \
  --verbose

Expected:

no leaks found

Project 41 was locally validated against the repository history with:

175 commits scanned
no leaks found
📊 Security Controls
Control	Status
Central Gitleaks configuration	✅
Default detection rules	✅
Full Git history scanning	✅
Push scanning	✅
Pull request scanning	✅
CI security gate	✅
Controlled allowlisting	✅
Real credentials committed	❌
Gitleaks baseline required	❌
New AWS infrastructure	❌
Duplicate CI architecture	❌
☁️ AWS Impact

Project 41 requires:

No EKS changes
No VPC changes
No ECR changes
No Terraform infrastructure changes
No IAM infrastructure changes
No additional AWS services

The existing EKS platform remains untouched.

💼 Recruiter Value

This project demonstrates practical DevSecOps engineering through:

Centralized secret detection
Reusable GitHub Actions workflows
Git history security scanning
Pull request protection
Push protection
Controlled false-positive handling
Security-first CI/CD architecture
Developer-focused security feedback

The engineering principle is simple:

Detect secrets before they reach deployment.

🛣️ CI/CD Mastery Roadmap
37  ECR Immutable Image Platform
38  EKS Application Platform
39  EKS Pod Identity
40  Enterprise EKS CI/CD Platform
41  Enterprise Gitleaks Secret Scanning  ← CURRENT
42  Trivy Filesystem + Dependency Scanning
43  Trivy Container Security
44  SBOM Generation
45  Cosign Image Signing
46  Image Verification in EKS
47  Kubernetes Pod Security Standards
48  Kyverno Policy Engine
49  Kubernetes NetworkPolicy Zero Trust
50  AWS IAM / EKS Security Hardening
...
77  Final EKS DevSecOps Production Capstone
🎯 Project Outcome

Project 41 establishes centralized repository secret protection as the first dedicated security control in the EKS DevSecOps platform.

The existing Project 40 CI/CD foundation remains reusable and unchanged architecturally.
EOF



## Step 2 — Validate everything


Then run:


```bash
echo "===== GITLEAKS ====="


gitleaks detect \
  --source . \
  --config .gitleaks.toml \
  --redact \
  --verbose


echo
echo "===== YAML / DIFF ====="


git diff --check


echo
echo "===== PROJECT 41 FILES ====="


find . \
  \( -path './.git' -o -path './.terraform' -o -path './.venv' \) -prune \
  -o \( -name '.gitleaks.toml' \
     -o -name 'project-41-gitleaks-enterprise.yml' \
     -o -name 'README.md' \) -print


echo
echo "===== DIFF STAT ====="


git diff --stat


echo
echo "===== STATUS ====="


git status --short
Expected status
