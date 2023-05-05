output "vpc_id" {
  value = aws_vpc.main.id
}

output "vpc_cidr" {
  value = aws_vpc.main.cidr_block
}

output "vpc_tags" {
  value = aws_vpc.main.tags
}

output "RDS-endpoint" {
  value = aws_db_instance.mysql-db.endpoint
}

output "alb_dns_name" {
  value = aws_alb.ALB.dns_name
}