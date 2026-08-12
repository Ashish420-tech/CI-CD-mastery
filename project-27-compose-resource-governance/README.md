# 🚀 Project 27 — Enterprise Docker Compose Resource Governance

> **Production-oriented Docker Compose resource governance with CPU limits, memory limits, reservations, healthchecks, non-root execution, and container security controls.**

![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?logo=docker&logoColor=white)
![Python](https://img.shields.io/badge/Python-3.12-3776AB?logo=python&logoColor=white)
![Flask](https://img.shields.io/badge/Flask-3.1-000000?logo=flask&logoColor=white)
![CI](https://img.shields.io/badge/CI-GitHub_Actions-2088FF?logo=githubactions&logoColor=white)
![Security](https://img.shields.io/badge/Security-Non--Root%20%7C%20No--New--Privileges-success)
![Status](https://img.shields.io/badge/Status-Completed-success)

---

## 🎯 Executive Summary

Containerized applications can become unstable when workloads consume uncontrolled CPU or memory.

This project demonstrates how to apply **explicit resource governance to Docker Compose workloads** so container consumption remains predictable and operationally controlled.

The implementation combines:

- CPU limits
- Memory limits
- Memory reservations
- Healthchecks
- Restart policy
- Non-root execution
- `no-new-privileges`
- Gunicorn
- Flask
- Python 3.12
- Docker Compose
- Pytest
- GitHub Actions

The goal is not simply to run a container.

The goal is to demonstrate **production-minded container resource management**.

---

# 🏗️ Architecture

```text
                    ┌──────────────────────┐
                    │       Client         │
                    └──────────┬───────────┘
                               │
                               ▼
                    ┌──────────────────────┐
                    │ Docker Compose       │
                    │ Application          │
                    │                      │
                    │ Flask + Gunicorn     │
                    └──────────┬───────────┘
                               │
             ┌─────────────────┼─────────────────┐
             │                 │                 │
             ▼                 ▼                 ▼
        CPU LIMIT         MEMORY LIMIT      RESERVATION
         0.50 CPU            256 MB            64 MB
             │                 │                 │
             └─────────────────┼─────────────────┘
                               ▼
                    ┌──────────────────────┐
                    │ Healthcheck          │
                    │ Restart Policy       │
                    │ Non-Root             │
                    │ No-New-Privileges    │
                    └──────────────────────┘
💡 Why This Project Matters

A container without resource governance can potentially consume excessive system resources.

For example:

Application
    │
    ├── CPU spikes
    │
    ├── Memory growth
    │
    └── Host resource pressure
             │
             ▼
      Other workloads affected

Resource governance introduces predictable boundaries:

Application
    │
    ├── CPU ≤ 0.50
    │
    ├── Memory ≤ 256 MB
    │
    └── Reservation = 64 MB
             │
             ▼
       Controlled workload

This is an important operational principle for production container platforms.

⚙️ Resource Policy
Resource	Configuration
CPU limit	0.50 CPU
Memory limit	256 MB
Memory reservation	64 MB
Application port	5001 → 5000
Container user	10001:10001
Restart policy	unless-stopped
Healthcheck	Enabled
No-new-privileges	Enabled
🔐 Container Security

Resource governance is combined with basic container hardening.

Non-root execution
USER 10001:10001

The application does not run as root.

Privilege escalation protection
security_opt:
  - no-new-privileges:true

This prevents processes inside the container from gaining additional privileges.

Minimal base image
FROM python:3.12-slim

The image uses a slim Python runtime to reduce unnecessary packages and attack surface.

❤️ Health Management

The container includes a Docker healthcheck:

healthcheck:
  interval: 5s
  timeout: 3s
  retries: 5
  start_period: 5s

The application exposes:

GET /health

Expected response:

{
  "status": "healthy"
}

This allows Docker to determine whether the workload is operational.

🧪 Testing Strategy

The project includes automated pytest coverage for:

CPU limits
Memory limits
Memory reservations
Healthcheck configuration
Security configuration
Non-root Docker execution

Run:

pytest -q

Expected:

6 passed
🔍 Runtime Validation

After starting the application:

docker compose up -d

Check:

docker compose ps

Health:

curl http://localhost:5001/health

Application:

curl http://localhost:5001/
🔎 Inspect Resource Governance

Docker runtime configuration can be inspected directly:

docker inspect "$(docker compose ps -q app)"

CPU:

docker inspect "$(docker compose ps -q app)" \
  --format '{{.HostConfig.NanoCpus}}'

Expected:

500000000

Memory:

docker inspect "$(docker compose ps -q app)" \
  --format '{{.HostConfig.Memory}}'

Expected:

268435456

This demonstrates that the configuration is not merely present in YAML — it is applied to the running container.

🔄 Operational Lifecycle
             docker compose up
                    │
                    ▼
            Build Application
                    │
                    ▼
          Apply Resource Policy
                    │
          ┌─────────┴─────────┐
          ▼                   ▼
      CPU Limit          Memory Limit
      0.50 CPU             256 MB
          │                   │
          └─────────┬─────────┘
                    ▼
               Healthcheck
                    │
                    ▼
              Healthy Service
                    │
                    ▼
             Runtime Inspection
                    │
                    ▼
             docker compose down
🤖 CI/CD Automation

GitHub Actions validates the complete implementation.

Workflow:

Git Push
   │
   ▼
Checkout
   │
   ▼
Python 3.12
   │
   ▼
Install pytest + PyYAML
   │
   ▼
Run Tests
   │
   ▼
Docker Compose Validation
   │
   ▼
Docker Build
   │
   ▼
Start Container
   │
   ▼
Health Validation
   │
   ▼
Application Validation
   │
   ▼
CPU Inspection
   │
   ▼
Memory Inspection
   │
   ▼
Security Validation
   │
   ▼
Cleanup

Workflow:

.github/workflows/project-27-compose-resource-governance.yml
📁 Project Structure
project-27-compose-resource-governance/
│
├── app/
│   └── app.py
│
├── tests/
│   └── test_resource_governance.py
│
├── Dockerfile
├── docker-compose.yml
├── .dockerignore
├── .gitignore
└── README.md

CI workflow:

.github/
└── workflows/
    └── project-27-compose-resource-governance.yml
🛡️ Validation Matrix
Validation	Result
CPU limit configured	✅
Memory limit configured	✅
Memory reservation configured	✅
Compose validation	✅
Docker build	✅
Container startup	✅
Application health	✅
Resource inspection	✅
Non-root execution	✅
no-new-privileges	✅
Pytest	✅
GitHub Actions	✅
Clean Git tree	✅
🚀 Quick Start
git clone https://github.com/Ashish420-tech/CI-CD-mastery.git

cd CI-CD-mastery/project-27-compose-resource-governance

docker compose build

docker compose up -d

docker compose ps

curl http://localhost:5001/health

curl http://localhost:5001/

docker inspect "$(docker compose ps -q app)" \
  --format 'CPU={{.HostConfig.NanoCpus}} Memory={{.HostConfig.Memory}} User={{.Config.User}}'

docker compose down -v
🧠 Key DevOps Lessons
1. Resource limits are operational controls

Containers should not be allowed to consume unlimited resources.

2. Reservations communicate expected capacity

Reservations help express the resources a workload expects to need.

3. Runtime inspection matters

A configuration file alone is not enough.

Always verify the effective Docker configuration:

docker inspect
4. Resource governance and security work together

Production containers need both:

Resource Governance
        +
Security Hardening
        +
Health Monitoring
        +
Automated CI
5. Infrastructure should be testable

The project treats Compose configuration as code and validates it automatically.

💼 Interview Talking Points
Q: Why do containers need resource limits?

Without limits, a workload can consume excessive CPU or memory and negatively affect other workloads on the same host.

Q: What is the difference between a limit and a reservation?

A limit establishes the maximum resource consumption allowed for the container.

A reservation communicates the amount of resource capacity the workload should have available.

Q: How did you verify the limits?

I used Docker runtime inspection:

docker inspect

and verified the effective NanoCpus and Memory values.

Q: Why run the container as non-root?

Running as a non-root user reduces the impact of application compromise and follows least-privilege container security practices.

Q: Why use no-new-privileges?

It prevents processes from gaining additional privileges through privilege-escalation mechanisms.

Q: How did you make the project production-oriented?

I combined:

explicit resource governance
healthchecks
restart policy
non-root execution
privilege escalation protection
production-style Gunicorn execution
automated testing
Docker validation
runtime inspection
GitHub Actions CI
📈 CI/CD Mastery Progress
Projects 01 → 25  ✅
Project 26         ✅ Dependency Resilience
Project 27         ✅ Resource Governance
Project 28         🔄 Logging & Rotation
Project 29         ⏳ Backup & Restore
Project 30         ⏳ Production Hardening
🏆 Project Outcome

This project demonstrates practical understanding of:

Docker
Docker Compose
Container Resource Governance
CPU Limits
Memory Limits
Reservations
Healthchecks
Container Security
Non-Root Containers
Gunicorn
Flask
Pytest
GitHub Actions
Infrastructure Validation
Production Operations

Project 27 — Enterprise Docker Compose Resource Governance: COMPLETE ✅


This version positions Project 27 much better for **DevOps/SRE/Platform Engineer recruiters
