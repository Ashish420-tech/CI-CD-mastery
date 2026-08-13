cd ~/CI-CD-mastery/infrastructure/eks

cat > eks_create.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# CI/CD MASTERY - REUSABLE EKS PLATFORM
#
# Region       : ap-south-1
# EKS          : Kubernetes 1.34
# AZs          : 3
# Nodes        : min 3 / desired 3 / max 6
# Instance     : c7i-flex.large
# Networking   : VPC + public/private subnets + single NAT Gateway
# Security     : IRSA + KMS secrets encryption + IMDSv2
# Add-ons      : VPC CNI + CoreDNS + kube-proxy + EBS CSI
# Observability: EKS control-plane logging
# Registry     : ECR
#
# This cluster is intended to be reused by Projects 33-100.
###############################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

REGION="ap-south-1"
ENVIRONMENT="devops-lab"
CLUSTER_NAME="ci-cd-mastery-eks"
KUBERNETES_VERSION="1.34"

NODE_INSTANCE_TYPE="c7i-flex.large"
NODE_MIN_SIZE="3"
NODE_DESIRED_SIZE="3"
NODE_MAX_SIZE="6"

echo
echo "============================================================"
echo " CI/CD MASTERY - EKS PLATFORM CREATION"
echo "============================================================"
echo "Region             : ${REGION}"
echo "Cluster            : ${CLUSTER_NAME}"
echo "Kubernetes         : ${KUBERNETES_VERSION}"
echo "Node instance      : ${NODE_INSTANCE_TYPE}"
echo "Minimum nodes      : ${NODE_MIN_SIZE}"
echo "Desired nodes      : ${NODE_DESIRED_SIZE}"
echo "Maximum nodes      : ${NODE_MAX_SIZE}"
echo "============================================================"
echo

###############################################################################
# 1. PRE-FLIGHT CHECKS
###############################################################################

echo "===== 1. PRE-FLIGHT CHECKS ====="

command -v terraform >/dev/null || {
    echo "ERROR: terraform is not installed"
    exit 1
}

command -v aws >/dev/null || {
    echo "ERROR: AWS CLI is not installed"
    exit 1
}

command -v kubectl >/dev/null || {
    echo "ERROR: kubectl is not installed"
    exit 1
}

echo "Terraform:"
terraform version | head -1

echo
echo "AWS CLI:"
aws --version

echo
echo "kubectl:"
kubectl version --client --output=yaml | grep -E 'gitVersion:' | head -1 || true

###############################################################################
# 2. AWS IDENTITY
###############################################################################

echo
echo "===== 2. AWS IDENTITY ====="

aws sts get-caller-identity

echo
echo "AWS Region: ${REGION}"

###############################################################################
# 3. TERRAFORM CONFIGURATION
###############################################################################

echo
echo "===== 3. TERRAFORM FILES ====="

test -f versions.tf
test -f providers.tf
test -f variables.tf
test -f main.tf
test -f ecr.tf
test -f outputs.tf

echo "Terraform configuration files found."

###############################################################################
# 4. FORMAT
###############################################################################

echo
echo "===== 4. TERRAFORM FORMAT ====="

terraform fmt -recursive

###############################################################################
# 5. INITIALIZE
###############################################################################

echo
echo "===== 5. TERRAFORM INIT ====="

terraform init -upgrade

###############################################################################
# 6. VALIDATE
###############################################################################

echo
echo "===== 6. TERRAFORM VALIDATE ====="

terraform validate

###############################################################################
# 7. PLAN
###############################################################################

echo
echo "===== 7. TERRAFORM PLAN ====="

rm -f eks-foundation.tfplan

terraform plan \
  -out=eks-foundation.tfplan \
  -var="aws_region=${REGION}" \
  -var="environment=${ENVIRONMENT}" \
  -var="cluster_name=${CLUSTER_NAME}" \
  -var="kubernetes_version=${KUBERNETES_VERSION}" \
  -var='node_instance_types=["c7i-flex.large"]' \
  -var="node_min_size=${NODE_MIN_SIZE}" \
  -var="node_desired_size=${NODE_DESIRED_SIZE}" \
  -var="node_max_size=${NODE_MAX_SIZE}" \
  -var="enable_nat_gateway=true" \
  -var="enable_cluster_logs=true" \
  -var="enable_ecr=true"

echo
echo "============================================================"
echo " PLAN CREATED"
echo "============================================================"
echo
echo "The exact plan is saved as:"
echo
echo "  ${SCRIPT_DIR}/eks-foundation.tfplan"
echo

###############################################################################
# 8. APPLY
###############################################################################

echo "============================================================"
echo " APPLYING EKS PLATFORM"
echo "============================================================"
echo
echo "This creates AWS resources."
echo

terraform apply -auto-approve eks-foundation.tfplan

###############################################################################
# 9. TERRAFORM OUTPUTS
###############################################################################

echo
echo "============================================================"
echo " TERRAFORM OUTPUTS"
echo "============================================================"

terraform output

###############################################################################
# 10. UPDATE KUBECONFIG
###############################################################################

echo
echo "===== 10. CONFIGURE KUBECTL ====="

aws eks update-kubeconfig \
  --region "${REGION}" \
  --name "${CLUSTER_NAME}"

###############################################################################
# 11. WAIT FOR CLUSTER
###############################################################################

echo
echo "===== 11. WAITING FOR EKS ====="

aws eks wait cluster-active \
  --region "${REGION}" \
  --name "${CLUSTER_NAME}"

echo "EKS control plane is ACTIVE."

###############################################################################
# 12. CLUSTER INFORMATION
###############################################################################

echo
echo "===== 12. CLUSTER INFO ====="

kubectl cluster-info

###############################################################################
# 13. NODE VERIFICATION
###############################################################################

echo
echo "===== 13. EKS NODES ====="

kubectl get nodes -o wide

echo
echo "===== NODE COUNT ====="

NODE_COUNT="$(kubectl get nodes --no-headers 2>/dev/null | wc -l)"

echo "Node count: ${NODE_COUNT}"

if [ "${NODE_COUNT}" -lt 3 ]; then
    echo "ERROR: Expected at least 3 nodes."
    exit 1
fi

###############################################################################
# 14. NODE READINESS
###############################################################################

echo
echo "===== 14. NODE READINESS ====="

kubectl get nodes \
  -o custom-columns='NAME:.metadata.name,STATUS:.status.conditions[-1].type,KERNEL:.status.nodeInfo.kernelVersion,KUBELET:.status.nodeInfo.kubeletVersion'

###############################################################################
# 15. SYSTEM PODS
###############################################################################

echo
echo "===== 15. SYSTEM PODS ====="

kubectl get pods -A -o wide

###############################################################################
# 16. EKS ADD-ONS
###############################################################################

echo
echo "===== 16. EKS ADD-ONS ====="

aws eks list-addons \
  --region "${REGION}" \
  --cluster-name "${CLUSTER_NAME}"

###############################################################################
# 17. EKS CLUSTER DETAILS
###############################################################################

echo
echo "===== 17. EKS DETAILS ====="

aws eks describe-cluster \
  --region "${REGION}" \
  --name "${CLUSTER_NAME}" \
  --query 'cluster.{Name:name,Status:status,Version:version,Endpoint:endpoint,PlatformVersion:platformVersion}' \
  --output table

###############################################################################
# 18. NODEGROUP DETAILS
###############################################################################

echo
echo "===== 18. NODE GROUP ====="

aws eks list-nodegroups \
  --region "${REGION}" \
  --cluster-name "${CLUSTER_NAME}"

###############################################################################
# 19. ECR
###############################################################################

echo
echo "===== 19. ECR ====="

aws ecr describe-repositories \
  --region "${REGION}" \
  --repository-names "ci-cd-mastery/applications" \
  --query 'repositories[].{Name:repositoryName,URI:repositoryUri,ScanOnPush:imageScanningConfiguration.scanOnPush,TagMutability:imageTagMutability}' \
  --output table

###############################################################################
# 20. STORAGE CLASS
###############################################################################

echo
echo "===== 20. STORAGE ====="

kubectl get storageclass || true

###############################################################################
# 21. IRSA / OIDC
###############################################################################

echo
echo "===== 21. OIDC ====="

aws eks describe-cluster \
  --region "${REGION}" \
  --name "${CLUSTER_NAME}" \
  --query 'cluster.identity.oidc.issuer' \
  --output text

###############################################################################
# 22. FINAL HEALTH CHECK
###############################################################################

echo
echo "============================================================"
echo " FINAL EKS HEALTH CHECK"
echo "============================================================"

CLUSTER_STATUS="$(
  aws eks describe-cluster \
    --region "${REGION}" \
    --name "${CLUSTER_NAME}" \
    --query 'cluster.status' \
    --output text
)"

echo "Cluster status: ${CLUSTER_STATUS}"

if [ "${CLUSTER_STATUS}" != "ACTIVE" ]; then
    echo "ERROR: EKS cluster is not ACTIVE."
    exit 1
fi

READY_NODES="$(
  kubectl get nodes \
    --no-headers \
    2>/dev/null |
    grep -c ' Ready ' || true
)"

echo "Ready nodes: ${READY_NODES}"

if [ "${READY_NODES}" -lt 3 ]; then
    echo "ERROR: Fewer than 3 Ready nodes."
    kubectl get nodes -o wide
    exit 1
fi

echo
echo "============================================================"
echo " EKS PLATFORM SUCCESSFULLY CREATED"
echo "============================================================"
echo
echo "Cluster       : ${CLUSTER_NAME}"
echo "Region        : ${REGION}"
echo "Kubernetes    : ${KUBERNETES_VERSION}"
echo "Ready nodes   : ${READY_NODES}"
echo "Node range    : ${NODE_MIN_SIZE}-${NODE_MAX_SIZE}"
echo "EKS add-ons   : VPC CNI / CoreDNS / kube-proxy / EBS CSI"
echo "IRSA          : Enabled"
echo "KMS           : Enabled"
echo "ECR           : Enabled"
echo "Control logs  : Enabled"
echo
echo "Reusable platform is ready for Projects 33-100."
echo "============================================================"
