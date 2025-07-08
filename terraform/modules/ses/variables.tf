variable "sender_email" {
  description = "Sender email address for SES"
  type        = string
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic"
  type        = string
}

variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
}