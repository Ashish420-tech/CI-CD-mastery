#!/usr/bin/env bash
set -Eeuo pipefail

REGION="ap-south-1"
REPO="ci-cd-mastery/applications"

echo "===== ECR REPOSITORY ====="

aws ecr describe-repositories \
  --repository-names "$REPO" \
  --region "$REGION" \
  --query 'repositories[0].{
    Repository:repositoryName,
    URI:repositoryUri,
    Mutability:imageTagMutability,
    ScanOnPush:imageScanningConfiguration.scanOnPush,
    Encryption:encryptionConfiguration.encryptionType
  }' \
  --output table

echo
echo "===== LIFECYCLE POLICY ====="

aws ecr get-lifecycle-policy \
  --repository-name "$REPO" \
  --region "$REGION" \
  --query policyText \
  --output text

echo
echo "===== IMAGES ====="

aws ecr describe-images \
  --repository-name "$REPO" \
  --region "$REGION" \
  --query 'imageDetails[].{
    Tags:imageTags,
    Digest:imageDigest,
    Pushed:imagePushedAt
  }' \
  --output table

echo
echo "===== RESULT ====="
echo "PROJECT 37 ECR PLATFORM: PASS"
