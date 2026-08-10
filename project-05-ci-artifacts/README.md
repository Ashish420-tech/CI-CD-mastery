# Project 05 — GitHub Actions CI Artifacts

## Overview

This project demonstrates how to use **GitHub Actions artifacts** to preserve, transfer, download, and troubleshoot CI-generated files.

The project starts with a basic Python test workflow and progressively builds an artifact lifecycle:

```text
Run Tests
    ↓
Generate CI Files
    ↓
Verify Files
    ↓
Upload Artifact
    ↓
GitHub Artifact Storage
    ↓
Download Artifact
    ↓
Verify Artifact
```

The project also demonstrates artifact transfer between independent GitHub Actions jobs and includes a deliberate artifact failure followed by root-cause analysis and recovery.

---

## Objectives

The main objectives of Project 05 are:

* Run Python tests using GitHub Actions.
* Generate files during CI execution.
* Verify files inside the GitHub-hosted runner.
* Upload files as GitHub Actions artifacts.
* Download artifacts using GitHub CLI.
* Upload multiple files as one artifact.
* Configure artifact retention.
* Transfer artifacts between GitHub Actions jobs.
* Intentionally break artifact configuration.
* Diagnose the resulting CI failure.
* Correct the configuration and verify recovery.
* Practice real-world CI/CD troubleshooting.

---

# Architecture

## Final Workflow

```text
                    GitHub Actions
                          │
                          ▼
                   ┌─────────────┐
                   │   test job  │
                   └──────┬──────┘
                          │
                     Run pytest
                          │
                          ▼
                Generate test artifacts
                          │
                          ▼
                    artifacts/
                  ┌───────┼────────┐
                  │       │        │
                  ▼       ▼        ▼
             test-result environment summary
                  .txt      .txt      .txt
                  │
                  ▼
             Verify artifacts
                  │
                  ▼
          upload-artifact@v4
                  │
                  ▼
       GitHub Artifact Storage
                  │
          python-test-artifacts
                  │
                  ▼
             ┌───────────────┐
             │ verify-artifact│
             │      job       │
             └───────┬───────┘
                     │
              download-artifact@v5
                     │
                     ▼
             downloaded-artifacts/
                     │
                     ▼
              Verify all files
```

---

# Repository Structure

```text
CI-CD-mastery/
│
├── .github/
│   └── workflows/
│       ├── project-03-ci.yml
│       ├── project-04-matrix.yml
│       └── project-05-artifacts.yml
│
├── project-03-branch-path-ci/
│
├── project-04-matrix-ci/
│
└── project-05-ci-artifacts/
    ├── app.py
    ├── test_app.py
    └── README.md
```

---

# Application

The project uses a small Python application and pytest test suite.

Tests are executed using:

```bash
pytest -v project-05-ci-artifacts/test_app.py
```

The CI environment uses:

```yaml
python-version: "3.12"
```

---

# Workflow Configuration

The workflow is:

```text
.github/workflows/project-05-artifacts.yml
```

It runs on:

```yaml
push:
  branches:
    - project-05-ci-artifacts

pull_request:
  branches:
    - project-05-ci-artifacts
```

---

# Experiment 1 — Baseline CI

The first version of the workflow established basic CI execution.

The workflow:

1. Checked out the repository.
2. Installed Python 3.12.
3. Installed pytest.
4. Ran the test suite.

The baseline command was:

```bash
pytest -v project-05-ci-artifacts/test_app.py
```

The CI test completed successfully.

---

# Experiment 2 — Generate a CI Result File

The workflow was extended to generate:

```text
test-result.txt
```

The file contained:

```text
CI Test Result
Python Version: Python 3.12.13
Test Status: PASS
```

The purpose was to understand the difference between a file existing inside the CI runner and an actual GitHub Actions artifact.

At this stage:

```text
Runner Workspace
└── test-result.txt
```

The file was **not yet stored as a GitHub artifact**.

---

# Experiment 3 — Verify the File Inside the Runner

The workflow then explicitly verified the generated file:

```yaml
- name: Verify test result file
  run: |
    ls -l test-result.txt
    cat test-result.txt
```

This demonstrated that the GitHub-hosted runner itself could create and read the file.

The important concept was:

```text
CI runner workspace ≠ GitHub artifact storage
```

---

# Experiment 4 — Upload a Single Artifact

The workflow introduced:

```yaml
- name: Upload test result
  uses: actions/upload-artifact@v4
  with:
    name: test-result
    path: test-result.txt
```

This created the first real GitHub Actions artifact.

Two concepts were intentionally separated:

```yaml
name: test-result
```

is the **artifact name**.

```yaml
path: test-result.txt
```

is the **file being uploaded**.

Therefore:

```text
Artifact
└── test-result
       └── test-result.txt
```

---

# Experiment 5 — Download the Artifact

The artifact was downloaded from the successful GitHub Actions run using:

```bash
gh run download 31391000571 -n test-result -D downloaded-artifact
```

The downloaded file was verified locally:

```bash
cat downloaded-artifact/test-result.txt
```

The contents were:

```text
CI Test Result
Python Version: Python 3.12.13
Test Status: PASS
```

This proved the complete lifecycle:

```text
Runner
  ↓
Upload
  ↓
GitHub Artifact Storage
  ↓
Download
  ↓
Local Machine
```

---

# Experiment 6 — Multiple-File Artifact

The workflow was expanded to generate three files:

```text
artifacts/
├── test-result.txt
├── environment.txt
└── summary.txt
```

### test-result.txt

```text
CI Test Result
Python Version: <CI Python Version>
Test Status: PASS
```

### environment.txt

```text
Python Version: <CI Python Version>
Runner OS: <Runner OS>
```

### summary.txt

```text
Project: Project 05 - CI Artifacts
Test Status: PASS
Artifact Files: 3
```

The complete directory was uploaded using:

```yaml
- name: Upload test artifacts
  uses: actions/upload-artifact@v4
  with:
    name: python-test-artifacts
    path: artifacts/
```

The GitHub Actions logs confirmed:

```text
With the provided path, there will be 3 files uploaded
```

and:

```text
Artifact python-test-artifacts has been successfully uploaded!
```

---

# Experiment 7 — Artifact Retention

Artifact retention was explicitly configured:

```yaml
retention-days: 7
```

The final upload configuration became:

```yaml
- name: Upload test artifacts
  uses: actions/upload-artifact@v4
  with:
    name: python-test-artifacts
    path: artifacts/
    retention-days: 7
```

The actual GitHub Actions logs confirmed that the runner received:

```text
name: python-test-artifacts
path: artifacts/
retention-days: 7
```

The artifact was successfully uploaded.

---

# Experiment 8 — Transfer Artifact Between Jobs

The workflow was expanded from one job to two jobs.

## Job 1

```yaml
test:
```

Responsibilities:

* Checkout repository.
* Set up Python.
* Run pytest.
* Generate artifact files.
* Verify artifact files.
* Upload artifact.

## Job 2

```yaml
verify-artifact:
  needs: test
```

The `needs` relationship creates the dependency:

```text
test
 ↓
verify-artifact
```

The second job downloads the artifact:

```yaml
- name: Download test artifacts
  uses: actions/download-artifact@v5
  with:
    name: python-test-artifacts
    path: downloaded-artifacts
```

Then it verifies:

```text
downloaded-artifacts/test-result.txt
downloaded-artifacts/environment.txt
downloaded-artifacts/summary.txt
```

The successful GitHub Actions run showed:

```text
✓ test
✓ verify-artifact
```

This proved that the artifact successfully crossed the job boundary.

---

# Experiment 9 — Deliberate Artifact Failure

A controlled failure was intentionally introduced.

The valid path:

```yaml
path: artifacts/
```

was temporarily changed to:

```yaml
path: does-not-exist.txt
```

The workflow still generated:

```text
artifacts/
├── test-result.txt
├── environment.txt
└── summary.txt
```

but the upload action searched for:

```text
does-not-exist.txt
```

The GitHub Actions run reported:

```text
No files were found with the provided path: does-not-exist.txt.
No artifacts will be uploaded.
```

Therefore the artifact was never created.

---

# Experiment 10 — Downstream Failure Diagnosis

Because the first job did not upload the artifact, the second job attempted to download an artifact that did not exist.

The downstream failure was:

```text
Artifact not found for name: python-test-artifacts
```

The complete failure chain was:

```text
Generate artifacts
       ↓
Actual directory = artifacts/
       ↓
Upload path = does-not-exist.txt
       ↓
No matching file
       ↓
No artifact uploaded
       ↓
verify-artifact starts
       ↓
Artifact not found
       ↓
Job fails
```

The important troubleshooting lesson is:

> The failure in the second job was a consequence. The root cause was the incorrect upload path in the first job.

---

# Experiment 11 — Root-Cause Fix

The incorrect path was restored:

```yaml
path: artifacts/
```

The retention configuration remained:

```yaml
retention-days: 7
```

The recovery commit restored the artifact upload configuration.

The subsequent GitHub Actions run succeeded:

```text
✓ test
✓ verify-artifact
```

The artifact was again available:

```text
python-test-artifacts
```

This completed the deliberate failure → diagnosis → fix → recovery cycle.

---

# Useful GitHub CLI Commands

## List Project 05 runs

```bash
gh run list \
  --branch project-05-ci-artifacts \
  --workflow "Project 05 - CI Artifacts" \
  --limit 5
```

## View a workflow run

```bash
gh run view <RUN_ID>
```

## View complete logs

```bash
gh run view <RUN_ID> --log
```

## View only failed logs

```bash
gh run view <RUN_ID> --log-failed
```

## Download an artifact

```bash
gh run download <RUN_ID> \
  -n python-test-artifacts \
  -D downloaded-artifact
```

## Check repository state

```bash
git status
```

## View project history

```bash
git log --oneline --decorate -n 10
```

---

# Git Commit Progression

The project was developed through incremental commits rather than one large change.

Important checkpoints included:

```text
ci(project-05): add baseline CI
ci(project-05): generate and verify test result
ci(project-05): upload test result artifact
ci(project-05): upload multiple test artifacts
ci(project-05): set artifact retention
ci(project-05): transfer artifacts between jobs
test(project-05): simulate missing artifact path
fix(project-05): restore artifact upload path
```

This commit history intentionally documents the learning progression.

---

# Key Concepts Learned

## 1. Runner Workspace

Files generated during a job initially exist only inside the GitHub-hosted runner.

```text
Runner
└── artifacts/
```

They are not automatically persisted after the job.

---

## 2. Artifact

An artifact provides persistent storage for files produced during a workflow run.

```text
Runner
   ↓
upload-artifact
   ↓
GitHub Artifact Storage
```

---

## 3. Artifact Name vs Path

These are different:

```yaml
name: python-test-artifacts
```

identifies the artifact.

```yaml
path: artifacts/
```

identifies what gets uploaded.

---

## 4. Artifact Between Jobs

Jobs have separate execution environments.

Therefore, a file created in:

```text
test
```

is not automatically available in:

```text
verify-artifact
```

The artifact provides the transfer mechanism:

```text
Job 1
 ↓
Upload
 ↓
Artifact Storage
 ↓
Download
 ↓
Job 2
```

---

## 5. Retention

Artifacts do not need to be retained forever.

This project explicitly configured:

```yaml
retention-days: 7
```

---

## 6. Troubleshooting

A downstream failure does not necessarily mean the downstream job is the root cause.

In this project:

```text
verify-artifact failed
```

but the actual root cause was:

```text
incorrect upload path
```

This is an important CI/CD troubleshooting principle:

> Follow the dependency chain backward until you find the first failure.

---

# Final Project Flow

The final successful workflow is:

```text
Git Push / Pull Request
        │
        ▼
   GitHub Actions
        │
        ▼
      test job
        │
        ├── Checkout
        │
        ├── Python 3.12
        │
        ├── Install pytest
        │
        ├── Run tests
        │
        ├── Generate artifacts
        │
        ├── Verify artifacts
        │
        └── Upload artifact
                  │
                  ▼
       python-test-artifacts
                  │
                  │ retention: 7 days
                  │
                  ▼
        verify-artifact job
                  │
                  ├── Download artifact
                  │
                  └── Verify 3 files
```

---

# Project Completion Criteria

Project 05 is considered complete when the following are demonstrated:

* [x] Python CI executes successfully.
* [x] CI generates files.
* [x] Runner verifies generated files.
* [x] Single artifact upload works.
* [x] Artifact can be downloaded.
* [x] Downloaded contents are verified.
* [x] Multiple files can be uploaded as one artifact.
* [x] Artifact retention is configured.
* [x] Artifact can move between jobs.
* [x] A deliberate artifact failure can be reproduced.
* [x] CI logs can be used to identify the root cause.
* [x] The artifact failure can be fixed.
* [x] The recovered workflow passes again.

---

# Final Result

Project 05 demonstrates a complete GitHub Actions artifact lifecycle:

```text
CREATE
  ↓
VERIFY
  ↓
UPLOAD
  ↓
STORE
  ↓
TRANSFER
  ↓
DOWNLOAD
  ↓
VERIFY
  ↓
FAIL
  ↓
DIAGNOSE
  ↓
FIX
  ↓
RECOVER
```

**Project 05 — CI Artifacts: Complete.**
