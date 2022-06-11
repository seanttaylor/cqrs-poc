
terraform {
  backend "local" {}
}

provider "aws" {
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
  region                      = "us-east-1"
  s3_use_path_style           = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    s3     = "http://0.0.0.0:4566"
  }
}

locals {
  app_owner = "com.omegalabs.platform"
}


resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "lambda-bucket"

  force_destroy = true
  tags = {
    "app_owner" = "${local.app_owner}"
  }
}