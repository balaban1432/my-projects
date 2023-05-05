resource "aws_security_group" "ALB-sec-grp" {
  name        = "ALB-sec-grp"
  description = "Allow http"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-ALB-sec-grp-${var.owner}"
  }
}

resource "aws_security_group" "EC2-sec-grp" {
  name        = "ec2-sec-grp"
  description = "Allow ssh, http"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.ALB-sec-grp.id]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-EC2-sec-grp-${var.owner}"
  }
}

resource "aws_security_group" "RDS-sec-grp" {
  name        = "RDS-sec-grp"
  description = "Allow 3306"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.EC2-sec-grp.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-RDS-sec-grp-${var.owner}"
  }
}

