output "rds_hostname" {
  description = "RDS instance hostname"
  value       = aws_db_instance.rds.endpoint
  sensitive   = true
}

output "s3_website_url" {
  description = "S3 website endpoint"
  value       = aws_s3_bucket_website_configuration.r53webconf.website_endpoint
}

output "certificate_arn" {
  description = "certificate"
  value = data.aws_acm_certificate.cert.arn
}

output "ubuntu_ami_id" {
  value = data.aws_ami.ubuntu-22-04.id
}

output "db_endpoint" {
  value = aws_db_instance.rds.endpoint
}

output "elb-endpoint" {
  value = aws_lb.capstone-lb.dns_name
}

output "cloudfront-endpoit" {
  value = aws_cloudfront_distribution.elb_distribution.domain_name
}