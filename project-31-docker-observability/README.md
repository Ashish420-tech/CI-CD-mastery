Project 31 — Enterprise Docker Observability

Production-oriented container observability platform using Docker Compose, Prometheus, cAdvisor and application-native metrics.

1. Executive Summary

This project implements a production-style observability foundation for containerized workloads.

The platform collects two categories of telemetry:

Application-level metrics
Container/runtime-level metrics

The application exposes Prometheus-compatible metrics through /metrics, while cAdvisor exposes container resource metrics. Prometheus continuously scrapes both sources and makes the telemetry queryable.

Business value

Without observability, a container platform can tell us only:

"The container is running."

With observability, we can answer:

Is the application healthy?
Is traffic increasing?
Is the application receiving requests?
Is the container consuming excessive memory?
Is CPU consumption increasing?
Is the metrics pipeline itself healthy?
Which monitoring target is down?
Can we detect degradation before users report it?
2. Architecture
                    ┌─────────────────────────┐
                    │       Client / User      │
                    └────────────┬────────────┘
                                 │
                                 ▼
                    ┌─────────────────────────┐
                    │     Flask + Gunicorn     │
                    │        App :5000         │
                    │                         │
                    │ /health                 │
                    │ /metrics                │
                    │ /                       │
                    └────────────┬────────────┘
                                 │
                                 │ Prometheus scrape
                                 ▼
                    ┌─────────────────────────┐
                    │      Prometheus :9090   │
                    │                         │
                    │ Time-series database    │
                    │ Query engine            │
                    │ Target health            │
                    └────────────┬────────────┘
                                 ▲
                                 │
                  ┌──────────────┴──────────────┐
                  │                             │
                  │                             │
        ┌─────────┴─────────┐        ┌──────────┴─────────┐
        │ Application       │        │ cAdvisor           │
        │ Metrics           │        │ :8080              │
        │                   │        │                    │
        │ request counter   │        │ CPU                │
        │ uptime            │        │ memory             │
        │ application data  │        │ filesystem         │
        └───────────────────┘        │ container metrics  │
                                     └────────────────────┘
3. Technology Stack
Technology	Purpose
Docker	Container runtime
Docker Compose	Multi-container orchestration
Python 3.12	Application runtime
Flask	HTTP API
Gunicorn	Production WSGI server
Prometheus Client	Application metrics
Prometheus	Metrics collection and querying
cAdvisor	Container-level metrics
pytest	Automated testing
GitHub Actions	CI validation
4. Repository Structure
project-31-docker-observability/
│
├── app/
│   ├── app.py
│   └── requirements.txt
│
├── prometheus/
│   └── prometheus.yml
│
├── tests/
│   └── test_observability.py
│
├── Dockerfile
├── docker-compose.yml
├── .dockerignore
└── .gitignore
5. Application Observability

The application exposes:

GET /
GET /health
GET /metrics
/health

Used for container health verification.

Example:

{
  "status": "healthy",
  "uid": 10001
}

The application running as UID 10001 demonstrates that observability does not require privileged application execution.

6. Application Metrics

The application uses the Prometheus Python client.

Important metrics include:

application_requests_total
application_uptime_seconds

Example:

# HELP application_requests_total Total application requests
# TYPE application_requests_total counter
application_requests_total 28.0

And:

# HELP application_uptime_seconds Application uptime in seconds
# TYPE application_uptime_seconds gauge
application_uptime_seconds 67.09
Interview concept

Counter vs Gauge

A Counter represents a value that normally increases:

requests_total
errors_total
orders_processed_total

A Gauge represents a value that can increase or decrease:

memory_usage
active_connections
temperature
uptime
7. Prometheus

Prometheus acts as the central metrics collection and querying system.

It periodically scrapes:

app:5000/metrics

and:

cadvisor:8080/metrics

The configured scrape interval is:

scrape_interval: 5s

This makes the environment suitable for demonstrating near-real-time metrics collection.

8. Prometheus Target Discovery

The project verifies:

application → UP
cadvisor    → UP

The actual runtime verification produced:

application up http://app:5000/metrics
cadvisor up http://cadvisor:8080/metrics

This is an important distinction.

A container being Running does not automatically mean Prometheus can successfully scrape it.

Prometheus target health confirms:

Container running
        +
Endpoint reachable
        +
Metrics endpoint valid
        =
Monitoring target UP
9. cAdvisor

cAdvisor provides container-level telemetry.

It exposes information such as:

CPU usage
Memory usage
Filesystem usage
Block I/O
Container lifecycle information
Container metadata

Example metric family:

container_memory_usage_bytes

This allows an engineer to investigate:

"Is the application slow because the application is broken, or because the container is resource constrained?"

10. End-to-End Telemetry Flow

The complete telemetry path is:

HTTP Request
     │
     ▼
Flask Application
     │
     ├── request counter
     └── uptime gauge
             │
             ▼
        /metrics
             │
             ▼
        Prometheus
             │
             ├── application target
             └── cAdvisor target
                     │
                     ▼
              Docker metrics

This is the foundation for a larger monitoring architecture.

11. Runtime Verification

The final runtime verification demonstrated:

Application       HEALTHY
Application UID   10001
Prometheus        HEALTHY
Application       UP
cAdvisor          UP
Prometheus query  SUCCESS
cAdvisor metrics  AVAILABLE

The Prometheus query successfully returned:

application_requests_total

with:

job="application"
instance="app:5000"

This proves that the metric was not merely exposed by Flask—it was actually scraped and stored by Prometheus.

12. Security Controls

The application container runs as:

10001:10001

rather than root.

The Compose configuration also uses:

security_opt:
  - no-new-privileges:true
Why?

no-new-privileges prevents processes inside the container from gaining additional privileges through mechanisms such as setuid/setgid binaries.

This follows the principle:

The monitoring application should have only the privileges it actually needs.

13. Why cAdvisor Requires More Privilege

A common interview question:

"Why is cAdvisor more privileged than the application?"

Because cAdvisor needs visibility into host/container runtime information.

It reads host resources such as:

/sys
/var/run
/var/lib/docker
/rootfs

The application does not require this visibility.

Therefore:

Application → least privilege
cAdvisor    → elevated monitoring access

This is an important production-security distinction.

14. Healthchecks

The application has a Docker healthcheck.

Prometheus also has a healthcheck.

This creates two separate concepts:

Container health
Is the service process healthy?
Monitoring health
Can Prometheus successfully observe the service?

These should not be confused.

15. Why Gunicorn?

The project deliberately avoids:

flask run

for production-style execution.

Instead:

Gunicorn
      ↓
WSGI
      ↓
Flask

Gunicorn provides a production-oriented application server model.

Interview answer:

"I used Gunicorn rather than Flask's development server because the project is intended to model production-style container execution."

16. Docker Health vs Prometheus Health

This is a very important interview distinction.

Docker healthcheck
Container → application health
Prometheus target health
Prometheus → scrape endpoint health

Possible scenario:

Container = healthy
Prometheus target = DOWN

Why?

Possibilities include:

wrong service name
wrong port
incorrect metrics path
networking problem
Prometheus configuration error

Therefore, observability troubleshooting must consider both layers.

17. Testing Strategy

The project includes pytest tests validating:

Required services
Prometheus configuration
Application metrics
Non-root execution
Healthchecks
Security configuration

The test suite passed locally.

The CI pipeline also validates the Docker environment.

18. CI/CD Pipeline

Dedicated workflow:

.github/workflows/project-31-docker-observability.yml

Pipeline stages:

Checkout
   ↓
Python 3.12
   ↓
Install test dependencies
   ↓
pytest
   ↓
Compose validation
   ↓
Docker build
   ↓
Start stack
   ↓
Application health
   ↓
Application metrics
   ↓
Prometheus health
   ↓
Prometheus target readiness
   ↓
cAdvisor validation
   ↓
Security validation
   ↓
Cleanup

The dedicated Project 31 workflow is now GREEN.

19. Important Failure & Root Cause

The first CI implementation failed at:

Verify Prometheus targets

The stack itself was healthy.

The problem was the CI validation logic.

The original check assumed that finding:

application

in the Prometheus API response was sufficient.

That does not prove the target is healthy.

The validation was upgraded to wait for:

"job":"application"

with:

"health":"up"

This is a much stronger production-style readiness check.

Interview story

This gives you an excellent troubleshooting answer:

"My first CI implementation passed application and Prometheus health checks but failed target validation. I investigated the workflow rather than changing the architecture. I realized the validation was checking target existence rather than target health. I changed it to poll the Prometheus target API until the application target reported health=up. The pipeline then passed."

That's a real DevOps troubleshooting story.

20. Useful Operational Commands
Start
docker compose up -d
Stop
docker compose down
Status
docker compose ps
Logs
docker compose logs -f
Application health
curl http://localhost:5001/health
Application metrics
curl http://localhost:5001/metrics
Prometheus health
curl http://localhost:9090/-/healthy
Prometheus targets
curl http://localhost:9090/api/v1/targets
Prometheus query
curl -G http://localhost:9090/api/v1/query \
  --data-urlencode 'query=application_requests_total'
21. Troubleshooting Playbook
Problem: Application target DOWN

Check:

docker compose ps

Then:

docker compose logs app

Then:

curl http://localhost:5001/metrics

Check Prometheus target configuration.

Problem: Prometheus unhealthy

Check:

docker compose logs prometheus

Validate:

docker compose config

Check:

prometheus/prometheus.yml
Problem: cAdvisor unavailable

Check:

docker compose logs cadvisor

Then:

curl http://localhost:9091/metrics

cAdvisor requires access to host/container runtime information, so its volume configuration is particularly important.

22. Production Improvements

For a real production platform, this project would be extended with:

Prometheus
    ↓
Alertmanager
    ↓
PagerDuty / Slack / Email

and:

Prometheus
    ↓
Grafana
    ↓
Dashboards

Additional improvements:

persistent Prometheus storage
retention policies
alert rules
SLO/SLI metrics
TLS
authentication
service discovery
remote_write
centralized logging
distributed tracing
OpenTelemetry
Kubernetes integration
23. Observability Maturity

This project represents the metrics foundation.

Level 1
Healthchecks
   ↓
Level 2
Application Metrics
   ↓
Level 3
Container Metrics
   ↓
Level 4
Dashboards
   ↓
Level 5
Alerting
   ↓
Level 6
SLO / SLI
   ↓
Level 7
Tracing + Logs + Metrics

Project 31 establishes Levels 1–3.

24. Interview Questions
Q1. Why Prometheus?

Answer:

Prometheus is designed around a pull-based metrics model and provides a powerful time-series query language. It is particularly suitable for containerized environments because targets can be dynamically discovered and monitored.

Q2. Why use cAdvisor?

cAdvisor exposes container-level resource and runtime metrics that aren't normally available from application metrics alone. It helps correlate application behavior with CPU, memory, filesystem and container-level resource consumption.

Q3. What is the difference between application and infrastructure metrics?

Application metrics describe business or application behavior such as request counts, errors and latency. Infrastructure metrics describe the environment running the application, such as CPU, memory, disk and container resource usage.

Q4. What does Prometheus UP mean?

It means Prometheus successfully scraped the target during the most recent scrape. It does not necessarily mean the entire application is healthy from a business perspective.

Q5. Why have a /health endpoint if Prometheus already monitors the application?

They solve different problems. The health endpoint determines application/process readiness, while Prometheus provides continuous telemetry and monitoring. Both are complementary.

Q6. Why shouldn't the application run as root?

Running as a non-root user limits the impact of a container compromise. If an attacker gains application-level access, they don't automatically receive root privileges inside the container.

Q7. Why use Gunicorn?

Flask's development server isn't intended for production workloads. Gunicorn provides a production-oriented WSGI server and process management model.

Q8. What happens if Prometheus goes down?

The application can continue serving traffic because Prometheus is not in the application request path. However, monitoring visibility is lost and metrics won't be collected during the outage. In production I'd address this with persistent storage, redundancy and alerting.

Q9. How would you troubleshoot a target showing DOWN?

My sequence would be:

Prometheus target status
        ↓
DNS/service resolution
        ↓
Network connectivity
        ↓
Endpoint/port
        ↓
/metrics response
        ↓
Application logs
        ↓
Prometheus logs
Q10. What was the actual failure you encountered in this project?

Strong answer:

"The first CI implementation failed during Prometheus target validation. The containers and Prometheus were healthy, but the workflow validated only the presence of the application target rather than its scrape health. I changed the workflow to poll the target API until the application reported health=up. This made the CI validation reflect the actual monitoring state rather than just configuration presence."

25. Resume Bullet

Use this version:

Built a production-oriented Docker observability platform using Prometheus, cAdvisor, Flask and Gunicorn, implementing application and container metrics, health monitoring, non-root execution, security controls and automated GitHub Actions validation.

Stronger version:

Engineered an enterprise-style Docker observability stack with Prometheus and cAdvisor, exposing application metrics and container telemetry, validating target health automatically, enforcing non-root/no-new-privileges security, and integrating end-to-end CI validation through GitHub Actions.

26. Interview Architecture Explanation — 60 Seconds

If an interviewer asks:

"Explain your Docker observability project."

Say:

"I built a Docker Compose-based observability platform consisting of a Flask application, Prometheus and cAdvisor. The application exposes Prometheus-compatible metrics through /metrics, while cAdvisor collects container-level CPU, memory and runtime metrics. Prometheus periodically scrapes both targets and provides a query interface for the collected time-series data. I added Docker healthchecks, non-root execution and no-new-privileges for the application container. The GitHub Actions pipeline validates the Compose configuration, builds the image, starts the complete stack, verifies application metrics, waits for Prometheus targets to report healthy, validates cAdvisor metrics and performs security checks. During development the initial target validation failed because it checked target existence instead of scrape health, so I changed it to poll until the target reported up. This gave me a realistic CI troubleshooting scenario rather than just a successful build."

That's interview-ready. 🔥

Project 31 Final State
Project:        31 — Docker Observability
Branch:         project-31-docker-observability
Commit:         f239323
CI:             GREEN
Application:    HEALTHY
Prometheus:     HEALTHY
Application:    UP
cAdvisor:       UP
Metrics:        VERIFIED
Non-root:       VERIFIED
Security:       VERIFIED
README:         NOW READY
