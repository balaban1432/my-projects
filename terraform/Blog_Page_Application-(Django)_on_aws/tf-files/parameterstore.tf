data "aws_ssm_parameter" "db_password" {
  name = "/${var.username}/capstone/password"
}

data "aws_ssm_parameter" "db_username" {
  name = "/${var.username}/capstone/username"
}

data "aws_ssm_parameter" "git_hub_token" {
  name = "/${var.username}/capstone/token"
}
