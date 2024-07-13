#create target grp

resource "aws_lb_target_group" "tg" {
   name               = "${var.username}-lt"
   port               = 80
   protocol           = "HTTP"
   vpc_id             = aws_vpc.my_vpc.id
   health_check {
      healthy_threshold   = var.health_check["healthy_threshold"]
      interval            = var.health_check["interval"]
      unhealthy_threshold = var.health_check["unhealthy_threshold"]
      timeout             = var.health_check["timeout"]
      path                = var.health_check["path"]
      port                = var.health_check["port"]
  }
}

# Attach the target group for "test" ALB

# create ALB

resource "aws_lb" "capstone-lb" {
  name               = "${var.project_name}-alb"
  internal           = false
  ip_address_type    = "ipv4"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.public_1a_subnet.id, aws_subnet.public_1b_subnet.id ]

}

# get certificate 
# Find a certificate that is issued

data "aws_acm_certificate" "cert" {
  domain      = "*.${var.domain-name}"
  statuses = ["ISSUED"]
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}


resource "aws_lb_listener" "rule_443" {
  load_balancer_arn = aws_lb.capstone-lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

resource "aws_lb_listener" "rule_80" {
  load_balancer_arn = aws_lb.capstone-lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}


#check if RDS endpoint is ready

data "aws_db_instance" "database" {
  
  depends_on = [aws_db_instance.rds]
  db_instance_identifier = var.username
}

resource "null_resource" "check_rds_endpoint" {
  depends_on = [aws_db_instance.rds]

  provisioner "local-exec" {
    command = <<EOT
if [ "${data.aws_db_instance.database.address}" != "" ]; then
  echo "RDS endpoint is available: ${data.aws_db_instance.database.address}"
else
  echo "RDS endpoint is not available"
  exit 1
fi
EOT
  }
}


resource "aws_autoscaling_group" "app-asg" {
  depends_on = [aws_instance.nat, null_resource.check_rds_endpoint]
  max_size                  = 1
  min_size                  = 1
  desired_capacity          = 1
  name                      = "${var.project_name}_asg"
  health_check_grace_period = 300
  health_check_type         = "ELB"
  target_group_arns         = [aws_lb_target_group.tg.arn]
  vpc_zone_identifier       = [aws_subnet.private_1a_subnet.id, aws_subnet.private_1b_subnet.id]
  launch_template {
    id      = aws_launch_template.asg-lt.id
    version = aws_launch_template.asg-lt.latest_version
  }
}


data "aws_ami" "ubuntu-22-04" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20240411"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_launch_template" "asg-lt" {
  name                   = "${var.project_name}_lt"
  image_id               = data.aws_ami.ubuntu-22-04.id
  instance_type          = "t2.micro"
  key_name               = var.key_name
  iam_instance_profile {
    name = aws_iam_instance_profile.asgprofile.name
  }
  vpc_security_group_ids = [aws_security_group.ec2.id]
  user_data              = base64encode(templatefile("user-data.sh", { db-endpoint = aws_db_instance.rds.address, user = var.username, bucketname = aws_s3_bucket.capstonedjango.bucket, githubname = var.github-name}))
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_name}-asg-instance"
    }
  }
}