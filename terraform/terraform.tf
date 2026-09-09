terraform {

  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "kel-aws-org"

    workspaces {
      name = "grades-predictor-MLOps-practice-#{tf-env}#"
    }
  }

  required_version = ">= 1.3"

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    awscc = {
      version = "0.77.0"
    }
  }
}