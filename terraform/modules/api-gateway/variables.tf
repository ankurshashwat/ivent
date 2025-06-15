variable "api_name" {
  description = "Name of the API Gateway"
  type        = string
}

variable "region" {
  description = "AWS region for the API Gateway"
  type        = string
  default     = "us-east-1"
}

variable "cognito_client_id" {
  description = "Client ID of the Cognito User Pool App Client"
  type        = string
}

variable "cognito_user_pool_arn" {
  description = "ARN of the Cognito User Pool"
  type        = string
}

variable "event_management_function_name" {
  description = "Name of the Event Management Lambda function"
  type        = string
}

variable "subscription_management_function_name" {
  description = "Name of the Subscription Management Lambda function"
  type        = string
}

variable "event_management_lambda_arn" {
  description = "ARN of the Event Management Lambda function"
  type        = string
}

variable "subscription_management_lambda_arn" {
  description = "ARN of the Subscription Management Lambda function"
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