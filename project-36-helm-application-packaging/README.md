# Project 36 — Helm Application Packaging & CI/CD

Production-style Kubernetes application packaging and deployment using **Helm, Docker, Amazon ECR, Amazon EKS, GitHub Actions, OIDC, and Trivy**.

This project extends Project 35 by replacing raw Kubernetes manifests and `kubectl`-based application deployment with a **versioned Helm chart and Helm release lifecycle**.

---

## 🚀 Project Overview

The objective of Project 36 is to implement a reusable Kubernetes deployment model using Helm and integrate it into a complete CI/CD pipeline.

The pipeline performs:

1. Application testing
2. Helm chart validation
3. Helm template rendering
4. Docker image build
5. Container vulnerability scanning
6. AWS authentication using GitHub OIDC
7. Image push to Amazon ECR
8. EKS authentication
9. Helm release deployment
10. Kubernetes rollout verification
11. Internal Kubernetes smoke testing

---

## 🏗️ Architecture

```text
Developer
    |
    | git push
    v
+----------------------+
|      GitHub           |
|   CI/CD Repository    |
+----------+-----------+
           |
           v
+----------------------+
|   GitHub Actions     |
+----------+-----------+
           |
     +-----+-----+
     |           |
     v           v
  Pytest      Helm Lint
     |           |
     +-----+-----+
           |
           v
    Docker Build
           |
           v
    +-------------+
    |    Trivy    |
    | Security    |
    |   Scan      |
    +------+------+
           |
           v
   GitHub OIDC
           |
           v
+----------------------+
| AWS IAM Role         |
| GitHubActions...Role |
+----------+-----------+
           |
           +----------------+
           |                |
           v                v
      Amazon ECR       Amazon EKS
           |                |
           |          Helm Release
           |                |
           +--------+-------+
                    |
                    v
             Kubernetes
             Application
                    |
                    v
              Smoke Test
🧰 Technologies Used
Technology	Purpose
Python 3.12	Application
Flask	HTTP application
Docker	Containerization
Kubernetes	Container orchestration
Helm 3.19.2	Application packaging
Amazon ECR	Container registry
Amazon EKS	Kubernetes platform
GitHub Actions	CI/CD
GitHub OIDC	Passwordless AWS authentication
AWS IAM	CI/CD authorization
Trivy	Container security scanning
Pytest	Automated testing
PyYAML	YAML validation
📁 Project Structure
project-36-helm-application-packaging/
│
├── app/
│   ├── app.py
│   ├── Dockerfile
│   ├── requirements.txt
│   └── .dockerignore
│
├── chart/
│   └── project-36-app/
│       ├── Chart.yaml
│       ├── values.yaml
│       │
│       └── templates/
│           ├── _helpers.tpl
│           ├── configmap.yaml
│           ├── deployment.yaml
│           └── service.yaml
│
├── tests/
│   └── test_helm.py
│
├── .gitignore
└── README.md
🐍 Application

The application is a small Flask service designed specifically for Kubernetes deployment.

Endpoints
/

Returns application metadata.

Example:

{
  "application": "project-36-helm-app",
  "version": "1.0.0",
  "environment": "production",
  "deployment": "helm"
}
/health

Used by the Kubernetes liveness probe.

{
  "status": "healthy"
}
/ready

Used by the Kubernetes readiness probe.

{
  "status": "ready"
}
🐳 Docker Design

The application uses:

python:3.12-slim

The image follows container security best practices.

Security characteristics
Dedicated non-root user
UID 10001
Minimal Python base image
No unnecessary packages
Application-owned filesystem
Dependency installation without pip cache
Docker build context restricted with .dockerignore

Example:

RUN useradd \
    --create-home \
    --uid 10001 \
    --shell /usr/sbin/nologin \
    appuser

The Kubernetes deployment additionally enforces:

runAsNonRoot: true
runAsUser: 10001
allowPrivilegeEscalation: false

and drops Linux capabilities:

capabilities:
  drop:
    - ALL
⎈ Helm Chart

The application is packaged as a Helm chart:

chart/project-36-app/

Helm replaces hard-coded Kubernetes deployment configuration with reusable templates and values.

Helm Resources

The chart creates:

ConfigMap
Service
Deployment

The namespace is intentionally managed outside the Helm chart.

This avoids Helm ownership conflicts when the namespace already exists.

⚙️ Helm Values

The chart supports configurable values such as:

replicaCount: 2

image:
  repository: project-36-helm-app
  tag: latest
  pullPolicy: IfNotPresent

Application configuration is also configurable:

app:
  environment: production
  version: "1.0.0"

This allows the same chart to be reused across environments.

For example:

Development
Staging
Production

without modifying Kubernetes templates.

🔐 Kubernetes Security

The deployment implements several Kubernetes security controls.

Non-root execution
runAsNonRoot: true
runAsUser: 10001
Disable privilege escalation
allowPrivilegeEscalation: false
Drop capabilities
capabilities:
  drop:
    - ALL
Seccomp
seccompProfile:
  type: RuntimeDefault
Disable automatic ServiceAccount token mounting
automountServiceAccountToken: false

These controls reduce the container's attack surface.

❤️ Health Checks

Kubernetes readiness and liveness probes are configured.

Readiness
readinessProbe:
  httpGet:
    path: /ready
    port: http

Readiness determines whether the application should receive traffic.

Liveness
livenessProbe:
  httpGet:
    path: /health
    port: http

Liveness determines whether Kubernetes should restart the container.

📊 Resource Management

The application defines CPU and memory requests/limits.

Example:

resources:
  requests:
    cpu: 100m
    memory: 128Mi

  limits:
    cpu: 500m
    memory: 256Mi

This improves scheduling predictability and prevents unrestricted resource consumption.

🔄 CI/CD Pipeline

Workflow:

Push
 |
 v
Application & Helm Tests
 |
 v
Helm Validation
 |
 v
Docker Build + Trivy
 |
 v
AWS OIDC
 |
 v
ECR Push
 |
 v
EKS Authentication
 |
 v
Helm Upgrade/Install
 |
 v
Helm Release Verification
 |
 v
Kubernetes Rollout
 |
 v
Kubernetes Smoke Test
 |
 v
SUCCESS

Workflow file:

.github/workflows/project-36-helm-cicd.yml
🧪 Stage 1 — Application and Helm Tests

The pipeline installs Python dependencies and executes:

pytest -q project-36-helm-application-packaging/tests

Local result:

4 passed

The tests verify the expected Helm chart structure and application configuration.

⎈ Stage 2 — Helm Validation

The pipeline executes:

helm lint chart/project-36-app

and:

helm template project-36 chart/project-36-app

It also packages the chart.

This catches:

Invalid Helm syntax
Template errors
Missing chart metadata
Invalid Kubernetes rendering
Incorrect values
Broken template references
🐳 Stage 3 — Docker Build

The pipeline builds the application image:

docker build \
  -t project-36-helm-app:${GITHUB_SHA} \
  project-36-helm-application-packaging/app

The Git commit SHA is used as the image tag.

Example:

project-36-helm-app:
241e84c53eb54d09bb4510ef583f418896d213b0

This provides immutable image identification.

🛡️ Stage 4 — Trivy Security Scan

The image is scanned using:

aquasecurity/trivy-action

The pipeline scans for:

HIGH
CRITICAL

vulnerabilities.

Unfixed vulnerabilities are ignored according to the project's CI policy.

The objective is to prevent vulnerable container images from progressing through the deployment pipeline.

🔑 Stage 5 — GitHub OIDC Authentication

The workflow does not store AWS access keys.

GitHub Actions receives an OIDC token and assumes:

GitHubActionsEnterpriseCapstoneRole

The workflow uses:

permissions:
  contents: read
  id-token: write

and:

- uses: aws-actions/configure-aws-credentials@v4

with:

role-to-assume: ${{ secrets.AWS_ROLE_ARN }}

This implements short-lived AWS credentials instead of static credentials.

☁️ AWS Architecture
GitHub Actions
      |
      | OIDC
      v
AWS IAM
      |
      | AssumeRoleWithWebIdentity
      v
GitHubActionsEnterpriseCapstoneRole
      |
      +----------------+
      |                |
      v                v
     ECR              EKS
📦 Stage 6 — Amazon ECR

The image is pushed to:

ci-cd-mastery/applications

Registry:

742820980479.dkr.ecr.ap-south-1.amazonaws.com

Image format:

<registry>/<repository>:<git-sha>

Example:

742820980479.dkr.ecr.ap-south-1.amazonaws.com/
ci-cd-mastery/applications:
<commit-sha>

This provides immutable deployment artifacts.

☸️ Stage 7 — EKS Authentication

The pipeline configures Kubernetes access using:

aws eks update-kubeconfig \
  --region ap-south-1 \
  --name ci-cd-mastery-eks

The GitHub Actions IAM role has an EKS Access Entry with:

Type:
STANDARD

and:

AmazonEKSClusterAdminPolicy

associated at cluster scope.

This allows GitHub Actions to deploy workloads to EKS.

⎈ Stage 8 — Helm Deployment

The deployment uses:

helm upgrade --install

Example:

helm upgrade --install "$RELEASE_NAME" "$CHART_PATH" \
  --namespace "$NAMESPACE" \
  --create-namespace \
  --set image.repository="${IMAGE%:*}" \
  --set image.tag="${GITHUB_SHA}" \
  --set image.pullPolicy=IfNotPresent \
  --wait \
  --timeout 180s

Release:

project-36

Namespace:

project-36

This provides idempotent deployment behavior.

🔁 Why helm upgrade --install?

The command supports both cases:

First deployment
Release does not exist
        |
        v
Install
Existing deployment
Release exists
        |
        v
Upgrade

This makes it suitable for CI/CD pipelines.

🔍 Stage 9 — Helm Release Verification

The pipeline verifies the Helm release after deployment.

This ensures that Helm successfully created and managed the expected resources.

🚦 Stage 10 — Kubernetes Rollout Verification

The pipeline waits for the Deployment to become ready:

kubectl rollout status \
  deployment/project-36 \
  -n "$NAMESPACE" \
  --timeout=180s

Then it collects:

kubectl get deployment
kubectl get pods
kubectl get service
kubectl get endpoints

This prevents the pipeline from declaring success before the workload is actually running.

🧪 Stage 11 — Kubernetes Smoke Test

The pipeline launches a temporary curl pod inside the cluster:

kubectl run project-36-smoke \
  -n "$NAMESPACE" \
  --rm \
  -i \
  --restart=Never \
  --image=curlimages/curl:8.12.1 \
  -- \
  curl -fsS \
  http://project-36.$NAMESPACE.svc.cluster.local/health

The request travels through Kubernetes DNS and the ClusterIP Service.

Smoke Pod
    |
    v
project-36 Service
    |
    v
project-36 Deployment
    |
    v
Flask Container
    |
    v
/health

If the endpoint returns HTTP success, the CI/CD pipeline passes.

🧩 Problems Faced and Solutions

Project 36 intentionally exposed several real-world CI/CD problems.

Problem 1 — Helm Namespace Ownership Conflict

Initial deployment failed:

namespaces "project-36" already exists
Root Cause

The Helm chart contained:

templates/namespace.yaml

while the namespace already existed in the cluster.

Helm attempted to create/manage a namespace that was not owned by the Helm release.

Solution

The namespace template was removed from the chart.

The namespace is now created using:

helm upgrade --install ... --create-namespace
Lesson

Namespaces can be managed independently from application resources.

Problem 2 — Inconsistent Helm Resource Names

Initial Helm resources generated names such as:

project-36-project-36-app

This caused CI/CD references to become inconsistent.

For example:

Deployment/project-36-project-36-app
Service/project-36-project-36-app

while the intended release-level resource naming was:

project-36
Solution

The Helm _helpers.tpl naming logic was normalized.

Final rendered resources became:

ConfigMap/project-36-config
Service/project-36
Deployment/project-36
Lesson

Helm naming conventions should be designed before writing CI verification logic.

Problem 3 — Rollout Verification Used Old Deployment Name

Helm successfully deployed the application, but CI failed with:

deployments.apps "project-36-project-36-app" not found
Root Cause

The Helm chart had been corrected, but the workflow still referenced the old Deployment name.

Solution

The workflow was changed to:

kubectl rollout status \
  deployment/project-36 \
  -n "$NAMESPACE"
Lesson

Changing Helm resource naming requires updating every downstream CI/CD reference.

Problem 4 — Smoke Test Used Old Service DNS

After rollout succeeded, the smoke test failed:

Could not resolve host:
project-36-project-36-app.project-36.svc.cluster.local
Root Cause

The Service had been renamed to:

project-36

but the smoke test still used the old DNS name.

Correct DNS
project-36.project-36.svc.cluster.local
Final command
curl -fsS \
  http://project-36.$NAMESPACE.svc.cluster.local/health
Lesson

Kubernetes Service DNS follows:

<service>.<namespace>.svc.cluster.local
Problem 5 — GitHub Actions Node.js Warning

GitHub Actions displayed:

Node.js 20 is being deprecated.
Important

This was a warning, not a pipeline failure.

The workflow successfully completed.

GitHub Actions is transitioning actions toward newer Node.js runtimes.

Lesson

Do not confuse GitHub Actions runtime warnings with actual CI/CD failures.

Problem 6 — AWS OIDC Authentication

Project 35 exposed an AWS OIDC trust-policy issue that was carried into Project 36.

The final solution involved:

GitHub OIDC Provider
        +
IAM Trust Policy
        +
AWS_ROLE_ARN
        +
EKS Access Entry
        +
EKS Access Policy

The resulting Project 36 pipeline successfully authenticated to AWS.

Problem 7 — EKS Authorization

AWS authentication alone was not sufficient.

The IAM role also required authorization inside EKS.

The role was configured as an EKS Access Entry:

GitHubActionsEnterpriseCapstoneRole

with:

AmazonEKSClusterAdminPolicy

at cluster scope.

Lesson

There are two separate security layers:

IAM Authentication
        +
EKS Authorization

Successfully assuming an AWS role does not automatically mean that Kubernetes will authorize the identity.

📈 Final CI/CD Result

Final GitHub Actions pipeline:

┌───────────────────────────────┐
│ Application and Helm Tests    │ ✅
└───────────────┬───────────────┘
                │
┌───────────────▼───────────────┐
│ Helm Validation               │ ✅
└───────────────┬───────────────┘
                │
┌───────────────▼───────────────┐
│ Build and Security Scan       │ ✅
└───────────────┬───────────────┘
                │
┌───────────────▼───────────────┐
│ Deploy Helm Release to EKS    │ ✅
│                               │
│ OIDC                  ✅      │
│ ECR                   ✅      │
│ EKS Authentication    ✅      │
│ Helm Deployment       ✅      │
│ Release Verification  ✅      │
│ Rollout Verification  ✅      │
│ Smoke Test            ✅      │
└───────────────────────────────┘
✅ Validation Performed
Python tests
python3 -m pytest -q

Result:

4 passed
Helm lint
helm lint chart/project-36-app

Result:

1 chart(s) linted, 0 chart(s) failed
Helm rendering
helm template project-36 chart/project-36-app

Result:

ConfigMap/project-36-config
Service/project-36
Deployment/project-36
Docker build
docker build \
  -t project-36-helm-app:local \
  ./app

Result:

Successfully built
GitHub Actions

Final pipeline:

SUCCESS
🔐 Security Practices Demonstrated

This project demonstrates:

GitHub OIDC authentication
No long-lived AWS credentials in workflow YAML
IAM role-based authorization
EKS Access Entries
EKS access policies
Immutable image tags
Trivy vulnerability scanning
Non-root containers
Linux capability dropping
Seccomp RuntimeDefault
Disabled privilege escalation
Disabled automatic ServiceAccount token mounting
Kubernetes resource requests/limits
Readiness probes
Liveness probes
Private Kubernetes Service communication
💼 Enterprise DevOps Concepts Demonstrated

Project 36 demonstrates practical understanding of:

Helm
Helm templating
Helm releases
Helm upgrade/install
Helm values
Helm naming conventions
Kubernetes Services
Kubernetes DNS
Kubernetes Deployments
Kubernetes probes
Container security
ECR
EKS
IAM
GitHub OIDC
GitHub Actions
CI/CD
Immutable artifacts
Trivy
Deployment verification
Smoke testing
🎯 Interview Questions
1. Why use Helm instead of raw Kubernetes YAML?

Helm provides:

Templating
Parameterization
Reusable application packages
Versioned releases
Upgrade/rollback capabilities
Environment-specific configuration
2. What is a Helm release?

A Helm release is an installed instance of a Helm chart in a Kubernetes cluster.

Example:

Chart:
project-36-app

Release:
project-36
3. What does helm upgrade --install do?

It installs the release if it doesn't exist and upgrades it if it already exists.

This makes it useful for idempotent CI/CD deployments.

4. Why should namespaces sometimes be managed outside Helm?

Namespaces often have a lifecycle independent of a specific application release.

Managing an existing namespace inside Helm can create ownership conflicts.

5. What caused the namespace error?

The chart attempted to create:

project-36

while that namespace already existed outside the Helm release.

6. What is _helpers.tpl?

_helpers.tpl contains reusable Helm template helpers.

It is commonly used for:

Resource naming
Labels
Selectors
Common metadata
7. How does Kubernetes Service DNS work?

The standard internal DNS format is:

<service>.<namespace>.svc.cluster.local

For Project 36:

project-36.project-36.svc.cluster.local
8. Why use a Kubernetes smoke test instead of testing from the GitHub runner?

The GitHub runner is outside the Kubernetes cluster.

The smoke-test pod runs inside the cluster and verifies:

DNS
Service
Endpoints
Pod
Application

as an actual cluster-internal client would experience them.

9. What is the difference between readiness and liveness probes?
Readiness

Determines whether the Pod should receive traffic.

Liveness

Determines whether Kubernetes should restart the container.

10. Why use immutable image tags?

Using:

GITHUB_SHA

means every image maps to a specific source revision.

This improves:

Traceability
Rollbacks
Auditing
Reproducibility
11. Why use GitHub OIDC?

OIDC eliminates the need for long-lived AWS access keys in GitHub secrets.

GitHub obtains a short-lived identity token and AWS STS exchanges it for temporary credentials.

12. Is OIDC authentication enough for EKS?

No.

Two authorization layers are involved:

GitHub
   |
   v
AWS IAM
   |
   v
EKS Access Entry / Policy
   |
   v
Kubernetes API

The role must be authorized by EKS.

13. What is the advantage of EKS Access Entries?

They provide an AWS-managed mechanism for associating IAM identities with EKS cluster permissions.

This reduces dependence on manually maintaining the legacy aws-auth ConfigMap.

14. Why scan the image with Trivy before deployment?

To detect known vulnerabilities before an image reaches the Kubernetes environment.

A production pipeline can block deployment when critical security thresholds are exceeded.

15. Why run as a non-root user?

If the application is compromised, running as a non-root user reduces the potential impact of container compromise.

16. Why drop Linux capabilities?

Linux capabilities provide privileged kernel-level functionality.

Dropping unnecessary capabilities reduces the container attack surface.

17. Why disable allowPrivilegeEscalation?

It prevents a process from gaining additional privileges through mechanisms such as setuid/setgid binaries.

18. Why disable ServiceAccount token mounting?

The application does not need Kubernetes API credentials.

Therefore:

automountServiceAccountToken: false

reduces unnecessary credential exposure.

19. What happens if Helm deployment succeeds but rollout fails?

The Helm command may successfully create/update resources, but the application itself may not become healthy.

Typical causes include:

ImagePullBackOff
CrashLoopBackOff
Failed readiness probe
Insufficient resources
Invalid configuration
Application startup failure
20. How would you rollback a failed Helm deployment?

Use:

helm history project-36 -n project-36

then:

helm rollback project-36 <REVISION> -n project-36
🧠 Senior-Level Interview Questions
Q1. How would you make this Helm deployment production-grade?

Expected discussion:

Separate values per environment
External secrets
PodDisruptionBudget
HorizontalPodAutoscaler
NetworkPolicies
Resource quotas
RBAC
Pod security standards
Image signing
SBOM
Admission control
Progressive delivery
Canary/blue-green deployment
Observability
Automated rollback
Q2. How would you prevent a compromised GitHub repository from gaining excessive AWS permissions?

Use:

Least-privilege IAM
Restricted OIDC subject claims
Environment protection rules
Required reviewers
Short-lived credentials
Separate roles per environment
Restricted EKS access
Branch protection
Q3. Why is AmazonEKSClusterAdminPolicy not ideal for production CI/CD?

Because it grants excessive permissions.

A production pipeline should use a narrowly scoped EKS access policy and Kubernetes permissions appropriate to the application's namespace.

Q4. How would you implement zero-downtime Helm deployments?

Use:

RollingUpdate
Readiness probes
Multiple replicas
PodDisruptionBudget
Proper resource requests
Graceful shutdown
Deployment strategy
Q5. How would you deploy the same chart to dev, staging and production?

Use environment-specific values:

values-dev.yaml
values-staging.yaml
values-production.yaml

For example:

helm upgrade --install project-36 ./chart/project-36-app \
  -f values-production.yaml
Q6. How would you implement automatic rollback?

Use Helm deployment monitoring plus CI/CD failure detection.

For example:

helm upgrade --install ... --wait --atomic

--atomic can automatically roll back when an upgrade fails.

Q7. How would you improve supply-chain security?

Introduce:

Trivy
SBOM
Cosign
Image signing
Provenance
SLSA
Dependency scanning
Secret scanning
Admission policies
📌 Key Takeaways

Project 36 upgrades the deployment architecture from:

Raw Kubernetes YAML
        |
        v
kubectl apply

to:

Helm Chart
    |
    v
Helm Release
    |
    v
EKS

while maintaining:

Automated Testing
       +
Security Scanning
       +
OIDC Authentication
       +
Immutable ECR Images
       +
Automated EKS Deployment
       +
Rollout Verification
       +
Cluster Smoke Testing
🏆 Project Status
PROJECT 36 — COMPLETE ✅

Application Tests       ✅
Helm Tests              ✅
Helm Lint               ✅
Helm Template           ✅
Docker Build            ✅
Trivy Scan              ✅
GitHub OIDC             ✅
ECR Push                ✅
EKS Authentication     ✅
Helm Deployment         ✅
Helm Verification       ✅
Kubernetes Rollout      ✅
Service Discovery       ✅
Smoke Test              ✅
GitHub Actions          ✅
🔗 Related Projects
Project 34

Kubernetes Configuration and Secrets

Project 35

Kubernetes CI/CD

Project 36

Helm Application Packaging & CI/CD

The progression is:

Project 34
     |
     v
Kubernetes Configuration
     |
     v
Project 35
     |
     v
Raw Kubernetes CI/CD
     |
     v
Project 36
     |
     v
Helm-based Kubernetes CI/CD
👨‍💻 Author

Ashish Mondal

DevOps & Cloud Engineer

Focus Areas:

AWS
Kubernetes
EKS
Docker
Terraform
Helm
GitHub Actions
CI/CD
DevSecOps
Cloud Infrastructure
⭐ Final Result

This project demonstrates a complete enterprise-style deployment lifecycle:

CODE
  ↓
TEST
  ↓
HELM VALIDATE
  ↓
BUILD
  ↓
SECURITY SCAN
  ↓
OIDC
  ↓
ECR
  ↓
EKS
  ↓
HELM RELEASE
  ↓
ROLLOUT
  ↓
SMOKE TEST
  ↓
PRODUCTION-STYLE CI/CD ✅

### One important cleanup

Your GitHub screenshot shows **4 warnings**, all related to GitHub Actions actions transitioning away from Node.js 20. These are **not Project 36 failures**; the run itself is successful.

So I recommend **not changing the working pipeline just to remove those warnings** befo
