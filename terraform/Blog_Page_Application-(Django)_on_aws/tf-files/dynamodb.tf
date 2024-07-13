resource "aws_dynamodb_table" "my_dynamodb" {
  name           =  "${var.project_name}_dynamo"
  billing_mode   = "PROVISIONED" 
  hash_key       = "id" 

  # Define capacity units using Terraform variables
  read_capacity  = var.ReadScalingMin
  write_capacity = var.WriteScalingMin

  # Define the primary key attribute
  attribute {
    name = "id"
    type = "S"
  }
}
