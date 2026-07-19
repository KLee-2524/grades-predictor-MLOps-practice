resource "aws_sagemaker_endpoint" "students_endpoint" {
  name = "${var.resource_name_prefix}-sm-endpoint"
  endpoint_config_name = aws_sagemaker_endpoint_configuration.students_endpoint_config.name

  tags = {
    Environment = var.environment
    Name        = "${var.resource_name_prefix}-sm-endpoint"
  }
}
