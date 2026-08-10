Project 05 Interview Mastery — CI Artifacts
Part 1 — Foundation
Q1. What is a GitHub Actions artifact?

Strong interview answer:

A GitHub Actions artifact is a file or collection of files produced during a workflow run that GitHub stores after the job completes. Artifacts are commonly used to preserve build outputs, test reports, logs, binaries, packages, screenshots, or other CI-generated data and make them available for later download or consumption by another job.

In our Project 05:

GitHub Runner
     |
     | generates
     v
artifacts/
├── test-result.txt
├── environment.txt
└── summary.txt
     |
     | upload-artifact
     v
GitHub Artifact Storage
Q2. Why can't we simply create a file in Job 1 and use it in Job 2?

This is one of the most important questions.

Each GitHub Actions job runs on its own runner environment.

Conceptually:

Job 1
Runner A
/home/runner/work/...
      |
      X
      |
Job 2
Runner B
/home/runner/work/...

The filesystem of Runner A is not automatically the filesystem of Runner B.

Therefore:

Job 1
  |
  └── test-result.txt

does not automatically mean:

Job 2
  |
  └── test-result.txt

To transfer the file:

Job 1
   |
   | upload-artifact
   v
GitHub Artifact Storage
   |
   | download-artifact
   v
Job 2

That is exactly what we implemented.

Q3. What is the difference between an artifact and a normal file?

A normal file inside a runner is temporary.

For example:

echo "hello" > test-result.txt

creates:

Runner workspace
└── test-result.txt

Once the job/runner environment disappears, that file is not something you should expect to persist.

An artifact is explicitly persisted by GitHub:

Runner
   |
   | upload
   v
Artifact Storage

So:

A runner file is temporary workspace data; an artifact is persisted workflow output.

Q4. Explain upload-artifact@v4.

Our workflow used:

- name: Upload test artifacts
  uses: actions/upload-artifact@v4
  with:
    name: python-test-artifacts
    path: artifacts/
    retention-days: 7

There are three important inputs.

name
name: python-test-artifacts

This identifies the artifact.

path
path: artifacts/

This identifies what should be uploaded.

retention-days
retention-days: 7

This controls how long the artifact is retained.

So:

Artifact name
      |
      v
python-test-artifacts
      |
      +--- test-result.txt
      +--- environment.txt
      +--- summary.txt
Q5. What's the difference between name and path?

This is an excellent interview trap.

Given:

with:
  name: python-test-artifacts
  path: artifacts/

name means:

What should GitHub call the artifact?

path means:

Which files/directories should GitHub upload?

They are completely different concepts.

For example:

name: production-build
path: dist/

means:

Artifact:
production-build

Contents:
dist/*
Q6. Can path point to a directory?

Yes.

We used:

path: artifacts/

which uploaded:

artifacts/
├── test-result.txt
├── environment.txt
└── summary.txt

The GitHub Actions log actually confirmed:

With the provided path, there will be 3 files uploaded

This is stronger evidence than simply assuming the configuration worked.

Q7. What happens if the artifact path doesn't exist?

This was our deliberate failure experiment.

We changed:

path: artifacts/

to:

path: does-not-exist.txt

But the workflow generated:

artifacts/
├── test-result.txt
├── environment.txt
└── summary.txt

Therefore the upload action couldn't find the specified path.

The runner reported:

No files were found with the provided path: does-not-exist.txt.
No artifacts will be uploaded.

Then the downstream job failed:

Artifact not found for name: python-test-artifacts

This gives us an important troubleshooting chain:

Wrong upload path
       ↓
No artifact uploaded
       ↓
Download job cannot find artifact
       ↓
Downstream job fails
Q8. Which failure was the root cause?

This is a Senior-level troubleshooting question.

You saw:

Artifact not found for name: python-test-artifacts

Would you immediately say:

"The download step is broken"?

No.

You trace the dependency backward.

The first failure was:

No files were found with the provided path:
does-not-exist.txt

Therefore:

Root cause:
Incorrect upload path

The download failure was a secondary failure.

Strong interview answer:

I would identify the first failure in the dependency chain rather than automatically fixing the final failing step. In this case, the upload job failed to create the artifact because the configured path didn't exist. The downstream download failure was only a consequence.

That's exactly the reasoning you practiced.

Q9. What is download-artifact@v5?

We used:

- name: Download test artifacts
  uses: actions/download-artifact@v5
  with:
    name: python-test-artifacts
    path: downloaded-artifacts

It retrieves an artifact created by a previous workflow job/run and places its contents into the specified directory.

In our case:

GitHub Artifact Storage
        |
        | python-test-artifacts
        v
downloaded-artifacts/
├── test-result.txt
├── environment.txt
└── summary.txt
Q10. Why did we use needs: test?

Our second job contains:

verify-artifact:
  needs: test

This establishes a job dependency.

Without it, GitHub Actions can schedule jobs independently.

With:

needs: test

we establish:

test
 |
 | must succeed
 v
verify-artifact

So the second job waits for the first job.

Q11. Does needs: test transfer files?

No.

This is a very important distinction.

needs controls job dependency/order.

It does not transfer the filesystem.

We need both mechanisms:

needs: test

for dependency:

test
 ↓
verify-artifact

and:

actions/upload-artifact

plus:

actions/download-artifact

for data transfer:

test
 ↓
artifact storage
 ↓
verify-artifact

Excellent interview phrase:

needs controls execution dependency; artifacts handle data transfer.

Q12. Why not use needs alone?

Because:

needs: test

doesn't mean:

"Give Job 2 Job 1's filesystem."

It only means:

"Don't run this job until Job 1 has completed successfully."

So:

needs
=
dependency

artifact
=
data transfer
Q13. What happens if Job 1 fails?

By default, a dependent job using:

needs: test

will not execute normally if test fails.

For example:

test ❌
  |
  X
  |
verify-artifact

This is different from our deliberate artifact failure because in our case the test job itself succeeded:

test ✓

but the upload step didn't create an artifact.

Therefore:

test ✓
   |
   v
verify-artifact
   |
   X artifact not found
Q14. What is artifact retention?

Artifact retention determines how long GitHub keeps the artifact.

We configured:

retention-days: 7

So the artifact was configured for a seven-day retention period.

Why is this useful?

Imagine a production pipeline generating:

build.zip
test-report.html
security-report.json

You may want those files available for investigation for a limited period without retaining them indefinitely.

Q15. Why shouldn't every artifact be retained forever?

Because artifacts consume storage and often become irrelevant after some period.

For example:

Every PR
   ↓
100 MB artifact
   ↓
10 PRs/day
   ↓
~1 GB / 10 days

In a large organization, this can become significant.

A production organization should decide retention based on:

debugging needs
compliance
storage cost
release lifecycle
audit requirements
Part 2 — Artifact vs Cache

This is a very common DevOps interview topic.

Q16. What is the difference between an artifact and a cache?
Artifact

Purpose:

Preserve and share workflow output.

Examples:

build.zip
test-report.html
coverage.xml
security-report.json
Docker build metadata
Cache

Purpose:

Speed up future workflow executions by reusing dependencies or intermediate data.

Examples:

pip cache
npm cache
Maven dependencies
Gradle dependencies

Think:

Artifact
=
"What did my build produce?"

Cache
=
"How can I make my next build faster?"
Q17. Give me a real example.

Suppose we build a Python application.

Dependency installation:

pip install -r requirements.txt

We could cache:

~/.cache/pip

because we want the next workflow to avoid downloading dependencies again.

But after testing we generate:

test-report.html

That should be an artifact.

Therefore:

Cache
→ pip dependencies

Artifact
→ test report
Q18. Is an artifact a replacement for Git?

No.

Git is source/version control.

Artifacts are workflow outputs.

Think:

Git
 ↓
Source code
 ↓
CI
 ↓
Build
 ↓
Artifact

For example:

Git repository
├── app.py
├── tests/
└── requirements.txt

CI builds application

Artifact:
└── application.zip

You don't normally commit generated build output into Git merely because you need it later.

Q19. Why shouldn't we commit test-result.txt into Git?

Because it is generated CI output.

If every CI run modifies:

test-result.txt

and commits it, the repository becomes polluted with generated state.

Instead:

Source
   ↓
Git
   ↓
CI
   ↓
Generated result
   ↓
Artifact

This maintains separation between:

source of truth

and:

generated output
Part 3 — Production Scenarios
Q20. Your build succeeds but deployment job can't find the build artifact. What do you check?

I would troubleshoot systematically.

Step 1 — Confirm build job succeeded
build ✓
Step 2 — Check artifact upload step

Look for:

Artifact successfully uploaded
Step 3 — Verify artifact name

For example:

name: production-build

and make sure the download job uses:

name: production-build
Step 4 — Verify upload path

Check:

path: dist/

and verify that dist/ actually exists.

Step 5 — Verify job dependency

Check:

needs: build
Step 6 — Check retention/expiration

An artifact may no longer exist if it expired.

Step 7 — Check download logs

Look for:

Artifact not found

or permission/access problems.

Q21. Suppose the upload step says "No files were found." What do you check?

I would check:

1. Does the file actually exist?
ls -la
find . -type f
2. Is the path correct?

For example:

path: artifacts/

versus:

path: artifact/
3. Is the working directory what I expect?

The runner's current directory matters.

4. Was the file generated earlier?

Check the previous step.

5. Are shell commands failing silently?

Inspect:

run: |

steps.

6. Did a previous step generate the file somewhere else?

This was essentially our Project 05 failure.

Q22. Why did we verify the artifact before uploading it?

Because troubleshooting becomes much easier.

We had:

- name: Verify test artifacts
  run: |
    find artifacts -type f

Then:

Generate
   ↓
Verify
   ↓
Upload

If upload fails, we know:

Generation ✓
Verification ✓
Upload ❌

That dramatically narrows the problem.

Without verification:

Generation ?
Upload ❌

We wouldn't immediately know whether generation or upload was responsible.

Q23. Why is observability important in CI/CD?

Because a pipeline is an execution system.

If something fails, we need evidence.

Our Project 05 pipeline deliberately used:

find
ls
cat

to expose state.

For example:

Generate
   ↓
find artifacts/
   ↓
3 files visible
   ↓
upload

This is CI/CD observability.

Part 4 — Senior-Level Questions
Q24. Why use artifacts instead of passing files through environment variables?

Because environment variables are appropriate for small configuration values, not large structured build outputs.

Bad:

BUILD_BINARY=<huge binary>

Better:

artifact:
  application.zip

Environment variables are suitable for:

VERSION=1.2.3
ENVIRONMENT=production

Artifacts are suitable for:

application.zip
test-report.html
coverage.xml
Q25. What happens if two workflows use the same artifact name?

Artifact names are associated with workflow runs, so the same name can exist across different runs.

For example:

Run 100
  └── python-test-artifacts

Run 101
  └── python-test-artifacts

The important thing is to reference the correct run/context when downloading.

Q26. What would you store as CI artifacts in a production pipeline?

A strong answer:

I would store outputs that are useful after the runner terminates and that need to be consumed by humans or downstream jobs.

Examples:

Build artifacts
application.zip
frontend-dist/
binary
Test artifacts
JUnit XML
coverage reports
HTML test reports
screenshots
Security artifacts
SAST report
dependency scan report
IaC scan report
SBOM
Troubleshooting artifacts
application logs
debug bundles
diagnostic output
Q27. Should secrets be uploaded as artifacts?

Absolutely not.

Never deliberately upload:

.env
private keys
AWS credentials
password files
tokens
service-account credentials

Artifacts are persisted and potentially accessible to people with appropriate repository/workflow permissions.

Secrets should be handled through:

GitHub Secrets
OIDC
Secret Manager
Vault

depending on the architecture.

Q28. Artifact or container registry — which one should store a Docker image?

For production container delivery, generally use a container registry, not a generic CI artifact.

For example:

CI
 ↓
docker build
 ↓
image
 ↓
Amazon ECR / GHCR / another registry
 ↓
Deployment

Artifacts are better suited to:

reports
logs
zip files
test outputs
temporary build outputs

A container registry provides image-specific capabilities such as:

tags
image manifests
layers
vulnerability scanning
registry authentication
image lifecycle management
Q29. What is the difference between an artifact and a release?

A CI artifact is generally associated with a workflow run.

A release represents a versioned software distribution.

For example:

Commit
 ↓
CI
 ↓
Artifact
 ↓
Validation
 ↓
Release v1.4.0

Artifacts can be intermediate outputs.

A release is a product/versioning concept.

Q30. Explain Project 05 in an interview in 60 seconds.

This is the answer I want you to eventually be able to deliver naturally:

"In Project 05, I implemented GitHub Actions artifact management. I started with a Python CI workflow that ran pytest and generated CI output files. I verified those files inside the GitHub runner and then used actions/upload-artifact@v4 to persist them. I progressed from a single file to a multi-file artifact and configured seven-day retention. I then created a second job using needs and actions/download-artifact@v5 to transfer the artifact across job boundaries and verify its contents.

I also deliberately introduced an incorrect artifact path, which caused the upload step to produce no artifact and the downstream job to fail with 'Artifact not found.' I traced the dependency chain back to the first failure, corrected the upload path, and verified that both jobs returned to green. So the project covered the complete artifact lifecycle: generation, verification, upload, retention, cross-job transfer, download, failure diagnosis, and recovery."
