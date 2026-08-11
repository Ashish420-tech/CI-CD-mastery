 Project 09 — Docker Image Security Scanning

## Objective

Implement vulnerability scanning as a security gate in the container CI pipeline.

## Enterprise Problem

A Docker image can build successfully while containing vulnerable OS packages or application dependencies.

Project 09 adds security validation before the container artifact progresses through CI/CD.

## Pipeline

Application
→ pytest
→ Docker build
→ Trivy vulnerability scan
→ Security gate
→ Approved image

HIGH/CRITICAL vulnerabilities cause CI failure.

## Technology

- Docker
- Trivy
- GitHub Actions
- Python
- pytest

## Local Validation

```bash
python -m pytest -q

docker build \
  -t ci-cd-mastery-project-09:local \
  .

trivy image \
  --severity HIGH,CRITICAL \
  --ignore-unfixed \
  --exit-code 1 \
  ci-cd-mastery-project-09:local
Interview Questions
What problem does container image scanning solve?
What is a CVE?
Image scanning vs dependency scanning?
Why block HIGH/CRITICAL vulnerabilities?
Why use ignore-unfixed?
Why scan before registry publication?
EOF

### Verify the copied application

```bash
cd ~/CI-CD-mastery/project-09-image-security-scanning

python -m pytest -q

cd ~/CI-CD-mastery

docker build \
  -t ci-cd-mastery-project-09:local \
  ./project-09-image-security-scanning
