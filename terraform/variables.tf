variable "environment" {
  description = "Deployment environment (dev, prd, etc.)"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "resource_name_prefix" {
  description = "Prefix for all resources, e.g. kel-{env}"
  type        = string
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
