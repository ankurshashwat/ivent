variable "pipeline_name" {
  description = "Name of the CodePipeline"
  type        = string
}

variable "codepipeline_role_arn" {
  description = "ARN of the CodePipeline IAM role"
  type        = string
}

variable "codebuild_role_arn" {
  description = "ARN of the CodeBuild IAM role"
  type        = string
}

variable "codebuild_project_name" {
  description = "Name of the CodeBuild project"
  type        = string
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket for pipeline artifacts"
  type        = string
}

variable "github_connection_arn" {
  description = "ARN of the GitHub CodeStar connection"
  type        = string
}

variable "dynamodb_lock_table" {
  description = "Name of the DynamoDB table for Terraform state lock"
  type        = string
}