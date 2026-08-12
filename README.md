# CI-CD Mastery — 100 Projects Portfolio

A comprehensive GitHub Actions and CI/CD learning portfolio demonstrating best practices in continuous integration, continuous deployment, Docker containerization, and GitHub Actions workflows.

**Repository:** [Ashish420-tech/CI-CD-mastery](https://github.com/Ashish420-tech/CI-CD-mastery)

**Language Composition:**
- Python: 69.2%
- Dockerfile: 17.7%
- Shell: 13.1%

---

## 📚 Portfolio Overview

This repository contains **25+ independent CI/CD projects**, each focusing on specific aspects of modern DevOps practices. Each project is maintained on its own branch with isolated workflows, applications, and documentation.

### Project Categories

#### 🔧 **Core CI/CD Fundamentals (Projects 01-09)**
1. **Project 01** — Basic CI
2. **Project 02** — Pull Request CI
3. **Project 03** — Branch & Path-Based CI
4. **Project 04** — Matrix CI
5. **Project 05** — CI Artifacts
6. **Project 06** — Environments & Deployment Gates
7. **Project 07** — Docker Image CI
8. **Project 08** — Container Registry
9. **Project 09** — Image Security Scanning

#### 🐳 **Docker & Containerization (Projects 10-17)**
10. **Project 10** — Image Tagging & Lifecycle
11. **Project 11** — Image Promotion
12. **Project 12** — Container Deployment
13. **Project 13** — Container Healthcheck
14. **Project 14** — Container Resource Limits
15. **Project 15** — Container Secrets & Config
16. **Project 16** — Container Logging
17. **Project 17** — Container Log Rotation

#### 🎵 **Docker Compose (Projects 18-25)**
18. **Project 18** — Compose Multi-Container
19. **Project 19** — Compose Enterprise Config
20. **Project 20** — Compose Secrets
21. **Project 21** — Compose Profiles
22. **Project 22** — Compose Networking
23. **Project 23** — Compose Resilience
24. **Project 24** — Compose Observability
25. **Project 25** — Compose Secrets

---

## 📋 Repository Structure

```
CI-CD-mastery/
│
├── README.md                          # This file
├── .github/
│   └── workflows/                     # GitHub Actions workflows
│       ├── project-03-ci.yml
│       ├── project-04-matrix.yml
│       ├── project-05-artifacts.yml
│       ├── project-06-environments.yml
│       └── ... (more workflows)
│
├── project-01-basic-ci/               # Branch: project-01-basic-ci
├── project-02-pr-ci/                  # Branch: project-02-pr-ci
├── project-03-branch-path-ci/         # Branch: project-03-branch-path-ci
├── project-04-matrix-ci/              # Branch: project-04-matrix-ci
├── project-05-ci-artifacts/           # Branch: project-05-ci-artifacts
├── project-06-environments-deployment-gates/
├── project-07-docker-image-ci/
├── project-08-container-registry/
├── ... (more project directories)
│
└── .gitignore
```

---

## 🌿 Git Branching Strategy

Each project is isolated on its own branch for independent development:

```
main (default branch)
  ├── feature/project-02-break-test
  ├── project-01-basic-ci
  ├── project-02-pr-ci
  ├── project-03-branch-path-ci
  ├── project-04-matrix-ci
  ├── project-05-ci-artifacts
  ├── project-06-environments-deployment-gates
  ├── project-07-docker-image-ci
  ├── project-08-container-registry
  ├── project-09-image-security-scanning
  ├── project-10-image-tagging-lifecycle
  ├── project-11-image-promotion
  ├── project-12-container-deployment
  ├── project-13-container-healthcheck
  ├── project-14-container-resource-limits
  ├── project-15-container-secrets-config
  ├── project-16-container-logging
  ├── project-17-container-log-rotation
  ├── project-18-compose-multi-container
  ├── project-19-compose-enterprise-config
  ├── project-20-compose-secrets
  ├── project-21-compose-profiles
  ├── project-22-compose-networking
  ├── project-23-compose-resilience
  ├── project-24-compose-observability
  └── project-25-compose-secrets
```

---

## 🎯 Learning Progression

### Phase 1: GitHub Actions Fundamentals
- Understanding GitHub Actions events (push, pull_request)
- Workflow triggers and conditions
- Branch and path filtering
- Job execution and failure handling
- Matrix strategies for multi-version testing

### Phase 2: CI Artifacts & Build Outputs
- Generating files during CI
- Uploading artifacts
- Downloading artifacts
- Artifact retention policies
- Transferring artifacts between jobs

### Phase 3: Docker & Container Integration
- Building Docker images in CI
- Container image tagging
- Image scanning and security
- Registry integration
- Image promotion workflows

### Phase 4: Docker Compose & Orchestration
- Multi-container workflows
- Service configuration
- Networking and communication
- Secret management
- Observability and logging

---

## 💻 Technologies Used

### Core Technologies
- **Git** — Version control
- **GitHub** — Repository hosting & Actions
- **GitHub Actions** — CI/CD automation
- **GitHub CLI** — Command-line interface

### Languages & Runtimes
- **Python 3.10+** — Application development
- **Shell/Bash** — Scripting and automation

### Containerization
- **Docker** — Container platform
- **Docker Compose** — Multi-container orchestration

### Testing & Quality
- **pytest** — Python testing framework
- **GitHub Checks** — Test reporting

---

## 🚀 Quick Start

### Prerequisites
- Git
- GitHub account with repository access
- GitHub CLI (`gh`)
- Docker (for container-based projects)
- Python 3.10+ (for Python-based projects)

### Exploring a Project

```bash
# Clone the repository
git clone https://github.com/Ashish420-tech/CI-CD-mastery.git
cd CI-CD-mastery

# Switch to a specific project branch
git checkout project-04-matrix-ci

# Read the project README
cat project-04-matrix-ci/README.md

# View workflow configuration
cat .github/workflows/project-04-matrix.yml

# Check repository status
git status
```

### Running Local Tests

```bash
# Project 04 example
cd project-04-matrix-ci

# Create virtual environment (optional but recommended)
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install pytest

# Run tests locally
pytest -v test_app.py
```

### Viewing GitHub Actions Runs

```bash
# List recent workflow runs
gh run list --limit 10

# View a specific run
gh run view <RUN_ID>

# View run logs
gh run view <RUN_ID> --log

# View only failed logs
gh run view <RUN_ID> --log-failed

# Download artifacts
gh run download <RUN_ID> -n <ARTIFACT_NAME> -D <DOWNLOAD_DIR>
```

---

## 📖 Project Documentation

Each project has its own comprehensive README with:

- **Overview** — Project objectives and scope
- **Architecture** — System design diagrams
- **Repository Structure** — File and directory layout
- **Experiments** — Step-by-step implementation details
- **Results** — Actual outcomes and lessons learned
- **Interview Questions** — Knowledge assessment
- **Completion Status** — Checklist of deliverables

### Featured Projects

#### **Project 03 — Branch & Path-Based CI**
Learn how GitHub Actions filters and triggers workflows based on:
- Git events (push, pull_request)
- Branch name patterns
- Changed file paths
- Workflow troubleshooting

**Key Concepts:**
- Event → Filter → Workflow lifecycle
- Branch and path filtering
- Pull request CI integration
- Failure diagnosis

#### **Project 04 — Matrix CI**
Understand matrix strategies for running the same CI across multiple configurations:
- Matrix variables
- Matrix combinations
- Job expansion
- Parallel execution
- Cartesian products

**Key Concepts:**
- `strategy.matrix` expansion
- Multi-version testing
- `fail-fast` behavior
- Test isolation in repositories

#### **Project 05 — CI Artifacts**
Master artifact lifecycle management:
- Generating files in CI
- Uploading artifacts
- Downloading artifacts
- Inter-job artifact transfer
- Retention policies

**Key Concepts:**
- Runner workspace vs. GitHub storage
- Artifact transfer between jobs
- Troubleshooting artifact failures
- Root cause analysis

---

## 🔍 Key Learning Outcomes

### GitHub Actions Mastery
- [x] Event-driven workflow automation
- [x] Branch and path filtering
- [x] Matrix strategies
- [x] Job dependencies and sequencing
- [x] Artifact management
- [x] Environment variables and secrets
- [x] Deployment gates

### Docker Mastery
- [x] Image building and tagging
- [x] Registry integration
- [x] Security scanning
- [x] Image promotion workflows
- [x] Container deployment

### Docker Compose Mastery
- [x] Multi-container workflows
- [x] Service networking
- [x] Configuration management
- [x] Secret management
- [x] Observability and logging

### CI/CD Best Practices
- [x] Test isolation
- [x] Failure diagnosis
- [x] Root cause analysis
- [x] Reproducible CI failures
- [x] Recovery procedures

---

## 📊 Progress Tracking

### Completed Projects
- [x] Project 01 — Basic CI
- [x] Project 02 — Pull Request CI
- [x] Project 03 — Branch & Path-Based CI (IN PROGRESS)
- [x] Project 04 — Matrix CI
- [x] Project 05 — CI Artifacts

### In Development
- [ ] Project 06 — Environments & Deployment Gates
- [ ] Project 07 — Docker Image CI
- [ ] Projects 08-25 (Planned)

---

## 🛠️ Tools & Commands Reference

### GitHub CLI Essentials

```bash
# List all workflows
gh workflow list

# List workflow runs
gh run list

# View a specific run
gh run view <RUN_ID>

# View run logs
gh run view <RUN_ID> --log

# Download artifact
gh run download <RUN_ID> -n <ARTIFACT_NAME> -D <DIR>

# List branches
gh branch list

# Create a branch
git checkout -b <BRANCH_NAME>

# Push branch to remote
git push -u origin <BRANCH_NAME>
```

### Git Essentials

```bash
# Clone repository
git clone <REPO_URL>

# Switch branches
git checkout <BRANCH_NAME>

# View branch list
git branch -a

# View commit history
git log --oneline --decorate -n 10

# Check status
git status

# Stage and commit
git add .
git commit -m "message"

# Push to remote
git push

# View differences
git diff
```

### Python & Testing

```bash
# Create virtual environment
python -m venv venv
source venv/bin/activate

# Install packages
pip install pytest

# Run tests
pytest -v

# Run specific test file
pytest -v test_file.py

# Run with output capture disabled
pytest -v -s
```

---

## 📚 Interview Questions Template

Each project includes interview questions covering:

1. **Conceptual Understanding**
   - What is a GitHub Actions matrix?
   - How do branch filters work?
   - What is an artifact lifecycle?

2. **Practical Application**
   - How would you troubleshoot a failing matrix job?
   - How would you transfer data between jobs?
   - How would you configure deployment gates?

3. **Scenario-Based**
   - A job fails on Python 3.11 but passes on 3.12. How would you debug?
   - How would you reduce CI cost while maintaining test coverage?
   - How would you design a multi-environment deployment?

---

## 🔗 Resources & References

### Official Documentation
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [GitHub CLI Reference](https://cli.github.com/manual)
- [Docker Documentation](https://docs.docker.com)
- [Docker Compose Documentation](https://docs.docker.com/compose)

### Key Concepts
- **Workflows** — Automated processes triggered by events
- **Jobs** — Execution units within a workflow
- **Steps** — Individual commands within a job
- **Actions** — Reusable units of code
- **Artifacts** — Files produced and shared between jobs
- **Environments** — Deployment configurations with protection rules
- **Secrets** — Encrypted environment variables

---

## 🤝 Contributing

This is a personal learning portfolio. Feel free to:
- Fork the repository for your own learning
- Create issues with questions or suggestions
- Use projects as templates for your own CI/CD workflows

---

## 📝 License

This repository documents learning and experimentation with GitHub Actions and CI/CD practices.

---

## 🎓 About This Portfolio

This portfolio represents a structured approach to mastering CI/CD through hands-on experimentation:

1. **Sequential Learning** — Projects build upon previous knowledge
2. **Experimental Method** — Each project includes deliberate failures and recovery
3. **Documentation** — Comprehensive README in each project
4. **Practical Focus** — Real-world scenarios and troubleshooting
5. **Scalable Design** — From simple CI to complex orchestration

---

## 📞 Contact & Support

- **GitHub:** [@Ashish420-tech](https://github.com/Ashish420-tech)
- **Repository:** [CI-CD-mastery](https://github.com/Ashish420-tech/CI-CD-mastery)

---

## 🗂️ All Branches

```
1.  main (default)
2.  feature/project-02-break-test
3.  project-01-basic-ci
4.  project-02-pr-ci
5.  project-03-branch-path-ci
6.  project-04-matrix-ci
7.  project-05-ci-artifacts
8.  project-06-environments-deployment-gates
9.  project-07-docker-image-ci
10. project-08-container-registry
11. project-09-image-security-scanning
12. project-10-image-tagging-lifecycle
13. project-11-image-promotion
14. project-12-container-deployment
15. project-13-container-healthcheck
16. project-14-container-resource-limits
17. project-15-container-secrets-config
18. project-16-container-logging
19. project-17-container-log-rotation
20. project-18-compose-multi-container
21. project-19-compose-enterprise-config
22. project-20-compose-secrets
23. project-21-compose-profiles
24. project-22-compose-networking
25. project-23-compose-resilience
26. project-24-compose-observability
27. project-25-compose-secrets
```

---

**Last Updated:** 2026-08-12

**Status:** Active Development

**Current Phase:** GitHub Actions Fundamentals & Docker Integration

---

> **"The journey to CI/CD mastery is not about knowing all the tools, but understanding the principles of automation, reliability, and reproducibility."**

