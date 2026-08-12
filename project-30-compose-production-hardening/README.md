# 🚀 Project 30 — Enterprise Docker Compose Production Hardening

> **Production-oriented Docker Compose container hardening using a read-only root filesystem, writable tmpfs, dropped Linux capabilities, non-root execution, `no-new-privileges`, healthchecks, graceful shutdown, logging rotation, and automated security validation.**

![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?logo=docker&logoColor=white)
![Python](https://img.shields.io/badge/Python-3.12-3776AB?logo=python&logoColor=white)
![Flask](https://img.shields.io/badge/Flask-3.1-000000?logo=flask&logoColor=white)
![Gunicorn](https://img.shields.io/badge/Gunicorn-Production-499848)
![Security](https://img.shields.io/badge/Container-Security-success)
![Pytest](https://img.shields.io/badge/Tests-Pytest-success)
![GitHub Actions](https://img.shields.io/badge/GitHub-Actions-2088FF?logo=githubactions&logoColor=white)
![Status](https://img.shields.io/badge/Project-Complete-success)

---

## 🎯 Executive Summary

A container running successfully does **not** automatically mean it is secure.

A default container may have:

- unnecessary Linux capabilities
- writable filesystem
- root privileges
- unnecessary filesystem access
- weak privilege boundaries
- unrestricted temporary storage
- insufficient runtime validation

This project demonstrates a defense-in-depth container security model:

```text
                    Docker Container
                          │
          ┌───────────────┼────────────────┐
          │               │                │
          ▼               ▼                ▼
      Non-root       Read-only FS      Capabilities
       UID 10001          │             dropped
                          │                │
                          ▼                ▼
                       tmpfs       no-new-privileges
                          │                │
                          └────────┬───────┘
                                   ▼
                             Healthcheck
                                   │
                                   ▼
                         Runtime Verification

The security configuration is not only declared in YAML.

It is verified against the running container using Docker inspection and runtime tests.

🏗️ Architecture
                         Client
                           │
                           ▼
                  ┌─────────────────┐
                  │ Gunicorn        │
                  │ Flask           │
                  │ UID 10001       │
                  └────────┬────────┘
                           │
             ┌─────────────┼─────────────┐
             │             │             │
             ▼             ▼             ▼
       Read-only FS     /tmp tmpfs   Dropped Caps
             │             │             │
             └─────────────┼─────────────┘
                           ▼
                  no-new-privileges
                           │
                           ▼
                     Healthcheck
                           │
                           ▼
                    Docker Engine
🔥 Security Philosophy

The project follows a defense-in-depth model.

No single security control is treated as sufficient.

Non-root
    +
Read-only filesystem
    +
Capability reduction
    +
no-new-privileges
    +
Minimal writable area
    +
Healthcheck
    +
Runtime validation

Each control reduces a different category of risk.

📌 Project Objectives

This project demonstrates:

non-root container execution
read-only root filesystem
writable tmpfs
Linux capability dropping
no-new-privileges
Docker healthchecks
graceful container shutdown
minimal application permissions
Docker logging rotation
runtime security inspection
application functionality testing
Pytest
Docker Compose validation
GitHub Actions CI
🧩 Core Concepts
1. Non-root Container

The Dockerfile uses:

USER 10001:10001

The application therefore does not run as root.

Conceptually:

Bad:
Application → root

Better:
Application → UID 10001
🎤 Interview Question
Why should containers run as non-root?

Containers should run with the minimum privileges required by the application. If the application is compromised, non-root execution reduces the privileges available to an attacker inside the container.

2. Read-only Root Filesystem

Compose configuration:

read_only: true

This makes the container's root filesystem immutable at runtime.

/app              READ-ONLY
/usr              READ-ONLY
/etc              READ-ONLY
/bin              READ-ONLY
/tmp              WRITABLE

The goal is to prevent an attacker or compromised application from freely modifying the container filesystem.

🎤 Interview Question
What does read_only: true protect against?

It prevents runtime processes from modifying the container's root filesystem, reducing persistence opportunities and limiting the impact of a compromised process.

3. Why Read-only Filesystems Matter

Without read-only protection:

Attacker
   │
   ▼
Compromised Process
   │
   ├── Modify binaries
   ├── Write persistence
   ├── Modify configuration
   └── Create malicious files

With a read-only root filesystem:

Attacker
   │
   ▼
Compromised Process
   │
   ▼
Root filesystem write
   │
   ▼
BLOCKED

This does not make a container immune to compromise, but it reduces available attack paths.

4. tmpfs

A read-only filesystem creates a practical problem:

Some applications need temporary writable storage.

This project provides:

tmpfs:
  - /tmp:rw,noexec,nosuid,nodev,size=16m

The application can write temporary files to /tmp, while the rest of the root filesystem remains read-only.

Architecture:

Container
│
├── Root FS ───────── READ ONLY
│
└── /tmp ──────────── WRITABLE
🎤 Interview Question
Why use tmpfs with a read-only filesystem?

Some applications require temporary writable storage. tmpfs provides a controlled writable memory-backed filesystem without making the entire container filesystem writable.

5. noexec

The tmpfs configuration includes:

noexec

This prevents execution of binaries directly from that mount.

Conceptually:

/tmp
 │
 ├── write file      ✅
 ├── read file       ✅
 └── execute binary  ❌

This adds another restriction to the temporary filesystem.

6. nosuid

The tmpfs also uses:

nosuid

This prevents set-user-ID and set-group-ID bits from providing privilege escalation through files on that mount.

7. nodev

The tmpfs uses:

nodev

This prevents device files from being interpreted as devices on the mount.

🎤 Interview Summary

A strong interview explanation:

For temporary storage, I use a constrained tmpfs with noexec, nosuid, and nodev to reduce the attack surface while still allowing the application to use temporary files.

8. Linux Capabilities

Linux capabilities split traditional root privileges into smaller privilege units.

Instead of giving a process unrestricted root-style privileges, we can remove capabilities it does not need.

This project uses:

cap_drop:
  - ALL

Conceptually:

Container
    │
    ▼
Linux Capabilities
    │
    ▼
DROP ALL
🎤 Interview Question
What are Linux capabilities?

Linux capabilities divide traditionally privileged root operations into individual permission sets, allowing administrators to grant or remove specific privileges instead of treating root as one unrestricted privilege level.

9. Why Drop ALL Capabilities?

The application is a simple HTTP service.

It does not need:

network administration
raw packet access
filesystem mounting
kernel module management
system administration capabilities

Therefore:

cap_drop:
  - ALL

follows least privilege.

🎤 Interview Question
Why not only drop a few capabilities?

If the workload does not require any additional Linux capabilities, dropping all capabilities creates a stronger baseline. Specific capabilities can then be added back only when a legitimate application requirement exists.

10. no-new-privileges

Compose:

security_opt:
  - no-new-privileges:true

This prevents processes from gaining additional privileges.

Conceptually:

Process
   │
   ▼
Privilege escalation attempt
   │
   ▼
BLOCKED
🎤 Interview Question
What does no-new-privileges protect against?

It prevents a process and its children from gaining additional privileges through mechanisms such as setuid/setgid execution.

It is an additional defense layer, not a replacement for non-root execution.

11. Defense in Depth

The strongest part of this project is that multiple controls overlap.

                 Compromised Application
                          │
          ┌───────────────┼────────────────┐
          ▼               ▼                ▼
       Non-root       Read-only FS    Capabilities
          │               │                │
          ▼               ▼                ▼
     Lower UID       No persistence     Less privilege
                          │
                          ▼
                  no-new-privileges

This is classic defense-in-depth.

12. Healthchecks

The application exposes:

GET /health

Docker runs:

healthcheck:
  interval: 5s
  timeout: 3s
  retries: 5
  start_period: 5s

The healthcheck validates the actual application endpoint.

🎤 Interview Question
Why is a running container not necessarily healthy?

A container can have a running process while the application itself is unavailable or malfunctioning. A healthcheck provides an application-level readiness signal.

13. Healthcheck Race Handling in CI

The first CI implementation checked health immediately:

Container
    │
    ▼
Health = starting
    │
    ▼
CI checks once
    │
    ▼
FAIL

The workflow was corrected to poll:

Container
    │
    ▼
starting
    │
    ├── wait
    │
    ├── wait
    │
    ▼
healthy
    │
    ▼
PASS

This is an important real-world CI/CD lesson.

🎤 Interview Question
Why shouldn't CI immediately inspect a newly started container?

Container startup and application readiness are asynchronous. CI should wait for the health/readiness condition instead of assuming that process startup means application readiness.

14. Graceful Shutdown

The Dockerfile uses:

STOPSIGNAL SIGTERM

Gunicorn is configured with:

--graceful-timeout 5

Compose also defines:

stop_grace_period: 10s

This gives the application time to terminate cleanly.

Conceptually:

docker stop
     │
     ▼
SIGTERM
     │
     ▼
Gunicorn graceful shutdown
     │
     ▼
Finish active work
     │
     ▼
Exit
🎤 Interview Question
Why is graceful shutdown important?

Abrupt termination can interrupt requests, leave incomplete operations, or cause inconsistent application state. Graceful shutdown gives the application an opportunity to finish or safely terminate active work.

15. init: true

Compose:

init: true

This provides an init process inside the container.

It helps with:

signal handling
process reaping
child-process management

This is particularly useful for applications that may create child processes.

16. Restart Policy

The project uses:

restart: unless-stopped

This provides basic local recovery behavior.

Important distinction:

Restart policy
       ≠
High availability

A restart policy can restart a failed container.

It does not provide:

multiple replicas
cross-host failover
distributed scheduling
load balancing
17. Logging Rotation

The project also includes:

logging:
  driver: json-file
  options:
    max-size: "10m"
    max-file: "3"

This prevents uncontrolled Docker log growth.

Conceptually:

Application Logs
      │
      ▼
json-file
      │
      ├── 10 MB limit
      │
      └── 3 retained files
🔐 Security Validation

The project does not trust the Compose YAML alone.

It verifies the actual running container:

Compose YAML
     │
     ▼
Docker Engine
     │
     ▼
Running Container
     │
     ▼
docker inspect
     │
     ▼
Effective Security Configuration

This is a powerful operational principle.

🔬 Runtime Security Tests
Non-root
docker inspect <container> \
  --format '{{.Config.User}}'

Expected:

10001:10001
Read-only filesystem
docker inspect <container> \
  --format '{{.HostConfig.ReadonlyRootfs}}'

Expected:

true
Capabilities
docker inspect <container> \
  --format '{{json .HostConfig.CapDrop}}'

Expected:

["ALL"]
no-new-privileges
docker inspect <container> \
  --format '{{json .HostConfig.SecurityOpt}}'

Expected:

["no-new-privileges:true"]
🧪 Actual Security Testing

Static configuration checks are not enough.

The project attempts to write to the root filesystem:

docker exec <container> \
  sh -c 'touch /rootfs-write-test'

Expected:

permission denied

Therefore:

Root filesystem write: BLOCKED ✅

Then /tmp is tested:

docker exec <container> \
  sh -c 'touch /tmp/hardening-test && rm /tmp/hardening-test'

Expected:

tmpfs write: PASS

This proves the intended security model actually works at runtime.

🐍 Application Stack
Python 3.12

Application runtime.

Flask

Provides the API:

/
 /health
 /runtime
Gunicorn

Production-style WSGI server.

Architecture:

Client
   │
   ▼
Gunicorn
   │
   ▼
Flask
🧪 Automated Testing

Pytest validates the desired security configuration.

Tests cover:

read-only filesystem
tmpfs
capability dropping
no-new-privileges
healthcheck
non-root execution
Gunicorn
restart policy
init process
logging rotation

Run:

pytest -q
🤖 GitHub Actions

Workflow:

.github/workflows/
└── project-30-compose-production-hardening.yml

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
Pytest
   │
   ▼
Compose Validation
   │
   ▼
Docker Build
   │
   ▼
Start Container
   │
   ▼
Health Readiness
   │
   ▼
Application Test
   │
   ├── Non-root
   ├── Read-only FS
   ├── tmpfs
   ├── Capabilities
   ├── no-new-privileges
   ├── Healthcheck
   ├── Logging
   └── Runtime write tests
            │
            ▼
          Cleanup
📁 Project Structure
project-30-compose-production-hardening/
│
├── app/
│   └── app.py
│
├── tests/
│   └── test_production_hardening.py
│
├── Dockerfile
├── docker-compose.yml
├── .dockerignore
└── .gitignore

Workflow:

.github/
└── workflows/
    └── project-30-compose-production-hardening.yml
🚀 Quick Start
cd project-30-compose-production-hardening

docker compose config

docker compose build

docker compose up -d

docker compose ps

Health:

curl http://localhost:5001/health

Application:

curl http://localhost:5001/

Runtime:

curl http://localhost:5001/runtime

Inspect security:

docker inspect "$(docker compose ps -q app)"

Cleanup:

docker compose down -v
📊 Security Validation Matrix
Security Control	Validation
Non-root	✅ UID/GID 10001:10001
Read-only root filesystem	✅
/tmp tmpfs	✅
noexec	✅
nosuid	✅
nodev	✅
Drop all capabilities	✅
no-new-privileges	✅
Healthcheck	✅
Graceful SIGTERM	✅
init: true	✅
Restart policy	✅
Logging rotation	✅
Root FS write blocked	✅
/tmp write succeeds	✅
Pytest	✅
GitHub Actions	✅
🎤 Interview Questions & Answers
Q1. How do you harden a Docker container?

I start with a minimal image and non-root execution, make the root filesystem read-only, provide only required writable paths through tmpfs or volumes, drop unnecessary Linux capabilities, enable no-new-privileges, configure healthchecks, and continuously validate the effective runtime configuration.

Q2. Is running as non-root enough?

No. Non-root is one layer of defense. I would combine it with filesystem restrictions, capability dropping, no-new-privileges, minimal images, network controls, vulnerability scanning, and appropriate runtime security policies.

Q3. What does cap_drop: ALL do?

It removes Linux capabilities from the container. If the application needs a specific capability, I would explicitly add only that capability back.

Q4. What is the difference between rootless containers and non-root containers?

Non-root execution means the process inside the container runs as a non-root user. Rootless Docker refers to running the container engine itself without root privileges. They address different layers of the security model.

Q5. Why use a read-only root filesystem?

It limits runtime filesystem modification and reduces the ability of a compromised application to persist malicious changes inside the container.

Q6. Why do applications sometimes fail with read-only filesystems?

Because applications may attempt to write to:

/tmp
cache directories
PID files
runtime sockets
application directories

The solution is not necessarily disabling read-only mode.

Instead:

Identify required writes
        ↓
Provide narrowly scoped writable storage
        ↓
Keep everything else read-only
Q7. Why use tmpfs instead of making /tmp part of the writable root filesystem?

tmpfs provides an isolated, constrained writable area without making the entire root filesystem writable.

Q8. What is least privilege?

Give a process only the permissions and resources required to perform its intended function, and nothing more.

Q9. What does no-new-privileges provide?

It prevents processes from gaining additional privileges, providing another barrier against privilege escalation.

Q10. Does cap_drop: ALL make the container completely secure?

No.

Container security is defense in depth.

Other concerns include:

vulnerable packages
application vulnerabilities
secrets
network exposure
kernel vulnerabilities
Docker daemon security
supply-chain attacks
image provenance
Q11. How would you improve this for a real production environment?

I would add:

image vulnerability scanning
SBOM generation
image signing
admission controls
centralized logging
runtime threat detection
network segmentation
secret management
resource limits
seccomp profiles
AppArmor/SELinux where applicable
supply-chain verification
dependency scanning
Q12. Why verify runtime configuration with docker inspect?

The Compose file represents desired configuration. docker inspect verifies the effective configuration applied to the running container.

Q13. How did you test that the root filesystem was actually read-only?

I attempted a real write operation inside the running container and verified that the write was blocked, while simultaneously verifying that /tmp remained writable through the configured tmpfs.

This is stronger than simply checking:

read_only: true
Q14. Why is healthcheck validation asynchronous?

Container startup and application readiness are separate events. A process may be running while the application is still initializing, so CI should poll until the health condition becomes healthy.

🧠 Production Hardening Checklist
[✓] Minimal runtime image
[✓] Non-root user
[✓] Read-only root filesystem
[✓] Controlled writable tmpfs
[✓] noexec
[✓] nosuid
[✓] nodev
[✓] Drop unnecessary capabilities
[✓] no-new-privileges
[✓] Healthcheck
[✓] Graceful shutdown
[✓] Init process
[✓] Restart policy
[✓] Logging rotation
[✓] Runtime inspection
[✓] Automated tests
[✓] CI validation
🏆 Skills Demonstrated
Docker
Docker Compose
Container Security
Linux Security
Linux Capabilities
Least Privilege
Non-root Containers
Read-only Filesystems
tmpfs
noexec
nosuid
nodev
no-new-privileges
Healthchecks
Graceful Shutdown
Gunicorn
Flask
Python 3.12
Pytest
Git
GitHub Actions
CI/CD
Runtime Validation
Defense in Depth
Production Hardening
📈 CI/CD Mastery Progress
Projects 01 → 25   ✅
Project 26          ✅ Dependency Resilience
Project 27          ✅ Resource Governance
Project 28          ✅ Logging & Rotation
Project 29          ✅ Backup & Restore
Project 30          ✅ Production Hardening
🔥 Final Takeaway

The core lesson from Project 30 is:

A production container should have the minimum privileges, writable storage, and Linux capabilities required by the application — nothing more.

The resulting security model is:

                    Production Container
                           │
              ┌────────────┼────────────┐
              ▼            ▼            ▼
          Non-root    Read-only FS   Drop ALL Caps
              │            │            │
              └────────────┼────────────┘
                           ▼
                  no-new-privileges
                           │
                           ▼
                    Controlled tmpfs
                           │
                           ▼
                      Healthcheck
                           │
                           ▼
                 Runtime Verification

This turns Docker Compose from a simple application launcher into a security-conscious production deployment platform.

🏁 Project Completion

Project 30 — Enterprise Docker Compose Production Hardening: COMPLETE ✅

GitHub Actions: 31625983411 ✅

Production-hardening validation: PASS
