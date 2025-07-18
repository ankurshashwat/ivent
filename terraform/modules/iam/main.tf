resource "aws_iam_openid_connect_provider" "github_actions" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1"
  ]

  tags = {
    Name = "GitHubActionsOIDC"
  }
}

resource "aws_iam_role" "lambda_role" {
  name = var.lambda_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "${var.lambda_role_name}-policy"
  role = aws_iam_role.lambda_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:Scan",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:GetRecords",
          "dynamodb:GetShardIterator",
          "dynamodb:DescribeStream",
          "dynamodb:ListStreams",
          "dynamodb:DescribeContinuousBackups",
          "dynamodb:DescribeTable"
        ]
        Resource = [
          var.events_table_arn,
          var.subscriptions_table_arn,
          var.events_table_stream_arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "sns:Publish",
          "sns:Subscribe",
          "sns:GetTopicAttributes",
          "sns:SetTopicAttributes",
          "sns:ListTagsForResource",
          "sns:ListSubscriptionsByTopic"
        ]
        Resource = "arn:aws:sns:us-east-1:${var.aws_account_id}:IventTopic"
      },
      {
        Effect = "Allow"
        Action = [
          "ses:SendEmail",
          "ses:SendRawEmail"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "xray:PutTraceSegments",
          "xray:PutTelemetryRecords"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "github_actions_role" {
  name = var.github_actions_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github_actions.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
            "token.actions.githubusercontent.com:sub" = "repo:ankurshashwat/ivent:ref:refs/heads/main"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "github_actions_policy" {
  name = "${var.github_actions_role_name}-policy"
  role = aws_iam_role.github_actions_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:*"
        ]
        Resource = [
          "arn:aws:s3:::ivent-tf-st",
          "arn:aws:s3:::ivent-tf-st/*",
          "arn:aws:s3:::ivent-tf-st-dev",
          "arn:aws:s3:::ivent-tf-st-dev/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:*"
        ]
        Resource = [
          var.events_table_arn,
          var.subscriptions_table_arn,
          var.events_table_stream_arn,
          "arn:aws:dynamodb:us-east-1:${var.aws_account_id}:table/ivent-tf-lock"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:*"
        ]
        Resource = [
          "arn:aws:logs:us-east-1:${var.aws_account_id}:log-group:/aws/*",
          "arn:aws:logs:us-east-1:${var.aws_account_id}:log-group:/aws/*:log-stream:*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "cognito-idp:*"
        ]
        Resource = "arn:aws:cognito-idp:us-east-1:${var.aws_account_id}:userpool/*"
      },
      {
        Effect = "Allow"
        Action = [
          "sns:*"
        ]
        Resource = "arn:aws:sns:us-east-1:${var.aws_account_id}:IventTopic"
      },
      {
        Effect = "Allow"
        Action = [
          "ses:*"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:*"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "lambda:*"
        ]
        Resource = [
          "arn:aws:lambda:us-east-1:${var.aws_account_id}:*",
          "arn:aws:lambda:us-east-1:${var.aws_account_id}:event-source-mapping:*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "apigateway:*"
        ]
        Resource = [
          "arn:aws:apigateway:us-east-1::/restapis/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ssm:*"
        ]
        Resource = "arn:aws:ssm:us-east-1:${var.aws_account_id}:parameter/ivent/*"
      },
      {
        Effect = "Allow"
        Action = [
          "iam:*"
        ]
        Resource = [
          aws_iam_role.lambda_role.arn,
          aws_iam_role.github_actions_role.arn,
          "arn:aws:iam::${var.aws_account_id}:policy/*",
          "arn:aws:iam::${var.aws_account_id}:role/Ivent*",
          "arn:aws:iam::${var.aws_account_id}:oidc-provider/token.actions.githubusercontent.com"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:*"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "events:*"
        ]
        Resource = "arn:aws:events:us-east-1:${var.aws_account_id}:event-bus/*"
      },
      {
        Effect = "Allow"
        Action = [
          "xray:*"
        ]
        Resource = "*"
      }
    ]
  })
}