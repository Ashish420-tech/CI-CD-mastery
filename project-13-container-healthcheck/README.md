# 🚀 Project 13 — Docker Container Health Checks

![Docker](https://img.shields.io/badge/Docker-Container-blue?logo=docker)
![Python](https://img.shields.io/badge/Python-3.12-blue?logo=python)
![Flask](https://img.shields.io/badge/Flask-Application-black?logo=flask)
![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-CI-success?logo=githubactions)
![Status](https://img.shields.io/badge/Status-Completed-success)

## 📌 Project Overview

Project 13 introduces **Docker-native container health checks** into the CI/CD pipeline.

The goal is to solve an important production problem:

> A container being `running` does not necessarily mean that the application inside the container is healthy.

Docker's `HEALTHCHECK` instruction allows the container runtime to verify application-level health.

---

# 🎯 Objectives

This project demonstrates:

- Docker `HEALTHCHECK`
- Application health endpoint
- Container health status
- Healthcheck intervals
- Healthcheck timeout
- Healthcheck retries
- Docker health inspection
- Automated CI validation
- Container lifecycle validation
- Difference between `running` and `healthy`

---

# 🏗️ Architecture

```text
                    GitHub Repository
                           |
                           v
                    GitHub Actions
                           |
              +------------+------------+
              |                         |
              v                         v
        Python Tests              Docker Build
              |                         |
              +------------+------------+
                           |
                           v
                  Docker Container
                           |
                           v
                    HEALTHCHECK
                           |
                           v
                    GET /health
                           |
                +----------+----------+
                |                     |
             HTTP 200              Failure
                |                     |
                v                     v
             HEALTHY              UNHEALTHY
📁 Project Structure
project-13-container-healthcheck/
├── .dockerignore
├── Dockerfile
├── README.md
├── app.py
└── test_app.py

GitHub Actions workflow:

.github/
└── workflows/
    └── project-13-container-healthcheck.yml
🐍 Application

The application is a lightweight Flask service.

It provides:

GET /
GET /health

The health endpoint returns:

{
  "status": "healthy"
}

The endpoint is intentionally simple because the objective of this project is Docker health monitoring rather than application development.

🐳 Dockerfile

The important part of the Dockerfile is:

HEALTHCHECK --interval=5s --timeout=3s --start-period=5s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:5000/health', timeout=2)" || exit 1
Healthcheck Parameters
--interval=5s

Docker performs the healthcheck every 5 seconds.

--timeout=3s

The healthcheck must complete within 3 seconds.

--start-period=5s

Docker allows the application 5 seconds to initialize before healthcheck failures count toward the retry threshold.

--retries=3

Three consecutive failures cause Docker to mark the container as:

unhealthy
🔄 Healthcheck Flow
Docker
  |
  | every 5 seconds
  v
GET http://127.0.0.1:5000/health
  |
  +---- HTTP 200 ----> HEALTHY
  |
  +---- failure ------> retry
                         |
                         +--> 3 failures
                                  |
                                  v
                              UNHEALTHY
🧪 Testing

Run the Python tests:

python -m pytest -q project-13-container-healthcheck

Expected result:

3 passed
🏗️ Build Docker Image
docker build \
  -t ci-cd-mastery-project-13:1.0.0 \
  ./project-13-container-healthcheck

Verify:

docker images | grep ci-cd-mastery-project-13
▶️ Run Container
docker rm -f project-13-app 2>/dev/null || true

docker run -d \
  --name project-13-app \
  -p 8091:5000 \
  ci-cd-mastery-project-13:1.0.0
🔍 Verify Container
docker ps

The container should be running.

❤️ Verify Application Health
curl -fsS http://localhost:8091/health

Expected:

{"status":"healthy"}
🩺 Verify Docker Health Status
docker inspect project-13-app \
  --format 'status={{.State.Status}} health={{.State.Health.Status}}'

Expected:

status=running health=healthy
🔬 Inspect Detailed Healthcheck Information
docker inspect project-13-app \
  --format '{{json .State.Health}}'

Example successful result:

{
  "Status": "healthy",
  "FailingStreak": 0
}

The healthcheck log contains successful executions with:

ExitCode: 0

This confirms that Docker successfully executed the configured healthcheck.

📊 Running vs Healthy

One of the most important concepts in this project:

Container Status
       |
       +---- running
       |
       |     means:
       |     main container process is running
       |
       +---- healthy
             |
             means:
             application healthcheck is succeeding

Therefore:

running != healthy

A container can have a running process while the application inside it is not responding correctly.

🔐 CI/CD Pipeline

GitHub Actions validates the complete container lifecycle.

Pipeline:

Checkout
   ↓
Setup Python
   ↓
Install Dependencies
   ↓
Run pytest
   ↓
Build Docker Image
   ↓
Run Container
   ↓
Wait for HEALTHY
   ↓
Verify Container State
   ↓
Verify /health Endpoint
   ↓
Cleanup

Workflow:

.github/workflows/project-13-container-healthcheck.yml
⚙️ CI Validation

The pipeline waits for Docker to report:

healthy

The workflow fails if the container becomes:

unhealthy

It also validates:

docker inspect project-13-app

and:

curl -fsS http://localhost:8091/health

This prevents a CI pipeline from declaring success merely because the Docker process started.

✅ Project Validation
Local Validation
Pytest                         ✅
Docker image build             ✅
Container startup              ✅
Docker HEALTHCHECK             ✅
Health status                  ✅ healthy
Failing streak                 ✅ 0
Healthcheck exit code          ✅ 0
/health endpoint               ✅ HTTP 200
GitHub Actions Validation

Project 13 GitHub Actions run:

31570104203

Result:

SUCCESS

The successful job validated:

Run tests                    ✅
Build Docker image           ✅
Run container                ✅
Wait for healthy container   ✅
Verify container state       ✅
Verify HTTP health endpoint  ✅
Cleanup                      ✅
🧹 Cleanup

After testing:

docker rm -f project-13-app

Optionally remove the image:

docker rmi ci-cd-mastery-project-13:1.0.0
💼 Enterprise Use Cases

Docker healthchecks are useful for:

Containerized microservices
CI/CD pipelines
Docker Compose applications
Development environments
Container monitoring
Application availability validation
Automated deployment verification

In production orchestration platforms such as Kubernetes, similar concepts are implemented using:

Liveness probes
Readiness probes
Startup probes

Docker HEALTHCHECK and Kubernetes probes are related concepts but are not identical.

🎤 Interview Questions & Answers
1. What is Docker HEALTHCHECK?

Docker HEALTHCHECK defines a command that Docker periodically executes to determine whether the application inside a container is functioning correctly.

2. What is the difference between running and healthy?

running means the container's main process is running.

healthy means the configured healthcheck is succeeding.

Therefore:

running != healthy
3. Why do we need healthchecks?

A process can remain alive while the application is broken.

For example:

Python process → running
Application API → unavailable

A healthcheck detects the application-level failure.

4. What happens when a healthcheck fails?

Docker records the failure.

After the configured retry threshold is reached, Docker marks the container:

unhealthy
5. Does Docker automatically restart an unhealthy container?

No.

HEALTHCHECK itself does not restart the container.

Restart behavior depends on the container runtime configuration or an external orchestrator.

6. What does --interval mean?

It defines how frequently Docker executes the healthcheck.

Example:

--interval=5s

means Docker checks approximately every 5 seconds.

7. What does --timeout mean?

It defines how long Docker waits for a healthcheck command to complete.

Example:

--timeout=3s

means the check must finish within 3 seconds.

8. What does --retries mean?

It defines how many consecutive failures are required before Docker considers the container unhealthy.

Example:

--retries=3

means three consecutive failures result in:

unhealthy
9. What is --start-period?

It gives the container time to initialize before healthcheck failures begin counting toward the retry threshold.

This is useful for applications that require startup time.

10. How do you check container health?

Use:

docker inspect container-name \
  --format '{{.State.Health.Status}}'

Example:

healthy
11. Can a container be running but unhealthy?

Yes.

Example:

Status: running
Health: unhealthy

This is one of the main reasons healthchecks are important.

12. Does HEALTHCHECK test the Docker daemon?

No.

It tests the application/container using the configured command.

13. What should a health endpoint return?

A successful health endpoint should normally return an appropriate successful HTTP status such as:

HTTP 200

when the application is healthy.

14. Should /health perform expensive operations?

Normally no.

Healthchecks run repeatedly, so they should be:

Fast
Lightweight
Deterministic
Reliable
15. What is the Kubernetes equivalent?

Kubernetes provides:

Liveness Probe
Readiness Probe
Startup Probe

These provide more advanced orchestration behavior than Docker's basic HEALTHCHECK.

16. What is the difference between readiness and liveness?
Liveness

Answers:

Is the application alive?

If liveness repeatedly fails, Kubernetes may restart the container.

Readiness

Answers:

Is the application ready to receive traffic?

A readiness failure normally removes the Pod from service endpoints without necessarily restarting it.

17. Why validate health in CI/CD?

Because a successful Docker build does not guarantee a working application.

A production-quality pipeline should validate:

Build
 ↓
Start
 ↓
Health
 ↓
Application endpoint

before considering the deployment artifact valid.

🧠 Key DevOps Lessons

Project 13 demonstrates an important production principle:

Container lifecycle health must be validated at the application level, not only at the process level.

The complete validation model is:

Source Code
     ↓
Automated Tests
     ↓
Docker Build
     ↓
Container Startup
     ↓
Healthcheck
     ↓
Application Validation
     ↓
CI Success
🏆 Project 13 Completion Checklist
 Flask application
 /health endpoint
 Dockerfile
 Docker HEALTHCHECK
 Healthcheck interval
 Healthcheck timeout
 Healthcheck start period
 Healthcheck retries
 Local Docker validation
 Container reports healthy
 Healthcheck failing streak = 0
 Pytest validation
 GitHub Actions validation
 HTTP health validation
 Cleanup
 README documentation
🚀 Project Status

PROJECT 13 — COMPLETED ✅
