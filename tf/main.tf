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

################## AWS S3 BUCKET CONFIGURATION ###################

resource "random_pet" "lambda_bucket_name" {
  prefix = "hello-world"
  length = 4
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = random_pet.lambda_bucket_name.id

  force_destroy = true
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

resource "aws_s3_object" "lambda_hello_world" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "hello-world.zip"
  source = data.archive_file.lambda_hello_world.output_path

  etag = filemd5(data.archive_file.lambda_hello_world.output_path)
}


################## AWS LAMBDA CONFIGURATION ###################

resource "aws_lambda_function" "hello_world" {
  function_name = "HelloWorld"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_hello_world.key

  runtime = "nodejs16.x"
  handler = "hello.handler"

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
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
