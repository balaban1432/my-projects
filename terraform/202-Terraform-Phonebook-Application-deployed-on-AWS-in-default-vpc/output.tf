output "RDS-endpoint" {
  value = aws_db_instance.mysql-db.endpoint
}

output "alb_dns_name" {
  value = aws_alb.ALB.dns_name
}

