# PROJECT 48 --- Progressive Delivery with Argo Rollouts

## Executive Summary

Project 48 introduces **progressive delivery** into the CI/CD Mastery
platform. Project 47 established Argo CD GitOps; Project 48 adds **Argo
Rollouts Canary deployments** on Amazon EKS.

The final architecture is:

``` text
Developer
   |
   v
Git Push
   |
   v
GitHub Actions
   |
   +--> Docker Build
   +--> Trivy Scan
   +--> ECR Push
   +--> Immutable SHA256 Digest
   |
   v
Git Repository / GitOps
   |
   v
Argo CD
   |
   v
Argo Rollouts
   |
   +--> 10%
   +--> 25%
   +--> 50%
   +--> 100%
   |
   v
Amazon EKS
```

**Key design principle:** CI creates and verifies artifacts; GitOps
controls desired state; Argo Rollouts controls progressive release
execution.

------------------------------------------------------------------------

## Roadmap Position

``` text
36 Helm Packaging
37 Immutable ECR
38 EKS Application Platform
39 EKS Pod Identity
40 Enterprise EKS CI/CD
41 Secret Scanning
42 Filesystem + Dependency Security
43 Kubernetes Network Security
44 Kubernetes RBAC
45 Cosign Image Signing
46 SBOM + Supply-Chain Attestation
47 GitOps
48 Progressive Delivery  <-- THIS PROJECT
49 Observability
50 Autoscaling
51 Disaster Recovery
52+ Production Platform Engineering
```

------------------------------------------------------------------------

## Objectives

-   Install and validate Argo Rollouts on EKS.
-   Convert the Project 38 Helm Deployment into an Argo Rollout.
-   Implement Canary progressive delivery.
-   Maintain stable and canary Services.
-   Deploy immutable ECR image digests.
-   Integrate Argo Rollouts with Argo CD GitOps.
-   Create a dedicated Project 48 GitHub Actions CI workflow.
-   Use AWS GitHub OIDC instead of long-lived AWS credentials.
-   Scan Version B with Trivy.
-   Verify the pushed ECR digest.
-   Diagnose real implementation failures.
-   Establish the foundation for automated rollout analysis in Project
    49.

------------------------------------------------------------------------

## Environment

  Component               Value
  ----------------------- -----------------------------------
  AWS Region              `ap-south-1`
  EKS Cluster             `ci-cd-mastery-eks`
  Kubernetes              `1.34`
  Repository              `Ashish420-tech/CI-CD-mastery`
  Branch                  `project-48-progressive-delivery`
  Application             `project-38`
  Application Namespace   `project-38`
  Argo CD Namespace       `argocd`
  Rollouts Namespace      `argo-rollouts`
  ECR Repository          `ci-cd-mastery/applications`

------------------------------------------------------------------------

# 1. Baseline

Before Project 48, Project 38 was deployed as a normal Kubernetes
Deployment:

``` text
Deployment: project-38
Replicas:   2
Health:     Running
Argo CD:    Synced / Healthy
```

Stable image:

``` text
742820980479.dkr.ecr.ap-south-1.amazonaws.com/ci-cd-mastery/applications@sha256:90e4b7e35b5b4c2644550dbc08c1ca257d37453874aeb06f8b585241884ed98f
```

The baseline was captured before introducing progressive delivery so
that the release had a known-good Version A.

------------------------------------------------------------------------

# 2. Argo Rollouts Installation

Initial pre-check:

``` text
argo-rollouts namespace does not exist
Argo Rollouts CRDs not installed
Argo Rollouts controller not installed
```

After installation, the following CRDs were present:

``` text
analysisruns.argoproj.io
analysistemplates.argoproj.io
clusteranalysistemplates.argoproj.io
experiments.argoproj.io
rollouts.argoproj.io
```

Controller:

``` text
deployment.apps/argo-rollouts
```

Pod:

``` text
argo-rollouts-5d88c6c7c7-pwr5l
```

Final controller status:

``` text
1/1 Running
```

Validation:

``` bash
kubectl get crd | grep argoproj.io
kubectl get deployment -n argo-rollouts
kubectl get pods -n argo-rollouts -o wide
```

------------------------------------------------------------------------

# 3. Helm Chart Conversion

The original Project 38 Deployment template was disabled:

``` text
templates/deployment.yaml.project-47-disabled
```

The chart gained:

``` text
templates/rollout.yaml
templates/service-canary.yaml
```

The stable Service remains:

``` text
project-38
```

The new canary Service is:

``` text
project-38-canary
```

This lets Argo Rollouts distinguish stable and canary workloads.

------------------------------------------------------------------------

# 4. Canary Strategy

The Rollout uses:

``` yaml
strategy:
  canary:
    stableService: project-38
    canaryService: project-38-canary

    steps:
      - setWeight: 10
      - pause: {}
      - setWeight: 25
      - pause: {}
      - setWeight: 50
      - pause: {}
      - setWeight: 100
```

Release progression:

``` text
Version A
   |
   v
10% Version B
   |
   v
Pause
   |
   v
25% Version B
   |
   v
Pause
   |
   v
50% Version B
   |
   v
Pause
   |
   v
100% Version B
```

The final successful rollout reported:

``` text
Status:       Healthy
Strategy:     Canary
Step:         7/7
SetWeight:    100
ActualWeight: 100
Desired:      2
Current:      2
Ready:        2
Available:    2
```

Conditions included:

``` text
RolloutCompleted
RolloutHealthy
NewReplicaSetAvailable
AvailableReason
```

------------------------------------------------------------------------

# 5. Immutable Image Design

The Helm chart supports both tag and digest forms:

``` yaml
image:
  repository: ...
  tag: "1.0.0"
  digest: ""
```

The template uses the digest when supplied:

``` yaml
image: "{{ .Values.image.repository }}{{ if .Values.image.digest }}@{{ .Values.image.digest }}{{ else }}:{{ .Values.image.tag }}{{ end }}"
```

Rendered immutable image:

``` text
repository@sha256:<digest>
```

Why?

Tags can move. A digest identifies exact image content.

``` text
Git SHA
   |
   v
ECR image
   |
   v
SHA256 digest
   |
   v
GitOps
   |
   v
Exact artifact
```

------------------------------------------------------------------------

# 6. Helm Validation

The chart was validated using:

``` bash
helm lint project-38-eks-application-platform/chart/project-38-app
```

Result:

``` text
1 chart(s) linted, 0 chart(s) failed
```

Rendered output was also checked for the immutable image:

``` text
742820980479.dkr.ecr.ap-south-1.amazonaws.com/ci-cd-mastery/applications@sha256:90e4...
```

Server-side Kubernetes validation:

``` bash
kubectl apply   --dry-run=server   -f /tmp/project-48-rendered.yaml
```

Validated resources included:

``` text
configmap/project-38-config
service/project-38-canary
service/project-38
rollout.argoproj.io/project-38
```

------------------------------------------------------------------------

# 7. Argo CD Integration

Project 47's Argo CD Application originally referenced:

``` text
project-47-gitops-argocd
```

Project 48 changed the desired Git revision to:

``` text
project-48-progressive-delivery
```

The Application eventually reconciled successfully:

``` text
project-38-gitops
SYNC STATUS:   Synced
HEALTH STATUS: Healthy
```

Architecture:

``` text
Git
 |
 v
Argo CD
 |
 v
Rollout CR
 |
 v
Argo Rollouts
 |
 v
EKS
```

------------------------------------------------------------------------

# 8. Argo Rollouts CLI

The initial command:

``` bash
kubectl argo
```

failed because the plugin was not installed:

``` text
unknown command "argo" for "kubectl"
```

The plugin was then installed and reported:

``` text
kubectl-argo-rollouts: v1.9.1+b6bd3bc
```

Useful commands:

``` bash
kubectl argo rollouts version
kubectl argo rollouts get rollout project-38 -n project-38
kubectl argo rollouts history rollout/project-38 -n project-38
kubectl argo rollouts promote project-38 -n project-38
kubectl argo rollouts abort project-38 -n project-38
kubectl argo rollouts undo project-38 -n project-38
```

------------------------------------------------------------------------

# 9. Version B

The application was changed from:

``` python
deployment="helm"
```

to:

``` python
deployment="helm-progressive"
```

This made Version B distinguishable at application level.

Version B commit:

``` text
52af2be feat(project-48): create progressive delivery version
```

The Project 48 CI workflow was then added to build and push Version B.

------------------------------------------------------------------------

# 10. Project 48 CI

Workflow:

``` text
.github/workflows/project-48-progressive-delivery.yml
```

It calls:

``` text
.github/workflows/reusable-build-push.yml
```

Pipeline:

``` text
Checkout
   |
Setup Buildx
   |
AWS OIDC
   |
ECR Login
   |
Docker Build
   |
Trivy Image Scan
   |
ECR Push
   |
Digest Verification
```

The workflow intentionally does **not** execute:

``` text
kubectl apply
helm upgrade
```

or:

``` text
reusable-eks-deploy.yml
```

because deployment is owned by GitOps.

------------------------------------------------------------------------

# 11. Why CI Does Not Deploy

The desired separation is:

``` text
CI
 |
 +--> Build
 +--> Scan
 +--> Push
 +--> Digest
 |
 v
Artifact
```

and:

``` text
Git
 |
 v
Argo CD
 |
 v
Argo Rollouts
 |
 v
EKS
```

Direct deployment from GitHub Actions would bypass the GitOps control
plane.

This is an important interview-level design decision.

------------------------------------------------------------------------

# 12. Failure History

## Failure 1 --- Argo Rollouts Missing

### Symptom

``` text
namespace does not exist
CRDs not installed
controller not installed
```

### Root Cause

Argo Rollouts had never been installed on the EKS cluster.

### Fix

Install Argo Rollouts and verify the CRDs, controller Deployment and
Pod.

### Lesson

Always establish controller/CRD prerequisites before applying custom
resources.

------------------------------------------------------------------------

## Failure 2 --- Helm YAML Parse Error

### Symptom

``` text
unable to parse YAML
did not find expected comment or line break
```

### Root Cause

The multiline Helm conditional inside the `image` YAML value produced
invalid rendered YAML.

### Fix

Use one valid quoted Helm expression:

``` yaml
image: "{{ .Values.image.repository }}{{ if .Values.image.digest }}@{{ .Values.image.digest }}{{ else }}:{{ .Values.image.tag }}{{ end }}"
```

### Lesson

Always run:

``` bash
helm lint
helm template
kubectl apply --dry-run=server
```

before a live deployment.

------------------------------------------------------------------------

## Failure 3 --- Argo CD Branch Resolution

### Symptom

``` text
ComparisonError
unable to resolve 'project-47-gitops-argocd' to a commit SHA
```

### Root Cause

Argo CD could not resolve the referenced Git revision.

### Fix

Push the branch/commit and allow Argo CD to reconcile against an
existing remote revision.

### Lesson

Argo CD requires the configured Git revision to exist and be reachable.

------------------------------------------------------------------------

## Failure 4 --- Existing Deployment Instead of Rollout

### Symptom

The cluster still showed:

``` text
deployment.apps/project-38
```

and:

``` text
Rollout not created yet
```

### Root Cause

The GitOps Application was still pointing at the Project 47 revision.

### Fix

Update the live Application target revision to:

``` text
project-48-progressive-delivery
```

Then wait for Argo CD reconciliation.

### Result

The Rollout was created and became Healthy.

------------------------------------------------------------------------

## Failure 5 --- `kubectl argo` Unknown Command

### Symptom

``` text
unknown command "argo" for "kubectl"
```

### Root Cause

The kubectl plugin was missing.

### Fix

Install:

``` text
kubectl-argo-rollouts
```

### Lesson

The Argo Rollouts CRD/controller does not automatically install the
local kubectl plugin.

------------------------------------------------------------------------

## Failure 6 --- Version B Not Found in ECR

### Symptom

An ECR lookup using:

``` text
52af2be
```

returned:

``` text
ImageNotFoundException
```

### Root Cause

There was initially no dedicated Project 48 CI pipeline that pushed
Version B to ECR.

Existing workflows ran, but they were not the required artifact
pipeline.

### Fix

Create:

``` text
project-48-progressive-delivery.yml
```

using the existing reusable build/push workflow.

### Lesson

A Git commit existing in GitHub does not imply that a corresponding ECR
artifact exists.

------------------------------------------------------------------------

## Failure 7 --- GitHub OIDC Authorization

### Symptom

The first Project 48 CI run failed at:

``` text
Configure AWS through GitHub OIDC
```

with:

``` text
Could not assume role with OIDC:
Not authorized to perform sts:AssumeRoleWithWebIdentity
```

### Root Cause

The IAM trust policy for:

``` text
GitHubActionsEnterpriseCapstoneRole
```

allowed previous project branches but did not include:

``` text
project-48-progressive-delivery
```

### Fix

Add the exact Project 48 GitHub OIDC subject to:

``` text
token.actions.githubusercontent.com:sub
```

### Security principle

Do not solve OIDC problems by creating access keys or allowing every
branch.

Use a narrow trust relationship.

------------------------------------------------------------------------

## Failure 8 --- Misleading `gh run list`

A generic:

``` bash
gh run list
```

showed workflows such as:

``` text
Project 03
Project 06
Project 07
Project 22
```

These were not necessarily the Project 48 pipeline.

### Correct command

``` bash
gh run list   --workflow=project-48-progressive-delivery.yml   --branch project-48-progressive-delivery   --limit 5
```

### Lesson

When troubleshooting CI, filter by the exact workflow and branch.

------------------------------------------------------------------------

# 13. Successful CI

After fixing IAM OIDC, the Project 48 workflow completed successfully:

``` text
Project 48 - Progressive Delivery
SUCCESS
```

The successful path was:

``` text
AWS OIDC       PASS
ECR Login      PASS
Docker Build   PASS
Trivy Scan     PASS
ECR Push       PASS
Digest Verify  PASS
```

This completed the Version B artifact pipeline.

------------------------------------------------------------------------

# 14. Final Rollout State

Final Rollout:

``` text
Name:            project-38
Namespace:       project-38
Status:          Healthy
Strategy:        Canary
Step:            7/7
SetWeight:       100
ActualWeight:    100
```

Replicas:

``` text
Desired:     2
Current:     2
Updated:     2
Ready:       2
Available:   2
```

ReplicaSet:

``` text
project-38-74b7fd875b
```

Pods:

``` text
project-38-74b7fd875b-gdt94
project-38-74b7fd875b-x96wg
```

Both were:

``` text
1/1 Running
```

Services:

``` text
project-38
project-38-canary
```

------------------------------------------------------------------------

# 15. Verification Commands

## Argo CD

``` bash
kubectl get application project-38-gitops -n argocd
```

Expected:

``` text
Synced
Healthy
```

## Rollout

``` bash
kubectl get rollout project-38 -n project-38
```

## Detailed Rollout

``` bash
kubectl argo rollouts get rollout   project-38   -n project-38
```

## Pods

``` bash
kubectl get pods -n project-38 -o wide
```

## ReplicaSets

``` bash
kubectl get rs -n project-38
```

## Services

``` bash
kubectl get svc -n project-38
```

## EKS

``` bash
aws eks describe-cluster   --name ci-cd-mastery-eks   --region ap-south-1
```

## Project 48 CI

``` bash
gh run list   --workflow=project-48-progressive-delivery.yml   --branch project-48-progressive-delivery   --limit 5
```

------------------------------------------------------------------------

# 16. Operational Rollback

For an emergency rollout abort:

``` bash
kubectl argo rollouts abort   project-38   -n project-38
```

For promotion:

``` bash
kubectl argo rollouts promote   project-38   -n project-38
```

For GitOps rollback, the preferred approach is to revert the Git commit:

``` text
Git revert
   |
   v
Argo CD
   |
   v
Argo Rollouts
   |
   v
Known-good version
```

This keeps Git as the source of truth.

------------------------------------------------------------------------

# 17. Rolling Update vs Canary

  -----------------------------------------------------------------------
  Capability              Kubernetes              Argo Rollouts Canary
                          RollingUpdate           
  ----------------------- ----------------------- -----------------------
  Gradual Pod replacement Yes                     Yes

  Explicit release stages Limited                 Yes

  Traffic weighting       Limited                 Yes

  Pause between stages    No native rollout       Yes
                          stages                  

  Stable/canary Services  No                      Yes

  Automated analysis      Limited                 Yes

  Abort/promotion         Basic deployment        Native Rollouts
                          operations              workflow

  Progressive delivery    Basic                   Advanced
  -----------------------------------------------------------------------

------------------------------------------------------------------------

# 18. Canary vs Blue-Green

Canary:

``` text
A 90% / B 10%
A 75% / B 25%
A 50% / B 50%
A 0%  / B 100%
```

Blue-Green:

``` text
Blue 100%
Green 0%

switch

Blue 0%
Green 100%
```

Canary is better for gradual exposure.

Blue-Green is better for rapid environment-level cutover and rollback.

------------------------------------------------------------------------

# 19. Interview Questions and Answers

## Q1. What is progressive delivery?

Progressive delivery is a controlled method of releasing a new version
gradually instead of exposing it to 100% of users immediately. Canary
and blue-green are common strategies.

Project 48 uses Argo Rollouts Canary.

------------------------------------------------------------------------

## Q2. Why use Argo Rollouts instead of Kubernetes Deployment?

A normal Deployment provides rolling updates. Argo Rollouts adds
progressive delivery capabilities such as canary steps, weighted
exposure, pause/resume, analysis, promotion and abort.

------------------------------------------------------------------------

## Q3. What is a Rollout?

A Rollout is an Argo Rollouts custom resource that extends Kubernetes
deployment behavior with advanced release strategies.

------------------------------------------------------------------------

## Q4. What is a Canary deployment?

A Canary deployment sends a controlled portion of traffic/workload to
the new version while the old version remains stable.

Example:

``` text
90% A
10% B
```

then:

``` text
75% A
25% B
```

and so on.

------------------------------------------------------------------------

## Q5. Why use `project-38` and `project-38-canary` Services?

They provide stable and canary endpoints that Argo Rollouts can manage
during progressive delivery.

------------------------------------------------------------------------

## Q6. Why use pauses?

Pauses create observation windows so operators or automated analysis can
determine whether it is safe to continue.

------------------------------------------------------------------------

## Q7. What happens if Version B fails at 25%?

The rollout can be paused or aborted. The stable version remains the
known-good release, reducing blast radius.

------------------------------------------------------------------------

## Q8. What does Argo CD do?

Argo CD reconciles Kubernetes state with the Git repository. It is the
GitOps control plane.

------------------------------------------------------------------------

## Q9. What does Argo Rollouts do?

Argo Rollouts controls the actual progressive release strategy after the
desired Rollout object is present in Kubernetes.

------------------------------------------------------------------------

## Q10. Why not deploy directly from GitHub Actions?

Direct `kubectl`/Helm deployment would bypass the GitOps control plane.
Project 48 intentionally separates CI from CD.

------------------------------------------------------------------------

## Q11. Why use immutable image digests?

A tag can be changed to point to another image. A SHA256 digest
identifies exact image content.

This improves reproducibility, auditability and rollback.

------------------------------------------------------------------------

## Q12. Why use AWS OIDC?

GitHub Actions obtains short-lived AWS credentials through an IAM trust
relationship instead of storing long-lived AWS access keys.

------------------------------------------------------------------------

## Q13. Why did the OIDC authentication fail?

The IAM trust policy did not authorize the Project 48 branch subject.
The branch was added to the `sub` condition.

------------------------------------------------------------------------

## Q14. What is the OIDC `sub` claim?

It identifies the GitHub workflow identity, allowing AWS IAM to restrict
which repository/branch can assume a role.

------------------------------------------------------------------------

## Q15. Why was `52af2be` missing in ECR?

Because a Git commit existed without a Project 48 artifact pipeline that
built and pushed the corresponding ECR image.

------------------------------------------------------------------------

## Q16. How do you debug an unhealthy Rollout?

Start with:

``` bash
kubectl argo rollouts get rollout project-38 -n project-38
kubectl describe rollout project-38 -n project-38
kubectl get rs -n project-38
kubectl get pods -n project-38
kubectl describe pod <pod> -n project-38
kubectl logs <pod> -n project-38
kubectl get events -n project-38 --sort-by=.lastTimestamp
```

------------------------------------------------------------------------

## Q17. How do you know a rollout succeeded?

Check:

``` text
Healthy
Step 7/7
ActualWeight 100
Ready replicas = desired replicas
Available replicas = desired replicas
```

and conditions such as:

``` text
RolloutCompleted
RolloutHealthy
AvailableReason
```

------------------------------------------------------------------------

## Q18. How would you automate rollback?

Use Argo Rollouts AnalysisTemplates connected to metrics from Prometheus
or another monitoring system.

Concept:

``` text
10%
 |
 v
Analyze
 |
 +--> success -> 25%
 |
 +--> failure -> abort
```

------------------------------------------------------------------------

## Q19. Why is observability required for progressive delivery?

Without metrics, the platform cannot reliably determine whether Version
B is better or worse.

Project 49 should provide metrics for automated analysis.

------------------------------------------------------------------------

## Q20. How does Project 48 lead into Project 49?

Project 48 provides the release mechanism. Project 49 provides the
telemetry required to make automated release decisions.

``` text
Canary
 +
Metrics
 =
Automated Progressive Delivery
```

------------------------------------------------------------------------

## Q21. What is the difference between Sync and Health in Argo CD?

`Synced` means the live resource state matches the desired Git state.

`Healthy` describes whether the application/resources are operating
correctly.

They are related but not identical.

------------------------------------------------------------------------

## Q22. How would you perform a GitOps rollback?

Revert the Git change that introduced the bad image/configuration and
allow Argo CD to reconcile.

This preserves Git as the source of truth.

------------------------------------------------------------------------

## Q23. What would you add for production?

I would add:

-   Prometheus metrics
-   Grafana dashboards
-   Argo Rollouts AnalysisTemplates
-   Automated promotion/abort
-   Alerting
-   OpenTelemetry
-   SLO-based release gates
-   Cosign verification
-   SBOM verification
-   Policy enforcement
-   Automated rollback

------------------------------------------------------------------------

# 20. Senior Interview Answer

A strong interview explanation:

> "I implemented progressive delivery on Amazon EKS using Argo Rollouts
> integrated with Argo CD GitOps. I converted an existing Helm-managed
> Deployment into a Canary Rollout with stable and canary Services and
> progressive exposure of 10%, 25%, 50% and 100%. The CI pipeline builds
> Version B, scans it with Trivy, pushes it to ECR using GitHub OIDC and
> verifies the immutable SHA256 digest. Argo CD remains the deployment
> control plane, while Argo Rollouts manages release progression. During
> implementation I diagnosed a real OIDC failure caused by the Project
> 48 branch being absent from the IAM trust policy and fixed it with
> branch-scoped authorization. The final rollout reached 100% and
> reported Healthy with all replicas available."

------------------------------------------------------------------------

# 21. Production Architecture

``` text
                    GitHub
                       |
                       v
              GitHub Actions CI
                       |
              +--------+--------+
              |                 |
              v                 v
          Docker Build      Trivy Scan
              |                 |
              +--------+--------+
                       |
                       v
                   Amazon ECR
                       |
                Immutable Digest
                       |
                       v
                  Git Repository
                       |
                       v
                    Argo CD
                       |
                       v
                Argo Rollouts
                       |
              +--------+--------+
              |                 |
              v                 v
          Stable Service    Canary Service
              |                 |
              +--------+--------+
                       |
                       v
                    EKS
                       |
          10% -> 25% -> 50% -> 100%
```

------------------------------------------------------------------------

# 22. Future Production Enhancement

Project 49 should connect observability to the Rollout:

``` text
Argo Rollouts
      |
      v
AnalysisTemplate
      |
      v
Prometheus
      |
      +--> Error Rate
      +--> Latency
      +--> Availability
      +--> Saturation
      |
      v
Promotion Decision
```

Possible result:

``` text
10%
 |
 v
Error rate < 1%?
 |
 +-- NO --> Abort
 |
 +-- YES
       |
       v
25%
 |
 v
Latency OK?
 |
 +-- NO --> Abort
 |
 +-- YES
       |
       v
50%
 |
 v
100%
```

This is the transition from manual progressive delivery to an automated
production release platform.

------------------------------------------------------------------------

# 23. Completion Checklist

``` text
[x] EKS baseline validated
[x] Argo Rollouts installed
[x] Rollout CRDs validated
[x] Rollouts controller Running
[x] Helm chart converted
[x] Canary Service created
[x] Immutable digest support added
[x] Helm lint passed
[x] Helm template passed
[x] Kubernetes server dry-run passed
[x] Argo CD Application updated
[x] GitOps reconciliation succeeded
[x] Project 48 CI created
[x] Version B application change created
[x] AWS OIDC failure diagnosed
[x] IAM trust policy fixed
[x] Project 48 CI succeeded
[x] ECR artifact produced
[x] Immutable digest verified
[x] Canary rollout completed
[x] 100% rollout reached
[x] Rollout Healthy
[x] EKS Pods Ready
```

------------------------------------------------------------------------

# 24. Final Status

``` text
PROJECT 48 — PROGRESSIVE DELIVERY

Argo Rollouts:        PASS
Helm:                 PASS
GitOps:               PASS
AWS OIDC:             PASS
GitHub Actions:       PASS
ECR:                  PASS
Trivy:                PASS
Immutable Image:      PASS
Canary Strategy:      PASS
Rollout:              PASS
Final Weight:         100%
Rollout Health:       HEALTHY
EKS:                  HEALTHY
```

------------------------------------------------------------------------

## Project 48 takeaway

The most important lesson is not the Argo Rollouts YAML.

It is the platform architecture:

``` text
Build safely
    |
Verify the artifact
    |
Store it immutably
    |
Declare desired state in Git
    |
Reconcile with Argo CD
    |
Release progressively with Argo Rollouts
    |
Measure the release
    |
Promote or abort
```

That architecture is the foundation for the next stage of the roadmap:
**Project 49 --- Observability**.
