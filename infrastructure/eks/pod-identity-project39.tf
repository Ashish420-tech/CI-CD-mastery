# ============================================================
# PROJECT 39 — EKS POD IDENTITY
# Existing EKS platform extension
# ============================================================

data "aws_iam_policy_document" "project39_pod_identity_assume" {
  statement {
    effect = "Allow"

    principals {
      type = "Service"

      identifiers = [
        "pods.eks.amazonaws.com"
      ]
    }

    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
  }
}

data "aws_iam_policy_document" "project39_permissions" {
  statement {
    effect = "Allow"

    actions = [
      "sts:GetCallerIdentity"
    ]

    resources = [
      "*"
    ]
  }
}

resource "aws_iam_role" "project39_pod_identity" {
  name = "GitHubActions-Project39PodIdentityRole"

  assume_role_policy = data.aws_iam_policy_document.project39_pod_identity_assume.json

  tags = {
    Project     = "39"
    Component   = "EKS-Pod-Identity"
    Environment = "platform"
    ManagedBy   = "Terraform"
  }
}

resource "aws_iam_role_policy" "project39_pod_identity" {
  name   = "project-39-minimal-identity-policy"
  role   = aws_iam_role.project39_pod_identity.id
  policy = data.aws_iam_policy_document.project39_permissions.json
}

resource "aws_eks_pod_identity_association" "project39" {
  cluster_name    = var.cluster_name
  namespace       = "project-39"
  service_account = "project-39-app"
  role_arn        = aws_iam_role.project39_pod_identity.arn
}

output "project39_pod_identity_role_arn" {
  value = aws_iam_role.project39_pod_identity.arn
}

output "project39_pod_identity_association_arn" {
  value = aws_eks_pod_identity_association.project39.association_arn
}
