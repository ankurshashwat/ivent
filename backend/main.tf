terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

module "backend" {
  source        = "../terraform/modules/backend"
  bucket_name   = var.bucket_name
  table_name    = var.table_name
  project       = var.project
  iam_user_arn  = var.iam_user_arn
}