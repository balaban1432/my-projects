terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  backend "s3" {
    bucket = "derya-jenkins-backend"
    key    = "backend/jenkins.tfstate"
    region = "us-east-1"
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

variable "tags_ec2" {
    default = ["postgresql", "nodejs", "react"]  
}

variable "user" {
    default = "balaban"
}

variable "ports" {
    default = [22, 3000, 5000, 5432]  
}

resource "aws_security_group" "my_sec_grp" {
  name        = "${var.user}-project208-sec-grp"

  dynamic "ingress" {
    for_each = var.ports
    content {
      from_port = ingress.value
      to_port = ingress.value
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "project208-sec-grp"
  }
}

resource "aws_instance" "managed_nodes" {
    ami = "ami-016eb5d644c333ccb"
    count = 3
    instance_type = "t2.micro"
    key_name = "derya-key"
    vpc_security_group_ids = [aws_security_group.my_sec_grp.id]
    iam_instance_profile   = "jenkins-project-profile-${var.user}" # we created this with jenkins server
    tags = {
        Name        = "ansible_${element(var.tags_ec2, count.index)}"
        stack       = "ansible_project"
        environment = "development"
    }
    user_data = <<-EOF
                #! /bin/bash
                dnf update -y
                EOF    
}

output "react_ip" {
  value = "http://${aws_instance.managed_nodes[2].public_ip}:3000"
}

output "node_public_ip" {
  value = aws_instance.managed_nodes[1].public_ip
}

output "postgre_private_ip" {
  value = aws_instance.managed_nodes[0].private_ip
}