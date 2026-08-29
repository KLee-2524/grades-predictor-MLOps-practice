resource "aws_cloudwatch_event_rule" "monitoring_alerts" {
  name = "${var.resource_name_prefix}-ev-monitoring-alerts"
  event_pattern = jsonencode({
    "source" : ["aws.sagemaker"],
    "detail-type" : ["SageMaker Model Monitor Alert"]
  })
}

resource "aws_cloudwatch_event_target" "monitoring_target" {
  rule = aws_cloudwatch_event_rule.monitoring_alerts.name
  arn  = aws_sns_topic.alerts.arn
}
