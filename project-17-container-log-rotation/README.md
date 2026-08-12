# 🚀 Project 17 — Docker Log Rotation & Disk Protection

![Docker](https://img.shields.io/badge/Docker-Container-blue?logo=docker)
![Python](https://img.shields.io/badge/Python-3.12-blue?logo=python)
![Flask](https://img.shields.io/badge/Flask-Application-black?logo=flask)
![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-CI-success?logo=githubactions)
![Status](https://img.shields.io/badge/Status-Completed-success)

> **CI/CD Mastery — Project 17**

---

# 📌 Project Overview

Project 17 demonstrates **Docker log rotation** and the importance of controlling container log growth.

Containerized applications continuously generate logs. Without a retention and rotation strategy, logs can consume increasing amounts of host disk space.

The project demonstrates:

- Docker logging drivers
- `json-file`
- `max-size`
- `max-file`
- Log rotation
- Disk protection
- Runtime logging configuration
- Container health
- CI/CD validation

The central principle is:

> **Logs must have controlled size and retention so that logging itself does not become a disk-space outage.**

---

# 🎯 Objectives

This project demonstrates how to:

1. Configure Docker log rotation.
2. Limit the maximum size of individual log files.
3. Limit the number of retained log files.
4. Verify the logging driver.
5. Generate application logs.
6. Verify that the container remains healthy.
7. Validate configuration automatically through GitHub Actions.

---

# 🏢 Enterprise Problem

A container can continue generating logs indefinitely.

Without log rotation:

```text
Container
   ↓
Logs
   ↓
10 MB
   ↓
100 MB
   ↓
1 GB
   ↓
10 GB
   ↓
Disk Full
   ↓
Production Outage

This creates an infrastructure risk.

A better approach is:

Container
    ↓
Logs
    ↓
Maximum Size
    ↓
Rotation
    ↓
Limited Retention
    ↓
Controlled Disk Usage
🏗️ Architecture
                    Flask Application
                           |
                           v
                     stdout/stderr
                           |
                           v
                  Docker Logging Driver
                           |
                       json-file
                           |
                +----------+----------+
                |                     |
                v                     v
          max-size=10k          max-file=3
                |                     |
                +----------+----------+
                           |
                           v
                     Log Rotation
                           |
                           v
                  Controlled Disk Usage
📁 Project Structure
project-17-container-log-rotation/
│
├── .dockerignore
├── Dockerfile
├── README.md
├── app.py
└── test_app.py

GitHub Actions:

.github/
└── workflows/
    └── project-17-container-log-rotation.yml
🐍 Application

The Flask application exposes:

GET /
GET /health
GET /log

The /log endpoint intentionally generates application log entries.

/log Endpoint

The endpoint generates:

INFO project-17 generated_log

Example:

curl http://localhost:8095/log

Response:

{
  "status": "logged",
  "message": "project-17 log rotation test"
}

This endpoint allows repeated log generation for testing rotation configuration.

📝 Logging

The application writes logs to:

stdout

using Python logging.

The logging flow is:

Application
     ↓
Python logger
     ↓
stdout
     ↓
Docker logging driver
     ↓
json-file
🐳 Docker Logging Configuration

The container was started with:

docker run -d \
  --name project-17-app \
  -p 8095:5000 \
  -e APP_VERSION=1.0.0 \
  -e ENVIRONMENT=development \
  --log-opt max-size=10k \
  --log-opt max-file=3 \
  ci-cd-mastery-project-17:1.0.0

The important options are:

max-size=10k
max-file=3
📏 max-size

max-size defines the maximum size of an individual log file before Docker rotates it.

Project configuration:

max-size=10k

Conceptually:

Log file
   ↓
10 KB
   ↓
Rotation
📦 max-file

max-file controls the number of log files retained.

Project configuration:

max-file=3

Conceptually:

Current log
Rotated log 1
Rotated log 2

Older logs are removed as new rotation occurs.

🔄 Log Rotation Model

The project demonstrates:

              Log Generation
                    |
                    v
                Current Log
                    |
                 10 KB
                    |
                    v
                Rotation
                    |
        +-----------+-----------+
        |           |           |
        v           v           v
      File 1      File 2      File 3
                    |
                    v
             Oldest removed

The exact disk usage can include filesystem and Docker overhead, so max-size × max-file should be treated as a configuration target rather than an exact total-storage guarantee.

🔍 Verify Logging Driver

Run:

docker inspect project-17-app \
  --format '{{.HostConfig.LogConfig.Type}}'

Expected:

json-file

Project result:

json-file
🔍 Verify Rotation Configuration

Run:

docker inspect project-17-app \
  --format 'driver={{.HostConfig.LogConfig.Type}} options={{json .HostConfig.LogConfig.Config}}'

Project result:

driver=json-file options={"max-file":"3","max-size":"10k"}

This proves the configuration was applied to the running container.

📜 View Logs
docker logs project-17-app

Tail recent logs:

docker logs --tail 10 project-17-app

Timestamped logs:

docker logs -t project-17-app
🔥 Generate Large Numbers of Log Events

The project can generate many log entries quickly:

for i in $(seq 1 500); do
  curl -s http://localhost:8095/log >/dev/null
done

This creates enough logging activity to exercise the configured rotation policy.

❤️ Container Health

The application has a Docker HEALTHCHECK.

Verify:

docker inspect project-17-app \
  --format 'status={{.State.Status}} health={{.State.Health.Status}}'

Expected:

status=running health=healthy

Project result:

status=running health=healthy

This confirms that log generation and rotation configuration did not prevent the application from remaining healthy.

🧪 Automated Tests

Run:

python3 -m pytest -q project-17-container-log-rotation

Project result:

3 passed

Tests validate:

GET /
GET /health
GET /log
🔄 CI/CD Pipeline

GitHub Actions validates the complete implementation.

Pipeline:

Checkout
   ↓
Setup Python
   ↓
Install Dependencies
   ↓
Run Tests
   ↓
Build Docker Image
   ↓
Run Container
   ↓
Configure Log Rotation
   ↓
Wait for Healthy
   ↓
Verify Logging Driver
   ↓
Verify max-size
   ↓
Verify max-file
   ↓
Generate Logs
   ↓
Verify Logs
   ↓
Verify Container State
   ↓
Cleanup

Workflow:

.github/workflows/project-17-container-log-rotation.yml
🔍 CI Rotation Validation

The CI pipeline retrieves:

Logging driver
max-size
max-file

and verifies:

driver = json-file
max-size = 10k
max-file = 3

This ensures the pipeline validates the actual running container configuration rather than only checking the Dockerfile.

📊 Local Validation

Project 17 local validation:

Python tests                  ✅ 3 passed
Docker build                  ✅
Container startup             ✅
Container health              ✅ healthy
Logging driver                ✅ json-file
max-size                      ✅ 10k
max-file                      ✅ 3
Log generation                ✅
Log retrieval                 ✅

Evidence:

status=running health=healthy

and:

driver=json-file options={"max-file":"3","max-size":"10k"}
🚀 GitHub Actions Validation

Successful workflow:

Project 17 - Container Log Rotation

Run ID:

31578497126

Job:

log-rotation

Duration:

26 seconds

Result:

SUCCESS ✅
✅ CI Steps Passed
✓ Set up job
✓ Checkout
✓ Set up Python
✓ Install dependencies
✓ Run tests
✓ Build Docker image
✓ Run container with log rotation
✓ Wait for healthy container
✓ Verify logging driver
✓ Verify log rotation configuration
✓ Generate application logs
✓ Verify logs
✓ Verify container state
✓ Cleanup
✓ Complete job
🎤 Interview Questions & Answers
1. Why is log rotation important?

Without log rotation, container logs can grow continuously and consume host disk space.

Eventually this can cause:

Disk exhaustion
Application failures
Container failures
Host instability
Production outages
2. What does max-size do?

It specifies the maximum size of a log file before Docker rotates it.

Example:

max-size=10m

means a log file is rotated around that configured size.

3. What does max-file do?

It specifies how many log files Docker retains.

Example:

max-file=3

means the configured logging system retains the current/rotated set according to that limit.

4. What configuration did Project 17 use?
max-size=10k
max-file=3

with:

json-file

as the logging driver.

5. How do you configure Docker log rotation?

For a container:

docker run \
  --log-opt max-size=10k \
  --log-opt max-file=3 \
  image
6. How do you verify the configuration?

Use:

docker inspect <container> \
  --format '{{json .HostConfig.LogConfig.Config}}'
7. What is a logging driver?

A Docker logging driver controls how container logs are handled, stored or forwarded.

Examples include:

json-file
local
syslog
journald
fluentd
awslogs
8. Why shouldn't you rely only on unlimited json-file logs?

Because local log files can consume disk space indefinitely if retention/rotation isn't configured appropriately.

9. Is log rotation the same as centralized logging?

No.

Log rotation controls:

size
retention
local storage

Centralized logging focuses on:

collection
search
correlation
analysis
alerting
retention

They solve related but different problems.

10. What happens when max-size is reached?

Docker rotates the log file according to the configured logging driver's behavior and retention settings.

With:

max-size=10k

the log file is rotated around that configured size.

11. What happens when max-file is exceeded?

Older rotated files are removed according to the logging driver's retention behavior so that the configured number of files is maintained.

12. Why shouldn't applications implement their own container log rotation?

In containerized environments, applications should generally write to stdout/stderr and let the container runtime or centralized logging system handle collection and retention.

This keeps application code simpler and separates concerns.

13. What happens if the host disk becomes full?

Possible consequences include:

Container failures
Database failures
Application crashes
Docker failures
System instability

Disk monitoring and log retention are therefore important operational controls.

14. How would you handle logging in Kubernetes?

A common Kubernetes pattern is:

Application
    ↓
stdout/stderr
    ↓
Container runtime
    ↓
Node-level collection
    ↓
Central logging platform

Kubernetes workloads should generally avoid depending on logs stored only inside ephemeral container filesystems.

15. How would you implement centralized logging in AWS?

Possible architectures include:

Container
   ↓
stdout/stderr
   ↓
CloudWatch Logs

or:

Container
   ↓
Fluent Bit
   ↓
CloudWatch / OpenSearch

The exact design depends on the AWS service architecture.

16. What is the difference between retention and rotation?

Rotation controls when a log file is rolled over.

Retention controls how long/how many historical logs are kept.

Example:

max-size → rotation trigger
max-file → local file retention count
17. How would you troubleshoot excessive Docker disk usage?

I would investigate:

docker system df
docker ps -a
docker inspect <container>
docker logs --tail 100 <container>

Then check:

Container logs
Image usage
Volumes
Build cache
Host filesystem usage
Logging configuration
18. Why is log rotation a reliability concern rather than merely a housekeeping task?

Because uncontrolled logs can consume infrastructure resources.

Therefore:

Logging
   ↓
Disk consumption
   ↓
Resource exhaustion
   ↓
Service impact

Log management directly contributes to reliability.

19. What would you use in production instead of max-size=10k?

The exact values depend on:

Application traffic
Log volume
Disk capacity
Retention requirements
Centralized logging architecture
Compliance requirements

For a production system, I would establish an appropriate rotation and retention policy rather than copying a lab value.

20. Explain Project 17 in an interview.

"In Project 17, I implemented Docker log rotation to prevent uncontrolled container log growth from consuming host disk space. I configured the Docker json-file logging driver with max-size=10k and max-file=3, verified the configuration using docker inspect, generated application logs to exercise the configuration, and confirmed that the container remained healthy. I then automated the complete validation through GitHub Actions, including testing, image building, health validation, logging-driver verification, rotation configuration checks, log generation and cleanup."

🧠 Production Mental Model

Remember this:

                Application
                    |
                stdout/stderr
                    |
                    v
              Logging Driver
                    |
          +---------+---------+
          |                   |
          v                   v
       Rotation          Centralization
          |                   |
          v                   v
     Disk Protection    Search/Alerts

Project 17 specifically focuses on:

Rotation → Retention → Disk Protection

Project 16 focused on:

Application Logging → Docker Logs
🔥 Key Commands
Run with rotation
docker run -d \
  --log-opt max-size=10k \
  --log-opt max-file=3 \
  image
Check driver
docker inspect <container> \
  --format '{{.HostConfig.LogConfig.Type}}'
Check options
docker inspect <container> \
  --format '{{json .HostConfig.LogConfig.Config}}'
Generate logs
for i in $(seq 1 500); do
  curl -s http://localhost:8095/log >/dev/null
done
Read logs
docker logs <container>
Tail logs
docker logs --tail 10 <container>
🏆 Completion Checklist
 Project branch
 Flask application
 Logging endpoint
 Dockerfile
 Docker HEALTHCHECK
 Docker image
 Container
 json-file logging driver
 max-size
 max-file
 Log generation
 Log verification
 Container health verification
 Python tests
 GitHub Actions
 CI logging-driver validation
 CI rotation validation
 CI cleanup
 Successful CI run
 README
🎯 Final Project 17 Result
PROJECT 17
Docker Log Rotation
       |
       +---- json-file
       |
       +---- max-size=10k
       |
       +---- max-file=3
       |
       +---- Log Generation
       |
       +---- Healthcheck
       |
       +---- CI Validation
       |
       +---- Disk Protection
🏆 PROJECT 17 — COMPLETED

Progress: 17 / 40

Next:

🚀 PROJECT 18 — Docker Compose Multi-Container Application

We'll move from individual containers to:

                 Docker Compose
                      |
          +-----------+-----------+
          |                       |
          v                       v
      Application              Database
          |                       |
          +-----------+-----------+
                      |
                  Networking
                      |
                 Healthchecks
                      |
                Dependency Order

This is the next major jump from single-container operations → multi-container orchestration.
