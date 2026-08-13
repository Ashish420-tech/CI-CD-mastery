Project 35 — Kubernetes CI/CD with GitHub Actions, ECR and EKS

Production-style Kubernetes CI/CD pipeline using GitHub Actions, Docker, Amazon ECR, Amazon EKS, Terraform-managed EKS access, GitHub OIDC and Trivy.

This project demonstrates a complete software delivery path:

Developer
    │
    │ git push
    ▼
GitHub Repository
    │
    ▼
GitHub Actions
    │
    ├── Test
    │
    ├── Kubernetes Manifest Validation
    │
    ├── Docker Build
    │
    ├── Trivy Security Scan
    │
    ├── GitHub OIDC
    │
    ├── AWS IAM
    │
    ├── Amazon ECR
    │
    ├── Amazon EKS Authentication
    │
    ├── Kubernetes Deployment
    │
    ├── Rollout Verification
    │
    └── Application Smoke Test
    │
    ▼
Running Application on EKS
🎯 Project Objective

The objective of Project 35 is to implement a real CI/CD pipeline that builds, scans, publishes and deploys a containerized application to Amazon EKS.

The project focuses on the complete delivery lifecycle rather than simply creating a GitHub Actions YAML file.

The pipeline must:

run automated tests
validate Kubernetes manifests
build a Docker image
scan the image with Trivy
authenticate to AWS without static AWS credentials
use GitHub OIDC
push the image to Amazon ECR
authenticate to Amazon EKS
deploy Kubernetes resources
verify the rollout
verify application health
🧠 What This Project Teaches

Project 35 connects several concepts that are frequently separated during learning.

Development
Python application
pytest
Docker
non-root container execution
CI
GitHub Actions
automated testing
YAML validation
Docker builds
DevSecOps
Trivy container scanning
vulnerability thresholds
immutable image tags
AWS
IAM
GitHub OIDC
STS AssumeRoleWithWebIdentity
Amazon ECR
Amazon EKS
Kubernetes
Namespace
Deployment
Service
readiness probe
liveness probe
rollout verification
Infrastructure as Code
Terraform
EKS Access Entries
EKS access policies
🏗️ Architecture
                         Developer
                            │
                            │ git push
                            ▼
                    ┌─────────────────┐
                    │     GitHub      │
                    │  CI-CD-mastery  │
                    └────────┬────────┘
                             │
                             ▼
                  ┌──────────────────────┐
                  │   GitHub Actions     │
                  │                      │
                  │  1. Test             │
                  │  2. YAML Validation  │
                  │  3. Docker Build     │
                  │  4. Trivy Scan       │
                  └──────────┬───────────┘
                             │
                             │ OIDC
                             ▼
                  ┌──────────────────────┐
                  │      AWS IAM         │
                  │                      │
                  │ GitHub OIDC Provider │
                  │          │           │
                  │          ▼           │
                  │ GitHubActions        │
                  │ EnterpriseRole       │
                  └──────────┬───────────┘
                             │
               ┌─────────────┴──────────────┐
               │                            │
               ▼                            ▼
        ┌──────────────┐            ┌──────────────┐
        │     ECR      │            │     EKS      │
        │              │            │              │
        │ Docker Image │            │ Kubernetes   │
        │ Repository   │            │ API          │
        └──────┬───────┘            └──────┬───────┘
               │                           │
               │                           ▼
               │                    ┌──────────────┐
               │                    │  Namespace   │
               │                    │  project-35  │
               │                    └──────┬───────┘
               │                           │
               │                           ▼
               │                    ┌──────────────┐
               │                    │  Deployment  │
               │                    │  2 replicas  │
               │                    └──────┬───────┘
               │                           │
               │                           ▼
               │                    ┌──────────────┐
               └───────────────────►│   Service    │
                                    │  ClusterIP   │
                                    └──────────────┘
🔐 Authentication Architecture

One of the most important lessons from this project is that GitHub Actions does not automatically have access to AWS or Kubernetes.

The authentication chain is:

GitHub Actions
      │
      │ OIDC token
      ▼
token.actions.githubusercontent.com
      │
      ▼
AWS IAM OIDC Provider
      │
      ▼
GitHubActionsEnterpriseCapstoneRole
      │
      ├──────────────► Amazon ECR
      │
      └──────────────► Amazon EKS
                              │
                              ▼
                    EKS Access Entry
                              │
                              ▼
              AmazonEKSClusterAdminPolicy

This creates two separate authorization layers.

Layer 1 — AWS IAM

GitHub must be allowed to assume the IAM role.

Layer 2 — EKS authorization

The IAM role must also be authorized inside EKS.

Having AWS permissions alone does not automatically grant Kubernetes API access.

🔑 GitHub OIDC

Static AWS credentials were intentionally avoided.

The workflow uses:

permissions:
  contents: read
  id-token: write

AWS authentication uses:

- name: Configure AWS through GitHub OIDC
  uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
    aws-region: ${{ env.AWS_REGION }}

The GitHub Actions runner receives a short-lived OIDC token.

AWS STS validates that token and issues temporary credentials.

This avoids storing:

AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY

as long-lived GitHub secrets.

🔐 Immutable GitHub OIDC Subject

A major real-world issue occurred because the repository was newly created in August 2026.

The repository identity was:

Repository:
Ashish420-tech/CI-CD-mastery

Owner ID:
100117629

Repository ID:
1329535358

The IAM trust relationship therefore had to use the repository's immutable GitHub OIDC subject.

The final trust condition was:

repo:Ashish420-tech@100117629/CI-CD-mastery@1329535358:ref:refs/heads/project-35-kubernetes-cicd

This was significantly more restrictive than simply trusting:

repo:Ashish420-tech/CI-CD-mastery:*
☁️ AWS Environment
Region:
ap-south-1

EKS Cluster:
ci-cd-mastery-eks

Kubernetes:
1.34

ECR Repository:
ci-cd-mastery/applications

EKS was reused from the existing CI/CD Mastery platform.

The cluster was not recreated for Project 35.

This is important because Project 35 is an application delivery project rather than an infrastructure recreation project.

☸️ Kubernetes Environment

Namespace:

project-35

Application:

project-35-gateway

Deployment:

project-35-gateway

Service:

project-35-gateway

The Deployment uses two replicas.

📁 Project Structure
project-35-kubernetes-cicd/
│
├── app/
│   ├── Dockerfile
│   ├── app.py
│   └── requirements.txt
│
├── k8s/
│   ├── namespace.yml
│   ├── deployment.yml
│   └── service.yml
│
├── tests/
│   └── test_cicd.py
│
├── .gitignore
│
└── README.md

The GitHub Actions workflow is intentionally located at repository level:

.github/
└── workflows/
    └── project-35-cicd.yml

This is required because GitHub discovers Actions workflows from:

.github/workflows/

at the repository root.

🐳 Docker

The application uses:

python:3.12-slim

The container creates a dedicated user:

UID 10001

The application does not run as root.

Build:

docker build \
  -t project-35-local \
  project-35-kubernetes-cicd/app

The CI pipeline uses the commit SHA as the image tag:

project-35-gateway:<GITHUB_SHA>

This is preferable to using:

latest

because every deployment can be mapped to an exact Git commit.

🧪 Automated Testing

Project tests are executed with:

python3 -m pytest -q

Verified result:

5 passed

The tests verify important CI/CD properties including:

workflow exists
GitHub OIDC is configured
static AWS credentials are not embedded
Kubernetes security context is configured
health probes exist
☸️ Kubernetes Manifest Validation

GitHub-hosted runners do not automatically have access to the EKS cluster.

An initial implementation attempted:

kubectl apply --dry-run=client

without a Kubernetes context.

That caused:

localhost:8080
connection refused

Even:

--validate=false

did not solve the problem because kubectl apply still attempted API interaction.

The final CI validation therefore performs offline YAML/structure validation.

Actual Kubernetes API validation happens during the authenticated EKS deployment stage.

This creates a clean separation:

CI runner
    │
    ▼
Offline manifest validation

then:

Authenticated EKS
    │
    ▼
Real Kubernetes API validation
🔍 Trivy Container Security

The pipeline scans the built image using Trivy.

The image is scanned for:

vulnerabilities
secrets
high severity findings
critical severity findings

The pipeline is configured to fail when the configured security threshold is exceeded.

This means security is part of the delivery gate rather than an optional manual step.

🚀 CI/CD Pipeline

The workflow contains four major jobs.

Test
 │
 ├───────────────┐
 │               │
 ▼               ▼
Manifest       Build &
Validation     Security Scan
 │               │
 └───────┬───────┘
         ▼
    Deploy to EKS
1. Test

The test job:

checkout
   ↓
setup Python
   ↓
install dependencies
   ↓
pytest
2. Kubernetes Manifest Validation

The validation job:

checkout
   ↓
setup Python
   ↓
install PyYAML
   ↓
parse Kubernetes YAML
   ↓
verify required fields

Required fields include:

apiVersion
kind
metadata
3. Build and Security Scan

The build job:

Docker build
     ↓
Trivy scan
     ↓
Security gate

The image is tagged with the Git commit SHA.

4. Deploy to EKS

The deployment job:

GitHub OIDC
     ↓
AWS IAM
     ↓
ECR login
     ↓
Docker build
     ↓
ECR push
     ↓
aws eks update-kubeconfig
     ↓
kubectl apply
     ↓
rollout status
     ↓
health verification
📦 ECR

The ECR repository is:

742820980479.dkr.ecr.ap-south-1.amazonaws.com/ci-cd-mastery/applications

The pipeline pushes the immutable SHA-tagged image.

Example:

742820980479.dkr.ecr.ap-south-1.amazonaws.com/ci-cd-mastery/applications:<commit-sha>
☸️ EKS Deployment

The workflow configures the cluster:

aws eks update-kubeconfig \
  --region ap-south-1 \
  --name ci-cd-mastery-eks

Then deploys:

kubectl apply \
  -f project-35-kubernetes-cicd/k8s/namespace.yml

The Deployment image placeholder is replaced with the actual ECR image.

Then:

kubectl apply \
  -f project-35-kubernetes-cicd/k8s/service.yml
🔐 EKS Access Entry

This was one of the most important infrastructure lessons.

Initially:

aws eks update-kubeconfig

worked.

But:

kubectl apply

failed with:

the server has asked for the client to provide credentials

The reason was not:

ECR
OIDC
IAM role assumption
kubeconfig generation

The actual problem was:

GitHubActionsEnterpriseCapstoneRole

was not present in the EKS access entries.

Existing access entries included:

devops-user
system-eks-node-group...
AWSServiceRoleForAmazonEKS

but not the GitHub Actions role.

🛠️ Durable EKS Fix

The EKS cluster uses:

authenticationMode = API_AND_CONFIG_MAP

Terraform was updated to create:

access_entries = {
  github_actions = {
    principal_arn = "arn:aws:iam::742820980479:role/GitHubActionsEnterpriseCapstoneRole"

    policy_associations = {
      admin = {
        policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

        access_scope = {
          type = "cluster"
        }
      }
    }
  }
}

Terraform then created:

aws_eks_access_entry

and:

aws_eks_access_policy_association

This avoids manually changing EKS access and leaving infrastructure drift.

⚠️ Important Security Note

For this learning project, the GitHub role received:

AmazonEKSClusterAdminPolicy

at:

cluster

scope.

This was chosen to get the CI/CD pipeline operational while demonstrating EKS access management.

For a production enterprise implementation, this should be reduced.

A stronger design would use:

GitHub Actions IAM Role
        │
        ▼
EKS Access Entry
        │
        ▼
Least-privilege EKS policy
        │
        ▼
Specific namespace / workload permissions

For example:

project-35

rather than the entire cluster.

🧯 Problems Encountered and Root-Cause Analysis

This section is intentionally detailed because these are the most valuable interview lessons from Project 35.

Problem 1 — Workflow Not Found
Error
HTTP 404:
workflow file location wrong
Root Cause

The workflow was initially being treated as though it belonged inside:

project-35-kubernetes-cicd/.github/workflows/

GitHub Actions requires workflows at:

.github/workflows/

at repository root.

Fix

Moved workflow to:

.github/workflows/project-35-cicd.yml
Lesson

GitHub Actions workflow discovery is repository-level.

Problem 2 — Incorrect Relative Paths
Error
error: the path "k8s/namespace.yml" does not exist
Root Cause

The workflow ran from repository root.

The Kubernetes files were actually:

project-35-kubernetes-cicd/k8s/
Fix

Changed:

k8s/namespace.yml

to:

project-35-kubernetes-cicd/k8s/namespace.yml

The same correction was made for:

deployment.yml
service.yml
Dockerfile
requirements.txt
tests
Lesson

Always design CI paths relative to the GitHub runner's working directory.

Problem 3 — Local pytest Could Not Find Workflow
Error
FileNotFoundError:
project-35-kubernetes-cicd/.github/workflows/project-35-cicd.yml
Root Cause

The test expected the workflow inside the project directory.

But GitHub's correct workflow location is repository root.

Fix

Tests were updated to resolve:

repository/.github/workflows/project-35-cicd.yml

while project-specific files remain under:

project-35-kubernetes-cicd/
Lesson

Application tests must understand repository structure, not impose an incorrect structure.

Problem 4 — kubectl --dry-run=client Tried localhost
Error
failed to download openapi

http://localhost:8080

connection refused
Root Cause

GitHub-hosted runners do not have the user's local Kubernetes context.

kubectl attempted to use a nonexistent local API server.

First Attempt
kubectl apply --dry-run=client

failed.

Second Attempt
kubectl apply --dry-run=client --validate=false

also failed because kubectl apply still attempted server/API discovery.

Final Fix

Offline YAML validation was implemented with Python/PyYAML.

Actual Kubernetes validation occurs after:

aws eks update-kubeconfig

in the deployment job.

Lesson

Never assume:

local kubectl context == GitHub runner kubectl context
Problem 5 — Invalid Trivy Action Version
Error
Unable to resolve action
aquasecurity/trivy-action@0.33.1

A second invalid tag was also attempted:

aquasecurity/trivy-action@0.28.0
Root Cause

The workflow referenced tags that were not available in the action repository.

Fix

Pinned the workflow to:

aquasecurity/trivy-action@v0.36.0
Lesson

CI dependencies are production dependencies.

Never invent action versions.

Verify the actual release/tag before pinning it.

Problem 6 — Trivy Received Invalid Image Name
Error
failed to parse the image name

$IMAGE_NAME:<sha>
Root Cause

The workflow passed:

image-ref: "$IMAGE_NAME:${{ github.sha }}"

to an action.

$IMAGE_NAME is a shell variable.

But the with: section of a GitHub Action is not a shell script.

Therefore $IMAGE_NAME remained literal.

Fix

Used the actual GitHub Actions expression/value:

image-ref: "project-35-gateway:${{ github.sha }}"
Lesson

Understand the difference between:

Shell expansion

and:

GitHub Actions expression evaluation
Problem 7 — GitHub OIDC AssumeRole Failure
Error
Not authorized to perform sts:AssumeRoleWithWebIdentity
Root Cause

The IAM role originally trusted:

repo:Ashish420-tech/aws-enterprise-capstone:*

while Project 35 runs from:

Ashish420-tech/CI-CD-mastery
Fix

Updated the IAM trust policy.

However, the newly created repository introduced another important detail.

Problem 8 — Immutable GitHub OIDC Subject
Discovery

The repository was created:

2026-08-10

Repository ID:

1329535358

Owner ID:

100117629

The trust relationship therefore had to match the immutable repository identity.

Final subject:

repo:Ashish420-tech@100117629/CI-CD-mastery@1329535358:ref:refs/heads/project-35-kubernetes-cicd
Lesson

Modern GitHub OIDC trust policies may require immutable repository identity rather than relying only on repository names.

Problem 9 — ECR Worked but EKS Did Not

This was the most important distinction.

The pipeline successfully:

assumed AWS role

and:

pushed image to ECR

but Kubernetes returned:

the server has asked for the client to provide credentials
Root Cause

AWS IAM authorization and Kubernetes authorization are separate.

The IAM role was valid in AWS.

But EKS did not have an access entry for:

GitHubActionsEnterpriseCapstoneRole
Fix

Terraform created:

EKS Access Entry

and:

AmazonEKSClusterAdminPolicy

association.

Lesson

A role can have:

AWS permissions

without having:

Kubernetes permissions
Problem 10 — Terraform Was the Durable Fix

Instead of running:

aws eks create-access-entry

manually, the configuration was added to the Terraform EKS module.

Terraform plan showed:

2 to add
0 to change
0 to destroy

The final resources were:

module.eks.aws_eks_access_entry.this["github_actions"]

module.eks.aws_eks_access_policy_association.this["github_actions_admin"]
Lesson

If infrastructure is Terraform-managed, infrastructure fixes should become Terraform configuration.

Otherwise:

AWS reality != Terraform state

which eventually causes drift and future failures.

⚠️ Node 20 Deprecation Warning

The successful GitHub Actions run shows warnings related to Node.js 20 deprecation.

Example:

Node.js 20 is deprecated.

This did not fail the pipeline.

The runner is currently forcing affected actions onto Node 24.

This is a maintenance warning rather than a Project 35 functional failure.

It should be tracked and addressed as GitHub Actions dependencies move to newer runtimes.

✅ Final CI/CD Evidence

The successful GitHub Actions run showed:

Test                         ✅
Kubernetes Manifest         ✅
Build and Security Scan     ✅
Deploy to EKS               ✅

Overall result:

SUCCESS

Total duration:

~1m 57s

This is the actual Project 35 completion evidence.

🔎 Runtime Verification

After deployment, verify:

kubectl get namespace project-35
kubectl get deployment -n project-35
kubectl get pods -n project-35
kubectl get service -n project-35

Expected deployment:

project-35-gateway   2/2

Expected pods:

2 Running

Verify rollout:

kubectl rollout status \
  deployment/project-35-gateway \
  -n project-35
🩺 Health Verification

Check the service:

kubectl get svc \
  project-35-gateway \
  -n project-35

Then test:

kubectl run p35-curl \
  -n project-35 \
  --rm -i \
  --restart=Never \
  --image=curlimages/curl:8.12.1 \
  -- \
  curl -fsS \
  http://project-35-gateway.project-35.svc.cluster.local/health

Expected:

{
  "status": "healthy"
}
🔐 Security Controls

The project implements several security controls.

Container
runAsNonRoot
runAsUser: 10001
allowPrivilegeEscalation: false
capabilities.drop: ALL
CI
OIDC

instead of static AWS credentials.

Image
Trivy

security scanning.

Image versioning
Git SHA

rather than:

latest
Kubernetes

EKS Access Entry controls which IAM principal can access the Kubernetes API.

💰 Cost Considerations

The pipeline itself is inexpensive because GitHub Actions uses hosted runners.

The major AWS cost components are:

EKS control plane
EC2 worker nodes
NAT Gateway
Load Balancer
ECR storage
CloudWatch

The shared EKS cluster is reused across projects to avoid recreating expensive infrastructure for every project.

🚨 Production Improvements

Project 35 is production-style, but not the final enterprise implementation.

At enterprise scale I would improve:

1. Least privilege EKS access

Replace:

AmazonEKSClusterAdminPolicy

with namespace-scoped access.

2. Separate environments
dev
staging
production
3. Deployment approval

Production should require:

approval gate
4. Immutable infrastructure

Terraform should manage:

EKS
IAM
ECR
Access Entries
5. Image signing

Add:

Cosign

and signature verification.

6. SBOM

Generate:

Software Bill of Materials

during CI.

7. Deployment strategy

Later projects can introduce:

Rolling
Blue/Green
Canary
Progressive Delivery
8. GitOps

A mature platform could move deployment responsibility to:

Argo CD

instead of directly deploying from GitHub Actions.

🧪 Definition of Done

Project 35 is considered complete when:

 Application implemented
 Docker image builds
 Container runs as non-root
 Kubernetes manifests created
 Automated tests created
 Tests pass
 Kubernetes manifests validated
 Trivy scanning implemented
 GitHub Actions implemented
 GitHub OIDC configured
 Static AWS credentials avoided
 ECR push works
 EKS authentication works
 EKS access entry created
 EKS access policy associated
 Terraform manages EKS access
 Deployment succeeds
 Rollout succeeds
 Application health verified
 GitHub Actions workflow succeeds
🎤 Interview Preparation

This project is extremely valuable for DevOps interviews because the interviewer can take you from:

Git push

all the way to:

Running workload on EKS

and ask about every boundary.

🔥 Core Interview Questions
1. Explain the Project 35 architecture.
Strong answer

Project 35 implements a push-driven Kubernetes CI/CD pipeline using GitHub Actions. A Git push triggers automated tests and Kubernetes manifest validation, followed by Docker image creation and Trivy security scanning. The pipeline authenticates to AWS using GitHub OIDC instead of static credentials, pushes the immutable Git-SHA-tagged image to ECR, configures kubeconfig for EKS, deploys Kubernetes manifests, waits for rollout completion and performs health verification.

2. Why use GitHub OIDC instead of AWS access keys?

Because long-lived access keys create credential-management and leakage risks.

OIDC provides:

short-lived credentials

and eliminates the need to store:

AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY

in GitHub.

3. Explain AssumeRoleWithWebIdentity.

GitHub issues an OIDC JWT.

The JWT contains claims identifying:

issuer
audience
repository
branch/ref
repository identity

AWS STS validates the token against the IAM OIDC provider and trust policy.

If the conditions match, STS issues temporary credentials.

4. What is the difference between IAM authorization and EKS authorization?

This is one of the most important Project 35 questions.

IAM determines:

Can this principal call AWS APIs?

EKS access management determines:

Can this principal authenticate/authorize against the Kubernetes API?

Therefore:

IAM role assumption != Kubernetes access
5. Why did ECR work while EKS failed?

Because the IAM role had enough AWS permissions to access ECR.

But the role was not present as an EKS access entry.

Therefore:

AWS API authorization → successful

Kubernetes API authorization → failed
6. What is an EKS Access Entry?

An EKS Access Entry associates an IAM principal with Kubernetes access.

Conceptually:

IAM Role
   ↓
EKS Access Entry
   ↓
EKS Access Policy
   ↓
Kubernetes API permissions
7. What is API_AND_CONFIG_MAP?

It allows EKS authentication to use both:

EKS Access Entries API

and:

aws-auth ConfigMap

This is useful during migrations and mixed authentication configurations.

8. Why manage the EKS access entry using Terraform?

Because the EKS cluster is infrastructure managed by Terraform.

Manual AWS changes create drift.

Terraform ensures:

configuration
      =
desired infrastructure
9. Why not simply use aws-auth?

Modern EKS provides Access Entries as a native access-management mechanism.

Access Entries provide an AWS-managed API-based approach instead of depending entirely on manually managing:

aws-auth
10. Why use Git SHA for Docker tags?

Because:

latest

is mutable.

A Git SHA is immutable and maps the container directly to source code.

Example:

project-35-gateway:
853b257ca1256f308fda3b27aeb2782f893ed24d

This makes rollback and auditing easier.

🐳 Docker Interview Questions
11. Why use python:3.12-slim?

It provides a smaller runtime image than a full Python image.

Benefits include:

smaller image
reduced attack surface
faster transfer
faster startup
12. Why run the container as UID 10001?

Running as a dedicated non-root user reduces the impact of container compromise.

If an attacker gains code execution, they don't immediately receive root privileges inside the container.

13. Why drop Linux capabilities?

The application does not need most Linux capabilities.

Therefore:

capabilities:
  drop:
    - ALL

reduces the container's privilege surface.

☸️ Kubernetes Questions
14. Why use a Deployment instead of a Pod?

A Deployment provides:

replica management
rolling updates
self-healing
rollout history
declarative desired state
15. Why use two replicas?

Two replicas improve availability.

If one pod fails:

Replica 1 ❌
Replica 2 ✅

the Deployment controller can maintain the desired replica count.

16. What is the difference between readiness and liveness probes?
Readiness

Determines:

Should this pod receive traffic?
Liveness

Determines:

Is this container still healthy?

A failed readiness probe removes the pod from service endpoints.

A failed liveness probe can cause Kubernetes to restart the container.

🔍 CI Questions
17. Why separate Test, Validation, Build and Deploy jobs?

Separation provides:

clearer failure diagnosis
independent stages
easier maintenance
better visualization
security boundaries
possible parallel execution
18. Why run tests before building the image?

There is no reason to build and publish an image when the application itself fails tests.

Fail fast.

Test
 ↓
Build

rather than:

Build
 ↓
discover test failure
🛡️ Trivy Questions
19. Why scan the container image?

Because vulnerabilities can exist in:

OS packages
Python packages
application dependencies
base images

Scanning before pushing/deploying creates a security gate.

20. Why should Trivy fail the pipeline?

If critical vulnerabilities are found, the pipeline should stop instead of automatically promoting an unsafe artifact.

🔥 Troubleshooting Interview Questions
21. GitHub Actions says k8s/namespace.yml does not exist. What do you check?

First check the runner working directory:

pwd

Then:

find . -name namespace.yml

If the project lives under:

project-35-kubernetes-cicd/

the workflow must use:

project-35-kubernetes-cicd/k8s/namespace.yml
22. Why did kubectl --dry-run=client try localhost?

Because the GitHub runner did not have an EKS kubeconfig/context.

kubectl attempted to contact its default API server:

localhost:8080
23. Why didn't --validate=false fix it?

Because kubectl apply still needs API discovery/interaction in this execution mode.

The proper solution for an offline CI runner was to use an actual offline YAML parser for pre-deployment validation.

24. GitHub OIDC says Not authorized to perform sts:AssumeRoleWithWebIdentity. What do you check?

Check:

OIDC provider exists.
id-token: write exists.

audience equals:

sts.amazonaws.com
trust policy subject matches.
repository identity matches.
branch/ref conditions match.
workflow is assuming the expected role.
GitHub secret contains the correct role ARN.
25. Why can OIDC be correct but EKS still fail?

Because OIDC only solves:

GitHub → AWS IAM

It does not automatically solve:

AWS IAM role → Kubernetes API

EKS access must also be configured.

26. aws eks update-kubeconfig succeeds but kubectl apply fails. What does that tell you?

It suggests:

AWS API access is working.

But Kubernetes authorization may still be missing.

Check:

aws eks list-access-entries

and:

aws eks list-associated-access-policies
27. ECR push succeeds but Kubernetes deployment fails. Where do you troubleshoot?

Separate the pipeline into boundaries:

GitHub
 ↓
OIDC
 ↓
IAM
 ↓
ECR
 ↓
EKS authentication
 ↓
Kubernetes authorization
 ↓
Deployment
 ↓
Pod
 ↓
Application

Do not assume an ECR success means EKS is correctly authorized.

28. How would you debug a failed rollout?

Start with:

kubectl rollout status deployment/<name> -n <namespace>

Then:

kubectl get pods -n <namespace>

Then:

kubectl describe pod <pod> -n <namespace>

Then:

kubectl logs <pod> -n <namespace>

Then inspect:

kubectl get events \
  -n <namespace> \
  --sort-by=.lastTimestamp
29. Pod is stuck in ImagePullBackOff. What do you check?

Check:

kubectl describe pod

Look for:

image not found
authorization failure
ECR access
wrong tag
wrong repository

Also verify:

aws ecr describe-images
30. Deployment succeeds but application is unavailable. What do you check?

Check in order:

Pod
 ↓
Readiness
 ↓
Service
 ↓
Endpoints
 ↓
Network
 ↓
Application

Commands:

kubectl get pods
kubectl get svc
kubectl get endpoints
kubectl describe svc
kubectl logs
🧠 Advanced Interview Questions
31. How would you make this pipeline production-grade?

I would add:

unit tests
integration tests
SAST
dependency scanning
container scanning
SBOM
image signing
policy enforcement
artifact promotion
staging environment
approval gates
production environment
rollback
observability
deployment notifications
32. How would you implement rollback?

Use Kubernetes rollout history:

kubectl rollout history deployment/project-35-gateway \
  -n project-35

Rollback:

kubectl rollout undo deployment/project-35-gateway \
  -n project-35

For a mature platform, deployment artifacts should also be immutable and versioned.

33. How would you implement blue/green deployment?

Maintain:

blue
green

versions simultaneously.

A Service points to one version.

Switching the Service selector changes production traffic.

34. How would you implement canary deployment?

Gradually route traffic:

95% stable
5% canary

then:

90/10
70/30
50/50
0/100

depending on health metrics.

35. How would you reduce EKS permissions?

Instead of:

AmazonEKSClusterAdminPolicy

use a namespace-scoped policy.

For Project 35:

project-35

only.

The pipeline should not be able to modify unrelated namespaces.

36. How would you protect the GitHub OIDC trust policy?

Use:

immutable repository identity

and restrict:

branch/ref

or preferably trusted GitHub environments where appropriate.

Avoid:

*

where unnecessary.

37. Why should CI not use latest?

Because it destroys artifact traceability.

If:

latest

points to different images over time, you cannot reliably answer:

Which exact code is running in production?

Git SHA solves this.

38. What is the difference between CI and CD?
CI
code
 ↓
test
 ↓
build
 ↓
scan
CD
artifact
 ↓
deploy
 ↓
verify
 ↓
promote

Project 35 implements both.

39. What happens if the GitHub runner dies during deployment?

The Kubernetes API receives declarative resource updates.

The Kubernetes control plane continues reconciling desired state.

The runner itself does not need to remain alive for the Deployment controller to maintain already-applied resources.

40. Why is Kubernetes declarative?

You specify:

desired state

Kubernetes controllers continuously reconcile:

actual state

against:

desired state
🎯 30-Second Interview Answer

If the interviewer says:

Tell me about your Project 35.

Use this:

Project 35 is a production-style Kubernetes CI/CD pipeline built with GitHub Actions, Docker, Trivy, Amazon ECR and Amazon EKS. A Git push triggers automated tests and Kubernetes manifest validation, followed by Docker image creation and Trivy vulnerability scanning. AWS authentication uses GitHub OIDC with short-lived credentials instead of static access keys. The image is pushed to ECR using the Git commit SHA as an immutable tag. GitHub Actions then authenticates to EKS and deploys the application. I also configured the EKS IAM access entry through Terraform because AWS IAM authorization and Kubernetes API authorization are separate layers. The pipeline verifies rollout and application health, giving us an end-to-end path from Git commit to a verified workload running on EKS.

🧠 60-Second Troubleshooting Answer

If asked:

What was the hardest issue you faced?

Answer:

The hardest issue was that GitHub OIDC and ECR were working, but Kubernetes deployment was failing with an authentication error. Initially it looked like an AWS credential problem, but I separated the authentication layers. GitHub successfully assumed the IAM role and pushed to ECR, so OIDC and IAM were working. aws eks update-kubeconfig also succeeded. The failure occurred when kubectl contacted the Kubernetes API. I inspected EKS access entries and found that the GitHub Actions IAM role was not authorized in EKS. Instead of manually creating an access entry, I added it to the Terraform EKS module using access_entries and associated the required EKS access policy. Terraform then created the access entry and policy association. After that, the deployment stage succeeded. The main lesson was that AWS IAM permissions and Kubernetes authorization are separate security boundaries.

🏆 What I Would Expect an Interviewer to Notice

This project demonstrates much more than:

"I know GitHub Actions."

It demonstrates:

CI/CD
+
Docker
+
DevSecOps
+
AWS IAM
+
OIDC
+
ECR
+
EKS
+
Kubernetes
+
Terraform
+
Troubleshooting
+
Security

The most valuable part is not that the first pipeline succeeded.

It is that you diagnosed:

wrong workflow path
       ↓
wrong repository paths
       ↓
offline kubectl validation
       ↓
invalid action version
       ↓
shell/GitHub variable mismatch
       ↓
OIDC trust mismatch
       ↓
immutable GitHub OIDC subject
       ↓
EKS authorization gap
       ↓
Terraform-managed access entry
       ↓
successful EKS deployment

That is real DevOps troubleshooting experience, and it is much stronger interview material than a project where everything worked on the first attempt.

Final Project 35 Status
PROJECT 35 — KUBERNETES CI/CD

Implementation       ✅
Testing              ✅
Docker               ✅
Trivy                ✅
GitHub Actions       ✅
OIDC                 ✅
IAM                  ✅
ECR                  ✅
EKS Access Entry     ✅
Terraform            ✅
Kubernetes Deploy    ✅
Rollout               ✅
CI Pipeline          ✅
Runtime verification ✅

STATUS: COMPLETE ✅
