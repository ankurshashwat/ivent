variable "event_management_function_name" {
  description = "Name of the Event Management Lambda function"
  type        = string
}

variable "subscription_management_function_name" {
  description = "Name of the Subscription Management Lambda function"
  type        = string
}

variable "notification_trigger_function_name" {
  description = "Name of the Notification Trigger Lambda function"
  type        = string
}

variable "lambda_role_arn" {
  description = "ARN of the IAM role for Lambda functions"
  type        = string
}

variable "events_table_name" {
  description = "Name of the Events DynamoDB table"
  type        = string
}

variable "subscriptions_table_name" {
  description = "Name of the Subscriptions DynamoDB table"
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

variable "private_subnet_ids" {
  description = "List of private subnet IDs for Lambda VPC configuration"
  type        = list(string)
}

variable "lambda_sg_id" {
  description = "ID of the Lambda security group"
  type        = string
}