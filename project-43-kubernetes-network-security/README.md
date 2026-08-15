# 🛡️ Project 43 — Kubernetes Network Security

> **Default-deny first. Allow only the traffic the application actually needs.**

![Kubernetes](https://img.shields.io/badge/Kubernetes-Network%20Security-326CE5)
![NetworkPolicy](https://img.shields.io/badge/NetworkPolicy-Least%20Privilege-success)
![DevSecOps](https://img.shields.io/badge/DevSecOps-Enabled-success)
![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-GREEN-success)
![AWS](https://img.shields.io/badge/AWS-Infrastructure%20Untouched-success)

---

## 🎯 Project Objective

Project 43 introduces **Kubernetes NetworkPolicy-as-Code** into the CI/CD
Mastery platform.

The objective is to establish a least-privilege network security model
around the existing Project 38 application without modifying the existing
AWS infrastructure.

The core principle is:

> **Network access should be explicitly allowed, not implicitly trusted.**

---

## 🛡️ Security Evolution

```text
Project 40
Enterprise EKS CI/CD
        │
        ▼
Project 41
Gitleaks Secret Detection
        │
        ▼
Project 42
Trivy Dependency Security
        │
        ▼
Project 43
Kubernetes Network Security

Project 43 moves security deeper into the Kubernetes workload layer.

🏗️ Architecture
                    Git Push / Pull Request
                              │
                              ▼
                       GitHub Actions
                              │
                              ▼
                 NetworkPolicy Validation
                              │
                              ▼
                  Kubernetes Manifests
                              │
             ┌────────────────┴────────────────┐
             │                                 │
             ▼                                 ▼
       Default Deny                       Explicit Allow
             │                                 │
       ┌─────┴─────┐                    ┌────┴─────┐
       │           │                    │          │
    Ingress      Egress                DNS       HTTP
       │           │                    │          │
       ▼           ▼                    ▼          ▼
     BLOCK        BLOCK              :53 DNS    :5000 App
🔐 Network Security Model

Project 43 defines four NetworkPolicies.

1. Default Deny Ingress
project-38-default-deny-ingress

Blocks unsolicited inbound traffic to pods in the application namespace.

2. Default Deny Egress
project-38-default-deny-egress

Blocks unsolicited outbound traffic from pods in the application namespace.

This establishes an explicit egress security boundary.

3. DNS Allow Rule
project-38-allow-dns

Allows application pods to resolve DNS through the Kubernetes DNS service.

Allowed:

UDP :53
TCP :53

Only traffic to the kube-system DNS pods is allowed.

4. Explicit Application Client Rule
project-38-allow-labeled-client

Allows HTTP traffic to the application only from explicitly labeled
client pods.

Required client label:

project-43-client=allowed

Application traffic:

TCP :5000

This demonstrates explicit workload-to-workload authorization.

🎯 Least-Privilege Model

The intended security model is:

                 project-38
                     │
             ┌───────┴───────┐
             │               │
          Ingress          Egress
             │               │
         DEFAULT DENY     DEFAULT DENY
             │               │
             ▼               ▼
       Explicit HTTP       Explicit DNS
       client only         only

The policies are additive, so no broad namespace-wide HTTP allow rule is
used.

🔍 Existing Application

Project 38 runs:

Namespace: project-38
Replicas: 2
Service: project-38
Service Type: ClusterIP
Service Port: 80
Container Port: 5000

The application exposes:

/health
/ready

Both endpoints were verified successfully before NetworkPolicy design.

🧪 Validation

The policies were validated against the actual Kubernetes API server using
server-side dry-run.

Result:

4 NetworkPolicies
Server validation: PASS

The live cluster was deliberately left unchanged.

Live NetworkPolicies: 0

This is intentional.

🚀 CI Validation

GitHub Actions validates the NetworkPolicy manifests without connecting
to the EKS cluster.

The CI gate validates:

✓ File exists
✓ Exactly 4 NetworkPolicies
✓ YAML syntax
✓ networking.k8s.io/v1
✓ Expected policy names
✓ Required policy specifications

The workflow requires:

No AWS credentials
No EKS access
No Kubernetes cluster connection

This keeps the validation inexpensive and independent from cloud
infrastructure.

🔒 Why CI Does Not Connect to EKS

A GitHub-hosted runner does not need production cluster access simply to
validate NetworkPolicy-as-Code.

Therefore the pipeline deliberately uses offline manifest validation.

Actual Kubernetes API validation was separately performed against the
existing EKS cluster using server-side dry-run.

This creates two security layers:

Repository CI
     │
     ▼
Offline policy validation
     │
     ▼
Kubernetes API validation
     │
     ▼
Deployment / enforcement
⚠️ NetworkPolicy Enforcement Status

During the Project 43 audit, the existing AWS VPC CNI was found to include
the AWS Network Policy Agent, but the NetworkPolicy controller was not
enabled.

Therefore Project 43 does not claim live NetworkPolicy enforcement.

Instead, this project intentionally delivers:

NetworkPolicy-as-Code
        +
Policy validation
        +
CI security gate

No VPC CNI modification was made.

This avoids introducing an unplanned networking change into the existing
EKS platform.

☁️ AWS Impact
ZERO AWS infrastructure changes

Project 43 does not modify:

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

No new AWS resources are required.

💰 Cost Strategy

Project 43 uses:

Existing EKS for API validation
GitHub Actions for CI validation
Kubernetes manifests stored in Git

No additional AWS services or infrastructure are introduced.

🧑‍💻 Developer Workflow
Developer
    │
    ▼
Modify NetworkPolicy
    │
    ▼
Git Commit
    │
    ▼
GitHub Actions
    │
    ├── YAML validation
    ├── Policy count
    ├── API version
    ├── Policy names
    └── Structure validation
            │
            ▼
         GREEN

This turns Kubernetes network security into a repeatable engineering
workflow instead of a manual cluster configuration.

💼 Industry Relevance

Project 43 demonstrates production-oriented concepts including:

Kubernetes NetworkPolicy
Zero-trust networking
Default-deny security
Least-privilege communication
Namespace isolation
DNS allow-listing
Workload identity through labels
Network security as code
CI policy validation
DevSecOps shift-left controls

These patterns are applicable to enterprise Kubernetes platforms,
microservices architectures, financial systems, SaaS platforms, and
large-scale application environments.

📊 Project 43 Outcome
┌──────────────────────────────────────────┐
│ PROJECT 43 — NETWORK SECURITY            │
├──────────────────────────────────────────┤
│ NetworkPolicies                  4       │
│ Default Deny Ingress             ✓       │
│ Default Deny Egress              ✓       │
│ DNS Allow                         ✓       │
│ Explicit HTTP Allow              ✓       │
│ Broad HTTP Allow                 ✗       │
│ CI Validation                    ✓       │
│ EKS Server Validation            ✓       │
│ Live Cluster Changes              0       │
│ AWS Infrastructure Changes        0       │
│ GitHub Actions                   GREEN   │
└──────────────────────────────────────────┘
🧠 DevSecOps Principle

If a workload does not explicitly need network access, it should not
receive it by default.

Project 43 turns that principle into version-controlled Kubernetes
security policy and automated CI validation.

🏆 Project Roadmap
Project	Capability
40	Enterprise EKS CI/CD
41	Gitleaks Secret Detection
42	Trivy Dependency Security
43	Kubernetes Network Security
👤 Author

Ashish Mondal

CI/CD • AWS • Kubernetes • Terraform • GitHub Actions • DevSecOps

⭐ Part of the CI/CD Mastery — 100 Project Engineering Journey
