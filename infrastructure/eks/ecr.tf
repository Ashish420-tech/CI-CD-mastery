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
