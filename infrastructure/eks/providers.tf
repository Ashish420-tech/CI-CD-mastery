provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "CI-CD-Mastery"
      ManagedBy   = "Terraform"
      Platform    = "EKS"
      Environment = var.environment
    }
  }
}
