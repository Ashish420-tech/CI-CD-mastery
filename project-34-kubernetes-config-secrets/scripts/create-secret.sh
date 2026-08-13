#!/usr/bin/env bash
set -euo pipefail

kubectl create secret generic application-secrets \
  --namespace project-34 \
  --from-literal=API_TOKEN="${API_TOKEN:?API_TOKEN must be set}" \
  --from-literal=DATABASE_PASSWORD="${DATABASE_PASSWORD:?DATABASE_PASSWORD must be set}" \
  --dry-run=client \
  -o yaml | kubectl apply -f -
