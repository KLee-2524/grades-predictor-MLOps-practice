resource "aws_cloudwatch_metric_alarm" "endpoint_5xx" {
  alarm_name          = "${var.resource_name_prefix}-cw-endpoint-5xx"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Invocation5XXErrors"
  namespace           = "AWS/SageMaker"
  period              = 60
  statistic           = "Sum"
  threshold           = 1

  dimensions = {
    EndpointName = aws_sagemaker_endpoint.students_endpoint.name
  }

  alarm_description = "Endpoint is returning 5XX errors"
}
