resource "aws_sagemaker_model" "students_model" {
  name = "${var.resource_name_prefix}-sm-model"

  execution_role_arn = aws_iam_role.sagemaker_execution.arn

  primary_container {
    image = aws_ecr_repository.students_model.repository_url

    model_data_url = "s3://${aws_s3_bucket.models.bucket}/artifacts/model.joblib"
  }

  tags = {
    Environment = var.environment
    Name        = "${var.resource_name_prefix}-sm-model"
  }
}
