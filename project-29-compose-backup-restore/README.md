# 🚀 Project 29 — Enterprise Docker Compose Backup & Restore

> **Production-oriented Docker Compose persistent-data protection with named volumes, application-level data persistence, temporary backup artifacts, restore validation, data integrity verification, non-root execution, and automated CI/CD.**

![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?logo=docker&logoColor=white)
![Python](https://img.shields.io/badge/Python-3.12-3776AB?logo=python&logoColor=white)
![Flask](https://img.shields.io/badge/Flask-3.1-000000?logo=flask&logoColor=white)
![Gunicorn](https://img.shields.io/badge/Gunicorn-Production-499848)
![Pytest](https://img.shields.io/badge/Tests-Pytest-success)
![CI/CD](https://img.shields.io/badge/GitHub_Actions-CI%2FCD-2088FF?logo=githubactions&logoColor=white)
![Security](https://img.shields.io/badge/Container-Security-success)
![Status](https://img.shields.io/badge/Project-Complete-success)

---

# 🎯 Executive Summary

Application containers are disposable.

Application **data should not be**.

A production container can be recreated, upgraded, or destroyed while its persistent application data must remain available.

This project demonstrates a complete Docker Compose backup and restore lifecycle:

```text
Application
     │
     ▼
Named Docker Volume
     │
     ▼
Persistent Application Data
     │
     ├──────────────► Backup
     │                   │
     │                   ▼
     │             Temporary Archive
     │
     ▼
Data Deletion
     │
     ▼
Restore
     │
     ▼
Data Integrity Validation
     │
     ▼
Application Recovery

The project validates that data can:

Be persisted
Be written
Be backed up
Be deleted
Be restored
Be verified
Remain available to the application

The backup artifact is deliberately temporary and excluded from Git.

🏗️ Architecture
                    ┌───────────────────┐
                    │      Client       │
                    └─────────┬─────────┘
                              │
                              ▼
                    ┌───────────────────┐
                    │ Flask + Gunicorn  │
                    │                   │
                    │ UID 10001         │
                    └─────────┬─────────┘
                              │
                              │ /data
                              ▼
                    ┌───────────────────┐
                    │ Docker Named      │
                    │ Volume            │
                    │                   │
                    │ app-data          │
                    └─────────┬─────────┘
                              │
                              │
                 ┌────────────┴────────────┐
                 │                         │
                 ▼                         ▼
           Backup Process             Restore Process
                 │                         │
                 ▼                         ▼
        Temporary tar.gz            Extract to volume
                 │                         │
                 └────────────┬────────────┘
                              ▼
                     Data Integrity Check
💡 Why This Project Matters

Containers are designed to be replaceable.

Consider:

Container
   │
   ├── Version 1
   │
   ├── Destroyed
   │
   └── Version 2

If application data exists only inside the container filesystem:

Container deleted
       │
       ▼
Data lost

With persistent storage:

Container
    │
    ▼
Named Volume
    │
    ▼
Persistent Data

The container can be recreated without losing application state.

📌 Project Objectives

This project demonstrates:

Docker named volumes
Persistent application data
Application-level data APIs
Backup creation
Backup verification
Data deletion
Restore operation
Data integrity validation
Temporary backup artifacts
Backup exclusion from Git
Non-root execution
no-new-privileges
Docker healthchecks
Pytest
Docker Compose
GitHub Actions
🧩 Core Concepts
1. Docker Volumes

The application uses:

volumes:
  - app-data:/data

Docker manages the persistent storage independently of the application container.

Conceptually:

Container
   │
   │ /data
   ▼
Named Volume
   │
   ▼
Persistent Storage

The volume is named:

project-29-backup-restore-data
🎤 Interview Concept
Q: Why use Docker volumes?

Docker volumes provide persistent storage that exists independently of a container's lifecycle. This allows application data to survive container recreation.

2. Persistent vs Ephemeral Data
Ephemeral container storage
Container
   │
   ▼
Container filesystem
   │
   ▼
Container removed
   │
   ▼
Data lost
Persistent volume
Container
   │
   ▼
Named volume
   │
   ▼
Container removed
   │
   ▼
Volume remains

This distinction is fundamental to stateful containerized applications.

3. Application Data

The application stores data at:

/data/application.json

The data looks conceptually like:

{
  "application": "backup-restore",
  "version": 1,
  "records": [
    {
      "id": 1,
      "name": "backup-test",
      "environment": "production"
    }
  ]
}

The application exposes:

GET    /data
POST   /data
DELETE /data

This provides a simple but realistic way to demonstrate persistence.

4. Atomic Data Writes

The application does not directly overwrite the primary data file.

Instead it uses:

tempfile.mkstemp()

followed by:

os.replace()

Conceptually:

application.json
      │
      │ write
      ▼
temporary file
      │
      │ successful write
      ▼
atomic replacement
      │
      ▼
application.json

This reduces the risk of leaving a partially written application data file if the process is interrupted during a write.

🎤 Interview Concept
Q: Why use atomic writes?

Atomic replacement reduces the chance of consumers seeing a partially written data file. The application writes a temporary file first and replaces the target only after the write completes successfully.

5. Backup

The project creates a temporary archive:

application-data.tar.gz

The Docker volume is mounted read-only:

volume:/data:ro

and the backup directory is mounted separately.

Conceptually:

Named Volume
     │
     │ read-only
     ▼
Backup Container
     │
     ▼
tar.gz archive
🔐 Why Read-Only During Backup?

The backup operation does not need to modify application data.

Therefore:

/data:ro

provides a safer backup workflow.

🎤 Interview Concept
Q: Why mount the source volume read-only during backup?

The backup process only needs to read application data. A read-only mount reduces the possibility of the backup process accidentally modifying production data.

6. Backup Artifact

The backup is intentionally created under:

backups/

but this directory is excluded from Git.

.gitignore contains:

backups/
*.tar
*.tar.gz
*.tgz

This is important because backup archives can contain sensitive or production application data.

🚨 Why Never Commit Backups?

A backup may contain:

customer information
credentials
application state
database exports
internal configuration
personal information

Therefore:

Backup artifact
       │
       ├── temporary
       ├── tested
       └── NOT committed
🎤 Interview Concept
Q: Why shouldn't backup files be stored in Git?

Git is source-control infrastructure, not a production backup repository. Backup artifacts can contain sensitive data, grow rapidly, and create unnecessary repository history and storage problems.

7. Backup Verification

Creating a backup is not enough.

The project verifies that the archive can actually be read:

tar -tzf application-data.tar.gz

This verifies archive structure before relying on it for restoration.

Conceptually:

Backup Created
      │
      ▼
Archive Inspection
      │
      ▼
Valid Archive
      │
      ▼
Restore Test
8. Restore

The restore process extracts the temporary archive back into the persistent volume.

Backup Archive
      │
      ▼
Restore Container
      │
      ▼
Named Volume
      │
      ▼
Application

The restore process demonstrates that application state can be reconstructed from the backup artifact.

9. Destructive Test

A strong backup test should not simply create a backup and declare success.

This project intentionally removes the original application data:

Original Data
     │
     ▼
Backup
     │
     ▼
Delete Original
     │
     ▼
Restore
     │
     ▼
Compare Expected Data

This simulates an actual recovery scenario.

🎤 Interview Concept
Q: Why delete the data during the test?

Because a backup that has never been restored is only an assumption. The test deliberately removes the original data and verifies that the application can recover from the backup.

This is a strong backup validation principle.

10. Data Integrity Validation

After restoration, the project validates:

id = 1
name = backup-test
environment = production

The CI pipeline parses the restored JSON rather than relying on text formatting.

This is important because:

String matching
      ↓
Formatting dependent

whereas:

JSON parsing
      ↓
Semantic validation

is more reliable.

🎤 Interview Concept
Q: How do you validate a backup?

I don't only verify that an archive exists. I restore it into the persistent volume and validate the recovered application data semantically.

11. RPO and RTO

Backup systems are often evaluated using two important concepts.

RPO — Recovery Point Objective

RPO answers:

How much data can we afford to lose?

Example:

Backup every 1 hour
        ↓
Worst-case data loss ≈ 1 hour
RTO — Recovery Time Objective

RTO answers:

How quickly must the service be restored?

Example:

Failure
   ↓
Backup retrieval
   ↓
Restore
   ↓
Application recovery

Target: < 30 minutes
🎤 Interview Question
Q: What is the difference between RPO and RTO?

RPO defines the maximum acceptable amount of data loss, while RTO defines the maximum acceptable time required to restore service.

12. Backup vs Snapshot

A Docker volume backup archive and a storage snapshot are not exactly the same.

File-level backup
Files
 ↓
Archive
 ↓
Object/file storage
Volume snapshot
Storage volume
      ↓
Point-in-time snapshot

Snapshots can provide faster recovery, while file-level backups can offer portability.

The correct strategy depends on the storage platform and recovery requirements.

13. Healthchecks

The application exposes:

GET /health

Docker checks:

healthcheck:
  interval: 5s
  timeout: 3s
  retries: 5

This verifies that the service remains operational after restoration.

The project therefore validates:

Restore
   │
   ▼
Application Data
   │
   ▼
Application Health
14. Non-root Execution

The Dockerfile uses:

USER 10001:10001

The application does not run as root.

This follows least-privilege principles.

🎤 Interview Concept
Q: Why is non-root execution important for backup workflows?

Backup and restore operations deal directly with application data. Running the application with unnecessary root privileges increases the impact of a potential compromise.

15. no-new-privileges

Compose configuration:

security_opt:
  - no-new-privileges:true

This prevents processes from gaining additional privileges.

The project verifies this at runtime with:

docker inspect
16. Gunicorn

The application uses:

Gunicorn

instead of Flask's development server.

Architecture:

Client
   │
   ▼
Gunicorn
   │
   ▼
Flask
   │
   ▼
Persistent Volume

This makes the example more representative of production container execution.

🧪 Testing Strategy

The project uses multiple testing layers.

Unit/configuration tests
pytest -q

Tests validate:

named volume
persistent data path
healthcheck
non-root execution
atomic writes
application persistence configuration
Integration validation

The project then performs:

Build
  ↓
Start
  ↓
Write data
  ↓
Backup
  ↓
Delete
  ↓
Restore
  ↓
Validate

This is stronger than unit testing alone.

🔬 End-to-End Recovery Test

The complete recovery workflow is:

┌──────────────────────┐
│ Start Application    │
└──────────┬───────────┘
           ▼
┌──────────────────────┐
│ Write Persistent Data│
└──────────┬───────────┘
           ▼
┌──────────────────────┐
│ Create Backup        │
└──────────┬───────────┘
           ▼
┌──────────────────────┐
│ Verify Archive       │
└──────────┬───────────┘
           ▼
┌──────────────────────┐
│ Delete Original Data │
└──────────┬───────────┘
           ▼
┌──────────────────────┐
│ Restore Backup       │
└──────────┬───────────┘
           ▼
┌──────────────────────┐
│ Validate Data        │
└──────────┬───────────┘
           ▼
┌──────────────────────┐
│ Verify Health        │
└──────────────────────┘
🤖 GitHub Actions CI/CD

Workflow:

.github/workflows/project-29-compose-backup-restore.yml

Pipeline:

Git Push
   │
   ▼
Checkout
   │
   ▼
Python 3.12
   │
   ▼
Install Pytest
   │
   ▼
Run Tests
   │
   ▼
Compose Validation
   │
   ▼
Docker Build
   │
   ▼
Start Application
   │
   ▼
Health Check
   │
   ▼
Write Data
   │
   ▼
Create Backup
   │
   ▼
Verify Backup
   │
   ▼
Delete Data
   │
   ▼
Restore Backup
   │
   ▼
Validate Restored Data
   │
   ▼
Security Validation
   │
   ▼
Cleanup
📁 Project Structure
project-29-compose-backup-restore/
│
├── app/
│   └── app.py
│
├── tests/
│   └── test_backup_restore.py
│
├── Dockerfile
├── docker-compose.yml
├── .dockerignore
└── .gitignore

CI workflow:

.github/
└── workflows/
    └── project-29-compose-backup-restore.yml

Temporary backup:

backups/

is intentionally not committed.

🚀 Quick Start
cd project-29-compose-backup-restore

docker compose config

docker compose build

docker compose up -d

docker compose ps

Health:

curl http://localhost:5001/health

Write data:

curl \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"id":1,"name":"backup-test","environment":"production"}' \
  http://localhost:5001/data

Read data:

curl http://localhost:5001/data
💾 Manual Backup Example

Create a temporary backup:

mkdir -p backups

docker run --rm \
  -v project-29-backup-restore-data:/data:ro \
  -v "$PWD/backups:/backup" \
  alpine:3.22 \
  tar -czf /backup/application-data.tar.gz -C /data .

Inspect:

docker run --rm \
  -v "$PWD/backups:/backup:ro" \
  alpine:3.22 \
  tar -tzf /backup/application-data.tar.gz
♻️ Manual Restore Example

Restore the backup:

docker run --rm \
  -v project-29-backup-restore-data:/data \
  -v "$PWD/backups:/backup:ro" \
  alpine:3.22 \
  sh -c \
  'tar -xzf /backup/application-data.tar.gz -C /data'

Validate:

curl http://localhost:5001/data
🔐 Backup Security Considerations

Production backup systems must consider:

Encryption

Backups should generally be encrypted:

Application Data
      ↓
Encrypted Backup
      ↓
Secure Storage
Access Control

Only authorized identities should be able to:

create backups
read backups
delete backups
restore backups
Retention

Backups should have defined retention policies.

Immutability

Critical backups may require immutable or write-once storage to protect against ransomware or accidental deletion.

Off-site storage

A backup stored on the same host as the production data may not protect against host-level failure.

☁️ Production Evolution

The local Docker Compose implementation can evolve into:

Application
    │
    ▼
Persistent Storage
    │
    ▼
Backup Job
    │
    ▼
Encrypted Backup
    │
    ▼
Object Storage
    │
    ├── Retention
    ├── Versioning
    ├── Encryption
    └── Lifecycle Policy

For AWS environments, this could evolve toward:

Docker / EKS
     │
     ▼
Persistent Storage
     │
     ▼
Backup Automation
     │
     ▼
S3
     │
     ├── Versioning
     ├── Encryption
     ├── Lifecycle
     └── Cross-region strategy

The exact implementation should be selected based on RPO, RTO, compliance, cost, and recovery requirements.

🎤 Interview Questions & Answers
Q1. Why are Docker containers not sufficient for persistent data?

Containers are designed to be replaceable. Container filesystems are tied to the container lifecycle, while persistent volumes allow application data to survive container recreation.

Q2. How did you prove that your backup actually works?

I wrote application data, created a backup, deliberately deleted the original data, restored the backup, and then parsed and validated the recovered application state.

Q3. What is the difference between backup and restore?

Backup creates a recoverable copy of data. Restore uses that copy to reconstruct application state after data loss or corruption.

Q4. What is RPO?

Recovery Point Objective is the maximum amount of data loss acceptable after a failure.

Q5. What is RTO?

Recovery Time Objective is the maximum acceptable time required to restore service.

Q6. Is copying a backup file enough to guarantee recoverability?

No. A backup should be periodically restored and validated. Recovery testing is essential because an apparently successful backup can still be unusable due to corruption, missing dependencies, incorrect permissions, or incomplete data.

Q7. Where would you store production backups?

Preferably in durable, access-controlled, encrypted storage separate from the production compute environment. Object storage is commonly used because it supports durability, lifecycle management, versioning, and controlled access.

Q8. Should production backups be committed to Git?

No. Git should contain source code and configuration, not production data archives. Backups may contain sensitive information and can dramatically increase repository size.

Q9. What happens if the Docker host is completely destroyed?

A local Docker volume alone may be lost.

Therefore production architecture needs:

Production Volume
       │
       ▼
External Backup Storage
       │
       ▼
Independent Recovery
Q10. How would you improve this project for production?

I would add:

encrypted backups
object storage
automated scheduled backups
backup retention policies
immutable backups
checksum validation
monitoring
alerting
restore drills
cross-region replication where required
IAM-based access control
audit logging
defined RPO/RTO
Q11. Why is restore testing more important than backup creation?

Because backup creation only proves that data was copied. Restore testing proves that the organization can actually recover from a failure.

Q12. How would you handle database backups?

For databases, I would generally prefer database-aware backup mechanisms rather than blindly copying live database files.

For example:

Database
   │
   ▼
Consistent logical/physical backup
   │
   ▼
Encrypted backup storage
   │
   ▼
Restore validation

Consistency requirements depend on the database technology.

📊 Validation Matrix
Capability	Result
Docker named volume	✅
Persistent application data	✅
Data write	✅
Backup creation	✅
Backup archive validation	✅
Original data deletion	✅
Restore	✅
Restored data validation	✅
Application health after restore	✅
Atomic application writes	✅
Non-root execution	✅
no-new-privileges	✅
Pytest	✅
Docker Compose validation	✅
Docker build	✅
GitHub Actions	✅
Backup artifact excluded from Git	✅
Clean working tree	✅
🧠 Key DevOps Lessons
1. Persistent storage must be separated from container lifecycle
Container lifecycle
        ≠
Data lifecycle
2. Backups are not useful unless they can be restored
Backup
  ↓
Restore
  ↓
Validate
3. Recovery should be tested automatically

CI can turn recovery assumptions into executable tests.

4. Backup security is part of infrastructure security

A backup can contain the same sensitive information as production.

5. RPO and RTO drive backup architecture

There is no universal backup strategy.

The correct design depends on:

business impact
acceptable data loss
recovery time
compliance
cost
storage durability
🏆 Skills Demonstrated
Docker
Docker Compose
Docker Volumes
Persistent Storage
Backup & Restore
Data Integrity
Recovery Testing
RPO / RTO
Container Security
Non-Root Containers
Least Privilege
Flask
Gunicorn
Python 3.12
Pytest
GitHub Actions
CI/CD
Infrastructure Testing
Disaster Recovery Fundamentals
Production Operations
📈 CI/CD Mastery Progress
Projects 01 → 25   ✅
Project 26          ✅ Dependency Resilience
Project 27          ✅ Resource Governance
Project 28          ✅ Logging & Rotation
Project 29          ✅ Backup & Restore
Project 30          ⏳ Production Hardening
🔥 Final Takeaway

The most important production lesson from Project 29 is:

A backup is not a backup strategy until recovery has been tested.

This project demonstrates the complete lifecycle:

Persist
   ↓
Backup
   ↓
Delete
   ↓
Restore
   ↓
Validate
   ↓
Recover

That turns backup and restore from a theoretical concept into an automated, testable DevOps workflow.

✅ Project 29 — Enterprise Docker Compose Backup & Restore: COMPLETE
