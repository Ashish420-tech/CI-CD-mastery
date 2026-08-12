# 🚀 Project 14 — Docker Container Resource Limits

![Docker](https://img.shields.io/badge/Docker-Container-blue?logo=docker)
![Python](https://img.shields.io/badge/Python-3.12-blue?logo=python)
![Flask](https://img.shields.io/badge/Flask-Application-black?logo=flask)
![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-CI-success?logo=githubactions)
![Status](https://img.shields.io/badge/Status-Completed-success)

> **CI/CD Mastery — Project 14**

---

# 📌 Project Overview

Project 14 demonstrates how to apply **resource constraints to Docker containers** so that a single container cannot consume uncontrolled amounts of host resources.

The project focuses on three major runtime controls:

- **Memory limits**
- **CPU limits**
- **PID limits**

The container also retains the healthcheck capability introduced in Project 13.

The complete implementation is validated locally and automatically through GitHub Actions.

---

# 🎯 Project Objective

The primary objective is to understand and implement:

```text
Docker Container
       |
       +---- Memory Limit
       |
       +---- CPU Limit
       |
       +---- PID Limit
       |
       +---- Healthcheck
       |
       +---- Runtime Validation
       |
       +---- CI/CD Validation

The project answers an important production question:

How do you prevent one container from consuming excessive resources and affecting other workloads on the host?

🏢 Enterprise Problem

Without appropriate resource constraints, a badly behaving application could consume a large amount of:

CPU
Memory
Processes

For example:

Docker Host
│
├── Application A
│
├── Application B
│
└── Application C
        │
        └── Memory leak
              │
              └── consumes host memory
                    │
                    └── impacts other workloads

This creates unpredictable infrastructure behavior.

Resource constraints establish boundaries:

Container
│
├── CPU     → 0.5 CPU
├── Memory  → 128 MiB
└── PIDs    → 100
🏗️ Architecture
                         Docker Host
                              |
                              |
                    +---------+---------+
                    |                   |
                    |  Project 14       |
                    |    Container     |
                    |                   |
                    |  Flask App        |
                    |       |           |
                    |       v           |
                    |   /health         |
                    |                   |
                    +---------+---------+
                              |
              +---------------+---------------+
              |               |               |
              v               v               v
          CPU Limit      Memory Limit      PID Limit
          0.5 CPU          128 MiB            100
📁 Project Structure
project-14-container-resource-limits/
│
├── .dockerignore
├── Dockerfile
├── README.md
├── app.py
└── test_app.py

GitHub Actions:

.github/
└── workflows/
    └── project-14-container-resource-limits.yml
🐍 Application

The project uses a lightweight Flask application.

The application provides:

GET /
GET /health

The health endpoint returns:

{
  "status": "healthy"
}

The application itself is intentionally simple.

The primary objective is Docker runtime resource management.

🐳 Docker Image

The Docker image is built using:

python:3.12-slim

Build command:

docker build \
  -t ci-cd-mastery-project-14:1.0.0 \
  ./project-14-container-resource-limits
❤️ Docker HEALTHCHECK

Project 14 retains the healthcheck introduced in Project 13:

HEALTHCHECK --interval=5s --timeout=3s --start-period=5s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:5000/health', timeout=2)" || exit 1

Therefore the project validates both:

Application Health
        +
Resource Constraints
🔒 Container Resource Limits

The container is started with:

docker run -d \
  --name project-14-app \
  --memory=128m \
  --cpus=0.5 \
  --pids-limit=100 \
  -p 8092:5000 \
  ci-cd-mastery-project-14:1.0.0

The configuration establishes:

Resource	Limit
Memory	128 MiB
CPU	0.5 CPU
PIDs	100
🧠 Memory Limit

The container is configured with:

--memory=128m

This limits the container's memory to approximately:

128 MiB

Docker internally represents this as bytes.

Validation:

docker inspect project-14-app \
  --format '{{.HostConfig.Memory}}'

Expected:

134217728

Calculation:

128 × 1024 × 1024
= 134217728 bytes

Therefore:

134217728 bytes
       =
128 MiB
⚙️ CPU Limit

The container is configured with:

--cpus=0.5

This represents approximately:

0.5 CPU

Docker exposes this through NanoCpus.

Validation:

docker inspect project-14-app \
  --format '{{.HostConfig.NanoCpus}}'

Expected:

500000000

Because:

0.5 × 1,000,000,000
=
500000000 NanoCPUs
👥 PID Limit

The container is configured with:

--pids-limit=100

This limits the number of processes/tasks that can exist inside the container according to Docker's PID limit configuration.

Validation:

docker inspect project-14-app \
  --format '{{.HostConfig.PidsLimit}}'

Expected:

100
🔍 Complete Resource Configuration Validation

Run:

docker inspect project-14-app \
  --format 'memory={{.HostConfig.Memory}} cpus={{.HostConfig.NanoCpus}} pids={{.HostConfig.PidsLimit}}'

Expected:

memory=134217728 cpus=500000000 pids=100
📊 Runtime Resource Monitoring

Docker provides live resource statistics through:

docker stats --no-stream project-14-app

Example validation from this project:

CPU %       11.36%
MEM USAGE   31.44MiB / 128MiB
MEM %       24.56%
PIDS        3

This demonstrates that the container is operating within its configured resource boundary.

❤️ Application Health Validation

Verify the application:

curl -fsS http://localhost:8092/health

Expected:

{
  "status": "healthy"
}

Verify Docker health:

docker inspect project-14-app \
  --format 'status={{.State.Status}} health={{.State.Health.Status}}'

Expected:

status=running health=healthy
🧪 Automated Tests

Run:

python -m pytest -q project-14-container-resource-limits

Project result:

3 passed

The Python test suite validates the application behavior before container-level validation begins.

🔄 CI/CD Pipeline

GitHub Actions automates the entire validation process.

Pipeline:

                    GitHub Push
                         |
                         v
                    GitHub Actions
                         |
                         v
                    Checkout Code
                         |
                         v
                    Setup Python
                         |
                         v
                  Install Dependencies
                         |
                         v
                     Run Tests
                         |
                         v
                  Build Docker Image
                         |
                         v
              Run Container With Limits
                         |
          +--------------+--------------+
          |              |              |
          v              v              v
      Memory          CPU Limit       PID Limit
      128 MiB          0.5 CPU           100
          |              |              |
          +--------------+--------------+
                         |
                         v
                  Healthcheck
                         |
                         v
                 Verify Resources
                         |
                         v
                  Verify /health
                         |
                         v
                  docker stats
                         |
                         v
                      Cleanup
⚙️ GitHub Actions Workflow

Workflow:

.github/workflows/project-14-container-resource-limits.yml

The workflow validates:

Python tests
Docker image build
Container startup
Docker health
Memory limit
CPU limit
PID limit
Container state
HTTP health endpoint
Runtime resource usage
Cleanup
🔐 CI Resource Validation

The CI pipeline extracts:

MEMORY=$(docker inspect project-14-app \
  --format '{{.HostConfig.Memory}}')

CPUS=$(docker inspect project-14-app \
  --format '{{.HostConfig.NanoCpus}}')

PIDS=$(docker inspect project-14-app \
  --format '{{.HostConfig.PidsLimit}}')

Then validates:

test "$MEMORY" -eq 134217728
test "$CPUS" -eq 500000000
test "$PIDS" -eq 100

This is important because the pipeline is not simply checking whether the container started.

It verifies the actual runtime configuration.

🧹 Container Cleanup

The CI workflow uses:

docker rm -f project-14-app 2>/dev/null || true

This ensures that the temporary CI container is removed even when earlier validation fails.

📊 Validation Results
Local Validation
Python tests                  ✅ 3 passed
Docker image                  ✅ Built
Container startup             ✅ Successful
Container state               ✅ Running
Docker health                 ✅ Healthy
Memory limit                  ✅ 128 MiB
CPU limit                     ✅ 0.5 CPU
PID limit                     ✅ 100
Runtime monitoring            ✅ docker stats
HTTP health endpoint          ✅ Successful
Actual Runtime Evidence
status=running health=healthy

memory=134217728
cpus=500000000
pids=100

Runtime statistics:

CPU:        11.36%
Memory:     31.44MiB / 128MiB
Memory %:   24.56%
PIDs:       3
🚀 GitHub Actions Result

The dedicated Project 14 workflow completed successfully after correcting the initial workflow syntax issue.

Successful workflow run:

Project 14 - Container Resource Limits
Run ID: 31571311414
Status: SUCCESS

The initial workflow attempt failed because the generated workflow contained duplicated/invalid heredoc content.

That issue was corrected and the workflow was successfully rerun.

This is a useful real-world CI/CD lesson:

A failed pipeline should be diagnosed from the actual failure rather than blindly rerunning it.

🎤 Interview Questions & Answers
1. Why are Docker resource limits important?

Without resource limits, a container can potentially consume excessive host resources.

For example:

Memory leak
     ↓
High memory consumption
     ↓
Host resource pressure
     ↓
Other workloads affected

Resource limits establish predictable boundaries.

2. How do you limit Docker container memory?

Use:

docker run --memory=128m image

This limits the container's memory to approximately 128 MiB.

3. How do you limit CPU?

Use:

docker run --cpus=0.5 image

This limits the container to approximately half a CPU's worth of processing capacity.

4. What does --cpus=0.5 mean?

It represents approximately:

50% of one CPU

Docker internally represents CPU quota using NanoCPUs.

For example:

0.5 CPU
=
500000000 NanoCPUs
5. How do you limit the number of processes?

Use:

--pids-limit=100

This limits the number of processes/tasks allowed inside the container according to the configured PID limit.

6. How do you verify Docker resource limits?

Use:

docker inspect container

For example:

docker inspect project-14-app \
  --format '{{.HostConfig.Memory}}'

and:

docker inspect project-14-app \
  --format '{{.HostConfig.NanoCpus}}'

and:

docker inspect project-14-app \
  --format '{{.HostConfig.PidsLimit}}'
7. How do you monitor actual container resource consumption?

Use:

docker stats

For a single container:

docker stats --no-stream project-14-app

This provides information about:

CPU
Memory
Network
Block I/O
PIDs
8. What is the difference between resource limit and resource usage?

A resource limit defines the maximum boundary.

Example:

Memory Limit = 128 MiB

Current usage might be:

31.44 MiB

Therefore:

Limit ≠ Current Usage
9. What happens if a container reaches its memory limit?

Depending on the configuration and workload, the container can experience memory pressure and may be terminated by the kernel/runtime through an out-of-memory condition.

This is why production workloads should have appropriately sized memory limits and monitoring.

10. Does docker stats configure limits?

No.

docker stats only monitors resource usage.

Resource limits are configured when the container is created/run.

Example:

docker run \
  --memory=128m \
  --cpus=0.5 \
  --pids-limit=100 \
  image
11. What is the difference between CPU limit and CPU usage?

CPU limit:

Maximum permitted CPU allocation

CPU usage:

Current CPU consumption

For example:

CPU Limit  = 0.5 CPU
CPU Usage  = 11.36%

These are different concepts.

12. Why use both HEALTHCHECK and resource limits?

They solve different problems.

HEALTHCHECK

Answers:

Is the application functioning?

Resource limits

Answer:

How many resources can this container consume?

Together:

Application Health
        +
Resource Isolation

provide stronger container runtime control.

13. Does Docker HEALTHCHECK limit resources?

No.

HEALTHCHECK determines application health.

Resource limits are separate Docker runtime controls.

14. What is the Kubernetes equivalent of Docker resource limits?

Kubernetes provides:

resources:
  requests:
    cpu: "100m"
    memory: "128Mi"
  limits:
    cpu: "500m"
    memory: "256Mi"

The concepts are related, but Kubernetes resource management operates within Kubernetes scheduling and orchestration.

15. What is a CPU request versus CPU limit in Kubernetes?

A request represents the amount of resource Kubernetes uses for scheduling decisions.

A limit represents the maximum resource the container can consume.

Example:

resources:
  requests:
    cpu: "100m"

  limits:
    cpu: "500m"
16. Why shouldn't production containers simply have unlimited resources?

Because unlimited resource consumption can cause:

Noisy Neighbor Problems
Resource Exhaustion
Unpredictable Performance
Host Instability
Service Degradation

Resource boundaries improve predictability.

17. Should every container use exactly the same limits?

No.

Limits should be based on:

Application characteristics
Expected traffic
Memory profile
CPU requirements
Performance testing
Production observations

Incorrectly low limits can also cause instability.

18. What is the "noisy neighbor" problem?

A noisy neighbor is a workload that consumes disproportionate shared infrastructure resources and negatively impacts other workloads.

Example:

Host
│
├── Service A
├── Service B
└── Service C
       │
       └── excessive CPU/memory
              ↓
       Services A/B affected

Resource limits help mitigate this problem.

19. How did you validate your Project 14 implementation?

I used multiple layers:

pytest
   ↓
Docker build
   ↓
Docker run
   ↓
docker inspect
   ↓
docker stats
   ↓
HEALTHCHECK
   ↓
curl /health
   ↓
GitHub Actions

This provides both application-level and infrastructure-level validation.

20. Explain your Project 14 implementation in an interview.

A strong answer:

"In Project 14 of my CI/CD mastery portfolio, I implemented Docker resource isolation. I built a Flask application into a Docker image and ran it with a 128 MiB memory limit, 0.5 CPU limit, and PID limit of 100. I retained the Docker HEALTHCHECK from the previous project and verified the runtime configuration using docker inspect and actual consumption using docker stats. I then automated these validations in GitHub Actions, including testing, image build, container startup, health validation, resource-limit assertions, HTTP validation, and cleanup."

🧠 Deep DevOps Concepts

Project 14 teaches the progression:

Containerization
      ↓
Health Monitoring
      ↓
Resource Isolation
      ↓
Automated Validation
      ↓
Production Readiness

This is an important transition from simply knowing Docker commands to understanding container operational behavior.

🔥 Production Mental Model

A production container should not simply be:

docker run image

A more disciplined approach is:

docker run
    |
    +── CPU boundary
    |
    +── Memory boundary
    |
    +── PID boundary
    |
    +── Healthcheck
    |
    +── Network configuration
    |
    +── Security configuration
    |
    +── Observability

Project 14 focuses specifically on:

CPU
Memory
PIDs

while building on the healthcheck capability from Project 13.

🏆 Project Completion Checklist
 Project branch created
 Flask application
 Dockerfile
 Docker image
 Docker HEALTHCHECK
 Memory limit
 CPU limit
 PID limit
 Runtime resource inspection
 docker stats validation
 Application health validation
 Python tests
 GitHub Actions workflow
 CI resource assertions
 CI health validation
 CI cleanup
 GitHub Actions successful
 README documentation
🎯 Key Commands
Build
docker build \
  -t ci-cd-mastery-project-14:1.0.0 \
  ./project-14-container-resource-limits
Run with limits
docker run -d \
  --name project-14-app \
  --memory=128m \
  --cpus=0.5 \
  --pids-limit=100 \
  -p 8092:5000 \
  ci-cd-mastery-project-14:1.0.0
Inspect limits
docker inspect project-14-app \
  --format 'memory={{.HostConfig.Memory}} cpus={{.HostConfig.NanoCpus}} pids={{.HostConfig.PidsLimit}}'
Monitor
docker stats --no-stream project-14-app
Health
docker inspect project-14-app \
  --format 'status={{.State.Status}} health={{.State.Health.Status}}'
Application
curl -fsS http://localhost:8092/health
Tests
python -m pytest -q project-14-container-resource-limits
🚀 Final Result
PROJECT 14
Container Resource Limits
             |
             +---- CPU       → 0.5
             |
             +---- Memory    → 128 MiB
             |
             +---- PIDs      → 100
             |
             +---- Health    → healthy
             |
             +---- Tests     → 3 passed
             |
             +---- CI/CD     → SUCCESS
🏆 PROJECT 14 — COMPLETED
