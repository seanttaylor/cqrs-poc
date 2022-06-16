# See https://learn.hashicorp.com/tutorials/terraform/lambda-api-gateway?in=terraform/aws for details about this configuration.

################## TERRAFORM CONFIGURATION ###################

variable "access_key" {
  type        = string
  description = "AWS Access Key ID"
}

variable "secret_key" {
  type        = string
  description = "AWS Secret Access Key" 
}

variable "account_id" {
  type        = string
  description = "AWS Account ID"
  default     = ""
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  access_key                  = var.access_key
  secret_key                  = var.secret_key 
  #profile                     = "default"
  region                      = "us-east-1"
}

variable "MY_KAFKA_BOOTSTRAP_SERVERS" {
  type        = string
  description = "Comma-separated list of self-managed Kafka bootstrap servers"
  default     = ""
}

variable "MY_KAFKA_CLUSTER_API_KEY" {
  type        = string
  description = "API key a Kafka cluster, alias for`username` in the Basic Auth authentication scheme"
  default     = ""
}

variable "MY_KAFKA_CLUSTER_SECRET" {
  type        = string
  description = "Secret for a Kafka cluster, alias for`password` in the Basic Auth authentication scheme"
  default     = ""
}

locals {
  app_owner = "com.omegalabs.platform"
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "${local.app_owner}.softserve"

  force_destroy = true
  tags = {
    "app_owner" = "${local.app_owner}"
  }
}

resource "aws_s3_bucket_acl" "lambda_bucket" {
  bucket = aws_s3_bucket.lambda_bucket.id
  acl    = "private"
}

data "archive_file" "lambda_hello_world" {
  type = "zip"

  source_dir  = "../../lib/lambda/hello-world"
  output_path = "../../dist/hello-world.zip"
}

resource "aws_s3_object" "lambda_hello_world" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "hello-world.zip"
  source = data.archive_file.lambda_hello_world.output_path

  etag = filemd5(data.archive_file.lambda_hello_world.output_path)
}

resource "aws_lambda_function" "hello_world" {
  function_name = "hello-world"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_hello_world.key

  runtime = "nodejs16.x"
  handler = "index.handler"

  source_code_hash = data.archive_file.lambda_hello_world.output_base64sha256

  role = aws_iam_role.lambda_exec.arn
}

resource "aws_cloudwatch_log_group" "hello_world" {
  name = "/aws/lambda/${aws_lambda_function.hello_world.function_name}"

  retention_in_days = 30
}

resource "aws_iam_role" "lambda_exec" {
  name = "serverless_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })

  inline_policy {
     policy = data.aws_iam_policy_document.lambda_exec.json
  }
}

data "aws_iam_policy_document" "lambda_exec" {
  statement {
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    effect = "Allow"
    resources = ["*"]
  }
}

resource "aws_secretsmanager_secret" "lambda_event_source" {
  name = "lambda-secret"
}

resource "aws_secretsmanager_secret_version" "kafka_auth" {
  secret_id     = aws_secretsmanager_secret.lambda_event_source.id
  secret_string = jsonencode({"username": "${var.MY_KAFKA_CLUSTER_API_KEY}", "password": "${var.MY_KAFKA_CLUSTER_SECRET}"})
}

resource "aws_lambda_event_source_mapping" "example" {
  function_name     = aws_lambda_function.hello_world.arn
  topics            = ["hello_world"]
  starting_position = "TRIM_HORIZON"

  self_managed_event_source {
    endpoints = {
      KAFKA_BOOTSTRAP_SERVERS = "kafka:9092"
    }
  }

  source_access_configuration {
    # See https://github.com/localstack/localstack/issues/6121#issuecomment-1134250573
    type = "BASIC_AUTH"
    uri = aws_secretsmanager_secret.lambda_event_source.arn
  }

  depends_on = [
    aws_secretsmanager_secret.lambda_event_source
  ]

}
