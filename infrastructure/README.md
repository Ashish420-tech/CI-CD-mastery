# Reusable Terraform EKS Platform

Shared AWS EKS infrastructure for CI/CD Mastery Kubernetes projects.

## Platform

- AWS VPC
- Three Availability Zones
- Private EKS worker subnets
- EKS Kubernetes 1.34
- Managed node group
- Minimum 3 nodes
- Desired 3 nodes
- Maximum 6 nodes
- IRSA
- KMS secrets encryption
- EKS control-plane logging
- CoreDNS
- kube-proxy
- VPC CNI
- EBS CSI
- Shared immutable ECR

## Lifecycle

Terraform manages infrastructure.

Kubernetes and Helm manage workloads.

GitHub Actions manages CI/CD.

Projects 33–100 reuse this EKS platform.

## Autoscaling

Node-group boundaries:

- minimum: 3
- desired: 3
- maximum: 6

Cluster Autoscaler/Karpenter will be introduced as dedicated platform capabilities later.

## Disaster Recovery Roadmap

- Remote Terraform state
- State locking
- EBS snapshots
- AWS Backup
- Kubernetes resource backup
- Velero evaluation
- Multi-AZ workloads
- Full infrastructure recreation from Terraform

## Cost Control

This is a controlled AWS lab.

Use:

```text
terraform apply
    ↓
test
    ↓
capture evidence
    ↓
terraform destroy
Our reusable EKS foundation should contain:

infrastructure/
└── eks/
    ├── versions.tf
    ├── providers.tf
    ├── variables.tf
    ├── main.tf
    ├── ecr.tf
    ├── outputs.tf
    ├── terraform.tfvars.example
    ├── eks_script.sh
    └── README.md

And the README should have a section:

## Troubleshooting Record

### Issue 1 — t3.medium Free Tier restriction

AWS rejected t3.medium because it was not eligible
under the available Free Tier configuration.

Resolution:
Use c7i-flex.large.

### Issue 2 — EKS nodes NotReady

Nodes launched successfully but reported:

NetworkPluginNotReady
CNI plugin not initialized

Resolution:
Install the AWS VPC CNI EKS add-on.

### Issue 3 — Terraform/AWS state mismatch

Some add-ons were created manually during recovery.

Resolution:
Import existing AWS resources into Terraform state.

### Issue 4 — Failed node group

The failed t3.medium node group was removed.

Final node group:
c7i-flex.large
min=3
desired=3
max=6

That gives us both:

Terraform = reproducible solution

and

README/Git history = engineering troubleshooting record.

The most important principle for Projects 34 onward

We're going to follow this architecture:

                    GitHub
                       │
                       ▼
                Terraform Code
                       │
                       ▼
              Reusable EKS Platform
                       │
       ┌───────────────┼────────────────┐
       ▼               ▼                ▼
    Network          EKS              Security
       │               │                │
       │        ┌──────┼──────┐         │
       │        ▼      ▼      ▼         │
       │       CNI   DNS  kube-proxy    │
       │                               │
       └───────────────┬───────────────┘
                       ▼
                Project 34+
                       │
                       ▼
             Applications / workloads
