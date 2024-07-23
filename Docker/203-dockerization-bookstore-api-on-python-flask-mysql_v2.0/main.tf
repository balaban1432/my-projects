resource "github_repository" "docker-repo" {
  name        = "bookstore-api"
  description = "203-phonebook project repo"
  visibility  = "private"
  auto_init   = true
}


resource "github_branch_default" "main" {
  repository = github_repository.docker-repo.name
  branch     = "main"
}


locals {
  files = ["requirements.txt", "docker-compose.yml", "Dockerfile", "bookstore-api.py"]
}

resource "github_repository_file" "app-files" {
  repository          = github_repository.docker-repo.name
  branch              = "main"
  for_each            = toset(local.files)
  file                = each.value
  content             = file(each.value)
  commit_message      = "Managed by Terraform"
  commit_author       = var.github-author
  commit_email        = var.author-email
  overwrite_on_create = true
}


resource "aws_security_group" "docker-instance-sec-grp" {
  name        = "webserver-sec-grp"
  description = "Allow ssh and http inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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
    Name = "docker-sec-grp"
  }
}


data "aws_ami" "ec2_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }
}

resource "aws_instance" "webserver" {
  ami                    = data.aws_ami.ec2_ami.id
  instance_type          = var.instance-type
  key_name               = var.key-name
  vpc_security_group_ids = [aws_security_group.docker-instance-sec-grp.id]
  tags = {
    Name = "Web-Server-of-Bookstore"
  }
  user_data = templatefile("userdata.sh", { userdata-git-token = data.aws_ssm_parameter.github-token.value, userdata-git-name = var.git-name })
  depends_on = [
    github_repository.docker-repo,
    github_repository_file.app-files
  ]
}

