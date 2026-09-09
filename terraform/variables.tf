variable "environment" {
  description = "Deployment environment (dev, prd, etc.)"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "monitor_image_account_id" {
  description = "AWS SageMaker provided model monitoring image account number MUST be updated with aws_region"
  type        = string
  default     = "763104351884"
}

variable "resource_name_prefix" {
  description = "Prefix for all resources, e.g. kel-{env}"
  type        = string
}

variable "training_image_tag" {
  description = "Tag for the training image"
  type        = string
  default     = "latest"
}

# Example ML-related variables (we'll refine as we go)
variable "training_instance_type" {
  description = "Instance type for SageMaker training jobs"
  type        = string
}

variable "endpoint_instance_type" {
  description = "Instance type for SageMaker endpoint"
  type        = string
}

# NEW BUDGET AI DLC VARIABLES
variable "data_bucket_name" {
  description = "S3 bucket for inputs, outputs, training data, and artifacts"
  type        = string
}

variable "s3_date_directories_prefix" {
  description = "Date prefix for S3 directories, e.g. 2026/09/05/"
  type        = string
}

variable "training_data_prefix" {
  description = "location in s3 where training data is stored"
  type        = string
  default     = "training/"
}

variable "inference_inputs_prefix" {
  description = "location in s3 where unlabeled inference input data"
  type        = string
  default     = "inputs/"
}

variable "predictions_prefix" {
  description = "location in s3 where the model predictions are stored"
  type        = string
  default     = "outputs/"
}

variable "artifacts_prefix" {
  description = "location in s3 where model artifacts are stored"
  type        = string
  default     = "artifacts/"
}

variable "endpoint_logs_prefix" {
  description = "location in s3 where sagemaker training endpoint logs are stored"
  type        = string
  default     = "endpoint-logs/"
}

variable "endpoint_name" {
  description = "name of sagemaker endpoint"
  type        = string
  default     = "student-grades-sm-endpoint"
}