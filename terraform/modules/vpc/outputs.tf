output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.event_announcement_vpc.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public_subnets[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private_subnets[*].id
}

output "lambda_sg_id" {
  description = "ID of the Lambda security group"
  value       = aws_security_group.lambda_sg.id
}