# Project 47 — GitOps Continuous Delivery with Argo CD on Amazon EKS

> **Enterprise GitOps deployment platform using GitHub, Helm, Argo CD, Amazon ECR, immutable image digests, and Amazon EKS — with automated reconciliation, drift detection, and self-healing.**

![GitOps](https://img.shields.io/badge/GitOps-Argo%20CD-ef7b4d)
![Kubernetes](https://img.shields.io/badge/Kubernetes-EKS-326CE5)
![AWS](https://img.shields.io/badge/AWS-EKS%20%7C%20ECR-232F3E)
![Helm](https://img.shields.io/badge/Helm-3.x-0F1689)
![Security](https://img.shields.io/badge/Image-Immutable%20Digest-success)
![Status](https://img.shields.io/badge/Project%2047-Completed-success)

---

## 📌 Executive Summary

Project 47 introduces a **GitOps continuous delivery model** into the existing CI/CD platform.

The major architectural change is that deployment state is no longer pushed directly from a CI runner into Kubernetes. Instead:

```text
Developer
   │
   ▼
GitHub
   │
   ├── Source Code
   ├── Helm Chart
   └── GitOps Desired State
          │
          ▼
      Argo CD
          │
          │ Reconciliation
          ▼
   Amazon EKS
          │
          ▼
      Project 38
```

GitHub becomes the **source of truth**, while Argo CD continuously compares the desired state stored in Git with the live state in Kubernetes.

Project 47 also preserves the supply-chain security work established in the preceding projects by deploying the application using an **immutable ECR SHA-256 digest** instead of a mutable image tag.

The final platform demonstrates:

- GitOps
- Continuous reconciliation
- Helm-based application delivery
- Argo CD
- Amazon EKS
- Amazon ECR
- Immutable image references
- Automated synchronization
- Drift detection
- Self-healing
- Kubernetes declarative management
- Separation of CI and CD responsibilities

---

# 🏗️ Architecture

```text
                              ┌─────────────────────┐
                              │     Developer       │
                              └──────────┬──────────┘
                                         │
                                         ▼
                              ┌─────────────────────┐
                              │       GitHub        │
                              │                     │
                              │ Source + Helm +     │
                              │ GitOps Desired State│
                              └──────────┬──────────┘
                                         │
                                         │ Git revision
                                         ▼
                              ┌─────────────────────┐
                              │      Argo CD        │
                              │                     │
                              │ Repo Server         │
                              │ Application Ctrl    │
                              │ Server              │
                              │ ApplicationSet Ctrl │
                              └──────────┬──────────┘
                                         │
                                         │ Kubernetes API
                                         ▼
                    ┌────────────────────────────────────────┐
                    │             Amazon EKS                 │
                    │                                        │
                    │  Namespace: argocd                     │
                    │      └── Argo CD control plane         │
                    │                                        │
                    │  Namespace: project-38                 │
                    │      ├── Deployment                    │
                    │      ├── Service                       │
                    │      └── ConfigMap                      │
                    └───────────────────┬────────────────────┘
                                        │
                                        │ Image pull
                                        ▼
                              ┌─────────────────────┐
                              │      Amazon ECR     │
                              │                     │
                              │ Immutable SHA-256   │
                              │ image digest         │
                              └─────────────────────┘
```

---

# 🎯 Project Objectives

The project was designed to answer a fundamental enterprise DevOps question:

> **How do we move from "CI deploys to Kubernetes" to a controlled, auditable, continuously reconciled GitOps deployment model?**

The objectives were:

1. Deploy Argo CD into the existing EKS cluster.
2. Reuse the existing EKS platform instead of provisioning another cluster.
3. Reuse the existing ECR repository.
4. Reuse the existing Project 38 Helm chart.
5. Make the Helm chart support immutable image digests.
6. Define an Argo CD `Application` declaratively in Git.
7. Configure automated synchronization.
8. Enable automated self-healing.
9. Demonstrate intentional Kubernetes drift.
10. Verify that Argo CD restores the Git-defined state.
11. Maintain the supply-chain integrity established in previous projects.

---

# 🧱 Existing Platform Reused

Project 47 intentionally **does not create another Kubernetes cluster**.

Existing infrastructure:

```text
Cluster:
ci-cd-mastery-eks

Region:
ap-south-1

Kubernetes:
1.34

Application namespace:
project-38

GitOps namespace:
argocd
```

Existing ECR repository:

```text
742820980479.dkr.ecr.ap-south-1.amazonaws.com/ci-cd-mastery/applications
```

This approach demonstrates an important enterprise principle:

> GitOps is a deployment/control-plane architecture, not a reason to duplicate infrastructure.

---

# 📁 Project Structure

```text
CI-CD-mastery/
│
├── project-38-eks-application-platform/
│   └── chart/
│       └── project-38-app/
│           ├── Chart.yaml
│           ├── values.yaml
│           └── templates/
│               ├── deployment.yaml
│               ├── service.yaml
│               └── configmap.yaml
│
└── project-47-gitops-argocd/
    └── argocd/
        └── application.yaml
```

---

# 🔐 Immutable Container Deployment

One of the most important improvements in Project 47 was changing the Helm chart from tag-only image references.

### Previous model

```yaml
image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
```

This makes deployments dependent on a mutable tag.

For example:

```text
applications:latest
```

could point to different image content at different times.

### Project 47 model

The chart now supports:

```yaml
image:
  repository: nginx
  tag: "1.27-alpine"
  digest: ""
  pullPolicy: IfNotPresent
```

and renders:

```text
repository@sha256:<digest>
```

when a digest is supplied.

The production GitOps deployment uses:

```text
742820980479.dkr.ecr.ap-south-1.amazonaws.com/ci-cd-mastery/applications@sha256:90e4b7e35b5b4c2644550dbc08c1ca257d37453874aeb06f8b585241884ed98f
```

### Why this matters

An image tag answers:

> "Which named version?"

An image digest answers:

> "Which exact image content?"

The digest therefore provides stronger deployment reproducibility and traceability.

---

# 🚀 Argo CD Installation

Argo CD was installed into:

```text
argocd
```

namespace.

The installation initially encountered an ApplicationSet CRD annotation-size problem when using client-side apply.

The failed resource was:

```text
applicationsets.argoproj.io
```

The CRD was successfully installed using server-side apply:

```bash
kubectl apply --server-side \
  --force-conflicts \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

Final Argo CD components were healthy:

```text
argocd-application-controller
argocd-applicationset-controller
argocd-dex-server
argocd-notifications-controller
argocd-redis
argocd-repo-server
argocd-server
```

All were verified as:

```text
1/1 Running
```

Argo CD was intentionally kept internal using Kubernetes `ClusterIP` services.

For local dashboard access:

```bash
kubectl port-forward svc/argocd-server \
  -n argocd \
  8081:443
```

Dashboard:

```text
https://localhost:8081
```

---

# 📜 Argo CD Application

The GitOps application is:

```text
project-38-gitops
```

defined in:

```text
project-47-gitops-argocd/argocd/application.yaml
```

Key configuration:

```yaml
spec:
  project: default

  source:
    repoURL: https://github.com/Ashish420-tech/CI-CD-mastery.git
    targetRevision: project-47-gitops-argocd
    path: project-38-eks-application-platform/chart/project-38-app
```

Argo CD renders the existing Helm chart directly from Git.

The destination is:

```yaml
destination:
  server: https://kubernetes.default.svc
  namespace: project-38
```

In the Argo CD dashboard this appears as:

```text
Destination: in-cluster
```

### What does `in-cluster` mean?

It means Argo CD is communicating with the Kubernetes API of the cluster where Argo CD itself is running.

In this project:

```text
Argo CD
   │
   ▼
ci-cd-mastery-eks
```

It does **not** mean "not using EKS."

It means:

> Argo CD is using the local Kubernetes API endpoint inside the same EKS cluster.

---

# 🔄 Automated Synchronization

The Application enables:

```yaml
syncPolicy:
  automated:
    prune: true
    selfHeal: true
```

This provides two important capabilities.

### Automated sync

When the Git desired state changes:

```text
Git change
   ↓
Argo CD detects change
   ↓
Application becomes OutOfSync
   ↓
Argo CD reconciles
   ↓
EKS updated
```

### Self-healing

When someone changes Kubernetes directly:

```text
Git:
replicas = 2

EKS:
replicas = 1

       ↓

Argo CD detects drift

       ↓

Argo CD restores:

EKS:
replicas = 2
```

---

# 🧪 Validation

## Helm lint

```bash
helm lint \
  project-38-eks-application-platform/chart/project-38-app
```

Result:

```text
1 chart(s) linted, 0 chart(s) failed
```

The only informational message was that a chart icon is recommended.

---

## Helm rendering

The chart was rendered with the immutable digest:

```bash
helm template project-38 \
  project-38-eks-application-platform/chart/project-38-app \
  --namespace project-38 \
  --set image.repository=742820980479.dkr.ecr.ap-south-1.amazonaws.com/ci-cd-mastery/applications \
  --set image.digest=sha256:90e4b7e35b5b4c2644550dbc08c1ca257d37453874aeb06f8b585241884ed98f
```

Rendered image:

```text
742820980479.dkr.ecr.ap-south-1.amazonaws.com/ci-cd-mastery/applications@sha256:90e4b7e35b5b4c2644550dbc08c1ca257d37453874aeb06f8b585241884ed98f
```

---

# ✅ Final Deployment Validation

Argo CD reported:

```text
project-38-gitops
SYNC STATUS:   Synced
HEALTH STATUS: Healthy
```

Managed resources:

```text
ConfigMap    project-38-config    Synced
Service      project-38           Synced
Deployment   project-38           Synced
```

Deployment:

```text
READY:        2/2
UP-TO-DATE:   2
AVAILABLE:    2
```

Pods:

```text
2/2 Running
```

Final image:

```text
742820980479.dkr.ecr.ap-south-1.amazonaws.com/ci-cd-mastery/applications@sha256:90e4b7e35b5b4c2644550dbc08c1ca257d37453874aeb06f8b585241884ed98f
```

---

# 🔥 Drift Detection & Self-Healing Demonstration

This was the most important practical test of Project 47.

## Baseline

```text
Argo CD:
Synced / Healthy

Deployment:
desired=2
available=2
```

Then the live Kubernetes deployment was intentionally changed:

```bash
kubectl scale deployment project-38 \
  -n project-38 \
  --replicas=1
```

This changed only the live EKS state.

Git remained unchanged:

```text
Git desired replicas = 2
```

Argo CD continuously reconciled the live cluster against Git.

Final result:

```text
Argo CD:
Synced / Healthy

Deployment:
2/2

Pods:
2/2 Running
```

This demonstrated:

```text
Git desired state
       │
       │ differs from
       ▼
Live Kubernetes state
       │
       ▼
Argo CD detects drift
       │
       ▼
Self-healing
       │
       ▼
Live state restored
```

---

# 🧠 Why GitOps Is Different from Traditional CI/CD

### Traditional deployment

```text
Developer
   ↓
GitHub
   ↓
CI pipeline
   ↓
kubectl / Helm
   ↓
Kubernetes
```

The CI pipeline actively pushes deployment changes.

### GitOps

```text
Developer
   ↓
GitHub
   ↓
Desired state
   ↓
Argo CD
   ↓
Kubernetes
```

Argo CD continuously pulls/reconciles the desired state.

### Key difference

Traditional CD asks:

> "Can the pipeline deploy?"

GitOps asks:

> "Does the live environment continuously match the desired state?"

That difference becomes extremely important in production.

---

# 🔐 Security Considerations

## Immutable images

Avoid:

```text
latest
```

Prefer:

```text
repository@sha256:digest
```

This reduces ambiguity around what artifact is actually deployed.

---

## Git as the source of truth

Production configuration should be reviewable through:

```text
Git history
Pull requests
Code review
Branch protection
Audit history
```

rather than relying on undocumented manual changes.

---

## Argo CD network exposure

Argo CD was not exposed using a public LoadBalancer.

Services remained:

```text
ClusterIP
```

The dashboard was accessed temporarily using:

```bash
kubectl port-forward
```

This reduces unnecessary exposure during the lab.

---

# 🔁 CI vs CD Responsibilities

A mature GitOps architecture separates responsibilities.

## CI

GitHub Actions can be responsible for:

```text
Checkout
   ↓
Unit tests
   ↓
Security scanning
   ↓
Build
   ↓
Container scan
   ↓
Push to ECR
   ↓
Cosign signing
   ↓
SBOM / attestation
```

## CD

Argo CD is responsible for:

```text
Git desired state
       ↓
Compare with EKS
       ↓
Detect drift
       ↓
Synchronize
       ↓
Self-heal
```

This separation prevents CI pipelines from requiring direct, continuous deployment control over the Kubernetes cluster.

---

# 🧩 Why Helm + Argo CD?

Helm solves:

> How should Kubernetes manifests be packaged and parameterized?

Argo CD solves:

> How should Kubernetes desired state be continuously reconciled?

Together:

```text
Helm
  ↓
Templating / Packaging
  ↓
Argo CD
  ↓
Reconciliation
  ↓
Kubernetes
```

They solve different problems and complement each other.

---

# ⚖️ Argo CD vs GitHub Actions Deployment

| Capability | GitHub Actions + Helm | Argo CD GitOps |
|---|---|---|
| Build images | Excellent | Not its purpose |
| Security scanning | Excellent | Not its purpose |
| Deploy to Kubernetes | Yes | Yes |
| Continuous reconciliation | No | Yes |
| Drift detection | Limited | Native |
| Self-healing | No | Yes |
| Git as desired state | Optional | Core principle |
| Deployment audit trail | Pipeline logs | Git + Argo CD |
| Pull-based deployment | No | Yes |
| Kubernetes health view | Limited | Excellent |
| Rollback | Pipeline-dependent | Git revision / Argo CD |
| Separation of CI/CD | Limited | Strong |

---

# 🎯 Interview Questions & Answers

## 1. What is GitOps?

**Answer:**

GitOps is an operational model where Git stores the declarative desired state of infrastructure and applications, and an automated controller continuously reconciles the live environment against that state.

In this project, GitHub stores the Helm chart and Argo CD Application definition, while Argo CD reconciles Amazon EKS.

---

## 2. Why did you introduce Argo CD?

**Answer:**

Previously, deployment could be performed directly from CI using Helm. Project 47 introduces a dedicated GitOps CD controller.

Argo CD continuously monitors Git and compares the desired state with Kubernetes. This gives us automated synchronization, drift detection, and self-healing.

---

## 3. What is the difference between push-based and pull-based deployment?

**Answer:**

In a push model, the CI system actively connects to Kubernetes and pushes changes.

```text
CI → Kubernetes
```

In a pull-based GitOps model, Argo CD runs inside the cluster and pulls desired state from Git.

```text
Git → Argo CD → Kubernetes
```

Pull-based deployment reduces the need for CI runners to have direct deployment credentials and allows continuous reconciliation.

---

## 4. Why is Git the source of truth?

**Answer:**

Git provides versioning, history, review, auditability, rollback, and peer review.

Instead of asking:

> "What was manually changed in the cluster?"

we can inspect Git and determine the intended state.

---

## 5. What happens if someone manually changes Kubernetes?

**Answer:**

Argo CD detects the difference between Git and the live cluster.

If automated sync and self-healing are enabled, Argo CD reconciles the cluster back to the Git-defined state.

We demonstrated exactly this by changing Project 38 from two replicas to one.

---

## 6. What is drift?

**Answer:**

Drift occurs when the live Kubernetes state differs from the declarative desired state stored in Git.

Example:

```text
Git:
replicas = 2

Kubernetes:
replicas = 1
```

That is configuration drift.

---

## 7. What is self-healing in Argo CD?

**Answer:**

Self-healing means Argo CD automatically restores live resources when they are modified outside the desired Git state.

It is enabled with:

```yaml
syncPolicy:
  automated:
    selfHeal: true
```

---

## 8. What is the purpose of `prune: true`?

**Answer:**

Pruning allows Argo CD to remove Kubernetes resources that are no longer defined in the Git desired state.

Without pruning, resources deleted from Git could remain in the cluster.

---

## 9. What does `Synced` mean?

**Answer:**

`Synced` means the live Kubernetes resources match the desired state represented by the Argo CD Application source.

It does not by itself mean the application is healthy.

---

## 10. What does `Healthy` mean?

**Answer:**

`Healthy` represents Argo CD's assessment of the health of the managed Kubernetes resources.

An application can theoretically be:

```text
Synced + Unhealthy
```

because desired state and health are different concepts.

---

## 11. Can an application be `Synced` but unhealthy?

**Answer:**

Yes.

For example, Git may correctly specify a Deployment with two replicas, but the pods could be crash-looping.

The configuration matches Git:

```text
Synced
```

but the workload isn't functioning:

```text
Unhealthy
```

---

## 12. What does `in-cluster` mean in Argo CD?

**Answer:**

`in-cluster` means Argo CD is targeting the Kubernetes cluster in which Argo CD itself is running.

In this project:

```text
Argo CD
   ↓
ci-cd-mastery-eks
```

The Application destination is:

```text
https://kubernetes.default.svc
```

which is the Kubernetes API service address available inside the cluster.

---

## 13. Is `in-cluster` a separate cluster?

**Answer:**

No.

It is a logical destination label used by Argo CD for the local Kubernetes cluster.

---

## 14. Why did you use Helm with Argo CD?

**Answer:**

Helm provides reusable templates and parameterization.

Argo CD provides continuous reconciliation.

Using both gives us:

```text
Helm → package/template
Argo CD → reconcile
Kubernetes → execute
```

---

## 15. Why did you modify the Helm chart?

**Answer:**

The original chart supported:

```text
repository:tag
```

but Project 47 required immutable image deployment using an ECR digest.

The chart was modified to support:

```text
repository@sha256:digest
```

while retaining backward compatibility with tag-based deployments when no digest is supplied.

---

## 16. Why are image digests better than tags?

**Answer:**

Tags can be mutable.

A digest identifies the exact image content.

For example:

```text
image:app:1.0
```

can potentially be repointed.

Whereas:

```text
image:app@sha256:abc...
```

identifies a specific content-addressed image.

---

## 17. Does using a digest eliminate all supply-chain risk?

**Answer:**

No.

It provides immutability and reproducibility of the referenced image content, but it does not by itself prove that the image is trustworthy.

A stronger supply-chain process should combine:

- Image scanning
- SBOM
- Signing
- Attestation
- Provenance
- Trusted registries
- Admission policies

Project 47 consumes the immutable artifact produced by the preceding security/supply-chain work.

---

## 18. Why shouldn't CI directly deploy to EKS in a GitOps model?

**Answer:**

CI should ideally focus on producing and validating artifacts.

Argo CD should own continuous deployment and reconciliation.

This reduces the need for CI runners to maintain direct long-lived deployment access and gives Kubernetes a dedicated reconciliation controller.

---

## 19. Does Argo CD replace GitHub Actions?

**Answer:**

No.

They have different responsibilities.

GitHub Actions:

```text
CI
Build
Test
Scan
Package
Sign
Publish
```

Argo CD:

```text
CD
Reconcile
Deploy
Detect drift
Self-heal
```

They complement each other.

---

## 20. What happens if Argo CD is temporarily unavailable?

**Answer:**

Existing Kubernetes workloads continue running because Kubernetes does not require Argo CD for the pods to continue executing.

However, new Git changes and drift reconciliation cannot be processed until Argo CD becomes available again.

This is an important distinction:

> Argo CD is the reconciliation controller, not the runtime for the application itself.

---

## 21. What happens if GitHub is temporarily unavailable?

**Answer:**

Existing workloads continue running with their current Kubernetes state.

Argo CD may continue operating with cached information depending on the situation, but it cannot reliably discover new desired-state changes from Git until repository access is restored.

---

## 22. How would you rollback?

**Answer:**

The preferred GitOps rollback is to revert Git to a known-good revision.

For example:

```text
Git commit A
   ↓
Deployment A

Git commit B
   ↓
Deployment B

Rollback:
Git revert B
   ↓
Argo CD
   ↓
Deployment A
```

This keeps the rollback auditable.

---

## 23. How would you handle multiple environments?

**Answer:**

A common pattern is environment-specific Git configuration combined with reusable Helm charts.

For example:

```text
GitOps/
├── dev/
├── staging/
└── production/
```

or:

```text
applications/
├── project-38-dev
├── project-38-staging
└── project-38-prod
```

Each Argo CD Application can point to the appropriate environment configuration.

---

## 24. What is an Argo CD Application?

**Answer:**

An Argo CD Application is a Kubernetes custom resource describing:

- Git source
- Revision
- Path
- Helm/Kustomize configuration
- Kubernetes destination
- Synchronization policy

It tells Argo CD:

> "Take this desired state from this Git location and reconcile it into this Kubernetes destination."

---

## 25. What is the Argo CD Application Controller?

**Answer:**

The Application Controller is responsible for monitoring Applications and reconciling desired state against live Kubernetes resources.

It is one of the core components responsible for the GitOps control loop.

---

## 26. What does the repo-server do?

**Answer:**

The repository server retrieves Git content and generates manifests using tools such as Helm and Kustomize.

In this project it:

```text
GitHub
  ↓
Helm chart
  ↓
Rendered Kubernetes manifests
```

---

## 27. What caused the initial Argo CD Git error?

**Answer:**

The Application initially referenced:

```text
project-47-gitops-argocd
```

before that branch existed on the remote GitHub repository.

Argo CD therefore could not resolve the revision to a commit SHA.

Once the branch was pushed:

```text
git push -u origin project-47-gitops-argocd
```

Argo CD could fetch and render it.

This is a good example of why GitOps requires the desired state to actually exist in the configured remote repository.

---

## 28. What caused the ApplicationSet CRD installation issue?

**Answer:**

The initial installation using client-side `kubectl apply` failed for:

```text
applicationsets.argoproj.io
```

because the generated `kubectl.kubernetes.io/last-applied-configuration` annotation exceeded Kubernetes' annotation-size limit.

Server-side apply successfully installed the CRD without relying on that oversized client-side annotation.

---

## 29. Why did you not create another EKS cluster?

**Answer:**

The existing enterprise EKS cluster was already healthy and was explicitly part of the platform established by previous projects.

Creating another cluster would:

- Increase cost
- Duplicate infrastructure
- Reduce architectural continuity
- Add unnecessary complexity

Project 47 focuses on GitOps, not cluster provisioning.

---

## 30. How would you secure Argo CD in production?

**Answer:**

I would consider:

- SSO/OIDC integration
- RBAC
- Least-privilege AppProjects
- TLS
- Network restrictions
- Private access where appropriate
- Secrets management
- Repository credential protection
- Audit logging
- Network policies
- Restricted Kubernetes permissions
- Image admission policies
- Signed artifact verification

The lab intentionally kept Argo CD internal and accessed it with `kubectl port-forward`.

---

## 31. What is the difference between Argo CD and Argo Rollouts?

**Answer:**

Argo CD is primarily a GitOps continuous delivery and reconciliation controller.

Argo Rollouts focuses on advanced progressive delivery such as:

- Canary deployments
- Blue/green deployments
- Traffic shifting
- Automated rollout analysis

They can be used together.

---

## 32. What is GitOps reconciliation?

**Answer:**

Reconciliation is the continuous process of comparing:

```text
Desired state
```

against:

```text
Live state
```

and taking corrective action when they differ.

Conceptually:

```text
desired != live
       ↓
calculate difference
       ↓
apply correction
       ↓
desired == live
```

---

## 33. Why is declarative configuration important?

**Answer:**

Declarative configuration describes the desired outcome rather than a sequence of imperative commands.

Instead of:

```bash
kubectl scale ...
kubectl set image ...
kubectl patch ...
```

we define:

```yaml
replicas: 2
image: repository@sha256:digest
```

and let the controller reconcile toward that state.

---

## 34. What would you monitor in an enterprise Argo CD deployment?

**Answer:**

I would monitor:

- Application sync status
- Application health
- Sync failures
- Reconciliation latency
- Repo-server errors
- Application-controller errors
- Git repository availability
- Kubernetes API errors
- Deployment health
- Pod health
- Argo CD resource usage
- Authentication failures
- Audit events

---

## 35. How would you prevent developers from bypassing GitOps?

**Answer:**

In production, I would combine:

- Kubernetes RBAC
- Restricted direct write permissions
- Separate service accounts
- Admission policies
- Namespace-level controls
- AppProject restrictions
- Git branch protection
- Pull request approvals
- Audit logging

The objective is to make Git the normal and controlled deployment path.

---

# 🧑‍💼 60-Second Interview Explanation

If an interviewer asks:

> **"Explain Project 47."**

Use this answer:

> "In Project 47 I introduced GitOps continuous delivery into my existing AWS EKS platform using Argo CD. Previously, deployment could be performed from CI using Helm. I moved the deployment responsibility to Argo CD, while GitHub became the source of truth for the desired Kubernetes state. Argo CD runs inside the EKS cluster and continuously reconciles the Git state with Kubernetes. I reused the existing Project 38 Helm chart and enhanced it to support immutable ECR image digests. The application is deployed using a SHA-256 digest rather than a mutable tag. I enabled automated synchronization, pruning, and self-healing. As a validation exercise, I intentionally scaled the live deployment from two replicas to one. Argo CD detected the drift and automatically restored the deployment to two replicas. So the project demonstrates not just deployment automation, but continuous reconciliation and self-healing in Kubernetes."

---

# 🧠 Senior-Level Interview Talking Points

When answering interviews, emphasize these concepts rather than simply saying:

> "I installed Argo CD."

Talk about:

### 1. Reconciliation

```text
Desired state → Live state → Difference → Correction
```

### 2. Separation of concerns

```text
CI → Build/Test/Security/Artifact
CD → GitOps/Reconciliation
```

### 3. Immutable artifacts

```text
tag → digest
```

### 4. Auditability

```text
Git commit → deployment revision
```

### 5. Drift management

```text
Manual Kubernetes change → detected → corrected
```

### 6. Security

```text
No unnecessary public Argo CD endpoint
+
immutable image
+
Git-controlled desired state
```

---

# 🏆 Project 47 Outcome

The project successfully demonstrates an enterprise-style GitOps control loop:

```text
             ┌───────────────┐
             │    GitHub     │
             │               │
             │ Desired State │
             └───────┬───────┘
                     │
                     ▼
             ┌───────────────┐
             │    Argo CD    │
             │               │
             │  Reconcile    │
             │  Sync         │
             │  Self-Heal    │
             └───────┬───────┘
                     │
                     ▼
             ┌───────────────┐
             │   Amazon EKS  │
             │               │
             │  project-38   │
             └───────┬───────┘
                     │
                     ▼
             ┌───────────────┐
             │   Amazon ECR  │
             │               │
             │ SHA256 Image  │
             └───────────────┘
```

### Final verified state

```text
Argo CD Application:       project-38-gitops
Sync:                       Synced
Health:                     Healthy
Kubernetes cluster:         ci-cd-mastery-eks
Application namespace:      project-38
Replicas:                   2/2
Image:                      Immutable SHA-256 digest
Automated sync:             Enabled
Prune:                      Enabled
Self-heal:                  Enabled
Drift test:                 Passed
```

---

# 🚀 Future Production Enhancements

Project 47 establishes the GitOps foundation. A production implementation could extend it with:

```text
Argo CD
├── AppProjects / RBAC
├── SSO / OIDC
├── ApplicationSet
├── Multi-environment promotion
├── Progressive delivery
├── Argo Rollouts
├── Image Updater
├── Policy enforcement
├── Signed-image verification
├── Admission control
├── Notifications
└── Observability
```

The important architectural principle remains:

> **CI produces trusted artifacts. Git declares the desired state. Argo CD continuously reconciles that state into Kubernetes.**
