output "lambda_function_names" {
  description = "Name(s) of the lamba function(s)"
  value = {
    hello_world = aws_lambda_function.hello_world.function_name
    validate_incoming_msg_header = aws_lambda_function.validate_incoming_msg_header.function_name
    enrich_incoming_msg = aws_lambda_function.enrich_incoming_msg.function_name
    route_incoming_msg = aws_lambda_function.enrich_route_incoming_msg.function_name
    create_db_digest_record = aws_lambda_function.create_db_digest_record.function_name
  }
}

output "api_gateway_base_url" {
  description = "Base URL for API Gateway stage"
  value = aws_apigatewayv2_stage.lambda.invoke_url
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value = aws_s3_bucket.lambda_bucket.id
}