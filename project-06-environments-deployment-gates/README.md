Project 06 — GitHub Actions Environments & Deployment Gates
📌 Project Overview

This project demonstrates how to build a controlled CI/CD pipeline using GitHub Actions Environments and deployment protection rules.

The objective is to move beyond simple CI testing and implement a basic continuous delivery promotion model:

                    Developer
                       │
                       │ git push
                       ▼
              ┌──────────────────┐
              │ GitHub Repository │
              └────────┬─────────┘
                       │
                       ▼
              ┌──────────────────┐
              │   Test Job       │
              │                  │
              │ Python 3.12      │
              │ Install pytest   │
              │ Run tests        │
              └────────┬─────────┘
                       │
                    SUCCESS
                       │
                       ▼
              ┌──────────────────┐
              │   Development   │
              │    Environment  │
              │                  │
              │ DEPLOYMENT_TARGET│
              └────────┬─────────┘
                       │
                    SUCCESS
                       │
                       ▼
              ┌──────────────────┐
              │     Staging      │
              │    Environment  │
              │                  │
              │ Approval Gate    │
              └────────┬─────────┘
                       │
                  APPROVAL
                       │
                       ▼
                Deployment

The important concept is:

CI validates the software. CD controls how validated software is promoted between environments.

1. Business Problem

In a real organization, we normally don't want:

Developer pushes code
        ↓
Automatically deploy to Production

That creates several risks:

untested changes
accidental production deployments
unauthorized releases
lack of approval
poor change control
difficult rollback decisions
no separation between validation and release authorization

Instead, enterprises commonly implement:

Code
 ↓
Build
 ↓
Test
 ↓
Development
 ↓
Staging
 ↓
Approval
 ↓
Production

Project 06 introduces this concept using GitHub Actions Environments.

2. Learning Objectives

By completing this project, you learn:

GitHub Actions environments
environment-specific variables
deployment jobs
job dependencies
needs
deployment promotion
required reviewers
deployment protection rules
staging approval gates
CI/CD separation
deployment sequencing
workflow execution analysis
GitHub Actions job logs
GitHub CLI workflow inspection
YAML workflow structure
deployment candidate generation
3. Technology Stack
Technology	Purpose
Git	Source control
GitHub	Repository
GitHub Actions	CI/CD automation
GitHub Environments	Environment isolation
GitHub Environment Variables	Environment-specific configuration
GitHub Deployment Protection Rules	Approval gates
Python 3.12	Application
pytest	Automated testing
Ubuntu	GitHub Actions runner
GitHub CLI	Workflow inspection
4. Repository Structure

Current project structure:

CI-CD-mastery/
│
├── .github/
│   └── workflows/
│       ├── project-03-ci.yml
│       ├── project-04-matrix.yml
│       ├── project-05-artifacts.yml
│       └── project-06-ci.yml
│
├── project-03-branch-path-ci/
│
├── project-04-matrix-ci/
│
├── project-05-ci-artifacts/
│
└── project-06-environments-deployment-gates/
    │
    ├── app.py
    ├── test_app.py
    └── README.md

The Project 06 workflow is:

.github/workflows/project-06-ci.yml
5. Application

The project contains a small Python application.

Conceptually, the application exposes:

APP_VERSION = "1.0.0"
DEFAULT_ENVIRONMENT = "development"

and:

get_application_info(environment)

returns information such as:

Application Version: 1.0.0
Environment: development

This deliberately simple application allows us to concentrate on CI/CD architecture rather than application complexity.

6. Automated Tests

The project contains:

test_app.py

The test verifies:

Version = 1.0.0
Environment = development
Message contains expected values

The CI pipeline executes:

python -m pytest -q

Expected result:

1 passed

The important principle is:

Deployment should depend on successful validation.

7. GitHub Actions Workflow

The workflow is:

.github/workflows/project-06-ci.yml

The pipeline contains three logical stages:

test
  ↓
deploy-development
  ↓
deploy-staging

The dependency chain is created with:

needs: test

and:

needs: deploy-development

Therefore:

test
 ↓
development
 ↓
staging
8. Workflow Trigger

The workflow executes when code is pushed to:

on:
  push:
    branches:
      - project-06-environments-deployment-gates

It also responds to pull requests targeting:

pull_request:
  branches:
    - main

This gives us two important CI/CD paths.

Feature/project branch
Developer
   ↓
Push
   ↓
Project 06 CI
Pull Request
Feature branch
      ↓
Pull Request
      ↓
main
      ↓
CI validation
9. Test Job

The first job is:

test:
  name: Test Application
  runs-on: ubuntu-latest

The GitHub-hosted runner provides a temporary Ubuntu machine.

The workflow then establishes:

defaults:
  run:
    working-directory: project-06-environments-deployment-gates

This means shell commands execute from the project directory.

10. Checkout

The pipeline uses:

- name: Checkout repository
  uses: actions/checkout@v4

Why?

Because the GitHub Actions runner starts with a clean workspace.

The repository source code is not automatically available.

actions/checkout retrieves the repository content.

Conceptually:

GitHub Repository
       │
       │ checkout
       ▼
GitHub Runner Workspace
11. Python Setup

The workflow uses:

- name: Set up Python
  uses: actions/setup-python@v5
  with:
    python-version: "3.12"

This ensures that CI uses a known Python version rather than relying on whatever happens to be installed on the runner.

This improves:

reproducibility
consistency
debugging
dependency compatibility
12. Installing pytest

The workflow executes:

python -m pip install pytest

This installs the test framework.

Then:

python -m pytest -q

runs the tests.

13. Deployment Candidate

After tests succeed, the workflow generates:

deployment-candidate/

containing:

application-output.txt
version.txt
deployment-status.txt

Example:

deployment-candidate/
├── application-output.txt
├── version.txt
└── deployment-status.txt

The status contains:

Deployment Candidate: READY

This introduces an important CD concept:

A deployment should consume a validated release candidate rather than blindly rebuilding or changing the code between environments.

In a more advanced pipeline, this candidate would typically become:

Docker image
package
artifact
Helm chart
release bundle
14. Development Environment

The workflow contains:

deploy-development:
  name: Deploy to Development
  runs-on: ubuntu-latest
  needs: test

  environment:
    name: development

The important part is:

needs: test

Therefore Development cannot start until:

Test Application = SUCCESS
15. GitHub Environment

We created a GitHub environment:

development

and another environment:

staging

GitHub Environments provide a logical boundary around deployment configuration.

For example:

development
    └── DEPLOYMENT_TARGET=development.example

staging
    └── DEPLOYMENT_TARGET=staging.example

The same workflow can therefore deploy to different targets without hard-coding environment-specific values into the application.

16. Environment Variables

The deployment uses:

${{ vars.DEPLOYMENT_TARGET }}

This is an important GitHub Actions expression.

It means:

Read DEPLOYMENT_TARGET
from the environment associated
with this deployment job.

For example:

development
      ↓
DEPLOYMENT_TARGET
      ↓
development.example

and:

staging
      ↓
DEPLOYMENT_TARGET
      ↓
staging.example

This is significantly better than writing:

echo "development.example"

directly into the workflow.

17. Development Deployment

The deployment job prints:

========================================
Deployment Environment: development
Deployment Target: development.example
Application Version: 1.0.0
Deployment Status: SUCCESS
========================================

Although this project uses a simulated deployment, the workflow structure is the same conceptually as a real deployment.

A production implementation could replace the echo commands with:

kubectl apply
helm upgrade
aws ecs update-service
aws eks
terraform
Ansible
SSH
cloud deployment API
18. Staging Deployment

The staging job is:

deploy-staging:
  name: Deploy to Staging
  runs-on: ubuntu-latest
  needs: deploy-development

  environment:
    name: staging

The important dependency is:

needs: deploy-development

Therefore:

Test
 ↓
Development
 ↓
Staging

Staging cannot begin until Development succeeds.

19. Deployment Gate

The staging environment has a:

Required reviewer

configured.

Therefore GitHub Actions can pause the workflow before deployment.

Conceptually:

Development
     │
     ▼
Staging requested
     │
     ▼
┌───────────────────────┐
│ Deployment Approval   │
│                       │
│ Required reviewer     │
└───────────┬───────────┘
            │
       APPROVED
            │
            ▼
     Staging deployment

This is the core lesson of Project 06.

20. Why Deployment Gates Matter

Imagine a banking organization.

A developer commits:

Change interest calculation

CI passes.

Should that automatically reach production?

No.

The release may require:

QA approval
business approval
change-management approval
security approval
operations approval

A deployment gate creates this control point.

21. Complete Pipeline

Your Project 06 architecture can be understood as:

                     Git Push
                        │
                        ▼
              ┌──────────────────┐
              │ GitHub Actions    │
              │ Workflow          │
              └────────┬─────────┘
                       │
                       ▼
              ┌──────────────────┐
              │ Test Application │
              │                  │
              │ Python 3.12      │
              │ pytest            │
              └────────┬─────────┘
                       │
                    PASS
                       │
                       ▼
              ┌──────────────────┐
              │ Development      │
              │ Environment      │
              └────────┬─────────┘
                       │
                    PASS
                       │
                       ▼
              ┌──────────────────┐
              │ Staging          │
              │ Environment      │
              │                  │
              │ Approval Gate    │
              └────────┬─────────┘
                       │
                    APPROVE
                       │
                       ▼
              ┌──────────────────┐
              │ Staging Deploy   │
              └──────────────────┘
22. Dependency Graph

The GitHub Actions dependency graph is:

             ┌──────────┐
             │   test   │
             └────┬─────┘
                  │
             needs: test
                  │
                  ▼
       ┌─────────────────────┐
       │ deploy-development  │
       └──────────┬──────────┘
                  │
       needs: deploy-development
                  │
                  ▼
          ┌──────────────┐
          │ deploy-stage │
          └──────────────┘

This is fundamentally different from simply listing jobs.

Without needs, jobs can execute independently.

With needs, we create a directed dependency graph.

23. Important GitHub Actions Concepts Learned
runs-on

Defines the runner:

runs-on: ubuntu-latest
needs

Defines job dependency:

needs: test

Meaning:

Don't execute this job until test succeeds.

environment

Associates the job with a GitHub environment:

environment:
  name: staging
vars

Reads environment/repository configuration variables:

${{ vars.DEPLOYMENT_TARGET }}
uses

Uses a reusable GitHub Action:

uses: actions/checkout@v4
run

Executes shell commands:

run: python -m pytest -q
24. Verification Commands

We used GitHub CLI extensively.

Check recent workflow runs:

gh run list --limit 5

Inspect a specific run:

gh run view <RUN_ID>

View complete logs:

gh run view <RUN_ID> --log

Filter logs:

gh run view <RUN_ID> --log | \
grep -E "Deployment Environment|Deployment Target|Application Version|Deployment Status"

This is a very useful DevOps troubleshooting technique.

25. Successful Execution

The successful workflow demonstrated:

✓ Test Application
✓ Deploy to Development
✓ Deploy to Staging

The deployment logs showed:

Deployment Environment: development
Deployment Target: development.example
Application Version: 1.0.0
Deployment Status: SUCCESS

This proves that the environment variable was correctly injected into the deployment job.

26. Node.js Deprecation Warning

The workflow produced warnings similar to:

Node.js 20 is deprecated

This came from GitHub Actions internally because some versions of:

actions/checkout
actions/setup-python

target Node.js 20 while GitHub's runner is transitioning execution to Node.js 24.

Important:

This was a warning, not a pipeline failure.

The workflow still completed successfully.

As a DevOps engineer, you should distinguish:

ERROR

from:

WARNING

rather than treating every annotation as a failed deployment.

27. Local Validation

Before committing the workflow, we validated it with:

git diff --check

This detects whitespace errors.

We also parsed the YAML using Ruby:

ruby -e '
require "yaml"
data = YAML.load_file(".github/workflows/project-06-ci.yml")
puts "YAML syntax: OK"
'

And inspected the job structure:

JOB: test
  needs: nil
  environment: nil

JOB: deploy-development
  needs: "test"
  environment: development

JOB: deploy-staging
  needs: "deploy-development"
  environment: staging

This is good engineering practice.

28. Git Workflow

Project 06 used a dedicated branch:

project-06-environments-deployment-gates

The branch was pushed to:

origin/project-06-environments-deployment-gates

Final verification:

git status

resulted in:

nothing to commit, working tree clean

and:

git log --oneline --decorate -n 5

showed the Project 06 commits.

29. What This Project Simulates

This project simulates a simplified enterprise release process.

Development

Developers validate their changes.

Staging

QA/operations validate the release candidate.

Production

A controlled approval should authorize production release.

Real deployments would replace:

echo "Deployment Status: SUCCESS"

with actual deployment mechanisms.

30. How This Evolves Into Enterprise CD

The current project:

Test
 ↓
Development
 ↓
Staging

can evolve into:

Test
 ↓
Build
 ↓
Security Scan
 ↓
Package
 ↓
Artifact
 ↓
Development
 ↓
Integration Tests
 ↓
Staging
 ↓
Approval
 ↓
Production
 ↓
Smoke Tests
 ↓
Monitoring

Eventually:

GitHub Actions
      │
      ▼
Docker
      │
      ▼
Amazon ECR
      │
      ▼
Amazon EKS
      │
      ▼
Helm
      │
      ▼
Production

That is where this learning becomes directly applicable to enterprise DevOps.

31. Interview Questions — Basic
Q1. What is a GitHub Actions Environment?

Answer:

A GitHub Actions Environment is a logical deployment target that allows us to associate configuration, variables, secrets, and deployment protection rules with a specific environment.

Examples:

development
staging
production

A job can reference an environment:

environment:
  name: staging

GitHub then applies the configuration and protection rules associated with that environment.

Q2. Why did you create separate Development and Staging environments?

Answer:

Because different deployment stages have different purposes and configuration.

Development is generally used for developer validation.

Staging should represent a production-like environment where the release candidate is validated before production.

Separating them allows us to control:

configuration
secrets
variables
approvals
deployment permissions
32. Q3. What does needs do?

Answer:

needs creates a dependency between jobs.

For example:

deploy-development:
  needs: test

means Development runs only after the Test job completes successfully.

Similarly:

deploy-staging:
  needs: deploy-development

creates:

test
 ↓
development
 ↓
staging

Without needs, jobs may execute independently.

33. Q4. What happens if the test job fails?

The Development deployment does not proceed.

Because:

deploy-development:
  needs: test

depends on the successful completion of:

test

Therefore:

Test FAILED
    ↓
Development SKIPPED
    ↓
Staging SKIPPED

This is a critical CI/CD safety mechanism.

34. Q5. What is a deployment protection rule?

A deployment protection rule is a control that must be satisfied before a deployment can proceed.

Examples include:

required reviewers
wait timers
custom protection rules

In this project, we used:

Required reviewer

for the staging environment.

35. Q6. What is a deployment gate?

A deployment gate is a control point between pipeline stages that determines whether deployment can continue.

For example:

Development
     ↓
Approval Gate
     ↓
Staging

The gate prevents automatic promotion until the required condition is satisfied.

36. Q7. Why use an approval gate?

Because deployment and validation are different concerns.

CI can determine:

Does the software pass automated validation?

But an approval gate can determine:

Are we authorized and ready to release this software?

This is especially important for:

production
banking
healthcare
government
regulated environments
37. Q8. What is the difference between CI and CD?
CI

Continuous Integration focuses on:

Build
Test
Validate
CD

Continuous Delivery/Deployment focuses on:

Package
Release
Deploy
Promote

Project 06 bridges the two:

CI
 ↓
Test
 ↓
CD
 ↓
Development
 ↓
Staging
 ↓
Approval
38. Q9. What is ${{ vars.DEPLOYMENT_TARGET }}?

It is a GitHub Actions expression that retrieves the configured variable:

DEPLOYMENT_TARGET

from the appropriate variable scope.

In our environment:

development

the value could be:

development.example

while staging could have:

staging.example

This allows the same workflow to behave differently depending on the target environment.

39. Q10. Why shouldn't environment configuration be hard-coded?

Bad:

run: deploy development.example

Better:

run: deploy ${{ vars.DEPLOYMENT_TARGET }}

The second approach provides:

separation of configuration
reusable workflows
easier promotion
reduced duplication
easier environment management
40. Intermediate Interview Questions
Q11. What is the difference between a repository variable and an environment variable?

A repository variable is generally available at repository scope.

An environment variable belongs to a specific GitHub Environment.

For example:

Repository
 └── APP_NAME

Development Environment
 └── DEPLOYMENT_TARGET=dev.example

Staging Environment
 └── DEPLOYMENT_TARGET=staging.example

Environment-specific values are useful because Development and Staging should not necessarily use the same target.

41. Q12. What is the difference between vars and secrets?

vars are intended for configuration values that are not sensitive.

Example:

DEPLOYMENT_TARGET=staging.example

Secrets are intended for sensitive values such as:

API_TOKEN
PASSWORD
PRIVATE_KEY

You should not put credentials into normal variables.

42. Q13. Can a deployment job run before testing?

Not in our dependency chain.

We explicitly created:

needs: test

Therefore:

test → deployment

If the dependency is removed, GitHub Actions may schedule the jobs independently.

43. Q14. What is the difference between needs and if?

needs defines a job dependency.

Example:

needs: test

if defines a conditional execution rule.

Example:

if: github.ref == 'refs/heads/main'

They solve different problems.

44. Q15. What happens if staging approval is rejected?

The staging deployment does not proceed.

The workflow is effectively blocked at the environment protection stage.

The release therefore does not move forward until the protection requirement is satisfied.

45. Q16. Can an environment contain secrets?

Yes.

An environment can contain:

Environment secrets
Environment variables
Deployment protection rules
Deployment branch restrictions

This allows different credentials/configuration to be associated with:

development
staging
production
46. Q17. Why is environment-level configuration useful for production?

Imagine:

Development:
AWS account A

Staging:
AWS account B

Production:
AWS account C

The deployment workflow can remain structurally similar while each environment supplies its own configuration and credentials.

This reduces hard-coded environment logic.

47. Senior-Level Interview Questions
Q18. How would you redesign this pipeline for production?

I would evolve:

Test
 ↓
Development
 ↓
Staging
 ↓
Approval
 ↓
Production

into:

Checkout
 ↓
Lint
 ↓
Unit Tests
 ↓
Security Scan
 ↓
Build
 ↓
Container Image
 ↓
Image Scan
 ↓
Push to Registry
 ↓
Deploy Development
 ↓
Integration Tests
 ↓
Deploy Staging
 ↓
Smoke Tests
 ↓
Manual Approval
 ↓
Production
 ↓
Post-deployment Verification

I would also introduce:

immutable artifacts
image tagging
artifact promotion
least-privilege IAM
OIDC
environment-specific credentials
rollback
health checks
monitoring
audit logs
48. Q19. Why should the same artifact be promoted between environments?

This is one of the most important production CI/CD concepts.

Bad approach:

Build version A
 ↓
Development

Build version B
 ↓
Staging

Build version C
 ↓
Production

Now we don't know whether Production is actually running what Staging tested.

Better:

Build artifact
      │
      ▼
Development
      │
      ▼
Staging
      │
      ▼
Production

The exact same immutable artifact is promoted.

This gives us:

Build once, deploy many.

49. Q20. How would you implement rollback?

A mature deployment system should retain previous versions.

For example:

Version 1.0
Version 1.1
Version 1.2

If:

1.2 → Production
      ↓
   Failure

we can roll back:

Production
    ↓
1.1

For Kubernetes, this could involve:

helm rollback

or deployment revision rollback.

For container platforms, we can redeploy the previous immutable image.

50. Q21. How would you prevent unauthorized production deployments?

I would use multiple controls:

Protected main branch
        +
Required PR reviews
        +
CI checks
        +
GitHub Environment
        +
Required reviewers
        +
Restricted deployment branches
        +
Least-privilege credentials

This creates defense in depth.

51. Q22. Why shouldn't developers have unrestricted production deployment permissions?

Because production deployment is a high-impact operation.

If every developer can deploy directly:

Developer
   ↓
Production

there is little separation of responsibility.

A controlled system is:

Developer
   ↓
PR
   ↓
Automated validation
   ↓
Review
   ↓
Deployment approval
   ↓
Production
52. Q23. What is separation of duties?

Separation of duties means critical actions should not necessarily be controlled by the same person.

For example:

Developer → writes code
QA → validates release
Operations → manages infrastructure
Release approver → authorizes production

This reduces operational and security risk.

53. Q24. What is the biggest limitation of the current Project 06 implementation?

The deployment is currently simulated.

We use:

echo "Deployment Status: SUCCESS"

rather than actually deploying an application.

That is intentional for this learning stage.

The next maturity level would replace the simulation with:

Docker
ECR
EKS
Helm
AWS
Terraform

or another deployment platform.

54. Q25. How would you deploy this application to Kubernetes?

A mature version could use:

GitHub Actions
      ↓
Docker build
      ↓
Trivy scan
      ↓
Amazon ECR
      ↓
Helm
      ↓
EKS

The deployment job could execute:

helm upgrade --install

against the target environment.

55. Q26. How would you handle AWS credentials?

I would avoid storing long-lived AWS access keys.

Instead, I would use:

GitHub Actions
       ↓
OIDC
       ↓
AWS IAM Role
       ↓
Temporary credentials

This provides short-lived credentials and eliminates the need to store permanent AWS secrets.

56. Q27. What would you monitor after deployment?

A production deployment should not end at:

Deployment successful

I would verify:

Application
HTTP status
Response time
Error rate
Availability
Infrastructure
CPU
Memory
Network
Pod health
Node health
Business
Transaction failures
Request volume
Success rate

A mature CD pipeline therefore becomes:

Deploy
 ↓
Verify
 ↓
Monitor
 ↓
Decide
57. Q28. What is the difference between Continuous Delivery and Continuous Deployment?
Continuous Delivery

The software is always in a releasable state, but production deployment may require approval.

CI
 ↓
Staging
 ↓
Approval
 ↓
Production
Continuous Deployment

A successful pipeline automatically deploys to production.

CI
 ↓
Tests
 ↓
Production

Our Project 06 is closer to Continuous Delivery because the environment gate introduces controlled promotion.

58. Q29. Why is staging important?

Staging should ideally resemble Production as closely as practical.

It allows us to test:

Application
Configuration
Dependencies
Infrastructure
Integration
Deployment process

before impacting real users.

59. Q30. Explain your Project 06 in an interview in 60 seconds.

Use this answer:

"In Project 06, I implemented a GitHub Actions CI/CD pipeline using GitHub Environments and deployment protection rules. The pipeline first checks out the Python application, installs Python 3.12 and pytest, runs automated tests, and generates a deployment candidate. After successful testing, the application is promoted to a Development environment. The Development deployment is connected to the Staging deployment using GitHub Actions needs, creating a controlled promotion chain. I configured environment-specific variables such as DEPLOYMENT_TARGET and configured a required reviewer as a deployment protection rule for Staging. This demonstrated the difference between automated CI validation and controlled CD promotion. In a production implementation, I would extend this using immutable Docker artifacts, ECR, Kubernetes/EKS, OIDC-based AWS authentication, security scanning, smoke tests, monitoring, and automated rollback."

That is a strong junior-to-mid/senior transition answer because you explain not only what you built, but why.

60. Interview Whiteboard Question

An interviewer may ask:

"Design a CI/CD pipeline where developers cannot directly deploy to production."

Draw:

                 Developer
                     │
                     ▼
                  Git Push
                     │
                     ▼
               ┌───────────┐
               │    CI     │
               │           │
               │ Test      │
               │ Lint      │
               │ Scan      │
               └─────┬─────┘
                     │
                   PASS
                     │
                     ▼
               ┌───────────┐
               │   Build   │
               │ Immutable │
               │ Artifact  │
               └─────┬─────┘
                     │
                     ▼
               Development
                     │
                     ▼
                Integration
                   Tests
                     │
                     ▼
                  Staging
                     │
                     ▼
             ┌──────────────┐
             │ Approval Gate│
             └──────┬───────┘
                    │
                 APPROVED
                    │
                    ▼
                Production
                    │
                    ▼
             Smoke / Health
                  Checks
                    │
             ┌──────┴──────┐
             │             │
           PASS          FAIL
             │             │
             ▼             ▼
          Monitor       Rollback

If you can explain this architecture clearly, you understand the fundamental CD control model.

61. Project 06 Key Takeaways

You should now be able to explain:

GitHub Actions
      ↓
Jobs
      ↓
needs
      ↓
Environments
      ↓
Environment Variables
      ↓
Deployment
      ↓
Protection Rules
      ↓
Required Reviewer
      ↓
Controlled Promotion

The most important mental model is:

CI answers "Is this change technically valid?"

CD answers "How and where should this validated change be released?"

Deployment gates answer "Is this release authorized to proceed?"

62. Final Project Status
Project 06 — Environments & Deployment Gates

Application              ✅
Automated tests          ✅
GitHub Actions           ✅
Development environment  ✅
Staging environment      ✅
Environment variable     ✅
Job dependencies         ✅
Deployment gate          ✅
Required reviewer        ✅
Staging deployment       ✅
Workflow verification    ✅
Git push                 ✅
Working tree clean       ✅
🏆 Project 06 COMPLETE
Your CI/CD mastery progression so far
Project 01
Basic CI
   ↓
Project 02
Pull Request CI
   ↓
Project 03
Branch & Path CI
   ↓
Project 04
Matrix CI
   ↓
Project 05
CI Artifacts
   ↓
Project 06
Environments & Deployment Gates
   ↓
Project 07
?????
