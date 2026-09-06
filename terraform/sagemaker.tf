locals {
  # Build full S3 URIs from bucket + prefix
  training_data_s3_uri    = "s3://${var.data_bucket_name}/${var.training_data_prefix}"
  inference_inputs_s3_uri = "s3://${var.data_bucket_name}/${var.inference_inputs_prefix}"
  predictions_s3_uri      = "s3://${var.data_bucket_name}/${var.predictions_prefix}"
  artifacts_s3_uri        = "s3://${var.data_bucket_name}/${var.artifacts_prefix}"
  endpoint_logs_s3_uri    = "s3://${var.data_bucket_name}/${var.endpoint_logs_prefix}"

  sm_pipeline_name = "${var.resource_name_prefix}-students-mlops-pipeline"

  training_image_uri = "${aws_ecr_repository.students_model.repository_url}:${var.training_image_tag}"

  sm_pipeline_definition = templatefile("${path.module}/resources/sagemaker/training_pipeline.tpl", {
    pipeline_name        = local.sm_pipeline_name
    instance_type        = var.training_instance_type
    training_job_name    = "${var.resource_name_prefix}-training-job"
    training_image_uri   = local.training_image_uri
    training_data_s3_uri = local.training_data_s3_uri
    artifacts_s3_uri     = local.artifacts_s3_uri
    role_arn             = aws_iam_role.sagemaker_execution.arn
    model_name           = "${var.resource_name_prefix}-model"
    endpoint_config_name = "${var.resource_name_prefix}-endpoint-config"
    endpoint_name        = var.endpoint_name
    }
  )
}

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

    destination_s3_uri = local.endpoint_logs_s3_uri
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
    image = local.training_image_uri

    model_data_url = "${local.artifacts_s3_uri}model.joblib"
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
  pipeline_name         = local.sm_pipeline_name
  pipeline_display_name = local.sm_pipeline_name
  role_arn              = aws_iam_role.sagemaker_pipeline.arn

  pipeline_definition = local.sm_pipeline_definition

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
    training_image      = local.training_image_uri
    training_input_mode = "File"
  }

  output_data_config {
    s3_output_path = local.artifacts_s3_uri
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
        s3_uri                    = local.training_data_s3_uri
        s3_data_distribution_type = "FullyReplicated"
      }
    }
  }

  tags = {
    Environment = var.environment
    Name        = "${var.resource_name_prefix}-sm-training-job"
  }
}