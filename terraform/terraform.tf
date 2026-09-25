terraform {

  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "kel-aws-org-2"

    workspaces {
      name = "grades-predictor-MLOps-practice"
    }
  }

  required_version = ">= 1.4.0"

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    awscc = {
      version = "0.77.0"
    }
  }
}