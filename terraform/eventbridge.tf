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
        "name" : [aws_s3_bucket.raw_data.bucket]
      },
      "object" : {
        "key" : [{
          "prefix" : ""
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