# Project 44 — Kubernetes RBAC Hardening

## Overview

Project 44 implements namespace-scoped Kubernetes RBAC using a least-privilege security model.

The project defines separate identities for:

- Application workloads
- Read-only viewers
- Application operators

Each identity receives only the permissions required for its intended responsibility.

The RBAC model is validated both statically in CI and dynamically against the existing EKS cluster using `kubectl auth can-i`.

---

## Objectives

- Implement Kubernetes Role-Based Access Control.
- Apply namespace-level least privilege.
- Separate application, viewer, and operator permissions.
- Prevent unnecessary access to Secrets.
- Prevent RBAC administration by application identities.
- Prevent wildcard permissions.
- Avoid unnecessary cluster-wide privileges.
- Automate RBAC policy validation in GitHub Actions.
- Verify real Kubernetes authorization behavior.

---

## Architecture

```text
                    Kubernetes Cluster
                           |
                    project-44-rbac
                           |
          +----------------+----------------+
          |                |                |
          v                v                v
   project-44-app   project-44-viewer   project-44-operator
          |                |                |
          v                v                v
    App Reader Role    Viewer Role      Operator Role
          |                |                |
          +----------------+----------------+
                           |
                    RoleBindings


All permissions are namespace-scoped.

No ClusterRole or ClusterRoleBinding is created by this project.

RBAC Model
Application

project-44-app

Allowed:

Read Pods
List Pods
Watch Pods
Read Services
Read ConfigMaps

Denied:

Read Secrets
Delete Pods
Create Deployments
Create Roles
Viewer

project-44-viewer

Allowed:

Read Pods
List Pods
Watch Pods
Read Services
Read ConfigMaps
Read Deployments

Denied:

Read Secrets
Update Deployments
Delete Pods
Operator

project-44-operator

Allowed:

Read Pods
List Pods
Read Deployments
Update Deployments
Patch Deployments
Read ConfigMaps

Denied:

Read Secrets
Create Roles
Create RoleBindings
Delete Pods
Security Controls

The project intentionally prevents:

Cluster-wide RBAC permissions
Wildcard resources
Wildcard verbs
Secret access
RBAC administration
Unnecessary destructive permissions

The operator role is intentionally limited to Deployment management rather than granting broad administrative access.

Repository Structure
project-44-kubernetes-rbac-hardening/
├── manifests/
│   └── rbac.yaml
│
└── scripts/
    ├── test-rbac.sh
    └── validate-rbac-policy.sh

CI workflow:

.github/workflows/project-44-rbac-security.yml
Validation
Static validation

The CI policy validator checks:

YAML structure
ServiceAccount count
Role count
RoleBinding count
Absence of ClusterRole
Absence of ClusterRoleBinding
Absence of wildcard permissions
Absence of Secret permissions
Absence of RBAC administration permissions
Runtime authorization testing

The authorization test suite uses:

kubectl auth can-i

to verify both allowed and denied operations.

Final result:

Application:  9/9 PASS
Viewer:       9/9 PASS
Operator:    10/10 PASS
-------------------------
Total:       28/28 PASS
CI/CD Security Gate

GitHub Actions validates the RBAC policy without requiring access to the EKS cluster.

Pipeline:

Git Push / Pull Request
          |
          v
    Checkout Repository
          |
          v
       Ruby Setup
          |
          v
   RBAC Policy Validator
          |
          v
     Security Checks
          |
          v
       PASS / FAIL

The CI gate does not create or modify Kubernetes resources.

Infrastructure Safety

Project 44 does not modify:

EKS infrastructure
VPC
ECR
Terraform infrastructure
IAM
GitHub OIDC
EBS CSI
VPC CNI
CoreDNS
kube-proxy
EKS Pod Identity

Only the dedicated Kubernetes namespace:

project-44-rbac

and its namespace-scoped RBAC resources are used for runtime validation.

Key Takeaways

This project demonstrates practical Kubernetes security through:

Least-privilege authorization.
Namespace isolation.
Separation of workload identities.
Explicit allow/deny authorization testing.
Automated RBAC policy validation.
Prevention of privilege escalation.
CI-based security enforcement.
Project Status

Project 44 — COMPLETE

✓ RBAC implementation
✓ Least-privilege design
✓ Static security validation
✓ Runtime authorization testing
✓ 28/28 authorization tests passing
✓ GitHub Actions security gate
✓ GitHub Actions GREEN
✓ No AWS infrastructure changes

EOF
