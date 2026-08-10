# Project 01 — Basic CI Pipeline

## 📌 Overview

This project demonstrates a foundational Continuous Integration (CI) pipeline using **GitHub Actions**.

The objective is to understand the complete CI lifecycle:

```text
Developer
    ↓
Git Push / Pull Request
    ↓
GitHub Actions
    ↓
Ubuntu Runner
    ↓
Checkout Source Code
    ↓
Setup Python
    ↓
Install Dependencies
    ↓
Run Automated Tests
    ↓
CI Success / Failure
🎯 Objectives

By completing this project, I learned how to:

Create a Git-based CI workflow
Create GitHub Actions workflows
Configure workflow triggers
Use GitHub-hosted runners
Checkout source code
Configure Python in a CI environment
Install application dependencies
Execute automated tests
Analyze CI failures
Verify successful pipeline execution
Manage CI configuration as code
🏗️ Project Structure
project-01-basic-ci/
│
├── .github/
│   └── workflows/
│       └── ci.yml
│
├── tests/
│   └── test_app.py
│
├── app.py
├── requirements.txt
└── README.md
🧩 Application

The project contains a simple Python application with an add() function.

app.py
def add(a, b):
    return a + b


def main():
    print(f"2 + 3 = {add(2, 3)}")


if __name__ == "__main__":
    main()
🧪 Automated Testing

The application is tested using pytest.

Tests validate:

Positive number addition
Negative number addition

Example:

def test_add():
    assert add(2, 3) == 5


def test_add_negative_numbers():
    assert add(-2, -3) == -5

Local validation:

python -m pytest -v

Expected result:

2 passed
⚙️ CI Pipeline

The pipeline is defined in:

.github/workflows/ci.yml
Workflow
name: Project 01 - Basic CI

on:
  push:
    branches:
      - project-01-basic-ci

  pull_request:
    branches:
      - project-01-basic-ci

jobs:
  test:
    name: Run Python Tests
    runs-on: ubuntu-latest

    steps:
      - name: Checkout source code
        uses: actions/checkout@v4

      - name: Setup Python
        uses: actions/setup-python@v5
        with:
          python-version: "3.12"

      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          python -m pip install -r requirements.txt

      - name: Run tests
        run: |
          python -m pytest -v
🔄 Pipeline Execution Flow
                  Git Push
                     │
                     ▼
              GitHub Repository
                     │
                     ▼
             GitHub Actions
                     │
                     ▼
              Ubuntu Runner
                     │
                     ▼
             Checkout Code
                     │
                     ▼
             Setup Python 3.12
                     │
                     ▼
          Install Dependencies
                     │
                     ▼
             Run pytest tests
                     │
              ┌──────┴──────┐
              │             │
           PASS           FAIL
              │             │
              ▼             ▼
          CI SUCCESS     CI FAILURE
🔍 Pipeline Stages
1. Trigger

The workflow executes when code is pushed to:

project-01-basic-ci

It also runs when a pull request targets this branch.

2. Checkout
uses: actions/checkout@v4

The action downloads the repository source code onto the GitHub Actions runner.

3. Setup Python
uses: actions/setup-python@v5

The workflow configures Python 3.12.

4. Install Dependencies
python -m pip install -r requirements.txt

This installs the dependencies required by the application.

5. Run Tests
python -m pytest -v

The automated test suite validates the application.

If a test fails, the CI job fails.

🧠 Important Learning

One issue was intentionally investigated during development.

Initially:

pytest -v

resulted in:

ModuleNotFoundError: No module named 'app'

However:

python -m pytest -v

successfully executed the tests.

Final result:

2 passed

This demonstrated the importance of using the intended Python interpreter and understanding the execution environment.

🧪 Failure Handling

CI pipelines must also be tested under failure conditions.

The test was intentionally changed from:

assert add(2, 3) == 5

to an incorrect expectation:

assert add(2, 3) == 6

Expected pipeline behavior:

Git Push
   ↓
GitHub Actions
   ↓
Run Tests
   ↓
Test Failure
   ↓
Pipeline FAILED ❌

After restoring the correct assertion:

assert add(2, 3) == 5

the pipeline returned to:

Pipeline SUCCESS ✅
🔐 CI Principles Demonstrated

This project demonstrates several fundamental CI principles:

1. Automate validation

Code should be automatically tested after changes.

2. Fail fast

A broken test should prevent the pipeline from being considered successful.

3. Reproducible environment

The CI runner explicitly configures the Python version and dependencies.

4. Pipeline as Code

The CI configuration is stored in Git:

.github/workflows/ci.yml
5. Developer feedback

GitHub Actions provides immediate feedback about whether the change passed validation.

🛠️ Technologies Used
Technology	Purpose
Git	Version control
GitHub	Source-code repository
GitHub Actions	CI automation
Python 3.12	Application runtime
pytest	Automated testing
Ubuntu	CI runner
📊 CI Pipeline Result
Build/Validation:  ✅
Dependencies:      ✅
Automated Tests:   ✅
Tests Passed:      2
Tests Failed:      0
CI Status:         SUCCESS
🎓 Interview Questions
Q1. What is Continuous Integration?

Continuous Integration is the practice of automatically validating code changes when developers integrate changes into a shared repository.

Q2. What triggers this pipeline?

A push to the project-01-basic-ci branch or a pull request targeting that branch.

Q3. What is a GitHub Actions runner?

A runner is the compute environment that executes the workflow jobs.

Q4. Why do we use actions/checkout?

It makes the repository source code available inside the runner.

Q5. What happens when pytest fails?

The workflow step exits with a non-zero status and the CI job becomes failed.

Q6. Why should tests run in CI?

To automatically detect defects before changes progress further through the software delivery lifecycle.

Q7. Why use python -m pytest?

It explicitly invokes pytest through the configured Python interpreter, reducing ambiguity about which Python environment executes the tests.

Q8. Where is the CI pipeline defined?
.github/workflows/ci.yml
🚀 Future Improvements

This project intentionally implements only basic CI.

Future projects will progressively introduce:

Pull Request validation
Build artifacts
Docker
Container registries
Jenkins
AWS
ECR
Kubernetes
EKS
Helm
Security scanning
SAST
Dependency scanning
SBOM
Image signing
GitOps
Argo CD
Blue/Green deployments
Canary deployments
Production deployment strategies
🏆 CI/CD Mastery Progress
Project 01 / 100

████████████████████████████████████████ 100%

Basic CI Pipeline       ✅
GitHub Actions          ✅
Automated Testing       ✅
CI Failure Analysis     ✅
Pipeline Recovery       ✅
📚 Repository

This project is part of my 100 CI/CD Pipeline Mastery journey.

Repository:

CI/CD Mastery — Ashish Mondal

Branch:

project-01-basic-ci

### Then commit it

From the repository root:

```bash
cd ~/CI-CD-mastery

Check you're still on the correct branch:

git branch

You should see:

* project-01-basic-ci

Then:

git add project-01-basic-ci/README.md
git commit -m "docs(project-01): add CI pipeline documentation"
git push
