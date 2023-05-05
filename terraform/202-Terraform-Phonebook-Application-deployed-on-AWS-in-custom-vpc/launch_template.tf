data "aws_ami" "ec2-ami" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}



resource "aws_launch_template" "web-server" {
  name                   = "webservertemplate"
  image_id               = data.aws_ami.ec2-ami.id
  instance_type          = var.aws_instance_type
  key_name               = var.key-name
  vpc_security_group_ids = [aws_security_group.EC2-sec-grp.id]
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "Web-Server-PhonebookApp-${var.owner}"
    }
  }
  user_data = filebase64("user-data.sh")
  depends_on = [
    github_repository_file.dbendpoint,
    aws_db_instance.mysql-db
  ]
}

resource "github_repository_file" "dbendpoint" {
  content             = aws_db_instance.mysql-db.address
  file                = "dbserver.endpoint"
  repository          = "phonebook"
  overwrite_on_create = true
  branch              = "main"
}