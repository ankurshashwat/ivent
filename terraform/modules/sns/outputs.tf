output "sns_topic_arn" {
  description = "SNS Topic ARN"
  value       = aws_sns_topic.event_notifications.arn
}