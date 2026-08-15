#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

echo "============================================================"
echo " EKS REUSABLE PLATFORM FOUNDATION"
echo "============================================================"

echo "===== FORMAT ====="
terraform fmt -recursive

echo "===== TERRAFORM VERSION ====="
terraform version

echo "===== AWS IDENTITY ====="
aws sts get-caller-identity

echo "===== INIT ====="
terraform init -upgrade

echo "===== VALIDATE ====="
terraform validate

echo "===== PLAN ONLY ====="

terraform plan \
  -var="aws_region=ap-south-1" \
  -var="environment=devops-lab" \
  -var="cluster_name=ci-cd-mastery-eks" \
  -var="kubernetes_version=1.34" \
  -var='node_instance_types=["c7i-flex.large"]' \
  -var="node_min_size=3" \
  -var="node_desired_size=3" \
  -var="node_max_size=6" \
  -var="enable_nat_gateway=true" \
  -var="enable_cluster_logs=true" \
  -var="enable_ecr=true"

echo "============================================================"
echo " FOUNDATION PLAN COMPLETE"
echo " NO AWS RESOURCES WERE CREATED BY THIS SCRIPT"
echo "============================================================"
