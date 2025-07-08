variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "aws_account_id" {
  description = "AWS account ID"
}

variable "bucket_name" {
  description = "S3 bucket name for Terraform state"
  type        = string
  default     = "ivent-tf-state-bucket"
}

variable "dynamodb_lock_table" {
  description = "DynamoDB lock table name"
  type        = string
  default     = "ivent-tf-lock"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnets" {
  description = "Private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "public_subnets" {
  description = "Public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "github_repo" {
  description = "GitHub repository"
  type        = string
}

variable "github_actions_role_name" {
  description = "Name of the IAM role for GitHub Actions"
  type        = string
}

variable "test_username" {
  description = "Test user username for Cognito authentication"
  type        = string
}

variable "test_password" {
  description = "Test user password for Cognito authentication"
  type        = string
  sensitive   = true
}

variable "sender_email" {
  description = "Sender email address for SES"
  type        = string
}