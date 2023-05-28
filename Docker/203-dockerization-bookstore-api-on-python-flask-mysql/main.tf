resource "aws_security_group" "docker-ec2-sec-grp" {
  name        = "docker-sec-grp"
  description = "Allow http and sh"

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }  

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "balaban-docker-sec-grp"
  }
}


data "aws_ami" "ec2_ami" {
    owners = [ "amazon" ]
    most_recent = true
    filter {
      name = "name"
      values = ["amzn2-ami-hvm*"]
    }  
}


resource "aws_instance" "web" {
  ami           = data.aws_ami.ec2_ami.id
  instance_type = "t2.micro"
  key_name = "derya-key"
  vpc_security_group_ids = [ aws_security_group.docker-ec2-sec-grp.id ]
  user_data = file("${path.module}/userdata.sh")
  tags = {
    Name = "web-server-of-Bookstore"
  }
  depends_on = [
    github_repository.repo,
    github_repository_file.file
  ]
}


resource "github_repository" "repo" {
  name      = "bookstore"
  auto_init = true
  visibility = "private"
}


locals {
  files = [ "requirements.txt", "docker-compose.yml", "Dockerfile", "bookstore-api.py" ]
}


resource "github_repository_file" "file" {
  repository          = github_repository.repo.name
  for_each = toset(local.files)
  file                = each.value
  content             = file(each.value)
  commit_message      = "Managed by Terraform"
  overwrite_on_create = true
}



output "webserver-dns" {
    value = "http://${aws_instance.web.public_dns}"  
}