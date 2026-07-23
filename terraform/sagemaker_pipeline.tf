resource "aws_sagemaker_pipeline" "students_pipeline" {
  pipeline_name = "${var.resource_name_prefix}-sm-pipeline"
  role_arn      = aws_iam_role.sagemaker_pipeline.arn

  definition = file("${path.module}/../pipeline/pipeline.json")

  tags = {
    Environment = var.environment
    Name        = "${var.resource_name_prefix}-sm-pipeline"
  }
}
