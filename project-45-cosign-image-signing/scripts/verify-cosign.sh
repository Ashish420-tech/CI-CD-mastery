#!/usr/bin/env bash
set -euo pipefail

IMAGE="${1:?Usage: verify-cosign.sh <image@sha256:digest>}"

echo "=============================================="
echo "PROJECT 45 — COSIGN IMAGE VERIFICATION"
echo "=============================================="

echo
echo "Image:"
echo "$IMAGE"

echo
echo "===== COSIGN VERSION ====="
cosign version

echo
echo "===== VERIFY SIGNATURE ====="

cosign verify \
  "$IMAGE" \
  --certificate-identity-regexp 'https://github.com/Ashish420-tech/CI-CD-mastery/.*' \
  --certificate-oidc-issuer-regexp 'https://token.actions.githubusercontent.com' \
  --output text

echo
echo "=============================================="
echo "COSIGN SIGNATURE VERIFICATION: PASS"
echo "=============================================="
