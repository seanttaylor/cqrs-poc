output "lambda_function_name" {
  description = "Name of the Lambda function"
  value = aws_lambda_function.hello_world.function_name
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value = aws_lambda_function.validate_incoming_msg_header.function_name
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value = aws_lambda_function.enrich_incoming_msg.function_name
}

output "api_gateway_base_url" {
  description = "Base URL for API Gateway stage"
  value = aws_apigatewayv2_stage.lambda.invoke_url
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value = aws_s3_bucket.lambda_bucket.id
}