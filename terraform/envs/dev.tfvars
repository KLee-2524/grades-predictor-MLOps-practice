environment                = "dev"
aws_region                 = "us-west-2"
resource_name_prefix       = "kel-dev"

data_bucket_name           = "kel-dev-student-grades"
s3_date_directories_prefix = "2026/09/06/"

training_instance_type     = "ml.t3.medium"
endpoint_instance_type     = "ml.t3.medium"
# https://docs.aws.amazon.com/sagemaker/latest/dg/notebooks-available-instance-types.html