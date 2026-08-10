# Project 04 — Matrix CI

## Overview

Project 04 demonstrates how to use **GitHub Actions Matrix Strategy** to run the same CI process across multiple Python versions.

The project uses a minimal Python application with `pytest` and GitHub Actions.

The main objective was to understand how GitHub Actions expands one matrix definition into multiple independent job combinations.

---

## Objective

The objectives of this project were to understand:

* GitHub Actions Matrix Strategy
* `strategy.matrix`
* Matrix variables
* Matrix combinations
* Job expansion
* Running CI against multiple Python versions
* Parallel matrix job execution
* GitHub Actions job visualization
* Matrix failure troubleshooting
* CI test isolation
* `fail-fast` behavior

---

# Why Matrix CI Matters

Without matrix CI, we would need to manually define separate jobs for every Python version.

For example:

```yaml
jobs:
  python-311:
    ...

  python-312:
    ...
```

This duplicates CI configuration.

With a matrix:

```yaml
strategy:
  matrix:
    python-version: ["3.11", "3.12"]
```

the job is defined once and GitHub Actions expands it into multiple combinations.

Conceptually:

```text
One CI Job Definition
        |
        v
Matrix Strategy
        |
        +------------------+
        |                  |
        v                  v
Python 3.11          Python 3.12
        |                  |
        v                  v
      pytest             pytest
        |                  |
        v                  v
      PASS               PASS
```

---

# Architecture

```text
Developer
    |
    | git push
    v
GitHub Repository
    |
    v
GitHub Actions
    |
    v
Project 04 Matrix CI
    |
    v
strategy.matrix
    |
    +---------------------+
    |                     |
    v                     v
Python 3.11          Python 3.12
    |                     |
    v                     v
pytest                pytest
    |                     |
    v                     v
  PASS                  PASS
```

---

# Repository Structure

```text
CI-CD-mastery/
│
├── .github/
│   └── workflows/
│       ├── project-03-ci.yml
│       └── project-04-matrix.yml
│
└── project-04-matrix-ci/
    ├── app.py
    └── test_app.py
```

The Project 04 application is intentionally simple because the purpose of this project is GitHub Actions Matrix CI rather than Python application development.

---

# Git Branching Model

Project branch:

```text
project-04-matrix-ci
```

Remote:

```text
origin/project-04-matrix-ci
```

Project 04 was developed on its own project branch.

> Note: The branch was created from the existing Project 03 branch rather than using an orphan branch. The project was nevertheless kept isolated at the application/workflow level.

---

# Application

## app.py

The application contains a simple addition function:

```python
def add(a, b):
    return a + b
```

## test_app.py

The test verifies:

```python
assert add(2, 3) == 5
```

The local test was successfully executed using:

```bash
pytest -v
```

---

# First Matrix

The initial matrix used two Python versions:

```yaml
strategy:
  matrix:
    python-version: ["3.11", "3.12"]
```

GitHub Actions conceptually expands this into:

```text
test (3.11)
test (3.12)
```

Therefore:

```text
2 Python versions
        ↓
2 matrix combinations
        ↓
2 matrix jobs
```

---

# Matrix Variable

The workflow uses:

```yaml
${{ matrix.python-version }}
```

This value changes according to the matrix combination.

For example:

```text
Matrix Job              matrix.python-version
------------------------------------------------
test (3.11)             3.11
test (3.12)             3.12
```

The value is then passed to:

```yaml
uses: actions/setup-python@v5
with:
  python-version: ${{ matrix.python-version }}
```

Therefore each matrix job installs and uses its corresponding Python version.

---

# Matrix Expansion

The most important concept learned in this project is:

> One matrix definition can be expanded by GitHub Actions into multiple job executions.

For:

```yaml
python-version: ["3.11", "3.12"]
```

GitHub creates:

```text
Job 1 → Python 3.11
Job 2 → Python 3.12
```

The same CI steps are executed independently for each combination.

---

# Experiment 1 — Two Python Versions

## Configuration

```yaml
strategy:
  matrix:
    python-version: ["3.11", "3.12"]
```

## Expected

Two matrix jobs:

```text
test (3.11)
test (3.12)
```

## Actual Result

Both matrix jobs completed successfully.

The matrix workflow successfully executed CI against:

```text
Python 3.11
Python 3.12
```

---

# Experiment 2 — Matrix Job Observation

The workflow was inspected using GitHub CLI.

Command:

```bash
gh run list --limit 5
```

A successful Project 04 Matrix CI run was observed.

Run ID:

```text
31385596637
```

The matrix jobs were inspected using:

```bash
gh run view 31385596637 --json jobs --jq '.jobs[] | {name:.name,status:.status,conclusion:.conclusion}'
```

The result showed two jobs corresponding to the two Python versions.

This confirmed that GitHub Actions was actually expanding the matrix rather than simply running one job.

---

# Matrix Failure Laboratory

A real CI failure occurred during the first Project 04 matrix execution.

The first matrix run was:

```text
Run ID: 31378469834
```

The matrix jobs were:

```text
test (3.11) → FAILURE
test (3.12) → CANCELLED
```

---

# Failure Investigation

The failing matrix job was identified with:

```bash
gh run view 31378469834 --json jobs --jq '.jobs[] | {name:.name,status:.status,conclusion:.conclusion}'
```

The result showed:

```text
test (3.11) → failure
test (3.12) → cancelled
```

The 3.11 job failure was then traced to the test collection process.

The relevant error was:

```text
ImportError while importing test module
project-03-branch-path-ci/tests/test_app.py

ModuleNotFoundError: No module named 'app'
```

---

# Root Cause

The failure was not caused by Python 3.11.

The actual problem was that the repository contains multiple projects.

The workflow originally executed:

```bash
pytest -v
```

This caused pytest to search the repository recursively.

As a result, pytest discovered the Project 03 test:

```text
project-03-branch-path-ci/tests/test_app.py
```

instead of running only the Project 04 test.

Project 03's test attempted:

```python
from app import add
```

but the corresponding application was not available in the expected Python import path.

Therefore the matrix job failed during test collection.

---

# Fix

The CI test command was changed from:

```bash
pytest -v
```

to:

```bash
pytest -v project-04-matrix-ci/test_app.py
```

This explicitly isolates the Project 04 test.

After the fix, a new workflow run succeeded.

Successful run:

```text
31385596637
```

Result:

```text
Project 04 Matrix CI → PASS
```

---

# Important CI Lesson

This failure demonstrated an important real-world CI principle:

> CI should have a clearly defined test scope.

When a repository contains multiple projects, simply running:

```bash
pytest -v
```

may unintentionally execute tests belonging to other projects.

Explicitly targeting the required test suite makes the pipeline more predictable.

---

# Fail-Fast Observation

During the failed matrix execution:

```text
test (3.11) → FAILURE
test (3.12) → CANCELLED
```

This provided an opportunity to observe the default matrix failure behavior.

The failure of one matrix job resulted in the other matrix job being cancelled.

This reinforced the purpose of the `fail-fast` strategy.

The project did **not** perform a separate controlled experiment comparing:

```yaml
fail-fast: true
```

against:

```yaml
fail-fast: false
```

Therefore no experimental result is claimed for that comparison.

---

# Matrix Concepts Learned

## strategy

`strategy` controls how GitHub Actions executes a job.

Example:

```yaml
strategy:
  matrix:
    python-version: ["3.11", "3.12"]
```

---

## matrix

`matrix` defines the configuration values that GitHub should test.

Example:

```yaml
matrix:
  python-version: ["3.11", "3.12"]
```

---

## Matrix Variable

A matrix variable is the individual value available during a matrix job.

Example:

```yaml
${{ matrix.python-version }}
```

---

## Matrix Combination

A matrix combination represents one specific configuration.

For example:

```text
Python 3.11
```

is one combination.

```text
Python 3.12
```

is another combination.

---

# Cartesian Product

For multiple matrix dimensions, GitHub Actions generates combinations from the values of each dimension.

For example:

```yaml
matrix:
  python-version: ["3.11", "3.12"]
  os: [ubuntu-latest, windows-latest]
```

The conceptual combinations would be:

```text
Python 3.11 + Ubuntu
Python 3.11 + Windows
Python 3.12 + Ubuntu
Python 3.12 + Windows
```

Total:

```text
2 × 2 = 4 combinations
```

This concept was studied as part of Project 04, but a multi-dimensional matrix was not executed as a separate experiment.

---

# include

`include` can be used to add additional matrix information or combinations.

Example concept:

```yaml
matrix:
  python-version: ["3.11", "3.12"]

  include:
    - python-version: "3.12"
      experimental: true
```

The exact `include` behavior was studied conceptually but was not executed as a separate Project 04 experiment.

---

# exclude

`exclude` can be used to remove unwanted combinations from a matrix.

Example:

```yaml
matrix:
  python-version: ["3.11", "3.12"]
  os: [ubuntu-latest, windows-latest]

  exclude:
    - python-version: "3.11"
      os: windows-latest
```

The exact `exclude` behavior was studied conceptually but was not executed as a separate Project 04 experiment.

---

# Commands Used

## Local testing

```bash
pytest -v
```

## Git status

```bash
git status
```

## Git branches

```bash
git branch -a
```

## Git history

```bash
git log --oneline --decorate -n 10
```

## GitHub Actions runs

```bash
gh run list --limit 5
```

## Inspect workflow run

```bash
gh run view <RUN_ID>
```

## Inspect matrix jobs

```bash
gh run view <RUN_ID> --json jobs
```

## Extract job status

```bash
gh run view <RUN_ID> --json jobs --jq '.jobs[] | {name:.name,status:.status,conclusion:.conclusion}'
```

---

# Troubleshooting Methodology

The troubleshooting process used in this project was:

```text
Matrix CI failure
       ↓
Check workflow run
       ↓
Identify matrix jobs
       ↓
Find failed combination
       ↓
Inspect failed step
       ↓
Identify actual error
       ↓
Determine root cause
       ↓
Fix CI configuration
       ↓
Push change
       ↓
Run CI again
       ↓
Verify matrix jobs
```

---

# Actual Results

| Experiment                        | Result                                       |
| --------------------------------- | -------------------------------------------- |
| Local pytest                      | PASS                                         |
| Python 3.11 matrix job            | PASS after fix                               |
| Python 3.12 matrix job            | PASS after fix                               |
| Two-version matrix                | PASS                                         |
| Matrix job expansion              | Verified                                     |
| Matrix failure investigation      | Completed                                    |
| Test isolation problem            | Identified                                   |
| CI workflow fix                   | Completed                                    |
| Multi-dimensional matrix          | Concept studied, not experimentally executed |
| `include`                         | Concept studied, not experimentally executed |
| `exclude`                         | Concept studied, not experimentally executed |
| Controlled `fail-fast` comparison | Not experimentally executed                  |

---

# Lessons Learned

### 1. Matrix does not mean one job runs multiple versions

Instead:

```text
One matrix definition
        ↓
Multiple combinations
        ↓
Multiple job executions
```

---

### 2. Matrix variables control each execution

```yaml
${{ matrix.python-version }}
```

evaluates to the value associated with the current matrix combination.

---

### 3. Matrix reduces YAML duplication

The same CI steps can be reused across multiple configurations.

---

### 4. Matrix failures are configuration-specific

A matrix allows us to determine whether a problem is associated with a particular:

* Python version
* Operating system
* Dependency configuration
* Environment

---

### 5. Repository test isolation matters

Multiple projects inside one repository can cause unintended test discovery.

CI must explicitly define what it should test.

---

### 6. GitHub Actions CLI is valuable for troubleshooting

The GitHub CLI helped identify:

```text
workflow
    ↓
matrix jobs
    ↓
failed combination
    ↓
job result
```

---

# Interview Questions

1. What is a GitHub Actions matrix?
2. Why use matrix CI?
3. What does `strategy.matrix` do?
4. What is a matrix variable?
5. What is a matrix combination?
6. How does GitHub expand a matrix?
7. What is the Cartesian product in matrix CI?
8. How many jobs are created by two Python versions and two operating systems?
9. What does `matrix.include` do?
10. What does `matrix.exclude` do?
11. What is `fail-fast`?
12. What happens when one matrix job fails?
13. What is the difference between `fail-fast: true` and `fail-fast: false`?
14. How do you access a matrix variable?
15. What does `${{ matrix.python-version }}` mean?
16. How would you troubleshoot one failing matrix job?
17. How do you identify which matrix combination failed?
18. Why is matrix CI useful for Python projects?
19. Why is matrix CI useful for cross-platform testing?
20. What are the disadvantages of matrix CI?
21. How can matrix CI increase CI cost?
22. How would you reduce unnecessary matrix combinations?
23. Explain matrix expansion from workflow definition to individual jobs.
24. What happens if one matrix combination fails?
25. How would you design a production-grade matrix strategy?

---

# Scenario-Based Interview Questions

## Scenario 1

A project supports:

```text
Python 3.10
Python 3.11
Python 3.12
```

and:

```text
Ubuntu
Windows
macOS
```

How many matrix combinations are created?

---

## Scenario 2

You exclude:

```text
Python 3.10 + Windows
```

How many combinations remain?

---

## Scenario 3

Python 3.11 on Windows fails.

How would you troubleshoot the problem?

Consider:

```text
Matrix combination
        ↓
Operating system
        ↓
Python version
        ↓
Failed step
        ↓
Logs
        ↓
Root cause
```

---

## Scenario 4

A repository supports 10 Python versions and 5 operating systems.

The matrix produces:

```text
10 × 5 = 50 jobs
```

How would you reduce CI cost while maintaining meaningful compatibility coverage?

---

## Scenario 5

One experimental Python version is allowed to fail.

How would you design the matrix?

Consider:

* `include`
* `continue-on-error`
* `fail-fast`
* matrix variables

---

# CI/CD Mastery Progress

```text
Project 01
Basic CI
    ↓
Project 02
Pull Request CI
    ↓
Project 03
Branch & Path-Based CI
    ↓
Project 04
Matrix CI
    ↓
Project 05
CI Artifacts
    ↓
Project 06
Test Reports
    ↓
Project 07
Code Quality CI
    ↓
Project 08
Dependency CI
    ↓
Project 09
Docker Image CI
```

Current progress:

```text
PROJECT 04 — MATRIX CI
STATUS: COMPLETE
```

---

# Technologies Used

* Git
* GitHub
* GitHub Actions
* GitHub CLI
* Python
* pytest
* actions/checkout
* actions/setup-python

---

# Final Takeaway

The most important concept from Project 04 is:

```text
Workflow
    ↓
strategy
    ↓
matrix
    ↓
matrix variables
    ↓
matrix combinations
    ↓
jobs
    ↓
steps
    ↓
tests
    ↓
checks
```

The key lesson is:

> **A GitHub Actions matrix allows one CI definition to be systematically expanded into multiple independent job combinations, enabling the same test process to validate different versions, operating systems, or configurations.**

Project 04 successfully demonstrated Python-version matrix CI, matrix job expansion, matrix failure investigation, and CI test isolation.
