data "aws_vpc" "selected" {
  default = true
}

data "aws_subnets" "default-vpc-subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
}

data "aws_subnet" "public" {
  for_each = toset(data.aws_subnets.default-vpc-subnets.ids)
  id       = each.value
}

resource "aws_alb" "ALB" {
  name               = var.owner
  ip_address_type    = "ipv4"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ALB-sec-grp.id]
  subnets            = [for subnet in data.aws_subnet.public : subnet.id]
}

resource "aws_alb_target_group" "alb-target" {
  name        = var.owner
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.selected.id
  target_type = "instance"
  health_check {
    healthy_threshold   = 3
    interval            = 20
    unhealthy_threshold = 3
    timeout             = 5
    path                = "/"
    protocol            = "HTTP"
  }
}

resource "aws_alb_listener" "my-listener" {
  load_balancer_arn = aws_alb.ALB.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.alb-target.arn
  }
}


resource "aws_autoscaling_group" "ASG" {
  desired_capacity    = 2
  max_size            = 3
  min_size            = 1
  name                = var.owner
  health_check_type   = "ELB"
  target_group_arns   = [aws_alb_target_group.alb-target.arn]
  vpc_zone_identifier = aws_alb.ALB.subnets

  launch_template {
    id      = aws_launch_template.web-server.id
    version = aws_launch_template.web-server.latest_version
  }
}
