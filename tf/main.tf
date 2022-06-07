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

variable "TFC_CONFIGURATION_VERSION_GIT_BRANCH" {
  type = string
  default = ""
}

variable "TFC_CONFIGURATION_VERSION_GIT_COMMIT_SHA" {
  type = string
  default = ""
}

locals {
  git_commit_sha = substr("${var.TFC_CONFIGURATION_VERSION_GIT_COMMIT_SHA}", -40, 6)
  app_owner = "com.omegalabs.platform"
}

################## AWS S3 BUCKET CONFIGURATION ###################

#resource "random_pet" "lambda_bucket_name" {
#  prefix = "hello-world"
#  length = 4
#}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "${local.app_owner}.lambda"

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

  source_dir  = "../lib/lambda/hello-world"
  output_path = "../dist/hello-world.zip"
}



data "archive_file" "lambda_enrich_incoming_msg" {
  type = "zip"

  source_dir  = "../lib/lambda/enrich-incoming-msg"
  output_path = "../dist/enrich-incoming-msg.zip"
}

data "archive_file" "lambda_route_incoming_msg" {
  type = "zip"

  source_dir  = "../lib/lambda/route-incoming-msg"
  output_path = "../dist/route-incoming-msg.zip"
}

data "archive_file" "lambda_create_db_digest_record" {
  type = "zip"

  source_dir  = "../lib/lambda/create-db-digest-record"
  output_path = "../dist/create-db-digest-record.zip"
}

resource "aws_s3_object" "lambda_hello_world" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "hello-world.zip"
  source = data.archive_file.lambda_hello_world.output_path

  etag = filemd5(data.archive_file.lambda_hello_world.output_path)
}



resource "aws_s3_object" "lambda_enrich_incoming_msg" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "/ice-cream-pipeline/enrich-incoming-msg-header.zip"
  source = data.archive_file.lambda_enrich_incoming_msg.output_path

  etag = filemd5(data.archive_file.lambda_enrich_incoming_msg.output_path)
}

resource "aws_s3_object" "lambda_route_incoming_msg" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "/ice-cream-pipeline/route-incoming-msg-header.zip"
  source = data.archive_file.lambda_route_incoming_msg.output_path

  etag = filemd5(data.archive_file.lambda_route_incoming_msg.output_path)
}

resource "aws_s3_object" "lambda_create_db_digest_record" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "/ice-cream-pipeline/create-db-digest-record.zip"
  source = data.archive_file.lambda_create_db_digest_record.output_path

  etag = filemd5(data.archive_file.lambda_create_db_digest_record.output_path)
}

################## AWS API GATEWAY CONFIGURATION ###################

resource "aws_apigatewayv2_api" "lambda" {
  name          = "serverless_lambda_gw"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "lambda" {
  api_id = aws_apigatewayv2_api.lambda.id

  name        = "serverless_lambda_stage"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }
}

resource "aws_apigatewayv2_integration" "hello_world" {
  api_id = aws_apigatewayv2_api.lambda.id

  integration_uri    = aws_lambda_function.hello_world.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "hello_world" {
  api_id = aws_apigatewayv2_api.lambda.id

  route_key = "GET /hello"
  target    = "integrations/${aws_apigatewayv2_integration.hello_world.id}"
}

resource "aws_cloudwatch_log_group" "api_gw" {
  name = "/aws/api_gw/${aws_apigatewayv2_api.lambda.name}"

  retention_in_days = 30
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.hello_world.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"
}