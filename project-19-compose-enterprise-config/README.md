# 🚀 Project 19 — Enterprise Docker Compose Configuration Management

![Docker](https://img.shields.io/badge/Docker-Container-blue?logo=docker)
![Docker Compose](https://img.shields.io/badge/Docker%20Compose-Enterprise-blue?logo=docker)
![Python](https://img.shields.io/badge/Python-3.12-blue?logo=python)
![Flask](https://img.shields.io/badge/Flask-Application-black?logo=flask)
![Redis](https://img.shields.io/badge/Redis-Database-red?logo=redis)
![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-CI-success?logo=githubactions)
![Status](https://img.shields.io/badge/Status-Completed-success)

> **CI/CD Mastery — Project 19**

---

## 📌 Project Overview

Project 19 upgrades the Docker Compose architecture from Project 18 into an **enterprise-style configuration management model**.

The objective is to separate application configuration from the container image and support environment-specific runtime configuration.

The project demonstrates:

- Docker Compose variable substitution
- `.env`
- `.env.example`
- Environment-specific configuration
- Runtime configuration injection
- Configuration validation
- Git protection for `.env`
- Feature flags
- Container environment verification
- Healthchecks
- CI/CD configuration validation

The core principle is:

> **Configuration belongs outside the application image.**

The same application image should be capable of running in different environments with different runtime configuration.

---

# 🎯 Objectives

This project demonstrates:

1. Externalized configuration
2. Compose environment variable substitution
3. `.env` usage
4. `.env.example` standards
5. Environment-specific configuration
6. Runtime configuration verification
7. Feature flag configuration
8. Configuration validation
9. Protection of local configuration files
10. Automated CI validation

---

# 🏗️ Architecture

```text
                    Configuration Layer
                           |
              +------------+------------+
              |                         |
              v                         v
        .env.example                  .env
        Safe template              Local runtime
              |                         |
              +------------+------------+
                           |
                           v
                    Docker Compose
                           |
                  Variable Substitution
                           |
                           v
                  Container Environment
                           |
              +------------+------------+
              |                         |
              v                         v
          Flask API                  Redis
              |                         |
              +------ redis:6379 -------+
📁 Project Structure
project-19-compose-enterprise-config/
│
├── .dockerignore
├── .env
├── .env.example
├── .gitignore
├── Dockerfile
├── README.md
├── app.py
├── compose.yml
├── requirements.txt
└── test_app.py

.env is intentionally ignored by Git and must not be committed.

GitHub Actions:

.github/
└── workflows/
    └── project-19-compose-enterprise-config.yml
🔐 Configuration Management

Project 19 separates:

Application Code
       +
Container Image
       +
Runtime Configuration

Instead of hard-coding environment-specific values into the application image.

Example:

Same image
   |
   +---- development
   |
   +---- staging
   |
   +---- production

The runtime configuration changes without rebuilding the application image.

📄 .env.example

.env.example provides safe configuration defaults and acts as a configuration template.

Example:

APP_NAME=project-19
APP_VERSION=1.0.0
ENVIRONMENT=development
LOG_LEVEL=INFO

API_PORT=8097

REDIS_HOST=redis
REDIS_PORT=6379

FEATURE_COUNTER=true

It is safe to commit because it contains configuration structure rather than production secrets.

🔒 .env

.env contains local runtime configuration.

Example:

APP_NAME=project-19
APP_VERSION=1.0.0
ENVIRONMENT=development
LOG_LEVEL=INFO

API_PORT=8097

REDIS_HOST=redis
REDIS_PORT=6379

FEATURE_COUNTER=true

The file is excluded through:

.env

in .gitignore.

⚠️ Secrets

Real credentials must not be stored in:

.env
.env.example
compose.yml
Dockerfile
Git repository

For production CI/CD systems, secrets should be supplied through appropriate secret-management mechanisms.

Project 19 intentionally focuses on non-secret runtime configuration.

🐳 Docker Compose

The Compose file consumes environment variables using:

ports:
  - "${API_PORT}:5000"

and:

environment:
  APP_NAME: "${APP_NAME}"
  APP_VERSION: "${APP_VERSION}"
  ENVIRONMENT: "${ENVIRONMENT}"
  LOG_LEVEL: "${LOG_LEVEL}"
  REDIS_HOST: "${REDIS_HOST}"
  REDIS_PORT: "${REDIS_PORT}"
  FEATURE_COUNTER: "${FEATURE_COUNTER}"

This allows Compose to inject configuration dynamically.

🔄 Configuration Flow
.env
  |
  v
Docker Compose
  |
  v
Variable substitution
  |
  v
Container environment
  |
  v
Flask application
  |
  v
/config endpoint
🔍 Validate Configuration

Run:

docker compose config

This renders the resolved Compose configuration.

When .env exists, the configuration contains values such as:

APP_NAME: project-19
APP_VERSION: 1.0.0
ENVIRONMENT: development
LOG_LEVEL: INFO
REDIS_HOST: redis
REDIS_PORT: "6379"
FEATURE_COUNTER: "true"
published: "8097"
🧪 Missing Configuration Test

Temporarily move .env:

mv .env .env.backup

Run:

docker compose config

Compose reports missing variables and defaults them to blank values.

Example:

The "API_PORT" variable is not set.
Defaulting to a blank string.

This proves that the Compose file is actually using environment-variable substitution.

Restore:

mv .env.backup .env

Then:

docker compose config

The configuration resolves correctly again.

🛡️ .env Git Protection

Verify:

git check-ignore -v .env

Project result:

project-19-compose-enterprise-config/.gitignore:1:.env  .env

This prevents the local environment file from accidentally being tracked.

🐍 Application

The Flask application supports:

GET /
GET /health
GET /config
GET /counter
/ Endpoint
curl -fsS http://localhost:8097/

Returns application metadata.

/config Endpoint
curl -fsS http://localhost:8097/config

Example:

{
  "application": "project-19",
  "counter_enabled": true,
  "environment": "development",
  "log_level": "INFO",
  "redis_host": "redis",
  "redis_port": 6379,
  "version": "1.0.0"
}

This endpoint demonstrates that configuration supplied externally has reached the running application.

❤️ /health
curl -fsS http://localhost:8097/health

Expected:

{
  "redis": "healthy",
  "status": "healthy"
}
🔢 Feature Flag

Project 19 introduces:

FEATURE_COUNTER=true

When enabled:

curl -fsS http://localhost:8097/counter

returns the Redis-backed counter.

The application can therefore change behavior through configuration rather than source-code modification.

🔄 Environment Override

The application configuration can be changed without modifying application code.

Example:

APP_VERSION=2.0.0
ENVIRONMENT=staging

After restarting the Compose stack:

docker compose up -d

the application reports:

{
  "environment": "staging",
  "version": "2.0.0"
}

This demonstrates runtime configuration externalization.

🧪 Tests

Run:

python3 -m pytest -q project-19-compose-enterprise-config

Project result:

4 passed

Tests validate:

Application endpoint
Health endpoint
Configuration endpoint
Counter endpoint

Redis is mocked during unit tests.

Actual API-to-Redis integration is validated by the Compose workflow.

🚀 Docker Compose Commands

Start:

docker compose up -d --build

Status:

docker compose ps

Logs:

docker compose logs

Configuration:

docker compose config

Stop:

docker compose stop

Remove stack:

docker compose down

Remove stack and volumes:

docker compose down -v
🔄 CI/CD Pipeline

Workflow:

.github/workflows/project-19-compose-enterprise-config.yml

Pipeline:

Checkout
   ↓
Python setup
   ↓
Install dependencies
   ↓
Run tests
   ↓
Create CI configuration
   ↓
Verify .env protection
   ↓
Validate Compose
   ↓
Build stack
   ↓
Start containers
   ↓
Verify API health
   ↓
Verify Redis health
   ↓
Verify runtime configuration
   ↓
Verify API → Redis
   ↓
Verify counter
   ↓
Verify container environment
   ↓
Show logs
   ↓
Cleanup
🏆 CI Validation

Successful workflow:

Project 19 - Compose Enterprise Configuration

Run:

31580934783

Job:

enterprise-config

Duration:

49 seconds

Result:

SUCCESS ✅
✅ CI Steps Passed
✓ Set up job
✓ Checkout
✓ Set up Python
✓ Install dependencies
✓ Run tests
✓ Create CI environment configuration
✓ Verify .env is ignored
✓ Validate Compose configuration
✓ Build and start stack
✓ Show Compose services
✓ Wait for API health
✓ Verify Redis health
✓ Verify runtime configuration
✓ Verify health endpoint
✓ Verify counter
✓ Verify container environment
✓ Show logs
✓ Cleanup
✓ Complete job
🎤 Enterprise Interview Questions
1. Why externalize configuration?

Externalized configuration allows the same application image to run across different environments without rebuilding the image.

Same Image
   |
   +── Dev Configuration
   +── Staging Configuration
   +── Production Configuration
2. What is .env used for in Docker Compose?

.env can provide values used for Compose variable interpolation.

Example:

API_PORT=8097

and:

ports:
  - "${API_PORT}:5000"
3. What is .env.example?

It is a safe template showing the required configuration variables without exposing real secrets.

4. Should .env be committed?

Normally, a local .env containing environment-specific values should be ignored.

.env

should generally be included in .gitignore.

5. Why is .env.example committed?

It documents required configuration for developers and CI/CD systems.

6. What happens if a Compose variable is missing?

Depending on the Compose configuration and syntax, an unset variable may be substituted with an empty value and Compose can emit a warning.

For example:

The "API_PORT" variable is not set.
Defaulting to a blank string.

This can lead to an invalid or unintended runtime configuration.

7. How would you prevent missing configuration in production?

Use explicit configuration validation.

For critical variables, Compose variable syntax can require a value rather than silently accepting an empty string.

For example:

"${API_PORT:?API_PORT must be set}"

This is a useful production-hardening technique.

8. Why shouldn't secrets be stored in .env committed to Git?

Because Git history is persistent and credentials can be exposed through repository access, logs or accidental publication.

Production secrets should be managed through dedicated secret-management systems.

9. What is configuration drift?

Configuration drift occurs when environments gradually diverge from their intended configuration.

Example:

Development → configuration A
Staging     → configuration B
Production  → undocumented configuration C

Externalized, versioned configuration helps reduce this risk.

10. What is the Twelve-Factor principle related to this project?

A key principle is:

Store configuration in the environment.

This allows deployment-specific configuration to remain separate from application code.

11. Why should the Docker image remain environment-neutral?

Because the image should be immutable and reusable.

A good deployment model is:

Build once
     ↓
Test once
     ↓
Promote same image
     ↓
Inject environment configuration
12. What is configuration versus secret?

Configuration:

APP_VERSION
LOG_LEVEL
API_PORT
FEATURE_COUNTER

Secret:

PASSWORD
API_TOKEN
PRIVATE_KEY
DATABASE_CREDENTIAL

Secrets require stronger protection.

13. How would you manage production secrets?

Depending on the platform:

AWS Secrets Manager
AWS Systems Manager Parameter Store
Kubernetes Secrets
External Secrets
Vault
GitHub Actions Secrets

The choice depends on the architecture and security requirements.

14. Why validate docker compose config in CI?

It catches:

Invalid YAML
Missing variables
Incorrect interpolation
Invalid Compose configuration

before deployment.

15. What is immutable infrastructure?

Infrastructure where deployed artifacts are replaced rather than manually modified.

For containers:

Source
  ↓
Build Image
  ↓
Test
  ↓
Deploy Same Image

rather than modifying a running container manually.

16. How would you separate development, staging and production?

A mature implementation can use:

.env.development
.env.staging
.env.production

or CI/CD environment variables and secret stores.

The important principle is keeping configuration separate from the image.

17. What is a feature flag?

A configuration-controlled switch that changes application behavior without requiring a new application build.

Project 19 uses:

FEATURE_COUNTER=true
18. How would you troubleshoot incorrect runtime configuration?

I would inspect:

docker compose config
docker inspect <container>
docker exec <container> env
docker compose logs

Then compare:

Expected configuration
        vs
Actual runtime configuration
19. Explain Project 19 in an interview.

"In Project 19, I implemented enterprise-style configuration management for a Docker Compose application. I externalized application settings using .env and .env.example, used Compose variable substitution to inject configuration at runtime, protected .env through Git ignore rules, added a feature flag and configuration endpoint, and validated the resolved configuration with docker compose config. I also automated the process in GitHub Actions, where CI creates its own non-secret environment configuration, validates the Compose stack, verifies runtime configuration and health, tests Redis integration, and cleans up the environment."

🧠 Enterprise Deployment Model

The most important concept from Project 19:

                 Source Code
                     |
                     v
                 Dockerfile
                     |
                     v
               Immutable Image
                     |
          +----------+----------+
          |          |          |
          v          v          v
         DEV       STAGING      PROD
          |          |          |
          v          v          v
     Configuration Configuration Configuration
          |          |          |
          +----------+----------+
                     |
                     v
              Same Application

Build once → configure per environment → promote the same artifact.

🏁 Project 19 Completion Checklist
[x] Enterprise configuration model
[x] .env.example
[x] .env
[x] .gitignore protection
[x] Compose interpolation
[x] Configuration validation
[x] Runtime configuration endpoint
[x] Feature flag
[x] Environment override
[x] Docker healthchecks
[x] Redis integration
[x] Unit tests
[x] GitHub Actions
[x] CI configuration validation
[x] CI runtime validation
[x] CI cleanup
[x] Successful workflow
[x] README
[x] Interview preparation
🏆 19 / 100 COMPLETE

Your progression is now:

13  Container Healthcheck
14  Container Resource Limits
15  Runtime Configuration
16  Container Logging
17  Log Rotation
18  Docker Compose
19  Enterprise Configuration Management
🚀 NEXT: PROJECT 20

Project 20 — Docker Compose Secrets & Secure Configuration

We'll move from:

Configuration
     ↓
Project 19

to:

Configuration
     +
Secrets
     ↓
Secure Runtime Injection
     ↓
No Secrets in Image
     ↓
No Secrets in Git
     ↓
CI Secret Validation

That is an important jump toward production-grade DevOps security.
