variable "owner" {
  default = "balaban"
}

variable "vpc_cidr_block" {
  default = "90.90.0.0/16"
}

variable "public_subnet1_cidr" {
  default = "90.90.10.0/24"
}

variable "public_subnet2_cidr" {
  default = "90.90.20.0/24"
}

variable "private_subnet1_cidr" {
  default = "90.90.11.0/24"
}

variable "private_subnet2_cidr" {
  default = "90.90.21.0/24"
}

variable "vpc-region" {
  default = "us-east-1"
}

variable "database_name" {
  default = "phonebook"
}

variable "database_password" {
  default = "RamazanBALABAN_1"
}

variable "db_username" {
  default = "admin"
}

variable "db_instance_class" {
  default = "db.t2.micro"
}

variable "db_identifier" {
  default = "rds-database"
}

variable "db_engine" {
  default = "mysql"
}

variable "db_engine_version" {
  default = "8.0.28"
}

variable "aws_instance_type" {
  default = "t2.micro"
}

variable "key-name" {
  default = "derya-key"
}

