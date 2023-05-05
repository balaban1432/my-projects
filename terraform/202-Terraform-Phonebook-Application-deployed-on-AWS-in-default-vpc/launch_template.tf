data "aws_ami" "ec2-ami" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}


data "template_file" "userdata" {
  template = file("${abspath(path.module)}/user-data.sh")
  vars = {
    db-endpoint = aws_db_instance.mysql-db.address
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
  user_data = "${base64encode(data.template_file.userdata.rendered)}"
  depends_on = [
    aws_db_instance.mysql-db
  ]
}
