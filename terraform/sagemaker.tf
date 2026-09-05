##########################
# Sagemaker Endpoint
##########################
resource "aws_sagemaker_endpoint" "students_endpoint" {
  name                 = "${var.resource_name_prefix}-sm-endpoint"
  endpoint_config_name = aws_sagemaker_endpoint_configuration.students_endpoint_config.name

  tags = {
    Environment = var.environment
    Name        = "${var.resource_name_prefix}-sm-endpoint"
  }
}

##########################
# Sagemaker Endpoint Config
##########################
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

    capture_options {
      capture_mode = "Output"
    }

    destination_s3_uri = "s3://${aws_s3_bucket.pipeline_logs.bucket}/endpoint-capture/"
  }

  tags = {
    Environment = var.environment
    Name        = "${var.resource_name_prefix}-sm-endpoint-config"
  }
}

##########################
# Sagemaker Model
##########################
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

##########################
# Sagemaker Pipeline
##########################
resource "aws_sagemaker_pipeline" "students_pipeline" {
  pipeline_name         = "${var.resource_name_prefix}-sm-pipeline"
  pipeline_display_name = "${var.resource_name_prefix}-sm-pipeline"
  role_arn              = aws_iam_role.sagemaker_pipeline.arn

  pipeline_definition = file("${path.module}/../pipeline/pipeline.json")

  tags = {
    Environment = var.environment
    Name        = "${var.resource_name_prefix}-sm-pipeline"
  }
}

##########################
# Sagemaker Training
##########################
########################################
# SageMaker Training Job
########################################

resource "aws_sagemaker_training_job" "students_training" {
  training_job_name = "${var.resource_name_prefix}-sm-training-job"

  role_arn = aws_iam_role.sagemaker_execution.arn

  algorithm_specification {
    training_image      = aws_ecr_repository.students_model.repository_url
    training_input_mode = "File"
  }

  output_data_config {
    s3_output_path = "s3://${aws_s3_bucket.models.bucket}/artifacts/"
  }

  resource_config {
    instance_type     = var.training_instance_type
    instance_count    = 1
    volume_size_in_gb = 10
  }

  stopping_condition {
    max_runtime_in_seconds = 3600
  }

  input_data_config {
    channel_name = "training"

    data_source {
      s3_data_source {
        s3_data_type              = "S3Prefix"
        s3_uri                    = "s3://${aws_s3_bucket.raw_data.bucket}/"
        s3_data_distribution_type = "FullyReplicated"
      }
    }
  }

  tags = {
    Environment = var.environment
    Name        = "${var.resource_name_prefix}-sm-training-job"
  }
}