output "bucket_name" {
  description = "S3 bucket for Terraform state"
  value       = aws_s3_bucket.state.bucket
}

output "table_name" {
  description = "DynamoDB table for state locking"
  value       = aws_dynamodb_table.lock.name
}