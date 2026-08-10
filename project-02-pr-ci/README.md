# Project 02 — Pull Request CI

## 100 CI/CD Pipeline Mastery

**Project:** 02 — Pull Request CI
**Repository:** `CI-CD-mastery`
**Branch:** `project-02-pr-ci`
**Technology:** GitHub Actions + Python + pytest
**Level:** Basic → Intermediate CI/CD
**Focus:** Pull Request validation, CI checks, failure diagnosis, and merge workflow

---

## 1. Project Overview

This project demonstrates how Continuous Integration (CI) can automatically validate code changes submitted through a Pull Request before those changes are merged.

The project builds on Project 01 and introduces an important CI/CD concept:

> **CI should validate proposed changes before they become part of the target branch.**

The workflow is triggered by a GitHub Pull Request and performs:

1. Repository checkout
2. Python environment setup
3. Dependency installation
4. Automated test execution
5. Pass/fail reporting to the Pull Request

The project also contains a deliberate failure laboratory where a test was intentionally broken, the Pull Request CI failed, the GitHub Actions logs were investigated, the root cause was identified, the test was fixed, and the same Pull Request became green.

---

# 2. Objective

The objectives of Project 02 were:

* Understand Pull Requests
* Understand feature branches
* Understand CI validation before merge
* Configure GitHub Actions for `pull_request`
* Understand GitHub Actions workflows
* Understand jobs and steps
* Understand GitHub status checks
* Observe a failed PR check
* Diagnose a failed GitHub Actions run
* Fix the underlying problem
* Verify the PR becomes green
* Understand the relationship between CI and merge protection
* Practice professional Git branching and commit discipline

---

# 3. Target Architecture

```text
Developer
    |
    | git switch -c feature/...
    |
    v
Feature Branch
    |
    | git push
    |
    v
GitHub
    |
    | Pull Request
    v
+-----------------------------+
| Pull Request                |
|                             |
| base: project-02-pr-ci      |
| head: feature/...           |
+-----------------------------+
    |
    | pull_request event
    v
GitHub Actions
    |
    v
Checkout Repository
    |
    v
Setup Python 3.12
    |
    v
Install Dependencies
    |
    v
Run pytest
    |
    +----------------------+
    |                      |
    v                      v
 PASS                    FAIL
    |                      |
    v                      v
Green Check            Red Check
    |                      |
    v                      v
Merge candidate       Fix required
```

---

# 4. Repository Strategy

The repository is designed as a collection of standalone CI/CD projects.

```text
CI-CD-mastery/
│
├── project-01-basic-ci/
│
├── project-02-pr-ci/
│
├── ...
│
└── project-100-enterprise-cicd/
```

Each project has its own Git branch.

For Project 02:

```text
project-02-pr-ci
```

A temporary feature branch was used to simulate real developer work:

```text
feature/project-02-break-test
```

---

# 5. Git Branch Model

The Project 02 branch structure was:

```text
project-01-basic-ci
        |
        | create Project 02
        v
project-02-pr-ci
        |
        | developer change
        v
feature/project-02-break-test
        |
        | Pull Request
        v
project-02-pr-ci
```

The important distinction is:

### Project branch

```text
project-02-pr-ci
```

Represents the stable state of Project 02.

### Feature branch

```text
feature/project-02-break-test
```

Represents a developer's proposed change.

### Pull Request

The Pull Request connects:

```text
feature/project-02-break-test
                ↓
        project-02-pr-ci
```

The PR is a collaboration and validation mechanism; it is not itself a Git branch.

---

# 6. Project Structure

Final Project 02 structure:

```text
CI-CD-mastery/
│
├── .github/
│   └── workflows/
│       └── project-02-pr-ci.yml
│
├── project-01-basic-ci/
│
├── project-02-pr-ci/
│   ├── app.py
│   ├── requirements.txt
│   ├── tests/
│   │   └── test_app.py
│   └── README.md
│
└── .gitignore
```

The GitHub Actions workflow ultimately lives at:

```text
.github/workflows/project-02-pr-ci.yml
```

This was discovered during troubleshooting.

Initially the workflow was located at:

```text
project-02-pr-ci/.github/workflows/pr-ci.yml
```

The Pull Request did not trigger the workflow.

After moving it to:

```text
.github/workflows/project-02-pr-ci.yml
```

GitHub Actions successfully detected and executed it.

This was an important real-world troubleshooting lesson:

> A workflow file existing in Git does not necessarily mean that GitHub is currently registering and executing that workflow.

---

# 7. Application

The application is intentionally simple.

```python
def add(a, b):
    return a + b
```

The purpose of the application is not complexity.

The purpose is to isolate and understand:

```text
Git
+
Pull Request
+
GitHub Actions
+
pytest
+
CI failure
+
CI recovery
```

---

# 8. Test

The test verifies the addition function:

```python
from app import add


def test_add():
    assert add(2, 3) == 5
```

Expected result:

```text
1 passed
```

---

# 9. Dependencies

`requirements.txt` contains:

```text
pytest
```

GitHub Actions installs the dependency before executing the test.

---

# 10. GitHub Actions Workflow

Final workflow:

```yaml
name: Project 02 - Pull Request CI

on:
  pull_request:
    paths:
      - "project-02-pr-ci/**"

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: "3.12"

      - name: Install dependencies
        run: python -m pip install -r project-02-pr-ci/requirements.txt

      - name: Run tests
        working-directory: project-02-pr-ci
        run: python -m pytest -v
```

---

# 11. Understanding the Workflow

## Trigger

```yaml
on:
  pull_request:
```

This tells GitHub Actions:

> Execute this workflow when a Pull Request event occurs.

This is different from simply running CI on a normal branch push.

---

## Path Filter

```yaml
paths:
  - "project-02-pr-ci/**"
```

This limits execution to Pull Request changes affecting Project 02.

This is useful in a multi-project repository because a change to Project 10 should not necessarily trigger Project 02's CI.

---

# 12. Job

```yaml
jobs:
  test:
```

A job is a group of steps executed together on a GitHub-hosted runner.

The runner is:

```yaml
runs-on: ubuntu-latest
```

Therefore GitHub provisions an Ubuntu runner for the job.

---

# 13. Checkout

```yaml
- name: Checkout repository
  uses: actions/checkout@v4
```

This downloads the repository contents into the GitHub Actions runner.

Without checkout, the runner would not have the repository files available for testing.

---

# 14. Python Setup

```yaml
- name: Set up Python
  uses: actions/setup-python@v5
  with:
    python-version: "3.12"
```

This installs/configures Python 3.12 on the runner.

The final successful run used:

```text
Python 3.12.13
```

---

# 15. Dependency Installation

```yaml
- name: Install dependencies
  run: python -m pip install -r project-02-pr-ci/requirements.txt
```

This installs pytest and its dependencies.

The successful run showed pytest being installed before the test stage.

---

# 16. Working Directory

The workflow executes tests with:

```yaml
working-directory: project-02-pr-ci
```

and:

```yaml
run: python -m pytest -v
```

This is important because:

```text
project-02-pr-ci/
├── app.py
└── tests/
```

The test contains:

```python
from app import add
```

Therefore pytest needs to execute from the Project 02 directory so that `app.py` is available on Python's import path.

---

# 17. First Troubleshooting Discovery

Before the final workflow was established, we ran:

```bash
python -m pytest -v project-02-pr-ci/tests
```

from:

```text
~/CI-CD-mastery
```

The result was:

```text
ModuleNotFoundError: No module named 'app'
```

The reason was the execution context.

Running:

```bash
cd project-02-pr-ci
python -m pytest -v
```

correctly located `app.py`.

This led to the workflow correction:

```yaml
working-directory: project-02-pr-ci
```

This was an important CI lesson:

> The command, working directory, environment, dependencies, and repository layout all influence whether a CI job succeeds.

---

# 18. Pull Request Lifecycle

The actual Project 02 lifecycle was:

```text
project-02-pr-ci
        |
        | create feature branch
        v
feature/project-02-break-test
        |
        | push
        v
GitHub
        |
        | create PR
        v
PR #2
        |
        | pull_request event
        v
GitHub Actions
        |
        v
Project 02 - Pull Request CI
```

---

# 19. First Pull Request

The first Project 02 PR was:

```text
PR #1
```

Title:

```text
feat(project-02): validate pull requests with GitHub Actions
```

Base:

```text
project-01-basic-ci
```

Head:

```text
project-02-pr-ci
```

It was merged.

However, during later investigation we discovered that the expected Project 02 workflow check had not actually been registered/executed for that PR.

This became part of the troubleshooting lesson.

---

# 20. Deliberate Failure Lab

The most important part of Project 02 was the deliberate failure.

A feature branch was created:

```bash
git switch -c feature/project-02-break-test
```

The initial application remained:

```python
def add(a, b):
    return a + b
```

which returns:

```text
5
```

for:

```python
add(2, 3)
```

The test was intentionally changed from:

```python
assert add(2, 3) == 5
```

to:

```python
assert add(2, 3) == 6
```

This created a controlled test failure.

---

# 21. Local Failure

Running the test locally produced:

```text
FAILED tests/test_app.py::test_add
assert 5 == 6
```

This confirmed that the failure was intentional and reproducible.

---

# 22. Failure Commit

The intentional failure was committed:

```text
089f8e3 test(project-02): introduce failing PR test
```

This was pushed to:

```text
feature/project-02-break-test
```

---

# 23. Failure Pull Request

A second PR was created:

```text
PR #2
```

Base:

```text
project-02-pr-ci
```

Head:

```text
feature/project-02-break-test
```

Title:

```text
test(project-02): verify failed PR CI
```

---

# 24. First CI Failure

After correcting the workflow location and pushing the feature branch, GitHub Actions finally triggered.

The workflow run was:

```text
Project 02 - Pull Request CI
```

Event:

```text
pull_request
```

The job executed:

```text
Set up job             ✓
Checkout repository    ✓
Set up Python          ✓
Install dependencies   ✓
Run tests              ✗
```

---

# 25. Diagnosing the Failure

The workflow run was inspected using:

```bash
gh run view 31370072711
```

Then the failed logs were examined:

```bash
gh run view 31370072711 --log-failed
```

The log showed:

```text
tests/test_app.py::test_add FAILED
```

and:

```text
assert 5 == 6
```

The root cause was therefore:

```text
Application result = 5
Test expected     = 6
```

The CI system itself was functioning correctly.

The **test was wrong**.

This distinction is critical:

```text
CI infrastructure failure
        ≠
application failure
        ≠
test failure
```

In this case:

```text
CI infrastructure = PASS
pytest execution  = PASS
test assertion    = FAIL
```

The uploaded GitHub Actions logs show checkout, Python setup, dependency installation, and test execution completing, with the failing assertion producing exit code 1.

---

# 26. Fix

The test was corrected:

```python
assert add(2, 3) == 5
```

The test was first verified locally:

```bash
cd project-02-pr-ci
python -m pytest -v
```

Result:

```text
1 passed
```

The fix was committed:

```text
8470c27 fix(project-02): restore correct test expectation
```

---

# 27. Successful CI Verification

The fix was pushed to the same Pull Request.

GitHub Actions automatically ran again.

The final workflow execution showed:

```text
Checkout repository    ✓
Set up Python          ✓
Install dependencies   ✓
Run tests              ✓
```

The final pytest result was:

```text
tests/test_app.py::test_add PASSED
============================== 1 passed
```

The complete successful runner log confirms that the test executed from the Project 02 directory and passed.

---

# 28. Final PR Check

The PR was checked with:

```bash
gh pr checks 2
```

Result:

```text
All checks were successful
0 cancelled
0 failing
1 successful
0 skipped
0 pending
```

Therefore:

```text
PR #2
    |
    v
CI CHECK
    |
    v
GREEN ✓
```

At this point the PR was still open.

That is intentional because **passing CI and merging are two separate concepts**.

---

# 29. Merge Protection Concept

We did not assume branch protection was configured.

A repository can have:

```text
CI passes
```

without necessarily enforcing:

```text
CI must pass before merge
```

Branch protection can make a status check required.

Conceptually:

```text
PR
 |
 +---- CI FAIL
 |       |
 |       └── Merge blocked if check is required
 |
 +---- CI PASS
         |
         └── Merge allowed if other requirements are satisfied
```

For a production repository, branch protection should normally require appropriate CI checks before merging important branches.

---

# 30. Push vs Pull Request CI

### Push CI

```yaml
on:
  push:
```

Runs when commits are pushed to a matching branch.

### Pull Request CI

```yaml
on:
  pull_request:
```

Runs in the context of a Pull Request.

The purpose of PR CI is:

> Validate proposed changes before they are merged.

---

# 31. Important Git Concepts

## Local Branch

A branch that exists in your local Git repository.

Example:

```text
feature/project-02-break-test
```

---

## Remote Branch

A branch stored on GitHub.

Example:

```text
origin/feature/project-02-break-test
```

---

## origin

`origin` is the conventional name for the remote Git repository.

Example:

```bash
git push origin feature/project-02-break-test
```

---

## HEAD

`HEAD` identifies the commit currently checked out.

Example:

```text
HEAD -> feature/project-02-break-test
```

means HEAD is currently pointing to that branch.

---

## Commit

A permanent snapshot of changes in Git history.

Example:

```text
8470c27 fix(project-02): restore correct test expectation
```

---

## Pull Request

A GitHub collaboration object that proposes merging changes from one branch into another.

Example:

```text
feature/project-02-break-test
              ↓
              PR
              ↓
project-02-pr-ci
```

---

## Merge

Combines the proposed changes into the target branch.

A Pull Request can exist without being merged.

That is exactly the state of PR #2 at the end of this lab.

---

# 32. GitHub Actions Terminology

## Workflow

A YAML-defined automation.

Example:

```text
Project 02 - Pull Request CI
```

---

## Workflow Run

One execution of a workflow.

Example:

```text
31370072711
```

---

## Job

A collection of steps running on a runner.

Example:

```yaml
jobs:
  test:
```

---

## Step

An individual operation inside a job.

Examples:

```text
Checkout repository
Set up Python
Install dependencies
Run tests
```

---

## Check

The result GitHub associates with the Pull Request.

Example:

```text
Project 02 - Pull Request CI/test
```

A successful check:

```text
✓
```

A failed check:

```text
X
```

---

# 33. Complete Git → GitHub → CI Flow

The complete technical lifecycle is:

```text
Developer modifies code
        |
        v
git add
        |
        v
git commit
        |
        v
git push
        |
        v
Remote feature branch
        |
        v
Pull Request created
        |
        v
GitHub generates pull_request event
        |
        v
GitHub Actions identifies matching workflow
        |
        v
Runner provisioned
        |
        v
actions/checkout
        |
        v
Python 3.12 configured
        |
        v
Dependencies installed
        |
        v
pytest executed
        |
        +----------------+
        |                |
        v                v
      PASS             FAIL
        |                |
        v                v
Green check         Red check
        |                |
        v                v
Merge candidate    Developer investigates
                         |
                         v
                       Fix
                         |
                         v
                    New commit
                         |
                         v
                    Push again
                         |
                         v
                  CI executes again
                         |
                         v
                      PASS
```

---

# 34. Troubleshooting Method Used

The troubleshooting methodology was:

```text
Observe
   ↓
Identify failing layer
   ↓
Inspect logs
   ↓
Find exact error
   ↓
Reproduce locally
   ↓
Determine root cause
   ↓
Apply targeted fix
   ↓
Run locally
   ↓
Push
   ↓
Verify CI
```

This is much better than randomly changing YAML or application code.

---

# 35. Troubleshooting Commands

Important commands used:

```bash
git status
```

Check working-tree state.

```bash
git branch
```

List local branches.

```bash
git branch -vv
```

Show branch tracking relationships.

```bash
git log --oneline --decorate -n 10
```

Inspect recent history.

```bash
git diff
```

Inspect unstaged changes.

```bash
git diff --cached
```

Inspect staged changes.

```bash
git ls-tree -r --name-only HEAD
```

Inspect tracked repository files.

```bash
gh workflow list
```

See workflows GitHub currently recognizes.

```bash
gh run list
```

List workflow runs.

```bash
gh run view <RUN_ID>
```

Inspect a workflow run.

```bash
gh run view <RUN_ID> --log-failed
```

Inspect failed logs.

```bash
gh pr view <PR_NUMBER>
```

Inspect a Pull Request.

```bash
gh pr checks <PR_NUMBER>
```

Inspect PR checks.

---

# 36. Failure Laboratory Summary

## Failure 1 — Local execution context

Command:

```bash
python -m pytest -v project-02-pr-ci/tests
```

Failure:

```text
ModuleNotFoundError: No module named 'app'
```

Root cause:

```text
pytest executed from repository root
```

Fix:

```yaml
working-directory: project-02-pr-ci
```

---

## Failure 2 — Deliberate test failure

Changed:

```python
assert add(2, 3) == 5
```

to:

```python
assert add(2, 3) == 6
```

Result:

```text
assert 5 == 6
```

CI correctly failed.

---

## Failure 3 — Workflow discovery

The initial workflow location did not produce the expected GitHub Actions run.

Investigation:

```bash
gh workflow list
gh run list
```

showed that the expected Project 02 workflow was not registered/running.

The workflow was moved to:

```text
.github/workflows/project-02-pr-ci.yml
```

After pushing the change, GitHub Actions successfully detected and executed it.

This was an important real-world CI troubleshooting exercise.

---

# 37. Final Git History

The Project 02 feature branch contains the meaningful history:

```text
8470c27 fix(project-02): restore correct test expectation
e915592 fix(project-02): move PR workflow to repository workflows
089f8e3 test(project-02): introduce failing PR test
eb175a0 feat(project-02): add pull request CI pipeline
```

The history clearly demonstrates:

```text
BUILD
  ↓
BREAK
  ↓
INFRASTRUCTURE FIX
  ↓
TEST FAILURE
  ↓
DIAGNOSE
  ↓
APPLICATION TEST FIX
  ↓
GREEN CI
```

---

# 38. What We Tested

Project 02 tested all of the following:

* [x] Git feature branch creation
* [x] Local branch tracking
* [x] Remote branch creation
* [x] Pull Request creation
* [x] Pull Request base/head concepts
* [x] `pull_request` GitHub Actions trigger
* [x] GitHub Actions workflow discovery
* [x] Ubuntu runner
* [x] Repository checkout
* [x] Python 3.12 setup
* [x] Dependency installation
* [x] pytest execution
* [x] Working-directory behavior
* [x] Deliberate test failure
* [x] Failed PR check
* [x] GitHub Actions log inspection
* [x] Root-cause identification
* [x] Local reproduction
* [x] Test correction
* [x] New commit
* [x] PR re-validation
* [x] Successful PR check
* [x] CI vs merge distinction
* [x] Branch protection concepts
* [x] Git history discipline

---

# 39. What We Did NOT Configure

The following were intentionally NOT implemented in Project 02:

* Docker
* Jenkins
* AWS
* Kubernetes
* Terraform
* Ansible
* DevSecOps
* Security scanning
* Argo CD
* Deployment
* Production infrastructure
* Automatic deployment
* Branch protection enforcement

These belong to later projects.

Project 02 intentionally focuses on:

```text
Git
+
Pull Requests
+
GitHub Actions
+
CI validation
```

---

# 40. Lessons Learned

### Lesson 1

A Pull Request is not the same thing as a branch.

```text
Branch = Git object
PR = GitHub collaboration/validation object
```

### Lesson 2

A workflow YAML existing in a repository does not automatically prove that the workflow executed.

Always verify:

```bash
gh workflow list
gh run list
```

### Lesson 3

CI failures must be diagnosed from logs.

Don't immediately modify code.

### Lesson 4

The execution directory matters.

```text
Correct command
+
Wrong working directory
=
Failure
```

### Lesson 5

A failed test can actually indicate healthy CI infrastructure.

In our failure lab:

```text
GitHub Actions = working
Python = working
pytest = working
Test = failing
```

Therefore CI correctly detected a bad change.

### Lesson 6

A green CI check does not automatically mean the PR has been merged.

```text
CI PASS
    ≠
MERGED
```

### Lesson 7

Branch protection is the mechanism that can turn CI into a merge gate.

---

# 41. Interview Questions

## Beginner Level

### 1. What is Continuous Integration?

**Answer:**

Continuous Integration is the practice of automatically building and testing code changes whenever developers integrate changes into a shared repository.

The objective is to detect defects early.

---

### 2. What is a Pull Request?

**Answer:**

A Pull Request is a GitHub collaboration mechanism used to propose changes from one branch into another branch.

For example:

```text
feature/login
      ↓
Pull Request
      ↓
development
```

It allows code review and automated validation before merging.

---

### 3. What is the difference between a branch and a Pull Request?

**Answer:**

A branch is a Git reference pointing to a line of commits.

A Pull Request is a GitHub object representing a proposed integration of one branch into another.

A branch can exist without a PR.

A PR references source and target branches.

---

### 4. What is GitHub Actions?

**Answer:**

GitHub Actions is GitHub's automation platform.

It executes workflows defined in YAML files and can automate:

* testing
* building
* security checks
* releases
* deployments

---

### 5. What is a workflow?

**Answer:**

A workflow is a YAML-defined automation process executed by GitHub Actions.

Example:

```yaml
name: CI

on:
  pull_request:
```

---

### 6. What is a job?

**Answer:**

A job is a group of steps executed on a runner.

Example:

```yaml
jobs:
  test:
```

---

### 7. What is a step?

**Answer:**

A step is an individual operation inside a job.

For example:

```text
Checkout
Setup Python
Install dependencies
Run tests
```

---

### 8. What is a status check?

**Answer:**

A status check is a result reported by an automated process against a commit or Pull Request.

Example:

```text
Project 02 - Pull Request CI/test
✓
```

---

# 42. Intermediate Interview Questions

## 9. What is the difference between `push` and `pull_request` triggers?

**Answer:**

`push` triggers a workflow when commits are pushed to matching branches.

```yaml
on:
  push:
```

`pull_request` triggers a workflow for Pull Request activity.

```yaml
on:
  pull_request:
```

The major purpose of `pull_request` CI is to validate proposed changes before merge.

---

## 10. What happens when a Pull Request is opened?

**Answer:**

Conceptually:

```text
Developer pushes feature branch
        ↓
Pull Request opened
        ↓
GitHub generates PR event
        ↓
Matching GitHub Actions workflow evaluated
        ↓
Runner starts
        ↓
Repository checked out
        ↓
Dependencies installed
        ↓
Tests executed
        ↓
Check reported to PR
```

---

## 11. How does GitHub Actions know that a PR was created?

**Answer:**

The workflow declares:

```yaml
on:
  pull_request:
```

GitHub generates the corresponding Pull Request event and evaluates workflows configured for that event.

---

## 12. What happens if a PR check fails?

**Answer:**

The check becomes red.

For example:

```text
Project 02 - Pull Request CI
X
```

If branch protection requires that check, the PR cannot be merged until the check succeeds.

Without required branch protection, a user with sufficient permissions may still be able to merge depending on repository settings.

---

## 13. What is branch protection?

**Answer:**

Branch protection is a GitHub repository policy mechanism that can enforce rules before changes are merged into protected branches.

Examples:

* required status checks
* required reviews
* preventing force pushes
* requiring conversation resolution

---

## 14. Why should CI run before merge?

**Answer:**

Because it prevents known automated validation failures from entering the target branch.

Without PR CI:

```text
Developer
   ↓
PR
   ↓
Merge
   ↓
Failure discovered later
```

With PR CI:

```text
Developer
   ↓
PR
   ↓
CI
   ↓
FAIL
   ↓
Fix
   ↓
PASS
   ↓
Merge
```

---

## 15. Can a failed CI pipeline be merged?

**Answer:**

Technically, it depends on repository permissions and protection rules.

If the relevant status check is configured as a required branch protection check, the PR cannot be merged while that check is failing.

If no such protection exists, a user with sufficient permissions may potentially merge it.

Therefore:

> CI failure and merge blocking are related but not identical concepts.

---

# 43. Advanced Interview Questions

## 16. Explain what happens technically from `git push` to PR CI.

**Answer:**

```text
git push
   ↓
Git object uploaded to GitHub
   ↓
Remote feature branch updated
   ↓
Developer creates Pull Request
   ↓
GitHub generates pull_request event
   ↓
GitHub evaluates workflow triggers
   ↓
Matching workflow selected
   ↓
Runner provisioned
   ↓
actions/checkout executes
   ↓
Python environment configured
   ↓
Dependencies installed
   ↓
pytest executes
   ↓
Exit code generated
   ↓
GitHub records check result
   ↓
PR displays green/red status
```

---

## 17. What does exit code 0 mean?

**Answer:**

Generally:

```text
exit code 0
```

means successful execution.

For pytest:

```text
1 passed
exit code 0
```

means the test command succeeded.

---

## 18. What does exit code 1 mean in our failure?

**Answer:**

The pytest command returned:

```text
exit code 1
```

because the test assertion failed:

```text
assert 5 == 6
```

Therefore GitHub Actions marked the step and job as failed.

---

## 19. How would you troubleshoot a failed GitHub Actions PR pipeline?

**Answer:**

I would follow a layered approach:

```text
1. Check PR status
2. Identify failed workflow
3. Identify failed job
4. Identify failed step
5. Inspect logs
6. Read exact error
7. Determine whether failure is:
      - code
      - test
      - dependency
      - environment
      - workflow
      - permissions
8. Reproduce locally
9. Fix root cause
10. Commit
11. Push
12. Verify new workflow run
```

In this project, that process identified:

```text
Run tests
    ↓
pytest
    ↓
assert 5 == 6
    ↓
incorrect test expectation
```

---

## 20. Why did the first local pytest command fail with `ModuleNotFoundError`?

**Answer:**

Because pytest was executed from the repository root while the application module was inside:

```text
project-02-pr-ci/app.py
```

The test imported:

```python
from app import add
```

Executing pytest from the Project 02 directory placed that directory on Python's import path.

Therefore:

```bash
cd project-02-pr-ci
python -m pytest -v
```

worked.

---

## 21. Why did we use `working-directory`?

**Answer:**

Because the Project 02 test suite should execute in its own project context.

```yaml
working-directory: project-02-pr-ci
```

This makes the CI execution equivalent to:

```bash
cd project-02-pr-ci
python -m pytest -v
```

and ensures:

```python
from app import add
```

can resolve the local application module.

---

## 22. What is `origin`?

**Answer:**

`origin` is the conventional Git remote name assigned when cloning or adding a remote repository.

For example:

```text
origin/project-02-pr-ci
```

is the remote-tracking reference for the GitHub branch.

---

## 23. What is `HEAD`?

**Answer:**

HEAD identifies the currently checked-out commit.

Example:

```text
HEAD -> feature/project-02-break-test
```

means HEAD points to the current feature branch.

---

## 24. What is `origin/feature/project-02-break-test`?

**Answer:**

It is a remote-tracking reference representing the corresponding branch state known from the `origin` remote.

Local:

```text
feature/project-02-break-test
```

Remote:

```text
origin/feature/project-02-break-test
```

---

## 25. Why did we create a separate feature branch instead of modifying `project-02-pr-ci` directly?

**Answer:**

To simulate a real development workflow.

The stable branch represents the accepted project state.

The feature branch represents a proposed change.

This allows:

```text
feature branch
      ↓
PR
      ↓
CI
      ↓
review
      ↓
merge
```

rather than developers directly modifying the protected/stable branch.

---

# 44. Scenario-Based Interview Questions

## Scenario 1

**Your PR shows a red CI check. What do you do first?**

Answer:

I would not immediately modify the code.

I would identify:

```text
workflow
→ job
→ failed step
→ log
→ error
```

Then reproduce the issue locally if possible.

---

## Scenario 2

**CI passes locally but fails in GitHub Actions. What could cause this?**

Possible causes include:

* different Python version
* different operating system
* missing dependency
* environment variable differences
* filesystem differences
* working-directory difference
* uncommitted local files
* dependency version differences
* GitHub Actions configuration
* permissions

The first thing I would compare is the environment and exact command executed locally versus CI.

---

## Scenario 3

**CI fails with `ModuleNotFoundError`. What would you check?**

I would check:

```text
1. Current working directory
2. Python import path
3. Repository structure
4. Package structure
5. Test location
6. Installation method
7. PYTHONPATH if applicable
```

In this project the root cause was the working directory.

---

## Scenario 4

**The PR has no checks. What would you investigate?**

I would check:

```bash
gh workflow list
gh run list
```

Then inspect:

* workflow location
* trigger
* branch filters
* path filters
* workflow YAML syntax
* whether the workflow exists in the relevant commit
* repository Actions configuration
* whether the event matches the workflow

This is exactly the type of investigation we performed in Project 02.

---

## Scenario 5

**The test passes locally but CI fails with a dependency error. What would you check?**

I would compare:

```text
Python version
pytest version
requirements.txt
dependency lock files
OS
environment variables
installation commands
```

I would also inspect the dependency-installation logs.

---

# 45. Senior-Level Interview Question

## 26. Is a Pull Request itself part of Git?

**Answer:**

The source and target branches and commits are Git concepts.

The Pull Request itself is a GitHub platform object built around those Git references.

Therefore:

```text
Git
→ commits
→ branches
→ refs

GitHub
→ Pull Requests
→ reviews
→ checks
→ merge controls
```

---

# 46. Senior-Level Question

## 27. Why is CI not the same as CD?

**Answer:**

CI focuses primarily on integrating and validating code changes.

Typical CI activities:

```text
checkout
build
test
lint
security checks
artifact creation
```

CD focuses on delivering or deploying validated changes.

Typical CD activities:

```text
artifact promotion
deployment
environment management
rollback
release
```

Project 02 intentionally stops at CI.

---

# 47. Senior-Level Question

## 28. What is the purpose of testing the merge result?

**Answer:**

A Pull Request represents a proposed combination of the source branch and target branch.

Testing the PR's effective merge state helps detect integration problems that might not exist when testing the feature branch in isolation.

Our GitHub Actions log showed checkout of:

```text
refs/remotes/pull/2/merge
```

which is an important practical detail of GitHub Pull Request workflows.

---

# 48. Project 02 Completion Checklist

```text
[x] Project branch created
[x] Project structure created
[x] PR workflow created
[x] Feature branch created
[x] Pull Request created
[x] pull_request trigger configured
[x] CI execution verified
[x] CI deliberately broken
[x] PR check failed
[x] Failed workflow investigated
[x] GitHub Actions logs inspected
[x] Root cause identified
[x] Test fixed
[x] Local test passed
[x] Fix committed
[x] Fix pushed
[x] PR CI became green
[x] Git history reviewed
[x] Merge behavior understood
[ ] Branch protection enforcement configured
[x] README documentation
[x] Interview preparation
```

### Branch protection status

Branch protection was **discussed but not configured** in this project.

That is intentional.

The objective was to understand:

```text
CI check
+
merge protection concept
```

without assuming repository settings were already configured.

---

# 49. Technologies Used

* Git
* GitHub
* GitHub CLI
* GitHub Actions
* Python 3.12
* pytest
* Ubuntu GitHub-hosted runner
* YAML

---

# 50. CI/CD Mastery Progress

```text
100 CI/CD Pipeline Mastery

Project 01 — Basic CI
Status: COMPLETE ✓

Project 02 — Pull Request CI
Status: COMPLETE ✓

Project 03 — NEXT
Status: NOT STARTED
```

Project 02 established the foundation for future projects:

```text
Git
  ↓
Branches
  ↓
Pull Requests
  ↓
Automated CI
  ↓
Status Checks
  ↓
Failure Detection
  ↓
Troubleshooting
  ↓
Green Validation
  ↓
Merge
```

---

# 51. Final Project Summary

Project 02 demonstrated that CI is not simply:

```text
"run pytest"
```

The real engineering workflow is:

```text
Developer change
       ↓
Feature branch
       ↓
Pull Request
       ↓
Automated validation
       ↓
Failure
       ↓
Investigation
       ↓
Root-cause analysis
       ↓
Fix
       ↓
Automated re-validation
       ↓
Green PR
       ↓
Potential merge
```

The most important lesson from this project is:

> **A CI pipeline is valuable not because it can pass, but because it can reliably detect a bad change before that change is merged.**

Project 02 successfully demonstrated both sides of that behavior:

```text
BAD CHANGE → CI FAIL ❌

FIXED CHANGE → CI PASS ✓
```

That is the foundation on which the remaining 98 CI/CD mastery projects will be built.
