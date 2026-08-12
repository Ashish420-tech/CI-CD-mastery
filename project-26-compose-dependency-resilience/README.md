# Project 26 — Enterprise Docker Compose Dependency Resilience

Production-focused Docker Compose implementation demonstrating reliable service dependency readiness.

## Objective

Ensure an application does not serve traffic until its critical dependency is healthy and ready.

## Architecture

```text
Client
  |
  v
Application :5001
  |
  | Docker Compose network
  v
Dependency :5000
  |
  v
Healthcheck / readiness

The application uses both Compose dependency conditions and application-level retry logic.

Key Capabilities
depends_on with condition: service_healthy
Dependency healthchecks
Application healthchecks
Application-level retry logic
Controlled startup sequencing
Gunicorn production-style execution
Python 3.12
Non-root UID 10001
no-new-privileges
Restart policy
Graceful Gunicorn shutdown
Automated pytest validation
Docker Compose validation
GitHub Actions CI
Validation

The project verifies:

Dependency becomes healthy before application startup
Application health endpoint becomes healthy
Application waits for dependency readiness
Application functionality works after dependency readiness
Compose configuration is valid
Healthchecks are configured
Retry logic exists
Containers run as non-root
no-new-privileges is enabled
Run
docker compose build
docker compose up -d
docker compose ps
curl http://localhost:5001/health
curl http://localhost:5001/
docker compose down -v
Reliability Design

Compose prevents the application from starting before the dependency passes its healthcheck.

The application additionally implements retry logic so readiness is enforced at the application layer rather than relying exclusively on container orchestration behavior.

Security
Non-root execution
Fixed UID 10001
no-new-privileges
Minimal Python slim base image
No host dependency exposure for the internal dependency
Only application port exposed to the host
CI

GitHub Actions performs:

Python test setup
pytest
Compose configuration validation
Docker image build
Stack startup
Health validation
Functional API validation
Dependency readiness validation
Cleanup
Project

Project 26 of CI/CD Mastery

Focus: Enterprise Docker Compose dependency resilience.
EOF

============================================================
GENERATED FILE SAFETY
============================================================

echo "===== CLEAN GENERATED FILES ====="
rm -rf .pytest_cache app/pycache dependency/pycache tests/pycache

echo "===== GIT STATUS ====="
cd ~/CI-CD-mastery
git status --short --untracked-files=all

echo "===== FORBIDDEN FILE AUDIT ====="
if git status --short --untracked-files=all | grep -E '(.venv/|pycache/|.pytest_cache/|.pyc$|backup|.env$|secret|password|credential)' ; then
echo "ERROR: forbidden/generated files detected"
exit 1
fi

============================================================
STAGE
============================================================

git add project-26-compose-dependency-resilience
.github/workflows/project-26-compose-dependency-resilience.yml

echo "===== STAGED FILES ====="
git diff --cached --name-status

echo "===== STAGED SAFETY AUDIT ====="
git diff --cached --name-only | grep -E '(^|/)(.venv|pycache|.pytest_cache)(/|$)|.pyc$' && {
echo "ERROR: generated files staged"
exit 1
} || true

git diff --cached --name-only | grep -Ei '(^|/)(.env|.secret.|.password.|.credential.)$' && {
echo "ERROR: possible secret staged"
exit 1
} || true

============================================================
COMMIT + PUSH
============================================================

git commit -m "feat(project-26): add compose dependency resilience"

git push -u origin project-26-compose-dependency-resilience

echo "===== LOCAL FINAL STATE ====="
git status --short --branch

echo "===== COMMIT ====="
git log -1 --oneline

echo "===== CI RUN ====="
gh run list
--workflow=.github/workflows/project-26-compose-dependency-resilience.yml
--branch=project-26-compose-dependency-resilience
--limit=1



