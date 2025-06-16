# modules/cicd/main.tf
resource "aws_codepipeline" "pipeline" {
  name     = var.pipeline_name
  role_arn = var.codepipeline_role_arn
  artifact_store {
    location = var.s3_bucket_name
    type     = "S3"
  }
  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]
      configuration = {
        ConnectionArn    = var.github_connection_arn
        FullRepositoryId = "ankurshashwat/ivent"
        BranchName       = "main"
      }
    }
  }
  stage {
    name = "Plan"
    action {
      name             = "Terraform_Plan"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["plan_output"]
      version          = "1"
      configuration = {
        ProjectName = aws_codebuild_project.plan.name
      }
    }
  }
  stage {
    name = "Apply"
    action {
      name             = "Terraform_Apply"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      version          = "1"
      configuration = {
        ProjectName = aws_codebuild_project.apply.name
      }
    }
  }
}

resource "aws_codebuild_project" "plan" {
  name          = "${var.codebuild_project_name}-plan"
  service_role  = var.codebuild_role_arn
  artifacts {
    type = "CODEPIPELINE"
  }
  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:5.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true
    environment_variable {
      name  = "TF_STATE_BUCKET"
      value = var.s3_bucket_name
    }
    environment_variable {
      name  = "TF_LOCK_TABLE"
      value = var.dynamodb_lock_table
    }
  }
  source {
    type      = "CODEPIPELINE"
    buildspec = <<-EOF
      version: 0.2
      phases:
        install:
          commands:
            - apt-get update
            - apt-get install -y unzip
            - curl -o terraform.zip https://releases.hashicorp.com/terraform/1.5.7/terraform_1.5.7_linux_amd64.zip
            - unzip terraform.zip
            - mv terraform /usr/local/bin/
        build:
          commands:
            - cd $CODEBUILD_SRC_DIR
            - terraform init -backend-config="bucket=$TF_STATE_BUCKET" -backend-config="key=terraform.tfstate" -backend-config="dynamodb_table=$TF_LOCK_TABLE" -backend-config="region=us-east-1"
            - terraform plan -out=tfplan
      artifacts:
        files:
          - tfplan
    EOF
  }
}

resource "aws_codebuild_project" "apply" {
  name          = "${var.codebuild_project_name}-apply"
  service_role  = var.codebuild_role_arn
  artifacts {
    type = "CODEPIPELINE"
  }
  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:5.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true
    environment_variable {
      name  = "TF_STATE_BUCKET"
      value = var.s3_bucket_name
    }
    environment_variable {
      name  = "TF_LOCK_TABLE"
      value = var.dynamodb_lock_table
    }
  }
  source {
    type      = "CODEPIPELINE"
    buildspec = <<-EOF
      version: 0.2
      phases:
        install:
          commands:
            - apt-get update
            - apt-get install -y unzip
            - curl -o terraform.zip https://releases.hashicorp.com/terraform/1.5.7/terraform_1.5.7_linux_amd64.zip
            - unzip terraform.zip
            - mv terraform /usr/local/bin/
        build:
          commands:
            - cd $CODEBUILD_SRC_DIR
            - terraform init -backend-config="bucket=$TF_STATE_BUCKET" -backend-config="key=terraform.tfstate" -backend-config="region=us-east-1" -backend-config="dynamodb_table=$TF_LOCK_TABLE"
            - terraform apply -auto-approve
    EOF
  }
}