# API Gateway
output "api_gateway_url" {
  description = "API Gateway invocation URL"
  value       = module.api_gateway.api_invoke_url
}

# SNS
output "sns_topic_arn" {
  description = "SNS Topic ARN"
  value       = module.sns.sns_topic_arn
}

# VPC
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

output "lambda_sg_id" {
  description = "ID of the Lambda security group"
  value       = module.vpc.lambda_sg_id
}

# Lambda
output "event_management_lambda_arn" {
  description = "ARN of the Event Management Lambda function"
  value       = module.lambda.event_management_lambda_arn
}

output "subscription_management_lambda_arn" {
  description = "ARN of the Subscription Management Lambda function"
  value       = module.lambda.subscription_management_lambda_arn
}

output "notification_trigger_lambda_arn" {
  description = "ARN of the Notification Trigger Lambda function"
  value       = module.lambda.notification_trigger_lambda_arn
}

# IAM
output "lambda_role_arn" {
  description = "ARN of the Lambda IAM role"
  value       = module.iam.lambda_role_arn
}

# DynamoDB
output "events_table_arn" {
  description = "ARN of the Events table"
  value       = module.dynamodb.events_table_arn
}

output "subscriptions_table_arn" {
  description = "ARN of the Subscriptions table"
  value       = module.dynamodb.subscriptions_table_arn
}

output "events_table_name" {
  description = "Name of the Events table"
  value       = module.dynamodb.events_table_name
}

output "subscriptions_table_name" {
  description = "Name of the Subscriptions table"
  value       = module.dynamodb.subscriptions_table_name
}

output "events_table_stream_arn" {
  description = "Stream ARN of the Events table"
  value       = module.dynamodb.events_table_stream_arn
}

# Cognito
output "user_pool_id" {
  description = "Cognito User Pool ID"
  value       = module.cognito.user_pool_id
}

output "user_pool_arn" {
  description = "Cognito User Pool ARN"
  value       = module.cognito.user_pool_arn
}

output "client_id" {
  description = "Cognito User Pool Client ID"
  value       = module.cognito.client_id
}