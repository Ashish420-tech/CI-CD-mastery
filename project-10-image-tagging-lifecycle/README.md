# Project 10 — Image Tagging & Lifecycle

## Objective

Implement traceable Docker image tagging for CI/CD.

The project demonstrates how one Docker image can have multiple tags representing:

- Git commit identity
- Short commit identity
- Release version
- Moving reference

## Enterprise Problem

A container image needs to be traceable back to the source revision that produced it.

Using only:

```text
latest

does not provide reliable release traceability because the tag is mutable.

Project 10 introduces multiple tags:

Git commit
    |
    +--> full commit SHA
    |
    +--> short commit SHA
    |
    +--> semantic version
    |
    +--> latest
Pipeline
Source Code
    |
    v
pytest
    |
    v
Docker Build
    |
    v
Immutable Commit Tag
    |
    +----> short SHA
    |
    +----> 1.0.0
    |
    +----> latest
    |
    v
Tag Validation
Tags
Full SHA
ci-cd-mastery-project-10:<full-git-sha>

Provides the strongest direct relationship between the image and the exact source revision.

Short SHA
ci-cd-mastery-project-10:sha-abcdef1

Provides a shorter human-friendly identifier.

Semantic Version
ci-cd-mastery-project-10:1.0.0

Represents a release version.

latest
ci-cd-mastery-project-10:latest

A mutable reference to the most recently tagged image.

Production Recommendation

Production deployments should prefer immutable references such as:

image digest
full commit SHA tag
release tag controlled by the release process

Avoid using latest as the primary production deployment reference.

Why Multiple Tags?

One Docker image can have multiple tags.

Conceptually:

                 +--> :full-sha
                 |
Docker Image ----+--> :sha-abcdef1
                 |
                 +--> :1.0.0
                 |
                 +--> :latest

The tags provide different operational views of the same artifact.

Validation

The GitHub Actions workflow validates:

Python tests
Docker image build
Full SHA tag
Short SHA tag
Semantic version tag
latest tag

The workflow uses docker image inspect to prove that every expected tag exists.

Interview Questions
1. Why is latest dangerous for production?

latest is mutable. A deployment referencing latest may resolve to a different image later.

2. Why use a Git SHA tag?

It creates a direct relationship between a container artifact and the source revision that produced it.

3. Tag vs digest?

A tag is a human-managed reference and can move.

A digest identifies the exact immutable image content.

4. Can multiple tags reference one Docker image?

Yes. Multiple tags can point to the same image ID and content.

5. What is a good production image reference?

An immutable digest or another immutable release identifier is preferred.

Project Result
Tests                 ✅
Docker Build          ✅
Full SHA Tag          ✅
Short SHA Tag         ✅
Semantic Version Tag  ✅
Latest Tag            ✅
Tag Validation        ✅
GitHub Actions        ✅

EOF


### 5. Validate locally before committing

```bash
git diff --check
