terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.9.0"
    }
  }

  required_version = ">= 1.3.9"
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

variable "domain" {
  default = "hayvanhaklari.balabandevops.online"
  type    = string
}

variable "bucketName" {
  default = "hayvanhaklari.balabandevops.online"
  type    = string
}

resource "aws_s3_bucket" "website_bucket" {
  bucket = var.bucketName
}
resource "aws_s3_object" "example-index" {
  bucket = aws_s3_bucket.website_bucket.id
  key    = "index.html"
  source = "C:/Users/balaban/Desktop/my-projects/aws/Project-006-kittens-carousel-static-web-s3-cf/static-web/index.html"
  acl    = "public-read"
}

resource "aws_s3_object" "object1" {
  for_each = fileset("C:/Users/balaban/Desktop/my-projects/aws/Project-006-kittens-carousel-static-web-s3-cf/static-web/", "*")
  bucket   = aws_s3_bucket.website_bucket.id
  key      = each.value
  source   = "C:/Users/balaban/Desktop/my-projects/aws/Project-006-kittens-carousel-static-web-s3-cf/static-web/${each.value}"
  etag     = filemd5("C:/Users/balaban/Desktop/my-projects/aws/Project-006-kittens-carousel-static-web-s3-cf/static-web/${each.value}")
}

resource "aws_s3_bucket_policy" "b3" {
  bucket = aws_s3_bucket.website_bucket.id
  policy = <<POLICY
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "AllowPublicRead",
            "Effect": "Allow",
            "Principal": {
                "AWS": "*"
            },
            "Action": [
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::${aws_s3_bucket.website_bucket.bucket}/*"
            ]
        }
    ]
}
POLICY
}

resource "aws_s3_bucket_website_configuration" "site" {
  bucket = aws_s3_bucket.website_bucket.id

  index_document {
    suffix = "index.html"
  }
}


output "website_bucket_name" {
  value = "http://${aws_s3_bucket.website_bucket.id}.s3-website-us-east-1.amazonaws.com"
}
