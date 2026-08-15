resource "aws_ecr_repository" "applications" {
  count = var.enable_ecr ? 1 : 0

  name                 = "ci-cd-mastery/applications"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  force_delete = true

  tags = {
    Purpose = "Shared application registry"
  }
}

# Project 37 — Immutable image retention.
# Keep the most recent 20 images to control ECR storage cost while
# preserving enough release history for rollback and audit purposes.

resource "aws_ecr_lifecycle_policy" "applications" {
  count = var.enable_ecr ? 1 : 0

  repository = aws_ecr_repository.applications[0].name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Retain the newest 20 immutable application images"

        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 20
        }

        action = {
          type = "expire"
        }
      }
    ]
  })
}
