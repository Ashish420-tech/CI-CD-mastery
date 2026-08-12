# Project 12 — Container Deployment

## Overview

Project 12 moves the CI/CD pipeline from **Docker image creation** into **actual container deployment and runtime validation**.

Previous projects established:

```text
Project 08
Container Registry
      ↓
Project 09
Image Security Scanning
      ↓
Project 10
Image Tagging & Lifecycle
      ↓
Project 11
Build Once → Promote
      ↓
Project 12
Container Deployment

The key objective is to prove that a successfully built Docker image can actually start as a container and serve application traffic.

1. Objective

Project 12 demonstrates:

Docker image creation
Container deployment
Container runtime validation
Port mapping
HTTP application validation
Health endpoint validation
Container restart
GitHub Actions deployment validation
CI dependency management

The deployment flow is:

Source Code
     |
     v
pytest
     |
     v
Docker Build
     |
     v
Docker Image
     |
     v
docker run
     |
     v
Running Container
     |
     v
HTTP Request
     |
     v
Application Response
2. Enterprise Problem

A successful Docker build does not prove that the application can actually run.

For example:

Docker Build
     |
     v
SUCCESS

does not necessarily mean:

Container starts
     |
     v
Application stays running
     |
     v
Application accepts traffic
     |
     v
HTTP endpoint responds

Project 12 therefore introduces runtime deployment validation.

3. Architecture
                         Git Repository
                              |
                              v
                         Run pytest
                              |
                              v
                       Docker Build
                              |
                              v
                    Project 12 Image
                              |
                              v
                       docker run
                              |
                              v
                    project-12-app
                              |
                     Port 8090:5000
                              |
                              v
                         HTTP Client
                              |
                              v
                       Flask Application
                         /        \
                        /          \
                       v            v
                      /             /health
                   HTTP 200       HTTP 200
4. Technology Stack
Technology	Purpose
Python	Application runtime
Flask	HTTP application
pytest	Application testing
Docker	Container build and deployment
Git	Version control
GitHub Actions	CI/CD automation
5. Directory Structure
CI-CD-mastery/
│
├── .github/
│   └── workflows/
│       └── project-12-container-deployment.yml
│
└── project-12-container-deployment/
    ├── .dockerignore
    ├── Dockerfile
    ├── README.md
    ├── app.py
    └── test_app.py
6. Application

The Project 12 application is a small Flask HTTP service.

The application exposes:

GET /
GET /health

The application listens on:

0.0.0.0:5000

Docker maps this container port to:

localhost:8090

Therefore:

Host
8090
 |
 v
Container
5000
 |
 v
Flask
7. Application Response

The root endpoint provides application information.

Example:

{
  "application": "ci-cd-mastery-project-12",
  "version": "1.0.0",
  "environment": "development",
  "status": "running"
}

The health endpoint returns:

{
  "status": "healthy"
}
8. Dockerfile

The container image contains:

Python 3.12
     |
     v
Flask
     |
     v
app.py
     |
     v
Port 5000

The application starts using:

CMD ["python", "app.py"]

The Dockerfile also exposes:

EXPOSE 5000
9. Local Testing

Activate the local Python environment:

source .venv/bin/activate

Run:

python -m pytest -q project-12-container-deployment

Result:

3 passed

This validates:

root endpoint
health endpoint
environment information
10. Docker Image Build

Build the image:

docker build \
  -t ci-cd-mastery-project-12:1.0.0 \
  ./project-12-container-deployment

Validate the image:

docker image inspect ci-cd-mastery-project-12:1.0.0 >/dev/null \
  && echo "IMAGE BUILD: PASS"

Expected:

IMAGE BUILD: PASS
11. Container Deployment

Remove any previous container:

docker rm -f project-12-app 2>/dev/null || true

Run the container:

docker run -d \
  --name project-12-app \
  -p 8090:5000 \
  ci-cd-mastery-project-12:1.0.0

The mapping is:

8090:5000

which means:

Host Port 8090
      |
      v
Container Port 5000
      |
      v
Flask Application
12. Container Runtime Validation

Check the container:

docker ps --filter name=project-12-app

Validate the state:

docker inspect project-12-app \
  --format 'status={{.State.Status}} exit_code={{.State.ExitCode}}'

Expected:

status=running exit_code=0

This proves that the application process remains alive.

13. HTTP Validation

Test the root endpoint:

curl -i http://localhost:8090/

Expected:

HTTP/1.1 200 OK

Test the health endpoint:

curl -i http://localhost:8090/health

Expected:

HTTP/1.1 200 OK

Expected response:

{
  "status": "healthy"
}

Automated validation:

curl -fsS http://localhost:8090/health >/dev/null \
  && echo "CONTAINER DEPLOYMENT: PASS"
14. Container Logs

Application logs can be inspected using:

docker logs project-12-app

This provides runtime visibility into the application.

15. Container Restart Validation

Project 12 also verifies that the same container can restart without rebuilding the image.

Stop:

docker stop project-12-app

Start:

docker start project-12-app

Validate:

curl -fsS http://localhost:8090/health

Expected:

{
  "status": "healthy"
}

This demonstrates:

Existing Image
     |
     v
Existing Container
     |
     v
Restart
     |
     v
Application Healthy

No Docker rebuild is required.

16. Real Failure Encountered

Project 12 initially failed during local deployment.

The container was created successfully:

docker run

but:

docker ps

showed no running container.

The container state was:

status=exited
exit_code=0

The logs showed:

Application: ci-cd-mastery-project-08 | Version: 1.0.0 | Environment: development

The original application only printed information and exited.

Therefore:

python app.py
     |
     v
print()
     |
     v
process exits
     |
     v
container exits

This was a real application runtime problem, not a Docker failure.

17. Runtime Fix

The application was changed into an actual Flask HTTP service.

New runtime model:

python app.py
     |
     v
Flask server
     |
     v
0.0.0.0:5000
     |
     v
Container remains running

This allowed the deployment to be tested through HTTP.

18. CI Failure Encountered

After local deployment succeeded, the first GitHub Actions run failed during:

Run tests

The Docker build and deployment stages were never reached.

The reason was that the GitHub runner installed:

pytest

but did not install:

Flask

The local environment already contained Flask, which is why local tests passed.

This exposed a classic CI environment parity problem.

19. CI Fix

The workflow originally contained:

python -m pip install --upgrade pytest

It was corrected to:

python -m pip install --upgrade pytest flask

The GitHub Actions runner now explicitly installs all dependencies required for the tests.

This makes the CI environment reproducible instead of depending on packages that happen to exist locally.

20. GitHub Actions Workflow

Workflow:

.github/workflows/project-12-container-deployment.yml

Pipeline:

Checkout
   |
   v
Install pytest + Flask
   |
   v
Run Tests
   |
   v
Docker Build
   |
   v
Deploy Container
   |
   v
Validate Container Running
   |
   v
Validate HTTP /health
   |
   v
Display Container
   |
   v
Cleanup
21. CI Validation

The final Project 12 GitHub Actions run passed successfully.

Successful run:

31566403592

Workflow:

Project 12 - Container Deployment

The previous failed run:

31525162559

was superseded by the corrected workflow.

Final CI validation:

Checkout                         ✅
Run tests                        ✅
Build Docker image               ✅
Deploy container                 ✅
Validate container is running    ✅
Validate HTTP endpoint           ✅
Display container information    ✅
Cleanup                          ✅
22. Final Validation Matrix
Validation	Result
pytest	✅
Flask dependency	✅
Docker build	✅
Image inspection	✅
Container deployment	✅
Container running	✅
Port mapping	✅
HTTP /	✅
HTTP /health	✅
Container restart	✅
GitHub Actions	✅
Cleanup	✅
23. CI Environment Parity

One of the most important lessons from Project 12 was:

Local Environment
    |
    +-- pytest
    +-- Flask
    |
    v
Tests PASS

while initially:

GitHub Runner
    |
    +-- pytest
    +-- Flask missing
    |
    v
Tests FAIL

The corrected pipeline explicitly installs:

python -m pip install --upgrade pytest flask

Therefore:

Local Dependencies
        ≈
CI Dependencies

This is an important DevOps practice.

24. Production Consideration

The Flask development server is intentionally used for this learning project.

It is not a production-grade application server.

The development server itself reports that it should not be used for production.

A production deployment would normally use a production WSGI server such as:

Application
    |
    v
Gunicorn / uWSGI
    |
    v
Container
    |
    v
Load Balancer / Service

That topic will be addressed later in the CI/CD mastery progression.

25. Project 12 vs Project 11

Project 11 focused on:

Build Once
     |
     v
Promote
     |
     +-- Staging
     |
     +-- Production

Project 12 focuses on:

Approved Image
     |
     v
Container Deployment
     |
     v
Runtime Validation
     |
     v
HTTP Traffic

Therefore Project 12 is the bridge from artifact management to runtime deployment.

26. Interview Questions
Q1. What is the difference between a Docker image and container?

A Docker image is the packaged application artifact.

A container is a runtime instance created from that image.

Image
  |
  v
Container
Q2. Why isn't docker build enough?

A successful build only proves that Docker successfully created the image.

It does not prove:

the application starts
the process stays alive
ports are configured correctly
the application accepts traffic
the application is healthy
Q3. What does -p 8090:5000 mean?

It maps:

Host:      8090
Container: 5000

Therefore:

curl localhost:8090
       |
       v
Docker
       |
       v
Container:5000
       |
       v
Flask
Q4. Why must Flask listen on 0.0.0.0?

If the application only listens on:

127.0.0.1

inside the container, external traffic through Docker's port mapping may not reach it.

Listening on:

0.0.0.0

allows the application to accept connections through the container's network interfaces.

Q5. Why did the first container exit?

The original application performed a print() operation and then terminated.

Docker containers normally run as long as their main process runs.

Therefore:

Main process exits
      ↓
Container exits

The application had to become a long-running HTTP service.

Q6. What does exit code 0 mean?

Exit code 0 normally means the process terminated successfully.

It does not mean that a long-running service deployment was successful.

In our case:

exit_code=0
status=exited

was evidence that the application simply finished execution.

Q7. Why should CI explicitly install dependencies?

CI runners should be reproducible and should not depend on packages accidentally installed in another environment.

Explicit dependencies reduce:

environment drift
"works on my machine" problems
unpredictable CI failures
Q8. What is runtime validation?

Runtime validation proves that the built artifact can actually operate as expected.

Project 12 validates:

Build
 ↓
Run
 ↓
Container running
 ↓
HTTP request
 ↓
HTTP response
Q9. How would you improve this for production?

A production implementation could add:

production WSGI server
Docker HEALTHCHECK
resource limits
non-root user
read-only filesystem
structured logging
vulnerability scanning
secrets management
orchestration with Kubernetes
readiness/liveness probes
centralized monitoring
27. Git History

Project 12 was completed on:

project-12-container-deployment

Final commits:

0ebc29d ci(project-12): install Flask for CI tests
3c66da6 ci(project-12): add container deployment validation

Repository state after completion:

working tree clean
28. Completion Status
PROJECT 12 — COMPLETE

Implementation:       ✅
Local Testing:        ✅
Docker Build:         ✅
Container Deployment: ✅
Runtime Validation:   ✅
HTTP Validation:      ✅
Restart Validation:   ✅
CI/CD:                ✅
Failure Diagnosis:    ✅
Commit:               ✅
Push:                 ✅
Interview:            ✅
29. Key Takeaway

Project 12 establishes an important CI/CD principle:

A container image is not considered deployable merely because it builds successfully. The runtime must also be validated.

The complete deployment proof is:

pytest
   ↓
Docker Build
   ↓
docker run
   ↓
Container = running
   ↓
Port = reachable
   ↓
HTTP /health = 200
   ↓
Deployment = PASS

Project 12 therefore establishes the foundation for the next stage of the roadmap: container health checks and production-oriented runtime validation.
