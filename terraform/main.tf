terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket         = "ivent-tf-st"
    key            = "state/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "ivent-tf-lock"
  }
}

provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source             = "./modules/vpc"
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b"]
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets    = ["10.0.3.0/24", "10.0.4.0/24"]
}

module "cognito" {
  source             = "./modules/cognito"
  user_pool_name     = "ivent-user-pool"
  test_username      = var.test_username
  test_password      = var.test_password
}

module "ses" {
  source          = "./modules/ses"
  sender_email    = var.sender_email
  sns_topic_arn   = module.sns.sns_topic_arn
  aws_account_id  = var.aws_account_id
}

module "sns" {
  source             = "./modules/sns"
  sns_topic_name     = "IventTopic"
}

module "dynamodb" {
  source                   = "./modules/dynamodb"
  events_table_name        = "Events"
  subscriptions_table_name = "Subscriptions"
}

module "iam" {
  source                   = "./modules/iam"
  aws_account_id           = var.aws_account_id
  lambda_role_name         = "IventLambdaRole"
  github_actions_role_name = "IventGithubActionsRole"
  events_table_arn         = module.dynamodb.events_table_arn
  subscriptions_table_arn  = module.dynamodb.subscriptions_table_arn
  sns_topic_arn            = module.sns.sns_topic_arn
  events_table_stream_arn  = module.dynamodb.events_table_stream_arn
}

module "lambda" {
  source                                = "./modules/lambda"
  event_management_function_name        = "EventManagement"
  subscription_management_function_name = "SubscriptionManagement"
  notification_trigger_function_name    = "NotificationTrigger"
  lambda_role_arn            = module.iam.lambda_role_arn
  events_table_name          = module.dynamodb.events_table_name
  subscriptions_table_name   = module.dynamodb.subscriptions_table_name
  events_table_stream_arn    = module.dynamodb.events_table_stream_arn
  sns_topic_arn              = module.sns.sns_topic_arn
  sender_email               = var.sender_email
  private_subnet_ids         = module.vpc.private_subnet_ids
  lambda_sg_id               = module.vpc.lambda_sg_id
}

module "api_gateway" {
  source                                = "./modules/api-gateway"
  api_name                              = "IventAPI"
  cognito_user_pool_arn                 = module.cognito.user_pool_arn
  cognito_client_id                     = module.cognito.client_id
  event_management_function_name        = "EventManagement"
  subscription_management_function_name = "SubscriptionManagement"
  event_management_lambda_arn           = module.lambda.event_management_lambda_arn
  subscription_management_lambda_arn    = module.lambda.subscription_management_lambda_arn
  region                                = var.aws_region
  test_username                         = var.test_username
  test_password                         = var.test_password
  depends_on                            = [module.lambda, module.cognito]
}