data "archive_file" "event_management_zip" {
  type        = "zip"
  source_file = "${path.module}/../../lambda_functions/event_management/lambda_function.py"
  output_path = "${path.module}/../../lambda_functions/event_management/event_management.zip"
}

data "archive_file" "subscription_management_zip" {
  type        = "zip"
  source_file = "${path.module}/../../lambda_functions/subscription_management/lambda_function.py"
  output_path = "${path.module}/../../lambda_functions/subscription_management/subscription_management.zip"
}

data "archive_file" "notification_trigger_zip" {
  type        = "zip"
  source_file = "${path.module}/../../lambda_functions/notification_trigger/lambda_function.py"
  output_path = "${path.module}/../../lambda_functions/notification_trigger/notification_trigger.zip"
}

# Event Management Lambda function
resource "aws_lambda_function" "event_management" {
  function_name = var.event_management_function_name
  runtime       = "python3.12"
  handler       = "lambda_function.lambda_handler"
  filename      = data.archive_file.event_management_zip.output_path
  source_code_hash = data.archive_file.event_management_zip.output_base64sha256
  role          = var.lambda_role_arn
  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [var.lambda_sg_id]
  }
  environment {
    variables = {
      DYNAMODB_TABLE = var.events_table_name
    }
  }
  tracing_config {
    mode = "Active"
  }
  depends_on = [data.archive_file.event_management_zip]
}

# Subscription Management Lambda function
resource "aws_lambda_function" "subscription_management" {
  function_name = var.subscription_management_function_name
  runtime       = "python3.12"
  handler       = "lambda_function.lambda_handler"
  filename      = data.archive_file.subscription_management_zip.output_path
  source_code_hash = data.archive_file.subscription_management_zip.output_base64sha256
  role          = var.lambda_role_arn
  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [var.lambda_sg_id]
  }
  environment {
    variables = {
      DYNAMODB_TABLE = var.subscriptions_table_name
      SNS_TOPIC_ARN  = var.sns_topic_arn
    }
  }
  tracing_config {
    mode = "Active"
  }
  depends_on = [data.archive_file.subscription_management_zip]
}

# Notification Trigger Lambda function
resource "aws_lambda_function" "notification_trigger" {
  function_name = var.notification_trigger_function_name
  runtime       = "python3.12"
  handler       = "lambda_function.lambda_handler"
  filename      = data.archive_file.notification_trigger_zip.output_path
  source_code_hash = data.archive_file.notification_trigger_zip.output_base64sha256
  role          = var.lambda_role_arn
  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [var.lambda_sg_id]
  }
  environment {
    variables = {
      SNS_TOPIC_ARN = var.sns_topic_arn
    }
  }
  tracing_config {
    mode = "Active"
  }
  depends_on = [data.archive_file.notification_trigger_zip]
}

# DynamoDB Stream trigger for Notification Lambda
resource "aws_lambda_event_source_mapping" "dynamodb_trigger" {
  event_source_arn  = var.events_table_stream_arn
  function_name     = aws_lambda_function.notification_trigger.arn
  starting_position = "LATEST"
}