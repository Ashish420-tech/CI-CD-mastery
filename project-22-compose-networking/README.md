# Project 22 — Enterprise Docker Compose Networking

## Overview

Project 22 demonstrates enterprise-grade Docker Compose networking using isolated custom bridge networks, Docker Compose DNS-based service discovery, health-aware startup dependencies, and explicit network security boundaries.

The application consists of:

- Flask API
- Redis backend
- Custom frontend network
- Internal backend network
- Docker Compose health checks
- Service-to-service DNS discovery
- Automated network isolation verification
- GitHub Actions CI validation

## Architecture

```text
                         HOST
                           |
                    localhost:8110
                           |
                           v
                  +----------------+
                  |   Flask API     |
                  | project22-api   |
                  +--------+-------+
                           |
                +----------+----------+
                |                     |
                v                     v
       +----------------+    +----------------------+
       | frontend_net   |    | backend_net          |
       | bridge         |    | bridge + internal    |
       +----------------+    +----------+-----------+
                                      |
                                      v
                              +---------------+
                              | Redis         |
                              | project22-redis|
                              | :6379         |
                              +---------------+
Network Design
frontend_net

The externally reachable application network.

frontend_net:
  driver: bridge

The API is connected to this network.

backend_net

The protected service network.

backend_net:
  driver: bridge
  internal: true

Both API and Redis are connected to this network.

Redis is intentionally excluded from frontend_net.

Connectivity Model
Host
 |
 | TCP :8110
 v
API
 |
 | Docker DNS: redis
 | TCP :6379
 v
Redis

The intended access matrix is:

Source	Destination	Result
Host	API:8110	Allowed
API	Redis:6379	Allowed
API	Redis using redis DNS	Allowed
Host	Redis:6379	Blocked
Frontend-only container	Redis	Blocked
Frontend-only container	Redis DNS	Blocked
Service Discovery

The API does not use:

localhost
127.0.0.1
host networking
hard-coded Redis IP addresses

Instead it uses:

redis

Docker Compose provides DNS-based service discovery for containers attached to the same network.

The API connects to:

redis:6379
Redis Exposure

Redis has no ports: configuration.

Therefore Redis is not published to the host.

The Compose configuration exposes only:

8110:5000

for the API.

Health Checks

Redis uses:

redis-cli ping

The API uses:

GET /health

Compose startup ordering uses:

depends_on:
  redis:
    condition: service_healthy

This prevents the API from being started before Redis has passed its health check.

API Endpoints
Root
GET /

Example:

{
  "service": "project-22-compose-networking-api",
  "status": "running"
}
Health
GET /health

Example:

{
  "redis": "healthy",
  "status": "healthy"
}
Network verification
GET /api/network

This endpoint performs an actual Redis operation and proves Docker DNS and service-to-service connectivity.

Example:

{
  "api": "reachable",
  "networking": "service-discovery-success",
  "redis": "reachable",
  "redis_hostname": "redis",
  "redis_value": "compose-dns-ok"
}
Security Controls

The project implements the following controls:

Redis has no published host port.
Redis is isolated on the internal backend network.
API is the only externally exposed service.
Frontend and backend network boundaries are explicit.
Backend network uses internal: true.
Containers use no-new-privileges.
Flask runs behind Gunicorn.
API container runs as a non-root user.
Redis connection timeouts are configured.
Environment configuration is separated from source code.
.env is excluded from Git.
Generated Python cache files are excluded from Git.
Network Isolation Verification

The project includes:

verify-networking.sh

The script validates:

Compose configuration
container existence
API health
Redis health
API network membership
Redis network membership
network segmentation
backend network internal flag
Redis host-port exposure
API → Redis communication
Docker DNS service discovery
frontend-only isolation
Isolation Test

A temporary Alpine container is connected only to:

project22_frontend_net

It attempts to resolve:

redis

and connect to:

redis:6379

The expected result is failure.

This demonstrates that network membership controls service reachability.

Local Setup

Clone the repository and enter the project:

cd ~/CI-CD-mastery/project-22-compose-networking

Create local environment configuration:

cp .env.example .env

The default host port is:

8110
Run Tests

Install dependencies:

pip install -r requirements.txt

Run:

pytest -q
Build
docker compose build
Start
docker compose up -d

Check:

docker compose ps
Test API
curl http://127.0.0.1:8110/

Health:

curl http://127.0.0.1:8110/health

Network:

curl http://127.0.0.1:8110/api/network
Inspect Networks
docker network inspect project22_frontend_net
docker network inspect project22_backend_net

Check the internal flag:

docker network inspect project22_backend_net \
  --format='Internal={{.Internal}}'

Expected:

Internal=true
Verify Redis Is Not Exposed
docker port project22-redis

Expected:

No host port should be returned.

Run Complete Networking Verification
./verify-networking.sh

Expected:

ALL NETWORK VERIFICATIONS PASSED
Stop the Environment
docker compose down

Remove volumes:

docker compose down -v
CI/CD

GitHub Actions workflow:

.github/workflows/project-22-compose-networking.yml

The workflow validates:

Python
pytest
Compose
docker compose config
Container build
docker compose build
Deployment
docker compose up -d
Health

Both API and Redis must become healthy.

Networking

The CI environment executes:

verify-networking.sh

Therefore CI verifies the architecture itself rather than only testing application code.

Enterprise Use Cases

This networking model is useful for:

Microservice platforms
Internal APIs
Redis-backed applications
Database-backed APIs
Frontend/backend separation
Multi-tier container applications
Development environments that model production network boundaries
Security-conscious Compose deployments
CI integration testing
Local service-discovery testing
Production Design Principles Demonstrated
1. Least network access

Services join only the networks they require.

2. No unnecessary exposure

Internal services should not publish ports to the host.

3. DNS instead of IP addresses

Applications communicate through service names instead of container IP addresses.

4. Explicit trust boundaries

Separate networks provide a clear communication boundary.

5. Health-aware startup

Services should not assume that dependency startup means dependency readiness.

6. Automated architecture testing

Network security assumptions should be validated automatically in CI.

Troubleshooting
Port already allocated

Check:

docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Ports}}'

Check host sockets:

sudo ss -ltnp

Choose an unused host port in .env.

API unhealthy

Inspect:

docker inspect project22-api \
  --format='{{json .State.Health}}'

Check logs:

docker compose logs api
Redis unhealthy

Check:

docker inspect project22-redis \
  --format='{{json .State.Health}}'

Logs:

docker compose logs redis
API cannot reach Redis

Verify:

docker network inspect project22_backend_net

Both API and Redis must appear on the backend network.

Check DNS from the API:

docker exec project22-api getent hosts redis
Redis is unexpectedly exposed

Run:

docker port project22-redis

Redis should have no host mapping.

Project Outcomes

Project 22 demonstrates enterprise Docker networking through:

Custom bridge networks
Network segmentation
Internal networks
Compose DNS
Service aliases
Health checks
Health-aware dependencies
Non-root containers
Redis isolation
Automated network security verification
CI/CD architecture validation
Project Status

Project 22 — Enterprise Docker Compose Networking

Status:

Implementation: Complete
Local Networking: Verified
Network Isolation: Verified
Health Checks: Verified
Redis Exposure: Blocked
Compose DNS: Verified
CI Validation: Configured

EOF
# Project 22 — Enterprise Docker Compose Networking

## Overview

Project 22 demonstrates enterprise-grade Docker Compose networking using isolated custom bridge networks, Docker Compose DNS-based service discovery, health-aware startup dependencies, and explicit network security boundaries.

The application consists of:

- Flask API
- Redis backend
- Custom frontend network
- Internal backend network
- Docker Compose health checks
- Service-to-service DNS discovery
- Network aliases
- Automated network isolation verification
- GitHub Actions CI validation

---

## Project Objective

Build a production-style Docker Compose environment where:

1. The API is externally accessible.
2. Redis is accessible only from the backend network.
3. Redis is never exposed directly to the host.
4. Docker Compose DNS provides service discovery.
5. Frontend and backend traffic are separated.
6. Backend networking uses an internal Docker network.
7. Services use health checks.
8. API startup waits for healthy Redis.
9. Network isolation is automatically tested.
10. GitHub Actions validates the complete architecture.

---

# Architecture

```text
                         HOST
                           |
                     localhost:8110
                           |
                           v
                  +------------------+
                  |    Flask API     |
                  |  project22-api   |
                  |      :5000       |
                  +--------+---------+
                           |
             +-------------+-------------+
             |                           |
             v                           v
      +---------------+          +----------------------+
      | frontend_net  |          | backend_net          |
      | bridge        |          | bridge               |
      |               |          | internal: true      |
      +---------------+          +----------+-----------+
                                            |
                                            v
                                   +----------------+
                                   |     Redis      |
                                   | project22-redis|
                                   |     :6379      |
                                   +----------------+
Network Architecture
Frontend Network
frontend_net:
  driver: bridge

The Flask API is connected to this network.

This network represents the application-facing network.

Backend Network
backend_net:
  driver: bridge
  internal: true

Both the API and Redis are connected to the backend network.

Redis is intentionally not connected to the frontend network.

The internal: true setting provides an additional network boundary for backend services.

Connectivity Model
Host
 |
 | TCP :8110
 v
Flask API
 |
 | Docker DNS
 | redis:6379
 v
Redis

Expected access:

Source	Destination	Result
Host	API:8110	Allowed
API	Redis:6379	Allowed
API	Redis using redis DNS	Allowed
Host	Redis:6379	Blocked
Frontend-only container	Redis	Blocked
Frontend-only container	Redis DNS	Blocked
Service Discovery

The API does not use:

localhost
127.0.0.1
host.docker.internal

for Redis communication.

Instead, it uses the Compose service name:

redis

The API connects to:

redis:6379

Docker Compose provides embedded DNS-based service discovery between containers attached to the same network.

This means container IP addresses do not need to be hard-coded.

Redis Security

Redis has intentionally no ports: configuration.

There is no:

ports:
  - "6379:6379"

Therefore Redis is not directly exposed to the host.

Only the API communicates with Redis over:

backend_net

This follows the principle:

Internal services should not be exposed unless external access is actually required.

Network Aliases

The Compose configuration provides aliases such as:

aliases:
  - redis
  - project22-redis

for Redis.

The API similarly has aliases:

aliases:
  - api
  - project22-api

This demonstrates controlled service discovery within Docker networks.

Health Checks

Both services implement health checks.

Redis

Redis uses:

redis-cli ping

Example:

healthcheck:
  test:
    [
      "CMD",
      "redis-cli",
      "ping"
    ]
API

The API health check calls:

/health

The endpoint verifies Redis connectivity.

Example response:

{
  "redis": "healthy",
  "status": "healthy"
}
Health-Aware Startup

The API depends on Redis being healthy:

depends_on:
  redis:
    condition: service_healthy

This is stronger than simple startup ordering.

The API does not simply wait for the Redis container to start.

It waits for Redis to pass its health check.

Application

The Flask API exposes three endpoints.

1. Root
GET /

Example:

{
  "service": "project-22-compose-networking-api",
  "status": "running"
}
2. Health
GET /health

Example:

{
  "redis": "healthy",
  "status": "healthy"
}

This endpoint verifies application and Redis health.

3. Network Verification
GET /api/network

This endpoint performs an actual Redis operation.

Example:

{
  "api": "reachable",
  "networking": "service-discovery-success",
  "redis": "reachable",
  "redis_hostname": "redis",
  "redis_value": "compose-dns-ok"
}

This proves:

Flask API
    |
    | DNS: redis
    |
    v
Redis
Container Security

The API container uses a non-root user.

The Dockerfile creates:

appgroup
appuser

and runs the application as:

USER appuser

The container also uses:

security_opt:
  - no-new-privileges:true

This reduces unnecessary container privileges.

Dockerfile

The application uses:

python:3.12-slim

The image:

Uses a slim base image
Installs only required Python dependencies
Runs as non-root
Uses Gunicorn
Disables Python bytecode generation
Uses unbuffered Python output
Uses no-new-privileges
Environment Configuration

The project uses:

.env

for local configuration.

The repository tracks:

.env.example

but intentionally ignores:

.env

This prevents environment-specific configuration or secrets from accidentally being committed.

Example:

APP_PORT=8110
PORT=5000
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_TIMEOUT=2
Project Structure
project-22-compose-networking/
│
├── .dockerignore
├── .env.example
├── .gitignore
├── Dockerfile
├── README.md
├── compose.yml
├── pytest.ini
├── requirements.txt
├── verify-networking.sh
│
├── app/
│   ├── __init__.py
│   └── app.py
│
└── tests/
    └── test_app.py

GitHub Actions workflow:

.github/
└── workflows/
    └── project-22-compose-networking.yml
Requirements

Main Python dependencies:

Flask
redis
gunicorn
pytest

Python version:

3.12
Local Setup

Navigate to the project:

cd ~/CI-CD-mastery/project-22-compose-networking

Create local environment configuration:

cp .env.example .env
Run Python Tests

Install dependencies:

pip install -r requirements.txt

Run tests:

pytest -q

Expected:

3 passed
Build Docker Image
docker compose build
Start the Environment
docker compose up -d

Check services:

docker compose ps

Expected services:

project22-api
project22-redis

Both should eventually become:

healthy
Test the API
Root Endpoint
curl http://127.0.0.1:8110/
Health Endpoint
curl http://127.0.0.1:8110/health

Expected:

{
  "redis": "healthy",
  "status": "healthy"
}
Network Endpoint
curl http://127.0.0.1:8110/api/network

Expected:

{
  "api": "reachable",
  "networking": "service-discovery-success",
  "redis": "reachable",
  "redis_hostname": "redis",
  "redis_value": "compose-dns-ok"
}
Docker Network Inspection

List Project 22 networks:

docker network ls | grep project22

Expected:

project22_frontend_net
project22_backend_net
Inspect Frontend Network
docker network inspect project22_frontend_net

Expected:

project22-api

Redis should not appear on this network.

Inspect Backend Network
docker network inspect project22_backend_net

Expected:

project22-api
project22-redis
Verify Internal Network

Run:

docker network inspect project22_backend_net \
  --format='Internal={{.Internal}}'

Expected:

Internal=true
Verify Redis Has No Host Port

Run:

docker port project22-redis

Expected:

No host port should be returned.

The API is the only externally exposed application service:

8110:5000
Verify API Network Membership
docker inspect project22-api \
  --format='{{range $name, $network := .NetworkSettings.Networks}}{{println $name "->" $network.IPAddress}}{{end}}'

Expected:

project22_backend_net
project22_frontend_net
Verify Redis Network Membership
docker inspect project22-redis \
  --format='{{range $name, $network := .NetworkSettings.Networks}}{{println $name "->" $network.IPAddress}}{{end}}'

Expected:

project22_backend_net

Redis should not appear on frontend_net.

Network Isolation Test

Project 22 includes:

verify-networking.sh

Run:

./verify-networking.sh

The script verifies:

Compose configuration
Required containers
Container health
Network membership
Backend network isolation
internal: true
Redis host-port exposure
API → Redis communication
Compose DNS service discovery
Frontend-only network isolation
Frontend-Only Isolation

The verification script creates a temporary container:

project22-network-isolation-test

It is attached only to:

project22_frontend_net

It then attempts to resolve:

redis

and connect to:

redis:6379

Expected result:

PASS: Frontend-only container cannot resolve Redis
PASS: Frontend-only container cannot reach Redis

This proves the network boundary is working.

Complete Verification

The final verification should produce:

1. Compose configuration
   PASS

2. Required containers
   PASS

3. Container health
   PASS

4. Network membership
   PASS

5. Backend network must be internal
   PASS

6. Redis must not publish host ports
   PASS

7. API -> Redis through Compose DNS
   PASS

8. Frontend-only isolation test
   PASS

Final result:

ALL NETWORK VERIFICATIONS PASSED
GitHub Actions

Workflow:

.github/workflows/project-22-compose-networking.yml

The CI pipeline contains three validation jobs.

Job 1 — Python Tests

GitHub Actions:

Python 3.12
      |
      v
pip install
      |
      v
pytest
Job 2 — Compose Validation

CI creates .env from the tracked template:

cp .env.example .env

Then validates:

docker compose config

The real .env file is not committed.

Job 3 — Docker Networking Validation

The workflow:

Checkout
   |
   v
Prepare environment
   |
   v
Docker Compose build
   |
   v
docker compose up -d
   |
   v
Wait for health
   |
   v
verify-networking.sh
   |
   v
Cleanup

The networking validation checks the actual Docker environment.

CI Security

GitHub Actions uses:

permissions:
  contents: read

No AWS credentials or registry credentials are required.

No secrets are required for this project.

The workflow generates .env from .env.example during CI.

CI Result

Project 22 GitHub Actions successfully validated:

Python Tests
    PASS

Compose Validation
    PASS

Docker Networking Validation
    PASS

The Docker networking job verified:

Docker image build
Compose deployment
Service health
Network membership
Internal backend network
Redis isolation
Compose DNS
API → Redis connectivity
Frontend network isolation
Cleanup
Troubleshooting
Port Already Allocated

If the API cannot start because the port is already allocated:

docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Ports}}'

Check host sockets:

sudo ss -ltnp

For Project 22, the verified host port is:

8110

The container port remains:

5000
API Unhealthy

Inspect:

docker inspect project22-api \
  --format='{{json .State.Health}}'

Check logs:

docker compose logs api
Redis Unhealthy

Inspect:

docker inspect project22-redis \
  --format='{{json .State.Health}}'

Check logs:

docker compose logs redis
API Cannot Reach Redis

Check backend network:

docker network inspect project22_backend_net

Both services should be present.

Check DNS from the API:

docker exec project22-api getent hosts redis

Expected:

redis <container-ip>
Redis Unexpectedly Exposed

Run:

docker port project22-redis

Redis should have no host mapping.

If Redis has a published port, inspect compose.yml and remove the ports: configuration.

Enterprise Use Cases

This architecture can be applied to:

Microservice applications
Internal APIs
Redis-backed services
Database-backed applications
Frontend/backend architectures
Multi-tier container platforms
Secure development environments
Integration testing
CI/CD environments
Internal enterprise services
Service-oriented applications
Enterprise Design Principles Demonstrated
1. Least Privilege

Containers are attached only to the networks they require.

2. Network Segmentation

Frontend and backend communication paths are separated.

3. Internal Services

Redis is treated as an internal dependency instead of an externally accessible service.

4. Service Discovery

Services communicate through stable DNS names instead of container IP addresses.

5. Health-Aware Dependencies

The API waits for Redis to become healthy.

6. Defense in Depth

Multiple controls protect Redis:

No published port
        +
Backend-only network
        +
Internal network
        +
Frontend isolation
7. Automated Architecture Testing

Network security assumptions are tested automatically rather than relying on manual inspection.

Interview Questions and Answers
Q1. Why did you create two Docker networks?

To separate application-facing traffic from backend service traffic.

The API needs access to both networks, while Redis only needs the backend network.

This prevents services that only require frontend access from directly reaching Redis.

Q2. How does Docker Compose DNS work?

Docker Compose provides an embedded DNS mechanism for containers on the same Docker network.

The Compose service name becomes a DNS name.

For example:

redis

resolves to the Redis container's IP address.

Q3. Why shouldn't applications use container IP addresses?

Container IP addresses can change when containers are recreated.

Service names provide stable service discovery independent of the underlying container IP.

Q4. What does internal: true do?

It creates a Docker network that is isolated from external connectivity through the Docker host.

It is useful for backend-only communication paths.

Q5. Why isn't Redis exposed with 6379:6379?

Redis is an internal backend service.

Publishing port 6379 would unnecessarily expose it to the host.

The API can reach Redis directly through the Docker network without host port publishing.

Q6. What is the difference between EXPOSE and ports?

EXPOSE documents a container port.

ports actually publishes a container port to the host.

Project 22 uses host publishing only for the API.

Q7. Why use depends_on.condition: service_healthy?

Basic container startup ordering does not guarantee that the dependency is ready.

Using:

condition: service_healthy

makes Compose wait for the Redis health check.

Q8. How did you verify isolation?

A temporary Alpine container was attached only to frontend_net.

It attempted to resolve and connect to Redis.

Both operations failed as expected.

This demonstrated that network membership controls access.

Q9. How does the API prove Redis connectivity?

The /api/network endpoint performs a Redis SET and GET operation.

It also confirms that Redis was reached through the hostname:

redis
Q10. Why is automated network testing important?

A network architecture can appear correct in a Compose file while behaving differently at runtime.

The verification script tests the actual running Docker environment.

This makes network security an enforceable CI requirement.

Q11. What happens if Redis is removed from the backend network?

The API would no longer be able to resolve or connect to Redis through the backend network.

The /health endpoint would fail because Redis connectivity is required.

Q12. Why run the Flask container as a non-root user?

Running applications as non-root reduces the impact of container compromise.

It follows the principle of least privilege.

Q13. Why use Gunicorn instead of Flask's development server?

Flask's built-in server is intended primarily for development.

Gunicorn provides a production-oriented WSGI application server.

Q14. Why use health checks instead of simply checking container status?

A container can be running while the application inside it is unavailable.

Health checks validate actual service readiness.

Q15. How would this architecture evolve for Kubernetes?

The same principles map naturally to Kubernetes:

Docker Compose network
        ↓
Kubernetes NetworkPolicy

and:

Compose service DNS
        ↓
Kubernetes Service DNS

The security concept remains network segmentation and least-privilege communication.

Resume Achievement

Engineered an enterprise Docker Compose networking architecture with isolated frontend/backend bridge networks, internal network controls, DNS-based service discovery, Redis isolation, health-aware dependencies, and automated CI network-security validation.

LinkedIn Achievement

Built Project 22 of my CI/CD Mastery series: an enterprise Docker Compose networking architecture implementing custom bridge networks, frontend/backend segmentation, internal backend isolation, Compose DNS service discovery, Redis protection, health checks, and automated GitHub Actions network-security validation.

Project Completion Checklist
[✓] Flask API
[✓] Redis backend
[✓] Dockerfile
[✓] requirements.txt
[✓] Docker Compose
[✓] Custom bridge networks
[✓] Frontend/backend separation
[✓] Internal backend network
[✓] Compose DNS
[✓] Network aliases
[✓] API → Redis communication
[✓] Redis not exposed to host
[✓] Health checks
[✓] depends_on health condition
[✓] Environment configuration
[✓] Non-root container
[✓] Security controls
[✓] Unit tests
[✓] Network verification script
[✓] Network isolation verification
[✓] GitHub Actions
[✓] CI validation
[✓] Git tracked files
[✓] Local validation
[✓] Git commit
[✓] Git push
[✓] GitHub Actions GREEN
[✓] Clean working tree
Project Status
Project 22 — Enterprise Docker Compose Networking
Implementation       : COMPLETE
Local Tests          : PASS
Docker Build         : PASS
Compose Deployment   : PASS
API Health           : PASS
Redis Health         : PASS
Compose DNS          : PASS
API → Redis          : PASS
Network Segmentation : PASS
Redis Exposure       : BLOCKED
Network Isolation    : PASS
CI Validation        : PASS
GitHub Actions       : GREEN

Project 22 COMPLETE.
