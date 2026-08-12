# 🚀 Project 16 — Docker Container Logging & Observability

![Docker](https://img.shields.io/badge/Docker-Container-blue?logo=docker)
![Python](https://img.shields.io/badge/Python-3.12-blue?logo=python)
![Flask](https://img.shields.io/badge/Flask-Application-black?logo=flask)
![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-CI-success?logo=githubactions)
![Status](https://img.shields.io/badge/Status-Completed-success)

> **CI/CD Mastery — Project 16**

---

# 📌 Project Overview

Project 16 introduces **Docker container logging** and demonstrates how application logs flow from a containerized application into Docker's logging subsystem.

The project focuses on:

- Application logging
- `stdout` and `stderr`
- Docker logging drivers
- `docker logs`
- Timestamped logs
- INFO and ERROR logs
- Application-level errors
- Container health
- CI/CD log validation
- Basic container observability

The central principle is:

> **Containerized applications should generally write logs to stdout/stderr so that the container runtime and external logging systems can collect them.**

---

# 🎯 Objectives

This project demonstrates how to:

1. Generate application logs.
2. Write logs to standard output.
3. Capture logs through Docker.
4. Retrieve logs with `docker logs`.
5. Follow logs in real time.
6. Display timestamps.
7. Generate INFO-level events.
8. Generate ERROR-level events.
9. Verify Docker's logging driver.
10. Validate logging automatically through GitHub Actions.

---

# 🏢 Enterprise Problem

When a containerized application fails, engineers need to answer:

> **What happened inside the container?**

Without application logging:

```text
Application
    ↓
Failure
    ↓
Container stops / request fails
    ↓
No useful diagnostic information

With proper logging:

Application
    ↓
INFO / WARNING / ERROR
    ↓
stdout / stderr
    ↓
Docker logging subsystem
    ↓
Centralized logging platform
    ↓
Search / Alert / Troubleshooting

Logging is therefore a fundamental component of observability.

🏗️ Architecture
                       Flask Application
                              |
                 +------------+------------+
                 |                         |
              INFO logs                ERROR logs
                 |                         |
                 +------------+------------+
                              |
                              v
                         stdout/stderr
                              |
                              v
                     Docker Logging Driver
                              |
                         json-file
                              |
                              v
                         docker logs
                              |
                +-------------+-------------+
                |                           |
                v                           v
           Developer                    CI/CD Pipeline
           Troubleshooting             Validation
📁 Project Structure
project-16-container-logging/
│
├── .dockerignore
├── Dockerfile
├── README.md
├── app.py
└── test_app.py

GitHub Actions:

.github/
└── workflows/
    └── project-16-container-logging.yml
🐍 Application

The project uses a lightweight Flask application.

Endpoints:

GET /
GET /health
GET /error
/ Endpoint

The root endpoint generates an INFO log:

request_received

Example:

INFO project-16 request_received endpoint=/ environment=development version=1.0.0
/health Endpoint

The health endpoint generates:

INFO project-16 healthcheck endpoint=/health

Docker's HEALTHCHECK periodically calls this endpoint.

Therefore, healthcheck activity also appears in the container logs.

/error Endpoint

The /error endpoint intentionally generates an application error:

ERROR project-16 simulated_application_error

and returns:

{
  "status": "error",
  "message": "simulated error"
}

with HTTP status:

500

This is intentionally simulated so that logging behavior can be validated without causing the container itself to fail.

📝 Python Logging

The application configures Python logging:

logging.basicConfig(
    level=logging.INFO,
    stream=sys.stdout,
    format="%(asctime)s %(levelname)s %(name)s %(message)s"
)

The important configuration is:

stream=sys.stdout

This sends application logs to standard output.

Docker can then capture those logs.

🔄 Logging Flow
Python logger
      |
      v
sys.stdout
      |
      v
Docker container
      |
      v
Docker logging driver
      |
      v
json-file
      |
      v
docker logs
📤 stdout vs stderr

Containers commonly use:

stdout
stderr

for application output.

A useful model is:

stdout
  ↓
Normal application events

stderr
  ↓
Errors / diagnostics

The exact logging behavior depends on the application and logging configuration.

For this project, Python logging is explicitly configured to write to:

stdout
🐳 Dockerfile

The Dockerfile uses:

python:3.12-slim

and installs Flask.

The container exposes:

5000

The Docker HEALTHCHECK validates:

http://127.0.0.1:5000/health
❤️ Docker HEALTHCHECK

The project retains the healthcheck pattern from previous projects:

HEALTHCHECK --interval=5s --timeout=3s --start-period=5s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:5000/health', timeout=2)" || exit 1

The result is:

running + healthy
🏗️ Build Image

Build:

docker build \
  -t ci-cd-mastery-project-16:1.0.0 \
  ./project-16-container-logging

Verify:

docker images | grep ci-cd-mastery-project-16
▶️ Run Container
docker rm -f project-16-app 2>/dev/null || true

docker run -d \
  --name project-16-app \
  -p 8094:5000 \
  -e APP_VERSION=1.0.0 \
  -e ENVIRONMENT=development \
  ci-cd-mastery-project-16:1.0.0
🔍 Verify Container
docker ps

Verify health:

docker inspect project-16-app \
  --format 'status={{.State.Status}} health={{.State.Health.Status}}'

Expected:

status=running health=healthy
📡 Generate Application Logs

Generate a normal request:

curl -fsS http://localhost:8094/

Generate a health request:

curl -fsS http://localhost:8094/health

Generate the intentional error:

curl -s http://localhost:8094/error

Expected:

{
  "message": "simulated error",
  "status": "error"
}
📜 View Container Logs

Use:

docker logs project-16-app

Example:

INFO project-16 application_starting version=1.0.0 environment=development
INFO project-16 healthcheck endpoint=/health
INFO project-16 request_received endpoint=/ environment=development version=1.0.0
ERROR project-16 simulated_application_error

This demonstrates that both normal and error-level application events are being captured.

🔴 Error Logging

The intentional /error request produced:

ERROR project-16 simulated_application_error

while the HTTP request returned:

500

The important point is:

HTTP 500
    ≠
Container failure

The application generated an error response, but the container remained running and healthy.

🔄 Follow Logs in Real Time

Use:

docker logs -f project-16-app

Then generate another request:

curl -fsS http://localhost:8094/

A new log entry appears immediately.

Stop following logs with:

Ctrl+C
⏱️ Timestamped Logs

Docker can display timestamps using:

docker logs -t project-16-app

Example:

2026-08-12T08:10:46.061937842Z INFO project-16 healthcheck endpoint=/health

This is useful when correlating application events with other infrastructure events.

🔢 Limit Number of Logs

Use:

docker logs --tail 10 project-16-app

This displays only the most recent 10 log entries.

Example:

docker logs --tail 10 project-16-app
🕒 Combine Tail and Timestamp
docker logs -t --tail 10 project-16-app

This provides a compact troubleshooting view containing recent events and timestamps.

🔎 Docker Logging Driver

Inspect the configured logging driver:

docker inspect project-16-app \
  --format '{{.HostConfig.LogConfig.Type}}'

Project validation returned:

json-file

Therefore:

Container
    ↓
json-file logging driver
    ↓
docker logs
📦 json-file Logging Driver

The json-file driver stores container logs in JSON format on the Docker host.

Docker can expose these logs through:

docker logs

The logging driver is configurable and should be selected according to the production logging architecture.

⚠️ Production Logging Consideration

Although json-file is useful for local development and learning, production environments commonly forward logs to a centralized logging platform.

A typical architecture is:

Container
    |
    v
stdout/stderr
    |
    v
Logging Driver / Agent
    |
    v
Central Log Platform
    |
    +---- Search
    +---- Dashboards
    +---- Alerts
    +---- Retention

Examples of centralized logging technologies include:

ELK / Elastic Stack
OpenSearch
CloudWatch Logs
Loki
Splunk
Datadog

The choice depends on the infrastructure and organizational requirements.

🧪 Automated Tests

Run:

python3 -m pytest -q project-16-container-logging

Project result:

3 passed

The tests validate:

GET /
GET /health
GET /error
🔄 CI/CD Pipeline

GitHub Actions automates the complete logging validation.

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
Wait for Healthy
   ↓
Generate Application Logs
   ↓
Verify Container Logs
   ↓
Verify Logging Driver
   ↓
Verify Container State
   ↓
Verify Timestamped Logs
   ↓
Cleanup

Workflow:

.github/workflows/project-16-container-logging.yml
🔍 CI Log Validation

The CI pipeline generates:

/
 /health
 /error

Then retrieves:

docker logs project-16-app

The pipeline verifies that expected log messages exist:

application_starting
request_received
healthcheck endpoint=/health
simulated_application_error

This means CI validates actual observability behavior instead of simply checking that the image builds.

🔐 CI Logging Driver Validation

The workflow checks:

docker inspect project-16-app \
  --format '{{.HostConfig.LogConfig.Type}}'

and verifies:

json-file
⏱️ CI Timestamp Validation

The workflow also runs:

docker logs -t --tail 20 project-16-app

This validates that Docker can provide timestamped log output.

📊 Local Validation Results

Project 16 local validation produced:

Python tests                  ✅ 3 passed
Docker build                  ✅
Container running             ✅
Docker health                 ✅ healthy
INFO logging                  ✅
ERROR logging                 ✅
docker logs                   ✅
Timestamped logs              ✅
Logging driver                ✅ json-file

Container state:

status=running health=healthy

Logging driver:

json-file
🚀 GitHub Actions Validation

Dedicated workflow:

Project 16 - Container Logging

Successful run:

Run ID: 31577303802

Result:

SUCCESS ✅

Job:

container-logging

Duration:

28 seconds
✅ CI Steps Passed
✓ Set up job
✓ Checkout
✓ Set up Python
✓ Install dependencies
✓ Run tests
✓ Build Docker image
✓ Run container
✓ Wait for healthy container
✓ Generate application logs
✓ Verify container logs
✓ Verify logging driver
✓ Verify container state
✓ Verify timestamped logs
✓ Cleanup
✓ Complete job
⚠️ GitHub Actions Annotation

The workflow produced a Node.js runtime deprecation annotation related to GitHub Actions dependencies:

Node.js 20 is deprecated

This was an annotation/warning and did not fail the workflow.

The Project 16 workflow completed successfully.

🧠 Important Observability Concepts
Logging

Answers:

What happened?

Example:

ERROR database_connection_failed
Metrics

Answers:

How much / how many?

Examples:

CPU usage
Memory usage
Request count
Request latency
Traces

Answers:

Where did the request spend time across services?

Example:

Client
  ↓
API Gateway
  ↓
Service A
  ↓
Service B
  ↓
Database

Project 16 focuses primarily on:

LOGGING
🎤 Interview Questions & Answers
1. Why should containers log to stdout/stderr?

Container runtimes can capture stdout/stderr and make those logs available to logging systems.

This separates application logging from the container filesystem.

2. What command displays Docker container logs?
docker logs <container>

Example:

docker logs project-16-app
3. How do you follow logs continuously?
docker logs -f project-16-app

-f means follow.

4. How do you display timestamps?
docker logs -t project-16-app
5. How do you show only the last 20 lines?
docker logs --tail 20 project-16-app
6. What is a Docker logging driver?

A Docker logging driver determines how container logs are handled and where they are sent/stored.

Examples include:

json-file
local
syslog
journald
fluentd
awslogs
gcplogs
splunk
7. What logging driver did you use?

Project 16 validated:

json-file

using:

docker inspect project-16-app \
  --format '{{.HostConfig.LogConfig.Type}}'
8. What is the problem with logging only to files inside a container?

Containers are designed to be replaceable and ephemeral.

Logs stored only inside the container filesystem can become difficult to retrieve when the container is removed.

For containerized workloads, stdout/stderr plus external log collection is generally a better pattern.

9. What is centralized logging?

Centralized logging collects logs from multiple workloads into a common platform.

Example:

Container A ─┐
Container B ─┼──> Central Logging Platform
Container C ─┘

This enables:

Search
Correlation
Retention
Dashboards
Alerting
Troubleshooting
10. What is the difference between logs and metrics?

Logs represent individual events.

Example:

ERROR payment_failed order=123

Metrics represent numerical measurements.

Example:

http_requests_total = 5000
11. What is structured logging?

Structured logging represents log information in a machine-readable format.

For example:

{
  "level": "ERROR",
  "service": "payment",
  "event": "database_connection_failed"
}

Structured logs are easier to search, parse and correlate.

12. Why is structured logging useful in microservices?

Because multiple services generate large amounts of logs.

Structured fields make it easier to search by:

service
environment
request ID
trace ID
user ID
status
timestamp
13. What happens if an application returns HTTP 500?

An HTTP 500 indicates an application/server-side request failure.

It does not automatically mean the Docker container has stopped.

Project 16 demonstrates:

HTTP 500
      ↓
Application error log
      ↓
Container remains running
      ↓
Healthcheck can remain healthy
14. What is the difference between application health and application errors?

An application can return an error for one request while still being operational.

For example:

GET /error → 500
GET /health → 200

Therefore health and request-level failures are different signals.

15. Why shouldn't production systems depend on docker logs manually?

Because manually inspecting each host doesn't scale.

Production systems typically centralize logs so engineers can:

Search
Correlate
Alert
Analyze
Retain

logs across many containers and hosts.

16. How would you troubleshoot a crashing container?

A basic investigation might include:

docker ps -a
docker logs <container>
docker inspect <container>
docker stats <container>

Then investigate:

Application errors
Configuration
Resource exhaustion
Healthchecks
Dependencies
Network connectivity
17. How would you prevent logs from consuming too much disk?

Use appropriate logging-driver configuration and log rotation/retention policies.

For example, Docker's local logging driver is designed with rotation considerations, while json-file can be configured with size/count options.

The exact strategy should match the production logging architecture.

18. What should an application log?

Useful events include:

Application startup
Request processing
Errors
Dependency failures
Authentication events
Configuration events
Important state transitions

Avoid logging sensitive information such as:

Passwords
Tokens
Private keys
Secrets
19. How does logging fit into observability?

Observability is commonly described through:

Logs
Metrics
Traces

Logs provide detailed event context.

Metrics provide numerical system behavior.

Traces provide request-flow visibility across distributed services.

20. Explain Project 16 in an interview.

A strong answer:

"In Project 16 of my CI/CD mastery portfolio, I implemented Docker container logging and basic observability. I configured a Flask application to write structured application events to stdout, including startup, request, healthcheck and error events. I then validated Docker's json-file logging driver using docker inspect, retrieved and followed logs using docker logs, and verified timestamped output. I also created a CI pipeline that builds the image, runs the container, generates INFO and ERROR events, validates expected log messages, verifies the logging driver, validates container health and cleans up the container."

🔥 Production Mental Model

A production container should follow:

Application
     |
     +---- stdout
     |
     +---- stderr
     |
     v
Container Runtime
     |
     v
Logging Driver / Agent
     |
     v
Central Logging Platform
     |
     +---- Search
     +---- Dashboards
     +---- Alerts
     +---- Retention

This is much more scalable than storing logs only inside individual containers.

🧩 Troubleshooting Cheat Sheet
View logs
docker logs project-16-app
Follow logs
docker logs -f project-16-app
Last 50 lines
docker logs --tail 50 project-16-app
Timestamps
docker logs -t project-16-app
Last 20 with timestamps
docker logs -t --tail 20 project-16-app
Inspect logging driver
docker inspect project-16-app \
  --format '{{.HostConfig.LogConfig.Type}}'
Inspect container
docker inspect project-16-app
Check health
docker inspect project-16-app \
  --format 'status={{.State.Status}} health={{.State.Health.Status}}'
🏆 Completion Checklist
 Project branch
 Flask application
 Python logging
 stdout logging
 INFO logging
 ERROR logging
 /health endpoint
 /error endpoint
 Dockerfile
 Docker HEALTHCHECK
 Docker image
 Container runtime
 docker logs
 docker logs -f
 Timestamped logs
 Tail logs
 Logging driver inspection
 json-file validation
 Python tests
 GitHub Actions
 CI log validation
 CI health validation
 CI cleanup
 Successful GitHub Actions run
 README
🎯 Key Commands
Build
docker build \
  -t ci-cd-mastery-project-16:1.0.0 \
  ./project-16-container-logging
Run
docker run -d \
  --name project-16-app \
  -p 8094:5000 \
  -e APP_VERSION=1.0.0 \
  -e ENVIRONMENT=development \
  ci-cd-mastery-project-16:1.0.0
Logs
docker logs project-16-app
Follow
docker logs -f project-16-app
Timestamp
docker logs -t project-16-app
Tail
docker logs --tail 10 project-16-app
Logging Driver
docker inspect project-16-app \
  --format '{{.HostConfig.LogConfig.Type}}'
Health
docker inspect project-16-app \
  --format 'status={{.State.Status}} health={{.State.Health.Status}}'
Tests
python3 -m pytest -q project-16-container-logging
🚀 Final Result
PROJECT 16
Docker Container Logging
          |
          +---- stdout/stderr
          |
          +---- INFO logs
          |
          +---- ERROR logs
          |
          +---- docker logs
          |
          +---- json-file
          |
          +---- timestamps
          |
          +---- CI validation
          |
          +---- Healthcheck
🏆 PROJECT 16 — COMPLETED
Next Project

Project 17 — Docker Log Rotation & Disk Protection

Focus:

Container Logs
      ↓
Log Growth
      ↓
Disk Consumption
      ↓
Log Rotation
      ↓
Retention
      ↓
Docker Logging Configuration
      ↓
CI Validation

The progression is now:

13 → Health
14 → Resources
15 → Configuration
16 → Logging
17 → Log Rotation
