########################################
# ECR Repository
########################################

resource "aws_ecr_repository" "students_model" {
  name                 = "${var.resource_name_prefix}-ecr-students_model"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Environment = var.environment
    Name        = "${var.resource_name_prefix}-ecr-students_model"
  }
}

output "ecr_repo_training_image_uri" {
  value = aws_ecr_repository.students_model.repository_url
}

########################################
# ECR Lifecycle Policy
########################################

resource "aws_ecr_lifecycle_policy" "students_model_lifecycle" {
  repository = aws_ecr_repository.students_model.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
