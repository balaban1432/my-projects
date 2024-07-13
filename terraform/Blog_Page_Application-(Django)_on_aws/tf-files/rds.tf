resource "aws_db_instance" "rds" {
  allocated_storage    = 20
  db_name              = "clarusway"
  engine               = "mysql"
  engine_version       = var.db_engine_version
  db_subnet_group_name = aws_db_subnet_group.dbsubnetgrp.name
  instance_class       = "db.t3.micro"
  identifier           = var.username
  username             = data.aws_ssm_parameter.db_username.value
  password             = data.aws_ssm_parameter.db_password.value
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = "true"
  monitoring_interval = 0
  vpc_security_group_ids = [aws_security_group.database.id]
  publicly_accessible = "false"
}