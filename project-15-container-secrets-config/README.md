# 🚀 Project 15 — Container Runtime Configuration & Secrets

![Docker](https://img.shields.io/badge/Docker-Container-blue?logo=docker)
![Python](https://img.shields.io/badge/Python-3.12-blue?logo=python)
![Flask](https://img.shields.io/badge/Flask-Application-black?logo=flask)
![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-CI-success?logo=githubactions)
![Status](https://img.shields.io/badge/Status-Completed-success)

> **CI/CD Mastery — Project 15**

---

# 📌 Project Overview

Project 15 demonstrates how to separate **application configuration from the Docker image**.

The project focuses on runtime environment variables and introduces the security principles required when handling secrets in containerized applications.

The core principle is:

> **Build the image once and provide environment-specific configuration at runtime.**

Instead of rebuilding an image for every environment:

```text
Development Image
Staging Image
Production Image

we use:

                    Same Docker Image
                           |
              +------------+------------+
              |            |            |
              v            v            v
        Development     Staging     Production
        configuration  configuration configuration
🎯 Objectives

This project demonstrates:

Docker environment variables
Runtime configuration
Immutable container images
Environment-specific configuration
Docker ENV
Docker -e / --env
Runtime environment inspection
Healthchecks
Configuration validation
Secret-management principles
CI/CD validation
🏢 Enterprise Problem

A common anti-pattern is rebuilding an application image whenever the environment changes.

For example:

Development
     ↓
Build image
     ↓
Change configuration
     ↓
Build another image
     ↓
Staging
     ↓
Build another image
     ↓
Production

This creates unnecessary image variations.

A better approach is:

Application Source
        ↓
   Docker Build
        ↓
Immutable Image
        ↓
Runtime Configuration
        ↓
Development / Staging / Production
🏗️ Architecture
                         Git Repository
                               |
                               v
                         Docker Build
                               |
                               v
                    Immutable Docker Image
                               |
                +--------------+--------------+
                |              |              |
                v              v              v
          Development       Staging       Production
                |              |              |
                +--------------+--------------+
                               |
                               v
                       Runtime Environment
                               |
                +--------------+--------------+
                |              |              |
                v              v              v
          APP_VERSION    ENVIRONMENT    APP_MESSAGE
                               |
                               v
                         Flask Application
                               |
                               v
                           /health
📁 Project Structure
project-15-container-secrets-config/
│
├── .dockerignore
├── Dockerfile
├── README.md
├── app.py
└── test_app.py

GitHub Actions:

.github/
└── workflows/
    └── project-15-container-secrets-config.yml
🐍 Application

The project uses Flask.

Endpoints:

GET /
GET /health
GET /config

The /config endpoint exposes only non-sensitive configuration for demonstration.

Example:

{
  "environment": "production",
  "version": "2.5.0"
}
⚙️ Runtime Configuration

The application reads configuration using:

os.getenv()

Example:

os.getenv("APP_VERSION", "1.0.0")

This means the application can use a runtime-provided value without modifying the application image.

🐳 Docker Configuration

The Dockerfile contains default configuration:

ENV APP_VERSION=1.0.0
ENV ENVIRONMENT=development

These are defaults, not secrets.

They can be overridden when starting the container.

▶️ Runtime Environment Variables

The container was started using:

docker run -d \
  --name project-15-app \
  -p 8093:5000 \
  -e APP_VERSION=2.5.0 \
  -e ENVIRONMENT=production \
  -e APP_MESSAGE="Runtime configuration works" \
  ci-cd-mastery-project-15:1.0.0

The image itself did not need to be rebuilt.

🔍 Verify Runtime Configuration

Inspect the environment:

docker exec project-15-app env \
  | grep -E 'APP_VERSION|ENVIRONMENT|APP_MESSAGE'

Expected:

APP_VERSION=2.5.0
ENVIRONMENT=production
APP_MESSAGE=Runtime configuration works

Application configuration:

curl -fsS http://localhost:8093/config

Expected:

{
  "environment": "production",
  "version": "2.5.0"
}
❤️ Healthcheck

The project retains the Docker healthcheck pattern introduced in Project 13.

Docker verifies:

GET /health

Expected:

{
  "status": "healthy"
}

Validation:

docker inspect project-15-app \
  --format 'status={{.State.Status}} health={{.State.Health.Status}}'

Expected:

status=running health=healthy
🔐 Secrets vs Configuration

This distinction is extremely important.

Configuration

Examples:

APP_VERSION
ENVIRONMENT
APP_MESSAGE

These are generally application configuration values.

They can be supplied through:

-e VARIABLE=value
Secrets

Examples:

Database passwords
API tokens
Private keys
Cloud credentials
Access tokens

These should not be hardcoded into:

Dockerfile
Source code
Git repository
README
Docker image
❌ Bad Practice

Never do this:

ENV DB_PASSWORD=mysecret

Never commit:

.env

containing real credentials.

Never hardcode:

PASSWORD = "my-production-password"

Never put real credentials directly into a GitHub Actions YAML file.

✅ Better Secret Flow

A production architecture should look like:

Secret Manager
      |
      v
CI/CD / Orchestrator
      |
      v
Container Runtime
      |
      v
Application

Examples of secret-management systems include:

GitHub Actions Secrets
Kubernetes Secrets
AWS Secrets Manager
AWS Systems Manager Parameter Store
HashiCorp Vault

The exact secret-management technology depends on the platform and architecture.

🔒 .dockerignore

The project excludes sensitive/local files:

.env
*.pem
*.key
.venv
.git
.github

This prevents these files from unnecessarily entering the Docker build context.

However:

.dockerignore is not a secret-management solution.

It reduces accidental inclusion; it does not replace proper secret management.

🧪 Automated Testing

Run:

python -m pytest -q project-15-container-secrets-config

Expected:

3 passed

Tests validate:

Application response
Health endpoint
Runtime configuration
🔄 CI/CD Pipeline

The GitHub Actions workflow validates the complete lifecycle:

Checkout
   ↓
Python Setup
   ↓
Install Dependencies
   ↓
Run Tests
   ↓
Build Docker Image
   ↓
Run Container
   ↓
Inject Runtime Configuration
   ↓
Wait for Healthy
   ↓
Verify Configuration
   ↓
Verify Environment
   ↓
Verify /health
   ↓
Cleanup

Workflow:

.github/workflows/project-15-container-secrets-config.yml
⚙️ CI Runtime Configuration

The CI pipeline runs:

docker run -d \
  --name project-15-app \
  -p 8093:5000 \
  -e APP_VERSION=2.5.0 \
  -e ENVIRONMENT=production \
  -e APP_MESSAGE="Runtime configuration works" \
  ci-cd-mastery-project-15:1.0.0

The workflow then verifies:

environment = production
version = 2.5.0

and checks:

container = running
health = healthy
📊 Validation Results
Local
Python tests                  ✅ 3 passed
Docker image                  ✅ Built
Container startup             ✅
Runtime configuration         ✅
Environment variables        ✅
Docker health                 ✅ healthy
/config endpoint              ✅
/health endpoint              ✅

Runtime evidence:

status=running health=healthy

APP_VERSION=2.5.0
ENVIRONMENT=production
APP_MESSAGE=Runtime configuration works
🚀 GitHub Actions

Dedicated workflow:

Project 15 - Container Secrets and Configuration

Successful run:

Run ID: 31576056426
Status: SUCCESS

The pipeline validated:

Tests                       ✅
Docker build                ✅
Container startup           ✅
Runtime configuration       ✅
Healthcheck                 ✅
Environment validation      ✅
HTTP validation             ✅
Cleanup                     ✅
🎤 Interview Questions & Answers
1. Why should configuration be separated from the Docker image?

Because the same immutable image should be deployable across multiple environments.

This prevents unnecessary rebuilds.

2. What is the twelve-factor principle related to configuration?

Application configuration should be separated from application code and supplied through the environment.

This allows the same application artifact to run in different environments.

3. What is the difference between ENV in Dockerfile and -e in docker run?

ENV defines a default environment variable inside the image.

-e supplies or overrides the variable when the container starts.

Example:

ENV ENVIRONMENT=development

Then:

docker run -e ENVIRONMENT=production image

The runtime value becomes:

production
4. Why shouldn't passwords be stored in a Dockerfile?

Because Dockerfile contents become part of the image build history/layers and source repository.

Credentials can therefore be exposed to users who can inspect the image or repository.

5. Are environment variables always secure for secrets?

No.

Environment variables are convenient but can potentially be exposed through:

Process inspection
Container inspection
Debugging
Logs
Application errors
Misconfigured monitoring

Sensitive credentials should use an appropriate secret-management mechanism.

6. What is an immutable image?

An immutable image is a versioned artifact that is built once and not modified between environments.

Example:

myapp:1.0.0

The same image can be deployed to:

Development
Staging
Production

with different runtime configuration.

7. What is the benefit of "build once, deploy many"?

It reduces differences between environments.

Instead of:

Build → Development
Build → Staging
Build → Production

we use:

Build once
    ↓
Same artifact
    ↓
Development
Staging
Production
8. What should be stored in a secret manager?

Sensitive values such as:

Passwords
API tokens
Private keys
Cloud credentials
Database credentials
9. What should not be committed to Git?

Never commit:

Passwords
Private keys
API tokens
AWS credentials
Production secrets
10. Is .dockerignore enough to protect secrets?

No.

.dockerignore helps prevent accidental files from entering the Docker build context.

It does not provide encryption, access control, rotation, auditing, or secure secret delivery.

11. What is a Docker build argument?

Docker supports:

docker build --build-arg NAME=value .

Build arguments are intended for build-time customization.

They should not be treated as a secure secret store.

12. What is the difference between build-time and runtime configuration?
Build-time

Available while creating the image.

docker build
Runtime

Available when starting the container.

docker run

Project 15 primarily demonstrates runtime configuration.

13. How would you provide secrets to Kubernetes?

Depending on the architecture, Kubernetes Secrets can be used and mounted or exposed to containers as environment variables/files.

For higher security requirements, external secret-management systems can also be integrated.

14. How would you handle AWS credentials in production?

I would avoid hardcoding credentials and prefer IAM roles or workload identity mechanisms where possible.

For workloads that genuinely require stored secrets, I would use a managed secret store such as AWS Secrets Manager.

15. Explain Project 15 in an interview.

"Project 15 demonstrates runtime configuration in Docker. I built an immutable Flask image and injected environment-specific configuration at container startup using environment variables. I verified that the same image could run with production configuration without rebuilding it. I also implemented health validation and automated the entire process through GitHub Actions. The project additionally demonstrates why sensitive values such as passwords and API credentials should not be baked into Docker images or committed to Git."

🧠 Key DevOps Lesson

Project 15 establishes:

Immutable Artifact
       +
Externalized Configuration
       +
Secure Secret Management

The production model becomes:

                    Application
                         |
                         v
                  Immutable Image
                         |
              +----------+----------+
              |                     |
              v                     v
        Configuration            Secrets
              |                     |
              v                     v
        Runtime Config        Secret Manager
              |                     |
              +----------+----------+
                         |
                         v
                      Container
🏆 Completion Checklist
 Project branch
 Flask application
 Runtime configuration
 Dockerfile
 Docker environment variables
 Runtime environment overrides
 .dockerignore
 Docker healthcheck
 Python tests
 Local container validation
 Configuration validation
 GitHub Actions
 CI health validation
 CI configuration validation
 Cleanup
 Successful GitHub Actions run
 README
🏆 PROJECT 15 — COMPLETED

Core lesson:

BUILD ONCE
    ↓
IMMUTABLE IMAGE
    ↓
CONFIGURE AT RUNTIME
    ↓
MANAGE SECRETS SECURELY
