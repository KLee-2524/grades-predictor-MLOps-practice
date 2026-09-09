locals {
  # Build full S3 URIs from bucket + prefix
  full_training_data_prefix    = "${var.s3_date_directories_prefix}${var.training_data_prefix}"
  full_inference_inputs_prefix = "${var.s3_date_directories_prefix}${var.inference_inputs_prefix}"
  full_predictions_prefix      = "${var.s3_date_directories_prefix}${var.predictions_prefix}"
  full_artifacts_prefix        = "${var.s3_date_directories_prefix}${var.artifacts_prefix}"
  full_endpoint_logs_prefix    = "${var.s3_date_directories_prefix}${var.endpoint_logs_prefix}"
}

################################
# Eventbridge Trigger
################################
resource "aws_cloudwatch_event_rule" "new_csv_trigger" {
  name        = "${var.resource_name_prefix}-ev-new-csv"
  description = "Trigger pipeline when new CSV arrives"
  event_pattern = jsonencode({
    "source" : ["aws.s3"],
    "detail-type" : ["Object Created"],
    "detail" : {
      "bucket" : {
        "name" : [var.data_bucket_name]
      },
      "object" : {
        "key" : [{
          "prefix" : local.full_training_data_prefix
        }]
      }
    }
  })
}

resource "aws_cloudwatch_event_target" "pipeline_target" {
  rule     = aws_cloudwatch_event_rule.new_csv_trigger.name
  arn      = aws_sagemaker_pipeline.students_pipeline.arn
  role_arn = aws_iam_role.eventbridge_sagemaker.arn
}

################################
# Eventbridge Monitoring
################################
resource "aws_cloudwatch_event_rule" "monitoring_alerts" {
  name = "${var.resource_name_prefix}-ev-monitoring-alerts"
  event_pattern = jsonencode({
    "source" : ["aws.sagemaker"],
    "detail-type" : ["SageMaker Model Monitor Alert"]
  })
}

resource "aws_cloudwatch_event_target" "monitoring_target" {
  rule = aws_cloudwatch_event_rule.monitoring_alerts.name
  arn  = aws_sns_topic.user_alerts.arn
}