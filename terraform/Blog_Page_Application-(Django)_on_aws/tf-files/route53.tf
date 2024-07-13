
resource "aws_route53_health_check" "capstone" {
  failure_threshold        = 3
  fqdn                     = aws_cloudfront_distribution.elb_distribution.domain_name
  port                     = 80
  request_interval         = 30
  type                     = "HTTP"

}

data "aws_route53_zone" "capstone" {
  name         = var.domain-name
}

resource "aws_route53_record" "primary" {
  zone_id = data.aws_route53_zone.capstone.id
  name    = var.subdomain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.elb_distribution.domain_name
    zone_id                = "Z2FDTNDATAQYW2" # CloudFront Hosted Zone ID for all distributions
    evaluate_target_health = true
  }
 failover_routing_policy {
    type = "PRIMARY"
  }
 set_identifier = "primary"
 health_check_id = aws_route53_health_check.capstone.id
}

resource "aws_route53_record" "secondary" {
  zone_id = data.aws_route53_zone.capstone.id
  name    = var.subdomain
  type    = "A"

  alias {
    name                   = lookup(local.region_map[data.aws_region.current.name], "websiteendpoint")
    zone_id                = lookup(local.region_map[data.aws_region.current.name], "s3hostedzoneID")
    evaluate_target_health = false
  }
 set_identifier = "secondary"

 failover_routing_policy { 
    type = "SECONDARY"
  }
}

data "aws_region" "current" {}

locals {
  region_map = {
    "us-east-1" = {
      s3hostedzoneID = "Z3AQBSTGFYJSTF",
      websiteendpoint = "s3-website-us-east-1.amazonaws.com"
    },
    "us-west-1" = {
      s3hostedzoneID = "Z2F56UZL2M1ACD",
      websiteendpoint = "s3-website-us-west-1.amazonaws.com"
    },
    "us-west-2" = {
      s3hostedzoneID = "Z3BJ6K6RIION7M",
      websiteendpoint = "s3-website-us-west-2.amazonaws.com"
    },
    "eu-west-1" = {
      s3hostedzoneID = "Z1BKCTXD74EZPE",
      websiteendpoint = "s3-website-eu-west-1.amazonaws.com"
    }
  }
}