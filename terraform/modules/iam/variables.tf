variable "lambda_role_name" {
  description = "Name of the Lambda IAM role"
  type        = string
}

variable "codepipeline_role_name" {
  description = "Name of the CodePipeline IAM role"
  type        = string
}

variable "codebuild_role_name" {
  description = "Name of the CodeBuild IAM role"
  type        = string
}

variable "events_table_arn" {
  description = "ARN of the Events DynamoDB table"
  type        = string
}

variable "subscriptions_table_arn" {
  description = "ARN of the Subscriptions DynamoDB table"
  type        = string
}

variable "events_table_stream_arn" {
  description = "ARN of the Events table stream"
  type        = string
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic"
  type        = string
}