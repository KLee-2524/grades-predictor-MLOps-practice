resource "aws_sagemaker_endpoint_configuration" "students_endpoint_config" {
  name = "${var.resource_name_prefix}-sm-endpoint-config"

  production_variants {
    variant_name           = "AllTraffic"
    model_name             = aws_sagemaker_model.students_model.name
    initial_instance_count = 1
    instance_type          = var.endpoint_instance_type
  }

  data_capture_config {
    enable_capture              = true
    initial_sampling_percentage = 100

    destination_s3_uri = "s3://${aws_s3_bucket.pipeline_logs.bucket}/endpoint-capture/"
  }

  tags = {
    Environment = var.environment
    Name        = "${var.resource_name_prefix}-sm-endpoint-config"
  }
}
