# Project 12 — Container Deployment

## Objective

Deploy a Docker image as a long-running container and validate the application through HTTP.

## Enterprise Problem

A successful Docker build does not prove that an application can start and serve traffic.

Project 12 adds runtime deployment validation:

```text
Docker Build
     ↓
Docker Run
     ↓
Container Running
     ↓
Port Mapping
     ↓
HTTP Health Check
     ↓
Deployment PASS
Application

Project 12 uses a small Flask HTTP service.

Endpoints:

GET /
GET /health

Container port:

5000

Host port:

8090
Directory Structure
project-12-container-deployment/
├── .dockerignore
├── Dockerfile
├── README.md
├── app.py
└── test_app.py
Local Validation
Tests
python3 -m pytest -q project-12-container-deployment

Result:

3 passed
Build
docker build \
  -t ci-cd-mastery-project-12:1.0.0 \
  ./project-12-container-deployment
Deploy
docker run -d \
  --name project-12-app \
  -p 8090:5000 \
  ci-cd-mastery-project-12:1.0.0
Runtime validation
docker inspect project-12-app \
  --format 'status={{.State.Status}} exit_code={{.State.ExitCode}}'

Expected:

status=running exit_code=0
HTTP validation
curl -i http://localhost:8090/

Expected:

HTTP/1.1 200 OK

Health check:

curl -fsS http://localhost:8090/health

Expected:

{"status":"healthy"}
Container Restart

The same image/container can be restarted without rebuilding:

docker stop project-12-app
docker start project-12-app

curl -fsS http://localhost:8090/health
CI/CD Pipeline
Checkout
   ↓
pytest
   ↓
Docker Build
   ↓
Docker Run
   ↓
Container Runtime Validation
   ↓
HTTP Health Validation
   ↓
Container Cleanup
Technologies
Docker
Python
Flask
pytest
GitHub Actions
Interview Questions
1. Why validate a container after building it?

Build success does not prove that the application starts correctly or serves traffic.

2. Image vs container?

An image is the packaged application artifact. A container is a running instance of that image.

3. What does 8090:5000 mean?

Host port 8090 is mapped to container port 5000.

4. Why use a health endpoint?

It provides a simple machine-readable signal that the application is running and responding.

5. Why use 0.0.0.0 inside the container?

The application must listen on all container interfaces so traffic arriving through Docker's port mapping can reach it.

6. Why is the Flask development server not production-ready?

It is suitable for this CI/CD learning project, but production deployments should use a production WSGI server and appropriate process management.

Validation Result
pytest                    ✅
Docker Build              ✅
Container Start           ✅
Container Running         ✅
Port Mapping              ✅
HTTP /                    ✅
HTTP /health              ✅
Container Restart         ✅
