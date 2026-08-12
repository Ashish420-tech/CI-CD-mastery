# 🔐 Project 20 — Secure Docker Compose Secrets

![Docker](https://img.shields.io/badge/Docker-Container-blue?logo=docker)
![Docker Compose](https://img.shields.io/badge/Docker%20Compose-Secrets-blue?logo=docker)
![Python](https://img.shields.io/badge/Python-3.12-blue?logo=python)
![Flask](https://img.shields.io/badge/Flask-Application-black?logo=flask)
![Redis](https://img.shields.io/badge/Redis-Database-red?logo=redis)
![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-CI-success?logo=githubactions)
![Security](https://img.shields.io/badge/Security-Secret%20Management-critical)
![Status](https://img.shields.io/badge/Status-Completed-success)

> **CI/CD Mastery — Project 20**

---

# 📌 Project Overview

Project 20 introduces **secure runtime secret management** into the Docker Compose architecture developed in Projects 18 and 19.

The project demonstrates how to provide sensitive configuration to a container without:

- Committing secrets to Git
- Storing secrets in the Dockerfile
- Baking secrets into the Docker image
- Exposing secret values through normal environment variables
- Printing secrets into CI logs

Instead, Docker Compose mounts the secret into:

```text
/run/secrets/app_secret

The application reads the secret directly from this file at runtime.

🎯 Objectives

Project 20 demonstrates:

Docker Compose secrets
Runtime secret injection
Secret files
/run/secrets
.gitignore protection
Secure application configuration
Secret isolation
Image-layer security
Environment-variable security
CI/CD secret validation
Automated security checks
🏗️ Architecture
                       Secret Source
                            |
                            v
                 secrets/app_secret.txt
                       Git ignored
                            |
                            v
                    Docker Compose
                            |
                            v
                    /run/secrets/
                            |
                            v
                  project-20-api
                            |
                            v
                 Flask Application
                            |
             +--------------+--------------+
             |                             |
             v                             v
        Secret File                     Redis
      /run/secrets/                  redis:6379
        app_secret

The application never requires:

APP_SECRET=<secret-value>

Instead it receives:

APP_SECRET_FILE=/run/secrets/app_secret

and reads the actual value from the mounted file.

🔐 Security Model

The insecure approach would be:

❌ Secret in Git
       |
       v
❌ Dockerfile
       |
       v
❌ Docker image
       |
       v
❌ Environment variable

Project 20 implements:

✅ Secret source
       |
       v
✅ Git ignored
       |
       v
✅ Docker Compose secret
       |
       v
✅ /run/secrets/app_secret
       |
       v
✅ Application runtime
📁 Project Structure
project-20-compose-secrets/
│
├── .dockerignore
├── .env
├── .env.example
├── .gitignore
├── Dockerfile
├── README.md
├── app.py
├── compose.yml
├── requirements.txt
├── secrets/
│   └── app_secret.txt
└── test_app.py

Important:

.env
secrets/

are ignored by Git.

GitHub Actions workflow:

.github/
└── workflows/
    └── project-20-compose-secrets.yml
⚠️ Secret Handling Rules

Never commit:

.env
secrets/app_secret.txt
passwords
API keys
private keys
tokens
cloud credentials
database credentials

Project 20 uses local secret files only for the lab.

Production environments should use dedicated secret-management systems such as:

AWS Secrets Manager
AWS Systems Manager Parameter Store
HashiCorp Vault
Kubernetes Secrets
External Secrets
GitHub Actions Secrets
🐳 Docker Compose Secret

The Compose file defines:

secrets:
  app_secret:
    file: ./secrets/app_secret.txt

The API consumes it:

secrets:
  - app_secret

The container receives the secret at:

/run/secrets/app_secret
🔄 Secret Flow
Local Secret
     |
     v
secrets/app_secret.txt
     |
     v
Docker Compose
     |
     v
/run/secrets/app_secret
     |
     v
Flask Application

The secret is available at runtime without being stored in the image.

🐍 Application

The Flask application exposes:

GET /
GET /health
GET /secret-status
GET /counter
/ Endpoint
curl -fsS http://localhost:8098/

Returns application metadata.

❤️ /health Endpoint
curl -fsS http://localhost:8098/health

Expected:

{
  "redis": "healthy",
  "secret_mounted": true,
  "status": "healthy"
}

The health endpoint verifies:

Redis connectivity
Secret file availability
🔐 /secret-status Endpoint
curl -fsS http://localhost:8098/secret-status

Expected:

{
  "secret_length": 33,
  "secret_mounted": true
}

The endpoint deliberately exposes only:

secret_mounted
secret_length

It never returns the actual secret value.

This is important because application diagnostics should not expose sensitive values.

🔢 /counter Endpoint

The application also communicates with Redis.

curl -fsS http://localhost:8098/counter

Expected:

{
  "counter": 1
}

This demonstrates that secret management does not interfere with normal application functionality.

🔍 Verify Secret Mount

Check that the secret file exists:

docker exec project-20-api \
  sh -c 'test -f /run/secrets/app_secret && echo SECRET_MOUNT_OK'

Expected:

SECRET_MOUNT_OK
⚠️ Do Not Print the Secret

Avoid:

docker exec project-20-api cat /run/secrets/app_secret

in CI pipelines or shared logs.

The existence of the file is enough to validate the mount.

Project 20 validates:

file exists
     +
application can detect it

without exposing the value.

🔒 Verify Secret Is Not an Environment Variable

Run:

docker exec project-20-api env | grep -i SECRET || true

Expected:

APP_SECRET_FILE=/run/secrets/app_secret

The actual secret value must not appear.

Incorrect:

APP_SECRET=project-20-local-secret...

Correct:

APP_SECRET_FILE=/run/secrets/app_secret
🧱 Verify Secret Is Not in Image

Inspect the image:

docker history ci-cd-mastery-project-20:1.0.0

The image layers should contain only application and dependency build operations.

The secret value must not appear in:

Dockerfile
COPY commands
RUN commands
ENV instructions
Image layers
🐳 Why Secrets Should Not Be Baked Into Images

An image is an immutable artifact that may be:

Stored in a registry
Pulled by multiple environments
Cached
Shared between teams
Scanned
Retained for long periods

If a production secret is baked into an image, anyone with access to that artifact may potentially retrieve it.

Therefore:

Build once
Deploy many times
Inject secrets at runtime

is a safer model.

🧪 Automated Tests

Run:

python3 -m pytest -q project-20-compose-secrets

Project result:

4 passed

The tests validate:

Application endpoint
Health endpoint
Secret status
Counter

Secrets are mocked during unit testing.

Actual secret mounting is tested by the Docker Compose integration workflow.

▶️ Start the Application

From the project directory:

cd ~/CI-CD-mastery/project-20-compose-secrets

Start:

docker compose up -d --build

Check:

docker compose ps

Expected:

project-20-api
project-20-redis

Both should become:

healthy
🔍 Inspect Services
docker compose ps

Expected:

NAME               SERVICE   STATUS
project-20-api     api       Up (healthy)
project-20-redis   redis     Up (healthy)
📜 View Logs
docker compose logs

API only:

docker compose logs api

Redis only:

docker compose logs redis

Recent logs:

docker compose logs --tail 50

Logs must never contain the actual secret value.

🛑 Stop Application
docker compose down

Remove volumes as well:

docker compose down -v
🔎 Git Secret Protection

Check:

git check-ignore -v .env

Expected:

.gitignore:1:.env    .env

Check the secret file:

git check-ignore -v secrets/app_secret.txt

Expected:

.gitignore:2:secrets/    secrets/app_secret.txt

This confirms that local secrets are excluded from version control.

🚀 GitHub Actions CI/CD

Workflow:

.github/workflows/project-20-compose-secrets.yml

The CI pipeline deliberately creates a temporary test secret:

ci-secret-value

inside the GitHub Actions runner.

It is never committed to the repository.

🔄 CI Pipeline
Checkout
   |
   v
Python Setup
   |
   v
Install Dependencies
   |
   v
Run Tests
   |
   v
Create CI Environment
   |
   v
Create Temporary CI Secret
   |
   v
Verify Secret Files Ignored
   |
   v
Validate Compose
   |
   v
Build Stack
   |
   v
Start Containers
   |
   v
API Health
   |
   v
Redis Health
   |
   v
Verify Secret Mount
   |
   v
Verify Secret Status
   |
   v
Verify Secret Not In Environment
   |
   v
Verify Application
   |
   v
Verify Redis Integration
   |
   v
Verify Secret Not In Image
   |
   v
Logs
   |
   v
Cleanup
🔐 CI Security Checks

The workflow verifies:

1. Secret file is ignored
git check-ignore -q .env
git check-ignore -q secrets/app_secret.txt
2. Secret is mounted
test -f /run/secrets/app_secret
3. Secret isn't exposed through environment

The workflow checks that:

ci-secret-value

does not appear in the container environment.

4. Secret isn't in image history

The workflow searches Docker image history for the test secret.

If found:

CI FAILS

This provides an automated security guardrail.

🏆 Successful CI Run

Workflow:

Project 20 - Compose Secrets

Run:

31582137956

Job:

compose-secrets

Duration:

45 seconds

Result:

SUCCESS
✅ CI Steps Passed
✓ Set up job
✓ Checkout
✓ Set up Python
✓ Install dependencies
✓ Run tests
✓ Create CI environment
✓ Create temporary CI secret
✓ Verify secret files are ignored
✓ Validate Compose
✓ Build and start stack
✓ Show services
✓ Wait for API health
✓ Verify Redis health
✓ Verify secret mount
✓ Verify secret status
✓ Verify secret is not environment value
✓ Verify health
✓ Verify Redis integration
✓ Verify secret not in image history
✓ Show logs
✓ Cleanup
✓ Complete job
🎤 Enterprise Interview Questions
1. Why should secrets not be stored in Docker images?

Docker images are long-lived artifacts that can be cached, pushed to registries, shared and inspected.

Embedding a secret creates a serious risk of credential exposure.

Secrets should be injected at runtime.

2. Why not use environment variables for secrets?

Environment variables are convenient, but they can be exposed through:

Container inspection
Process environments
Debugging
Application dumps
CI logs
Accidental logging

For sensitive values, mounted secret files or dedicated secret-management systems can provide better separation.

3. Where does a Docker Compose secret appear inside the container?

Docker Compose mounts the secret at:

/run/secrets/<secret-name>

Project 20 uses:

/run/secrets/app_secret
4. Is /run/secrets part of the Docker image?

No.

The secret is supplied at runtime.

It is not part of the image's build layers.

5. What is the difference between configuration and secrets?

Configuration:

APP_VERSION
LOG_LEVEL
API_PORT
ENVIRONMENT

Secrets:

PASSWORD
API_TOKEN
PRIVATE_KEY
DATABASE_PASSWORD

Secrets require stronger access controls and handling.

6. Why is .env.example safe to commit?

It documents the required variables and expected structure without containing actual sensitive credentials.

Example:

DATABASE_PASSWORD=<set-at-runtime>
7. Why should .env normally be ignored?

A local .env may contain environment-specific or sensitive values.

Keeping it out of Git reduces accidental credential exposure.

8. How do you prove the secret isn't in the image?

Inspect:

docker history <image>

and ensure the secret value does not appear.

Also inspect the Dockerfile and build context.

9. Why is COPY secrets/... dangerous?

A COPY instruction places the secret into an image layer.

Even if the file is later deleted, the secret may remain recoverable from earlier image layers.

10. Why is ARG SECRET=... dangerous?

Build arguments can potentially become exposed through build metadata, logs, cache or image history depending on how they're used.

Build-time secrets should use dedicated BuildKit secret mechanisms where appropriate, and runtime secrets should generally be injected at runtime.

11. What happens if the secret file is missing?

The application cannot read the secret.

Project 20's /secret-status endpoint will report:

{
  "secret_mounted": false,
  "secret_length": 0
}

Production applications should fail safely or become unhealthy when a required secret is missing.

12. How should production secrets be managed?

Use a dedicated secret-management solution.

Examples:

AWS Secrets Manager
AWS Systems Manager Parameter Store
HashiCorp Vault
Kubernetes Secrets
External Secrets Operator
GitHub Actions Secrets

The appropriate solution depends on the deployment platform.

13. What is secret rotation?

Secret rotation means replacing credentials periodically or when compromise is suspected.

A mature system should allow:

Old Secret
    ↓
New Secret
    ↓
Application reload/redeploy
    ↓
Old Secret revoked

without rebuilding the application image.

14. What is the principle of least privilege?

Applications and users should receive only the permissions required to perform their tasks.

For secret management this means:

Application
    ↓
Only required secret
    ↓
Only required access

rather than access to every secret in the environment.

15. What is the difference between build-time and runtime secrets?

Build-time secret:

Used temporarily while constructing an image.

Runtime secret:

Provided when the container starts and consumed by the running application.

Project 20 focuses primarily on runtime secrets.

16. How would you implement this in Kubernetes?

Conceptually:

Kubernetes Secret
       |
       v
Secret Volume
       |
       v
Pod
       |
       v
/run/secrets/...

or environment-based injection where appropriate.

For stronger enterprise designs, external secret managers can be integrated with Kubernetes.

17. How would you implement this on AWS?

A production AWS design could use:

AWS Secrets Manager
        |
        v
IAM-controlled application access
        |
        v
ECS / EKS workload
        |
        v
Runtime secret

The workload should receive only the secrets it needs.

18. How do you prevent secrets from appearing in CI logs?

Never execute commands such as:

cat secret.txt
echo "$SECRET"

Use:

secret existence checks
secret length checks
masked CI variables
secret-store integrations

and carefully control logging.

19. What would you do if a secret was accidentally committed?

Immediately:

Revoke/rotate the compromised credential.
Remove the secret from the repository.
Check Git history and other replicas.
Investigate access.
Update secret-management procedures.
Add CI secret scanning/prevention.

Deleting the file from the latest commit alone does not make the credential safe.

20. Explain Project 20 in an interview.

"Project 20 implements secure runtime secret management for a Docker Compose application. Instead of storing the secret in Git, the Dockerfile, image or environment variables, I defined it as a Compose secret and mounted it under /run/secrets/app_secret. The Flask application reads the secret from the mounted file and exposes only its presence and length for validation. Git ignores both the local environment file and secret directory. GitHub Actions creates a temporary CI secret, validates the Compose configuration, verifies the secret mount, confirms the secret isn't exposed through the environment, checks that it isn't present in Docker image history, validates the API and Redis integration, and cleans up the environment."

🧠 Enterprise Security Model
                   Source Code
                       |
                       v
                Immutable Image
                       |
              +--------+--------+
              |                 |
              v                 v
        Configuration        Secrets
              |                 |
              v                 v
          Environment       Secret Store
                                |
                                v
                         Runtime Injection
                                |
                                v
                           Application

The key principle:

Build artifacts should be reusable; environment-specific secrets should be supplied at runtime.

🏁 Project 20 Completion Checklist
[x] Docker Compose secrets
[x] Runtime secret injection
[x] /run/secrets
[x] Secret file
[x] .env protection
[x] secrets/ protection
[x] No secret in Dockerfile
[x] No secret in image
[x] No secret in environment
[x] Secret status endpoint
[x] Redis integration
[x] Unit tests
[x] CI temporary secret
[x] CI secret validation
[x] CI image-history validation
[x] CI cleanup
[x] Successful GitHub Actions run
[x] README
[x] Enterprise interview preparation
🏆 PROJECT 20 — COMPLETED
18  Docker Compose Multi-Container       ✅
19  Enterprise Configuration              ✅
20  Secure Docker Compose Secrets         ✅

Progress: 20 / 100

Next: Project 21 — Docker Compose Profiles & Environment-Specific Deployment.
EOF


Then commit it:

```bash
