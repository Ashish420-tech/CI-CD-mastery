# Project 27 — Enterprise Docker Compose Resource Governance

Production-focused Docker Compose resource governance.

## Objective

Control container resource consumption with explicit CPU and memory limits and reservations.

## Architecture

Client → Flask/Gunicorn application → Docker resource controls.

Configured governance:

- CPU limit: 0.50
- Memory limit: 256 MB
- Memory reservation: 64 MB
- Healthcheck
- Restart policy
- Non-root UID 10001
- no-new-privileges

## Validation

The project verifies:

- CPU limit
- Memory limit
- Memory reservation
- Compose configuration
- Container startup
- Application health
- Docker-inspect resource configuration
- Non-root execution
- no-new-privileges

## Run

    docker compose config
    docker compose build
    docker compose up -d
    curl http://localhost:5001/health
    docker compose down -v

## CI

GitHub Actions runs pytest, Compose validation, Docker build, runtime health checks, resource inspection, security checks and cleanup.
