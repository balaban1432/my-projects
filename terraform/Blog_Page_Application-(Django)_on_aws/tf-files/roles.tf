# creates SSM FullAccees and S3 Fullacess role for ec2 instanes 

data "aws_iam_policy_document" "instance_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "instanceS3andSSm" {
  name               = "${var.project_name}_s3andSSM"
  assume_role_policy = data.aws_iam_policy_document.instance_assume_role_policy.json
  managed_policy_arns = [var.ssmfullaccesspolicy_arn, var.s3fullaccesspolicy_arn]
}


resource "aws_iam_instance_profile" "asgprofile" {
  name = "asg_profile"
  role = aws_iam_role.instanceS3andSSm.name
}


# creates S3 Fullacess, DynamoDb Fullacees and lambda basic Execution role for Lambda 

data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambdaS3dynamoBasic" {
  name               = "${var.project_name}_lambdaS3dynamoBasic"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
  managed_policy_arns = [var.lambdabasicexecutionpolicy_arn, var.s3fullaccesspolicy_arn, var.dynamodbfullaccesspolicy_arn]
}
