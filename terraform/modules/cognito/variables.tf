variable "user_pool_name" {
  description = "Name of the Cognito user pool"
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