# Project 25 — Enterprise Docker Compose Secrets

> Secure runtime secret injection for a non-root Docker container — without baking secrets into images or exposing them through environment variables.

## 🎯 What This Project Demonstrates

A production-style Docker Compose implementation of:

- Docker Compose secrets
- Runtime-only secret injection
- Non-root container execution
- Linux UID/GID and file-permission management
- Least-privilege security
- Docker healthchecks
- Secret leakage prevention
- Automated testing
- GitHub Actions CI/CD
- Real-world failure diagnosis

---

## 🏗️ Architecture

```text
                    Docker Compose
                         │
                         │ Runtime Secret
                         ▼
              ┌──────────────────────┐
              │ /run/secrets/        │
              │ app_secret            │
              └──────────┬───────────┘
                         │
                         ▼
              ┌──────────────────────┐
              │      Flask API       │
              │                      │
              │ appuser UID 1000     │
              │ no-new-privileges    │
              │ healthcheck          │
              └──────────┬───────────┘
                         │
              ┌──────────┼──────────┐
              ▼          ▼          ▼
             /        /health   /secret-status
🔐 Secure Secret Flow
Local / CI Secret
       │
       ▼
secrets/app_secret
       │
       │ Docker Compose runtime mount
       ▼
/run/secrets/app_secret
       │
       ▼
   Flask API
       │
       ▼
Metadata only

The actual secret value is never returned by the API.

The application only reports:

{
  "secret_available": true,
  "secret_length": 32
}
🛡️ Security Controls
Security Control	Implementation
Runtime secret injection	/run/secrets/app_secret
Secret baked into image	❌
Secret environment variable	❌
Secret tracked by Git	❌
Docker build context	Secret excluded
Container user	appuser
UID/GID	1000:1000
Secret permissions	0440
Secret ownership	appuser:appgroup
Privilege escalation	no-new-privileges:true
Base image	python:3.12-slim
Process management	init: true
Health monitoring	Docker HEALTHCHECK
Image-history leakage test	Automated
🚨 Real Production-Style Failure Diagnosed

This project intentionally exposed a realistic container-security problem.

Initial failure

The secret was successfully mounted:

/run/secrets/app_secret

but the Flask endpoint returned:

HTTP 500

because the non-root process could not read the file.

The actual error was:

PermissionError: [Errno 13] Permission denied
Root cause

The mounted secret was owned by a different UID/GID than the application process.

Secret ownership
UID/GID mismatch
        │
        ▼
appuser cannot read file
        │
        ▼
HTTP 500
Correct fix

Instead of running the container as root, the security model was preserved:

appuser
UID 1000
GID 1000
     +
secret permissions 0440
     +
appuser:appgroup ownership

Result:

Secret readable
        │
        ▼
Application remains non-root
        │
        ▼
Runtime secret validation GREEN
CI-specific discovery

The same permission issue appeared on GitHub-hosted runners because the CI-created secret had different ownership.

The GitHub Actions workflow was corrected to explicitly establish:

UID 1000
GID 1000
Permissions 0440

This makes the pipeline reproducible instead of depending on the host environment.

⚙️ Application Endpoints
GET /

Application status.

{
  "service": "project-25-secrets",
  "status": "ok"
}
GET /health

Container health endpoint.

{
  "status": "healthy"
}
GET /secret-status

Validates secret availability without exposing the secret.

{
  "secret_available": true,
  "secret_length": 32
}
🧪 Validation
Local validation

Verified:

4/4 pytest tests
Docker Compose configuration
Docker image build
Container health
Runtime secret mount
Secret readability as non-root
Secret permissions
Secret ownership
No environment-variable leakage
No image-history leakage
API functionality
GitHub Actions validation

The CI pipeline verifies:

Python tests
      ↓
Create disposable CI secret
      ↓
Set permissions + ownership
      ↓
Compose validation
      ↓
Docker build
      ↓
Container startup
      ↓
Health verification
      ↓
Runtime secret verification
      ↓
Secret mount verification
      ↓
Environment leakage detection
      ↓
Image-history leakage detection
      ↓
Cleanup
      ↓
GREEN
🐳 Docker Security Design

The API container uses:

python:3.12-slim
non-root appuser
UID/GID 1000:1000
Gunicorn
no-new-privileges
init: true
Docker HEALTHCHECK
restrictive secret permissions
excluded secret files
minimal Docker build context
📁 Project Structure
project-25-compose-secrets/
├── app/
│   ├── app.py
│   └── requirements.txt
├── secrets/
│   └── .gitkeep
├── tests/
│   └── test_secrets.py
├── Dockerfile
├── docker-compose.yml
├── .dockerignore
├── .gitignore
└── README.md

The real local secret:

secrets/app_secret

is intentionally ignored by Git.

🎤 DevOps Interview Talking Points
Why avoid environment variables for secrets?

Environment variables can unintentionally become visible through process inspection, debugging, container metadata, or logs. Runtime-mounted secrets provide a dedicated file-based interface and keep the secret out of the image.

Why not run the container as root?

Running as root would hide the permission problem while weakening the security model.

The correct solution is:

Least privilege
+
Correct UID/GID
+
Correct file permissions
What caused the HTTP 500?

The secret existed but the non-root application process lacked permission to read it.

This was an identity and filesystem-permission problem, not a Flask or Docker networking problem.

How was CI made reproducible?

The CI pipeline creates a disposable secret, explicitly sets its ownership and permissions, validates runtime access, checks for leakage, and cleans up the Compose environment.

Is this identical to Docker Swarm secrets?

No.

This project demonstrates Docker Compose's file-backed secret mechanism for local/CI Compose environments. Swarm-managed secrets use a different underlying mechanism.

The security principles remain the same:

Runtime injection
Least privilege
Controlled access
No secrets in images
No accidental exposure
📊 Project Results
Gate	Result
Flask API	✅
Runtime secret injection	✅
Non-root execution	✅
UID/GID validation	✅
Secret permissions	✅
Secret ownership	✅
Environment leakage check	✅
Image-history leakage check	✅
Automated tests	✅ 4/4
Docker build	✅
Compose validation	✅
GitHub Actions	✅ GREEN
Cleanup	✅
💼 Skills Demonstrated
Docker
Docker Compose
Docker Security
Docker Secrets
Linux Permissions
UID/GID Management
Least Privilege
Container Hardening
Flask
Gunicorn
Pytest
Git
GitHub Actions
CI/CD
Failure Diagnosis
Security Validation
🏁 Result

Project 25 — COMPLETE ✅

Enterprise Docker Compose runtime secret management implemented, failure-tested, security-hardened, automated, and verified through GitHub Actions.

Projects 01 → 25 complete.
