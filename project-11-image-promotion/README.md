Project 11 — Docker Image Promotion
Overview

Project 11 demonstrates a core enterprise CI/CD principle:

Build once, promote the same artifact.

The project shows how a Docker image can be built once and then promoted across different environments without rebuilding the application.

Source Code
    |
    v
Tests
    |
    v
Docker Build
    |
    v
ONE IMAGE ARTIFACT
    |
    +--------> Staging
    |
    +--------> Production

The staging and production references are verified to point to the same Docker image ID.

Enterprise Problem

A weak CI/CD implementation may rebuild an application separately for every environment:

Build
  |
  v
Staging

Rebuild
  |
  v
Production

This creates a potential artifact consistency problem.

The production artifact may differ from the artifact that was tested in staging.

A stronger enterprise model is:

Build Once
    |
    v
Test
    |
    v
Security Validation
    |
    v
Publish Artifact
    |
    v
Promote Same Artifact
    |
    +----> Staging
    |
    +----> Production

Project 11 implements the promotion portion of this lifecycle.

Project Objective

The project validates that:

The application passes tests.
A Docker image is built once.
The resulting image ID is captured.
The same image is promoted to staging.
The same image is promoted to production.
No second Docker build occurs.
The image IDs remain identical.
Architecture
                         Git Repository
                              |
                              v
                       ┌──────────────┐
                       │    pytest    │
                       └──────┬───────┘
                              |
                              v
                       ┌──────────────┐
                       │ Docker Build │
                       └──────┬───────┘
                              |
                              v
                  ┌────────────────────────┐
                  │  Docker Image Artifact │
                  │   Image ID: 4107...    │
                  └────────────┬───────────┘
                               |
                 ┌─────────────┴─────────────┐
                 |                           |
                 v                           v
        ┌────────────────┐         ┌─────────────────┐
        │    Staging     │         │   Production    │
        │      tag       │         │      tag        │
        └───────┬────────┘         └────────┬────────┘
                |                           |
                └─────────────┬─────────────┘
                              v
                   SAME IMAGE ARTIFACT
Technologies
Technology	Purpose
Docker	Build and promote container artifact
Python	Application runtime
pytest	Application validation
Git	Source control
GitHub Actions	CI/CD automation
Directory Structure
CI-CD-mastery/
│
├── .github/
│   └── workflows/
│       └── project-11-image-promotion.yml
│
└── project-11-image-promotion/
    ├── .dockerignore
    ├── Dockerfile
    ├── README.md
    ├── app.py
    └── test_app.py
Promotion Model

The project uses the following Docker references:

ci-cd-mastery-project-11:build
ci-cd-mastery-project-11:staging
ci-cd-mastery-project-11:production

The important point is that the staging and production tags are created from the same build image.

docker tag \
  ci-cd-mastery-project-11:build \
  ci-cd-mastery-project-11:staging

docker tag \
  ci-cd-mastery-project-11:build \
  ci-cd-mastery-project-11:production

No second Docker build is performed.

Why Docker Tags Work for Promotion

Docker tags are references to image content.

For example:

                    ┌── :build
                    │
Docker Image ───────┼── :staging
                    │
                    └── :production

All three references can point to the same image.

Therefore, changing the tag does not rebuild the application.

Local Implementation
1. Build the image
docker build \
  -t ci-cd-mastery-project-11:build \
  ./project-11-image-promotion
2. Create staging reference
docker tag \
  ci-cd-mastery-project-11:build \
  ci-cd-mastery-project-11:staging
3. Create production reference
docker tag \
  ci-cd-mastery-project-11:build \
  ci-cd-mastery-project-11:production
Artifact Identity Validation

Docker image IDs were inspected using:

docker image inspect ci-cd-mastery-project-11:build \
  --format '{{.Id}}'

docker image inspect ci-cd-mastery-project-11:staging \
  --format '{{.Id}}'

docker image inspect ci-cd-mastery-project-11:production \
  --format '{{.Id}}'

Actual validation produced:

build:
sha256:4107dea7f90f20d265f1c69199f510f82586f549ee2063bad8b931b01463158b

staging:
sha256:4107dea7f90f20d265f1c69199f510f82586f549ee2063bad8b931b01463158b

production:
sha256:4107dea7f90f20d265f1c69199f510f82586f549ee2063bad8b931b01463158b

All three references resolved to the same image ID.

Therefore:

Build Artifact      = 4107...
Staging Artifact    = 4107...
Production Artifact = 4107...
Result
PROMOTION VALIDATION: SAME ARTIFACT
Automated Artifact Validation

The following logic verifies that all environment references point to the same image:

BUILD_ID=$(docker image inspect ci-cd-mastery-project-11:build --format '{{.Id}}')
STAGING_ID=$(docker image inspect ci-cd-mastery-project-11:staging --format '{{.Id}}')
PRODUCTION_ID=$(docker image inspect ci-cd-mastery-project-11:production --format '{{.Id}}')

test "$BUILD_ID" = "$STAGING_ID" &&
test "$BUILD_ID" = "$PRODUCTION_ID" &&
echo "PROMOTION VALIDATION: SAME ARTIFACT"

This is stronger than simply checking whether the tags exist.

GitHub Actions Pipeline

Workflow:

Checkout
    |
    v
Run Tests
    |
    v
Build Artifact Once
    |
    v
Capture Image ID
    |
    v
Promote to Staging
    |
    v
Promote to Production
    |
    v
Verify Same Artifact

Workflow file:

.github/workflows/project-11-image-promotion.yml
GitHub Actions Validation

Project 11 was successfully validated through GitHub Actions.

Workflow
Project 11 - Image Promotion
Run
31522092293
Result
SUCCESS
Job
Build Once and Promote
Validated Steps
✓ Set up job
✓ Checkout
✓ Run tests
✓ Build artifact once
✓ Capture source artifact ID
✓ Promote to staging
✓ Promote to production
✓ Verify same artifact
✓ Display promoted images
✓ Complete job

The critical validation step:

✓ Verify same artifact

passed successfully.

CI/CD Validation Result
Tests                    ✅
Docker Build             ✅
Artifact ID Capture      ✅
Staging Promotion        ✅
Production Promotion     ✅
Same Artifact Validation ✅
GitHub Actions           ✅
Real Validation Failure Encountered

During local validation, the first verification attempt failed because the staging tag had not yet been created.

The command:

docker image inspect ci-cd-mastery-project-11:staging

returned:

No such image: ci-cd-mastery-project-11:staging
Root Cause

The production tag had been created, but the staging tag had not.

Resolution

The staging reference was created:

docker tag \
  ci-cd-mastery-project-11:build \
  ci-cd-mastery-project-11:staging

The verification was then repeated.

All three image IDs matched.

Lesson

A deployment pipeline should validate artifact identity, not merely the existence of environment tags.

Build Once vs Rebuild
Anti-pattern
Source
  |
  +----> Build → Staging
  |
  +----> Build → Production

Two builds can potentially produce different artifacts.

Recommended pattern
Source
  |
  v
Build Once
  |
  v
Test
  |
  v
Scan
  |
  v
Publish
  |
  v
Promote
  |
  +----> Staging
  |
  +----> Production

The same artifact is tested, approved, promoted, and eventually deployed.

Why Artifact Promotion Matters

This approach provides:

Consistency

The artifact tested in staging is the artifact promoted to production.

Traceability

Engineers can identify exactly which artifact is running.

Faster deployments

Production does not need another Docker build.

Reduced risk

The deployment process does not introduce a new build after testing.

Better rollback

A previously approved artifact can be promoted again.

Production Consideration

Docker tags are useful for demonstrating promotion, but production systems should generally use immutable artifact references.

Preferred:

image@sha256:<digest>

or an immutable Git SHA-based image reference.

For example:

app@sha256:abc123...

This prevents an environment from unexpectedly receiving different image content because a mutable tag was moved.

Interview Questions
1. What is artifact promotion?

Artifact promotion means moving an already-built and validated artifact from one environment or lifecycle stage to another without rebuilding it.

2. Why build only once?

Because the artifact tested and approved should be exactly the artifact deployed to production.

3. Why not rebuild for production?

A second build could produce different output because of:

Changed dependencies
Base image updates
Build-time timestamps
External package changes
Different build environments
Configuration differences
4. What proves that the artifact is identical?

The Docker image ID or, more strongly, the image digest.

In this project:

build       → sha256:4107...
staging     → sha256:4107...
production  → sha256:4107...

The identical IDs prove that the references point to the same image content.

5. What is the difference between promotion and deployment?

Promotion moves or authorizes an artifact to another lifecycle stage.

Deployment actually runs that artifact in an environment.

Example:

Build
  ↓
Security Scan
  ↓
Promote → Staging
  ↓
Deploy → Staging
  ↓
Promote → Production
  ↓
Deploy → Production
6. Why are image digests useful?

A digest identifies the exact image content and provides immutable artifact identity.

Example:

repository/image@sha256:...

This is safer than relying only on mutable tags.

7. How would you implement this in a real enterprise registry?

A typical model would be:

Developer Commit
      ↓
CI Build
      ↓
Security Scan
      ↓
Push to Registry
      ↓
Staging Promotion
      ↓
Testing/Approval
      ↓
Production Promotion
      ↓
Deployment

The same immutable image digest is retained throughout the lifecycle.

Project 11 Completion
┌──────────────────────────────────────────┐
│ PROJECT 11 — COMPLETE                    │
├──────────────────────────────────────────┤
│ Implementation             ✅            │
│ Docker Build               ✅            │
│ pytest                     ✅            │
│ Artifact ID Validation     ✅            │
│ Staging Promotion          ✅            │
│ Production Promotion       ✅            │
│ Same Artifact Validation    ✅            │
│ GitHub Actions              ✅            │
│ Commit                      ✅            │
│ Push                        ✅            │
│ Interview Preparation       ✅            │
└──────────────────────────────────────────┘
CI/CD Mastery Progress
01  Basic CI                         ✅
02  Pull Request CI                 ✅
03  Branch/Path CI                  ✅
04  Matrix CI                       ✅
05  CI Artifacts                    ✅
06  Environments + Gates            ✅
07  Docker Image CI                 ✅
08  GHCR Container Registry         ✅
09  Docker Image Security           ✅
10  Image Tagging & Lifecycle       ✅
11  Image Promotion                 ✅
12  Container Deployment            ▶ NEXT
Key Takeaway

Project 11 establishes one of the most important CI/CD principles:

Build once. Test once. Approve once. Promote the same immutable artifact.
