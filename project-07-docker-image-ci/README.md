# Project 07 — Docker Image CI with GitHub Actions

## 🚀 CI/CD Mastery — Project 07

This project introduces **Docker image creation and container validation as part of a CI pipeline** using GitHub Actions.

The objective is to build a Docker image from application source code, validate the image metadata, start the container, verify the application output, and fail the pipeline automatically if any validation fails.

---

# 1. Project Objective

The purpose of this project is to understand how Docker integrates into a CI/CD pipeline.

The pipeline performs the following:

```text
Developer Push
      │
      ▼
GitHub Repository
      │
      ▼
GitHub Actions
      │
      ├── Checkout Source
      │
      ├── Setup Python
      │
      ├── Install pytest
      │
      ├── Run Unit Tests
      │
      ├── Build Docker Image
      │
      ├── Tag Docker Image
      │
      ├── Validate Image Metadata
      │
      ├── Run Container
      │
      ├── Validate Application Output
      │
      └── Cleanup Container
      │
      ▼
CI PASS / FAIL

The key principle is:

Never treat "docker build succeeded" as proof that the application works.

The pipeline must also start the container and validate its behavior.

2. Learning Objectives

After completing this project, you should understand:

Docker image fundamentals
Dockerfile structure
Docker build context
.dockerignore
Docker image tags
Docker containers
Container exit codes
Container logs
Docker image metadata
OCI image labels
Build arguments
Git commit traceability
GitHub Actions Docker builds
Container runtime validation
CI failure handling
Artifact traceability
Test → Build → Validate pipeline design
3. Technology Stack
Technology	Purpose
Python 3.12	Application runtime
pytest	Unit testing
Docker	Containerization
Docker BuildKit	Image building
Git	Source control
GitHub	Remote repository
GitHub Actions	CI automation
Ubuntu	CI runner
OCI labels	Image metadata
4. Repository Structure
CI-CD-mastery/
│
├── .github/
│   └── workflows/
│       └── project-07-docker-ci.yml
│
└── project-07-docker-image-ci/
    │
    ├── .dockerignore
    ├── .gitignore
    ├── Dockerfile
    ├── app.py
    ├── test_app.py
    └── README.md
5. Application

The application is intentionally simple.

app.py
APP_VERSION = "1.0.0"
DEFAULT_ENVIRONMENT = "development"


def get_application_info(environment=DEFAULT_ENVIRONMENT):
    return {
        "version": APP_VERSION,
        "environment": environment,
        "message": f"Application Version: {APP_VERSION} | Environment: {environment}",
    }


if __name__ == "__main__":
    info = get_application_info()
    print(info["message"])

The application produces:

Application Version: 1.0.0 | Environment: development

This output becomes our runtime validation target.

6. Unit Test
test_app.py
from app import get_application_info


def test_application_info_contains_version_and_environment():
    info = get_application_info("development")

    assert info["version"] == "1.0.0"
    assert info["environment"] == "development"
    assert "Application Version: 1.0.0" in info["message"]
    assert "Environment: development" in info["message"]

The test verifies:

Application version
Environment
Application message
Correct runtime information
7. Dockerfile

The Dockerfile creates the application image.

FROM python:3.12-slim

ARG APP_VERSION=1.0.0
ARG VCS_REF=unknown

LABEL org.opencontainers.image.version="${APP_VERSION}"
LABEL org.opencontainers.image.revision="${VCS_REF}"

WORKDIR /app

COPY app.py .

CMD ["python", "app.py"]
8. Dockerfile Explanation
FROM
FROM python:3.12-slim

Uses the official Python 3.12 slim image as the base image.

The slim variant is preferred here because it provides Python while avoiding unnecessary packages.

ARG
ARG APP_VERSION=1.0.0
ARG VCS_REF=unknown

Build arguments allow CI to provide information during image creation.

Example:

docker build \
  --build-arg APP_VERSION=1.0.0 \
  --build-arg VCS_REF=9c72658 \
  .
9. OCI Image Metadata

The image contains OCI-compatible metadata:

LABEL org.opencontainers.image.version="${APP_VERSION}"
LABEL org.opencontainers.image.revision="${VCS_REF}"

This allows us to associate a Docker image with:

Application Version
        +
Git Commit

For example:

Version=1.0.0
Revision=9c72658

This is important for production traceability.

If a deployment contains an incorrect application version, we can determine exactly which source revision produced the image.

10. WORKDIR
WORKDIR /app

Sets the working directory inside the container.

The application therefore exists at:

/app/app.py
11. COPY
COPY app.py .

Copies only the application file into the image.

This is intentionally minimal.

12. CMD
CMD ["python", "app.py"]

Defines the default container command.

When we execute:

docker run project-07-app:1.0.0

Docker executes:

python app.py
13. .dockerignore

The project uses:

.venv/
__pycache__/
.pytest_cache/
.git/

The purpose is to prevent unnecessary files from being sent to the Docker build context.

Benefits:

Smaller build context
Faster builds
Cleaner images
Reduced accidental file leakage
Better build hygiene
14. Local Docker Build

The image was built using:

docker build -t project-07-app:1.0.0 .

Successful output resulted in:

project-07-app:1.0.0
15. Inspecting the Image

The image can be inspected with:

docker image inspect project-07-app:1.0.0

This provides information including:

Image ID
Architecture
Operating system
Environment variables
Working directory
Command
Layers
Metadata
Root filesystem
16. Docker Image History

Use:

docker history project-07-app:1.0.0

This demonstrates Docker's layered image architecture.

Example layers include:

FROM python:3.12-slim
WORKDIR /app
COPY app.py .
CMD ["python", "app.py"]

Understanding layers is important for Docker optimization and troubleshooting.

17. Container Validation

The image was executed using:

docker run --name project-07-app-test project-07-app:1.0.0

Output:

Application Version: 1.0.0 | Environment: development

The container exited successfully with:

ExitCode=0

This proves that:

Image builds
        ↓
Container starts
        ↓
Application executes
        ↓
Application exits successfully
18. Container Failure Test

A deliberate failure was also tested.

Command:

docker run \
  --name project-07-app-failure-test \
  project-07-app:1.0.0 \
  python missing.py

Docker reported:

python: can't open file '/app/missing.py':
[Errno 2] No such file or directory

The container returned:

ExitCode=2

This is important because CI must detect application/runtime failures.

A successful Docker build alone does not guarantee successful application execution.

19. GitHub Actions Workflow

Workflow:

.github/workflows/project-07-docker-ci.yml

The workflow performs:

Checkout
   ↓
Setup Python
   ↓
Install pytest
   ↓
Run unit tests
   ↓
Get Git SHA
   ↓
Build Docker image
   ↓
Validate image metadata
   ↓
Run container
   ↓
Validate application output
   ↓
Remove test container
20. Workflow Trigger

The workflow runs on pushes to:

on:
  push:
    branches:
      - project-07-docker-image-ci

It also runs for pull requests targeting:

pull_request:
  branches:
    - main

Therefore the project has both:

Branch CI
+
Pull Request CI
21. Working Directory

The workflow uses:

defaults:
  run:
    working-directory: project-07-docker-image-ci

This is important because the repository contains multiple projects.

Without the working directory, commands such as:

python -m pytest
docker build .

could execute from the repository root instead of Project 07.

22. Python Setup

GitHub Actions installs Python 3.12:

- name: Setup Python
  uses: actions/setup-python@v5
  with:
    python-version: "3.12"
23. Installing pytest

The workflow installs the testing dependency:

- name: Install test dependency
  run: python -m pip install pytest
24. Running Unit Tests

The workflow executes:

python -m pytest -v

The successful CI result was:

collected 1 item

test_app.py::test_application_info_contains_version_and_environment
PASSED [100%]

1 passed in 0.01s

Therefore the application unit test passed before the Docker image was created.

25. Git Commit Traceability

The workflow retrieves the Git revision:

git rev-parse --short HEAD

The successful build used:

9c72658

The Docker image was tagged:

project-07-app:1.0.0
project-07-app:9c72658

This gives us two useful references:

Semantic Version
      +
Git Revision
26. Docker Image Build in CI

The workflow executes:

docker build \
  --build-arg APP_VERSION=1.0.0 \
  --build-arg VCS_REF=${{ steps.git.outputs.sha }} \
  -t project-07-app:1.0.0 \
  -t project-07-app:${{ steps.git.outputs.sha }} \
  .

The result was:

project-07-app:1.0.0
project-07-app:9c72658
27. Image Metadata Validation

The workflow executes:

docker image inspect project-07-app:1.0.0 \
  --format='Version={{index .Config.Labels "org.opencontainers.image.version"}} Revision={{index .Config.Labels "org.opencontainers.image.revision"}}'

CI produced:

Version=1.0.0 Revision=9c72658

This proves that the expected metadata was embedded into the image.

28. Container Runtime Validation

The workflow starts the image:

docker run --name project-07-container-test \
  project-07-app:1.0.0 > container-output.txt

Then:

cat container-output.txt

Expected output:

Application Version: 1.0.0 | Environment: development

The pipeline then validates:

grep -q "Application Version: 1.0.0" container-output.txt
grep -q "Environment: development" container-output.txt

If either string is missing, the CI job fails.

29. Why Runtime Validation Matters

Consider this situation:

Dockerfile syntax
       ↓
       ✓
Docker build
       ↓
       ✓
Image created
       ↓
       ✓
Application starts
       ↓
       ✗
Application crashes

A pipeline that only performs:

docker build .

would incorrectly report success.

Project 07 prevents this by performing:

Build
 ↓
Run
 ↓
Validate

This is a much stronger CI design.

30. CI Failure Behavior

GitHub Actions commands normally run with shell error handling enabled.

For example:

grep -q "Application Version: 1.0.0" container-output.txt

If the string is not found, grep returns a non-zero exit code.

The workflow then fails.

Therefore:

Expected output
      ↓
      ✓
CI continues

Unexpected output
      ↓
      ✗
CI fails
31. Complete CI Architecture
                  Developer
                      │
                      │ git push
                      ▼
              GitHub Repository
                      │
                      ▼
             GitHub Actions Runner
                      │
          ┌───────────┴───────────┐
          │                       │
          ▼                       ▼
     Python Setup             Docker Engine
          │                       │
          ▼                       │
       pytest                     │
          │                       │
          ▼                       ▼
     Unit Tests             Docker Build
          │                       │
          │                       ▼
          │                 Docker Image
          │                       │
          │                 ┌─────┴─────┐
          │                 │           │
          │                 ▼           ▼
          │              Metadata    Container
          │              Validation   Runtime
          │                 │           │
          │                 └─────┬─────┘
          │                       │
          └───────────┬───────────┘
                      ▼
                  CI Result
                 PASS / FAIL
32. CI Design Principles Learned
Principle 1 — Test before packaging
Code
 ↓
Unit Test
 ↓
Docker Build

Do not package known-broken code.

Principle 2 — Build reproducible artifacts

The Docker image should be associated with:

Version
+
Git Revision
Principle 3 — Validate runtime behavior

Always consider:

docker run

not only:

docker build
Principle 4 — Fail fast

If:

pytest fails

the image should not be built.

Principle 5 — Traceability

A production image should answer:

Which version is this?

and:

Which source commit produced it?

33. Important Docker Commands
Build
docker build -t project-07-app:1.0.0 .
List images
docker images
Run container
docker run project-07-app:1.0.0
Run with name
docker run --name project-07-app-test project-07-app:1.0.0
List containers
docker ps -a
View logs
docker logs project-07-app-test
Inspect container
docker inspect project-07-app-test
Inspect image
docker image inspect project-07-app:1.0.0
Image history
docker history project-07-app:1.0.0
Remove container
docker rm project-07-app-test
34. Important GitHub CLI Commands

List workflow runs:

gh run list --limit 5

View a run:

gh run view <RUN_ID>

View job logs:

gh run view <RUN_ID> --log

View a specific job:

gh run view <RUN_ID> --job=<JOB_ID>
35. Project 07 CI Result

The final GitHub Actions run successfully completed:

Project 07 - Docker Image CI

Job:

Test, Build and Validate Container

The CI pipeline confirmed:

✓ Checkout source
✓ Python 3.12 setup
✓ pytest installation
✓ Unit test
✓ Docker image build
✓ Image tagging
✓ Image metadata validation
✓ Container execution
✓ Application output validation
✓ Container cleanup
✓ CI success

The successful run produced:

Version=1.0.0 Revision=9c72658

and:

Application Version: 1.0.0 | Environment: development
36. What I Can Explain in an Interview

A strong interview explanation would be:

"In Project 07, I implemented a Docker-based CI pipeline using GitHub Actions. The pipeline first checks out the source code and executes Python unit tests. If the tests pass, it builds a Docker image using Python 3.12-slim. During the build I inject application version and Git revision metadata using Docker build arguments and OCI labels. I create both a semantic version tag and a Git revision tag for traceability. After building the image, the pipeline validates the embedded metadata using docker image inspect. Finally, it runs the container and validates the actual application output. This prevents a false-positive CI result where the Docker image builds successfully but the application fails at runtime."

37. Interview Questions
Docker Fundamentals
Q1. What is a Docker image?

A Docker image is an immutable template containing the application, runtime, libraries, configuration, and filesystem layers required to create a container.

Q2. What is a Docker container?

A container is a running instance of a Docker image.

Image
 ↓
Container
Q3. Image vs container?
Image	Container
Immutable template	Runtime instance
Stored artifact	Running/stopped process
Built	Created from image
Can have tags	Has container name/ID
Q4. What is a Dockerfile?

A Dockerfile is a declarative instruction file used to build a Docker image.

Q5. Why use python:3.12-slim?

It provides Python while keeping the base image smaller than a full distribution image.

38. Dockerfile Interview Questions
Q6. What does FROM do?

Defines the base image.

Q7. What is WORKDIR?

Sets the working directory inside the image/container.

Q8. Difference between COPY and ADD?

COPY is generally preferred for straightforward file copying.

ADD has additional behavior such as archive extraction and URL handling.

Q9. Difference between CMD and ENTRYPOINT?

CMD provides the default command/arguments.

ENTRYPOINT defines the executable that normally forms the container's main process.

Q10. What is a Docker build context?

The build context is the set of files available to the Docker build.

Example:

docker build .

The . represents the build context.

39. Docker Layer Questions
Q11. What are Docker image layers?

Docker images are composed of filesystem layers created from Dockerfile instructions and base image layers.

Q12. Why are layers useful?

They enable caching and reduce repeated work during builds.

Q13. How can you inspect layers?
docker history image-name
40. Docker CI Questions
Q14. Why build Docker images in CI?

To ensure every accepted source change can produce a validated container artifact automatically.

Q15. Why run tests before Docker build?

Because building a container for code that already fails unit tests wastes CI resources and can produce invalid artifacts.

Q16. Why validate the container after building?

Because successful image creation does not guarantee successful application startup.

Q17. Why tag the image with Git SHA?

For source-to-artifact traceability.

Example:

Git commit
9c72658
     ↓
Docker image
project-07-app:9c72658
41. Metadata Questions
Q18. Why use OCI labels?

OCI labels provide standardized metadata associated with container images.

Example:

org.opencontainers.image.version
org.opencontainers.image.revision
Q19. Why is image metadata useful?

It helps operations teams identify:

application version
source revision
release information
artifact provenance
Q20. How did you validate image metadata?

Using:

docker image inspect

with a Go template:

--format='Version={{index .Config.Labels "org.opencontainers.image.version"}} Revision={{index .Config.Labels "org.opencontainers.image.revision"}}'
42. Container Runtime Questions
Q21. How do you check container logs?
docker logs <container>
Q22. How do you check the exit code?
docker inspect \
  --format='{{.State.ExitCode}}' \
  <container>
Q23. What does exit code 0 mean?

Successful process completion.

Q24. What happened in your intentional failure test?

The container attempted:

python missing.py

Since the file did not exist, Python returned:

ExitCode=2

This demonstrated that runtime failures can be detected.

43. GitHub Actions Questions
Q25. What is GitHub Actions?

A CI/CD automation platform integrated into GitHub.

Q26. What is a workflow?

A YAML-defined automation process executed by GitHub Actions.

Q27. What is a job?

A group of steps executed on a runner.

Q28. What is a step?

An individual operation within a job.

Examples:

Checkout
Setup Python
Run pytest
Build Docker image
Validate container
Q29. Why use defaults.run.working-directory?

Because this repository contains multiple projects.

It ensures Project 07 commands execute inside:

project-07-docker-image-ci/
44. Advanced Interview Questions
Q30. What would you improve for production?

Potential improvements include:

Docker image vulnerability scanning
        ↓
SBOM generation
        ↓
Image signing
        ↓
Registry push
        ↓
Immutable release tags
        ↓
Deployment

For example:

Source
 ↓
Unit Tests
 ↓
Docker Build
 ↓
Trivy Scan
 ↓
SBOM
 ↓
Sign Image
 ↓
Push to ECR/GHCR
 ↓
Deploy

These capabilities will be introduced in later CI/CD mastery projects.

45. Common Failure Scenarios
Failure 1 — Dockerfile not found

Error:

failed to read dockerfile:
open Dockerfile: no such file or directory

Cause:

Running:

docker build .

from the repository root instead of:

project-07-docker-image-ci/
Failure 2 — pytest not installed

Error:

No module named pytest

Cause:

System Python did not have pytest installed.

Solution:

Use a project virtual environment or install:

python -m pip install pytest

CI installs pytest explicitly.

Failure 3 — Container name conflict

Error:

Conflict. The container name is already in use

Cause:

Docker container names must be unique.

Solution:

docker rm <container-name>
Failure 4 — Application file missing

Example:

python: can't open file '/app/missing.py'

This produces a non-zero container exit code.

46. Production Evolution

Project 07 represents the foundation.

Current:

Code
 ↓
Test
 ↓
Docker Build
 ↓
Container Validation

A production-grade pipeline evolves toward:

Code
 ↓
Lint
 ↓
Unit Tests
 ↓
Security Scan
 ↓
Docker Build
 ↓
SBOM
 ↓
Image Scan
 ↓
Image Signing
 ↓
Registry Push
 ↓
Deployment
 ↓
Health Check
 ↓
Monitoring

This is the direction of the later projects in the CI/CD mastery roadmap.

47. Key Takeaways

The most important lessons from Project 07 are:

A Docker build is not enough.
Always validate container runtime behavior.
Use .dockerignore to control build context.
Use meaningful image tags.
Associate images with Git revisions.
Use OCI metadata for traceability.
Run unit tests before building the image.
Make CI fail when runtime validation fails.
Keep Docker images minimal.
Treat the Docker image as a CI artifact.
48. Project Completion Checklist
[✓] Application created
[✓] Unit test created
[✓] Dockerfile created
[✓] .dockerignore created
[✓] .gitignore created
[✓] Docker image built locally
[✓] Docker image inspected
[✓] Docker image history inspected
[✓] Container executed
[✓] Container logs validated
[✓] Container failure scenario tested
[✓] Docker metadata implemented
[✓] Git SHA tagging implemented
[✓] GitHub Actions workflow created
[✓] Unit tests executed in CI
[✓] Docker build executed in CI
[✓] Image metadata validated in CI
[✓] Container runtime validated in CI
[✓] CI pipeline passed
[✓] Changes pushed to GitHub
49. Final Project Status
✅ PROJECT 07 COMPLETE

Project 07 successfully demonstrates:

GitHub
   │
   ▼
GitHub Actions
   │
   ▼
Python Unit Tests
   │
   ▼
Docker Build
   │
   ▼
Version + Git Metadata
   │
   ▼
Docker Image
   │
   ▼
Container Runtime Test
   │
   ▼
Application Validation
   │
   ▼
CI PASS

Project 07 — Docker Image CI is complete.

Next Project

The next stage should build on this foundation by introducing:

Docker Image
     ↓
Container Registry
     ↓
Image Push
     ↓
Versioned Artifact
     ↓
Pull / Verify

This will move the mastery roadmap from building containers toward publishing and consuming container artifacts in a real CI/CD lifecycle.
