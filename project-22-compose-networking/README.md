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
