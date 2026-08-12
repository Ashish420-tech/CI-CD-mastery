#!/usr/bin/env bash

set -euo pipefail

COMPOSE_FILE="compose.yml"
API_CONTAINER="project22-api"
REDIS_CONTAINER="project22-redis"
FRONTEND_NETWORK="project22_frontend_net"
BACKEND_NETWORK="project22_backend_net"

echo "=========================================="
echo " Project 22 Network Verification"
echo "=========================================="

echo
echo "1. Compose configuration"
docker compose -f "$COMPOSE_FILE" config >/dev/null
echo "PASS: Compose configuration is valid"

echo
echo "2. Required containers"
docker inspect "$API_CONTAINER" >/dev/null
docker inspect "$REDIS_CONTAINER" >/dev/null
echo "PASS: API and Redis containers exist"

echo
echo
echo "3. Container health"

echo "Waiting for services to become healthy..."

for attempt in {1..30}; do
    API_HEALTH="$(docker inspect "$API_CONTAINER" --format="{{.State.Health.Status}}" 2>/dev/null || true)"
    REDIS_HEALTH="$(docker inspect "$REDIS_CONTAINER" --format="{{.State.Health.Status}}" 2>/dev/null || true)"

    echo "Attempt $attempt/30: API=$API_HEALTH Redis=$REDIS_HEALTH"

    if [[ "$API_HEALTH" == "healthy" && "$REDIS_HEALTH" == "healthy" ]]; then
        break
    fi

    if [[ "$API_HEALTH" == "unhealthy" || "$REDIS_HEALTH" == "unhealthy" ]]; then
        echo "FAIL: A service became unhealthy"
        docker compose logs
        exit 1
    fi

    sleep 2
done

API_HEALTH="$(docker inspect "$API_CONTAINER" --format="{{.State.Health.Status}}")"
REDIS_HEALTH="$(docker inspect "$REDIS_CONTAINER" --format="{{.State.Health.Status}}")"

echo "Final API health:   $API_HEALTH"
echo "Final Redis health: $REDIS_HEALTH"

[[ "$API_HEALTH" == "healthy" ]]
[[ "$REDIS_HEALTH" == "healthy" ]]

echo "PASS: Both services are healthy"

echo
echo "4. Network membership"

API_NETWORKS="$(docker inspect "$API_CONTAINER" \
  --format='{{range $name, $_ := .NetworkSettings.Networks}}{{println $name}}{{end}}')"

REDIS_NETWORKS="$(docker inspect "$REDIS_CONTAINER" \
  --format='{{range $name, $_ := .NetworkSettings.Networks}}{{println $name}}{{end}}')"

echo "API networks:"
echo "$API_NETWORKS"

echo
echo "Redis networks:"
echo "$REDIS_NETWORKS"

grep -q "$FRONTEND_NETWORK" <<< "$API_NETWORKS"
grep -q "$BACKEND_NETWORK" <<< "$API_NETWORKS"
grep -q "$BACKEND_NETWORK" <<< "$REDIS_NETWORKS"

if grep -q "$FRONTEND_NETWORK" <<< "$REDIS_NETWORKS"; then
    echo "FAIL: Redis is attached to frontend network"
    exit 1
fi

echo "PASS: Network segmentation is correct"

echo
echo "5. Backend network must be internal"

BACKEND_INTERNAL="$(docker network inspect "$BACKEND_NETWORK" \
  --format='{{.Internal}}')"

echo "backend_net Internal=$BACKEND_INTERNAL"

[[ "$BACKEND_INTERNAL" == "true" ]]

echo "PASS: Backend network is internal"

echo
echo "6. Redis must not publish host ports"

REDIS_PORTS="$(docker port "$REDIS_CONTAINER" 2>/dev/null || true)"

if [[ -n "$REDIS_PORTS" ]]; then
    echo "FAIL: Redis has published ports:"
    echo "$REDIS_PORTS"
    exit 1
fi

echo "PASS: Redis has no host port exposure"

echo
echo "7. API -> Redis through Compose DNS"

NETWORK_RESPONSE="$(curl -fsS \
  http://127.0.0.1:8110/api/network)"

echo "$NETWORK_RESPONSE"

grep -q '"redis":"reachable"' <<< "$NETWORK_RESPONSE"
grep -q '"networking":"service-discovery-success"' <<< "$NETWORK_RESPONSE"
grep -q '"redis_hostname":"redis"' <<< "$NETWORK_RESPONSE"

echo "PASS: API resolves and communicates with Redis"

echo
echo "8. Frontend-only isolation test"

TEST_CONTAINER="project22-network-isolation-test"

docker rm -f "$TEST_CONTAINER" >/dev/null 2>&1 || true

docker run -d \
  --name "$TEST_CONTAINER" \
  --network "$FRONTEND_NETWORK" \
  alpine:3.22 \
  sleep 120 >/dev/null

trap 'docker rm -f "$TEST_CONTAINER" >/dev/null 2>&1 || true' EXIT

TEST_NETWORKS="$(docker inspect "$TEST_CONTAINER" \
  --format='{{range $name, $_ := .NetworkSettings.Networks}}{{println $name}}{{end}}')"

echo "Test container networks:"
echo "$TEST_NETWORKS"

grep -q "$FRONTEND_NETWORK" <<< "$TEST_NETWORKS"

if grep -q "$BACKEND_NETWORK" <<< "$TEST_NETWORKS"; then
    echo "FAIL: Isolation test container is attached to backend network"
    exit 1
fi

echo
echo "Testing Redis DNS resolution from frontend-only network..."

if docker exec "$TEST_CONTAINER" \
    getent hosts redis >/dev/null 2>&1; then
    echo "FAIL: Frontend-only container resolved Redis"
    exit 1
fi

echo "PASS: Frontend-only container cannot resolve Redis"

echo
echo "Testing Redis TCP connectivity from frontend-only network..."

if docker exec "$TEST_CONTAINER" \
    sh -c 'apk add --no-cache busybox-extras >/dev/null 2>&1 && timeout 3 nc -z redis 6379'; then
    echo "FAIL: Frontend-only container reached Redis"
    exit 1
fi

echo "PASS: Frontend-only container cannot reach Redis"

echo
echo "=========================================="
echo " ALL NETWORK VERIFICATIONS PASSED"
echo "=========================================="
