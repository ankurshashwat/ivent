variable "lambda_role_name" {
  description = "Name of the Lambda IAM role"
  type        = string
}

variable "github_actions_role_name" {
  description = "Name of the IAM role for GitHub Actions"
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