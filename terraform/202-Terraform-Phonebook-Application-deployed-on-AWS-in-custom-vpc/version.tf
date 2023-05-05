terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.58.0"
    }
    github = {
      source  = "integrations/github"
      version = "5.18.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = var.vpc-region
}

provider "github" {
  token = "xxxxxxxxxxxxxxxxxx"
}