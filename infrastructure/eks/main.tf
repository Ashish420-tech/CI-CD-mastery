locals {
  name = var.cluster_name

  azs = [
    "${var.aws_region}a",
    "${var.aws_region}b",
    "${var.aws_region}c"
  ]

  common_tags = {
    Project   = "CI-CD-Mastery"
    Platform  = "EKS"
    Terraform = "true"
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.6.1"

  name = "${local.name}-vpc"
  cidr = var.vpc_cidr

  azs = local.azs

  private_subnets = [
    "10.50.11.0/24",
    "10.50.12.0/24",
    "10.50.13.0/24"
  ]

  public_subnets = [
    "10.50.101.0/24",
    "10.50.102.0/24",
    "10.50.103.0/24"
  ]

  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }

  tags = local.common_tags
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.24.0"

  name               = local.name
  kubernetes_version = var.kubernetes_version

  endpoint_public_access  = true
  endpoint_private_access = true

  authentication_mode = "API_AND_CONFIG_MAP"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  enable_irsa = true

  create_kms_key = true

  encryption_config = {
    resources = ["secrets"]
  }

  enabled_log_types = var.enable_cluster_logs ? [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ] : []

  addons = {
    coredns = {
      most_recent = true
    }

    kube-proxy = {
      most_recent = true
    }

    vpc-cni = {
      most_recent = true
    }
    eks-pod-identity-agent = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true

      pod_identity_association = [{
        role_arn        = aws_iam_role.ebs_csi.arn
        service_account = "ebs-csi-controller-sa"
      }]
    }
  }

  eks_managed_node_groups = {
    system = {
      name = "system"

      instance_types = var.node_instance_types

      min_size     = var.node_min_size
      desired_size = var.node_desired_size
      max_size     = var.node_max_size

      capacity_type = "ON_DEMAND"

      disk_size = 30

      subnet_ids = module.vpc.private_subnets

      labels = {
        role        = "system"
        environment = var.environment
      }

      update_config = {
        max_unavailable = 1
      }

      tags = {
        "k8s.io/cluster-autoscaler/enabled"       = "true"
        "k8s.io/cluster-autoscaler/${local.name}" = "owned"
      }
    }
  }

  tags = local.common_tags
}
