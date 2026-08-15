# 🚀 Project 39 — EKS Pod Identity

> Secure Kubernetes workload identity using Amazon EKS Pod Identity,
> IAM least privilege and temporary AWS credentials.

![AWS](https://img.shields.io/badge/AWS-EKS-orange?logo=amazonaws)
![Kubernetes](https://img.shields.io/badge/Kubernetes-1.34-blue?logo=kubernetes)
![Terraform](https://img.shields.io/badge/IaC-Terraform-purple?logo=terraform)
![IAM](https://img.shields.io/badge/Security-IAM-red)
![EKS Pod Identity](https://img.shields.io/badge/EKS-Pod%20Identity-green)

---

## 📌 Overview

Project 39 introduces secure AWS workload identity for Kubernetes
applications running on the existing Amazon EKS platform.

Instead of storing AWS access keys inside containers, Kubernetes workloads
receive temporary AWS credentials through EKS Pod Identity.

```text
Kubernetes Pod
      ↓
ServiceAccount
      ↓
EKS Pod Identity Association
      ↓
IAM Role
      ↓
Temporary AWS Credentials
      ↓
AWS API


🎯 Objectives

Project 39 demonstrates:

EKS Pod Identity
Kubernetes ServiceAccount integration
IAM role trust for pods.eks.amazonaws.com
Temporary AWS credentials
Least-privilege IAM
Terraform-managed identity infrastructure
Automated identity verification
Reuse of the existing EKS platform

No new EKS cluster is created.

🏗️ Architecture
                         Amazon EKS
                             │
                             ▼
                    ┌─────────────────┐
                    │ Kubernetes Pod  │
                    └────────┬────────┘
                             │
                             ▼
                    ServiceAccount
                     project-39-app
                             │
                             ▼
                 EKS Pod Identity Agent
                             │
                             ▼
                 Pod Identity Association
                             │
                             ▼
              GitHubActions-Project39PodIdentityRole
                             │
                             ▼
                  Temporary STS Credentials
                             │
                             ▼
                    AWS API / Services
☁️ Existing EKS Platform

Project 39 reuses the existing platform:

Component	Value
AWS Account	742820980479
Region	ap-south-1
EKS Cluster	ci-cd-mastery-eks
Kubernetes	v1.34.9-eks-254016e
EKS Status	ACTIVE
Nodes	3
Pod Identity Agent	Enabled

The EKS Pod Identity Agent was already installed on the cluster.

No duplicate agent installation was required.

🔐 IAM Architecture

The Project 39 IAM role is:

GitHubActions-Project39PodIdentityRole

Role ARN:

arn:aws:iam::742820980479:role/GitHubActions-Project39PodIdentityRole

The trust policy allows:

pods.eks.amazonaws.com

with:

sts:AssumeRole
sts:TagSession

This is the EKS Pod Identity trust model.

🛡️ Least Privilege

The demonstration workload receives only:

sts:GetCallerIdentity

permission.

This intentionally proves workload identity without granting unnecessary
AWS permissions.

The policy can later be replaced with narrowly scoped permissions for the
actual AWS service required by an application.

☸️ Kubernetes Configuration
Namespace
project-39
ServiceAccount
project-39-app

The Pod uses:

serviceAccountName: project-39-app

The ServiceAccount is associated with the IAM role through EKS Pod Identity.

🔗 Pod Identity Association

Terraform creates:

EKS Cluster
     ↓
Namespace: project-39
     ↓
ServiceAccount: project-39-app
     ↓
IAM Role

Terraform resource:

resource "aws_eks_pod_identity_association" "project39" {
  cluster_name    = "ci-cd-mastery-eks"
  namespace       = "project-39"
  service_account = "project-39-app"
  role_arn        = aws_iam_role.project39.arn
}
🏗️ Terraform

Project 39 uses Terraform to create:

1. IAM Role
2. IAM Inline Policy
3. EKS Pod Identity Association

Terraform result:

Plan:
3 to add
0 to change
0 to destroy

Apply result:

Apply complete!
Resources: 3 added, 0 changed, 0 destroyed.

The existing EKS platform was not recreated.

🧪 Identity Verification

A dedicated Kubernetes test pod was deployed using:

project-39-app

The pod executed:

aws sts get-caller-identity

Successful response:

Account:
742820980479


Arn:
arn:aws:sts::742820980479:assumed-role/
GitHubActions-Project39PodIdentityRole/...

Final verification:

===== IDENTITY TEST PASSED =====

This proves that the pod received temporary AWS credentials through EKS
Pod Identity.

🔄 Credential Flow

The complete credential flow is:

Pod
 │
 │ ServiceAccount
 ▼
EKS Pod Identity Agent
 │
 ▼
EKS Pod Identity
 │
 ▼
IAM Role
 │
 ▼
Temporary STS Credentials
 │
 ▼
AWS API

No AWS access keys are stored inside the container.

No static AWS credentials are required.

🔒 Security Benefits
No Static Credentials

The application does not require:

AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_SESSION_TOKEN

to be stored as Kubernetes secrets.

Temporary Credentials

AWS credentials are provided dynamically to the workload.

Least Privilege

The IAM policy grants only the permission required for this demonstration.

Workload Isolation

Identity is attached to a specific Kubernetes ServiceAccount.

📊 Verification Commands
Check Pod Identity Agent
kubectl get pods \
  -n kube-system \
  -l app.kubernetes.io/instance=eks-pod-identity-agent

Expected:

3/3 Running
Check Association
aws eks list-pod-identity-associations \
  --cluster-name ci-cd-mastery-eks \
  --region ap-south-1

Expected:

project-39
project-39-app
Check ServiceAccount
kubectl get serviceaccount \
  project-39-app \
  -n project-39
Verify AWS Identity
kubectl logs \
  project-39-identity-test \
  -n project-39

Expected:

Account: 742820980479
Arn: assumed-role/GitHubActions-Project39PodIdentityRole/...
📁 Project Structure
project-39-eks-pod-identity/
│
├── manifests/
│   ├── namespace.yaml
│   ├── serviceaccount.yaml
│   └── identity-test-pod.yaml
│
├── terraform/
│   └── main.tf
│
└── README.md
🔗 CI/CD Mastery Platform Evolution

Project 39 extends the previous platform projects.

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

The platform now provides:

Source
  ↓
Secure CI/CD
  ↓
Immutable Artifact
  ↓
EKS Deployment
  ↓
Workload Identity
🏢 Platform Engineering Principle

Project 39 follows the platform engineering principle:

Applications consume platform capabilities instead of implementing
cloud authentication independently.

Future applications can reuse the same pattern:

Application
     ↓
Dedicated ServiceAccount
     ↓
Dedicated IAM Role
     ↓
EKS Pod Identity
     ↓
Least-Privilege AWS Access

This prevents applications from sharing broad IAM permissions.

💰 Cost Optimization

Project 39 does not create:

New EKS cluster
New VPC
New NAT Gateway
New node group
New ECR repository

The existing EKS platform and Pod Identity Agent are reused.

The only AWS resources introduced are the workload IAM role and Pod Identity
association required for the project.

🏆 Project Outcome

Project 39 successfully demonstrates:

EKS Pod Identity
Kubernetes ServiceAccount identity
IAM trust configuration
Temporary AWS credentials
Least-privilege IAM
Terraform automation
AWS STS identity verification
Secure workload authentication
Existing EKS platform reuse
📈 Roadmap
36 — Helm Application Packaging       ✅
37 — ECR Immutable Image Platform     ✅
38 — EKS Application Platform         ✅
39 — EKS Pod Identity                 ✅
40 — Enterprise EKS CI/CD Platform    ⏭

Future phases will build on this foundation:

41–50  DevSecOps
51–60  Advanced Delivery + GitOps
61–70  Observability + Reliability
71–77  Production Platform Engineering
👨‍💻 Author

Ashish Mondal

DevOps & Cloud Engineer

Core Technologies:

AWS · EKS · IAM · Terraform · Kubernetes ·
Docker · Helm · GitHub Actions · DevSecOps

✅ Status
PROJECT 39 — EKS POD IDENTITY

COMPLETE ✅

Verified:

EKS Pod Identity Agent       ✅
IAM Role                    ✅
IAM Trust Policy             ✅
Least Privilege Policy       ✅
Pod Identity Association     ✅
ServiceAccount               ✅
Temporary AWS Credentials    ✅
STS Identity Verification    ✅
Terraform Deployment         ✅
Existing EKS Reused          ✅
Final Proof
Kubernetes Pod
      ↓
ServiceAccount
      ↓
EKS Pod Identity
      ↓
GitHubActions-Project39PodIdentityRole
      ↓
Temporary STS Credentials
      ↓
AWS Account 742820980479


IDENTITY TEST PASSED ✅
