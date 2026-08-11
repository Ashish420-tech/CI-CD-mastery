🚀 Project 08 — Container Registry & Image Publishing
📌 Project Overview

Project 08 extends the Docker CI pipeline developed in Project 07.

Project 07 demonstrated:

Source Code
    ↓
Tests
    ↓
Docker Build
    ↓
Container Runtime Validation

Project 08 introduces the next critical CI/CD capability:

Source Code
    ↓
Tests
    ↓
Docker Build
    ↓
Container Validation
    ↓
Image Tagging
    ↓
GHCR Authentication
    ↓
Image Publishing
    ↓
Container Registry
    ↓
Docker Pull
    ↓
Container Runtime

The objective is to build a traceable, reusable, deployable Docker artifact and publish it to GitHub Container Registry (GHCR).

🎯 Project Objective

The primary objective is to understand how a CI pipeline transforms source code into a reusable container artifact.

The project demonstrates:

Docker image creation
Docker image validation
GitHub Actions
GHCR
Container registry authentication
GITHUB_TOKEN
GitHub Actions permissions
Docker Buildx
Docker Metadata
Image versioning
Git SHA image tagging
OCI metadata
Container artifact traceability
Registry publishing
Registry consumption
Runtime validation
CI/CD troubleshooting
Least-privilege permissions
🧠 Core DevOps Principle

The major principle demonstrated by this project is:

CI should produce a validated and traceable deployment artifact, not merely a green build.

Project 07:

Green CI
   +
Docker Image

Project 08:

Green CI
   +
Validated Docker Image
   +
Container Registry
   +
Version Tag
   +
Git SHA Tag
   +
OCI Metadata
   +
Reusable Deployment Artifact
🏗️ Architecture
                         Developer
                             │
                             │ git push
                             ▼
                    ┌─────────────────┐
                    │     GitHub      │
                    │   Repository    │
                    └────────┬────────┘
                             │
                             ▼
                  ┌──────────────────────┐
                  │   GitHub Actions     │
                  │                      │
                  │ Checkout             │
                  │ Setup Python         │
                  │ pytest               │
                  │ Docker Build         │
                  │ Image Metadata       │
                  │ GHCR Authentication  │
                  │ Docker Push          │
                  └──────────┬───────────┘
                             │
                             │ Docker Push
                             ▼
                  ┌──────────────────────┐
                  │        GHCR          │
                  │ GitHub Container     │
                  │ Registry             │
                  │                      │
                  │ 1.0.0                │
                  │ sha-ff0def7          │
                  └──────────┬───────────┘
                             │
                             │ docker pull
                             ▼
                  ┌──────────────────────┐
                  │   Docker Runtime     │
                  │                      │
                  │ Container            │
                  │       ↓              │
                  │ Application          │
                  └──────────────────────┘
🔄 Complete CI/CD Flow
Developer
   │
   │ git push
   ▼
GitHub Repository
   │
   ▼
GitHub Actions
   │
   ├── Checkout
   │
   ├── Python 3.12
   │
   ├── Install pytest
   │
   ├── Run tests
   │
   ├── Authenticate to GHCR
   │
   ├── Generate image metadata
   │
   ├── Setup Docker Buildx
   │
   ├── Build Docker image
   │
   └── Push image
          │
          ▼
        GHCR
          │
          ├── 1.0.0
          │
          └── sha-ff0def7
          │
          ▼
       docker pull
          │
          ▼
       docker run
          │
          ▼
       Application
📁 Repository Structure
CI-CD-mastery/
│
├── project-03-branch-path-ci/
├── project-04-matrix-ci/
├── project-05-ci-artifacts/
├── project-06-environments-deployment-gates/
├── project-07-docker-image-ci/
│
├── project-08-container-registry/
│   ├── .dockerignore
│   ├── Dockerfile
│   ├── README.md
│   ├── app.py
│   └── test_app.py
│
└── .github/
    └── workflows/
        ├── project-03-ci.yml
        ├── project-04-matrix.yml
        ├── project-05-artifacts.yml
        ├── project-06-ci.yml
        ├── project-07-docker-ci.yml
        └── project-08-container-registry.yml
🐍 Application

The application is intentionally simple because the primary learning objective is the container delivery pipeline.

import os

APP_VERSION = os.getenv("APP_VERSION", "1.0.0")
ENVIRONMENT = os.getenv("ENVIRONMENT", "development")


def get_application_info():
    return {
        "application": "ci-cd-mastery-project-08",
        "version": APP_VERSION,
        "environment": ENVIRONMENT,
    }


if __name__ == "__main__":
    info = get_application_info()

    print(
        f"Application: {info['application']} | "
        f"Version: {info['version']} | "
        f"Environment: {info['environment']}"
    )
🧪 Application Testing

Three tests were implemented:

def test_application_name():
    info = get_application_info()

    assert info["application"] == "ci-cd-mastery-project-08"
def test_default_version():
    info = get_application_info()

    assert info["version"] == "1.0.0"
def test_default_environment():
    info = get_application_info()

    assert info["environment"] == "development"

Validation result:

3 passed
🐳 Dockerfile

The Dockerfile packages the application:

FROM python:3.12-slim

LABEL org.opencontainers.image.title="CI/CD Mastery Project 08"
LABEL org.opencontainers.image.description="Docker image registry and publishing demonstration"
LABEL org.opencontainers.image.version="1.0.0"
LABEL org.opencontainers.image.source="https://github.com/Ashish420-tech/CI-CD-mastery"

WORKDIR /app

COPY app.py .

ENV APP_VERSION=1.0.0
ENV ENVIRONMENT=development

CMD ["python", "app.py"]
🔍 Dockerfile Explanation
FROM
FROM python:3.12-slim

Provides the Python runtime.

We deliberately use the slim image to avoid unnecessary packages.

OCI Labels
LABEL org.opencontainers.image.version="1.0.0"

Provides image metadata.

The source label:

LABEL org.opencontainers.image.source="https://github.com/Ashish420-tech/CI-CD-mastery"

provides repository provenance.

WORKDIR
WORKDIR /app

Sets the application working directory.

COPY
COPY app.py .

Copies only the required application file.

Runtime Configuration
ENV APP_VERSION=1.0.0
ENV ENVIRONMENT=development

These provide defaults.

They can be overridden during runtime.

For example:

docker run \
  -e ENVIRONMENT=ci-validation \
  image

produces:

Environment: ci-validation
🧠 Build Once, Configure at Runtime

One of the important concepts demonstrated:

              ONE IMAGE
                  │
       ┌──────────┼──────────┐
       ▼          ▼          ▼
 Development   Staging   Production
       │          │          │
       ▼          ▼          ▼
 Environment-specific runtime configuration

Instead of building:

development-image
staging-image
production-image

we prefer:

ONE VALIDATED IMAGE

and configure it at runtime.

📦 .dockerignore
.git
.github
.venv
__pycache__
.pytest_cache
*.pyc
*.pyo
*.log
README.md

This prevents unnecessary files from entering the Docker build context.

For example:

.venv/
__pycache__/
.pytest_cache/

should never become part of the production image.

🧪 Local Docker Validation

The image was built using:

docker build \
  --tag project-08-app:1.0.0 \
  .

The resulting image was:

project-08-app:1.0.0

The container was then executed:

docker run --rm \
  -e APP_VERSION=1.0.0 \
  -e ENVIRONMENT=ci-validation \
  project-08-app:1.0.0

Output:

Application: ci-cd-mastery-project-08 |
Version: 1.0.0 |
Environment: ci-validation
🌐 Container Registry
What is a Container Registry?

A container registry is a centralized system for storing and distributing container images.

Examples:

GitHub Container Registry
Amazon ECR
Azure Container Registry
Google Artifact Registry
Docker Hub
Harbor

For this project:

GHCR

was selected.

Why do we need a registry?

Without a registry:

GitHub Actions Runner
       │
       └── Docker Image

The image exists only on the temporary CI runner.

Once the runner is destroyed:

Runner
   ↓
Destroyed
   ↓
Image unavailable

With a registry:

GitHub Actions
      │
      ▼
Validated Image
      │
      ▼
GHCR
      │
      ├── Development
      ├── Staging
      └── Production

The image becomes a reusable deployment artifact.

📦 GHCR Image

The published image:

ghcr.io/ashish420-tech/ci-cd-mastery-project-08

Published tags:

1.0.0
sha-ff0def7

The package was verified as:

package_type: container
visibility: public
🏷️ Image Tagging Strategy

We intentionally used two tags.

Release tag
1.0.0

Human-friendly.

Git SHA tag
sha-ff0def7

Provides source traceability.

Conceptually:

Git commit
    │
    │ ff0def7
    ▼
Docker image
    │
    └── sha-ff0def7
Why not use only latest?

Consider:

latest

today:

latest → version A

Tomorrow:

latest → version B

The same reference now points to different artifacts.

That makes auditing and rollback harder.

Better:

1.0.0
1.1.0
1.2.0

and/or:

sha-abc1234
sha-def5678

For strongest reproducibility, use the registry digest.

🧬 Image Tag vs Digest

A tag:

:1.0.0

is a named reference.

A digest:

@sha256:35901a7428...

is content-addressed.

Conceptually:

Tag
 │
 └── mutable reference

Digest
 │
 └── specific registry manifest

Production deployment systems often prefer digest-based deployment when strict immutability is required.

🔐 GHCR Authentication

The GitHub Actions workflow uses:

permissions:
  contents: read
  packages: write

The workflow authenticates using:

username: ${{ github.actor }}
password: ${{ secrets.GITHUB_TOKEN }}

The important point is:

The workflow does not contain a hardcoded registry password.

🔑 GITHUB_TOKEN

GitHub automatically provides a GITHUB_TOKEN to GitHub Actions workflows.

We use it to authenticate against GHCR.

Required permission:

packages: write

Without it, publishing may fail.

🔐 Least Privilege

The workflow uses:

permissions:
  contents: read
  packages: write

rather than giving the workflow unnecessary permissions.

Conceptually:

Workflow
   │
   ├── Read repository
   │
   └── Write packages

This follows the principle:

Give CI only the permissions required to perform its task.

⚙️ GitHub Actions Workflow

The workflow:

.github/workflows/project-08-container-registry.yml

performs:

Checkout
   ↓
Python setup
   ↓
Install pytest
   ↓
Run tests
   ↓
GHCR login
   ↓
Generate metadata
   ↓
Buildx
   ↓
Build
   ↓
Push
Workflow Trigger

Project 08 is scoped to:

on:
  push:
    branches:
      - project-08-container-registry

  pull_request:
    branches:
      - project-08-container-registry

This prevents the Project 08 pipeline from running on unrelated branches.

Docker Build Context

The workflow explicitly uses:

context: ${{ env.PROJECT_DIR }}

where:

PROJECT_DIR: project-08-container-registry

This is important.

We do not build from:

CI-CD-mastery/

Instead:

project-08-container-registry/

is the Docker build context.

This reduces accidental inclusion of unrelated repository content.

Docker Buildx

The workflow uses:

uses: docker/setup-buildx-action@v4

Buildx is Docker's extended build functionality and is commonly used by modern CI pipelines.

It enables advanced BuildKit-based image builds and supports more sophisticated build workflows.

Docker Metadata

The workflow uses:

uses: docker/metadata-action@v6

This generates image tags and OCI labels automatically.

Our tags include:

1.0.0
sha-ff0def7
Docker Build and Push

The workflow uses:

uses: docker/build-push-action@v7

with:

push: true

So the pipeline performs:

Docker Build
     +
Docker Push

in CI.

🔄 Complete Workflow
Git Push
   │
   ▼
GitHub Actions
   │
   ▼
Checkout
   │
   ▼
Python Setup
   │
   ▼
pytest
   │
   ├── FAIL → STOP
   │
   └── PASS
         │
         ▼
    GHCR Login
         │
         ▼
    Metadata
         │
         ▼
      Buildx
         │
         ▼
     Docker Build
         │
         ▼
      Docker Push
         │
         ▼
        GHCR

This ordering is intentional.

We don't want to publish an image before the tests succeed.

📊 Actual Project Validation
Unit Tests
3 passed
Docker Build
Successfully tagged project-08-app:1.0.0
Local Runtime
Application: ci-cd-mastery-project-08 |
Version: 1.0.0 |
Environment: ci-validation
GitHub Actions

Run:

31515994571

Result:

SUCCESS
GHCR Package
ci-cd-mastery-project-08

Type:

container

Visibility:

public
Published Tags
1.0.0
sha-ff0def7
Registry Pull
docker pull ghcr.io/ashish420-tech/ci-cd-mastery-project-08:1.0.0

successful.

Published Runtime
Application: ci-cd-mastery-project-08 |
Version: 1.0.0 |
Environment: ghcr-validation
🧬 OCI Metadata

The pulled image contained:

org.opencontainers.image.revision
ff0def76195dad09eaf48784427f28100e7c6475

and:

org.opencontainers.image.source
https://github.com/Ashish420-tech/CI-CD-mastery

and:

org.opencontainers.image.version
1.0.0

This gives the artifact provenance.

🔎 Artifact Traceability

We can trace:

Git Commit
     │
     ▼
GitHub Actions Run
     │
     ▼
Docker Image
     │
     ▼
GHCR
     │
     ▼
Deployment

For this project:

Git SHA:
ff0def7

Image tag:

sha-ff0def7
🚨 Real Failure Encountered

During validation we attempted to query GHCR using:

gh api /user/packages/container/...

The API returned:

403
You need at least read:packages scope
Root Cause

The local GitHub CLI authentication token did not initially have:

read:packages

This was a local CLI authentication problem, not a failure of the GitHub Actions publishing workflow.

Resolution

We refreshed the GitHub CLI authentication:

gh auth refresh -h github.com -s read:packages

Afterward:

read:packages

was present.

GHCR API queries then succeeded.

Important Authentication Distinction

There were two different identities.

GitHub Actions
GITHUB_TOKEN
      ↓
packages: write
      ↓
GHCR
Local GitHub CLI
gh token
      ↓
read:packages
      ↓
GHCR API

These are different authentication contexts.

🧪 Troubleshooting Guide
Push fails with permission denied

Check:

permissions:
  packages: write

Then inspect workflow logs.

GHCR API returns 403

Check:

gh auth status

Look for:

read:packages

If missing:

gh auth refresh -h github.com -s read:packages
Docker pull fails

Check whether the package is public/private.

For private packages, authenticate Docker appropriately.

Wrong image

Check:

docker image inspect IMAGE

and compare:

revision
version
digest
Wrong Git SHA tag

Check:

git rev-parse --short HEAD

Then compare it with:

sha-<commit>
Tests pass but Docker build fails

Separate the problem into:

Application
   ↓
pytest

versus:

Docker
   ↓
Dockerfile
   ↓
Build context

Check:

docker build .

locally.

🛡️ Security Considerations
Do not commit credentials

Never put:

AWS keys
Docker passwords
PATs
registry passwords

inside:

Dockerfile
workflow YAML
source code
README
Prefer ephemeral CI credentials

For GitHub Actions + GHCR:

GITHUB_TOKEN

is preferable to manually managing a long-lived credential for the basic repository-associated publishing workflow.

Least privilege

Use:

permissions:
  contents: read
  packages: write

rather than broad permissions.

🚀 Production Evolution

This project is intentionally small.

A production system could evolve into:

Developer
    │
    ▼
GitHub
    │
    ▼
CI
    │
    ├── Unit Tests
    ├── SAST
    ├── Dependency Scan
    ├── Docker Build
    ├── Trivy Scan
    ├── SBOM
    ├── Image Signing
    └── Push
          │
          ▼
      Registry
          │
          ▼
       Staging
          │
          ▼
     Approval Gate
          │
          ▼
      Production

Later projects can introduce:

Trivy
SBOM
Cosign
Image signing
ECR
Kubernetes
Helm
EKS
Argo CD
Canary deployments
Blue/Green deployments
🏦 Enterprise Architecture

A more mature architecture:

                Developer
                    │
                    ▼
              Git Repository
                    │
                    ▼
              Pull Request
                    │
             ┌──────┴──────┐
             │             │
           Tests         Security
             │             │
             └──────┬──────┘
                    ▼
              Docker Build
                    │
                    ▼
             Image Scan
                    │
                    ▼
                 SBOM
                    │
                    ▼
             Image Signing
                    │
                    ▼
                Registry
                    │
             ┌──────┴──────┐
             ▼             ▼
          Staging      Artifact Store
             │
             ▼
        Validation
             │
             ▼
        Approval Gate
             │
             ▼
        Production
🎯 Definition of Done
Requirement	Status
Application created	✅
Unit tests	✅
Dockerfile	✅
.dockerignore	✅
Local Docker build	✅
Local runtime validation	✅
GitHub Actions	✅
GHCR authentication	✅
Image publishing	✅
GHCR package	✅
Version tag	✅
Git SHA tag	✅
OCI metadata	✅
Registry pull	✅
Published image runtime	✅
Failure analysis	✅
Clean Git status	✅
Deep documentation	✅
🏆 Project 08 Status: COMPLETE
🎤 PROJECT 08 — DEEP INTERVIEW PREPARATION

Now the important part.

Don't memorize one-line answers. Understand the architecture.

Q1. Why do we need a container registry?
Strong answer

A container registry provides durable storage and distribution for container images. A CI runner is temporary, so an image built on the runner needs to be stored somewhere persistent so deployment environments such as Kubernetes, ECS, or other Docker runtimes can retrieve it.

Architecture:

CI
 ↓
Build
 ↓
Registry
 ↓
Deployment
Q2. What problem did Project 08 solve compared with Project 07?
Answer

Project 07 built and validated a Docker image.

Project 08 took the next step by publishing that validated image to a container registry.

Project 07:

Build → Validate

Project 08:

Build → Validate → Publish → Pull → Run
Q3. What is GHCR?
Answer

GHCR is GitHub Container Registry.

It is GitHub's registry for container/OCI images.

An image can be referenced as:

ghcr.io/<owner>/<image>:<tag>

For this project:

ghcr.io/ashish420-tech/ci-cd-mastery-project-08:1.0.0
Q4. What happens if the GitHub Actions runner disappears after the job?

The local Docker image on the ephemeral runner is lost.

That's why we push the image to GHCR.

Runner
  ↓
Build
  ↓
Push
  ↓
GHCR

The registry survives the runner lifecycle.

Q5. How does GitHub Actions authenticate to GHCR?

Using the workflow's GITHUB_TOKEN and appropriate permissions.

For publishing:

permissions:
  packages: write

Then:

docker/login-action

uses:

github.actor
GITHUB_TOKEN
Q6. Why is packages: write required?

Because pushing a container image modifies the GitHub Packages resource.

Therefore the workflow needs permission to write packages.

Without it, authentication or authorization can fail during the push.

Q7. What is least privilege?

Giving an identity only the permissions required for its task.

Instead of:

Administrator

we use:

contents: read
packages: write

for this workflow.

Q8. Why not use a PAT?

A PAT can work, but it introduces a long-lived credential that must be stored, rotated, protected, and revoked.

For a GitHub Actions workflow publishing a package associated with the repository, the built-in GITHUB_TOKEN is preferable.

Q9. What was the 403 error you encountered?

The local gh CLI initially lacked:

read:packages

The API therefore returned:

403 Forbidden

The CI workflow itself was already successfully publishing using its separate GITHUB_TOKEN.

We fixed the local CLI authentication by adding:

read:packages
Q10. Is GITHUB_TOKEN the same as your local gh token?

No.

This is a very important distinction.

GitHub Actions
   ↓
GITHUB_TOKEN

is generated for the workflow.

Your local:

gh auth

uses your local GitHub authentication.

They have different scopes and lifecycles.

Q11. Why shouldn't we use latest?

Because it is mutable.

Example:

latest → image A

then later:

latest → image B

You lose strong version traceability.

Version tags, Git SHA tags, and especially digests provide stronger reproducibility.

Q12. What is the difference between a tag and a digest?

Tag:

:1.0.0

is a named reference.

Digest:

@sha256:...

is content-addressed.

A tag can move.

A digest identifies a specific registry manifest.

Q13. What would you deploy to production?

For strong reproducibility:

ghcr.io/company/application@sha256:<digest>

rather than relying only on:

:latest
Q14. Why use Git SHA tags?

They provide traceability.

Example:

Git commit:
ff0def7

Image:
sha-ff0def7

This allows us to determine which source revision produced an image.

Q15. Why use both version and SHA tags?

Version:

1.0.0

is human-friendly.

SHA:

sha-ff0def7

is traceability-friendly.

Both serve different purposes.

Q16. What is OCI metadata?

OCI means Open Container Initiative.

OCI image annotations provide standardized metadata about container artifacts.

Examples:

org.opencontainers.image.version
org.opencontainers.image.source
org.opencontainers.image.revision

Our image contained:

version → 1.0.0
source → GitHub repository
revision → ff0def7...
Q17. Why is image provenance important?

Suppose production is running an image and someone asks:

Which source code generated this image?

Without provenance, answering that may be difficult.

With:

revision
source
version
SHA tag

we can trace:

Production image
      ↓
Registry
      ↓
Image metadata
      ↓
Git SHA
      ↓
Source code
Q18. Why test before pushing?

Because the registry should contain usable artifacts.

Bad pattern:

Build
 ↓
Push
 ↓
Test

Better:

Test
 ↓
Build
 ↓
Validate
 ↓
Push

This reduces the chance of publishing known-broken images.

Q19. What is Docker Buildx?

Buildx provides an extended Docker build interface powered by BuildKit.

It supports advanced build functionality and is commonly used in CI/CD workflows.

Q20. Why did we specify the Docker build context?

Because the repository contains multiple projects.

We used:

context: project-08-container-registry

rather than:

repository root

This keeps the build isolated.

Q21. What happens if we accidentally use the repository root as Docker context?

Docker may send unnecessary repository content to the build process.

That can:

increase build context
slow builds
expose unnecessary files
cause accidental inclusion
complicate reproducibility

That's why .dockerignore and an appropriate context are important.

Q22. Difference between Docker image and container?
Image

Immutable-style packaged artifact containing application code, runtime, libraries, configuration defaults, and metadata.

Container

A running instance of an image.

Image
 ├── Container A
 ├── Container B
 └── Container C
Q23. What does "build once, deploy many" mean?

Build one validated image:

Image 1.0.0

then promote the same image:

Development
    ↓
Staging
    ↓
Production

Do not rebuild separately for each environment.

Q24. Why is rebuilding for production dangerous?

Suppose:

Build A → Staging

Then you rebuild:

Build B → Production

Even though the source is supposedly identical, the dependency/base-image environment could differ.

Now:

Staging ≠ Production

Building once reduces that risk.

Q25. What happens if the registry is unavailable?

The pipeline's publish step fails.

Existing deployed workloads may continue running because containers already running don't necessarily need the registry continuously.

But new deployments, scaling events, or image pulls may fail.

This is why registry availability is part of the delivery platform's reliability model.

Q26. How would you make the pipeline more secure?

I would add:

SAST
Dependency scanning
Container vulnerability scanning
SBOM
Image signing
Provenance/attestation
Least privilege
Protected branches
Environment approvals
Immutable deployment references
Registry access control
Q27. How would Trivy fit here?

After building:

Docker Build
    ↓
Trivy Image Scan
    ↓
PASS
    ↓
GHCR Push

For example:

Critical vulnerabilities
       ↓
       > 0
       ↓
Pipeline FAIL
Q28. Where would SBOM fit?

A Software Bill of Materials describes the components inside the artifact.

Architecture:

Docker Build
    ↓
SBOM
    ↓
Security Scan
    ↓
Sign/Attest
    ↓
Registry
Q29. What is image signing?

Image signing allows consumers to verify that an image came from a trusted publisher and wasn't replaced by an unauthorized artifact.

Tools such as Cosign are commonly used.

Production flow:

Build
 ↓
Scan
 ↓
Sign
 ↓
Push
 ↓
Verify before deployment
Q30. How would Kubernetes use this image?

Kubernetes could reference:

image: ghcr.io/ashish420-tech/ci-cd-mastery-project-08:1.0.0

or preferably an immutable digest:

image: ghcr.io/ashish420-tech/ci-cd-mastery-project-08@sha256:...

Then Kubernetes pulls the image from GHCR.

Q31. What if the GHCR package is private?

The Kubernetes runtime would need appropriate registry credentials.

For Kubernetes this could involve:

imagePullSecrets

or a cloud/platform-specific workload identity mechanism.

Q32. How would you promote an image from staging to production?

Don't rebuild it.

Instead:

Build
 ↓
Scan
 ↓
Push
 ↓
Staging
 ↓
Validate
 ↓
Approval
 ↓
Production

The production environment should consume the same artifact validated in staging.

Q33. What is artifact promotion?

Moving an already-built artifact through environments:

Registry
   ↓
Staging
   ↓
Production

rather than creating a new artifact for each environment.

Q34. How would you implement rollback?

If production is running:

1.2.0

and it fails:

1.1.0

can be redeployed.

This is much easier when images are versioned and immutable.

Q35. How would you design a production registry?

I would consider:

Private registry
   +
RBAC
   +
Immutable tags
   +
Image scanning
   +
SBOM
   +
Signing
   +
Retention policies
   +
Audit logging
   +
Replication
   +
Access controls
Q36. Why should container registries have retention policies?

Without lifecycle management:

100 images
 ↓
1,000
 ↓
10,000
 ↓
Storage growth

Old images should be removed according to organizational retention rules while preserving required release/rollback versions.

Q37. What is the difference between GHCR and AWS ECR?
GHCR

Best integrated with:

GitHub
GitHub Actions
GitHub Packages
ECR

Best integrated with:

AWS
EKS
IAM
ECS
AWS security/networking

For an AWS enterprise environment, ECR is often a natural registry choice.

For this GitHub Actions mastery project, GHCR keeps the focus on CI/CD and GitHub integration.

Q38. If this were an AWS production system, what would change?

Instead of:

GitHub Actions
      ↓
GHCR

we could use:

GitHub Actions
      ↓
AWS authentication
      ↓
Amazon ECR
      ↓
EKS

Later projects can introduce that architecture.

Q39. How would you prevent arbitrary developers from publishing production images?

Use:

Protected branches
Required PR reviews
Environment approvals
Restricted GitHub Actions permissions
Registry RBAC
Trusted workflows
Image signing
Admission policies

Kubernetes could also verify signatures before allowing deployment.

Q40. What was the biggest lesson from Project 08?

A strong interview answer:

The biggest lesson was that building a Docker image is only one part of CI/CD. A production-oriented pipeline must validate the image, publish it to a durable registry, provide traceability back to source code, and make the exact artifact consumable by deployment environments.

🧠 Senior-Level Interview Scenario
Interviewer:

Your GitHub Actions pipeline says the Docker image was successfully built. Can you deploy it?

Weak answer:

Yes, because the build passed.

Strong answer:

Not necessarily. A successful build only proves that the image was created. I would verify that the image passed application and security validation, was successfully pushed to the registry, has a traceable version or digest, and can be pulled by the deployment environment. Ideally, I'd deploy the exact immutable image digest rather than relying on a mutable tag.

That is the answer you want to give.

🔥 Senior-Level Scenario 2
Interviewer:

Production is running image 1.0.0, but someone pushed a new image using the same tag. What is the problem?

Answer:

The tag is mutable, so the same tag can reference different artifacts over time. This weakens reproducibility and rollback guarantees. I would use immutable tags or digests and configure registry policies to prevent tag mutation where appropriate.

🔥 Senior-Level Scenario 3
Interviewer:

The GitHub Actions workflow can push to GHCR, but your local gh api command returns 403. Is the CI pipeline broken?

Answer:

Not necessarily. GitHub Actions and the local GitHub CLI use different authentication contexts. The workflow's GITHUB_TOKEN had packages: write, allowing it to publish. My local CLI token initially lacked read:packages, which caused the API's 403. I resolved that by refreshing the local CLI authentication with the required scope.

That is exactly your real Project 08 experience, so you can confidently explain it.

🏆 Your Project 08 Interview Story

If an interviewer asks:

"Tell me about a CI/CD project you built."

You can say:

I built a GitHub Actions CI/CD pipeline that takes a Python application, runs automated tests, builds a Docker image, authenticates securely to GitHub Container Registry using the workflow's GITHUB_TOKEN, generates version and Git SHA-based image tags, publishes the validated image to GHCR, and then verifies that the exact published artifact can be pulled and executed independently. I also added OCI metadata for source and revision traceability. During implementation I encountered a 403 when inspecting the package through the local GitHub CLI because the local token lacked read:packages; I diagnosed that separately from the CI publishing identity and resolved it by refreshing the CLI scope.

That is a much stronger interview story than simply saying:

"I created a Docker GitHub Actions workflow."

Final Mental Model

Memorize this architecture, not individual commands:

                SOURCE
                  │
                  ▼
             AUTOMATED TEST
                  │
                  ▼
             DOCKER BUILD
                  │
                  ▼
           IMAGE VALIDATION
                  │
                  ▼
             IMAGE TAGGING
                  │
                  ▼
          REGISTRY AUTHENTICATION
                  │
                  ▼
              GHCR PUSH
                  │
                  ▼
          DURABLE ARTIFACT
                  │
                  ▼
              PULL IMAGE
                  │
                  ▼
            RUN CONTAINER
                  │
                  ▼
           APPLICATION WORKS

And the enterprise evolution:

CI
 ↓
Build
 ↓
Test
 ↓
Scan
 ↓
SBOM
 ↓
Sign
 ↓
Registry
 ↓
Staging
 ↓
Approval
 ↓
Production
 ↓
Kubernetes

That is the CI/CD mastery progression we're building.
