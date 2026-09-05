resource "aws_sagemaker_monitoring_schedule" "data_quality" {
  name = "${var.resource_name_prefix}-sm-data-quality"

  monitoring_schedule_config {
    monitoring_type = "DataQuality"

    #data_quality_config {
    #  baseline_statistics  = "s3://${aws_s3_bucket.models.bucket}/baseline/statistics.json"
    #  baseline_constraints = "s3://${aws_s3_bucket.models.bucket}/baseline/constraints.json"
    #}

    monitoring_job_definition {
      monitoring_inputs {
        endpoint_input {
          local_path    = "/opt/ml/processing/input"
          endpoint_name = aws_sagemaker_endpoint.students_endpoint.name
        }
      }

      monitoring_output_config {
        monitoring_outputs {
          s3_output {
            local_path = "/opt/ml/processing/output"
            s3_uri     = "s3://${aws_s3_bucket.pipeline_logs.bucket}/monitoring/"
          }
        }
      }

      monitoring_resources {
        cluster_config {
          instance_count    = 1
          instance_type     = "ml.m5.large"
          volume_size_in_gb = 20
        }
      }

      role_arn = aws_iam_role.sagemaker_execution.arn
    }
  }
}
