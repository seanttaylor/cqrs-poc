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

################## LAMBDA GROUP DEPLOYMENT CONFIGURATION ################

variable "my_lambda_group_deployment_configuration" {
  type = map
  description = "Map of lambda configurations"
  default = {
    hello_world = {
      s3 = {
        archive_file = {
          source_dir  = "../lib/lambda/hello-world"
          output_path = "../dist/hello-world.zip"
        }
        bucket = "${local.app_owner}.lambda"
        object = {
          key = "/hello-world.zip"
          source = "../dist/hello-world.zip"
        }
      }
      lambda = {
        function_name = "hello-world-${local.git_commit_sha}"
        s3_key = "/hello-world.zip"
        runtime = "nodejs16.x"
        handler = "index.handler"
      }
      cloudwatch = {
        log_group = {
          name = "/aws/lambda/hello-world-${local.git_commit_sha}"
        }
      }
      api_gateway = {
        route_key = "GET /hello"
      }
      tags = {
        "app_owner" = "${local.app_owner}"
      }
    }
  }
}


################## AWS S3 BUCKET CONFIGURATION ###################

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

data "archive_file" "lambda" { 
  for_each = var.my_lambda_group_deployment_configuration

  type = "zip"
  source_dir  = each.value.s3.archive_file.source_dir
  output_path = each.value.s3.archive_file.output_path
}

resource "aws_s3_object" {
  for_each = var.my_lambda_group_deployment_configuration

  bucket = aws_s3_bucket.lambda_bucket.id
  
  key    = each.value.s3.object.key
  source = each.value.s3.archive_file.output_path
  
  etag = filemd5(each.value.s3.archive_file.output_path)
}


################## AWS LAMBDA CONFIGURATION ###################

resource "aws_lambda_function" {
  for_each = var.my_lambda_group_deployment_configuration
 
  function_name = each.value.lambda.function_name
  
  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = each.value.lambda.s3_key

  runtime = each.value.lambda.runtime
  handler = each.value.lambda.handler
  
  source_code_hash = data.archive_file.lambda.output_base64sha256

  role = aws_iam_role.lambda_exec.arn
}

resource "aws_cloudwatch_log_group" "hello_world" {
  for_each = var.my_lambda_group_deployment_configuration

  name = "/aws/lambda/${each.value.lambda.function_name}"

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
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
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

  integration_uri    = aws_lambda_function.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "hello_world" {
  for_each = var.my_lambda_group_deployment_configuration

  api_id = aws_apigatewayv2_api.lambda.id

  route_key = "${each.value.api_gateway.route_key}"
  target    = "integrations/${aws_apigatewayv2_integration.hello_world.id}"
}

resource "aws_cloudwatch_log_group" "api_gw" {
  name = "/aws/api_gw/${aws_apigatewayv2_api.lambda.name}"

  retention_in_days = 30
}

resource "aws_lambda_permission" "api_gw" {
  for_each = var.my_lambda_group_deployment_configuration

  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  
  function_name = each.value.lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"
}
