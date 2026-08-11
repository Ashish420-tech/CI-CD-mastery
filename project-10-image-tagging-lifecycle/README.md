# Project 10 — Docker Image Tagging & Lifecycle

## Overview

Project 10 implements a **Docker image tagging strategy** for CI/CD.

The project demonstrates how a single Docker image can receive multiple traceable tags representing:

* Exact Git commit
* Short Git commit
* Semantic release version
* Mutable `latest` reference

The key principle is:

> **Build the image once and identify the same artifact using multiple meaningful references.**

---

# Enterprise Problem

Container images need to be traceable throughout the software delivery lifecycle.

Using only:

```text
latest
```

creates an operational problem because `latest` is mutable.

For production troubleshooting, rollback, auditing, and incident response, engineers need to answer:

> Which exact source revision produced this running container?

Project 10 introduces Git-based image tagging to solve this problem.

---

# Project Architecture

```text
                     Git Commit
                         |
                         v
                 ┌───────────────┐
                 │    Checkout   │
                 └───────┬───────┘
                         |
                         v
                 ┌───────────────┐
                 │    pytest     │
                 └───────┬───────┘
                         |
                         v
                 ┌───────────────┐
                 │ Docker Build  │
                 └───────┬───────┘
                         |
                         v
                ┌──────────────────┐
                │    One Image     │
                └────────┬─────────┘
                         |
             ┌───────────┼────────────┐
             |           |            |
             v           v            v
         Full SHA    Short SHA    1.0.0
             |           |            |
             └───────────┼────────────┘
                         |
                         v
                       latest
```

---

# CI/CD Flow

```text
Source Code
    |
    v
Checkout
    |
    v
pytest
    |
    v
Docker Build
    |
    v
Create Image Tags
    |
    ├── Full Git SHA
    ├── Short Git SHA
    ├── 1.0.0
    └── latest
    |
    v
Verify All Tags
```

---

# Technologies

| Technology     | Purpose                        |
| -------------- | ------------------------------ |
| Docker         | Container image creation       |
| Git            | Source revision identification |
| GitHub Actions | CI/CD automation               |
| Python         | Application runtime            |
| pytest         | Automated testing              |

---

# Directory Structure

```text
CI-CD-mastery/
│
├── .github/
│   └── workflows/
│       └── project-10-image-tagging.yml
│
└── project-10-image-tagging-lifecycle/
    ├── .dockerignore
    ├── Dockerfile
    ├── README.md
    ├── app.py
    └── test_app.py
```

---

# Image Tagging Strategy

Project 10 creates four meaningful references.

## 1. Full Git SHA

```text
ci-cd-mastery-project-10:<FULL_GIT_SHA>
```

Example:

```text
ci-cd-mastery-project-10:ff0def76195dad09eaf48784427f28100e7c6475
```

### Purpose

Provides an exact relationship between the Docker image and the Git commit that generated it.

This is useful for:

* Auditing
* Incident investigation
* Rollbacks
* Deployment traceability

---

# 2. Short Git SHA

```text
ci-cd-mastery-project-10:sha-<SHORT_SHA>
```

Example:

```text
ci-cd-mastery-project-10:sha-ff0def7
```

### Purpose

Provides a shorter human-readable reference while maintaining source-code traceability.

---

# 3. Semantic Version

```text
ci-cd-mastery-project-10:1.0.0
```

### Purpose

Represents a release version.

Semantic versioning generally follows:

```text
MAJOR.MINOR.PATCH
```

Example:

```text
1.0.0
1.0.1
1.1.0
2.0.0
```

---

# 4. Latest

```text
ci-cd-mastery-project-10:latest
```

### Purpose

Provides a convenient moving reference.

However:

> `latest` should not normally be used as the immutable production deployment reference.

The tag can move to different image content.

---

# Important Docker Concept

Multiple tags can reference the same image.

Conceptually:

```text
                     ┌── :full-sha
                     │
                     ├── :sha-ff0def7
Docker Image ────────┼── :1.0.0
                     │
                     └── :latest
```

The tags are references.

They do not necessarily represent four separate image builds.

---

# Why Build Once?

A mature CI/CD pipeline should avoid rebuilding the application for every environment.

Bad pattern:

```text
Build
  ↓
Staging

Rebuild
  ↓
Production
```

Potential problem:

The second build may not produce byte-for-byte identical content.

Preferred pattern:

```text
Build Once
    ↓
Test
    ↓
Scan
    ↓
Publish
    ↓
Promote Same Artifact
    ↓
Deploy
```

Project 10 establishes the image identity required for this model.

---

# GitHub Actions Workflow

The workflow is:

```text
Checkout
   ↓
Install pytest
   ↓
Run tests
   ↓
Docker build
   ↓
Create lifecycle tags
   ↓
Verify tags
```

The important commands are:

```bash
docker build
docker tag
docker image inspect
```

---

# Local Validation

## Run Tests

```bash
python -m pytest -q project-10-image-tagging-lifecycle
```

---

## Build Image

```bash
docker build \
  -t ci-cd-mastery-project-10:local \
  ./project-10-image-tagging-lifecycle
```

---

## Create Tags

```bash
docker tag \
  ci-cd-mastery-project-10:local \
  ci-cd-mastery-project-10:sha-local

docker tag \
  ci-cd-mastery-project-10:local \
  ci-cd-mastery-project-10:1.0.0

docker tag \
  ci-cd-mastery-project-10:local \
  ci-cd-mastery-project-10:latest
```

---

## Verify Tags

```bash
docker image ls ci-cd-mastery-project-10
```

And:

```bash
docker image inspect \
  ci-cd-mastery-project-10:local \
  --format '{{.Id}}'

docker image inspect \
  ci-cd-mastery-project-10:sha-local \
  --format '{{.Id}}'

docker image inspect \
  ci-cd-mastery-project-10:1.0.0 \
  --format '{{.Id}}'

docker image inspect \
  ci-cd-mastery-project-10:latest \
  --format '{{.Id}}'
```

The IDs should be identical.

This proves that the tags reference the same built image.

---

# GitHub Actions Validation

Project 10 was validated successfully through GitHub Actions.

### Workflow

```text
Project 10 - Image Tagging Lifecycle
```

### Run

```text
31520651164
```

### Result

```text
SUCCESS
```

### Validated Steps

```text
✓ Set up job
✓ Checkout
✓ Run tests
✓ Build image
✓ Create lifecycle tags
✓ Verify tags
✓ Complete job
```

---

# CI Validation Result

```text
Tests                  PASS
Docker Build           PASS
Full SHA Tag           PASS
Short SHA Tag          PASS
Semantic Version Tag   PASS
Latest Tag             PASS
Tag Verification       PASS
GitHub Actions         PASS
```

---

# Production Recommendation

For production deployments, prefer immutable image references.

### Preferred

```text
image@sha256:<digest>
```

or a controlled immutable release identifier.

### Also useful

```text
image:<full-git-sha>
```

### Avoid using as the primary production reference

```text
image:latest
```

because `latest` is mutable.

---

# Tag vs Digest

This is an important DevOps interview concept.

## Tag

Example:

```text
app:1.0.0
```

A tag is a human-readable reference.

It can potentially be moved to another image.

## Digest

Example:

```text
app@sha256:abc123...
```

A digest identifies the exact image content.

Therefore:

```text
Tag    → mutable reference
Digest → immutable content identity
```

---

# Rollback Strategy

If version `1.1.0` causes a production issue:

```text
Production
    |
    v
1.1.0  ❌
```

The deployment can be rolled back to:

```text
1.0.0  ✅
```

or, preferably, the exact immutable digest.

This makes rollback predictable and auditable.

---

# Interview Questions

## 1. Why should production avoid `latest`?

Because `latest` is mutable.

The same deployment configuration can point to different image contents at different times.

---

## 2. Why use Git SHA tags?

They provide direct traceability between:

```text
Git Commit
     ↓
Docker Image
     ↓
Deployment
```

This is extremely useful for troubleshooting and auditing.

---

## 3. What is the difference between a tag and a digest?

A tag is a reference that can move.

A digest identifies exact image content.

For strong production immutability, a digest is preferred.

---

## 4. Can multiple tags reference the same Docker image?

Yes.

For example:

```text
app:1.0.0
app:sha-abcdef1
app:latest
```

can all point to the same image.

---

## 5. Why should an image ideally be built only once?

To ensure that the artifact tested and approved is the same artifact promoted to later environments.

This reduces:

* Configuration drift
* Build inconsistency
* Supply-chain uncertainty
* Deployment surprises

---

## 6. How would you identify which Git commit produced a production container?

Use a Git SHA image tag or, preferably, record the image digest together with the Git commit SHA during the deployment.

Example:

```text
Git SHA:
ff0def76195dad09...

Image:
ci-cd-mastery-project-10:sha-ff0def7

Digest:
sha256:...
```

---

## 7. What is semantic versioning?

Semantic versioning uses:

```text
MAJOR.MINOR.PATCH
```

Example:

```text
2.4.1
```

Generally:

* MAJOR = breaking changes
* MINOR = backward-compatible features
* PATCH = backward-compatible fixes

---

# Project 10 Completion

```text
┌────────────────────────────────────────┐
│ PROJECT 10 — COMPLETE                  │
├────────────────────────────────────────┤
│ Implementation             ✅          │
│ Docker Build               ✅          │
│ pytest                     ✅          │
│ Full SHA Tag               ✅          │
│ Short SHA Tag              ✅          │
│ Semantic Version Tag       ✅          │
│ latest Tag                 ✅          │
│ Tag Verification           ✅          │
│ GitHub Actions             ✅          │
│ Commit                     ✅          │
│ Push                       ✅          │
└────────────────────────────────────────┘
```

## CI/CD Mastery Progress

```text
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
11  Image Promotion                 ▶ NEXT
```

## Key Takeaway

Project 10 establishes **artifact identity and traceability**.

The next logical step is Project 11:

```text
Build Once
   ↓
Approved Artifact
   ↓
Promote
   ↓
Staging
   ↓
Production
```

That moves the CI/CD mastery track from **artifact creation** toward **artifact promotion and release engineering**.
