
        Host / Client


Failure simulation:

Redis PID 1 failure
        |
        v
Docker detects process exit
        |
        v
restart: unless-stopped
        |
        v
Same container recovers
        |
        v
Redis healthcheck passes
        |
        v
API health recovers
        |
        v
Application request succeeds
Project Structure
project-23-compose-resilience/
├── .dockerignore
├── .env.example
├── .gitignore
├── Dockerfile
├── README.md
├── compose.yml
├── pytest.ini
├── requirements.txt
├── app/
│   └── app.py
├── tests/
│   ├── testapi.py
│   └── testcompose.py
└── verify-resilience.sh
Services
API

Technology:

Python 3.12
Flask
Gunicorn

Responsibilities:

Application API
Redis connectivity
Health reporting
Readiness reporting
Cache validation

Host port:

8123

Container port:

5000
Redis

Technology:

redis:7.4-alpine

Responsibilities:

Application cache
Health dependency
Persistence configuration

Redis has no host port published and is accessible only through the Compose network.

Resilience Configuration
Restart policy

Both services use:

restart: unless-stopped

This allows Docker to restart services after unexpected process failures.

Init process
init: true

This provides proper PID 1 behavior and signal/reaping support.

Graceful termination

API:

stop_signal: SIGTERM
stop_grace_period: 20s

Redis:

stop_signal: SIGTERM
stop_grace_period: 15s
API health check

The API health endpoint verifies Redis connectivity.

GET /health

A healthy response indicates both the API and Redis dependency are operational.

Dependency health

The API waits for Redis:

depends_on:
  redis:
    condition: service_healthy
    restart: true
Security

The containers run as a dedicated non-root user where applicable.

The API Docker image creates:

appgroup
appuser

The containers also use:

security_opt:
  - no-new-privileges:true

Redis does not expose port 6379 to the host.

The local .env file is ignored by Git.

Application Endpoints
Root
GET /

Returns service status.

Health
GET /health

Checks API and Redis health.

Example:

{
  "redis": "healthy",
  "status": "healthy"
}
Readiness
GET /ready

Confirms that the service can accept traffic.

Cache
GET /cache

Writes and reads a Redis value to validate application-to-Redis functionality.

Local Setup

Create the local environment file:

cp .env.example .env

The default API port is:

8123
Python Tests

The project uses pytest.

Run:

python3 -m pytest -v

The test suite validates:

API behavior
health behavior
readiness behavior
Compose service definitions
restart policy
init configuration
graceful shutdown
health checks
security configuration
Redis port isolation
healthy dependency ordering
Compose Validation

Run:

docker compose config -q

A successful command produces no error.

Build
docker compose build
Start
docker compose up -d

Check:

docker compose ps
Health Verification
curl -fsS http://127.0.0.1:8123/health

Test Redis:

docker exec project23-redis redis-cli ping

Expected:

PONG

Test cache:

curl -fsS http://127.0.0.1:8123/cache
Resilience Test

The automated verification script:

./verify-resilience.sh

performs:

Compose build
Stack startup
API health verification
Redis health verification
Controlled Redis PID 1 failure
Docker restart-policy recovery
Redis health recovery
Container identity verification
API recovery verification
Application functionality verification
Cleanup

The failure is intentionally injected into the Redis process rather than manually stopping the container.

This tests an unexpected application/process failure.

Successful output ends with:

Project 23 resilience verification PASSED.
Verified Local Results

Project 23 was validated locally with:

pytest: 9 passed
Compose configuration: valid
Docker image build: successful
API health: healthy
Redis health: healthy
Redis process failure: recovered
Redis container identity: preserved
API recovery: successful
Cache operation: successful
Resilience verification: PASSED
GitHub Actions

Workflow:

.github/workflows/project-23-compose-resilience.yml

The CI pipeline performs:

Checkout
   |
Python 3.12
   |
Install dependencies
   |
pytest
   |
Compose config validation
   |
Docker build
   |
Compose resilience verification
   |
Failure diagnostics
   |
Cleanup

The workflow uses:

permissions:
  contents: read

and creates .env from .env.example inside CI rather than storing secrets in Git.

Troubleshooting
Port 8123 already in use

Check:

ss -lntp | grep 8123

Change the local value:

APP_PORT=8124

Then start Compose again.

Redis is unhealthy

Check:

docker compose ps
docker compose logs redis

Test:

docker exec project23-redis redis-cli ping
API is unhealthy

Check:

docker compose logs api

Then:

curl -i http://127.0.0.1:8123/health
Compose resource conflict

Check:

docker compose ps -a

For Project 23 resources only:

docker compose down --remove-orphans

Then restart:

docker compose up -d
Enterprise Use Cases

This pattern is applicable to:

Stateless API services
Internal microservices
Redis-backed applications
Development platforms
CI test environments
Self-hosted application stacks
Edge services
Small production workloads
Service recovery validation

The key production principle is:

A container should be designed to recover predictably from unexpected process failure without requiring manual intervention.

DevOps Interview Questions
1. What does restart: unless-stopped do?

It instructs Docker to restart a container when it exits unexpectedly, unless the container has been explicitly stopped.

2. Why use init: true?

It provides an init process inside the container that helps handle orphaned processes and PID 1 responsibilities correctly.

3. Why use SIGTERM?

SIGTERM gives the application an opportunity to shut down gracefully before Docker forcibly terminates it.

4. Why configure stop_grace_period?

Applications such as web servers may need time to finish active requests and close resources cleanly.

5. Why should Redis not expose port 6379 to the host?

The API only needs internal network access. Removing host exposure reduces the attack surface.

6. Why is a health check different from a process check?

A running process does not necessarily mean the application is functional. A health check validates application-level availability.

7. Why use depends_on: condition: service_healthy?

It prevents the dependent API from starting before Redis has passed its health check.

8. Why test process failure instead of manually stopping the container?

A process crash represents an unexpected application failure. Manually stopping a container represents an intentional administrative action.

9. What happens when PID 1 crashes?

The container exits. Docker can then apply the configured restart policy.

10. How did this project prove recovery?

It killed Redis's PID 1, waited for Redis to return to running/healthy, verified the same container identity, then verified API health and cache functionality.

11. Why run the application as a non-root user?

It limits the potential impact of a container compromise.

12. Why use no-new-privileges?

It prevents processes from gaining additional Linux privileges through privilege-escalation mechanisms.

13. What is the difference between liveness and readiness?

Liveness determines whether a process should remain running. Readiness determines whether the service is prepared to receive traffic.

14. What would you use in Kubernetes instead of Compose restart policies?

Kubernetes Deployments, ReplicaSets, liveness probes, readiness probes, and pod restart behavior provide the equivalent production orchestration mechanisms.

15. Why is resilience testing important in CI?

Configuration can appear correct while recovery behavior is broken. CI turns resilience from an assumption into a continuously verified property.

Resume Achievement

Designed and automated an enterprise Docker Compose resilience platform implementing restart policies, graceful shutdown, health-aware dependencies, process-failure recovery, security hardening, and automated resilience testing through GitHub Actions.

Short version

Implemented Docker Compose self-recovery with health checks, graceful shutdown, Redis dependency management, security hardening, and automated CI resilience validation.

LinkedIn

🚀 Project 23 — Enterprise Docker Compose Resilience

Built a production-style Docker Compose resilience architecture capable of automatically recovering from unexpected Redis process failures while restoring API health and application functionality.

Key areas:

Docker restart policies
Graceful shutdown
Health checks
Dependency health ordering
Redis isolation
Non-root containers
Security hardening
Automated failure injection
GitHub Actions CI/CD

Validation: 9/9 tests passed + resilience recovery verified successfully.

Project 23 Completion Criteria
[✓] Dedicated branch
[✓] Enterprise architecture
[✓] Health checks
[✓] Restart policy
[✓] Graceful shutdown
[✓] Security hardening
[✓] Redis network isolation
[✓] Automated failure injection
[✓] Automatic recovery
[✓] API recovery
[✓] Application functionality
[✓] Pytest
[✓] Docker build
[✓] Compose validation
[✓] GitHub Actions workflow
[✓] README
[ ] Git commit
[ ] GitHub Actions GREEN
[ ] Clean git status

EOF

echo "===== README CREATED ====="
wc -l project-23-compose-resilience/README.md

echo
echo "===== DIFF CHECK ====="
git diff --check
