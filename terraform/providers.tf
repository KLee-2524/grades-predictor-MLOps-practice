terraform {
  cloud {
    organization = "kel-aws-org"

    workspaces {
      name = "students-mlops"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
