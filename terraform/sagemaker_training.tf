########################################
# SageMaker Training Job
########################################

resource "aws_sagemaker_training_job" "students_training" {
  name = "${var.resource_name_prefix}-sm-training-job"

  role_arn = aws_iam_role.sagemaker_execution.arn

  algorithm_specification {
    training_image     = aws_ecr_repository.students_model.repository_url
    training_input_mode = "File"
  }

  output_data_config {
    s3_output_path = "s3://${aws_s3_bucket.models.bucket}/artifacts/"
  }

  resource_config {
    instance_type  = var.training_instance_type
    instance_count = 1
    volume_size_gb = 10
  }

  stopping_condition {
    max_runtime_in_seconds = 3600
  }

  input_data_config {
    channel_name = "training"

    data_source {
      s3_data_source {
        s3_data_type       = "S3Prefix"
        s3_uri             = "s3://${aws_s3_bucket.raw_data.bucket}/"
        s3_data_distribution_type = "FullyReplicated"
      }
    }
  }

  tags = {
    Environment = var.environment
    Name        = "${var.resource_name_prefix}-sm-training-job"
  }
}
