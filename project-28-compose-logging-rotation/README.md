# 🚀 Project 28 — Enterprise Docker Compose Logging & Rotation

> **Production-oriented container logging with Docker `json-file`, bounded log retention, automatic rotation, healthchecks, non-root execution, security hardening, automated testing, and GitHub Actions CI.**

![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?logo=docker&logoColor=white)
![Python](https://img.shields.io/badge/Python-3.12-3776AB?logo=python&logoColor=white)
![Flask](https://img.shields.io/badge/Flask-3.1-000000?logo=flask&logoColor=white)
![Gunicorn](https://img.shields.io/badge/Gunicorn-Production-499848)
![CI/CD](https://img.shields.io/badge/GitHub_Actions-CI/CD-2088FF?logo=githubactions&logoColor=white)
![Testing](https://img.shields.io/badge/Pytest-Automated-success)
![Security](https://img.shields.io/badge/Container-Security-success)
![Status](https://img.shields.io/badge/Project-Complete-success)

---

## 🎯 Executive Summary

Logs are one of the most important operational signals in a production environment.

However, container logging without retention controls can create another operational problem:

```text
Application
    │
    ▼
Continuous Logs
    │
    ▼
Docker Host Storage
    │
    ▼
Unbounded Log Growth
    │
    ▼
Disk Exhaustion
    │
    ▼
Application / Host Failure

This project demonstrates a production-minded Docker Compose logging strategy using:

Docker json-file logging driver
max-size
max-file
bounded local log retention
application log generation
runtime Docker inspection
healthchecks
non-root execution
no-new-privileges
Gunicorn
Flask
Python 3.12
Pytest
GitHub Actions

The implementation focuses on log lifecycle management, not simply printing application logs.

🏗️ Architecture
                         ┌─────────────────┐
                         │     Client      │
                         └────────┬────────┘
                                  │
                                  ▼
                    ┌─────────────────────────┐
                    │ Flask + Gunicorn        │
                    │ Container               │
                    │                         │
                    │ Non-root UID 10001      │
                    └────────────┬────────────┘
                                 │
                                 │ stdout / stderr
                                 ▼
                    ┌─────────────────────────┐
                    │ Docker Logging Driver   │
                    │                         │
                    │ json-file               │
                    └────────────┬────────────┘
                                 │
                    ┌────────────┴────────────┐
                    │                         │
                    ▼                         ▼
              max-size: 10m             max-file: 3
                    │                         │
                    └────────────┬────────────┘
                                 ▼
                       Bounded Log Storage
🔥 The Production Problem

Without log rotation:

container
   │
   ├── 100 MB
   ├── 500 MB
   ├── 1 GB
   ├── 5 GB
   └── 20 GB
          │
          ▼
     Disk pressure

With rotation:

Current log
     │
     ▼
  max-size
   10 MB
     │
     ▼
 Rotation
     │
     ├── file 1
     ├── file 2
     └── file 3

The objective is to keep local Docker log storage bounded and predictable.

📌 Project Objectives

This project demonstrates:

Docker logging drivers
JSON logging
log rotation
maximum log size
maximum retained files
container stdout/stderr logging
runtime configuration inspection
health-based validation
container security
automated testing
CI/CD validation
🧩 Core Concepts
1. Docker Logging Driver

Docker containers generate logs primarily through:

stdout
stderr

Docker captures these streams using a logging driver.

This project explicitly configures:

logging:
  driver: json-file
Why?

The json-file driver stores container logs in JSON format on the Docker host.

Conceptually:

Application
     │
     ▼
stdout/stderr
     │
     ▼
Docker Engine
     │
     ▼
json-file driver
Interview Question

Q: What is a Docker logging driver?

A logging driver determines how Docker collects and stores container logs.

Examples include:

json-file
local
syslog
journald
fluentd
gelf
awslogs
Strong Interview Answer

Docker logging drivers define where and how container stdout/stderr logs are delivered. For a production environment, I would choose the driver based on the centralized logging architecture rather than treating local container logs as the final observability solution.

2. JSON Logging

This project uses:

driver: json-file

Docker stores log entries in JSON format.

Conceptually:

{
  "log": "application request served\n",
  "stream": "stdout",
  "time": "2026-08-12T..."
}
Why JSON?

JSON provides machine-readable structure that Docker can process.

It is useful for:

troubleshooting
log parsing
automation
local inspection
integration with logging pipelines
Interview Question

Q: Why might JSON logs be useful?

JSON provides a structured representation of log events, making them easier for tooling to parse and process than arbitrary text.

3. max-size

The project configures:

max-size: "10m"

This means a log file is rotated when it reaches approximately the configured size.

Conceptually:

Log file
   │
   ▼
10 MB
   │
   ▼
ROTATE
Why?

Without a size boundary, log files can grow continuously.

Interview Question

Q: Why configure max-size?

To prevent an individual container log file from growing indefinitely and consuming excessive host disk space.

4. max-file

The project configures:

max-file: "3"

This limits the number of retained rotated log files.

Conceptually:

Current
   │
   ├── log
   ├── rotated-1
   └── rotated-2

Older logs are eventually removed as rotation continues.

Interview Question

Q: What is the difference between max-size and max-file?

Answer:

max-size → controls size of each log file

max-file → controls number of retained log files

For example:

max-size: "10m"
max-file: "3"

provides bounded local retention of roughly the configured file-count × size, subject to Docker's implementation details.

5. Log Rotation

Log rotation means replacing an active log file with a new file when the configured threshold is reached.

             Application
                  │
                  ▼
              Current.log
                  │
             reaches 10 MB
                  │
                  ▼
               Rotate
                  │
       ┌──────────┴──────────┐
       ▼                     ▼
   Older log             New active log
Why is rotation important?

Because production systems continuously generate logs.

Without rotation:

Log volume ↑
Disk usage ↑
Disk availability ↓

Eventually:

Disk full
   │
   ▼
Application instability
Interview Question

Q: What happens if you don't implement log rotation?

Container logs can consume the host filesystem over time, potentially exhausting disk space and causing unrelated workloads or the Docker host itself to become unhealthy.

6. Container stdout/stderr

The application logs using Python:

logger.info("application request served")

Gunicorn sends the process output to the container's standard output stream.

Docker captures it:

Python logger
      │
      ▼
Gunicorn
      │
      ▼
stdout/stderr
      │
      ▼
Docker logging driver

This is preferable to blindly writing application logs into arbitrary files inside the container.

Interview Question

Q: Why should containers generally log to stdout/stderr?

Container platforms can capture stdout/stderr consistently and route the resulting logs through the configured logging system. This avoids coupling application logging to a particular filesystem layout inside the container.

7. docker logs

Runtime logs are validated using:

docker logs <container>

Example:

docker logs "$(docker compose ps -q app)"

This demonstrates that Docker is actually collecting the application's runtime output.

Interview Question

Q: How do you troubleshoot a container that is running but the application is failing?

A strong first step is:

docker logs <container>

Then inspect:

docker inspect <container>
docker compose ps
docker compose logs
8. Runtime Configuration Inspection

One of the most important DevOps principles demonstrated here is:

Configuration should be verified at runtime, not just trusted because it exists in YAML.

The project uses:

docker inspect

Example:

docker inspect "$(docker compose ps -q app)" \
  --format '{{.HostConfig.LogConfig.Type}}'

Expected:

json-file

And:

docker inspect "$(docker compose ps -q app)" \
  --format '{{index .HostConfig.LogConfig.Config "max-size"}}'

Expected:

10m

And:

docker inspect "$(docker compose ps -q app)" \
  --format '{{index .HostConfig.LogConfig.Config "max-file"}}'

Expected:

3
Interview Question

Q: Why use docker inspect if the Compose file already contains the configuration?

Because the Compose file represents desired configuration, while docker inspect shows the effective configuration applied to the running container.

This is an important distinction in production troubleshooting.

9. Healthchecks

The application exposes:

GET /health

Docker verifies it with:

healthcheck:
  interval: 5s
  timeout: 3s
  retries: 5
  start_period: 5s

Expected response:

{
  "status": "healthy"
}
Why?

A running process does not necessarily mean a healthy application.

Container running
       ≠
Application healthy
Interview Question

Q: Why are Docker healthchecks important?

They provide an application-level signal that can distinguish a running container from a functioning service.

10. Restart Policy

The project uses:

restart: unless-stopped

This allows Docker to restart the service after certain failures or Docker daemon events while respecting an explicit administrative stop.

Interview Question

Q: Is a restart policy the same as high availability?

No.

A restart policy provides local recovery behavior.

It does not provide:

multiple replicas
cross-host failover
load balancing
distributed scheduling

For larger production systems, an orchestrator such as Kubernetes provides broader workload-management capabilities.

🔐 Security Concepts

Logging management should not ignore container security.

This project also validates:

Non-root
+
No-new-privileges
+
Minimal image
+
Healthcheck
11. Non-root Execution

Dockerfile:

USER 10001:10001

The application does not run as root.

Why?

If the application is compromised, the attacker receives the privileges of the application user rather than root inside the container.

Interview Question

Q: Why should containers avoid root?

Running as non-root follows least privilege and reduces the potential impact of a container compromise.

12. no-new-privileges

Compose:

security_opt:
  - no-new-privileges:true

This prevents processes from gaining additional privileges through privilege-escalation mechanisms.

Interview Question

Q: What does no-new-privileges do?

It prevents a process and its children from gaining additional privileges, providing another layer of defense against privilege escalation.

13. Minimal Base Image

The project uses:

FROM python:3.12-slim
Why?

A smaller runtime generally means:

fewer unnecessary packages
smaller image
lower attack surface
faster image transfer

However:

Smaller does not automatically mean secure.

Images should still be scanned and patched.

🐍 Application Stack
Python 3.12

Provides the application runtime.

Flask

Provides lightweight HTTP endpoints:

/
 /health
 /generate-logs
Gunicorn

Provides production-style WSGI serving:

Client
  │
  ▼
Gunicorn
  │
  ▼
Flask

Instead of relying on Flask's development server, Gunicorn is used as the production application server.

🧪 Automated Testing

Pytest validates configuration before deployment.

Tests verify:

Logging driver
       ↓
max-size
       ↓
max-file
       ↓
Healthcheck
       ↓
Non-root
       ↓
Application logging

Run:

pytest -q

Expected:

6 passed
🔬 Runtime Test Strategy

The project does not stop at unit tests.

It performs multiple validation layers:

                Code
                  │
                  ▼
             Pytest
                  │
                  ▼
          Compose Validation
                  │
                  ▼
             Docker Build
                  │
                  ▼
          Runtime Container
                  │
        ┌─────────┼─────────┐
        ▼         ▼         ▼
     Health     Logs     Security
        │         │         │
        └─────────┼─────────┘
                  ▼
          Docker Inspection

This provides stronger confidence than static YAML validation alone.

🤖 GitHub Actions CI/CD

Workflow:

.github/workflows/project-28-compose-logging-rotation.yml

Pipeline:

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
Compose Validation
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
Generate Logs
   │
   ▼
Verify Logs
   │
   ▼
Inspect Logging Driver
   │
   ▼
Verify Rotation
   │
   ▼
Security Validation
   │
   ▼
Cleanup
📁 Project Structure
project-28-compose-logging-rotation/
│
├── app/
│   └── app.py
│
├── tests/
│   └── test_logging_rotation.py
│
├── Dockerfile
├── docker-compose.yml
├── .dockerignore
└── .gitignore

CI:

.github/
└── workflows/
    └── project-28-compose-logging-rotation.yml
🚀 Quick Start
cd project-28-compose-logging-rotation

docker compose config

docker compose build

docker compose up -d

docker compose ps

Health:

curl http://localhost:5001/health

Application:

curl http://localhost:5001/

Generate logs:

curl http://localhost:5001/generate-logs

View logs:

docker logs "$(docker compose ps -q app)"

Inspect logging:

docker inspect "$(docker compose ps -q app)" \
  --format 'Driver={{.HostConfig.LogConfig.Type}} Config={{json .HostConfig.LogConfig.Config}}'

Cleanup:

docker compose down -v
📊 Validation Matrix
Capability	Validation
JSON logging driver	✅
max-size	✅ 10m
max-file	✅ 3
Application log generation	✅
Docker log collection	✅
Runtime logging inspection	✅
Healthcheck	✅
Docker Compose validation	✅
Docker build	✅
Non-root execution	✅
no-new-privileges	✅
Pytest	✅
GitHub Actions	✅
Clean Git tree	✅
🎤 Interview Questions & Answers
Q1. What happens when a Docker container generates logs?

The application writes logs to stdout/stderr. Docker captures those streams through its configured logging driver. With the json-file driver, Docker stores the entries as JSON-formatted log records.

Q2. Why do you need log rotation?

Without rotation, container logs can continuously grow and consume host disk space. max-size limits individual log-file size and max-file controls the number of retained rotated files.

Q3. What is the difference between Docker logging and centralized logging?

Docker logging:

Application
    ↓
Docker
    ↓
Local logging driver

Centralized logging:

Application
    ↓
Docker / Agent
    ↓
Log Collector
    ↓
Central Logging Platform
    ↓
Search / Alert / Dashboard

Examples of centralized platforms include:

ELK / Elastic Stack
Loki
Splunk
CloudWatch
Datadog
Q4. Would you use json-file in a large production Kubernetes environment?

Not necessarily. Kubernetes environments commonly use stdout/stderr combined with a node-level logging agent or platform-specific collection mechanism. The correct approach depends on the centralized observability architecture.

Q5. What is the risk of logging sensitive information?

Logs can become a security and compliance problem if they contain:

passwords
API keys
tokens
session cookies
personal information
database credentials

Therefore:

Applications should never intentionally log secrets.

Q6. How would you troubleshoot missing container logs?

I would check:

docker compose ps
docker logs <container>
docker inspect <container>
docker compose logs

Then verify:

Application stdout/stderr
        ↓
Docker logging driver
        ↓
Host storage
        ↓
Central collector
Q7. How would you monitor log volume?

I would monitor:

log ingestion rate
log storage usage
error rate
log rotation frequency
collector health
dropped logs
disk utilization
Q8. Why not simply write logs to /var/log/app.log inside the container?

Writing directly into the container filesystem couples the application to local filesystem management. Container platforms generally work better when applications emit logs to stdout/stderr and the platform handles collection and routing.

Q9. Does max-file: 3 mean exactly three files will always exist?

No.

It establishes the configured retention count for rotated files. Actual file presence depends on whether rotation has occurred and Docker's logging behavior.

Q10. Does log rotation solve centralized logging?

No.

Log rotation solves local log storage management.

Centralized logging solves:

collection
aggregation
search
retention
alerting
analysis

These are related but different concerns.

🧠 Production Design Evolution

This project represents the local Docker layer:

               Docker Compose
                     │
             ┌───────┴───────┐
             ▼               ▼
         Application       Logging
             │               │
             ▼               ▼
         Healthcheck     Rotation
                             │
                             ▼
                        Local Storage

A larger production architecture could evolve into:

Application
     │
     ▼
stdout/stderr
     │
     ▼
Container Runtime
     │
     ▼
Log Collector
     │
     ▼
Central Logging Platform
     │
 ┌───┼───────────┐
 ▼   ▼           ▼
Search Dashboard Alerts
🏆 DevOps Skills Demonstrated
Docker
Docker Compose
Container Logging
Logging Drivers
JSON Logging
Log Rotation
Resource-Aware Operations
Container Healthchecks
Docker Runtime Inspection
Python
Flask
Gunicorn
Pytest
Git
GitHub Actions
CI/CD
Container Security
Non-Root Containers
Least Privilege
Production Troubleshooting
Observability Fundamentals
📈 CI/CD Mastery Progress
Projects 01 → 25   ✅
Project 26          ✅ Dependency Resilience
Project 27          ✅ Resource Governance
Project 28          ✅ Logging & Rotation
Project 29          ⏳ Backup & Restore
Project 30          ⏳ Production Hardening
🔥 Final Takeaway

The key lesson from Project 28 is:

Container logging is an operational resource that must be deliberately governed.

A production-minded implementation should answer four questions:

1. Where do logs go?
2. How large can they become?
3. How long are they retained?
4. How are they collected centrally?

This project answers the first three at the Docker Compose layer while establishing the foundation for centralized observability.

Project 28 — Enterprise Docker Compose Logging & Rotation: COMPLETE ✅
