Project 21 — Enterprise Docker Compose Profiles
📌 Overview

Project 21 demonstrates how to design a production-oriented Docker Compose application using Compose Profiles to selectively enable optional operational services.

The project builds on the previous Compose projects by introducing:

Docker Compose Profiles
Default vs optional services
Development tooling
Debugging tooling
Secret mounting
Redis dependency
Health checks
Environment-based configuration
Multi-profile deployments
CI/CD validation with GitHub Actions
Host-port isolation

The objective is to make the same Compose stack usable in different environments without maintaining multiple Compose files.

🎯 Project Objective

Build an application stack with:

                    ┌─────────────────────┐
                    │   Project 21 API    │
                    │     Flask App       │
                    │      :5000          │
                    └──────────┬──────────┘
                               │
                     depends_on / Redis
                               │
                    ┌──────────▼──────────┐
                    │        Redis        │
                    │      redis:7        │
                    │       :6379         │
                    └─────────────────────┘

Optional operational services are enabled through profiles:

                 Docker Compose
                       │
          ┌────────────┼────────────┐
          │            │            │
       default         dev        debug
          │            │            │
       API+Redis   RedisInsight   Adminer
🏗️ Architecture
Default profile
project-21-api
       │
       ▼
project-21-redis

Only the core application stack runs.

Development profile
project-21-api
       │
       ▼
project-21-redis

project-21-redis-insight

RedisInsight is enabled for development/operational inspection.

Debug profile
project-21-api
       │
       ▼
project-21-redis

project-21-adminer

Adminer is enabled as debugging/administrative tooling.

Both profiles
project-21-api
       │
       ▼
project-21-redis
       │
       ├── RedisInsight
       │
       └── Adminer
📁 Project Structure
project-21-compose-profiles/
├── .dockerignore
├── .env.example
├── .gitignore
├── Dockerfile
├── app.py
├── compose.yml
├── requirements.txt
├── test_app.py
└── secrets/
    └── app_secret.txt        # ignored; never commit

GitHub Actions workflow:

.github/workflows/
└── project-21-compose-profiles.yml
🐳 Docker Image

The application image is:

ci-cd-mastery-project-21:1.0.0

Application container:

project-21-api

Port:

8099 → 5000
🔐 Configuration

The application uses environment variables such as:

APP_NAME
APP_VERSION
ENVIRONMENT
LOG_LEVEL
REDIS_HOST
REDIS_PORT
APP_SECRET_FILE

Example:

APP_NAME=project-21
APP_VERSION=1.0.0
ENVIRONMENT=development
LOG_LEVEL=INFO
REDIS_HOST=redis
REDIS_PORT=6379

Local .env files are ignored by Git.

Verify:

git check-ignore -v .env
🔑 Secret Management

The application uses a mounted Compose secret:

/run/secrets/app_secret

The secret is not passed as a normal environment variable.

The container receives:

APP_SECRET_FILE=/run/secrets/app_secret

Verify:

docker exec project-21-api \
  cat /run/secrets/app_secret

Check that the secret isn't exposed as an environment variable:

docker exec project-21-api env | grep -i SECRET

Only the file reference should be present.

Security principle

Do not commit:

.env
secrets/app_secret.txt

The repository uses .gitignore to protect them.

🧩 Compose Profiles
Default
docker compose up -d

Expected services:

project-21-api
project-21-redis
Development
docker compose --profile dev up -d

Expected:

project-21-api
project-21-redis
project-21-redis-insight

RedisInsight:

localhost:8090
Debug
docker compose --profile debug up -d

Expected:

project-21-api
project-21-redis
project-21-adminer

Adminer:

localhost:8101

The host port was deliberately changed to 8101 to avoid conflicts with:

8080 → Jenkins
8090 → RedisInsight
8091 → Project 13
8099 → Project 21 API

The Adminer container itself still listens on:

8080

So:

Host:      8101
Container: 8080
🚀 Run Both Profiles

This was successfully validated during the project:

docker compose \
  --profile dev \
  --profile debug \
  up -d

Expected:

NAME
project-21-api
project-21-redis
project-21-redis-insight
project-21-adminer

Check:

docker compose ps
❤️ Health Checks

The API includes a health endpoint:

/health

Test:

curl -fsS http://localhost:8099/health

Successful response:

{
  "redis": "healthy",
  "secret_mounted": true,
  "status": "healthy"
}

Redis uses:

redis-cli ping

as its container health check.

The API depends on Redis becoming healthy before startup.

🧪 Application Endpoints
Health
curl -fsS http://localhost:8099/health
Secret status
curl -fsS http://localhost:8099/secret-status

Example:

{
  "secret_length": 23,
  "secret_mounted": true
}
Counter
curl -fsS http://localhost:8099/counter

Example:

{
  "counter": 1
}
🧪 Automated Testing

Run:

python3 -m pytest -q project-21-compose-profiles

Final result:

4 passed

The tests validate core application behavior and configuration.

🔍 Compose Validation

Validate the default configuration:

docker compose config

Development:

docker compose --profile dev config

Debug:

docker compose --profile debug config

Both:

docker compose \
  --profile dev \
  --profile debug \
  config
🧹 Cleanup

Remove Project 21 containers, network and volume:

docker compose down -v --remove-orphans

This is especially useful when switching between profiles.

🔄 CI/CD Pipeline

GitHub Actions workflow:

.github/workflows/project-21-compose-profiles.yml

Workflow:

Checkout
   ↓
Set up Python
   ↓
Install dependencies
   ↓
Run tests
   ↓
Create CI environment
   ↓
Verify ignored files
   ↓
Validate Compose
   ↓
Validate dev profile
   ↓
Validate debug profile
   ↓
Build Docker image
   ↓
Start default stack
   ↓
Verify services
   ↓
Wait for API health
   ↓
Test development profile
   ↓
Test debug profile
   ↓
Test both profiles
   ↓
Show logs
   ↓
Cleanup
✅ Final CI Result

Project 21 successfully completed GitHub Actions validation.

Run:

31598323367

Result:

✓ Project 21 - Compose Profiles
✓ compose-profiles
✓ completed with success

Important CI stages passed:

✓ Install dependencies
✓ Run tests
✓ Create CI environment
✓ Verify local configuration
✓ Validate default Compose
✓ Validate development profile
✓ Validate debug profile
✓ Build Docker image
✓ Verify default services
✓ API health
✓ Default application
✓ Development profile
✓ Debug profile
✓ Both profiles
✓ Cleanup
🧠 Key DevOps Concepts Learned
1. What are Compose Profiles?

Profiles allow optional services to be enabled selectively.

Instead of maintaining:

docker-compose-dev.yml
docker-compose-debug.yml
docker-compose-prod.yml

you can maintain one Compose file:

compose.yml

and activate services with:

--profile
2. Why use profiles?

They allow the same Compose configuration to support different operational requirements.

For example:

Developer
    ↓
API + Redis + RedisInsight

Debugging
    ↓
API + Redis + Adminer

Minimal deployment
    ↓
API + Redis
3. What is the advantage over multiple Compose files?

Profiles reduce:

Configuration duplication
Maintenance overhead
Configuration drift
Environment-specific inconsistencies
🎤 Interview Questions & Answers
Q1. What are Docker Compose profiles?

Answer:

Docker Compose profiles allow services to be conditionally enabled. A service assigned to a profile doesn't start by default and can be activated using docker compose --profile <name> up.

Q2. How do you enable multiple profiles?
docker compose \
  --profile dev \
  --profile debug \
  up -d

Multiple profiles can be activated simultaneously.

Q3. What happens if no profile is specified?

Services without a profile start normally.

Profile-specific services remain disabled.

Q4. Why would you use Compose profiles in a DevOps environment?

They allow a single Compose configuration to support different environments and operational workflows without duplicating configuration files.

Q5. How do you prevent development tools from running in production?

Assign them to profiles:

profiles:
  - dev

or:

profiles:
  - debug

Then only activate those profiles when required.

Q6. What problem did the port conflict demonstrate?

Host ports must be unique.

For example:

Jenkins        → 8080
Project 13     → 8091
RedisInsight   → 8090
Project 21 API → 8099
Adminer        → 8101

Two containers cannot bind the same host port simultaneously.

Q7. What's the difference between host and container ports?

For:

ports:
  - "8101:8080"
8101 = host port
8080 = container port

The service listens on 8080 inside the container while users access it through port 8101 on the host.

Q8. Why should secrets not be passed as environment variables?

Environment variables can accidentally appear in:

Process inspection
Debug output
Logs
CI output
Container metadata

Compose secrets provide a file-based mechanism such as:

/run/secrets/app_secret
Q9. What is depends_on with a health condition?

Instead of simply starting containers in order, Compose can wait for a dependency to become healthy:

depends_on:
  redis:
    condition: service_healthy

This helps prevent the API from starting before Redis is ready.

Q10. Does depends_on guarantee application-level readiness?

Not necessarily.

A container being started or healthy according to a basic health check doesn't guarantee the application is completely ready for every operation.

Production systems should use meaningful health/readiness checks.

Q11. How do you validate a Compose configuration without starting containers?
docker compose config

This renders and validates the resolved Compose configuration.

Q12. How would you debug a failed Compose deployment?

I would check:

docker compose ps
docker compose logs
docker inspect <container>
docker compose config

Then investigate:

Container state
Health status
Port conflicts
Environment variables
Volumes
Networks
Dependencies
Q13. How do you verify that a secret isn't committed?
git check-ignore -v .env
git check-ignore -v secrets/app_secret.txt

Then:

git status

and verify the files aren't tracked.

Q14. How would you use this pattern in production?

I would keep the core application services in the default Compose configuration and place optional operational tooling behind profiles.

For example:

default
 └── application services

monitoring
 └── monitoring tools

debug
 └── debugging tools

development
 └── developer tooling

In a true production environment, however, I'd generally move toward an orchestrator such as Kubernetes for larger-scale workloads.

💼 Strong Interview Explanation

If an interviewer asks:

"Explain something you've implemented with Docker Compose."

You can say:

"I implemented an enterprise-style Docker Compose application using profiles to separate core services from optional development and debugging tools. The default stack runs a Flask API and Redis, while development enables RedisInsight and debugging enables Adminer. I also implemented health checks, Redis dependency conditions, environment configuration, mounted secrets, and CI validation. GitHub Actions validates the Compose configuration and tests each profile independently as well as both profiles together. During implementation I also handled host-port collisions by isolating the host ports while keeping the internal container ports unchanged."

That's a strong hands-on DevOps interview answer because it demonstrates design, implementation, troubleshooting, security, and CI/CD rather than simply knowing the docker compose --profile command.

🏆 Project 21 Completion Checklist
Requirement	Status
Flask application	✅
Redis	✅
Docker image	✅
Environment configuration	✅
Compose secrets	✅
Health checks	✅
Default profile	✅
Development profile	✅
Debug profile	✅
Multi-profile deployment	✅
Port isolation	✅
Unit tests	✅
GitHub Actions	✅
CI Compose validation	✅
CI cleanup	✅
GitHub Actions green	✅
Project 21 — COMPLETE ✅

Next in the sequence: Project 22 — Enterprise Docker Compose Networking.
