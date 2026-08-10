# Project 03 — Branch & Path-Based CI

## Project Overview

This project is part of the **100 CI/CD Pipeline Mastery** portfolio.

The objective is to understand how GitHub Actions controls workflow execution using:

- Push events
- Pull Request events
- Branch filters
- Path filters
- Workflow discovery
- CI execution conditions
- Workflow troubleshooting

This project is intentionally independent from the other CI/CD projects.

---

## Project Objective

Project 01 taught basic CI execution.

Project 02 taught Pull Request CI.

Project 03 focuses on answering:

> **When should GitHub Actions run CI, and when should it not run?**

The main concepts are:

```text
Git Event
    ↓
Event Type
    ↓
Branch Filter
    ↓
Path Filter
    ↓
Workflow
    ↓
Workflow Run
    ↓
Job
    ↓
Steps
    ↓
Check

Project Architecture
Developer
    ↓
Git Branch
    ↓
Git Push / Pull Request
    ↓
GitHub Event
    ↓
Branch Filter
    ↓
Path Filter
    ↓
GitHub Actions
    ↓
CI Job
    ↓
Python Tests
    ↓
PASS / FAIL
Repository Structure

Current Project 03 structure:

project-03-branch-path-ci/
├── .gitignore
├── app.py
├── tests/
│   └── test_app.py
└── .github/
    └── workflows/
        └── project-03-ci.yml

The Python application is intentionally minimal because the primary objective is learning GitHub Actions trigger behavior.

Application

The application contains a simple addition function:

def add(a, b):
    return a + b

The test verifies:

assert add(2, 3) == 5

The application exists only to provide a test target for CI.

Local Testing

Project 03 uses its own Python virtual environment.

Python version:

Python 3.12.3

pytest version:

pytest 9.1.1

The local test was executed using:

python -m pytest

Result:

collected 1 item

tests/test_app.py . [100%]

1 passed
Why python -m pytest?

The initial pytest command failed because the shell was still referencing an old Project 01 virtual environment.

A Project 03-specific virtual environment was then created.

The direct Python import test confirmed:

python -c "import app; print(app.add(2, 3))"

Result:

5

Running:

python -m pytest

then successfully executed the test.

This demonstrated an important troubleshooting principle:

First establish a working local test baseline before troubleshooting CI.

Git Branch Strategy

Project 03 is maintained as an independent branch:

project-03-branch-path-ci

The branch has its own root commit:

10db371 feat(project-03): initialize branch and path CI project

The CI workflow was added in:

881fbd6 ci(project-03): add initial push CI workflow

Project 03 does not depend on the Project 01 or Project 02 branch histories.

Initial CI Workflow

The initial workflow is located at:

.github/workflows/project-03-ci.yml

Current trigger:

on:
  push:

Current workflow:

name: Project 03 CI

on:
  push:

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Setup Python
        uses: actions/setup-python@v5
        with:
          python-version: "3.12"

      - name: Install pytest
        run: python -m pip install pytest

      - name: Run tests
        working-directory: project-03-branch-path-ci
        run: python -m pytest
Push Event

The first workflow experiment used:

on:
  push:

This means the workflow is configured to respond to GitHub push events.

Conceptually:

git commit
    ↓
git push
    ↓
GitHub receives push event
    ↓
Workflow trigger evaluation
    ↓
Project 03 CI
Baseline Push Experiment
Experiment

The Project 03 workflow was pushed to GitHub.

Command used:

git push

GitHub created the following workflow run:

Workflow:
Project 03 CI

Branch:
project-03-branch-path-ci

Event:
push

Run ID:
31376293724

The run completed successfully.

Job:

test

Result:

PASS

Duration:

11 seconds

The run was also verified using:

gh run list --limit 5

and:

gh run view 31376293724
Important Distinction

A workflow being triggered does not automatically mean that the workflow succeeded.

We distinguish:

Event
  ↓
Workflow triggered
  ↓
Workflow run created
  ↓
Job executed
  ↓
Steps executed
  ↓
PASS / FAIL

For the baseline experiment:

Push event          ✅
Workflow triggered  ✅
Job executed        ✅
Tests passed        ✅
Branch Filters

Branch filters restrict workflow execution based on branch names.

Example:

on:
  push:
    branches:
      - project-03-*

The branch name is evaluated against the configured pattern.

For example:

project-03-feature

matches:

project-03-*

But:

feature/project-03-trigger-test

does not match:

project-03-*

because the actual branch name starts with:

feature/

This distinction will be verified experimentally later in the project.

Path Filters

Path filters restrict workflow execution based on changed files.

Example:

on:
  push:
    paths:
      - "project-03-branch-path-ci/**"

The purpose is to prevent Project 03 CI from running when unrelated files are changed.

This will be tested through dedicated experiments.

Pull Request Events

Project 03 will also demonstrate:

on:
  pull_request:

Pull Request filtering will be studied separately from push.

We will determine:

What branch is evaluated
What event occurred
How branch filters behave
How path filters behave
Why a PR workflow may or may not trigger
Planned Trigger Experiments

The following experiments are required before Project 03 can be considered complete.

Experiment 1 — Matching Branch

Create a branch matching the configured branch pattern.

Expected:

CI RUNS

Actual result:

TODO — experiment not completed yet
Experiment 2 — Non-Matching Branch

Create a branch that does not match the configured branch filter.

Expected:

CI DOES NOT RUN

Actual result:

TODO — experiment not completed yet
Experiment 3 — Matching Path

Modify a file under:

project-03-branch-path-ci/

Expected:

CI RUNS

Actual result:

TODO — experiment not completed yet
Experiment 4 — Non-Matching Path

Modify a file outside the configured Project 03 path.

Expected:

CI DOES NOT RUN

Actual result:

TODO — experiment not completed yet
Experiment 5 — Pull Request

Create a Pull Request involving Project 03.

Expected:

pull_request
    ↓
GitHub Actions

Actual result:

TODO — experiment not completed yet
Failure Laboratory

A deliberate workflow trigger failure must be created.

The failure laboratory will investigate cases such as:

Expected:
CI runs

Actual:
CI does not run

Possible causes:

Incorrect branch pattern
Incorrect path pattern
Wrong event
Workflow location problem
Workflow not registered
YAML configuration problem
Repository configuration
Incorrect expectation

The failure must be diagnosed before being fixed.

Troubleshooting Methodology

When CI does not run:

No CI run
    ↓
Was workflow discovered?
    ↓
Is workflow enabled?
    ↓
Was the expected event generated?
    ↓
Does branch filter match?
    ↓
Does path filter match?
    ↓
Does workflow exist in the relevant branch/commit?
    ↓
Are repository Actions settings correct?
    ↓
Why did GitHub skip it?

Useful commands:

gh workflow list
gh run list
gh pr checks <PR_NUMBER>
gh pr view <PR_NUMBER>
gh run view <RUN_ID>
gh run view <RUN_ID> --log-failed
Technologies Used
Git
GitHub
GitHub Actions
Python 3.12
pytest
GitHub CLI
Current CI/CD Mastery Progress
Project 01 — Basic CI
        ↓
Project 02 — Pull Request CI
        ↓
Project 03 — Branch & Path-Based CI
        ↓
Project 04 — Matrix CI
        ↓
Project 05 — CI Artifacts
        ↓
Project 06 — Test Reports
        ↓
Project 07 — Code Quality CI
        ↓
Project 08 — Dependency CI
        ↓
Project 09 — Docker Image CI

Current project:

PROJECT 03 — BRANCH & PATH-BASED CI

Status:

IN PROGRESS
Lessons Learned So Far
Git branches and Python virtual environments are independent concepts.
A Git branch can have its own independent history.
.venv should not be committed to Git.
Establish a working local test before troubleshooting CI.
git push generates a GitHub push event.
on: push allows a workflow to respond to push events.
A workflow being triggered and a workflow succeeding are different things.
Workflow discovery depends on the repository-level .github/workflows/ location.
Branch filters evaluate branch names against configured patterns.
feature/project-03-trigger-test does not match project-03-*.
Interview Questions
What is a GitHub Actions event?
What is the difference between push and pull_request?
What does branches do?
What does paths do?
What is a branch filter?
What is a path filter?
What happens if a branch does not match?
What happens if a path does not match?
How does GitHub decide whether to start a workflow?
Why might a workflow not trigger even though the YAML looks correct?
How do you troubleshoot a workflow that does not run?
What is the difference between branch filtering and path filtering?
Can push and pull_request trigger the same workflow?
Why should large repositories use path filters?
How can path filters reduce CI cost?
What is the difference between workflow configuration and workflow execution?
What is the difference between "workflow skipped" and "workflow failed"?
What does gh workflow list tell you?
What does gh run list tell you?
What does gh pr checks tell you?
What is the difference between a workflow run and a check?
Explain the complete event → filter → workflow → job → step → check lifecycle.
How would you troubleshoot a PR where no CI check appears?
How would you troubleshoot CI triggering for the wrong branch?
How would you troubleshoot CI triggering for unrelated file changes?
Completion Status
[✓] Project branch created
[✓] Repository state verified
[✓] CI workflow created
[✓] Push trigger understood
[ ] Pull Request trigger understood
[ ] Branch filtering implemented
[ ] Path filtering implemented
[ ] Matching branch tested
[ ] Non-matching branch tested
[ ] Matching path tested
[ ] Non-matching path tested
[ ] Pull Request tested
[✓] CI execution verified
[ ] Deliberate trigger failure created
[ ] Failure diagnosed
[ ] Root cause understood
[ ] Workflow fixed
[ ] CI verified again
[✓] Git history clean
[ ] README finalized
[ ] Interview questions answered
[ ] Trigger/filter lifecycle explained independently
Project Status

Project 03 is NOT COMPLETE yet.

The baseline push workflow is working.

The next phase is to implement and experimentally verify:

push
  ↓
branches
  ↓
paths
  ↓
pull_request
  ↓
failure laboratory
  ↓
troubleshooting mastery
