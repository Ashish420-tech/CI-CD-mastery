#!/usr/bin/env bash
set -Eeuo pipefail

cd ~/CI-CD-mastery

BRANCH="project-37-ecr-immutable-image-platform"
REGION="ap-south-1"
REPO="ci-cd-mastery/applications"

echo "============================================================"
echo " PROJECT 37 — ECR + IMMUTABLE IMAGE PLATFORM"
echo " FINAL IMPLEMENTATION"
echo "============================================================"

# ============================================================
# 1. BRANCH
# ============================================================

echo
echo "===== 1. BRANCH ====="

if git show-ref --verify --quiet "refs/heads/$BRANCH"; then
    git switch "$BRANCH"
else
    git switch -c "$BRANCH"
fi

echo "Branch: $(git branch --show-current)"

# ============================================================
# 2. REMOVE ONLY FAILED TEMPORARY FILES
# ============================================================

echo
echo "===== 2. CLEAN FAILED TEMPORARY FILES ====="

rm -f finish-project-37.sh
rm -f project-37-ecr-immutable-image-platform-verify.sh

# ============================================================
# 3. VERIFY EXISTING ECR TERRAFORM
# ============================================================

echo
echo "===== 3. VERIFY EXISTING ECR CONFIGURATION ====="

grep -q 'name.*ci-cd-mastery/applications' infrastructure/eks/ecr.tf
grep -q 'image_tag_mutability.*IMMUTABLE' infrastructure/eks/ecr.tf
grep -q 'scan_on_push.*true' infrastructure/eks/ecr.tf
grep -q 'encryption_type.*AES256' infrastructure/eks/ecr.tf
grep -q 'aws_ecr_lifecycle_policy.*applications' infrastructure/eks/ecr.tf

echo "Existing ECR configuration confirmed."

# ============================================================
# 4. TERRAFORM FORMAT / VALIDATE
# ============================================================

echo
echo "===== 4. TERRAFORM VALIDATION ====="

cd infrastructure/eks

terraform fmt ecr.tf
terraform init -backend=false
terraform validate

echo "Terraform validation: PASS"

# ============================================================
# 5. VERIFY TERRAFORM STATE
# ============================================================

echo
echo "===== 5. TERRAFORM ECR STATE ====="

terraform state list | grep \
    -E 'aws_ecr_repository.applications|aws_ecr_lifecycle_policy.applications'

# ============================================================
# 6. RECONCILE ONLY ECR LIFECYCLE
# ============================================================

echo
echo "===== 6. ECR LIFECYCLE RECONCILIATION ====="

terraform plan \
    -target=aws_ecr_lifecycle_policy.applications[0] \
    -out=/tmp/project-37.tfplan

PLAN_TEXT="$(terraform show -no-color /tmp/project-37.tfplan)"

if echo "$PLAN_TEXT" | grep -Eq \
    'will be created|will be updated|must be replaced'; then

    echo
    echo "Lifecycle policy requires reconciliation."
    echo "Applying ONLY the ECR lifecycle resource."

    terraform apply -auto-approve /tmp/project-37.tfplan

else

    echo
    echo "ECR lifecycle already matches Terraform."
    echo "No infrastructure change required."

fi

# ============================================================
# 7. AWS ECR VERIFICATION
# ============================================================

echo
echo "===== 7. AWS ECR VERIFICATION ====="

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

MUTABILITY="$(
    aws ecr describe-repositories \
        --repository-names "$REPO" \
        --region "$REGION" \
        --query 'repositories[0].imageTagMutability' \
        --output text
)"

SCAN="$(
    aws ecr describe-repositories \
        --repository-names "$REPO" \
        --region "$REGION" \
        --query 'repositories[0].imageScanningConfiguration.scanOnPush' \
        --output text
)"

if [[ "$MUTABILITY" != "IMMUTABLE" ]]; then
    echo "ERROR: ECR is not immutable."
    exit 1
fi

if [[ "$SCAN" != "True" && "$SCAN" != "true" ]]; then
    echo "ERROR: ECR scan-on-push is disabled."
    exit 1
fi

echo "Immutable tags: PASS"
echo "Scan on push: PASS"

# ============================================================
# 8. LIFECYCLE VERIFICATION
# ============================================================

echo
echo "===== 8. LIFECYCLE VERIFICATION ====="

if aws ecr get-lifecycle-policy \
    --repository-name "$REPO" \
    --region "$REGION" \
    --output json > /tmp/project-37-lifecycle.json 2>/dev/null; then

    cat /tmp/project-37-lifecycle.json

    grep -q 'imageCountMoreThan' /tmp/project-37-lifecycle.json
    grep -q '20' /tmp/project-37-lifecycle.json

    echo "Lifecycle policy: PASS"

else

    echo "ERROR: AWS lifecycle policy is missing."
    exit 1

fi

# ============================================================
# 9. RETURN TO REPOSITORY
# ============================================================

cd ~/CI-CD-mastery

# ============================================================
# 10. CREATE PROJECT DIRECTORY
# ============================================================

mkdir -p project-37-ecr-immutable-image-platform

# ============================================================
# 11. PROJECT 37 README
# ============================================================

echo
echo "===== 9. CREATE README ====="

cat > project-37-ecr-immutable-image-platform/README.md <<'EOF'
# Project 37 — ECR + Immutable Image Platform

> Production-grade container artifact management using Amazon ECR,
> immutable Git-SHA tags, image scanning, encryption and lifecycle governance.

## Objective

Establish the shared container image platform for the CI/CD Mastery
EKS Platform Engineering + DevSecOps roadmap.

Project 37 reuses the existing ECR repository created for the platform.

```text
ci-cd-mastery/applications
