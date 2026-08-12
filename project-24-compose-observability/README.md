# Project 24 — Enterprise Docker Compose Observability

Production-style Docker Compose observability using Flask application metrics and Prometheus.

## Objective

Build an observable Docker Compose application with:

- Flask application metrics
- `/metrics` Prometheus endpoint
- Prometheus scraping
- Application health checks
- Prometheus health checks
- Explicit Docker networking
- Automated tests
- Secure non-root container execution
- GitHub Actions CI validation

## Architecture

```text
                    ┌─────────────────────────┐
                    │      Prometheus         │
                    │        :9090            │
                    │                         │
                    │ scrape: api:5000/metrics│
                    └────────────┬────────────┘
                                 │
                         observability
                            network
                                 │
                    ┌────────────▼────────────┐
                    │       Flask API         │
                    │        :5000            │
                    │                         │
                    │ /                      │
                    │ /health                │
                    │ /metrics               │
                    └─────────────────────────┘
Components
Component	Purpose
Flask	Application service
Prometheus Client	Exposes application metrics
Prometheus	Metrics collection and querying
Docker Compose	Service orchestration
pytest	Automated application tests
GitHub Actions	Continuous integration
Application Endpoints
Root
GET /

Returns application status.

Health
GET /health

Returns:

{
  "status": "healthy"
}
Metrics
GET /metrics

Exposes Prometheus-compatible metrics including:

flask_http_requests_total
Prometheus Configuration

Prometheus scrapes:

http://api:5000/metrics

The API is addressed through the internal Docker Compose network rather than the host port.

Scrape interval:

5 seconds
Security

The API container:

Runs as non-root appuser
Uses no-new-privileges
Uses a minimal python:3.12-slim base image
Uses PYTHONDONTWRITEBYTECODE
Uses PYTHONUNBUFFERED
Does not require privileged execution
Reliability

The stack includes:

Container restart policies
Docker health checks
Compose depends_on with service_healthy
Graceful shutdown configuration
Docker init process
Prometheus health/readiness endpoints
Validation

Local validation covers:

4 pytest tests
Docker image build
Docker Compose configuration
API health
Application metrics
Prometheus health
Prometheus scrape target
Prometheus metric query
CI/CD

GitHub Actions validates:

Python dependencies
pytest suite
Docker Compose configuration
Docker image build
Compose startup
Container health
API health
Application metrics
Prometheus health
Prometheus scrape target
Prometheus metric query
Stack cleanup

Workflow:

.github/workflows/project-24-compose-observability.yml
Verification

Successful local verification:

4 passed
Compose validation: 0
API: healthy
Prometheus: healthy
flask-api target: UP
flask_http_requests_total: PRESENT
Project Status

Project 24 — COMPLETE

Enterprise Docker Compose observability successfully implemented and validated locally.
EOF

echo "===== PROJECT FILES ====="
find . -maxdepth 3 -type f
! -path './.venv/'
! -path './app/pycache/'
! -path './tests/pycache/'
! -path './.pytest_cache/'
| sort

echo
echo "===== GITIGNORE ====="
cat .gitignore

echo
echo "===== README CHECK ====="
wc -l README.md

echo
echo "===== GIT STATUS ====="
cd ~/CI-CD-mastery
git status --short


Then **send the output**.

After that, we'll do the final `git add → staged-file audit → commit → push → GitHub 
