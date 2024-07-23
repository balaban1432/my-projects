terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}


provider "aws" {
  region = var.aws-region
}


data "aws_ssm_parameter" "github-token" {
  name = "git-token"
}

provider "github" {
  token = data.aws_ssm_parameter.github-token.value
}
