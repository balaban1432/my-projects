
# Create Lambda function
resource "aws_lambda_function" "s3dynamolambda" {
  filename      = "lambda_function_payload.zip"
  function_name = "S3DynamoLambda"  
  handler       = "lambda_function.lambda_handler"  
  role          = aws_iam_role.lambdaS3dynamoBasic.arn
  runtime       = "python3.8" 
  source_code_hash = data.archive_file.lambda.output_base64sha256
  timeout = 60
  # Environment variables
  environment {
    variables = {
      DynamoDBTableName = aws_dynamodb_table.my_dynamodb.name
    }
  }
}

# Archive Lambda function code from local directory into a .zip file

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "lambda.py"
  output_path = "lambda_function_payload.zip"
}

# Retrieve the AWS account ID
data "aws_caller_identity" "current" {}

# Allow S3 to invoke Lambda
resource "aws_lambda_permission" "allow_s3_invoke" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3dynamolambda.function_name
  principal     = "s3.amazonaws.com"
  source_account = data.aws_caller_identity.current.account_id
  source_arn    = "arn:aws:s3:::${aws_s3_bucket.capstonedjango.bucket}-encryption-service"
}