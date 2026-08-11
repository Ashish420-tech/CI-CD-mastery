# Project 11 — Docker Image Promotion

## Objective

Demonstrate the enterprise CI/CD principle:

> Build once, promote the same artifact.

## Problem

Rebuilding an application separately for staging and production can produce different artifacts.

Bad:

```text
Build → Staging
Rebuild → Production
Preferred:

Build Once
   ↓
Approved Artifact
   ↓
Staging
   ↓
Production
Implementation

The workflow:

Runs pytest
Builds one Docker image
Records the image ID
Creates a staging tag
Creates a production tag
Verifies all tags reference the same image ID
Promotion Model
                  Docker Build
                       |
                       v
                ci-cd-mastery:build
                       |
              ┌────────┴────────┐
              v                 v
           staging          production
              |                 |
              └────────┬────────┘
                       v
                 SAME IMAGE ID
Local Validation
docker build \
  -t ci-cd-mastery-project-11:build \
  ./project-11-image-promotion

docker tag \
  ci-cd-mastery-project-11:build \
  ci-cd-mastery-project-11:staging

docker tag \
  ci-cd-mastery-project-11:build \
  ci-cd-mastery-project-11:production

Verify:

docker image inspect ci-cd-mastery-project-11:build \
  --format '{{.Id}}'

docker image inspect ci-cd-mastery-project-11:staging \
  --format '{{.Id}}'

docker image inspect ci-cd-mastery-project-11:production \
  --format '{{.Id}}'

All IDs must be identical.

Interview Questions
Why build once?

To ensure the artifact tested and approved is the same artifact promoted to later environments.

Why not rebuild for production?

A second build can introduce differences between the tested artifact and the production artifact.

Tag vs artifact?

Tags are references. The underlying image is the artifact being promoted.

What is the stronger production model?

Build once, scan once, publish once, then promote the same immutable artifact using controlled environment references or its digest.

Result
Tests                    ✅
Docker Build             ✅
Staging Promotion        ✅
Production Promotion     ✅
Same Artifact Validation  ✅
