resource "aws_security_group" "alb" {
  name        = "${var.project_name}_alb"
  description = "Enable HTTP and HTTPS for ALB"
  vpc_id      = aws_vpc.my_vpc.id

  
}

resource "aws_vpc_security_group_ingress_rule" "enable_443_alb" {
  security_group_id = aws_security_group.alb.id
  from_port         = 443
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "enable_80_alb" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "enableoutbound_alb" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}



#create ec2 security groups
resource "aws_security_group" "ec2" {
  name        = "${var.project_name}_ec2_sec_grp"
  description = "Enable HTTP, HTTPS and SSH "
  vpc_id      = aws_vpc.my_vpc.id
  }

resource "aws_vpc_security_group_ingress_rule" "enable_443_ec2" {
  security_group_id = aws_security_group.ec2.id
  referenced_security_group_id = aws_security_group.alb.id
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "enable_80_ec2" {
  security_group_id = aws_security_group.ec2.id
  referenced_security_group_id = aws_security_group.alb.id
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "enable_22_ec2" {
  security_group_id = aws_security_group.ec2.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "enableoutbound_ec2" {
  security_group_id = aws_security_group.ec2.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}



#create database security group
resource "aws_security_group" "database" {
  name        = "${var.project_name}_database_sec_grp"
  description = "Enable 3306 "
  vpc_id      = aws_vpc.my_vpc.id
  }

resource "aws_vpc_security_group_ingress_rule" "enable_3306_db" {
  security_group_id = aws_security_group.database.id
  referenced_security_group_id = aws_security_group.ec2.id
  from_port         = 3306
  ip_protocol       = "tcp"
  to_port           = 3306
}

resource "aws_vpc_security_group_egress_rule" "enableoutbound_db" {
  security_group_id = aws_security_group.database.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}


#create nat-instance security group

resource "aws_security_group" "nat" {
  name        = "${var.project_name}_nat_instance_sec_grp"
  description = "Enable SSH, HTTP and HTTPS for ALB"
  vpc_id      = aws_vpc.my_vpc.id

  
}

resource "aws_vpc_security_group_ingress_rule" "enable_443_nat" {
  security_group_id = aws_security_group.nat.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "enable_80_nat" {
  security_group_id = aws_security_group.nat.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "enable_22_nat" {
  security_group_id = aws_security_group.nat.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}



resource "aws_vpc_security_group_egress_rule" "enableoutbound_nat" {
  security_group_id = aws_security_group.nat.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

