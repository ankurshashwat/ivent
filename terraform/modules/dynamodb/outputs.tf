output "events_table_arn" {
  description = "ARN of the Events table"
  value       = aws_dynamodb_table.events_table.arn
}

output "subscriptions_table_arn" {
  description = "ARN of the Subscriptions table"
  value       = aws_dynamodb_table.subscriptions_table.arn
}

output "events_table_name" {
  description = "Name of the Events table"
  value       = aws_dynamodb_table.events_table.name
}

output "subscriptions_table_name" {
  description = "Name of the Subscriptions table"
  value       = aws_dynamodb_table.subscriptions_table.name
}

output "events_table_stream_arn" {
  description = "Stream ARN of the Events table"
  value       = aws_dynamodb_table.events_table.stream_arn
}