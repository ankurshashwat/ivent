output "event_management_lambda_arn" {
  description = "ARN of the Event Management Lambda function"
  value       = aws_lambda_function.event_management.arn
}

output "subscription_management_lambda_arn" {
  description = "ARN of the Subscription Management Lambda function"
  value       = aws_lambda_function.subscription_management.arn
}

output "notification_trigger_lambda_arn" {
  description = "ARN of the Notification Trigger Lambda function"
  value       = aws_lambda_function.notification_trigger.arn
}