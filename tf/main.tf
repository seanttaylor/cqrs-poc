# See https://learn.hashicorp.com/tutorials/terraform/lambda-api-gateway?in=terraform/aws for details about this configuration.

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

  source_dir  = "${path.module}/lib/lambda/hello-world"
  output_path = "${path.module}/dist/hello-world.zip"
}

resource "aws_s3_object" "lambda_hello_world" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "hello-world.zip"
  source = data.archive_file.lambda_hello_world.output_path

  etag = filemd5(data.archive_file.lambda_hello_world.output_path)
}
