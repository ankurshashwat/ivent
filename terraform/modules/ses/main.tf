resource "aws_ses_email_identity" "sender" {
  email = var.sender_email
}

resource "aws_sns_topic_policy" "event_notifications" {
  arn = var.sns_topic_arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ses.amazonaws.com"
        }
        Action = "sns:Publish"
        Resource = var.sns_topic_arn
        Condition = {
          StringEquals = {
            "AWS:SourceAccount" = var.aws_account_id
          }
        }
      }
    ]
  })
}