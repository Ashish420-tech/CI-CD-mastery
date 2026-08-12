# Project 25 — Enterprise Docker Compose Secrets

Production-style Docker Compose secret management using runtime-mounted secrets and a non-root Flask application.

## Objective

Demonstrate secure application secret handling with:

- Docker Compose secrets
- Runtime-only secret injection
- Non-root containers
- Secret file permissions
- No secrets in environment variables
- No secrets baked into images
- Automated tests
- Docker/Compose validation
- GitHub Actions CI

## Architecture

```text
                Docker Compose
                     |
              runtime secret
                     |
                     v
        /run/secrets/app_secret
                     |
                     v
             +---------------+
             |   Flask API   |
             |  appuser UID  |
             |     1000      |
             +---------------+
                |    |    |
                v    v    v
                /  health  /secret-status
Secret Handling

The application reads:

/run/secrets/app_secret

The secret is:

mounted only at runtime
not copied by the Dockerfile
not stored in an environment variable
not returned by any API endpoint
excluded from Git
excluded from the Docker build context

The local development secret is stored under:

secrets/app_secret

and ignored by Git.

Security

The API container:

Runs as non-root appuser
Uses UID/GID 1000
Uses no-new-privileges
Uses a minimal Python image
Uses a Docker health check
Uses an init process
Uses graceful shutdown configuration

The secret is mounted with:

0440

and owned by:

appuser:appgroup
Endpoints
Root
GET /

Returns application status.

Health
GET /health

Returns:

{
  "status": "healthy"
}
Secret Status
GET /secret-status

Returns only metadata:

{
  "secret_available": true,
  "secret_length": 32
}

The actual secret value is never returned.

Validation

Local validation verifies:

pytest suite
Docker build
Compose configuration
Container health
Runtime secret mount
Secret readability as non-root user
Secret not exposed through environment
Secret not present in Docker image history
API functionality
CI/CD

GitHub Actions validates:

Python tests
Docker Compose configuration
Docker build
Compose startup
Container health
API health
Secret mount
Secret availability
Secret environment leakage
Stack cleanup
