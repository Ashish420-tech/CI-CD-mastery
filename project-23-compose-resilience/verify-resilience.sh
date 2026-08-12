#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

COMPOSE="docker compose -p project-23-compose-resilience"
API_URL="http://127.0.0.1:8123"

cleanup() {
    $COMPOSE down --remove-orphans >/dev/null 2>&1 || true
}

trap cleanup EXIT

echo "==> Starting Project 23"
$COMPOSE up -d --build

echo "==> Waiting for API health"
for i in $(seq 1 30); do
    if curl -fsS "$API_URL/health" >/dev/null 2>&1; then
        break
    fi
    sleep 2
done

echo "==> Verifying initial health"
curl -fsS "$API_URL/health"
echo

REDIS_ID="$(docker inspect -f '{{.Id}}' project23-redis)"

echo "Redis container: ${REDIS_ID:0:12}"

echo "==> Injecting controlled Redis process failure"
$COMPOSE exec -T redis sh -c 'kill -9 1'

echo "==> Waiting for Redis automatic recovery"

RECOVERED=0

for i in $(seq 1 30); do
    STATUS="$(docker inspect -f '{{.State.Status}}' project23-redis 2>/dev/null || true)"
    HEALTH="$(docker inspect -f '{{if .State.Health}}{{.State.Health.Status}}{{else}}none{{end}}' project23-redis 2>/dev/null || true)"

    if [[ "$STATUS" == "running" && "$HEALTH" == "healthy" ]]; then
        RECOVERED=1
        break
    fi

    sleep 1
done

if [[ "$RECOVERED" -ne 1 ]]; then
    echo "ERROR: Redis did not return to running/healthy state"
    docker inspect project23-redis \
        --format 'Status={{.State.Status}} Health={{if .State.Health}}{{.State.Health.Status}}{{else}}none{{end}} ExitCode={{.State.ExitCode}}'
    $COMPOSE ps
    exit 1
fi

echo "Redis recovered successfully."

CURRENT_ID="$(docker inspect -f '{{.Id}}' project23-redis)"

if [[ "$CURRENT_ID" != "$REDIS_ID" ]]; then
    echo "ERROR: Redis container identity unexpectedly changed"
    exit 1
fi

echo "Redis container identity preserved."

echo "==> Waiting for API recovery"

API_RECOVERED=0

for i in $(seq 1 30); do
    if curl -fsS "$API_URL/health" >/dev/null 2>&1; then
        API_RECOVERED=1
        break
    fi
    sleep 1
done

if [[ "$API_RECOVERED" -ne 1 ]]; then
    echo "ERROR: API did not recover after Redis recovery"
    $COMPOSE ps
    exit 1
fi

echo "API recovered successfully."

echo "==> Verifying application functionality"
curl -fsS "$API_URL/cache"
echo

echo "==> Final container state"
$COMPOSE ps

echo "Project 23 resilience verification PASSED."
