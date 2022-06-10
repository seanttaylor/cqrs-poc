
terraform {
  backend "local" {}
}

provider "aws" {
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
  region                      = "us-east-1"
  s3_force_path_style         = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    sqs     = "http://0.0.0.0:4566"
  }
}

resource "aws_sqs_queue" "rt_telemetry_queue" {
  name                      = "rt_telemetry_queue"
  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10

  tags = {
    ApplicationOwner = "api@parcely"
  }
}