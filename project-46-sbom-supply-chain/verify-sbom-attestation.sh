#!/usr/bin/env bash
set -euo pipefail

IMAGE_DIGEST="${1:?Usage: $0 <image>@sha256:<digest>}"

COSIGN_IDENTITY_REGEX='^https://github.com/Ashish420-tech/CI-CD-mastery/.github/workflows/project-46-sbom-supply-chain.yml@refs/heads/project-46-sbom-supply-chain$'
COSIGN_ISSUER='https://token.actions.githubusercontent.com'

echo "=============================================="
echo "PROJECT 46 — SBOM ATTESTATION VERIFICATION"
echo "=============================================="

echo
echo "Image:"
echo "$IMAGE_DIGEST"

cosign verify-attestation \
  --type spdxjson \
  --certificate-oidc-issuer "$COSIGN_ISSUER" \
  --certificate-identity-regexp "$COSIGN_IDENTITY_REGEX" \
  "$IMAGE_DIGEST"

echo
echo "SBOM ATTESTATION VERIFIED"
