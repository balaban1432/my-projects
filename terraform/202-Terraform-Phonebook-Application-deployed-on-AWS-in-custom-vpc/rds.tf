resource "aws_db_subnet_group" "tf-subnet-group" {
  name       = "rds-subnet-group"
  subnet_ids = [aws_subnet.private1.id, aws_subnet.private2.id]

  tags = {
    Name = "terraform-subnetgroup-${var.owner}"
  }
}

resource "aws_db_instance" "mysql-db" {
  allocated_storage       = 20
  db_name                 = var.database_name
  engine                  = var.db_engine
  engine_version          = var.db_engine_version
  instance_class          = var.db_instance_class
  username                = var.db_username
  password                = var.database_password
  skip_final_snapshot     = true
  db_subnet_group_name    = aws_db_subnet_group.tf-subnet-group.name
  identifier              = var.db_identifier
  port                    = 3306
  vpc_security_group_ids  = [aws_security_group.RDS-sec-grp.id]
  publicly_accessible     = false
  backup_retention_period = 7
}