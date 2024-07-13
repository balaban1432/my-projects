terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    null = {
      source = "hashicorp/null"
      version = "~> 3.0"
    }

    archive = {
      source = "hashicorp/archive"
      version = "2.4.2"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}
