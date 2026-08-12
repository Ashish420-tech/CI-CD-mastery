 🚀 Project 18 — Docker Compose Multi-Container Application

![Docker](https://img.shields.io/badge/Docker-Container-blue?logo=docker)
![Docker Compose](https://img.shields.io/badge/Docker%20Compose-Multi--Container-blue?logo=docker)
![Python](https://img.shields.io/badge/Python-3.12-blue?logo=python)
![Flask](https://img.shields.io/badge/Flask-Application-black?logo=flask)
![Redis](https://img.shields.io/badge/Redis-Database-red?logo=redis)
![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-CI-success?logo=githubactions)
![Status](https://img.shields.io/badge/Status-Completed-success)

> **CI/CD Mastery — Project 18**

---

## 📌 Project Overview

Project 18 introduces **Docker Compose** and moves from single-container workloads to a multi-container application.

The project consists of:

```text
Flask API
    |
    | Redis protocol
    v
Redis

Docker Compose manages:

Application container
Redis container
Networking
Service discovery
Healthchecks
Dependency ordering
Persistent Redis volume
Environment configuration
Multi-container lifecycle

The central principle is:

Docker Compose allows multiple related containers to be defined, networked, started, health-checked and managed as one application stack.

🎯 Objectives

This project demonstrates:

Docker Compose
Multi-container architecture
Compose services
Compose networking
Docker DNS/service discovery
depends_on
Healthcheck conditions
Redis connectivity
Persistent volumes
Environment variables
Container health
Compose logs
CI/CD validation
Automated cleanup
🏢 Enterprise Problem

Running containers individually becomes difficult as application architecture grows.

For example:

docker run API
docker run Redis
docker run Database
docker run Worker
docker run Queue

Managing networking, configuration and startup order manually becomes increasingly difficult.

Docker Compose provides a declarative approach:

compose.yml
     |
     +── API
     |
     +── Redis
     |
     +── Network
     |
     +── Volume
     |
     +── Healthchecks

The complete stack can then be managed using:

docker compose up
docker compose down
🏗️ Architecture
                       Docker Compose
                              |
                 +------------+------------+
                 |                         |
                 v                         v
          Flask API Container       Redis Container
          project-18-api            project-18-redis
                 |                         |
                 |       redis:6379        |
                 +-------------------------+
                              |
                       Compose Network
                              |
                              v
                         Redis Service

External request flow:

Browser / curl
      |
      v
localhost:8096
      |
      v
Flask API
      |
      | redis:6379
      v
Redis
📁 Project Structure
project-18-compose-multi-container/
│
├── .dockerignore
├── Dockerfile
├── README.md
├── app.py
├── compose.yml
├── requirements.txt
└── test_app.py

GitHub Actions:

.github/
└── workflows/
    └── project-18-compose-multi-container.yml
🐍 Flask Application

The application exposes three endpoints:

GET /
GET /health
GET /counter
/ Endpoint

Returns application information.

Example:

curl -fsS http://localhost:8096/

Response:

{
  "environment": "development",
  "project": "project-18-compose-multi-container",
  "version": "1.0.0"
}
❤️ /health Endpoint

The health endpoint verifies both:

Flask application
       +
Redis connectivity

Example:

curl -fsS http://localhost:8096/health

Expected:

{
  "redis": "healthy",
  "status": "healthy"
}

The application connects to Redis using:

REDIS_HOST=redis
REDIS_PORT=6379
🔢 /counter Endpoint

The counter endpoint demonstrates real communication between the Flask API and Redis.

curl -fsS http://localhost:8096/counter

Example:

{
  "counter": 1
}

Another request:

curl -fsS http://localhost:8096/counter

returns:

{
  "counter": 2
}

This proves that the API is communicating with the Redis service.

🐳 Docker Compose

The application stack is defined in:

compose.yml

The Compose file defines two services:

api
redis
API Service

The API service:

Builds from the local Dockerfile
Creates the application image
Exposes port 8096
Connects to Redis
Has a healthcheck
Depends on Redis health

Configuration:

environment:
  APP_VERSION: "1.0.0"
  ENVIRONMENT: "development"
  REDIS_HOST: "redis"
  REDIS_PORT: "6379"
Redis Service

The Redis service uses:

redis:7-alpine

Redis listens on:

6379

A Redis healthcheck uses:

redis-cli ping

Expected:

PONG
🔗 Docker Compose Service Discovery

One of the most important concepts in Project 18 is service discovery.

The Flask application uses:

redis

as the Redis hostname.

It does not use:

localhost

The architecture is:

project-18-api
       |
       | DNS: redis
       |
       v
project-18-redis
       |
       v
     :6379

Docker Compose provides DNS resolution for service names on the Compose network.

Therefore:

redis

resolves to the Redis container.

❌ Incorrect Configuration

Inside the API container, this would be incorrect:

REDIS_HOST=localhost

because localhost refers to the API container itself.

It does not refer to the Redis container.

✅ Correct Configuration
REDIS_HOST=redis

because redis is the Compose service name.

🔄 depends_on

The API uses:

depends_on:
  redis:
    condition: service_healthy

This means Compose waits for Redis to satisfy its health condition before starting the API service according to the declared dependency.

This is stronger than simply declaring:

depends_on:
  - redis

because the health condition provides an explicit readiness requirement.

❤️ Healthchecks

Both services have healthchecks.

API

The API healthcheck calls:

/health

The endpoint verifies Redis connectivity.

Redis

Redis healthcheck:

redis-cli ping

Expected:

PONG

Architecture:

Redis
  |
  +── healthcheck
  |
  v
healthy
  |
  v
API dependency satisfied
  |
  v
API starts / remains healthy
💾 Persistent Volume

Redis uses:

volumes:
  - redis-data:/data

Compose creates the named volume:

redis-data

This demonstrates persistent storage separate from the Redis container filesystem.

The conceptual model is:

Redis Container
      |
      v
/data
      |
      v
redis-data volume
▶️ Start the Stack

From the project directory:

cd ~/CI-CD-mastery/project-18-compose-multi-container

Start the stack:

docker compose -f compose.yml up -d --build
🔍 Check Compose Services
docker compose -f compose.yml ps

Expected conceptually:

project-18-api
    Up
    healthy

project-18-redis
    Up
    healthy
⚙️ Validate Compose Configuration

Before starting the application:

docker compose -f compose.yml config

This validates and renders the Compose configuration.

It is useful in CI/CD because configuration errors can be detected before deployment.

📜 View Compose Logs

All services:

docker compose -f compose.yml logs

Only API:

docker compose -f compose.yml logs api

Only Redis:

docker compose -f compose.yml logs redis

Recent logs:

docker compose -f compose.yml logs --tail 20
🧪 Test the Application
API
curl -fsS http://localhost:8096/
Health
curl -fsS http://localhost:8096/health
Redis counter
curl -fsS http://localhost:8096/counter

Repeat the counter request:

curl -fsS http://localhost:8096/counter

The value should increment.

🔍 Inspect Container Health

API:

docker inspect project-18-api \
  --format 'status={{.State.Status}} health={{.State.Health.Status}}'

Redis:

docker inspect project-18-redis \
  --format 'status={{.State.Status}} health={{.State.Health.Status}}'

Expected:

status=running health=healthy

for both services.

🌐 Inspect Networking

Check the API network:

docker inspect project-18-api \
  --format '{{json .NetworkSettings.Networks}}'

The API and Redis containers are connected through the Compose-created network.

Conceptually:

                    Compose Network
                         |
              +----------+----------+
              |                     |
              v                     v
          API Container        Redis Container
              |                     |
              +------ redis --------+
🛑 Test Redis Dependency

Stop Redis:

docker compose -f compose.yml stop redis

Now test:

curl -s http://localhost:8096/health

The API should report Redis as unhealthy because its dependency is unavailable.

Restart Redis:

docker compose -f compose.yml start redis

Wait:

sleep 10

Then:

curl -fsS http://localhost:8096/health

The health endpoint should recover once Redis becomes available again.

🧪 Automated Tests

Run:

python3 -m pytest -q project-18-compose-multi-container

Project result:

3 passed

The tests validate:

GET /
GET /health
GET /counter

Redis is mocked during unit testing.

The actual API-to-Redis communication is validated through the Docker Compose integration test flow.

🔄 CI/CD Pipeline

The GitHub Actions workflow is:

.github/workflows/project-18-compose-multi-container.yml

The pipeline performs:

Checkout
   ↓
Python setup
   ↓
Install dependencies
   ↓
Run tests
   ↓
Validate Compose configuration
   ↓
Build Compose stack
   ↓
Start API + Redis
   ↓
Show services
   ↓
Wait for API health
   ↓
Verify Redis health
   ↓
Verify API health endpoint
   ↓
Verify Redis connectivity
   ↓
Verify counter
   ↓
Verify Compose network
   ↓
Show logs
   ↓
Cleanup
🔍 CI Validation

The CI pipeline validates the following:

Python tests
Docker Compose syntax
Docker image build
API container
Redis container
API health
Redis health
Redis connectivity
Counter functionality
Compose network
Container logs
Cleanup

This means the pipeline validates actual multi-container behavior rather than only building an image.

📊 Local Validation Results

Project 18 local validation:

Python tests                  ✅
Dockerfile                    ✅
Compose configuration         ✅
API container                 ✅
Redis container               ✅
API health                    ✅
Redis health                  ✅
API → Redis connectivity      ✅
Counter                       ✅
Compose networking            ✅
Persistent volume             ✅
Compose logs                  ✅
🚀 GitHub Actions Validation

Dedicated workflow:

Project 18 - Compose Multi Container

Successful run:

Run ID: 31579440805

Job:

compose

Result:

SUCCESS ✅
✅ CI Steps Passed
✓ Set up job
✓ Checkout
✓ Set up Python
✓ Install dependencies
✓ Run tests
✓ Validate Compose configuration
✓ Build and start Compose stack
✓ Show Compose services
✓ Wait for API health
✓ Verify Redis health
✓ Verify API health endpoint
✓ Verify Redis connectivity
✓ Verify counter
✓ Verify Compose network
✓ Show logs
✓ Cleanup
✓ Complete job
🎤 Interview Questions & Answers
1. What is Docker Compose?

Docker Compose is a tool for defining and managing multi-container applications using a declarative YAML configuration.

A Compose file can define:

Services
Networks
Volumes
Environment variables
Healthchecks
Dependencies
2. Why use Docker Compose?

It simplifies running multiple related containers.

Instead of manually running:

docker run api
docker run redis

we can define the entire application in:

compose.yml

and start it using:

docker compose up
3. How do containers communicate in Docker Compose?

Containers communicate through the Compose network.

Services can use service names as DNS names.

Example:

REDIS_HOST=redis

The API can then connect to:

redis:6379
4. Why can't the API use localhost for Redis?

Because localhost inside the API container refers to the API container itself.

Redis is running in a different container.

Therefore the API uses:

redis

as the hostname.

5. What does depends_on do?

It defines a dependency relationship between services.

Project 18 uses:

depends_on:
  redis:
    condition: service_healthy

This ensures the Redis health condition is satisfied before the API dependency is considered ready.

6. Is depends_on a complete application readiness mechanism?

No.

Applications should still implement proper retry and health behavior.

depends_on controls Compose startup ordering/conditions; it doesn't replace application-level resilience.

7. What is a Docker Compose network?

A network created/managed for the Compose application that allows services to communicate with each other.

Example:

api ──────── redis
8. How does service discovery work?

Compose provides DNS resolution for service names.

If the service is:

redis:

other services can use:

redis

as the hostname.

9. What is a named volume?

A named volume is persistent storage managed by Docker.

Project 18 uses:

redis-data

mounted into Redis:

/data
10. Why use a volume for Redis?

It demonstrates persistence outside the container's writable layer.

The container can be recreated while the named volume can retain its stored data, depending on how the stack is managed.

11. What happens when docker compose down -v is executed?

The Compose services are stopped and removed, and the associated named volumes defined for the Compose project are also removed.

Therefore:

docker compose down

and:

docker compose down -v

have an important difference.

12. What is the difference between docker compose stop and docker compose down?

stop stops containers but keeps the Compose resources.

down removes the containers and associated Compose-created resources such as networks.

Adding -v also removes declared volumes.

13. What is the difference between docker compose up and docker compose up -d?

Without -d, Compose runs attached to the terminal.

With:

docker compose up -d

containers run in detached/background mode.

14. How do you rebuild Compose services?
docker compose up -d --build

This rebuilds images where required before starting the services.

15. How do you inspect Compose logs?
docker compose logs

For a specific service:

docker compose logs api
16. How would you troubleshoot API → Redis connectivity?

I would check:

1. Is Redis running?
2. Is Redis healthy?
3. Are both containers on the same network?
4. Is REDIS_HOST correct?
5. Is REDIS_PORT correct?
6. Can the API resolve redis?
7. Can the API connect to port 6379?
8. What do the application logs show?

Useful commands:

docker compose ps
docker compose logs api
docker compose logs redis
docker network ls
docker inspect project-18-api
17. What happens if Redis goes down?

The API's /health endpoint should detect that Redis is unavailable and return an unhealthy response.

This is an important example of dependency-aware health monitoring.

18. What is the difference between healthcheck and readiness?

A healthcheck determines whether a service currently satisfies a defined health condition.

Readiness is the broader concept of whether a service is ready to accept traffic or perform its required function.

In Project 18, the API healthcheck includes Redis connectivity.

19. How would you move this architecture to Kubernetes?

Conceptually:

Docker Compose
      ↓
Kubernetes
      |
      +── Deployment
      +── Service
      +── ConfigMap
      +── Secret
      +── PersistentVolume
      +── Probes

The Compose concepts translate into Kubernetes resources, but Kubernetes provides a much broader orchestration platform.

20. What is the biggest limitation of Docker Compose?

Docker Compose is excellent for local development, testing and smaller deployments, but it is not equivalent to a full production orchestration platform such as Kubernetes.

Large production environments typically need capabilities such as:

Advanced scheduling
Self-healing
Horizontal scaling
Rolling deployments
Service discovery
Declarative orchestration
Multi-node management
21. Explain Project 18 in an interview.

"Project 18 demonstrates a multi-container application using Docker Compose. I built a Flask API and Redis service, connected them through the Compose network using service-name DNS, implemented healthchecks for both services, configured the API to wait for Redis health, and used a named volume for Redis data. I also created GitHub Actions automation that validates the Compose configuration, builds and starts the complete stack, verifies API and Redis health, tests real API-to-Redis connectivity and counter functionality, verifies networking, captures logs and cleans up the environment."

🧠 Production Mental Model

Project 18 establishes this model:

              Application Stack
                     |
             Docker Compose
                     |
        +------------+------------+
        |                         |
        v                         v
      API                      Redis
        |                         |
        +-------- Network --------+
                  |
               Health
                  |
               Storage

The most important concept is:

Containers are isolated processes, but Compose provides the networking, configuration and lifecycle model needed to operate them as one application stack.

🔥 Troubleshooting Cheat Sheet
Validate Compose
docker compose config
Start
docker compose up -d --build
Status
docker compose ps
Logs
docker compose logs
API logs
docker compose logs api
Redis logs
docker compose logs redis
Stop
docker compose stop
Start again
docker compose start
Remove stack
docker compose down
Remove stack + volumes
docker compose down -v
Test API
curl -fsS http://localhost:8096/
Test health
curl -fsS http://localhost:8096/health
Test Redis integration
curl -fsS http://localhost:8096/counter
🏆 Completion Checklist
 Project branch
 Flask API
 Redis service
 Dockerfile
 Compose configuration
 Compose networking
 Service discovery
 Environment configuration
 API healthcheck
 Redis healthcheck
 depends_on
 Redis volume
 API → Redis connectivity
 Counter functionality
 Compose logs
 Python tests
 GitHub Actions
 CI Compose validation
 CI health validation
 CI integration validation
 CI cleanup
 Successful CI run
 README
 Interview preparation
🎯 Final Result
PROJECT 18
Docker Compose Multi-Container
             |
       +-----+------+
       |            |
       v            v
     Flask         Redis
       |            |
       +-- Network -+
             |
        Healthchecks
             |
       Persistent Data
             |
        GitHub Actions
             |
          SUCCESS
🏆 PROJECT 18 — COMPLETED

Progress: 18 / 100

13 → Container Health
14 → Resource Limits
15 → Runtime Configuration
16 → Container Logging
17 → Log Rotation
18 → Docker Compose

Next: Project 19 — Docker Compose Environment & Configuration.
EOF


Then commit the documentation:

```bash
cd ~/CI-CD-mastery

git add project-18-compose-multi-container/README.md

git commit -m "docs(project-18): add compose multi-container README"

git push

Verify:

git status
git log --oneline --decorate -n 3

Then we're clear to continue with Project 19 at full speed.
