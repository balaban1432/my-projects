variable "project_name" {}

variable "aws-region" {}

variable "username" {}

variable "github-name" {}

variable "key_name" {}

variable "az_a" {}

variable "az_b" {}

variable "domain-name" {}

variable "subdomain" {}

variable "nat_instance_ami" {
  default = "ami-0780b09c119334593"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "s3fullaccesspolicy_arn" {
  default = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

variable "ssmfullaccesspolicy_arn" {
  default = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}

variable "dynamodbfullaccesspolicy_arn" {
  default = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

variable "lambdabasicexecutionpolicy_arn" {
  default = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

variable "db_engine_version" {
  default = "8.0.35"
  
}

variable "health_check" {
   type = map(string)
   default = {
      "timeout"  = "10"
      "interval" = "30"
      "path"     = "/"
      "port"     = "80"
      "unhealthy_threshold" = "2"
      "healthy_threshold" = "3"
    }
}

variable "ReadScalingMin" {
  default = 3
}

variable "WriteScalingMin" {
  default = 3
}
