variable "bucket_name" {
  description = "S3 bucket name for Terraform state"
  type        = string
}

variable "table_name" {
  description = "DynamoDB table name for state locking"
  type        = string
}

variable "project" {
  description = "Project name for tagging"
  type        = string
}

variable "iam_user_arn" {
  description = "IAM user ARN for bucket access"
  type        = string
}